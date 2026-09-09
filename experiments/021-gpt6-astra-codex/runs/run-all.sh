#!/bin/bash
# EXP-021: gpt-6-astra 순차 3 run — EXP-016 오케스트레이터 이식 (codex 단일 조건)
# 기동: nohup caffeinate -is "$HOME/ralph-exp021/run-all.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp021"
LOG="$BASE/orchestrator.log"
log(){ echo "=== $* : $(date '+%F %T') ===" >> "$LOG"; }

run_one(){ # $1 run name
  local run="$1"
  [ -f "$BASE/done-$run" ] && { log "skip $run (already done)"; return; }
  log "start $run"
  bash "$BASE/driver.sh" "$run"
  mv "$BASE/codex-home/sessions" "$BASE/codex-sessions-$run" 2>/dev/null
  log "end $run | $(tail -1 "$BASE/metrics-$run.csv" 2>/dev/null)"
}

log "starting sequential runs"
run_one astra-1
run_one astra-2
run_one astra-3
log "ALL RUNS FINISHED"
touch "$BASE/done-all"
