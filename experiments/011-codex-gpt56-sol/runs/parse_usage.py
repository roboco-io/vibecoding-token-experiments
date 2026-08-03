#!/usr/bin/env python3
"""EXP-011: Codex rollout jsonl -> token usage CSV. 세션별 마지막 token_count 누계 사용(중복 이벤트 dedup 불필요)."""
import json, sys
from pathlib import Path

def last_usage(path):
    usage = None
    for line in path.read_text().splitlines():
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        payload = ev.get("payload", ev)
        if payload.get("type") == "token_count":
            info = payload.get("info") or {}
            usage = info.get("total_token_usage") or usage
    return usage

def main(root):
    print("session,input,cached,output,total")
    tot = {"input_tokens": 0, "cached_input_tokens": 0, "output_tokens": 0, "total_tokens": 0}
    for f in sorted(Path(root).rglob("rollout-*.jsonl")):
        u = last_usage(f)
        if not u:
            continue
        row = [u.get(k, 0) for k in tot]
        for k, v in zip(tot, row):
            tot[k] += v
        print(f"{f.name},{row[0]},{row[1]},{row[2]},{row[3]}")
    print(f"TOTAL,{tot['input_tokens']},{tot['cached_input_tokens']},{tot['output_tokens']},{tot['total_tokens']}")

if __name__ == "__main__":
    main(sys.argv[1])
