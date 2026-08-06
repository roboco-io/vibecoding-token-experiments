# EXP-019 Phase 0 기록 (2026-08-06)

- ① Codex×gpt-5.6-sol 한국어 스모크: `SMOKE-OK` 정확 출력, 4,526 tokens (1차 시도는 외부 중단 — 재시도 성공). 스모크 세션은 `codex-sessions-phase0`로 격리, 본 계측 제외
- ② claude-opus-4-8 한국어 스모크: `SMOKE-OK` 정확 출력
- ③ claude-opus-5 한국어 스모크: `SMOKE-OK` 정확 출력
- PROMPT 정본: EXP-017 한국어 정본 byte-identical (md5 `fa75275f335b1552ad1baedb630c522a`)
- measure v4 (EXP-016/017 12 run 무오검 이력 그대로), Codex config: EXP-011 사본 + 신규 app 디렉토리 trust 등록
- Opus 레인은 비격리(기본 ~/.claude) — EXP-009/010 EN 기준선과 동일 조건 (OAuth 제약, 설계 명기)
