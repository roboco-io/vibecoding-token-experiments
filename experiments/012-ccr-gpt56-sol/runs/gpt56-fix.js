// EXP-012: OpenAI gpt-5.6-sol 파라미터 보정 + usage 탭 (responses API 경유)
// - reasoning effort "medium" 고정 (실험 조건)
// - chat/completions는 function tools + reasoning_effort 조합 미지원(400)이라 responses API 사용
// - responses 스트리밍은 stream_options 미지원 → ccr 변환에서 usage가 유실되므로
//   response.completed 이벤트를 탭해 ~/ralph-exp012/usage-tap.jsonl 에 기록 (스트림 무변조)
const fs = require("fs");
const os = require("os");
const path = require("path");
const TAP = path.join(os.homedir(), "ralph-exp012", "usage-tap.jsonl");

class Gpt56FixTransformer {
  name = "gpt56-fix";

  async transformRequestIn(request) {
    request.reasoning = { effort: "medium" };
    delete request.reasoning_effort;
    delete request.temperature;
    return request;
  }

  async transformResponseOut(response) {
    const ct = response.headers.get("content-type") || "";
    if (!ct.includes("text/event-stream") || !response.body) return response;
    let buf = "";
    const decoder = new TextDecoder();
    const tap = new TransformStream({
      transform(chunk, controller) {
        controller.enqueue(chunk);
        try {
          buf += decoder.decode(chunk, { stream: true });
          let nl;
          while ((nl = buf.indexOf("\n")) >= 0) {
            const line = buf.slice(0, nl);
            buf = buf.slice(nl + 1);
            if (!line.startsWith("data:")) continue;
            const payload = line.slice(5).trim();
            if (!payload.includes('"response.completed"')) continue;
            const ev = JSON.parse(payload);
            const usage = ev.response && ev.response.usage;
            if (usage) {
              fs.appendFileSync(
                TAP,
                JSON.stringify({ ts: new Date().toISOString(), id: ev.response.id, usage }) + "\n"
              );
            }
          }
        } catch (e) {
          /* 탭 실패는 본 스트림에 영향 주지 않음 */
        }
      },
    });
    return new Response(response.body.pipeThrough(tap), {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers,
    });
  }
}
module.exports = Gpt56FixTransformer;
