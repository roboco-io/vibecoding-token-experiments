# EXP-013 설계: Claude Code × qwen3.8-max 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증

## 배경

EXP-012에서 Claude Code는 ccr(claude-code-router) 변환 계층을 거쳐 gpt-5.6-sol로 iteration 11 완주를 기록했다(스트림 스톨 1건 하네스 복구). 본 실험은 **변환 계층 없이** DashScope의 Anthropic 호환 엔드포인트로 qwen3.8-max(2026-08-03 출시)를 Claude Code에 직결한다. Claude Code 하네스에 비-Anthropic 모델을 연결하는 두 번째 스택(기존 ccr → 신규 직결)이자, 직결 방식의 첫 데이터 포인트다.

## 가설

[M-09](../../hypotheses/catalog.md) — Claude Code를 DashScope Anthropic 호환 엔드포인트로 qwen3.8-max에 직결하면(thinking 기본값), 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. (과금 배제 — 완주 단일 판정)

## 조건 (사전 고정)

- **모델**: `qwen3.8-max`, thinking 기본값 무지정 (엔드포인트 기본 동작 그대로 — 조건에 '기본값'으로 기록), n=1
- **연결**: ccr 없이 env 직결 — `ANTHROPIC_BASE_URL=https://dashscope-intl.aliyuncs.com/apps/anthropic`, `ANTHROPIC_AUTH_TOKEN=$QWEN_API_KEY`, `ANTHROPIC_MODEL=qwen3.8-max`, haiku 대체 모델(`ANTHROPIC_DEFAULT_HAIKU_MODEL`)도 동일 지정. `/v1/models` 미제공이므로 모델 수동 지정 필수, URL 끝에 `/v1`을 붙이면 404
- **하네스**: EXP-010 driver.sh 원형(`claude -p` 호출) + measure.sh·`.ralph-done` 게이트·iteration별 채점 로직 그대로
- **격리 (EXP-007/008 교훈)**: 전용 `CLAUDE_CONFIG_DIR` — 개인 훅·전역 CLAUDE.md·플러그인 배제, `hasCompletedOnboarding` 우회. run 리포는 독립 빈 git 리포
- **프롬프트**: EXP-010 정본 byte-identical (EXP-011/012에서 diff 0 확인된 동일 파일)
- **상한**: 30 iteration
- **계측**: wall-clock, Claude 세션 jsonl usage(message.id dedup — EXP-007 교훈), git 커밋 수, iteration 수
- **판정 기준 (사전 등록)**: EXP-012와 동일 — 검증(30 iter 내 게이트 통과+독립 재검증 일치) / 기각(소진 미완주) / 보류(엔드포인트·인증 등 모델 외적 장애로 루프 불성립)
- **선행 게이트 (통과)**: `QWEN_API_KEY`로 intl 엔드포인트 `/v1/messages` 호출 → HTTP 200, thinking 블록 기본 활성, usage 필드 Claude 스키마 호환(`cache_creation_input_tokens` 등) 확인 (2026-08-03 실측. beijing 엔드포인트는 미시도 — intl에서 즉시 200)

## Phase 0 (실행 전 게이트)

1. 격리 CLAUDE_CONFIG_DIR에서 env 직결로 `claude -p` 스모크 1회 (모델 라우팅·thinking 기본값 반영·tool call 왕복 확인)
2. PROMPT diff 0 재확인
3. measure.sh 경로 치환본 동작 확인, 포트 8000 비점유
4. 세션 jsonl usage 파싱 스모크 (dedup 로직이 qwen 응답 usage 스키마에서 동작하는지 검증)

## 리스크

- 출시 당일 모델 — Model Studio Anthropic 호환 문서에 qwen3.7-max까지만 등재(갱신 지연 추정). 스모크는 200이나, 스트리밍·tool call 등 미검증 경로에서 미지원 동작 가능 → 모델 외적 장애로 판별되면 '보류' 처리, ccr 폴백 여부는 별도 결정
- GPT 계열과 마찬가지로 Claude 도구 스키마와 궁합이 다를 수 있음 — tool call 실패 반복 시 '보류' 사유로 기록
- thinking 기본값이 크게 잡힐 수 있음(문서상 기본 budget 131K) — 완주 판정에는 영향 없으나 usage 서사 금지 원칙 유지
- n=1 완주 판정 — 효율·프로파일 서사 금지 (EXP-011/012와 동일)

## 후속

- EXP-012(ccr)와 정성 비교: 같은 하네스에서 변환 계층 유무가 루프 안정성에 주는 영향 (판정 서사는 완주 여부까지만)
- 완주 시 도구·모델 간 효율 비교는 계측 표준화(ROADMAP Phase 3) 이후 n 확충 실험으로
