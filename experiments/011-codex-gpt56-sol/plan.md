# EXP-011 Codex CLI × gpt-5.6-sol 하네스 구현·실행 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** EXP-010 랄프 하네스를 Codex CLI(`codex exec`)용으로 이식해 gpt-5.6-sol의 RealWorld 백엔드 무개입 완주(M-07, n=1)를 판정한다.

**Architecture:** 작업 베이스는 `~/ralph-exp011/`(리포 밖, EXP-010 관례). 격리 `CODEX_HOME`으로 개인 설정·MCP·AGENTS.md를 배제하고, driver.sh가 30 iteration 상한 랄프 루프를 돌리며 iteration마다 measure.sh(Hurl 채점)로 게이트한다. 계측은 Codex 세션 rollout jsonl 파싱.

**Tech Stack:** bash, python3(표준 라이브러리만), Codex CLI 0.144.0, hurl

## Global Constraints

- 모델 `gpt-5.6-sol`, `model_reasoning_effort="medium"` 고정 (스펙: 개인 config의 low 미사용)
- MAX_ITER=30, `.ralph-done` + Hurl 13파일 게이트 (스펙 판정 기준)
- PROMPT.md는 EXP-010 정본 byte-identical (diff 0을 Phase 0에서 기록)
- 격리: 전용 `CODEX_HOME=~/ralph-exp011/codex-home` — auth.json 외 개인 설정 미복사
- measure.sh 채점 로직 무변경 (BASE 경로 치환만 허용)
- 리포 커밋물: 실험 스크립트·기록은 `experiments/011-codex-gpt56-sol/runs/`에 수집 (실행 자체는 `~/ralph-exp011/`)

---

### Task 1: 베이스 디렉토리 + 격리 CODEX_HOME 구성·스모크

**Files:**
- Create: `~/ralph-exp011/` (PROMPT.md, harness-hurl/, codex-home/config.toml, codex-home/auth.json)

**Interfaces:**
- Produces: `~/ralph-exp011/` 베이스 (이후 모든 태스크의 BASE), 격리 `CODEX_HOME` 경로

- [ ] **Step 1: 베이스 구성**

```bash
BASE="$HOME/ralph-exp011"
mkdir -p "$BASE/codex-home"
cp "$HOME/ralph-exp010/PROMPT.md" "$BASE/PROMPT.md"
cp -R "$HOME/ralph-exp010/harness-hurl" "$BASE/harness-hurl"
diff "$HOME/ralph-exp010/PROMPT.md" "$BASE/PROMPT.md" && echo "PROMPT diff 0"
ls "$BASE/harness-hurl"/*.hurl | wc -l   # 기대: 13
```

- [ ] **Step 2: 격리 CODEX_HOME 작성**

```bash
cp "$HOME/.codex/auth.json" "$BASE/codex-home/auth.json"
cat > "$BASE/codex-home/config.toml" <<'EOF'
model = "gpt-5.6-sol"
model_reasoning_effort = "medium"
EOF
ls "$BASE/codex-home"   # auth.json, config.toml 두 개만 있어야 함
```

- [ ] **Step 3: 스모크 — codex exec 1회 + effort 반영 확인**

```bash
cd /tmp && CODEX_HOME="$HOME/ralph-exp011/codex-home" \
  codex exec --skip-git-repo-check --sandbox read-only "Reply with exactly: OK" 2>&1 | tail -5
grep -rl 'gpt-5.6-sol' "$HOME/ralph-exp011/codex-home/sessions" | head -1
```

기대: 응답에 OK, sessions 아래 rollout jsonl 생성, 세션 메타에 model=gpt-5.6-sol / effort medium. 플래그가 버전과 다르면 `codex exec --help`로 교정하고 교정 내용을 phase0.md에 기록.

- [ ] **Step 4: 스모크 세션 jsonl에서 usage 필드 스키마 확인**

```bash
F=$(ls -t "$HOME/ralph-exp011/codex-home/sessions"/*/*/*/rollout-*.jsonl | head -1)
grep -o '"token_count".*' "$F" | tail -1 | head -c 600
```

기대: input/cached/output/total 토큰 필드 확인 → Task 3 파서의 실제 키 이름 확정.

---

### Task 2: measure.sh 치환본

**Files:**
- Create: `~/ralph-exp011/measure.sh` (EXP-010판에서 BASE만 치환)

**Interfaces:**
- Consumes: Task 1의 `$BASE/harness-hurl`
- Produces: `measure.sh <repo-dir>` → stdout `"succ_files,exec_reqs"` (driver가 파싱)

- [ ] **Step 1: 복사 + BASE 치환**

```bash
sed 's|ralph-exp010|ralph-exp011|' "$HOME/ralph-exp010/measure.sh" > "$HOME/ralph-exp011/measure.sh"
chmod +x "$HOME/ralph-exp011/measure.sh"
grep -n 'ralph-exp01' "$HOME/ralph-exp011/measure.sh"   # 기대: exp011만 존재
```

- [ ] **Step 2: 빈 리포 동작 검증**

```bash
mkdir -p /tmp/exp011-empty && "$HOME/ralph-exp011/measure.sh" /tmp/exp011-empty
```

기대 출력: `0,0`

---

### Task 3: usage 파싱 스크립트

**Files:**
- Create: `~/ralph-exp011/parse_usage.py`

**Interfaces:**
- Consumes: `$CODEX_HOME/sessions/**/rollout-*.jsonl` (Task 1 Step 4에서 확정한 키 이름으로 조정)
- Produces: `python3 parse_usage.py <sessions-dir>` → 세션별 1행 + TOTAL 행 CSV(`session,input,cached,output,total`)

- [ ] **Step 1: 파서 작성** (키 이름은 Task 1 Step 4 실측에 맞춰 조정 — 아래는 0.144 기본 스키마 가정: `token_count` 이벤트의 `info.total_token_usage`가 세션 누계)

```python
#!/usr/bin/env python3
"""EXP-011: Codex rollout jsonl -> token usage CSV. 세션별 마지막 token_count 누계 사용(중복 이벤트 dedup 불필요)."""
import json, sys
from pathlib import Path

def last_usage(path):
    usage = None
    for line in path.read_text().splitlines():
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        payload = ev.get("payload", ev)
        if payload.get("type") == "token_count":
            info = payload.get("info") or {}
            usage = info.get("total_token_usage") or usage
    return usage

def main(root):
    print("session,input,cached,output,total")
    tot = {"input_tokens": 0, "cached_input_tokens": 0, "output_tokens": 0, "total_tokens": 0}
    for f in sorted(Path(root).rglob("rollout-*.jsonl")):
        u = last_usage(f)
        if not u:
            continue
        row = [u.get(k, 0) for k in tot]
        for k, v in zip(tot, row):
            tot[k] += v
        print(f"{f.name},{row[0]},{row[1]},{row[2]},{row[3]}")
    print(f"TOTAL,{tot['input_tokens']},{tot['cached_input_tokens']},{tot['output_tokens']},{tot['total_tokens']}")

if __name__ == "__main__":
    main(sys.argv[1])
```

- [ ] **Step 2: 스모크 세션으로 검증**

```bash
python3 "$HOME/ralph-exp011/parse_usage.py" "$HOME/ralph-exp011/codex-home/sessions"
```

기대: 스모크 세션 1행 + TOTAL, output > 0. 키 불일치 시 Step 1 코드를 실측 스키마로 수정 후 재실행.

---

### Task 4: driver.sh (EXP-010 변형, codex exec 호출)

**Files:**
- Create: `~/ralph-exp011/driver.sh`

**Interfaces:**
- Consumes: Task 1 BASE/CODEX_HOME, Task 2 `measure.sh`(출력 `"SF,ER"`), `$BASE/PROMPT.md`
- Produces: `$BASE/metrics-sol-1.csv` (행: `iter,timestamp,exit,SF,ER,claim,gate`), `$BASE/ralph-run-sol-1.log`, `$BASE/done-sol-1`

- [ ] **Step 1: driver 작성**

```bash
cat > "$HOME/ralph-exp011/driver.sh" <<'EOF'
#!/bin/bash
# EXP-011: Codex CLI x gpt-5.6-sol 랄프 루프 (EXP-010 driver 이식, n=1)
# 기동: nohup caffeinate -is "$HOME/ralph-exp011/driver.sh" > /dev/null 2>&1 &
BASE="$HOME/ralph-exp011"
RUN="sol-1"
MODEL="gpt-5.6-sol"
MAX_ITER=30
export CODEX_HOME="$BASE/codex-home"

REPO="$BASE/app-$RUN"; MET="$BASE/metrics-$RUN.csv"; LOG="$BASE/ralph-run-$RUN.log"
[ -f "$BASE/done-$RUN" ] && exit 0
mkdir -p "$REPO"
cp "$BASE/PROMPT.md" "$REPO/PROMPT.md"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || git -C "$REPO" init -q
cd "$REPO" || exit 1
DONE_ITER=$(grep -c '^[0-9]' "$MET" 2>/dev/null | head -1)
DONE_ITER=${DONE_ITER:-0}
echo "=== RUN $RUN ($MODEL) start: $(date '+%F %T') ===" >> "$BASE/driver.log"
for i in $(seq $((DONE_ITER + 1)) $MAX_ITER); do
  echo "=== [$RUN] iteration $i start: $(date '+%F %T') ===" >> "$LOG"
  codex exec --model "$MODEL" -c model_reasoning_effort=\"medium\" \
    --sandbox danger-full-access --skip-git-repo-check -C "$REPO" \
    "$(cat "$REPO/PROMPT.md")" < /dev/null >> "$LOG" 2>&1
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
EOF
chmod +x "$HOME/ralph-exp011/driver.sh"
bash -n "$HOME/ralph-exp011/driver.sh" && echo "syntax OK"
```

주: EXP-010과 달리 PROMPT의 `ralph.sh` 사본은 리포에 두지 않는다(codex가 참조할 필요 없음). PROMPT 문구 "Do not modify PROMPT.md or ralph.sh"는 무해하므로 byte-identical 유지 우선.

- [ ] **Step 2: 스텁으로 루프·게이트 검증 (API 미호출)**

```bash
TESTDIR=$(mktemp -d); mkdir -p "$TESTDIR/bin"
printf '#!/bin/bash\necho stub-codex "$@"\n' > "$TESTDIR/bin/codex"
chmod +x "$TESTDIR/bin/codex"
sed "s|^BASE=.*|BASE=\"$TESTDIR/base\"|; s|^MAX_ITER=30|MAX_ITER=2|" \
  "$HOME/ralph-exp011/driver.sh" > "$TESTDIR/driver-test.sh"
mkdir -p "$TESTDIR/base/codex-home"
cp "$HOME/ralph-exp011/PROMPT.md" "$TESTDIR/base/PROMPT.md"
printf '#!/bin/bash\necho "0,0"\n' > "$TESTDIR/base/measure.sh"; chmod +x "$TESTDIR/base/measure.sh"
PATH="$TESTDIR/bin:$PATH" bash "$TESTDIR/driver-test.sh"
cat "$TESTDIR/base/metrics-sol-1.csv"
```

기대: 2행(`1,...,0,0,0,0,na`, `2,...`), `done-sol-1` 생성, 로그에 stub-codex 2회. 확인 후 `rm -rf "$TESTDIR"`.

---

### Task 5: Phase 0 게이트 기록 + 하네스 리포 커밋

**Files:**
- Create: `experiments/011-codex-gpt56-sol/runs/phase0.md`
- Create: `experiments/011-codex-gpt56-sol/runs/{driver.sh,measure.sh,parse_usage.py}` (`~/ralph-exp011/`에서 복사)

**Interfaces:**
- Consumes: Task 1–4의 검증 결과
- Produces: 사전 등록된 Phase 0 통과 기록 (report.md가 인용)

- [ ] **Step 1: phase0.md 작성** — 설계 README의 4개 게이트 각각에 실측 증거(명령·출력 요약) 기입: ① 스모크 응답·effort medium ② PROMPT diff 0 ③ measure.sh `0,0`·포트 8000 비점유(`lsof -nP -iTCP:8000` 빈 출력) ④ usage 파서 스키마 검증. 플래그 교정이 있었다면 명시.

- [ ] **Step 2: 하네스 스크립트 리포 복사 + 커밋**

```bash
cd /Users/dohyunjung/Workspace/roboco-io/research/vibecoding-token-experiments
mkdir -p experiments/011-codex-gpt56-sol/runs
cp ~/ralph-exp011/driver.sh ~/ralph-exp011/measure.sh ~/ralph-exp011/parse_usage.py \
  experiments/011-codex-gpt56-sol/runs/
git add experiments/011-codex-gpt56-sol/runs/
git commit -m "EXP-011 하네스: codex exec 랄프 driver·계측 + Phase 0 통과 기록"
```

---

### Task 6: 본 실행 기동·모니터링

**Files:**
- 실행 산출: `~/ralph-exp011/{metrics-sol-1.csv, ralph-run-sol-1.log, driver.log, app-sol-1/}`

**Interfaces:**
- Consumes: Task 4 driver.sh
- Produces: 완료 마커 `~/ralph-exp011/done-sol-1`, metrics CSV (Task 7 판정 입력)

- [ ] **Step 1: 사전 상태 확인** — 포트 8000 비점유, `app-sol-1` 부재(재실행이면 이어달리기 여부 명시 기록)

- [ ] **Step 2: 기동**

```bash
nohup caffeinate -is "$HOME/ralph-exp011/driver.sh" > /dev/null 2>&1 &
echo "driver pid: $!"
```

- [ ] **Step 3: 모니터링** — iteration 종료마다 확인, 무개입 원칙(로그 열람만, app-sol-1·프롬프트 불개입)

```bash
tail -3 ~/ralph-exp011/metrics-sol-1.csv; tail -5 ~/ralph-exp011/driver.log
```

종료 조건: `done-sol-1` 생성. 루프 자체가 성립 안 하는 하네스 장애(스펙의 '보류' 사유)만 개입 허용 — 개입 시 시각·내용을 기록하고 iteration 재시작.

---

### Task 7: 판정·수집·보고

**Files:**
- Create: `experiments/011-codex-gpt56-sol/report.md`, `runs/sol-1/` (metrics·log·usage csv)
- Modify: `hypotheses/catalog.md` (M-07 상태), `ROADMAP.md` (체크박스), README(스크립트 재생성)

**Interfaces:**
- Consumes: Task 6 산출물, Task 3 파서
- Produces: 판정 확정된 report.md (헤더에 파싱 가능한 `- 가설:` / `- **판정:**` 두 줄 — CLAUDE.md 필수 절차)

- [ ] **Step 1: 독립 재검증 2회**

```bash
"$HOME/ralph-exp011/measure.sh" "$HOME/ralph-exp011/app-sol-1"
"$HOME/ralph-exp011/measure.sh" "$HOME/ralph-exp011/app-sol-1"
```

기대(완주 시): 두 번 모두 `13,154`. metrics의 gate=pass와 일치해야 검증 판정.

- [ ] **Step 2: 계측 수집**

```bash
python3 ~/ralph-exp011/parse_usage.py ~/ralph-exp011/codex-home/sessions > ~/ralph-exp011/usage-sol-1.csv
git -C ~/ralph-exp011/app-sol-1 log --oneline | wc -l   # 커밋 수
```

주: 스모크 세션 행은 TOTAL에서 제외해 보고 (세션명으로 식별).

- [ ] **Step 3: 산출물 리포 수집**

```bash
cd /Users/dohyunjung/Workspace/roboco-io/research/vibecoding-token-experiments
mkdir -p experiments/011-codex-gpt56-sol/runs/sol-1
cp ~/ralph-exp011/metrics-sol-1.csv ~/ralph-exp011/usage-sol-1.csv \
   ~/ralph-exp011/driver.log experiments/011-codex-gpt56-sol/runs/sol-1/
gzip -c ~/ralph-exp011/ralph-run-sol-1.log > experiments/011-codex-gpt56-sol/runs/sol-1/ralph-run-sol-1.log.gz
```

- [ ] **Step 4: report.md 작성** — 템플릿 `templates/report.md` 준수. 헤더 두 줄: `- 가설: [M-07](../../hypotheses/catalog.md) — <문장>`, `- **판정: 검증|기각|보류** — <한 문장>`. 본문: iteration 수·wall-clock·usage TOTAL·커밋 수·게이트 이력·관찰. n=1이므로 효율 비교 서사 금지(스펙 리스크 항목).

- [ ] **Step 5: 종료 절차 (CLAUDE.md 필수)**

```bash
python3 scripts/update_readme_results.py
# hypotheses/catalog.md M-07 상태 갱신, ROADMAP.md EXP-011 체크
git add -A && git commit -m "EXP-011 완료: Codex CLI × gpt-5.6-sol (M-07 <판정>)"
```

---

## Self-Review 결과

- 스펙 커버리지: 격리(T1)·프롬프트 diff(T1/T5)·measure 무변경(T2)·계측 dedup(T3, 누계 방식이라 dedup 자체가 불필요함을 명시)·30 iter 게이트(T4)·Phase 0 4항목(T5)·판정 기준(T7). 리스크 3항목은 T1 Step 3 플래그 교정, T6 개입 규칙, T7 서사 금지로 대응.
- EXP-012는 본 계획 범위 외 (EXP-011 보고 후 별도 설계·계획).
