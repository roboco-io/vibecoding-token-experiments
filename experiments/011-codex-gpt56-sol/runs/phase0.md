# EXP-011 Phase 0 통과 기록 (2026-08-03 07:41 KST)

설계 README의 실행 전 게이트 4항목 실측 결과. 하네스 베이스는 `~/ralph-exp011/`.

## ① 격리 CODEX_HOME 스모크

- `CODEX_HOME=~/ralph-exp011/codex-home` (내용물: `auth.json` 사본 + 2줄 `config.toml`만 — 개인 `~/.codex`의 AGENTS.md·MCP·ambient 기능 배제)
- `codex exec --skip-git-repo-check --sandbox read-only "Reply with exactly: OK"` → 응답 `OK`, tokens used 3,285
- 세션 rollout jsonl 메타 실측: `"model":"gpt-5.6-sol"`, `"reasoning_effort":"medium"` — 개인 config의 low가 아닌 medium 반영 확인
- Codex CLI 0.144.0, 플래그 교정 불필요 (계획안 그대로 동작)

## ② 프롬프트 diff

- `diff ~/ralph-exp010/PROMPT.md ~/ralph-exp011/PROMPT.md` → **diff 0 (byte-identical)**
- 설계 시점에 "도구 중립화 변형" 가능성을 뒀으나 정본에 Claude 특화 문구가 없어 무수정 재사용. PROMPT 내 "Do not modify PROMPT.md or ralph.sh" 문구는 무해하여 유지 (EXP-011은 ralph.sh 사본을 리포에 두지 않음)

## ③ measure.sh 치환본·포트

- EXP-010판에서 `BASE`만 `ralph-exp011`로 치환 (채점 로직 무변경, grep으로 잔존 exp010 참조 없음 확인)
- 빈 리포 실행 → `0,0` 정상
- `lsof -nP -iTCP:8000 -sTCP:LISTEN` → 비점유
- `harness-hurl/*.hurl` 13개 확인

## ④ usage 계측 검증

- rollout jsonl의 `token_count` 이벤트 스키마 실측: `info.total_token_usage{input_tokens, cached_input_tokens, output_tokens, reasoning_output_tokens, total_tokens}` — 세션 누계라 dedup 불필요
- `parse_usage.py` 스모크 세션 파싱: `13264,9984,5,13269` — CSV 출력 정상
- 스모크 세션(rollout-2026-08-03T07-41-02-*)은 본 실행 집계에서 제외 예정

## 추가 검증 (계획 Task 4)

- driver.sh 스텁 테스트: 가짜 `codex`(echo)·가짜 measure(`0,0`)로 MAX_ITER=2 루프 실행 → metrics 2행·`done-sol-1` 생성·호출 2회 — 루프·게이트·CSV 로직 정상, API 미호출
