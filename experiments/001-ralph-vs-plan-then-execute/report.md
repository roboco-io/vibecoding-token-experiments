# EXP-001 결과 보고: Ralph loop vs Plan-then-execute

- 실험일: 2026-07-20
- 가설: [S-01](../../hypotheses/catalog.md) — Plan-then-execute가 Ralph loop보다 동일 과제에서 토큰을 적게 쓴다
- **판정: 기각 (반증)** — plan-then-execute가 billable 기준 **약 8.7배 더 많은** 토큰을 사용

## 측정 결과

| 지표 | ralph-loop | plan-then-execute |
|------|-----------:|------------------:|
| 완료 판정 | ✅ 통과 (Hurl 154요청 100%) | ✅ 통과 (Newman 311 assertion 100%) |
| 벽시계 시간 | **14분** (09:00:34→09:14:29) | 49분 (18:47:59→19:37:17) |
| 세션 수 | **1** | 16 (계획1 + 태스크12 + 수정2 + 재검증1) |
| messages | 112 | 782 |
| input_tokens | 211 | 1,457 |
| output_tokens | **90,877** | 797,845 |
| cache_creation_input_tokens | **233,687** | 2,040,513 |
| cache_read_input_tokens | 8,426,223 | 42,520,755 |
| **billable (input+output+cache_creation)** | **324,775** | **2,839,815** |

billable 차이: **-2,515,040** (plan-then-execute가 +774% 더 사용)

## 왜 이런 결과가 나왔나 — 로그 분해 분석

### 세션별 billable 분해 (PTE 16세션)

| 구간 | 세션 | billable | 비중 |
|------|------|---------:|-----:|
| 계획 | plan (14분, output 134.5K, Agent 서브에이전트 9회 호출) | 363,387 | 12.8% |
| 실행 | 01~12 태스크 12세션 | 2,139,837 | 75.3% |
| 수정 루프 | 13·14·15 (게이트 RED → 재검증) | 336,591 | 11.9% |
| | **합계** | **2,839,815** | |

**계획 세션 하나(363K)가 ralph-loop 전체 실행(325K)보다 비쌌다.**

| 세션 | billable | 세션 | billable |
|------|---------:|------|---------:|
| plan | 363,387 | 07-articles-crud | 176,594 |
| 01-scaffolding | 78,428 | 08-articles-list-feed | 218,539 |
| 02-prisma-schema | 93,398 | 09-favorites | 310,026 |
| 03-common-infra | 169,584 | 10-comments | 205,116 |
| 04-views-slug | 80,176 | 12-newman-e2e | 276,189 |
| 05-users-auth | 246,664 | 13-fix-content-type | 127,903 |
| 06-profiles | 129,168 | 14-fix-favorites-types | 100,240 |
| 11-tags | 155,955 | 15-regate | 108,448 |

### 원인 1: 세션 기동 고정비 × 16 (측정)

각 세션 첫 응답의 cache_creation으로 측정한 **세션당 기동세는 약 20.6K 토큰**(시스템 프롬프트·도구 정의·전역 설정). ralph 1회 = 20,679 vs PTE 16회 = 329,958. **기동세 차액(약 31만)만으로 ralph 전체 실행비와 맞먹는다.**

### 원인 2: 컨텍스트 재구축의 중복

기동세를 뺀 cache_creation(새로 편입된 컨텍스트)은 ralph 213K vs PTE 1,710K로 **8배**. 실체는:

- **같은 파일 반복 읽기**: `src/app.ts` 7회, `12-newman-e2e.md` 명세 5회, `tests/helpers/app.ts` 4회, `package.json` 3회. Read 호출 ralph 2회 vs PTE 49회.
- **검증의 중복**: Bash 호출 ralph 35회 vs PTE 186회. 16개 세션이 각자 `npm install`/`tsc`/`vitest`를 실행하고 그 출력이 매번 새 컨텍스트로 캐시에 편입됐다. ralph는 한 컨텍스트 안에서 한 번 본 것을 다시 보지 않는다.

### 원인 3: 문서 연속성의 생산 비용

Write/Edit 문자 수 기준 ralph는 **문서 0 / 코드 27.7K**, PTE는 **문서 60.8K / 코드 78.1K** — 산출량의 44%가 코드가 아닌 '세션 간 전달용 문서'였다. output 토큰 798K vs 91K의 상당 부분이 명세 작성·완료 기록·재읽기로 소비됐다.

### 원인 4: 격리가 만든 낭비 세션

- **11-tags**: GET 엔드포인트 하나짜리 최소 태스크가 155,955 — ralph 전체의 48%. 태스크가 작아질수록 고정비(기동세 + 리포 파악 + 독립 검증)의 비중이 지배한다. **아토믹 분할의 역설.**
- **09-favorites**: 실행 세션 중 최고가(310,026, 84메시지)인데도 빌드를 깨는 타입 에러를 남겼고, 수정 루프 3세션(336K)의 절반을 유발했다.
- **08-articles-list-feed**: 218,539를 쓰고 블로커의 원인·해법까지 찾았지만 범위 규칙 때문에 적용도 완료 기록도 못 하고 종료 — 진단 비용을 지불하고 회수하지 못했다.

### 종합

ralph가 이긴 것은 루프 구조가 우월해서가 아니라 **한 번 만든 컨텍스트(프롬프트 캐시)를 끝까지 재활용했기 때문**이다(cache_read 8.4M이 소비를 흡수). PTE는 컨텍스트를 16번 새로 지었고, 세션 간 지식 전달을 전부 '문서 쓰기 + 다시 읽기'라는 토큰 지출로 치렀다. 과제가 단일 컨텍스트에 들어가는 한 이 구조적 세금을 상쇄할 이득이 없다.

## 품질 관찰 (토큰 외)

- 두 조건 모두 API 테스트 100% 통과. 다만 **서로 다른 정본을 채택**: upstream이 Postman→Hurl/Bruno로 마이그레이션된 상태에서 ralph는 최신 Hurl 테스트(154요청)를, PTE의 T12는 클래식 Postman 컬렉션(311 assertion, 커밋 `dedb6969fe`)을 선택했다. 완주 판정에는 문제없으나 조건 간 테스트 세트가 동일하지 않았음을 기록한다.
- PTE의 부수 산출물(계획서·인터페이스 계약·태스크별 완료 기록·vitest 통합 테스트)은 ralph 산출물에 없는 자산이다. 유지보수·인수인계 관점의 가치는 이 실험의 측정 범위 밖.
- PTE의 검증 게이트(T12)는 결함 2건을 정확히 특정한 고품질 보고를 남겼고, 수정→재검증 사이클이 문서만으로 작동함을 확인했다.

## 한계와 후속 실험

- **n=1, 단일 과제 크기.** 이 결과는 "과제가 단일 세션 컨텍스트에 들어갈 때"에 한정된다. 컨텍스트 한계를 초과하는 대형 과제에서는 ralph-loop의 세션이 비대해지며 역전될 가능성이 있다 → 후속 실험 후보: 과제 규모를 키운 EXP-002.
- 조건 간 테스트 정본 불일치(위 참조). 후속 실험에서는 테스트 세트를 사전 고정해야 한다.
- ralph-loop가 1 이터레이션 만에 끝나 루프 구조(반복 재시작 시 컨텍스트 재구축)의 비용이 관측되지 않았다.

## 원자료

- [runs/ralph-loop/](runs/ralph-loop/) — meta.md, logs/(세션 1), test-result.txt, ralph-run.log
- [runs/plan-then-execute/](runs/plan-then-execute/) — meta.md, logs/(세션 16), test-result.txt, pte-run.log
- 집계: `python3 ../../scripts/aggregate_tokens.py runs/ralph-loop/logs runs/plan-then-execute/logs`
