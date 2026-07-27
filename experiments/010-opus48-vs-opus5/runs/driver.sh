#!/bin/bash
# EXP-010: Opus 4.8 vs Opus 5 순수 A/B — 동일 시점·동일 하네스, 교차 순서 6 run 순차 실행
# 기동: nohup caffeinate -is "$HOME/ralph-exp010/driver.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp010"
RUNS="48-1:claude-opus-4-8 5-1:claude-opus-5 48-2:claude-opus-4-8 5-2:claude-opus-5 48-3:claude-opus-4-8 5-3:claude-opus-5"
MAX_ITER=10

for spec in $RUNS; do
  RUN="${spec%%:*}"; MODEL="${spec##*:}"
  REPO="$BASE/app-$RUN"; MET="$BASE/metrics-$RUN.csv"; LOG="$BASE/ralph-run-$RUN.log"
  [ -f "$BASE/done-$RUN" ] && continue
  mkdir -p "$REPO"
  cp "$BASE/PROMPT.md" "$REPO/PROMPT.md"
  cp "$BASE/driver.sh" "$REPO/ralph.sh"
  git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || git -C "$REPO" init -q
  cd "$REPO" || exit 1
  DONE_ITER=$(grep -c '^[0-9]' "$MET" 2>/dev/null | head -1)
  DONE_ITER=${DONE_ITER:-0}
  echo "=== RUN $RUN ($MODEL) start: $(date '+%F %T') ===" >> "$BASE/driver.log"
  for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
    echo "=== [$RUN] iteration $i start: $(date '+%F %T') ===" >> "$LOG"
    claude -p "$(cat "$REPO/PROMPT.md")" --model "$MODEL" --dangerously-skip-permissions \
      < /dev/null >> "$LOG" 2>&1
    EXIT=$?
    echo "=== [$RUN] iteration $i end (exit $EXIT): $(date '+%F %T') ===" >> "$LOG"
    RESULT=$("$BASE/measure.sh" "$REPO")
    CLAIM=0; [ -f "$REPO/.ralph-done" ] && CLAIM=1
    GATE=na
    if [ "$CLAIM" = 1 ]; then
      if [ "${RESULT%%,*}" = "13" ]; then
        GATE=pass
      else
        GATE=rejected
        rm -f "$REPO/.ralph-done"
        echo "=== [$RUN] GATE 기각 (hurl $RESULT) iter $i ===" >> "$LOG"
      fi
    fi
    echo "$i,$(date '+%F %T'),$EXIT,$RESULT,$CLAIM,$GATE" >> "$MET"
    [ -f "$REPO/.ralph-done" ] && break
  done
  touch "$BASE/done-$RUN"
  echo "=== RUN $RUN finished: $(date '+%F %T') | $(tail -1 "$MET") ===" >> "$BASE/driver.log"
done
echo "=== ALL RUNS finished: $(date '+%F %T') ===" >> "$BASE/driver.log"
