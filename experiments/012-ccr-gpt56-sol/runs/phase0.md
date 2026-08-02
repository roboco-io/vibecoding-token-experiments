# EXP-012 Phase 0 통과 기록 (2026-08-03 08:48–08:52 KST)

하네스 베이스 `~/ralph-exp012/`, ccr 1.0.73, 기존 Solar용 config는 `config.json.bak-exp012`로 백업 후 교체 (실험 종료 시 복원 예정).

## 선행 게이트 (설계 등록)

- `OPENAI_API_KEY` → `gpt-5.6-sol` chat/completions 직접 호출: HTTP 200, "OK" 응답

## ① ccr 라우팅 + 격리 스모크

- **트러블슈팅 (기록)**: chat/completions 경유 첫 파일럿은 provider 400 —
  `"Function tools with reasoning_effort are not supported for gpt-5.6-sol in /v1/chat/completions"`.
  → provider를 `https://api.openai.com/v1/responses` + 내장 `openai-responses` transformer로 전환 (EXP-011의 Codex도 responses API 사용이라 조건 정합).
  → 이후 `streamoptions`는 responses에서 `Unknown parameter: stream_options.include_usage` 400 → 체인에서 제외.
- 최종 체인: `["openai-responses", "gpt56-fix"]`. `gpt56-fix`가 `reasoning={effort:"medium"}` 고정·temperature 제거 — ccr 로그 final request에 `"reasoning":{"effort":"medium"}` 실림 실측.
- Anthropic 형식 왕복(200)·thinking 왕복(400 없음)·function tool 왕복(tool_use 반환) 모두 통과.
- 도구 사용 파일럿(`claude -p`, 격리 `CLAUDE_CONFIG_DIR`): hello.txt 생성 + git 커밋 + "DONE" — 완주.

## ② 프롬프트 diff

- `diff ~/ralph-exp010/PROMPT.md ~/ralph-exp012/PROMPT.md` → **diff 0 (byte-identical)**

## ③ measure.sh 치환본·포트

- EXP-010판 BASE만 치환, 빈 리포 → `0,0`. 포트 8000 비점유. hurl 13파일.

## ④ usage 계측

- **한계 발견**: responses 스트리밍 경유 시 Claude 세션 jsonl usage가 전부 0 (ccr 변환에서 usage 유실, `streamoptions` 우회 불가).
- **대안 확립**: `gpt56-fix`에 usage 탭 추가 — provider SSE의 `response.completed` 이벤트에서 usage를 추출해 `~/ralph-exp012/usage-tap.jsonl`에 기록 (스트림 무변조, 요청 단위·response.id dedup).
- 스모크 실측: `1,15744,0,5,0,15749` (requests,input,cached,output,reasoning,total). Phase 0 탭은 `usage-tap-phase0.jsonl`로 분리, 본 실행은 새 파일로 집계.

## 기타

- driver.sh: EXP-010 루프 + EXP-008 격리 env 이식, `bash -n` 통과. 라우터 다운 시 자동 재기동(하네스 인프라 복구, 로그 기록 — 모델 개입 아님).
