#!/usr/bin/env python3
"""EXP-012: ccr usage-tap.jsonl -> token usage CSV. 요청(response.id) 단위 dedup 후 합산."""
import json, sys

def main(path):
    seen = {}
    for line in open(path):
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        if d.get("id") and d.get("usage"):
            seen[d["id"]] = d  # 같은 id 재등장 시 마지막 기록 사용
    print("requests,input,cached,output,reasoning,total")
    n = len(seen)
    tot = {"input": 0, "cached": 0, "output": 0, "reasoning": 0, "total": 0}
    for d in seen.values():
        u = d["usage"]
        tot["input"] += u.get("input_tokens", 0)
        tot["cached"] += (u.get("input_tokens_details") or {}).get("cached_tokens", 0)
        tot["output"] += u.get("output_tokens", 0)
        tot["reasoning"] += (u.get("output_tokens_details") or {}).get("reasoning_tokens", 0)
        tot["total"] += u.get("total_tokens", 0)
    print(f"{n},{tot['input']},{tot['cached']},{tot['output']},{tot['reasoning']},{tot['total']}")

if __name__ == "__main__":
    main(sys.argv[1])
