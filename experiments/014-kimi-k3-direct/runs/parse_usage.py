#!/usr/bin/env python3
"""EXP-013: 격리 CLAUDE_CONFIG_DIR 세션 jsonl -> usage CSV. assistant message.id 단위 dedup 후 합산."""
import json, sys, glob

def main(cfg_dir):
    seen = {}
    for path in glob.glob(f"{cfg_dir}/projects/**/*.jsonl", recursive=True):
        for line in open(path):
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            m = d.get("message") or {}
            if d.get("type") == "assistant" and m.get("id") and m.get("usage"):
                seen[m["id"]] = m["usage"]  # 같은 id 재등장 시 마지막 기록 사용
    tot = {"input": 0, "cache_create": 0, "cache_read": 0, "output": 0}
    for u in seen.values():
        tot["input"] += u.get("input_tokens", 0) or 0
        tot["cache_create"] += u.get("cache_creation_input_tokens", 0) or 0
        tot["cache_read"] += u.get("cache_read_input_tokens", 0) or 0
        tot["output"] += u.get("output_tokens", 0) or 0
    print("messages,input,cache_create,cache_read,output")
    print(f"{len(seen)},{tot['input']},{tot['cache_create']},{tot['cache_read']},{tot['output']}")

if __name__ == "__main__":
    main(sys.argv[1])
