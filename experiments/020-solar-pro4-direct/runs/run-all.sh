#!/bin/bash
# EXP-020: solar-pro4 직결 — 순차 3 run (pro4-1..3), run별 세션 격리
# 기동: nohup caffeinate -is "$HOME/ralph-exp020/run-all.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp020"
LOG="$BASE/orchestrator.log"
log(){ echo "=== $* : $(date '+%F %T') ===" >> "$LOG"; }

run_one(){ # $1 run name
  [ -f "$BASE/done-$1" ] && { log "skip $1"; return; }
  log "start $1"
  bash "$BASE/driver.sh" "$1"
  mv "$BASE/claude-config/projects" "$BASE/claude-config-projects-$1" 2>/dev/null
  log "end $1 | $(tail -1 "$BASE/metrics-$1.csv" 2>/dev/null)"
}

log "starting sequential runs"
run_one pro4-1
run_one pro4-2
run_one pro4-3
log "ALL RUNS FINISHED"
touch "$BASE/done-all"
