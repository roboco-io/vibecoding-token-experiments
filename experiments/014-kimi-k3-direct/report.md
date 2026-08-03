# EXP-014 결과 보고: Claude Code × kimi-k3 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증

- 실험일: 2026-08-04 (00:06–00:27 KST)
- 가설: [M-10](../../hypotheses/catalog.md) — Claude Code를 Moonshot Anthropic 호환 엔드포인트로 kimi-k3에 직결하면(thinking 기본값) 격리·무개입 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다.
- **판정: 검증** — **iteration 1에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, 21분 18초·커밋 4회·개입 0, 직결 스택 트러블슈팅 0건).

## 결과

| run | 완주 | wall-clock | input (비캐시) | cache create | cache read | output | git 커밋 |
|-----|------|-----------|----------------|--------------|------------|--------|----------|
| kimi-1 | iter 1/30 | 21분 18초 | 81.3K | 0 | 2.34M | 31.3K | 4 |

- metrics: `1,2026-08-04 00:27:23,0,13,154,1,pass` — claim 1회, 게이트 기각 0회, 허위 신고 0
- 독립 재검증: 완료 후 measure.sh 2회 재실행 → 두 번 모두 `13,154` (드라이버 게이트 포함 3중 일치)
- usage(Phase 0 세션 격리 후 본 실행만, message.id dedup): assistant 50 messages, input 81,252 / cache_create 0 / cache_read 2,339,328 / output 31,302. cache_create가 0인데 cache_read가 적중하는 것은 Moonshot의 캐시 계상 방식 차이로 보이며 기록만 남긴다.

## 조건 준수 확인

- 격리 `CLAUDE_CONFIG_DIR`(온보딩 우회 1줄 config만), PROMPT는 EXP-010 정본 byte-identical, thinking 파라미터 무지정(kimi-k3는 thinking 끄기 불가·기본 ON) — [Phase 0 기록](runs/phase0.md)
- 개입 0회 (기동 후 로그 열람만, 하네스 인프라 복구 0건). 설계 리스크였던 Moonshot Tier 0 rate limit은 전 구간 미발현.

## 관찰

1. **직결 스택 방법 재사용성 확인.** EXP-013 하네스에서 BASE 경로·RUN명·모델 env(엔드포인트/키/모델 ID) 3요소만 치환해 그대로 동작 — 설계~Phase 0~완주까지 조정 0건. Anthropic 호환 엔드포인트를 제공하는 제공자라면 이 템플릿이 그대로 이식된다는 두 번째 데이터 포인트(qwen3.8-max에 이어 kimi-k3).
2. **단일 iteration 완주.** 랄프 루프 재시도 없이 첫 세션에서 구현→공식 hurl vendoring→자체 검증→`.ralph-done`까지 완결. 게이트 기각 0회.
3. **산출 구조**: Fastify + Prisma + SQLite(qwen3.8-max와 동일 스택 선택), 커밋 4회(구현 → hurl vendoring·정렬 → README → 완료 마킹).
4. wall-clock 21분 18초, output 31.3K는 직결 쌍(EXP-013 15분 5초·34.6K)과 유사 범위이나 n=1이므로 효율·프로파일 서사는 하지 않는다 — 판정은 완주 여부 단일.

## 한계·후속

- n=1 완주 판정 실험 — 재현성(완주율)·토큰 효율 비교는 n 확충 후속 실험 필요
- Moonshot 캐시 계상(cache_create 0) 특성으로 usage 필드 간 비교 가능성이 제공자별로 다름 — 계측 표준화(ROADMAP Phase 3) 논점에 추가
- 출시 3주차 모델의 서빙 품질 변동 가능 — 시점 명기(2026-08-04)
