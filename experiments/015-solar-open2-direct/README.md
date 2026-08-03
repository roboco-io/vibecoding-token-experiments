# EXP-015 설계: Claude Code × solar-open2 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증

## 배경

EXP-013(qwen3.8-max)·EXP-014(kimi-k3)에서 직결 스택이 제공자 독립적으로 재사용됨을 확인했다. 본 실험은 같은 템플릿을 **Upstage solar-open2**에 적용한다. solar-open2는 EXP-008에서 ccr 스택으로 iteration 10 완주(약 173분)를 기록한 모델이라, 완주 시 **동일 모델의 양 스택(ccr vs 직결) 데이터가 처음 성립**한다 — 단 EXP-008과는 프롬프트(정본 이전 버전)·시점(약 열흘)·상류 서빙이 달라 정량 비교가 아닌 정성 참조로 한정한다(사전 등록).

## 가설

[M-11](../../hypotheses/catalog.md) — Claude Code를 Upstage Anthropic 호환 엔드포인트로 solar-open2에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. (과금 배제 — 완주 단일 판정)

## 조건 (사전 고정)

- **모델**: `solar-open2`, thinking 기본값 무지정, n=1
- **연결**: ccr 없이 env 직결 — `ANTHROPIC_BASE_URL=https://api.upstage.ai`, `ANTHROPIC_AUTH_TOKEN=$UPSTAGE_API_KEY`, `ANTHROPIC_MODEL=solar-open2`, SMALL_FAST·DEFAULT_HAIKU 동일 지정. **주의: Upstage Anthropic 경로는 `x-api-key` 미지원·`Authorization: Bearer` 필수** — `ANTHROPIC_AUTH_TOKEN`이 Bearer 방식이므로 하네스는 무수정 동작(선행 게이트 실측)
- **하네스**: EXP-013/014 driver.sh 원형 (BASE·RUN명·모델 env 3요소만 치환). Upstage 공식 스크립트가 권장하는 추가 env(`CLAUDE_CODE_MAX_OUTPUT_TOKENS` 등)는 **적용하지 않음** — EXP-013/014와 방법 동일성 우선(사전 등록, 스톨 발생 시 리스크 절에 따름)
- **격리**: 전용 `CLAUDE_CONFIG_DIR`, `hasCompletedOnboarding` 우회, 독립 빈 git 리포
- **프롬프트**: EXP-010 정본 byte-identical (EXP-008과는 프롬프트가 다름 — 비교 한정 사유)
- **상한**: 30 iteration
- **계측**: wall-clock, 세션 jsonl usage(message.id dedup), git 커밋 수, iteration 수
- **판정 기준 (사전 등록)**: 검증(30 iter 내 게이트 통과+독립 재검증 일치) / 기각(소진 미완주) / 보류(엔드포인트·인증 등 모델 외적 장애로 루프 불성립)
- **선행 게이트 (통과)**: `UPSTAGE_API_KEY`로 `https://api.upstage.ai/v1/messages` Bearer 호출 → HTTP 200, thinking 블록 기본 활성 (2026-08-04 실측. `x-api-key` 헤더는 401 — 인증 방식 차이로 판별)

## Phase 0 (실행 전 게이트)

1. 격리 CLAUDE_CONFIG_DIR에서 env 직결로 `claude -p` 스모크 1회 (모델 라우팅·tool call 왕복 확인)
2. PROMPT diff 0 재확인 (vs ~/ralph-exp010/PROMPT.md)
3. measure.sh 경로 치환본 동작 확인, 포트 8000 비점유
4. 세션 jsonl usage 파싱 스모크

## 리스크

- solar-open2는 EXP-006/007에서 thinking 폭주·선언-실행 탈락 등 모델 행동 결함 전례 — 완주 실패 시 로그 부검으로 모델 귀책·스택 귀책 구분 (EXP-007 원칙)
- EXP-008 완주가 173분이었으므로 직결에서도 장시간 run 가능 — 상한 30 iter 유지, 중도 개입 금지
- 스트림 스톨 등 인프라 장애 시 하네스 수준 복구만 허용·기록 (EXP-012 선례). 반복 시 Upstage 권장 `CLAUDE_STREAM_IDLE_TIMEOUT_MS` 적용을 별도 run으로 검토(본 run 조건은 불변)
- n=1 완주 판정 — 효율·프로파일 서사 금지

## 후속

- 완주 시: EXP-008(ccr)과 동일 모델 양 스택 정성 비교 (프롬프트·시점 교락 명시 전제)
- EXP-013/014와 함께 직결 템플릿 세 번째 데이터 포인트 — 제공자 3사(DashScope·Moonshot·Upstage) 이식성
