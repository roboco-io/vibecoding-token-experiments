# Claude Code 커스텀 백엔드(타사 LLM) 설정 가이드

Claude Code를 OpenAI 호환 API만 제공하는 타사 모델(Upstage Solar 등)로 돌리기 위한 검증된 설정. Solar Pro 3 연동 작업(2026-07)에서 실측·검증한 내용의 정리이며, 향후 Solar-Open-2 등 다른 모델 실험에 재사용한다.

## 1. 기본 구조

Claude Code는 Anthropic Messages 프로토콜(`/v1/messages`)만 사용한다. OpenAI 호환 API에 연결하려면 **변환 프록시가 필수**이며, claude-code-router(CCR)가 실전 검증됐다.

```
Claude Code ──(Anthropic 형식)──> CCR :3456 ──(OpenAI 형식)──> 타사 API
```

## 2. claude-code-router 설치 — 반드시 1.x 고정

```bash
npm install -g @musistudio/claude-code-router@1.0.73
```

- **v3.x 금지**: v3는 sqlite + 관리 UI 기반이라 config.json을 읽지 않고, 헤드리스 자동화가 안 된다. 1.0.73이 config.json 기반의 마지막 검증 버전.
- asdf 환경에서는 설치 후 `asdf reshim nodejs` 필요.

`~/.claude-code-router/config.json` (권한 600 권장 — API 키 평문 포함):

```json
{
  "LOG": true,
  "PORT": 3456,
  "API_TIMEOUT_MS": 600000,
  "transformers": [
    { "path": "/Users/<user>/.claude-code-router/plugins/solar-fix.js" }
  ],
  "Providers": [
    {
      "name": "upstage",
      "api_base_url": "https://api.upstage.ai/v1/chat/completions",
      "api_key": "<UPSTAGE_API_KEY>",
      "models": ["solar-pro3", "solar-mini"],
      "transformer": { "use": ["solar-fix", "streamoptions"] }
    }
  ],
  "Router": {
    "default": "upstage,solar-pro3",
    "background": "upstage,solar-mini",
    "think": "upstage,solar-pro3",
    "longContext": "upstage,solar-pro3"
  }
}
```

## 3. 필수 transformer 2개

### 3-1. `streamoptions` (내장) — usage 계측의 핵심

스트리밍 요청에서 usage가 유실되면 **Claude Code 세션 JSONL의 토큰이 전부 0**으로 기록된다. 내장 `streamoptions` transformer를 provider 체인에 넣으면 SSE 마지막 청크에 usage가 포함되고, CCR이 이를 Anthropic 형식으로 되돌려 세션 로그 집계(`aggregate_tokens.py`, ccusage)가 정상 동작한다.

- 부가 발견: Upstage는 OpenAI식 자동 프롬프트 캐싱을 제공하며(`prompt_tokens_details.cached_tokens`), CCR이 이를 `cache_read_input_tokens`로 매핑한다.

### 3-2. 커스텀 파라미터 보정 (예: `solar-fix`)

Claude Code가 thinking을 켜면 CCR이 OpenRouter식 `reasoning` 객체를 붙이는데, 이를 모르는 API는 400을 반환한다(`Unrecognized request arguments supplied: reasoning`). 커스텀 transformer로 대상 API의 파라미터로 변환한다:

```js
// ~/.claude-code-router/plugins/solar-fix.js
class SolarFixTransformer {
  name = "solar-fix";
  constructor(options) { this.effort = (options && options.effort) || "high"; }
  async transformRequestIn(request) {
    if (request.reasoning !== undefined) {
      delete request.reasoning;
      if (request.model && String(request.model).startsWith("solar-pro")) {
        request.reasoning_effort = this.effort;   // Upstage식 reasoning 파라미터
      }
    }
    return request;
  }
}
module.exports = SolarFixTransformer;
```

- CCR은 `transformers: [{path, options}]`로 로드하고 `new Class(options)` 후 `name` 프로퍼티로 등록한다. 등록 확인: `~/.claude-code-router/logs/ccr-*.log`에서 `register transformer: solar-fix`.
- provider의 `transformer.use` 체인은 OpenAI 형식으로 변환된 요청에 순서대로 적용된다.

## 4. Claude Code 실행 환경변수

```bash
env -u ANTHROPIC_API_KEY \
  ANTHROPIC_BASE_URL=http://127.0.0.1:3456 \
  ANTHROPIC_AUTH_TOKEN=test \
  ANTHROPIC_MODEL="upstage,solar-pro3" \
  ANTHROPIC_SMALL_FAST_MODEL="upstage,solar-mini" \
  CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1 \
  claude -p "<프롬프트>" --dangerously-skip-permissions < /dev/null
```

- `env -u ANTHROPIC_API_KEY`: 진짜 Anthropic 키가 남아 있으면 자격증명 충돌·과금 사고. 반드시 제거.
- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`: beta 헤더로 인한 비Anthropic 백엔드 4xx 방지.
- 모델 ID는 CCR 형식 `provider,model`.
- headless 파이프에서 stdin 경고가 나오면 `< /dev/null`.

## 5. 서비스 기동·재시작의 함정

```bash
ccr stop; lsof -ti :3456 | xargs kill -9 2>/dev/null   # 확실한 정지
nohup ccr start > ccr.log 2>&1 & disown                 # 분리 기동 (ccr start는 포그라운드 블로킹)
```

- **`pkill -f claude-code-router`는 매칭에 실패할 수 있다** — 옛 프로세스가 살아남아 "설정을 바꿨는데 반영이 안 되는" 상황이 생긴다. `ccr stop` + 포트 기준 kill을 쓸 것.
- config 변경 후에는 반드시 완전 재시작 + transformer 등록 로그 확인.

## 6. 검증 절차 (스모크 테스트)

```bash
# 1) 라우터 왕복 (Anthropic 형식 → 변환 → 응답·usage 확인)
curl -s -X POST http://127.0.0.1:3456/v1/messages \
  -H "Content-Type: application/json" -H "x-api-key: test" \
  -d '{"model":"upstage,solar-pro3","max_tokens":200,"messages":[{"role":"user","content":"1+1?"}]}'

# 2) thinking 경로 (reasoning 변환 확인)
#    위 요청에 "thinking":{"type":"enabled","budget_tokens":1024} 추가 → 400 없이 응답이면 OK

# 3) 실전 파일럿: 도구 사용 소과제 후 세션 JSONL의 usage가 0이 아닌지 확인
jq -c 'select(.message.usage) | .message.usage' ~/.claude/projects/<slug>/*.jsonl | tail -3
```

## 7. 알려진 한계 (미해결)

- **컨텍스트 한도 불일치**: Claude Code는 200K를 가정해 컴팩션 타이밍을 잡지만 타사 모델 한도(예: 131K)가 더 작으면 `context_length_exceeded` 400으로 크래시한다. 게다가 Claude Code의 `max_tokens`(32K)가 completion 예약으로 그대로 전달돼 한도를 더 조인다. 완화: CCR 내장 `maxtoken` transformer로 max_tokens 축소 + 긴 자율 세션 회피. 근본 해결책은 없음.
- 토큰 회계는 세션 JSONL(참고치) 외에 **provider 콘솔 과금 대시보드를 정본**으로 3중 대조할 것. 토크나이저가 달라 Claude 기준 수치와 직접 비교 불가 — 비교 단위는 USD.
- 모델의 에이전틱 행동(자율성, 지시 추종)은 프로토콜 연동과 별개 문제다. tool calling이 잘 돌아도 headless 자율 루프 완주는 별도 검증 필요.
