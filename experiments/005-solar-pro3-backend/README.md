# EXP-005: Claude Code × Upstage Solar Pro 3 백엔드 교체

> 사전 조사: [research.md](research.md) · 과제·프롬프트: EXP-002 재사용 ([tasks/realworld-backend](../../tasks/realworld-backend/), [prompts/ko.md](../002-korean-vs-english/prompts/ko.md))

## 가설

[M-01](../../hypotheses/catalog.md): Claude Code의 백엔드를 Upstage Solar Pro 3로 교체하면 동일 과제(RealWorld 백엔드)를 무개입 완주할 수 있고, 완주 시 총비용(USD)이 Claude Opus 대비 유의미하게 낮다.

근거·불확실성:

- **단가**: Solar Pro 3 자사 API $0.25/$0.25 per Mtok (입출력 대칭) — Opus 대비 명목 단가 수십 배 저렴. 비용 역전이 일어나려면 품질 저하로 인한 재작업·미완주가 그 격차를 다 갚아야 한다.
- **품질**: Solar Pro 3는 에이전틱 벤치마크(Tau2-all 72.3)·tool calling·한국어 강점을 내세우지만, Claude Code의 긴 자율 루프에서 검증된 바 없다. 완주 자체가 1차 관문.
- **구조적 핸디캡**: 프롬프트 캐싱 부재(매 턴 전체 컨텍스트 재과금), max output 8K(reasoning 포함), 컨텍스트 128K(Opus 200K 대비 컴팩션 빈발 예상) — 단가가 싸도 캐시 없는 재과금이 누적되면 격차가 좁혀진다.

**선행 사례 없음**: 조사 결과 Solar × Claude Code 공개 벤치마크는 전무 — 본 실험이 첫 공개 사례가 될 수 있다 ([research.md](research.md) §3).

## 연동 방식 (Phase 0에서 확정)

Upstage API는 OpenAI 호환 형식만 제공(Anthropic 호환 엔드포인트 없음) → 변환 계층이 필요하다. 공통 설정: `ANTHROPIC_API_KEY=""` 명시적 비움, `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`(beta 헤더 4xx 방지), `ANTHROPIC_SMALL_FAST_MODEL`은 `solar-mini`로 매핑. 후보 3개를 스모크 테스트로 비교해 1개 확정:

| 경로 | 구성 | 장점 | 단점 |
|------|------|------|------|
| A. claude-code-router | 로컬 프록시(:3456) + Upstage provider 설정, `ANTHROPIC_BASE_URL=http://127.0.0.1:3456` | 요청/응답 전문 로깅 가능(토큰 회계 검증), 커뮤니티 검증 많음 | 변환기 품질이 결과를 좌우 |
| B. OpenRouter Anthropic skin | `ANTHROPIC_BASE_URL=https://openrouter.ai/api` + `ANTHROPIC_MODEL=upstage/solar-pro-3` | 프록시 불필요, 가장 단순 | 단가 상이($0.15/$0.60), 변환 블랙박스, 중개 마진 |
| C. LiteLLM proxy | 로컬 LiteLLM `/anthropic` 엔드포인트 → Upstage | 토큰·비용 집계 내장 | 설정 복잡 |

기본 후보는 **A**(자사 API 단가로 비용 계산이 깔끔하고 로그 확보 가능). B는 A 실패 시 대안.

## Phase 0 — 파일럿 (go/no-go)

본 실험 전 30분 내외의 소형 과제(예: 파일 3개 수정 + 테스트 실행)로 다음을 확인한다. 하나라도 실패하면 해당 경로 탈락, 전 경로 탈락 시 실험 보류 판정:

1. tool calling 왕복: Read/Write/Edit/Bash 도구 호출이 형식 오류 없이 N턴 연속 동작 (Anthropic `tool_use` ↔ OpenAI function calling 변환 충실도 — 선행 보고에서 조용한 실패가 agentic 성능 저하로 오인되는 최대 리스크)
2. 토큰 회계: 세션 JSONL에 usage(input/output)가 기록되고 `scripts/aggregate_tokens.py`로 집계 가능한지 (cache 필드는 0/부재 예상 — 집계 스크립트 보정 필요 여부 확인)
3. max output 8K 제약: 긴 파일 Write가 잘리는지, Claude Code가 분할 재시도로 복구하는지
4. 컴팩션: 128K 컨텍스트에서 자동 컴팩션이 정상 동작하는지

## 조건

| 조건 | 설명 | 데이터 |
|------|------|--------|
| solar (신규, n=2) | Claude Code + Solar Pro 3 (Phase 0 확정 경로), EXP-002 ko.md 프롬프트, headless ralph 루프, 무개입 | `runs/solar-1/`, `runs/solar-2/` |
| opus 기준 (재사용, n=2) | EXP-002 ko-1(270,352)·ko-2(307,930) — 동일 프롬프트·워크플로, Opus + 캐싱 | EXP-002 runs |

## 통제 변수

- 프롬프트: EXP-002 ko.md 그대로 (Solar Pro 3의 한국어 강점 고려 시 KO 프롬프트가 불리하지 않음)
- 완료 판정: Hurl 13파일/154요청 100% (독립 재검증), headless, 무개입
- 중단 상한(사전 고정): run당 비용 $15 또는 wall-clock 8시간 초과 시 중단 → 미완주 판정
- Claude Code 버전·설정 고정, MCP/스킬 등 부가 컨텍스트는 EXP-002 당시와 동일하게 비활성

## 측정·판정

**1차 지표 — 토큰이 아니라 비용.** 토크나이저가 다르고(같은 텍스트의 토큰 수 자체가 다름) 캐싱 구조도 달라 billable 토큰의 직접 비교는 무의미하다:

| 지표 | solar | opus 기준 |
|------|-------|----------|
| 완주 여부 (Hurl 154 100%) | 측정 | 4/4 완주 |
| 총비용 USD | Σ(input+output) × $0.25/Mtok | billable × Opus 단가 (EXP-002 로그에서 재계산) |
| 이터레이션 수 / wall-clock | 측정 | EXP-002 기록 |
| 실패 모드 | tool call 오류율, 출력 잘림, 루프 이탈, 컴팩션 횟수 기록 | — |

**판정 기준** (사전 고정):

- 2/2 완주 + 평균 총비용이 opus 평균의 50% 미만 → M-01 **검증**
- 0/2 완주 → **기각** (품질이 관문을 못 넘음)
- 그 외(1/2 완주, 비용 역전 등) → **보류** + 실패 모드 분석

**주의 — 비교의 프레임**: 본 실험은 "토크나이저 효율 비교"가 아니라 **실전 스택 비교**다. Opus는 캐싱 포함, Solar는 캐싱 부재가 각자의 실제 운용 조건이므로 그대로 비교한다. 다만 보고서에 캐싱 부재가 비용에 기여한 몫을 분해해 명시한다(전 턴 재전송 input 누적량 추정).

## 리스크

| 리스크 | 대응 |
|--------|------|
| 변환 프록시 결함이 모델 품질로 오인됨 | Phase 0에서 경로 검증 + 실패 모드 기록 시 프록시 로그 대조 |
| max output 8K로 긴 파일 생성 실패 반복 | 파일럿에서 확인, 심하면 프롬프트에 "파일 분할 작성" 지침 추가 여부를 사전 결정(추가 시 opus 재실행 필요성 명시) |
| 세션 로그 usage 부정확 (프록시 경유) | 프록시 측 로그·Upstage Console 사용량 대시보드와 3중 대조 |
| Solar Pro 3 무료 프로모션 종료(2026-03) 후 단가 변동 | 실행 시점 단가를 report에 기록 |
