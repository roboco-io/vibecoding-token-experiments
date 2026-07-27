#!/bin/bash
# EXP-009: Opus 5 랄프 루프 (EXP-002 en 프롬프트) — 게이트 + iteration별 계측
# 환경: 기본 ~/.claude 사용 (격리 불가 — OAuth 키체인 제약. EXP-002 기준선과 동일 환경이라 비교 정합)
# 기동: nohup caffeinate -is "$HOME/ralph-exp009/ralph.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp009"
REPO="$BASE/app2"
MAX_ITER=10
cd "$REPO" || exit 1
DONE_ITER=0
[ -f "$BASE/metrics2.csv" ] && DONE_ITER=$(grep -c '^[0-9]' "$BASE/metrics2.csv")
for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
  echo "=== iteration $i start: $(date '+%F %T') ===" >> "$BASE/ralph-run2.log"
  claude -p "$(cat "$REPO/PROMPT.md")" --model claude-opus-5 --dangerously-skip-permissions \
    < /dev/null >> "$BASE/ralph-run2.log" 2>&1
  EXIT=$?
  echo "=== iteration $i end (exit $EXIT): $(date '+%F %T') ===" >> "$BASE/ralph-run2.log"
  rsync -a --exclude node_modules "$REPO/" "$BASE/snapshots/run2-iter-$i/"
  RESULT=$("$BASE/measure.sh" "$REPO")
  CLAIM=0; [ -f "$REPO/.ralph-done" ] && CLAIM=1
  GATE=na
  if [ "$CLAIM" = 1 ]; then
    if [ "${RESULT%%,*}" = "13" ]; then
      GATE=pass
    else
      GATE=rejected
      rm -f "$REPO/.ralph-done"
      echo "=== GATE: .ralph-done 기각 (hurl $RESULT) iter $i ===" >> "$BASE/ralph-run2.log"
    fi
  fi
  echo "$i,$(date '+%F %T'),$EXIT,$RESULT,$CLAIM,$GATE" >> "$BASE/metrics2.csv"
  if [ -f "$REPO/.ralph-done" ]; then
    echo "=== DONE (gate pass) at iteration $i: $(date '+%F %T') ===" >> "$BASE/ralph-run2.log"
    break
  fi
done
echo "=== ralph loop finished: $(date '+%F %T') ===" >> "$BASE/ralph-run2.log"
