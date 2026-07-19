#!/usr/bin/env python3
"""Claude Code 세션 로그(.jsonl) 디렉토리별 토큰 집계·비교.

사용법: python3 scripts/aggregate_tokens.py <dir1> [dir2 ...]
각 디렉토리의 *.jsonl에서 assistant 메시지 usage를 합산해 조건 간 비교 표를 출력한다.
"""
import json
import sys
from pathlib import Path

FIELDS = ["input_tokens", "output_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"]


def aggregate(log_dir: Path) -> dict:
    totals = {f: 0 for f in FIELDS}
    totals["sessions"] = 0
    totals["messages"] = 0
    for jsonl in sorted(log_dir.glob("*.jsonl")):
        totals["sessions"] += 1
        with jsonl.open() as fp:
            for line in fp:
                try:
                    usage = json.loads(line).get("message", {}).get("usage")
                except (json.JSONDecodeError, AttributeError):
                    continue
                if not usage:
                    continue
                totals["messages"] += 1
                for f in FIELDS:
                    totals[f] += usage.get(f, 0) or 0
    # 과금 토큰: cache read는 제외(할인율 큼)하고 별도 표기
    totals["billable"] = totals["input_tokens"] + totals["output_tokens"] + totals["cache_creation_input_tokens"]
    return totals


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__.strip(), file=sys.stderr)
        return 1
    results = {}
    for arg in sys.argv[1:]:
        d = Path(arg)
        if not d.is_dir():
            print(f"경고: 디렉토리 아님, 건너뜀: {d}", file=sys.stderr)
            continue
        results[d.name if d.name != "logs" else d.parent.name] = aggregate(d)
    if not results:
        return 1

    rows = ["sessions", "messages", *FIELDS, "billable"]
    names = list(results)
    width = max(len(r) for r in rows) + 2
    print(f"{'':<{width}}" + "".join(f"{n:>24}" for n in names))
    for r in rows:
        print(f"{r:<{width}}" + "".join(f"{results[n][r]:>24,}" for n in names))
    if len(names) == 2:
        a, b = names
        diff = results[a]["billable"] - results[b]["billable"]
        base = results[a]["billable"] or 1
        print(f"\nbillable 차이: {a} - {b} = {diff:+,} ({diff / base * 100:+.1f}% of {a})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
