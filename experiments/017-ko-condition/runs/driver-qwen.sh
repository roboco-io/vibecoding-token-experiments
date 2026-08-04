#!/bin/bash
# EXP-013: Claude Code x qwen3.8-max 직결(ANTHROPIC_BASE_URL) 랄프 루프 (EXP-012 driver에서 ccr 제거, n=1)
# 기동: nohup caffeinate -is "$HOME/ralph-exp017q/driver.sh" > /dev/null 2>&1 &
source "$HOME/.zsh_secrets"
BASE="$HOME/ralph-exp017q"
RUN="qwen-1"
MAX_ITER=30

REPO="$BASE/app-$RUN"; MET="$BASE/metrics-$RUN.csv"; LOG="$BASE/ralph-run-$RUN.log"
[ -f "$BASE/done-$RUN" ] && exit 0
[ -n "$QWEN_API_KEY" ] || { echo "QWEN_API_KEY missing" >> "$BASE/driver.log"; exit 1; }
mkdir -p "$REPO"
cp "$BASE/PROMPT.md" "$REPO/PROMPT.md"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || git -C "$REPO" init -q
cd "$REPO" || exit 1
DONE_ITER=$(grep -c '^[0-9]' "$MET" 2>/dev/null | head -1)
DONE_ITER=${DONE_ITER:-0}
echo "=== RUN $RUN (direct qwen3.8-max) start: $(date '+%F %T') ===" >> "$BASE/driver.log"
for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
  echo "=== [$RUN] iteration $i start: $(date '+%F %T') ===" >> "$LOG"
  env -u ANTHROPIC_API_KEY \
    CLAUDE_CONFIG_DIR="$BASE/claude-config" \
    ANTHROPIC_BASE_URL=https://dashscope-intl.aliyuncs.com/apps/anthropic \
    ANTHROPIC_AUTH_TOKEN="$QWEN_API_KEY" \
    ANTHROPIC_MODEL=qwen3.8-max \
    ANTHROPIC_SMALL_FAST_MODEL=qwen3.8-max \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=qwen3.8-max \
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
