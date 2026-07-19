# EXP-001: Ralph loop vs Plan-then-execute

## 가설

[S-01](../../hypotheses/catalog.md): Plan-then-execute가 Ralph loop보다 동일 과제에서 토큰을 적게 쓴다.

## 과제

[realworld-backend](../../tasks/realworld-backend/) — RealWorld App 백엔드 구현

## 조건 (Conditions)

| 조건 | 설명 | runs 디렉토리 |
|------|------|---------------|
| ralph-loop | 골(과제 스펙 + 완료 기준)을 지정한 뒤 Ralph loop로 자율 진행 | `runs/ralph-loop/` |
| plan-then-execute | 계획을 먼저 수립하고 태스크를 분할한 뒤, 개별 태스크를 병렬로 구현 | `runs/plan-then-execute/` |

## 통제 변수

- 모델: Claude Opus 고정 (모든 조건, 모든 세션)
- 기술 스택: 실험 시작 전 확정하여 양 조건에 동일 지정 (TBD)
- 초기 입력: `tasks/realworld-backend/README.md`의 과제 정의를 동일하게 제공
- 실험자 개입: 최초 골 지정 이후 무개입 원칙. 불가피한 개입은 로그에 기록

## 측정 방법

- 조건별 세션 로그(`~/.claude/projects/*.jsonl`) 사본을 `runs/<조건>/`에 보관
- ccusage / tokenhabit으로 토큰 집계 (input / output / cache creation / cache read / 총 과금)
- 보조 지표: 벽시계 시간, API 테스트 통과율, 세션 수

## 성공 기준

- 과제 완료 판정: RealWorld 공식 API 테스트 전체 통과
- 가설 판정: 총 과금 토큰 기준으로 비교. 두 조건 모두 과제를 완료한 경우에만 유효 비교로 인정
