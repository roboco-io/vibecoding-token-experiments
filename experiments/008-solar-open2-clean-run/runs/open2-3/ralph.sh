#!/bin/bash
# EXP-008: solar-open2 무오염 클린 run — 격리 CLAUDE_CONFIG_DIR + 검증 게이트 + iteration별 계측
# 기동: nohup caffeinate -is "$HOME/ralph-exp008/ralph.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp008"
REPO="$BASE/app"
MAX_ITER=30
cd "$REPO" || exit 1   # claude -p는 반드시 작업 리포에서 실행 (누락 시 기동 cwd 오염 사고)
DONE_ITER=0
[ -f "$BASE/metrics.csv" ] && DONE_ITER=$(grep -c '^[0-9]' "$BASE/metrics.csv")
for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
  echo "=== iteration $i start: $(date '+%F %T') ===" >> "$BASE/ralph-run.log"
  env -u ANTHROPIC_API_KEY \
    CLAUDE_CONFIG_DIR="$BASE/claude-config" \
    ANTHROPIC_BASE_URL=https://api.upstage.ai \
    ANTHROPIC_AUTH_TOKEN=up_T4PYUlNRhwfWaZsbS7eudT6nE7IA1 \
    ANTHROPIC_MODEL=solar-open2 \
    ANTHROPIC_SMALL_FAST_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_SONNET_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_OPUS_MODEL=solar-open2 \
    API_TIMEOUT_MS=600000 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144 \
    CLAUDE_CODE_MAX_OUTPUT_TOKENS=131072 \
    CLAUDE_STREAM_IDLE_TIMEOUT_MS=600000 \
    claude -p "$(cat "$REPO/PROMPT.md")" --dangerously-skip-permissions \
    < /dev/null >> "$BASE/ralph-run.log" 2>&1
  EXIT=$?
  echo "=== iteration $i end (exit $EXIT): $(date '+%F %T') ===" >> "$BASE/ralph-run.log"
  rsync -a --exclude node_modules "$REPO/" "$BASE/snapshots/iter-$i/"
  RESULT=$("$BASE/measure.sh" "$REPO")
  CLAIM=0; [ -f "$REPO/.ralph-done" ] && CLAIM=1
  GATE=na
  if [ "$CLAIM" = 1 ]; then
    if [ "${RESULT%%,*}" = "13" ]; then
      GATE=pass
    else
      GATE=rejected
      rm -f "$REPO/.ralph-done"
      echo "=== GATE: .ralph-done 기각 (hurl $RESULT) iter $i ===" >> "$BASE/ralph-run.log"
    fi
  fi
  echo "$i,$(date '+%F %T'),$EXIT,$RESULT,$CLAIM,$GATE" >> "$BASE/metrics.csv"
  if [ -f "$REPO/.ralph-done" ]; then
    echo "=== DONE (gate pass) at iteration $i: $(date '+%F %T') ===" >> "$BASE/ralph-run.log"
    break
  fi
done
echo "=== ralph loop finished: $(date '+%F %T') ===" >> "$BASE/ralph-run.log"
