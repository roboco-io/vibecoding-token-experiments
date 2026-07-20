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

## 왜 이런 결과가 나왔나

1. **세션 분할 = 캐시 파편화.** ralph-loop는 단일 세션이 프롬프트 캐시를 끝까지 재활용했다(cache_creation 234K). PTE는 16개 세션이 각각 컨텍스트를 처음부터 구축해 cache_creation이 2.04M(8.7배)으로 폭증했고, 세션마다 계획서·명세·기존 코드를 다시 읽어 cache_read도 5배였다.
2. **문서 기반 연속성의 작성 비용.** 계획 세션이 상세 명세 12건(인터페이스 계약 포함)을 산출하고, 각 실행 세션이 완료 기록을 작성했다. output이 798K vs 91K — 코드 외에 '세션 간 전달용 문서'라는 부산물을 계속 생산한 비용이다.
3. **조율 마찰의 토큰 비용.** 격리된 세션들은 서로 대화할 수 없어 마찰이 문서·재실행으로 해소됐다: 태스크 08은 공유 인프라 블로커 앞에서 범위 규칙 때문에 멈췄고(완료 기록 미작성), 검증 게이트 RED → 수정 태스크 2건 + 재검증 세션이 추가로 필요했다. 병렬 git 커밋 경합으로 커밋 누락도 발생했다.
4. **과제가 단일 컨텍스트에 충분히 들어갔다.** RealWorld 백엔드는 Opus 단일 세션이 컨텍스트 부담 없이 완주할 수 있는 크기였다(1 이터레이션, 14분). 분할의 이득(컨텍스트 한계 회피)이 발동할 조건 자체가 없었고 오버헤드만 남았다.

## 품질 관찰 (토큰 외)

- 두 조건 모두 API 테스트 100% 통과. 다만 **서로 다른 정본을 채택**: upstream이 Postman→Hurl/Bruno로 마이그레이션된 상태에서 ralph는 최신 Hurl 테스트(154요청)를, PTE의 T12는 클래식 Postman 컬렉션(311 assertion, 커밋 `dedb6969fe`)을 선택했다. 완주 판정에는 문제없으나 조건 간 테스트 세트가 동일하지 않았음을 기록한다.
- PTE의 부수 산출물(계획서·인터페이스 계약·태스크별 완료 기록·vitest 통합 테스트)은 ralph 산출물에 없는 자산이다. 유지보수·인수인계 관점의 가치는 이 실험의 측정 범위 밖.
- PTE의 검증 게이트(T12)는 결함 2건을 정확히 특정한 고품질 보고를 남겼고, 수정→재검증 사이클이 문서만으로 작동함을 확인했다.

## 한계와 후속 실험

- **n=1, 단일 과제 크기.** 이 결과는 "과제가 단일 세션 컨텍스트에 들어갈 때"에 한정된다. 컨텍스트 한계를 초과하는 대형 과제에서는 ralph-loop의 세션이 비대해지며 역전될 가능성이 있다 → 후속 실험 후보: 과제 규모를 키운 EXP-002.
- 조건 간 테스트 정본 불일치(위 참조). 후속 실험에서는 테스트 세트를 사전 고정해야 한다.
- ralph-loop가 1 이터레이션 만에 끝나 루프 구조(반복 재시작 시 컨텍스트 재구축)의 비용이 관측되지 않았다.
- 인프라 사고: 1차 ralph 실행이 무효 `ANTHROPIC_API_KEY`로 전량 실패(측정 제외, [runs/ralph-loop/meta.md](runs/ralph-loop/meta.md) 참조). 이후 두 조건 모두 `env -u ANTHROPIC_API_KEY`로 동일화.

## 원자료

- [runs/ralph-loop/](runs/ralph-loop/) — meta.md, logs/(세션 1), test-result.txt, ralph-run.log
- [runs/plan-then-execute/](runs/plan-then-execute/) — meta.md, logs/(세션 16), test-result.txt, pte-run.log
- 집계: `python3 ../../scripts/aggregate_tokens.py runs/ralph-loop/logs runs/plan-then-execute/logs`
