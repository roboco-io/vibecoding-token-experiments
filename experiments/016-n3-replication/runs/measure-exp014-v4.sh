#!/bin/bash
# EXP-008 계측 v4: 리포 서버 기동 → 리포 소속 리스닝 포트 자동 탐지 → 공식 Hurl 13파일 채점
# stdout: "succ_files,exec_reqs"
# v3 대비: 리포 소속 판정을 command 경로 grep + 프로세스 CWD로 확장
#   (npx가 글로벌 캐시에서 실행돼 command에 리포 경로가 없는 경우 — EXP-015 iter 2 오검의 원인)
BASE="$HOME/ralph-exp014"
REPO="$1"

# 프로세스가 리포 소속인지: command에 리포 경로 포함 OR CWD가 리포 안
belongs_to_repo() {
  local pid="$1" cwd
  ps -p "$pid" -o command= 2>/dev/null | grep -q "$REPO" && return 0
  cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1)
  case "$cwd" in "$REPO"|"$REPO"/*) return 0;; esac
  return 1
}

cleanup() {
  for pid in $(lsof -nP -iTCP -sTCP:LISTEN -t 2>/dev/null); do
    belongs_to_repo "$pid" && kill -9 "$pid" 2>/dev/null
  done
  pkill -9 -f "$REPO/node_modules" 2>/dev/null
  sleep 1
  pkill -9 -f "$REPO/node_modules" 2>/dev/null
}

# 리포 소속 프로세스가 LISTEN 중인 첫 포트 반환
find_port() {
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | tail -n +2 | while read -r _ pid _ _ _ _ _ _ name _; do
    belongs_to_repo "$pid" || continue
    echo "${name##*:}"
    break
  done
}

cleanup
[ -d "$REPO" ] && [ -f "$REPO/package.json" ] || { echo "0,0"; exit 0; }
( cd "$REPO" && npm run dev > "$BASE/server-iter.log" 2>&1 & )
PORT=""
for _ in $(seq 1 30); do
  PORT=$(find_port | head -1)
  [ -n "$PORT" ] && break
  sleep 1
done
if [ -z "$PORT" ]; then cleanup; echo "0,0"; exit 0; fi

HURL_OUT="$BASE/hurl-last.log"
UID_VAL="$(date +%s)$$"
( hurl --test --jobs 1 --max-time 10 \
    --variable "host=http://localhost:$PORT" --variable "uid=$UID_VAL" \
    "$BASE"/harness-hurl/*.hurl > "$HURL_OUT" 2>&1 ) &
HP=$!
for _ in $(seq 1 300); do
  kill -0 "$HP" 2>/dev/null || break
  sleep 1
done
kill -9 "$HP" 2>/dev/null
cleanup
SF=$(grep -oE 'Succeeded files:[[:space:]]*[0-9]+' "$HURL_OUT" | grep -oE '[0-9]+' | tail -1)
ER=$(grep -oE 'Executed requests:[[:space:]]*[0-9]+' "$HURL_OUT" | grep -oE '[0-9]+' | tail -1)
echo "${SF:-0},${ER:-0}"
