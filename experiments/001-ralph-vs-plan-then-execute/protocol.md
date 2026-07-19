# EXP-001 실행 프로토콜

## 사전 준비 (조건 공통)

1. 조건별 작업 리포지토리를 새로 만든다 (빈 저장소, 이 리포 밖):
   - `realworld-exp001-ralph`
   - `realworld-exp001-pte`
2. 각 작업 리포에서 Claude Code 모델을 Opus로 고정한다 (`/model opus` 또는 settings).
3. 작업 리포에는 CLAUDE.md 등 추가 컨텍스트를 두지 않는다 (조건 간 동일 조건 유지).
4. 측정 기준 시각을 기록한다 (`runs/<조건>/meta.md`에 시작/종료 시각, 작업 리포 경로).

## 조건 A: ralph-loop

1. 작업 리포에서 새 세션 시작.
2. [`prompts/ralph-loop-goal.md`](prompts/ralph-loop-goal.md) 내용을 골로 지정하고 Ralph loop(`/ralph-loop`)로 자율 진행.
3. 완료 기준 충족 또는 루프 정지까지 무개입. 불가피한 개입은 `runs/ralph-loop/meta.md`에 기록.

## 조건 B: plan-then-execute

1. **계획 세션** (새 세션 1회): [`prompts/pte-plan.md`](prompts/pte-plan.md)를 입력. 산출물 = `docs/plan.md` + `docs/tasks/NN-*.md` (아토믹 태스크 명세, 태스크 간 의존성 명시).
2. **실행 세션** (태스크당 새 세션): 각 태스크마다 [`prompts/pte-execute.md`](prompts/pte-execute.md) 템플릿에 태스크 명세 경로를 넣어 시작. 의존성 없는 태스크는 병렬 실행 가능.
3. 각 실행 세션 종료 시 태스크 명세에 완료 기록을 남긴다 (다음 세션의 컨텍스트는 문서만).
4. 모든 태스크 완료 후 **검증 세션** 1회: API 테스트 실행, 실패 시 수정 태스크를 새로 정의해 2번 방식으로 반복.

## 로그 수집·측정 (조건 공통)

1. 세션 로그 사본 수집: `cp ~/.claude/projects/<작업리포-슬러그>/*.jsonl runs/<조건>/logs/`
2. 토큰 집계: `python3 scripts/aggregate_tokens.py runs/ralph-loop/logs runs/plan-then-execute/logs`
3. 보조 측정: ccusage(일자별 교차 확인), tokenhabit `habit_scan.py`(습관 패턴 참고용)
4. 완료 판정: RealWorld 공식 Postman/Newman collection 실행 결과를 `runs/<조건>/test-result.txt`로 저장

## 종료 후

`report.md` 작성 → `hypotheses/catalog.md`의 S-01 상태 갱신.
