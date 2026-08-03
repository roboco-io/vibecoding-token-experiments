# EXP-014 설계: Claude Code × kimi-k3 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증

## 배경

EXP-013에서 qwen3.8-max는 DashScope Anthropic 호환 엔드포인트 직결로 iteration 1 완주를 기록했고, 직결 스택이 ccr 대비 트러블슈팅 0건임을 확인했다. 본 실험은 **동일한 직결 방법**을 Moonshot AI kimi-k3(2026-07-16 출시)에 적용한다. 직결 스택의 두 번째 데이터 포인트로, 방법 재사용성(제공자만 교체)도 함께 확인된다.

## 가설

[M-10](../../hypotheses/catalog.md) — Claude Code를 Moonshot Anthropic 호환 엔드포인트로 kimi-k3에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. (과금 배제 — 완주 단일 판정)

## 조건 (사전 고정)

- **모델**: `kimi-k3`, thinking 기본값 무지정(끄기 불가·기본 ON — 조건에 '기본값'으로 기록), n=1
- **연결**: ccr 없이 env 직결 — `ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic`, `ANTHROPIC_AUTH_TOKEN=$KIMI_API_KEY`, `ANTHROPIC_MODEL=kimi-k3`, SMALL_FAST·DEFAULT_HAIKU 동일 지정, 잔존 `ANTHROPIC_API_KEY`는 env -u로 제거(충돌 주의)
- **하네스**: EXP-013 driver.sh 원형(`claude -p`) + measure.sh·`.ralph-done` 게이트·iteration별 채점 로직 그대로 (BASE·모델 env만 치환)
- **격리 (EXP-007/008 교훈)**: 전용 `CLAUDE_CONFIG_DIR` — 개인 훅·전역 CLAUDE.md·플러그인 배제, `hasCompletedOnboarding` 우회. run 리포는 독립 빈 git 리포
- **프롬프트**: EXP-010 정본 byte-identical
- **상한**: 30 iteration
- **계측**: wall-clock, Claude 세션 jsonl usage(message.id dedup), git 커밋 수, iteration 수
- **판정 기준 (사전 등록)**: EXP-013과 동일 — 검증(30 iter 내 게이트 통과+독립 재검증 일치) / 기각(소진 미완주) / 보류(엔드포인트·인증·rate limit 등 모델 외적 장애로 루프 불성립)
- **선행 게이트 (통과)**: `KIMI_API_KEY`로 국제판 `/anthropic/v1/messages` 호출 → HTTP 200, thinking 블록 기본 활성 (2026-08-04 실측)

## Phase 0 (실행 전 게이트)

1. 격리 CLAUDE_CONFIG_DIR에서 env 직결로 `claude -p` 스모크 1회 (모델 라우팅·tool call 왕복·rate limit 거동 확인)
2. PROMPT diff 0 재확인
3. measure.sh 경로 치환본 동작 확인, 포트 8000 비점유
4. 세션 jsonl usage 파싱 스모크 (message.id dedup 동작 검증)

## 리스크

- **rate limit**: Moonshot Tier 0은 동시 1요청·3 RPM으로 에이전트 루프 불성립 가능 — Phase 0 스모크·본 실행 초기 429 반복 시 모델 외적 장애로 '보류' 처리
- Anthropic 호환 경로의 스트리밍·tool call 미검증 영역 — tool call 실패 반복 시 '보류' 사유 기록
- thinking 끄기 불가·기본 effort 높음(문서상 max) 가능 — 완주 판정에는 영향 없으나 usage 서사 금지 원칙 유지
- n=1 완주 판정 — 효율·프로파일 서사 금지

## 후속

- EXP-013과 쌍으로 직결 스택 방법 재사용성 정성 확인 (판정 서사는 완주 여부까지만)
- 완주 시 모델 간 효율 비교는 계측 표준화 이후 n 확충 실험으로
