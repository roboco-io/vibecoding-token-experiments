#!/bin/bash
# EXP-019: 네이티브 Opus 4.8/5 + Codex x gpt-5.6-sol 한국어 조건 — 순차 9 run 교차 실행
# 기동: nohup caffeinate -is "$HOME/ralph-exp019/run-all.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp019"
LOG="$BASE/orchestrator.log"
log(){ echo "=== $* : $(date '+%F %T') ===" >> "$LOG"; }

run_opus(){ # $1 run  $2 model
  [ -f "$BASE/done-$1" ] && { log "skip $1"; return; }
  log "start $1 ($2)"
  bash "$BASE/driver-opus.sh" "$1" "$2"
  log "end $1 | $(tail -1 "$BASE/metrics-$1.csv" 2>/dev/null)"
}
run_codex(){ # $1 run
  [ -f "$BASE/done-$1" ] && { log "skip $1"; return; }
  log "start $1 (gpt-5.6-sol)"
  bash "$BASE/driver-codex.sh" "$1"
  mv "$BASE/codex-home/sessions" "$BASE/codex-sessions-$1" 2>/dev/null
  log "end $1 | $(tail -1 "$BASE/metrics-$1.csv" 2>/dev/null)"
}

log "starting sequential runs"
run_opus  48ko-1 claude-opus-4-8
run_opus  5ko-1  claude-opus-5
run_codex solko-1
run_opus  48ko-2 claude-opus-4-8
run_opus  5ko-2  claude-opus-5
run_codex solko-2
run_opus  48ko-3 claude-opus-4-8
run_opus  5ko-3  claude-opus-5
run_codex solko-3
log "ALL RUNS FINISHED"
touch "$BASE/done-all"
