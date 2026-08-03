#!/bin/bash
# EXP-011: Codex CLI x gpt-5.6-sol 랄프 루프 (EXP-010 driver 이식, n=1)
# 기동: nohup caffeinate -is "$HOME/ralph-exp011/driver.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp011"
RUN="sol-1"
MODEL="gpt-5.6-sol"
MAX_ITER=30
export CODEX_HOME="$BASE/codex-home"

REPO="$BASE/app-$RUN"; MET="$BASE/metrics-$RUN.csv"; LOG="$BASE/ralph-run-$RUN.log"
[ -f "$BASE/done-$RUN" ] && exit 0
mkdir -p "$REPO"
cp "$BASE/PROMPT.md" "$REPO/PROMPT.md"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || git -C "$REPO" init -q
cd "$REPO" || exit 1
DONE_ITER=$(grep -c '^[0-9]' "$MET" 2>/dev/null | head -1)
DONE_ITER=${DONE_ITER:-0}
echo "=== RUN $RUN ($MODEL) start: $(date '+%F %T') ===" >> "$BASE/driver.log"
for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
  echo "=== [$RUN] iteration $i start: $(date '+%F %T') ===" >> "$LOG"
  codex exec --model "$MODEL" -c model_reasoning_effort="medium" \
    --sandbox danger-full-access --skip-git-repo-check -C "$REPO" \
    "$(cat "$REPO/PROMPT.md")" < /dev/null >> "$LOG" 2>&1
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
