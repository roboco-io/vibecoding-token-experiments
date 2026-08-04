#!/bin/bash
# EXP-017: 한국어 조건 qwen·kimi 각 n=3 — 순차·교차 (EXP-016 오케스트레이터 패턴)
# 기동: nohup caffeinate -is "$HOME/ralph-exp017/run-all.sh" > /dev/null 2>&1 &
BASE17="$HOME/ralph-exp017"
LOG="$BASE17/orchestrator.log"
log(){ echo "=== $* : $(date '+%F %T') ===" >> "$LOG"; }

run_one(){ # $1 base dir  $2 run name  $3 orig run name
  local base="$1" run="$2" orig="$3"
  [ -f "$HOME/$base/done-$run" ] && { log "skip $run (already done)"; return; }
  log "start $run"
  sed "s|RUN=\"$orig\"|RUN=\"$run\"|" "$HOME/$base/driver.sh" > "$HOME/$base/driver-$run.sh"
  chmod +x "$HOME/$base/driver-$run.sh"
  bash "$HOME/$base/driver-$run.sh"
  mv "$HOME/$base/claude-config/projects" "$HOME/$base/claude-config-projects-$run" 2>/dev/null
  log "end $run | $(tail -1 "$HOME/$base/metrics-$run.csv" 2>/dev/null)"
}

log "starting sequential ko runs"
run_one ralph-exp017q qwen-ko-1 qwen-1
run_one ralph-exp017k kimi-ko-1 kimi-1
run_one ralph-exp017q qwen-ko-2 qwen-1
run_one ralph-exp017k kimi-ko-2 kimi-1
run_one ralph-exp017q qwen-ko-3 qwen-1
run_one ralph-exp017k kimi-ko-3 kimi-1
log "ALL RUNS FINISHED"
touch "$BASE17/done-all"
