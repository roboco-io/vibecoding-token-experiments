# EXP-009 설계: Opus 5 랄프 루프 (EXP-002 en 조건 재실행)

## 목적

Claude Opus 5 출시에 따라, 기존 Opus(4.x) 기준선(EXP-001/002)과 동일 과제·동일 프롬프트로 랄프 루프를 재실행해 **세대 갱신된 기준선**을 확보한다. EXP-002 en 조건(영문 프롬프트)을 계승한다.

## 가설

[M-05](../../hypotheses/catalog.md) — Opus 5는 EXP-002 en 조건의 랄프 루프에서 단일 세션 완주를 재현하고, Opus 4.x 기준선(en 평균 6–7분, API 38–54회) 대비 동등 이상의 효율을 보인다.

## 조건 (사전 고정)

- **PROMPT.md**: EXP-002 en run이 실제 사용한 프롬프트를 세션 로그(queue-operation)에서 추출해 byte-identical 사용 (1,230 bytes)
- **모델**: `claude --model claude-opus-5` (나머지 슬롯 기본값 — EXP-002와 동일 방식)
- **환경**: 기본 `~/.claude` (비격리). 격리 `CLAUDE_CONFIG_DIR`는 OAuth 키체인 제약으로 불가함을 Phase 0에서 확인했고, **EXP-002 기준선도 동일한 비격리 환경이었으므로 세대 비교의 통제 관점에서 오히려 정합** — 단 EXP-008(격리)과의 환경 차이를 결과 해석 시 명시할 것
- **하네스**: EXP-008 이식 — 상한 10 iteration, `.ralph-done` 외부 검증 게이트(Hurl 13/13 미달 시 기각), 매 iteration 하네스 Hurl 채점(포트 자동 탐지) → metrics.csv 수렴 곡선, iteration별 스냅샷, `caffeinate` + 터미널 분리 기동
- 작업 리포: `~/ralph-exp009/app` (빈 git init + PROMPT.md + ralph.sh, 무커밋 시작)
- 판정: 검증 = 상한 내 게이트 통과 + 독립 재검증 일치 / 기각 = 10 iter 소진 / 보류 = 교란·하네스 결함

## Phase 0 (통과 기록)

1. Opus 5 스모크: `SMOKE OK` 응답 확인 (기본 설정)
2. PROMPT byte-identical: EXP-002 en-1 세션 로그 원문에서 추출
3. harness-hurl: EXP-008 사본과 diff 0 (공식 정본 계승)
4. 포트 8000 비점유 확인
5. (기각된 시도) 격리 CLAUDE_CONFIG_DIR + 크리덴셜 파일/계정 메타 이식 → "OAuth session expired" — 키체인 정본이 격리 디렉토리에서 접근 불가. 기록으로 남김
