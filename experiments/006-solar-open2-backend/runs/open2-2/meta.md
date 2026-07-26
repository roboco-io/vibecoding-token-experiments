# open2-2 run meta

- 시작: 2026-07-26 17시경 (ralph-run.log 1행이 정본)
- 작업 리포: ~/Workspace/roboco-io/research/realworld-exp006-open2-2
- 경로: **공식 직결** — `ANTHROPIC_BASE_URL=https://api.upstage.ai` (Anthropic 호환 네이티브, 변환 프록시 없음). 공식 claude-upstage.sh의 `set_claude_env`를 그대로 재현
- 모델: solar-open2 (모든 모델 슬롯 매핑: MODEL/SMALL_FAST/HAIKU/SONNET/OPUS)
- 한도 정합: `CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144` (서빙 256K), `CLAUDE_CODE_MAX_OUTPUT_TOKENS=131072` (출력 128K)
- 단가(실행 시점): 미공개 (베타) — 콘솔 과금이 정본
- 환경: env -u ANTHROPIC_API_KEY, headless -p, 무개입. CCR·CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS 미사용(공식 스크립트 기준)
- 중단 상한: 15 iterations / $15 / 8h (EXP-005와 동일)
- PROMPT.md: EXP-005 solar-1과 byte-identical (diff 검증)
- 직결 스모크: Bash 도구 사용 왕복 통과 (긴 절대 경로 무결 확인)
