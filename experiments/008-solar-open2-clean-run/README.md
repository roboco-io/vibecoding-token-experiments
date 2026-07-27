# EXP-008 설계: Solar Open 2 무오염 클린 run — 완주 가능성 단일 검증

## 목적

**과금·비용은 판정에서 배제한다.** 질문은 하나다: EXP-007 부검에서 밝힌 교란 요인(환경 오염·외부 kill·짧은 상한)을 제거하면, **solar-open2가 랄프 루프로 RealWorld 백엔드 구현을 완주할 수 있는가.**

## 가설

[M-04](../../hypotheses/catalog.md) — 오염 제거(격리 설정)·무교란·충분한 상한(30 iter) 조건에서 solar-open2는 랄프 루프로 RealWorld 백엔드(공식 Hurl 154/154)를 무개입 완주할 수 있다.

EXP-007 근거: 유효 13 iteration 중 3개가 오염 지시(superpowers·AskUserQuestion 규칙) 준수로 잠식, 2개가 외부 kill로 유실됐고, 수렴은 실재했으며(1/13→3/13), 마지막 iteration은 실패 원인 5개를 정확히 진단한 상태에서 소진됐다. 반대 근거(완주 실패 예측): 선언-실행 탈락·thinking 폭주는 오염과 무관한 모델 자체 결함이다.

## EXP-006 대비 변경점 (사전 고정)

| 항목 | EXP-006 open2-2 | EXP-008 | 근거 |
|------|-----------------|---------|------|
| 설정 디렉토리 | 실험자 `~/.claude` (superpowers 훅·글로벌 CLAUDE.md·플러그인 주입) | **격리 `CLAUDE_CONFIG_DIR`** (빈 설정) | EXP-007 오염 실증 |
| 작업 리포 위치 | `~/Workspace/...` (조상 `~/Workspace/CLAUDE.md` 주입) | **`~/ralph-exp008/app/`** (홈 직하 — 조상 CLAUDE.md 없음 확인) | 〃 |
| iteration 상한 | 15 (재개마다 sed 감산) | **30 고정** (재개 시 잔여 = 30 − metrics.csv 기록 수로 산출, sed 금지) | 15 iter 소진 시점에도 수렴 중 |
| `.ralph-done` | 무검증 신뢰 | **외부 검증 게이트** — 하네스가 Hurl 154/154 확인, 미달 시 삭제 후 계속 | open2-1 허위 신고 |
| 교란 방지 | 없음 (kill 2회·슬립 1회) | **`caffeinate -is` + nohup 분리 실행**, Claude Code UI에서 기동 금지 | iteration 2개 유실 |
| 수렴 계측 | 종료 후 1회 | **매 iteration 종료 시 하네스가 Hurl 자동 실행** → `metrics.csv` (수렴 곡선), 리포 스냅샷 아카이브 | 실패 시에도 특성 데이터 확보 |
| 판정 지표 | 완주 + 비용 | **완주 여부만** (usage는 참고 수집, 판정 미사용) | 실험자 지시 |

**불변 조건**: PROMPT.md는 EXP-005/006과 byte-identical (변경 금지). env는 공식 claude-upstage.sh `set_claude_env` 그대로 (open2-2 ralph.sh와 동일 — thinking 억제 등 추가 튜닝 없음: "공식 가이드 그대로"가 시험 대상). 모델 slot 5개 전부 solar-open2, 직결 `ANTHROPIC_BASE_URL=https://api.upstage.ai`. n=1.

## 하네스 구성 (`~/ralph-exp008/`)

```
~/ralph-exp008/
├── ralph.sh            # 아래 스펙. PROMPT.md와 함께 리포 밖(harness 레벨)에 위치
├── PROMPT.md           # 정본 복사 (byte-identical 검증 후)
├── claude-config/      # 격리 CLAUDE_CONFIG_DIR (Phase 0에서 스모크로 초기화)
├── harness-hurl/       # 하네스 전용 공식 Hurl 13파일 + 러너 (모델 리포와 분리, 수정 불가)
├── app/                # 작업 리포 (빈 git init — 모델의 세계)
├── metrics.csv         # iter, 종료시각, exit, succ_files, exec_reqs, ralph_done_claim, gate_result
├── snapshots/iter-NN/  # iteration별 리포 스냅샷 (node_modules 제외 rsync)
└── ralph-run.log
```

주의: PROMPT.md가 리포 밖이므로 EXP-006과 달리 "PROMPT.md·ralph.sh 수정 금지" 지시의 대상 파일이 모델 시야에 없다 — 리포 안에 사본을 두는 EXP-006 방식을 유지한다(동일 조건). 즉 `app/PROMPT.md`·`app/ralph.sh`는 EXP-006과 동일하게 배치하되, **실행은 하네스 레벨 wrapper가 담당**한다.

### ralph.sh v2 스펙 (게이트·계측 내장)

```bash
#!/bin/bash
# EXP-008: 격리 환경 + 검증 게이트 + iteration별 수렴 계측
BASE=~/ralph-exp008; REPO=$BASE/app; MAX_ITER=30
DONE_ITER=$( [ -f $BASE/metrics.csv ] && grep -c '^[0-9]' $BASE/metrics.csv || echo 0 )
for i in $(seq $((DONE_ITER+1)) $MAX_ITER); do
  echo "=== iteration $i start: $(date '+%F %T') ===" >> $BASE/ralph-run.log
  env -u ANTHROPIC_API_KEY \
    CLAUDE_CONFIG_DIR=$BASE/claude-config \
    ANTHROPIC_BASE_URL=https://api.upstage.ai \
    ANTHROPIC_AUTH_TOKEN=<Upstage 키> \
    ANTHROPIC_MODEL=solar-open2 ANTHROPIC_SMALL_FAST_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_SONNET_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_OPUS_MODEL=solar-open2 \
    API_TIMEOUT_MS=600000 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144 CLAUDE_CODE_MAX_OUTPUT_TOKENS=131072 \
    CLAUDE_STREAM_IDLE_TIMEOUT_MS=600000 \
    claude -p "$(cat $REPO/PROMPT.md)" --dangerously-skip-permissions \
    < /dev/null >> $BASE/ralph-run.log 2>&1
  EXIT=$?
  # --- 계측: 하네스 Hurl 실행 (모델 산출물과 무관하게 매번) ---
  rsync -a --exclude node_modules "$REPO/" "$BASE/snapshots/iter-$i/"
  RESULT=$($BASE/harness-hurl/measure.sh "$REPO")   # "succ_files,exec_reqs" 출력, 서버 기동 실패 시 "0,0"
  CLAIM=$( [ -f $REPO/.ralph-done ] && echo 1 || echo 0 )
  GATE=pass
  if [ "$CLAIM" = 1 ] && [ "${RESULT%%,*}" != "13" ]; then
    rm "$REPO/.ralph-done"; GATE=rejected   # 허위 신고 게이트
  fi
  echo "$i,$(date '+%F %T'),$EXIT,$RESULT,$CLAIM,$GATE" >> $BASE/metrics.csv
  [ -f "$REPO/.ralph-done" ] && { echo "=== DONE (gate pass) iter $i ===" >> $BASE/ralph-run.log; break; }
done
```

`measure.sh`: 포트 8000 정리 → `npm run dev`(또는 start) 백그라운드 기동 → 포트 대기(최대 30초) → 공식 13파일 실행 → 통과 파일/실행 요청 수 출력 → 서버 종료(`lsof -ti:8000 | xargs kill -9`). 서버 기동 불가 iteration은 `0,0`으로 기록 (수렴 곡선의 정당한 데이터 포인트).

기동: `nohup caffeinate -is $BASE/ralph.sh > /dev/null 2>&1 &` — **터미널에서 직접 실행** (Claude Code 백그라운드 작업으로 띄우지 않음 — EXP-006 kill 사고 원인 제거).

## Phase 0 (기동 전 관문 — 하나라도 실패 시 시작 금지)

1. 격리 스모크: `CLAUDE_CONFIG_DIR=$BASE/claude-config` + 직결 env로 `claude -p` 왕복 성공, 출력에 superpowers/CLAUDE.md 흔적 없음 확인 (세션 JSONL에서 SessionStart 훅 부재 검증)
2. PROMPT.md byte-identical: `diff` 대상 `~/Workspace/roboco-io/research/realworld-exp005-solar-1/PROMPT.md`
3. harness-hurl 정본성: EXP-006 벤더링본(byte-identical 검증됨)에서 복사 후 재 diff
4. `measure.sh` 단독 동작: EXP-006 최종 산출물(`realworld-exp006-open2-2`) 대상 dry-run → `3,94` 재현 확인
5. CCR 정지(`ccr stop`) 및 포트 8000 비점유 확인

## 판정 기준 (사전 고정)

- **검증(완주)**: 30 iter 내 `.ralph-done` 생성 + 게이트 통과(13/13 파일·154/154 요청) + 실험자 독립 재실행 일치.
- **기각(미완주)**: 30 iter 소진. 이 경우 metrics.csv 수렴 곡선으로 "정체형(plateau)인지 진행형(rising)인지"를 부검·보고 — 진행형이면 상한이, 정체형이면 모델 능력이 관문이라는 후속 판단 근거가 된다.
- **보류(무효)**: 외부 교란(kill·슬립·API 장애)으로 iteration이 1개라도 유실되거나, 하네스 결함으로 게이트/계측이 오작동한 경우.
- 판정과 무관하게 usage(message.id dedup, EXP-007 방식)·세션 로그는 아카이브한다.

## 중단 상한·소요 예상

- 상한: 30 iteration 또는 wall-clock 10h 중 선도달 (EXP-006 실적 15 iter ≈ 2h + 계측 오버헤드 감안 시 30 iter ≈ 4–6h 예상. 10h는 안전판).
- 비용 상한 없음(과금 배제 — 베타 단가 미공개). 단 API 401/429 연속 3 iteration이면 중단(무효).

## 리스크

- 격리 config의 headless 최초 실행이 온보딩 상태를 요구할 수 있음 — Phase 0 스모크에서 발견·해결(발견 시 절차를 기록해 재현성 확보).
- 상한 30 iter는 EXP-006(15)과 다르므로 iteration 수 기반 직접 비교는 불가 — 본 실험은 비교가 아닌 완주 가능성 단일 검증이므로 허용.
- 게이트·매 iteration 계측은 프로토콜 신설 — EXP-006과의 조건 차이로 기록.
- 오염 제거에도 미완주라면 남는 변수는 모델 결함(선언-실행 탈락·thinking 폭주)이며, 이는 본 실험 설계로는 더 분해할 수 없다(추가 개입은 "공식 가이드 그대로" 조건을 깨므로 후속 실험 소관).
