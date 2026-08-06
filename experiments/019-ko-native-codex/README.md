# EXP-019 설계: 네이티브 Opus 4.8·Opus 5·Codex×gpt-5.6-sol 한국어 조건 완주 검증 (각 n=3)

## 배경

EXP-017이 직결 2사(qwen·kimi)의 한국어 조건 완주를 검증했다. 본 실험은 나머지 EN 기준선 3조건 — 네이티브 Opus 4.8(EXP-010)·Opus 5(EXP-009/010)·Codex CLI×gpt-5.6-sol(EXP-011/016) — 에 동일한 한국어 정본 조건을 적용해, 대시보드의 한국어 vs 영어 비교를 전 조건으로 확장한다.

## 가설

[L-03](../../hypotheses/catalog.md) — 네이티브 Opus 4.8·Opus 5(Claude Code)와 gpt-5.6-sol(Codex CLI)은 한국어 정본 프롬프트(전 산출물 한국어 지시 포함) 조건에서도 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 iteration 안에 무개입 완주할 수 있다 (각 n=3, 완주율 판정·과금 배제).

## 조건 (사전 고정)

- **PROMPT**: EXP-017 한국어 정본 byte-identical (md5 `fa75275f…`, [EXP-017 runs/PROMPT-ko.md](../017-ko-condition/runs/PROMPT-ko.md))
- **하네스**: 각 EN 기준선 driver를 이식, PROMPT와 RUN명만 변경
  - Opus 4.8·5: EXP-010 driver 이식 — **비격리(기본 ~/.claude)**, EXP-009/010 EN 기준선과 동일 조건 (OAuth 키체인 제약, EXP-009 report 한계 절 명문화 계승). 상한 10 iter
  - Codex: EXP-011 driver 이식 — 전용 CODEX_HOME(EXP-011 사본, 세션 초기화), effort medium, 상한 30 iter
- **채점**: measure v4 게이트 + 완료 후 독립 재검증 2회 (기존 원칙)
- **실행**: 순차 9 run 교차 순서 (48ko → 5ko → solko 반복). 동시 실행 금지
- **usage**: Opus는 기본 `~/.claude/projects`의 app 디렉토리별 세션 jsonl(message.id dedup), Codex는 run별 세션 격리 이동 후 rollout 누계
- **판정 기준 (사전 등록)**: 검증(9/9 완주) / 부분 검증(조건별 3/3 여부 보고) / run 단위 보류(모델 외적 장애)
- **보조 지표 (사전 등록)**: 언어 준수 — 완주 산출물의 커밋 메시지·README 언어 전수 검사. 언어별 토큰 효율 서사는 금지(L-01 원칙), 분포 병치와 방향성 기록만

## 리스크

- Opus run은 실 계정 과금 — EXP-010과 동일 규모(각 3 run, iter 1 완주 시 run당 output 30–50K 수준 예상)
- EN 기준선과 시점 차이(Opus 4.8/5는 12일, Codex는 2일) — 완주율 비교는 유효, 시간 차이의 원인 분해는 불가(명기)
- Codex 라인은 한국어 프롬프트 + 영어권 모델 조합 — 언어 이탈(영어 산출) 발생 시 그대로 기록 (개입 금지)

## Phase 0 (기동 전 스모크)

- Opus 4.8·5: 한국어 지시 스모크 각 200 (SMOKE-OK 정확 출력)
- Codex×gpt-5.6-sol: 한국어 지시 스모크 (아래 phase0.md)
- Codex 세션 잔재 제거(사본의 sessions 초기화), Phase 0 스모크 세션은 본 계측에서 제외

## 후속

- 완주 시 아티팩트 대시보드 "한국어 vs 영어" 섹션에 3조건 추가 (EN 기준선: EXP-010 Opus 4.8 n=3 · Opus 5 n=3(EXP-010분) · EXP-011/016 sol n=3)
