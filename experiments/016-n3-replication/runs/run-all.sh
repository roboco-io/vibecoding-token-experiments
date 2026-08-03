#!/bin/bash
# EXP-016: n 확충 재현성 — 순차 6 run (교차 순서), EXP-015 종료+go 게이트 대기
# 기동: nohup caffeinate -is "$HOME/ralph-exp016/run-all.sh" > /dev/null 2>&1 &
BASE16="$HOME/ralph-exp016"
LOG="$BASE16/orchestrator.log"
log(){ echo "=== $* : $(date '+%F %T') ===" >> "$LOG"; }

log "waiting for EXP-015 done + go gate"
while [ ! -f "$HOME/ralph-exp015/done-solar-1" ] || [ ! -f "$BASE16/go" ]; do sleep 120; done
log "gate open — starting sequential runs"

run_one(){ # $1 base dir  $2 run name  $3 orig run name  $4 kind(claude|codex)
  local base="$1" run="$2" orig="$3" kind="$4"
  [ -f "$HOME/$base/done-$run" ] && { log "skip $run (already done)"; return; }
  log "start $run"
  sed "s|RUN=\"$orig\"|RUN=\"$run\"|" "$HOME/$base/driver.sh" > "$HOME/$base/driver-$run.sh"
  chmod +x "$HOME/$base/driver-$run.sh"
  bash "$HOME/$base/driver-$run.sh"
  if [ "$kind" = claude ]; then
    mv "$HOME/$base/claude-config/projects" "$HOME/$base/claude-config-projects-$run" 2>/dev/null
  else
    mv "$HOME/$base/codex-home/sessions" "$HOME/$base/codex-sessions-$run" 2>/dev/null
  fi
  log "end $run | $(tail -1 "$HOME/$base/metrics-$run.csv" 2>/dev/null)"
}

run_one ralph-exp011 sol-2  sol-1  codex
run_one ralph-exp013 qwen-2 qwen-1 claude
run_one ralph-exp014 kimi-2 kimi-1 claude
run_one ralph-exp011 sol-3  sol-1  codex
run_one ralph-exp013 qwen-3 qwen-1 claude
run_one ralph-exp014 kimi-3 kimi-1 claude
log "ALL RUNS FINISHED"
touch "$BASE16/done-all"
