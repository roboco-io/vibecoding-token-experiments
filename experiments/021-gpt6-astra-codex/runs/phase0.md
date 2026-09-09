# EXP-021 Phase 0 — 기동 전 스모크

- 일시: 2026-09-10 (KST)
- 명령: `CODEX_HOME=~/ralph-exp021/codex-home codex exec --model gpt-6-astra -c model_reasoning_effort="medium" --sandbox read-only --skip-git-repo-check -C ~/ralph-exp021/smoke-tmp "Output exactly the string SMOKE-OK and nothing else."`
- 결과: **통과** — `SMOKE-OK` 정확 출력, tokens used 3,388. 모델 ID `gpt-6-astra` 유효 확인 (Codex CLI 0.153.4)
- 인증 경위: EXP-011 codex-home의 auth.json(2026-08-03 사본)은 ChatGPT OAuth 토큰 만료로 401 → 최신 `~/.codex/auth.json`(2026-09-07 갱신)으로 교체 후 통과
- **계측 주의**: 인증은 ChatGPT 플랜 OAuth(OPENAI_API_KEY 미설정) — API 종량 과금이 아니므로 설계서의 달러 추정(run당 ~$3)은 참고치로 강등. 과금 배제 판정(완주율 단일)에는 영향 없음. usage는 rollout 누계로 동일 계측
- 스모크 세션은 본 계측에서 제외 — 기동 전 `codex-home/sessions` 초기화 완료
