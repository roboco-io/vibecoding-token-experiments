# EXP-012 결과 보고: Claude Code × gpt-5.6-sol 백엔드(ccr) 리얼월드 백엔드 완주 검증

- 실험일: 2026-08-03 (08:53–09:52 KST)
- 가설: [M-08](../../hypotheses/catalog.md) — Claude Code 백엔드를 ccr로 gpt-5.6-sol에 연결하면(reasoning effort medium) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다.
- **판정: 검증** — **iteration 11/30에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, 총 58분·커밋 11회). 단 iteration 2에서 스트림 스톨 1건에 하네스 수준 개입(프로세스 종료로 iteration 경계 복구, 모델 산출물 불개입)이 있었다 — 아래 프로토콜 이슈 참조.

## 결과

| run | 완주 | wall-clock | API 요청 | input (비캐시) | cache read | output (reasoning) | git 커밋 |
|-----|------|-----------|----------|----------------|------------|--------------------|----------|
| sol-1 | iter 11/30 | 58.2분 | 532 | 555.6K | 11.11M | 77.1K (22.2K) | 11 |

- 게이트 이력: hurl 통과 파일 0→0→0→0→0→3→4→4→9→12→**13** — EXP-008(solar-open2, iter 10 완주)과 유사한 점진 수렴 곡선
- claim 1회(iter 11), 게이트 기각 0, 허위 신고 0. 독립 재검증 2회 모두 `13,154`
- usage는 ccr 탭(provider `response.completed` 이벤트, response.id dedup) 집계 — Claude 세션 jsonl은 responses 스트리밍 경유 시 전부 0이라 사용 불가 ([phase0.md](runs/phase0.md) ④)

## 조건 준수 확인

- 격리 `CLAUDE_CONFIG_DIR`, PROMPT는 EXP-010 정본 byte-identical, `reasoning={effort:"medium"}` 최종 요청 실림 실측 — [Phase 0 기록](runs/phase0.md)
- 라우팅: ccr 1.0.73, OpenAI **responses API** 경유 (chat/completions는 function tools + reasoning_effort 조합 400 거부 — EXP-011의 Codex도 responses 사용이라 조건 정합)

## 관찰

1. **동일 모델·동일 과제에서 하네스에 따라 작업 궤적이 완전히 달랐다.** Codex CLI(EXP-011)는 iteration 1 단일 세션 완주(5분 46초, 단일 파일 436줄, 커밋 3회)였으나, Claude Code 하네스에서는 iteration당 "한 단위 작업"만 수행하고 종료하는 소형 iteration 패턴(각 2~6분)으로 11회에 걸쳐 수렴했다. 프롬프트의 "pick the single most important remaining piece of work and do it"를 Codex는 "완주까지"로, Claude Code 하네스의 gpt-5.6-sol은 문자 그대로 "한 조각"으로 해석했다.
2. **산출 구조도 하네스에 따라 갈렸다**: 모듈형 11개 TS 파일(routes/·lib/·plugins) + 점진 커밋 11회 (auth→CRUD→comments→favorites→feed→tags→테스트 vendoring→정합 수정 3회→완료 마킹) — Codex 경로의 단일 파일·3커밋과 대조적.
3. **완주 신뢰성**: 조기 claim이 한 번도 없었고(진행 중 iteration은 모두 `.ralph-done` 미생성), 최초 claim이 곧 게이트 통과였다.
4. n=1이므로 효율·프로파일 서사는 하지 않는다. 토큰 수치는 계측 방식(ccr 탭 vs Codex rollout vs ccusage)이 서로 달라 참고치다.

## 프로토콜 이슈

1. **iteration 2 스트림 스톨 (하네스 인프라 장애 1건)**: 08:58:25 요청이 in-flight로 21분 무통신(연결은 모두 ESTABLISHED, claude/ccr 양쪽 10분 타임아웃 미발화). 09:19 프로세스 종료로 iteration 경계 복구 — 산출물·프롬프트 불개입, driver.log에 사건 기록. 이후 iteration 3~11은 스톨 카운터 감시 하에 무정지 진행(재발 0). 원인은 provider 스트림 정지로 추정되나 ccr 변환 계층 가능성 배제 못함. 완주 판정에는 영향 없다고 보나, 무개입 조항의 각주로 남긴다.
2. Phase 0에서 chat/completions 400(function tools+reasoning_effort 미지원)·`stream_options` 미지원을 발견해 본 실행 전에 responses API 전환·usage 탭으로 해결 — 실행 중 이슈 아님.

## 한계·후속

- n=1 완주 판정. 스톨 재현성·완주율은 n 확충 필요
- EXP-011과 쌍 관찰: **완주는 모델 특성(gpt-5.6-sol 2/2), 작업 궤적·산출 구조는 하네스 특성**이라는 가설이 형성됨 — 검증하려면 각 n≥3 교차 실험 필요
- 도구 간 토큰 효율 비교는 계측 표준화 이후 (ROADMAP Phase 3)
