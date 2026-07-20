# ralph-loop 실행 기록

- 작업 리포: `~/Workspace/roboco-io/research/realworld-exp001-ralph` (빈 저장소, CLAUDE.md 없음)
- 모델: Claude Opus (`claude --model opus -p`)
- 실행 방식: headless Ralph loop — `ralph.sh`가 `PROMPT.md`를 골로 `claude -p --dangerously-skip-permissions`를 최대 15회 반복, 완료 마커 `.ralph-done` 생성 시 중단. 이터레이션당 새 프로세스(새 세션 로그)
- 시작 시각: 2026-07-20 09:00:34 (유효 실행)
- 종료 시각: (완료 시 기록)
- 세션 로그 슬러그: `~/.claude/projects/-Users-dohyunjung-Workspace-roboco-io-research-realworld-exp001-ralph/`

## 개입 기록

(무개입 원칙. 불가피한 개입 발생 시 시각·내용 기록)

## 특이사항

- **1차 실행 실패 (08:09:12~08:55:19)**: 셸 환경의 무효한 `ANTHROPIC_API_KEY`가 claude.ai 로그인보다 우선 적용되어 15회 이터레이션 전부 `401 API key is invalid`로 실패. 작업 산출물 0 (커밋 없음). 실패 세션 로그 15개는 측정에서 제외하고 격리함.
- **조치**: `ralph.sh`의 claude 호출을 `env -u ANTHROPIC_API_KEY claude ...`로 수정 후 09:00:34 재시작. 이 조치는 실험 개입이 아닌 인프라 수정임 (에이전트 작업 시작 전 발생).
