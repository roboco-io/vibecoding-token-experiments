# ralph-loop 실행 기록

- 작업 리포: `~/Workspace/roboco-io/research/realworld-exp001-ralph` (빈 저장소, CLAUDE.md 없음)
- 모델: Claude Opus (`claude --model opus -p`)
- 실행 방식: headless Ralph loop — `ralph.sh`가 `PROMPT.md`를 골로 `claude -p --dangerously-skip-permissions`를 최대 15회 반복, 완료 마커 `.ralph-done` 생성 시 중단. 이터레이션당 새 프로세스(새 세션 로그)
- 시작 시각: 2026-07-20 09:00:34 (유효 실행)
- 종료 시각: 2026-07-20 09:14:29 (이터레이션 1회 만에 `.ralph-done` 생성, 소요 약 14분)

## 결과

- **완료 판정: 통과** — 공식 RealWorld API 테스트(Hurl, 공식 리포가 Postman/Newman에서 마이그레이션)를 실험자가 독립 재실행: 13파일 / 154요청 100% 통과 ([test-result.txt](test-result.txt)). 단일 명령 기동(`npm run start`) 확인.
- **토큰 집계** (`scripts/aggregate_tokens.py runs/ralph-loop/logs`):

| 항목 | 값 |
|------|-----|
| sessions | 1 |
| messages | 112 |
| input_tokens | 211 |
| output_tokens | 90,877 |
| cache_creation_input_tokens | 233,687 |
| cache_read_input_tokens | 8,426,223 |
| **billable (input+output+cache_creation)** | **324,775** |

- 작업 리포 커밋 4개 (scaffold → feat 전체 구현 → 테스트 벤더링 → .env 커밋)
- 세션 로그 슬러그: `~/.claude/projects/-Users-dohyunjung-Workspace-roboco-io-research-realworld-exp001-ralph/`

## 개입 기록

(무개입 원칙. 불가피한 개입 발생 시 시각·내용 기록)

## 특이사항

- **1차 실행 실패 (08:09:12~08:55:19)**: 셸 환경의 무효한 `ANTHROPIC_API_KEY`가 claude.ai 로그인보다 우선 적용되어 15회 이터레이션 전부 `401 API key is invalid`로 실패. 작업 산출물 0 (커밋 없음). 실패 세션 로그 15개는 측정에서 제외하고 격리함.
- **조치**: `ralph.sh`의 claude 호출을 `env -u ANTHROPIC_API_KEY claude ...`로 수정 후 09:00:34 재시작. 이 조치는 실험 개입이 아닌 인프라 수정임 (에이전트 작업 시작 전 발생).
