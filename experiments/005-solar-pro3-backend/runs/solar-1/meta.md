# solar-1 run meta

- 시작: 2026-07-26 10:47:43
- 작업 리포: ~/Workspace/roboco-io/research/realworld-exp005-solar-1
- 경로: claude-code-router 1.0.73 (:3456) → Upstage API (OpenAI 호환)
- 모델: solar-pro3 (해석: solar-pro3-260323) / small-fast: solar-mini
- transformer: solar-fix(reasoning→reasoning_effort=high) + streamoptions(SSE usage 전달)
- 단가(실행 시점): $0.25/$0.25 per Mtok (자사 API, 입출력 대칭). 캐시 입력 할인율 미공표 — 보수적으로 전액 계산
- 환경: CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1, env -u ANTHROPIC_API_KEY, headless -p, 무개입
- 중단 상한: 15 iterations / $15 / 8h
- Phase 0 파일럿: tool calling·usage 회계 통과 (Upstage 자동 캐싱 → cache_read 매핑 확인)

## 종료
- 중단: 2026-07-26 12:45 (사용자 결정, iteration 6 진행 중 / 5 완료)
- 결과: 미완주 — 판정·분석은 [report.md](../../report.md)
