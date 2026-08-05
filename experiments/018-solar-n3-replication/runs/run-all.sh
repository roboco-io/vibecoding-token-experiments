#!/bin/bash
# EXP-018: solar-open2 직결 재현성 확충 — 순차 2 run (solar-2, solar-3), EXP-015 하네스 재사용
# 기동: nohup caffeinate -is "$HOME/ralph-exp018/run-all.sh" > /dev/null 2>&1 &
BASE18="$HOME/ralph-exp018"
LOG="$BASE18/orchestrator.log"
log(){ echo "=== $* : $(date '+%F %T') ===" >> "$LOG"; }

run_one(){ # $1 run name
  local run="$1" base="ralph-exp015"
  [ -f "$HOME/$base/done-$run" ] && { log "skip $run (already done)"; return; }
  log "start $run"
  sed "s|RUN=\"solar-1\"|RUN=\"$run\"|" "$HOME/$base/driver.sh" > "$HOME/$base/driver-$run.sh"
  chmod +x "$HOME/$base/driver-$run.sh"
  bash "$HOME/$base/driver-$run.sh"
  mv "$HOME/$base/claude-config/projects" "$HOME/$base/claude-config-projects-$run" 2>/dev/null
  log "end $run | $(tail -1 "$HOME/$base/metrics-$run.csv" 2>/dev/null)"
}

log "starting sequential runs"
run_one solar-2
run_one solar-3
log "ALL RUNS FINISHED"
touch "$BASE18/done-all"
