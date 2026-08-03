# EXP-013 (Claude Code × qwen3.8-max 직결) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Claude Code를 DashScope Anthropic 호환 엔드포인트로 qwen3.8-max에 직결해 격리 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154) 30 iter 내 무개입 완주 여부를 판정한다 (M-09, n=1).

**Architecture:** EXP-012 하네스(driver.sh 루프 + measure.sh 채점 + `.ralph-done` 게이트)를 `~/ralph-exp013`으로 이식하되, ccr 계층을 제거하고 `ANTHROPIC_BASE_URL` env 직결로 교체. usage 계측은 ccr 탭 대신 격리 `CLAUDE_CONFIG_DIR` 세션 jsonl 파싱(message.id dedup)으로 회귀.

**Tech Stack:** bash, `claude -p`(비대화), hurl, python3(usage 파싱), git.

## Global Constraints (스펙: experiments/013-qwen38max-direct/README.md)

- 모델 `qwen3.8-max` 고정, thinking 파라미터 **무지정**(엔드포인트 기본값), n=1
- `ANTHROPIC_BASE_URL=https://dashscope-intl.aliyuncs.com/apps/anthropic` (끝에 `/v1` 금지), `ANTHROPIC_AUTH_TOKEN=$QWEN_API_KEY`
- 격리: 전용 `CLAUDE_CONFIG_DIR=$HOME/ralph-exp013/claude-config` — 개인 훅·전역 CLAUDE.md·플러그인 배제
- 프롬프트: `~/ralph-exp010/PROMPT.md`와 byte-identical (diff 0 확인 필수)
- 상한 30 iteration, 무개입 (하네스 인프라 복구만 허용·기록)
- 판정: 검증(게이트 통과+독립 재검증 일치) / 기각(30 iter 소진) / 보류(모델 외적 장애로 루프 불성립)
- n=1이므로 report에서 효율·프로파일 서사 금지 (완주 여부까지만)
- 실험 종료 절차(CLAUDE.md): report.md 헤더 2줄 형식 → `python3 scripts/update_readme_results.py` → catalog·ROADMAP 갱신

---

### Task 1: 하네스 베이스 구축 (`~/ralph-exp013`)

**Files:**
- Create: `~/ralph-exp013/{PROMPT.md, measure.sh, driver.sh, parse_usage.py, harness-hurl/, claude-config/}` (런타임 베이스)
- Create: `experiments/013-qwen38max-direct/runs/{driver.sh, measure.sh, parse_usage.py}` (리포 사본)

**Interfaces:**
- Consumes: `~/ralph-exp012/{PROMPT.md, harness-hurl/, measure.sh}` (원본), `~/.zsh_secrets`의 `QWEN_API_KEY`
- Produces: Task 2가 실행할 `driver.sh`(RUN=`qwen-1`, metrics CSV `$BASE/metrics-qwen-1.csv` 한 줄 = `iter,ts,exit,succ_files,exec_reqs,claim,gate`), `measure.sh "$REPO"` → stdout `"succ_files,exec_reqs"`, `parse_usage.py <config_dir>` → stdout CSV 2줄

- [ ] **Step 1: 베이스 디렉토리·프롬프트·hurl 스위트 복사**

```bash
mkdir -p ~/ralph-exp013
cp ~/ralph-exp012/PROMPT.md ~/ralph-exp013/PROMPT.md
cp -R ~/ralph-exp012/harness-hurl ~/ralph-exp013/harness-hurl
ls ~/ralph-exp013/harness-hurl/*.hurl | wc -l   # 기대: 13
```

- [ ] **Step 2: measure.sh 치환본 생성 (BASE만 exp012→exp013)**

```bash
sed 's|ralph-exp012|ralph-exp013|' ~/ralph-exp012/measure.sh > ~/ralph-exp013/measure.sh
chmod +x ~/ralph-exp013/measure.sh
bash -n ~/ralph-exp013/measure.sh && diff <(sed 's|ralph-exp013|ralph-exp012|' ~/ralph-exp013/measure.sh) ~/ralph-exp012/measure.sh
```

기대: `bash -n` 무출력, diff 무출력 (BASE 외 변경 없음 증명).

- [ ] **Step 3: 격리 claude-config 생성 (온보딩 우회)**

```bash
mkdir -p ~/ralph-exp013/claude-config
cat > ~/ralph-exp013/claude-config/.claude.json <<'EOF'
{"hasCompletedOnboarding": true}
EOF
```

- [ ] **Step 4: driver.sh 작성 (EXP-012 원형 − ccr 감시 + 직결 env)**

`~/ralph-exp013/driver.sh`:

```bash
#!/bin/bash
# EXP-013: Claude Code x qwen3.8-max 직결(ANTHROPIC_BASE_URL) 랄프 루프 (EXP-012 driver에서 ccr 제거, n=1)
# 기동: nohup caffeinate -is "$HOME/ralph-exp013/driver.sh" > /dev/null 2>&1 &
source "$HOME/.zsh_secrets"
BASE="$HOME/ralph-exp013"
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
```

- [ ] **Step 5: driver.sh 문법 검사**

```bash
chmod +x ~/ralph-exp013/driver.sh && bash -n ~/ralph-exp013/driver.sh
```

기대: 무출력(통과).

- [ ] **Step 6: parse_usage.py 작성 (세션 jsonl, message.id dedup — EXP-007 교훈)**

`~/ralph-exp013/parse_usage.py`:

```python
#!/usr/bin/env python3
"""EXP-013: 격리 CLAUDE_CONFIG_DIR 세션 jsonl -> usage CSV. assistant message.id 단위 dedup 후 합산."""
import json, sys, glob

def main(cfg_dir):
    seen = {}
    for path in glob.glob(f"{cfg_dir}/projects/**/*.jsonl", recursive=True):
        for line in open(path):
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            m = d.get("message") or {}
            if d.get("type") == "assistant" and m.get("id") and m.get("usage"):
                seen[m["id"]] = m["usage"]  # 같은 id 재등장 시 마지막 기록 사용
    tot = {"input": 0, "cache_create": 0, "cache_read": 0, "output": 0}
    for u in seen.values():
        tot["input"] += u.get("input_tokens", 0) or 0
        tot["cache_create"] += u.get("cache_creation_input_tokens", 0) or 0
        tot["cache_read"] += u.get("cache_read_input_tokens", 0) or 0
        tot["output"] += u.get("output_tokens", 0) or 0
    print("messages,input,cache_create,cache_read,output")
    print(f"{len(seen)},{tot['input']},{tot['cache_create']},{tot['cache_read']},{tot['output']}")

if __name__ == "__main__":
    main(sys.argv[1])
```

- [ ] **Step 7: parse_usage.py 빈 입력 동작 확인**

```bash
python3 ~/ralph-exp013/parse_usage.py ~/ralph-exp013/claude-config
```

기대: 헤더 + `0,0,0,0,0` (projects/ 없음 → 0 집계, 예외 없음).

- [ ] **Step 8: 리포 사본 커밋**

```bash
cd /Users/dohyunjung/Workspace/roboco-io/research/vibecoding-token-experiments
mkdir -p experiments/013-qwen38max-direct/runs
cp ~/ralph-exp013/driver.sh ~/ralph-exp013/measure.sh ~/ralph-exp013/parse_usage.py experiments/013-qwen38max-direct/runs/
git add experiments/013-qwen38max-direct/runs && git commit -m "EXP-013 하네스: 직결 driver·measure 치환본·세션 jsonl usage 파서"
```

---

### Task 2: Phase 0 게이트 (실행 전 검증 4항목)

**Files:**
- Create: `experiments/013-qwen38max-direct/runs/phase0.md`
- Test: 격리 스모크용 임시 리포 `~/ralph-exp013/smoke-repo` (기록 후 삭제)

**Interfaces:**
- Consumes: Task 1의 `driver.sh` env 블록(동일 env로 스모크), `measure.sh`, `parse_usage.py <config_dir>`
- Produces: `phase0.md` 4항목 통과 기록 — **전 항목 통과 전 Task 3 진입 금지**. 실패 항목은 모델 외적 장애 여부를 기록(보류 판정 근거)

- [ ] **Step 1: ① 직결 claude -p 도구 사용 스모크**

```bash
mkdir -p ~/ralph-exp013/smoke-repo && cd ~/ralph-exp013/smoke-repo && git init -q
source ~/.zsh_secrets
env -u ANTHROPIC_API_KEY \
  CLAUDE_CONFIG_DIR="$HOME/ralph-exp013/claude-config" \
  ANTHROPIC_BASE_URL=https://dashscope-intl.aliyuncs.com/apps/anthropic \
  ANTHROPIC_AUTH_TOKEN="$QWEN_API_KEY" \
  ANTHROPIC_MODEL=qwen3.8-max \
  ANTHROPIC_SMALL_FAST_MODEL=qwen3.8-max \
  ANTHROPIC_DEFAULT_HAIKU_MODEL=qwen3.8-max \
  CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1 \
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
  API_TIMEOUT_MS=600000 \
  claude -p "Create a file hello.txt containing exactly 'hello', git add and commit it with message 'smoke', then reply DONE." \
  --dangerously-skip-permissions < /dev/null
cat hello.txt && git -C ~/ralph-exp013/smoke-repo log --oneline
```

기대: 출력에 DONE, `hello.txt`=hello, 커밋 1개 → **tool call 왕복·모델 라우팅 검증**. 401/404면 엔드포인트·키 문제(모델 외적)로 기록.

- [ ] **Step 2: ② PROMPT diff 0**

```bash
diff ~/ralph-exp010/PROMPT.md ~/ralph-exp013/PROMPT.md && echo BYTE-IDENTICAL
```

기대: `BYTE-IDENTICAL`.

- [ ] **Step 3: ③ measure.sh 빈 리포 동작·포트 8000 비점유**

```bash
~/ralph-exp013/measure.sh ~/ralph-exp013/nonexistent ; lsof -ti :8000 || echo PORT-8000-FREE
```

기대: `0,0` + `PORT-8000-FREE`.

- [ ] **Step 4: ④ usage 파싱 스모크 (Step 1 세션 대상)**

```bash
python3 ~/ralph-exp013/parse_usage.py ~/ralph-exp013/claude-config
```

기대: messages ≥ 1, input/output > 0 (qwen usage 필드가 Claude 스키마로 집계됨 확인). 전부 0이면 직결에서도 usage 유실 → phase0.md에 한계 기록(완주 판정에는 영향 없음, EXP-012 선례와 동일 처리).

- [ ] **Step 5: 스모크 세션 격리·본 실행 오염 방지**

```bash
rm -rf ~/ralph-exp013/smoke-repo
mv ~/ralph-exp013/claude-config/projects ~/ralph-exp013/claude-config-projects-phase0 2>/dev/null || true
```

(Phase 0 세션 jsonl을 본 실행 집계에서 분리 — EXP-012의 `usage-tap-phase0.jsonl` 분리와 동일 원칙.)

- [ ] **Step 6: phase0.md 작성·커밋**

`experiments/013-qwen38max-direct/runs/phase0.md`에 ①–④ 실측 결과(시각·출력 요약·트러블슈팅)를 EXP-012 phase0.md 형식으로 기록:

```bash
cd /Users/dohyunjung/Workspace/roboco-io/research/vibecoding-token-experiments
git add experiments/013-qwen38max-direct/runs/phase0.md && git commit -m "EXP-013 Phase 0 통과 기록"
```

---

### Task 3: 본 run 실행 (qwen-1, 무개입)

**Files:**
- Create (런타임): `~/ralph-exp013/{app-qwen-1/, metrics-qwen-1.csv, ralph-run-qwen-1.log, driver.log, done-qwen-1}`

**Interfaces:**
- Consumes: Task 1 `driver.sh`, Task 2 전 항목 통과
- Produces: `metrics-qwen-1.csv`(iter별 한 줄), `done-qwen-1` 마커 → Task 4의 채점 입력

- [ ] **Step 1: 기동**

```bash
nohup caffeinate -is "$HOME/ralph-exp013/driver.sh" > /dev/null 2>&1 &
sleep 10 && tail -2 ~/ralph-exp013/driver.log && pgrep -f ralph-exp013/driver.sh
```

기대: `RUN qwen-1 (direct qwen3.8-max) start` 로그 + PID 존재.

- [ ] **Step 2: 모니터링 (개입 금지 — 관찰만)**

주기적으로(약 10분 간격):

```bash
tail -3 ~/ralph-exp013/metrics-qwen-1.csv 2>/dev/null; ls ~/ralph-exp013/done-qwen-1 2>/dev/null && echo FINISHED
```

- 허용되는 개입: 없음. 하네스 인프라 장애(드라이버 프로세스 사망 등)만 재기동으로 복구하고 driver.log에 기록 (EXP-012 스톨 선례 — 모델 개입 아님).
- 앱 리포(`app-qwen-1`) 내부 수정·프롬프트 추가·수동 커밋은 전면 금지.

- [ ] **Step 3: 종료 확인**

```bash
tail -1 ~/ralph-exp013/driver.log && tail -1 ~/ralph-exp013/metrics-qwen-1.csv
```

기대: `RUN qwen-1 finished` + 마지막 행의 gate 값 확인 (`pass` = 완주 주장, 30행 소진 = 기각 후보).

---

### Task 4: 독립 재검증·계측 집계

**Files:**
- Create: `experiments/013-qwen38max-direct/runs/qwen-1/{metrics-qwen-1.csv, driver.log, usage-qwen-1.csv, ralph-run-qwen-1.log.gz}`

**Interfaces:**
- Consumes: Task 3 산출물, `measure.sh`, `parse_usage.py`
- Produces: 독립 재검증 2회 결과(일치 여부), usage CSV, wall-clock·커밋 수 — Task 5 report의 근거 수치

- [ ] **Step 1: 독립 재검증 2회 (게이트와 동일 채점기 재실행)**

```bash
~/ralph-exp013/measure.sh ~/ralph-exp013/app-qwen-1
sleep 5
~/ralph-exp013/measure.sh ~/ralph-exp013/app-qwen-1
```

기대(검증 판정 시): 2회 모두 `13,154` — driver 게이트 결과와 3중 일치.

- [ ] **Step 2: 계측 집계**

```bash
python3 ~/ralph-exp013/parse_usage.py ~/ralph-exp013/claude-config | tee ~/ralph-exp013/usage-qwen-1.csv
git -C ~/ralph-exp013/app-qwen-1 log --oneline | wc -l
head -1 ~/ralph-exp013/metrics-qwen-1.csv; tail -1 ~/ralph-exp013/metrics-qwen-1.csv
```

wall-clock = driver.log의 start/finished 시각 차. 커밋 수 = `git log` 행 수.

- [ ] **Step 3: 아카이브·커밋**

```bash
cd /Users/dohyunjung/Workspace/roboco-io/research/vibecoding-token-experiments
mkdir -p experiments/013-qwen38max-direct/runs/qwen-1
cp ~/ralph-exp013/metrics-qwen-1.csv ~/ralph-exp013/driver.log ~/ralph-exp013/usage-qwen-1.csv experiments/013-qwen38max-direct/runs/qwen-1/
gzip -c ~/ralph-exp013/ralph-run-qwen-1.log > experiments/013-qwen38max-direct/runs/qwen-1/ralph-run-qwen-1.log.gz
git add experiments/013-qwen38max-direct/runs/qwen-1 && git commit -m "EXP-013 qwen-1 run 산출물 아카이브"
```

---

### Task 5: report.md·실험 종료 절차

**Files:**
- Create: `experiments/013-qwen38max-direct/report.md`
- Modify: `hypotheses/catalog.md`(M-09 상태), `ROADMAP.md`(체크박스), `README.md`(스크립트 재생성 + 필요시 종합 인사이트)

**Interfaces:**
- Consumes: Task 4의 수치(재검증·usage·wall-clock·커밋)·판정 기준(스펙 사전 등록)
- Produces: 파싱 가능한 report 헤더 2줄 — `- 가설: [M-09](../../hypotheses/catalog.md) — <문장>`, `- **판정: <검증|기각|보류>** — <핵심 요약 한 문장>`

- [ ] **Step 1: report.md 작성**

EXP-012 report.md 구조를 따라 작성. 헤더 2줄은 위 형식 그대로(파싱 대상). 본문: 조건 요약, iteration 경과표(metrics CSV 기반), 게이트·독립 재검증 결과, usage 집계(참고 수치 — n=1 효율 서사 금지), 트러블슈팅·각주(하네스 복구 있었다면 기록), 판정 근거.

- [ ] **Step 2: README 결과 섹션 재생성**

```bash
cd /Users/dohyunjung/Workspace/roboco-io/research/vibecoding-token-experiments
python3 scripts/update_readme_results.py
git diff --stat README.md
```

기대: `<!-- RESULTS -->` 마커 사이에 EXP-013 행 추가.

- [ ] **Step 3: catalog·ROADMAP 갱신**

`hypotheses/catalog.md` M-09 행의 상태를 `진행중` → 판정(요약 포함, M-08 행 형식 준수)으로, 링크를 `report.md`로 교체. `ROADMAP.md` EXP-013 항목을 `- [x]` + 판정 요약 + 보고서 링크로 갱신. 직결 스택 결과가 기존 결론(ccr 스택 서사)을 바꾸면 README `### 종합 인사이트` 수동 갱신.

- [ ] **Step 4: 최종 커밋**

```bash
git add experiments/013-qwen38max-direct/report.md hypotheses/catalog.md ROADMAP.md README.md
git commit -m "EXP-013 완료: Claude Code × qwen3.8-max 직결 (M-09 <판정>)"
```

(`<판정>`은 실측 결과로 치환. 푸시는 사용자 지시 시에만.)
