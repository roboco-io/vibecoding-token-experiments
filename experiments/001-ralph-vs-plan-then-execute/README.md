# EXP-001: Ralph loop vs Plan-then-execute

> 실행 절차: [protocol.md](protocol.md) · 초기 프롬프트: [prompts/](prompts/)

## 가설

[S-01](../../hypotheses/catalog.md): Plan-then-execute가 Ralph loop보다 동일 과제에서 토큰을 적게 쓴다.

## 과제

[realworld-backend](../../tasks/realworld-backend/) — RealWorld App 백엔드 구현

## 조건 (Conditions)

| 조건 | 설명 | runs 디렉토리 |
|------|------|---------------|
| ralph-loop | 골(과제 스펙 + 완료 기준)을 지정한 뒤 Ralph loop로 자율 진행 | `runs/ralph-loop/` |
| plan-then-execute | 계획 수립 → 아토믹 태스크 분할 → 태스크마다 새 세션에서 병렬 구현. 컨텍스트 연속성은 문서로 유지 | `runs/plan-then-execute/` |

### plan-then-execute 조건 상세 (컨텍스트 윈도우 관리 원칙)

- **아토믹 태스크 분할**: 계획 단계에서 작업을 가능한 한 잘게, 서로 독립적으로 실행 가능한 단위로 나눈다.
- **태스크당 새 세션**: 각 태스크는 새로운 세션에서 수행한다. 세션 하나가 여러 태스크를 이어서 처리하지 않는다 (컨텍스트 누적 방지).
- **문서 기반 연속성**: 세션 간 컨텍스트 전달은 오직 문서(계획서, 태스크 명세, 완료 기록)에 의존한다. 계획 단계 산출물로 태스크별 명세 문서를 만들고, 각 세션은 해당 명세만 읽고 시작한다.

## 통제 변수

- 모델: Claude Opus 고정 (모든 조건, 모든 세션)
- 기술 스택: TypeScript (Node.js) + Fastify + Prisma + SQLite (선정 근거는 [과제 스펙](../../tasks/realworld-backend/README.md) 참조)
- 초기 입력: `tasks/realworld-backend/README.md`의 과제 정의를 동일하게 제공
- 실험자 개입: 최초 골 지정 이후 무개입 원칙. 불가피한 개입은 로그에 기록

## 측정 방법

- 조건별 세션 로그(`~/.claude/projects/*.jsonl`) 사본을 `runs/<조건>/`에 보관
- ccusage / tokenhabit으로 토큰 집계 (input / output / cache creation / cache read / 총 과금)
- 보조 지표: 벽시계 시간, API 테스트 통과율, 세션 수

## 성공 기준

- 과제 완료 판정: RealWorld 공식 API 테스트 전체 통과
- 가설 판정: 총 과금 토큰 기준으로 비교. 두 조건 모두 과제를 완료한 경우에만 유효 비교로 인정
