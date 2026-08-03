#!/bin/bash
# EXP-012: Claude Code x gpt-5.6-sol 백엔드(ccr) 랄프 루프 (EXP-010 driver + EXP-008 격리 이식, n=1)
# 기동: nohup caffeinate -is "$HOME/ralph-exp012/driver.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp012"
RUN="sol-1"
MAX_ITER=30

REPO="$BASE/app-$RUN"; MET="$BASE/metrics-$RUN.csv"; LOG="$BASE/ralph-run-$RUN.log"
[ -f "$BASE/done-$RUN" ] && exit 0
mkdir -p "$REPO"
cp "$BASE/PROMPT.md" "$REPO/PROMPT.md"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || git -C "$REPO" init -q
cd "$REPO" || exit 1
DONE_ITER=$(grep -c '^[0-9]' "$MET" 2>/dev/null | head -1)
DONE_ITER=${DONE_ITER:-0}
echo "=== RUN $RUN (ccr openai,gpt-5.6-sol) start: $(date '+%F %T') ===" >> "$BASE/driver.log"
for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
  # 라우터 생존 확인 — 하네스 인프라 장애는 자동 복구하되 기록 (모델 개입 아님)
  if ! lsof -ti :3456 >/dev/null 2>&1; then
    echo "=== [$RUN] ccr down before iter $i — restarting: $(date '+%F %T') ===" >> "$BASE/driver.log"
    nohup ccr start > /tmp/ccr-exp012.log 2>&1 &
    sleep 5
  fi
  echo "=== [$RUN] iteration $i start: $(date '+%F %T') ===" >> "$LOG"
  env -u ANTHROPIC_API_KEY \
    CLAUDE_CONFIG_DIR="$BASE/claude-config" \
    ANTHROPIC_BASE_URL=http://127.0.0.1:3456 \
    ANTHROPIC_AUTH_TOKEN=test \
    ANTHROPIC_MODEL="openai,gpt-5.6-sol" \
    ANTHROPIC_SMALL_FAST_MODEL="openai,gpt-5.6-sol" \
    CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    API_TIMEOUT_MS=600000 \
    claude -p "$(cat "$REPO/PROMPT.md")" --dangerously-skip-permissions \
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
