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
- 중단·재개 이력: 외부 kill 2회(07-26 18:23, 07-27 00:37 — 모두 `[Request interrupted by user]` 신호, API 오류 0건) → 상태 보존 재기동으로 누적 상한 15 iter 유지. 마지막 2 iter는 시스템 슬립 후 07-27 06:24에 실행

## 종료

- 종료: 2026-07-27 06:28:54 — 누적 15 iteration 소진 (완주 13 + kill로 유실 2), `.ralph-done` 미생성
- 실가동 wall-clock: 약 1시간 56분 (중단 공백 제외: 33m + 78m + 5m)
- 결과: **미완주** — 독립 검증(공식 스위트 재실행): **3/13 파일 통과 (23.1%), 94/154 요청 실행**. 통과: auth(20요청)·errors_articles(20)·pagination(7). 서버 단일 명령 기동은 충족
- 테스트 정본성: 벤더링된 13개 hurl + 실행 스크립트 전부 공식 realworld-apps/realworld `specs/api/hurl`과 byte-identical
- git 커밋: 0회 (지시 위반 지속)
- usage 집계: 1,481 요청, input 67.0M / output 1.30M tokens, cache 필드 전부 0 (직결 경로는 캐시 미보고 — 실제 캐싱 여부 불명)
