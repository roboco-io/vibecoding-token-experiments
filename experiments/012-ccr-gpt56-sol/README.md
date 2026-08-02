# EXP-012 설계: Claude Code × gpt-5.6-sol 백엔드(ccr) 리얼월드 백엔드 완주 검증

## 배경

EXP-011에서 gpt-5.6-sol은 Codex CLI 하네스로 iteration 1 완주를 기록했다. 본 실험은 **같은 모델을 Claude Code 하네스에 ccr(claude-code-router)로 연결**해 동일 과제를 수행, 모델 고정·하네스 변인의 효과를 분리한다(Solar 실험과 동일 스택). EXP-011과 쌍을 이뤄 "완주가 모델 특성인지 하네스 특성인지"의 첫 데이터 포인트가 된다.

## 가설

[M-08](../../hypotheses/catalog.md) — Claude Code 백엔드를 ccr로 gpt-5.6-sol에 연결하면(reasoning effort medium) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. (과금 배제 — 완주 단일 판정)

## 조건 (사전 고정)

- **모델**: OpenAI API `gpt-5.6-sol`, `reasoning_effort: "medium"` (EXP-011과 동일 고정), n=1
- **하네스**: EXP-010 driver.sh 원형(`claude -p` 호출) + ccr 라우터 경유. measure.sh·`.ralph-done` 게이트·iteration별 채점 로직 그대로
- **격리 (EXP-007/008 교훈)**: 전용 `CLAUDE_CONFIG_DIR` — 개인 훅·전역 CLAUDE.md·플러그인 배제. run 리포는 독립 빈 git 리포
- **프롬프트**: EXP-010 정본 byte-identical (EXP-011에서 diff 0 확인된 동일 파일)
- **상한**: 30 iteration
- **계측**: wall-clock, Claude 세션 jsonl usage(message.id dedup — EXP-007 교훈), git 커밋 수, iteration 수
- **판정 기준 (사전 등록)**: EXP-011과 동일 — 검증(30 iter 내 게이트 통과+독립 재검증 일치) / 기각(소진 미완주) / 보류(라우터·인증 등 모델 외적 장애로 루프 불성립)
- **선행 게이트 (통과)**: `OPENAI_API_KEY`로 `gpt-5.6-sol` chat/completions 호출 → HTTP 200, 정상 응답 (2026-08-03 실측)

## Phase 0 (실행 전 게이트)

1. ccr 라우터 기동 + 격리 CLAUDE_CONFIG_DIR에서 `claude -p` 스모크 1회 (모델 라우팅·effort medium 반영 확인)
2. PROMPT diff 0 재확인
3. measure.sh 경로 치환본 동작 확인, 포트 8000 비점유
4. 세션 jsonl usage 파싱 스모크 (dedup 로직 검증)

## 리스크

- ccr 변환 계층 결함 가능성 (EXP-007에서 멀티 델타 버그 전례) — 스모크와 로그 부검으로 라우터 귀책·모델 귀책 구분
- GPT 계열은 Claude 도구 스키마와 궁합이 다를 수 있음 — tool call 실패가 반복되면 '보류' 사유로 기록
- n=1 완주 판정 — 효율·프로파일 서사 금지 (EXP-011과 동일)

## 후속

- EXP-011과 쌍으로 하네스 효과 정성 비교 (판정 서사는 완주 여부까지만)
- 완주 시 도구 간 효율 비교는 계측 표준화(ROADMAP Phase 3) 이후 n 확충 실험으로
