#!/usr/bin/env python3
"""EXP-007: EXP-006 open2-2 세션 트랜스크립트 부검 스크립트.

사용법: python3 analyze_transcripts.py [로그 디렉토리]
기본 대상: ../../006-solar-open2-backend/runs/open2-2/logs

핵심: Claude Code JSONL은 한 API 응답(message)을 콘텐츠 블록별 여러 행으로
기록하고 같은 message.id 행들이 동일 usage를 반복하므로, 요청 수·토큰은
반드시 message.id로 중복 제거해 집계해야 한다 (행 합산 시 약 3배 과대).
"""
import json, glob, re, os, sys
from collections import Counter
from datetime import datetime

HERE = os.path.dirname(os.path.abspath(__file__))
LOGDIR = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    HERE, "..", "..", "006-solar-open2-backend", "runs", "open2-2", "logs")
FMT = "%Y-%m-%dT%H:%M:%S.%fZ"

def text_of(body):
    if isinstance(body, str):
        return body
    if isinstance(body, list):
        return " ".join(x.get("text", "") for x in body if isinstance(x, dict))
    return ""

sessions = []
dup_check_same = dup_check_diff = 0

for path in sorted(glob.glob(os.path.join(LOGDIR, "*.jsonl"))):
    rows = [json.loads(l) for l in open(path) if l.strip()]
    ts = [r["timestamp"] for r in rows if "timestamp" in r]

    usage_by_id = {}      # message.id -> usage (dedup)
    rows_by_id = Counter()
    stop = Counter()
    tools = Counter()
    files_written, files_edited = set(), set()
    git_cmds, skill_calls, agent_calls = [], [], []
    hurl_runs = []        # (ts, exec_files, exec_reqs, succ_files, fail_files)
    think_chars = text_chars = 0
    tool_errors = 0
    last_text = ""

    for r in rows:
        if r.get("type") == "assistant":
            m = r.get("message", {})
            mid = m.get("id")
            if mid:
                rows_by_id[mid] += 1
                u = m.get("usage") or {}
                if mid in usage_by_id:
                    if usage_by_id[mid] != u:
                        dup_check_diff += 1
                else:
                    usage_by_id[mid] = u
                    if m.get("stop_reason"):
                        stop[m["stop_reason"]] += 1
            for c in m.get("content", []) or []:
                if not isinstance(c, dict):
                    continue
                if c.get("type") == "thinking":
                    think_chars += len(c.get("thinking", ""))
                elif c.get("type") == "text":
                    text_chars += len(c.get("text", ""))
                    if c.get("text", "").strip():
                        last_text = c["text"]
                elif c.get("type") == "tool_use":
                    name = c.get("name", "?")
                    tools[name] += 1
                    inp = c.get("input", {}) or {}
                    fp = inp.get("file_path", "")
                    if name == "Write" and fp:
                        files_written.add(os.path.basename(fp))
                    elif name in ("Edit", "MultiEdit") and fp:
                        files_edited.add(os.path.basename(fp))
                    elif name == "Bash" and inp.get("command", "").strip().startswith("git"):
                        git_cmds.append(inp["command"][:100])
                    elif name == "Skill":
                        skill_calls.append(inp.get("skill", "?"))
                    elif name == "Agent":
                        agent_calls.append(inp.get("subagent_type", "?"))
        elif r.get("type") == "user":
            content = r.get("message", {}).get("content")
            if isinstance(content, list):
                for c in content:
                    if isinstance(c, dict) and c.get("type") == "tool_result":
                        if c.get("is_error"):
                            tool_errors += 1
                        t = text_of(c.get("content"))
                        for mm in re.finditer(
                            r"Executed files:\s*(\d+).*?Executed requests:\s*(\d+).*?"
                            r"Succeeded files:\s*(\d+).*?Failed files:\s*(\d+)", t, re.S):
                            hurl_runs.append((r.get("timestamp"),) + tuple(map(int, mm.groups())))

    dup_check_same += sum(1 for mid, n in rows_by_id.items() if n > 1)

    tok = Counter()
    for u in usage_by_id.values():
        for k in ("input_tokens", "output_tokens",
                  "cache_creation_input_tokens", "cache_read_input_tokens"):
            tok[k] += u.get(k) or 0

    sessions.append(dict(
        sid=os.path.basename(path)[:8],
        start=min(ts) if ts else None, end=max(ts) if ts else None,
        n_rows=len(rows), n_api=len(usage_by_id), tok=dict(tok), stop=dict(stop),
        tools=dict(tools), files_written=sorted(files_written),
        files_edited=sorted(files_edited), git_cmds=git_cmds,
        skill_calls=skill_calls, agent_calls=agent_calls, hurl_runs=hurl_runs,
        think_chars=think_chars, text_chars=text_chars,
        tool_errors=tool_errors, last_text=last_text[:300],
    ))

sessions.sort(key=lambda s: s["start"] or "")

print(f"=== 세션 {len(sessions)}개, 시간순 (usage는 message.id dedup) ===")
tot = Counter()
for i, s in enumerate(sessions, 1):
    t = s["tok"]
    dur = (datetime.strptime(s["end"], FMT) - datetime.strptime(s["start"], FMT)).total_seconds() / 60
    tot["api"] += s["n_api"]; tot["in"] += t.get("input_tokens", 0)
    tot["out"] += t.get("output_tokens", 0); tot["think"] += s["think_chars"]
    tot["text"] += s["text_chars"]
    print(f"[{i:2d}] {s['sid']} {s['start'][:19]}Z dur={dur:5.1f}m api={s['n_api']:3d} "
          f"in={t.get('input_tokens',0)/1e6:5.2f}M out={t.get('output_tokens',0)/1e3:6.1f}K "
          f"stop={s['stop']} wrote={len(s['files_written'])} edit={len(s['files_edited'])} "
          f"skills={s['skill_calls']} agents={len(s['agent_calls'])}")

print(f"\n합계: API {tot['api']}회, input {tot['in']/1e6:.1f}M, output {tot['out']/1e6:.2f}M")
print(f"thinking {tot['think']:,}자 vs text {tot['text']:,}자 "
      f"(thinking 비중 {100*tot['think']/(tot['think']+tot['text']):.0f}%)")
print(f"usage 중복 검증: 다중 행 message {dup_check_same}개, usage 불일치 {dup_check_diff}건")

print("\n=== Hurl 궤적 (성공파일/실행파일, 실행요청) ===")
for i, s in enumerate(sessions, 1):
    for rec in s["hurl_runs"]:
        print(f"[{i:2d}] {rec[0][11:19]}Z  files {rec[3]}/{rec[1]}  reqs {rec[2]}  failed {rec[4]}")

print("\n=== git 명령 전수 (commit 부재 확인) ===")
for i, s in enumerate(sessions, 1):
    for c in s["git_cmds"]:
        print(f"[{i:2d}] {c}")

print("\n=== 각 세션 마지막 assistant 텍스트 (종결 방식) ===")
for i, s in enumerate(sessions, 1):
    print(f"[{i:2d}] {s['last_text'][:200]!r}")
