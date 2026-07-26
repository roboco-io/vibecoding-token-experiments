# open2-1 run meta

- 시작: 2026-07-26 16:20대 (ralph-run.log 1행이 정본)
- 작업 리포: ~/Workspace/roboco-io/research/realworld-exp006-open2-1
- 경로: claude-code-router 1.0.73 (:3456) → Upstage API (OpenAI 호환)
- 모델: solar-open2 / small-fast: solar-mini
- transformer: open2-split(멀티 tool_calls 델타 분리) + solar-fix(reasoning→reasoning_effort=high, solar-open2 포함하도록 확장) + streamoptions
- 단가(실행 시점): **미공개** — 공식 가격 페이지에 solar-open2 항목 없음 (베타/Early Access, API 1개월 무료 프로모션 존재). 콘솔 과금이 정본. 참고: solar-pro3 현행 단가 $0.15/$0.60, 캐시 입력 $0.015 (90% 할인)
- 모델 스펙: 250B-A15B MoE 오픈웨이트 (Upstage Solar License), 모델 컨텍스트 1M / **API 서빙 256K**, max output 128K, reasoning_effort 지원 (공식 스크립트 기준 — 본 run은 CCR 경유라 Claude Code 기본 가정 200K·32K 예약 사용)
- 환경: CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1, env -u ANTHROPIC_API_KEY, headless -p, 무개입
- 중단 상한: 15 iterations / $15 / 8h (EXP-005와 동일)
- PROMPT.md: EXP-005 solar-1과 byte-identical (diff 검증)
- Phase 0 파일럿: open2-split 적용 전 0/2 실패(tool call 인자 앞부분 유실), 적용 후 1/1 완주
