# open2-3 run meta (EXP-008)

- 실행: 2026-07-27 08:25:07 – 11:18:30 KST (wall-clock 약 2시간 53분, 무중단·무개입)
- 하네스: `~/ralph-exp008/` — ralph.sh(게이트·계측 내장, 본 디렉토리에 사본), measure.sh v3(포트 자동 탐지), harness-hurl(공식 13파일 byte-identical)
- 격리: `CLAUDE_CONFIG_DIR=~/ralph-exp008/claude-config` (superpowers 훅·글로벌 CLAUDE.md·플러그인·MCP 미주입 — 스모크 세션 JSONL로 부재 검증), 작업 리포 `~/ralph-exp008/app` (조상 CLAUDE.md 없음)
- env: 공식 claude-upstage.sh `set_claude_env` 재현 (EXP-006 open2-2와 동일), 모델 슬롯 5개 전부 solar-open2, 직결
- PROMPT.md: EXP-005/006과 byte-identical (Phase 0 diff 검증)
- 기동: `nohup caffeinate -is ./ralph.sh` (터미널 분리) — 외부 kill·슬립 0회

## 결과

- **완주**: iteration 10/30에서 `.ralph-done` 생성 → 게이트 검증 13/13 파일·154/154 요청 → 루프 종료
- 독립 재검증: 실험자 재실행 2회 모두 13/154 일치
- 수렴 궤적 (파일/요청): 0/0 → 0/0 → 3/60 → 3/92 → 4/107 → 9/134 → 9/134 → 10/135 → 0/19 → **13/154**
  - iteration 9의 0점은 DB 마이그레이션 미적용 상태(Prisma P2021)로 회차 종료 — 회차 경계 실행 불가 상태 리스크 사례, iteration 10에서 자체 복구
- git 커밋: **4회, 한국어 메시지** (EXP-005·006의 0회와 대조)
- 허락-대기: iteration 1에서 1회 재현("진행하시겠습니까?" 후 43초 종료) — 무오염 환경이므로 모델 내재 행동으로 확정
- usage (message.id dedup): API 587회, input 36.3M, output 0.57M tokens. thinking 1.43M자 = 출력 문자의 94% (클린 환경에서도 유지). cache 필드 전부 0(직결 미보고)
- 추정 비용: ~$5.8 (solar-pro3 단가 가정, 참고치 — 본 실험 판정에 미사용)

## 하네스 사고 이력 (모델 무관, report 프로토콜 이슈 절 참조)

1. 최초 기동 시 ralph.sh에 `cd $REPO` 누락 → claude가 실험 관리 리포에서 실행(약 2분) → kill·리포 복원·수정 후 클린 재기동. 해당 세션은 `incident-wrong-cwd.jsonl`로 보존, 본 run 데이터에서 제외
2. measure.sh v1이 Phase 0 dry-run 서버(tsx watch 재스폰)와 포트 간섭 + hurl 무한 대기 → iteration 2 계측이 34분 지연(iteration 유실은 없음). v2에서 리포 소속 검증·시간 상한 추가
3. 모델이 포트 3000에 서빙 → 8000 고정 가정 제거, v3 포트 자동 탐지 (iteration 3 계측부터 적용)

- 스냅샷: iteration별 리포 스냅샷은 `~/ralph-exp008/snapshots/` (용량 문제로 리포에 미수록), 최종 산출물은 `~/ralph-exp008/app`
