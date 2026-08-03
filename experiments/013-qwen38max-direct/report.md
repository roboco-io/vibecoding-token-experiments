# EXP-013 결과 보고: Claude Code × qwen3.8-max 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증

- 실험일: 2026-08-03 (23:31–23:46 KST)
- 가설: [M-09](../../hypotheses/catalog.md) — Claude Code를 DashScope Anthropic 호환 엔드포인트로 qwen3.8-max에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다.
- **판정: 검증** — **iteration 1에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, 15분 5초·커밋 4회·개입 0, 직결 스택 트러블슈팅 0건).

## 결과

| run | 완주 | wall-clock | input (비캐시) | cache create | cache read | output | git 커밋 |
|-----|------|-----------|----------------|--------------|------------|--------|----------|
| qwen-1 | iter 1/30 | 15분 5초 | 2.4K | 83.4K | 2.13M | 34.6K | 4 |

- metrics: `1,2026-08-03 23:46:28,0,13,154,1,pass` — claim 1회, 게이트 기각 0회, 허위 신고 0
- 독립 재검증: 완료 후 measure.sh 2회 재실행 → 두 번 모두 `13,154` (드라이버 게이트 포함 3중 일치)
- usage(Phase 0 세션 격리 후 본 실행만, message.id dedup): assistant 39 messages, input 2,381 / cache_create 83,419 / cache_read 2,131,487 / output 34,617

## 조건 준수 확인

- 격리 `CLAUDE_CONFIG_DIR`(온보딩 우회 1줄 config만), PROMPT는 EXP-010 정본 byte-identical, thinking 파라미터 무지정(엔드포인트 기본값) — [Phase 0 기록](runs/phase0.md)
- 개입 0회 (기동 후 로그 열람만, 하네스 인프라 복구도 0건)

## 관찰

1. **단일 iteration 완주 + 변환 계층 제로 트러블슈팅.** 동일 하네스(Claude Code)에서 ccr 경유 EXP-012는 Phase 0에서 responses 전환·transformer 체인·usage 탭 구축이 필요했고 본 실행에서 스트림 스톨 1건이 있었으나, 직결 스택은 Phase 0 4항목이 조정 없이 한 번에 통과했고 본 실행도 무사고였다.
2. **usage 계측이 표준 경로로 회귀**: 직결에서는 Claude 세션 jsonl에 usage가 정상 기록되고(cache 필드 포함) context caching도 동작 — cache_read 2.13M은 캐시가 실제로 적중했음을 보여준다. ccr의 usage 유실 문제(EXP-012 Phase 0 ④)가 구조적으로 사라졌다.
3. **산출 구조**: TypeScript + Fastify + Prisma + SQLite, 커밋 4회(공식 hurl vendoring → 스캐폴드 → 전체 구현 → 완료 마킹). 공식 스위트를 스스로 vendoring해 자체 검증 후 `.ralph-done`을 신고했다.
4. wall-clock 15분 5초는 M축 Claude Code 스택(솔라 수십 분~미완주, ccr gpt-5.6-sol 58분) 중 최단이나, 모델·엔드포인트가 모두 다르므로 기록으로만 남긴다. n=1이므로 효율·프로파일 서사는 하지 않는다 — 판정은 완주 여부 단일.

## 한계·후속

- n=1 완주 판정 실험 — 재현성(완주율)·토큰 효율 비교는 n 확충 후속 실험 필요
- 하네스 고정(Claude Code) 비교에서 EXP-012와 모델이 달라(gpt-5.6-sol vs qwen3.8-max) "직결 vs ccr" 효과와 모델 효과가 교락 — 분리하려면 동일 모델 양 스택 실험 필요
- thinking 기본값 조건이라 qwen3.8-max의 effort 수준별 거동은 미측정 — 필요 시 `reasoning_effort` 변인 실험으로
- 출시 당일 모델의 서빙 품질이 안정화 이후와 다를 수 있음 — 시점 명기(2026-08-03)
