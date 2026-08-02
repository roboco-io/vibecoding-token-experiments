# EXP-011 설계: Codex CLI × gpt-5.6-sol 리얼월드 백엔드 완주 검증

## 배경

M축은 지금까지 Claude Code 하네스 안에서 백엔드 모델만 교체해왔다(Solar Pro 3, Solar Open 2, Opus 4.8/5). 본 실험은 ROADMAP Phase 3의 "타 도구 비교" 첫 실험으로, **하네스 자체를 Codex CLI로 바꾸고** OpenAI `gpt-5.6-sol`이 동일 과제(RealWorld 백엔드)를 랄프 루프로 무개입 완주할 수 있는지 검증한다. 후속 EXP-012는 같은 모델을 Claude Code 백엔드로 연결해(ccr) 하네스 효과를 분리한다.

## 가설

[M-07](../../hypotheses/catalog.md) — Codex CLI(`codex exec`) 하네스에서 gpt-5.6-sol(reasoning effort medium)은 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. (과금 비교 배제 — 완주 여부 단일 판정, M-04 방식)

## 조건 (사전 고정)

- **모델**: `gpt-5.6-sol`, `model_reasoning_effort = "medium"` (Codex 기본값 — 개인 config의 low는 미사용), n=1
- **하네스**: EXP-010 driver.sh 변형 — `claude -p` 호출부를 `codex exec --model gpt-5.6-sol --sandbox danger-full-access` 비대화 실행으로 교체. measure.sh(Hurl 채점)·`.ralph-done` 게이트·iteration별 채점 로직은 그대로
- **격리 (EXP-007 교훈)**: 전용 `CODEX_HOME`에 최소 config.toml만 배치 — 개인 `~/.codex`의 AGENTS.md·MCP 서버·ambient 기능 배제. run 리포는 독립 빈 git 리포
- **프롬프트**: EXP-009/010 영문 정본에서 Claude 특화 문구(도구명 등)만 도구 중립화한 변형판. diff를 설계 산출물로 기록
- **상한**: 30 iteration (M-04 전례)
- **계측**: wall-clock, Codex 세션 jsonl의 token usage(입/출력·캐시, 중복 이벤트 dedup), git 커밋 수, iteration 수, 도구 호출 분포(로그에서 추출 가능한 범위)
- **판정 기준 (사전 등록)**:
  - **검증**: 30 iter 안에 게이트 통과(Hurl 13/13·154/154) + 독립 재검증 일치
  - **기각**: 30 iter 소진 시점에 미완주
  - **보류**: 하네스·인증 등 모델 외적 요인으로 루프 자체가 성립하지 않는 경우
- 비용(USD)·토큰 효율 비교는 판정에 미사용 — 완주 확인 후 후속 실험에서 n 확충·비교

## Phase 0 (실행 전 게이트)

1. 격리 CODEX_HOME 스모크: `codex exec` 1회 응답 + effort medium 반영 확인
2. 프롬프트 중립화 diff 검토 (과제 내용 불변, 도구 참조만 변경)
3. measure.sh 경로 치환본 동작 확인, 포트 8000 비점유
4. 세션 jsonl 위치·usage 필드 파싱 검증 (1회 스모크 세션으로)

## 리스크

- Codex CLI의 비대화 루프 거동(자율성·중단 조건)이 Claude Code와 달라 랄프 프로토콜이 그대로 성립하지 않을 수 있음 — Phase 0에서 1 iteration 시험으로 확인
- 세션 usage 계측 방식이 ccusage 계열과 달라 토큰 수치의 타 실험 직접 비교는 참고치로만 취급
- n=1이므로 완주/미완주 판정만 유효, 효율·프로파일 서사는 금지

## 후속

- EXP-012 (M-08): 동일 모델을 ccr로 Claude Code 백엔드에 연결 — 하네스 효과 분리. 선행 게이트: OpenAI API 키로 `gpt-5.6-sol` 호출 가능 여부 스모크 (불가 시 보류)
