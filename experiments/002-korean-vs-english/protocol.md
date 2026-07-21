# EXP-002 실행 프로토콜

## 사전 준비

1. run별 작업 리포 4개를 새로 만든다 (빈 저장소, CLAUDE.md 없음, 이 리포 밖):
   - `realworld-exp002-ko-1`, `realworld-exp002-ko-2`
   - `realworld-exp002-en-1`, `realworld-exp002-en-2`
2. 각 리포에 EXP-001의 `ralph.sh`(최대 15회, `.ralph-done` 마커, `env -u ANTHROPIC_API_KEY claude --model opus -p`)를 복사하고, 조건에 맞는 프롬프트([prompts/ko.md](prompts/ko.md) 또는 [prompts/en.md](prompts/en.md)의 `---` 이후 본문)를 `PROMPT.md`로 저장한다.
3. **번역 충실성 교차 검토**: 실행 전 두 프롬프트를 나란히 놓고 언어 외 내용 차이가 없는지 확인한다 (완료 기준·지침 항목 수·구체성 동일).
4. 시작 전 `runs/<run>/meta.md`에 시작 시각·리포 경로를 기록한다.

## 실행

1. run 순서: ko-1 → en-1 → ko-2 → en-2 (조건 교차 배치 — 시간대·시스템 상태 편향 완화).
2. 각 run: 작업 리포에서 `nohup ./ralph.sh & disown` 실행, `.ralph-done` 또는 루프 종료까지 무개입.
3. 완료 시각·이터레이션 수를 `runs/<run>/meta.md`에 기록.

## run별 수집·검증

1. **완료 판정**: 실험자가 독립적으로 서버 기동 + Hurl 테스트 재실행 → `runs/<run>/test-result.txt` 저장. 154요청 100%만 통과 인정.
2. **언어 준수 검사**: 산출된 README·주석·커밋 메시지 샘플을 확인해 조건 언어와 일치하는지 기록. 광범위 미준수 run은 무효 처리 후 재실행.
3. 세션 로그 수집: `cp ~/.claude/projects/<리포-슬러그>/*.jsonl runs/<run>/logs/`
4. `ralph-run.log` 사본 보관.

## 집계·분석

1. 동적: `python3 scripts/aggregate_tokens.py runs/ko-1/logs runs/ko-2/logs runs/en-1/logs runs/en-2/logs`
2. 분해: run별 output / cache_creation / billable, 조건 평균과 run 간 변동폭 비교.
3. 정적: 문서쌍(프롬프트 KO/EN, EXP-001 plan.md 발췌 번역쌍)을 count_tokens API로 측정해 한국어/영어 토큰 비율 산출. 유효 API 키 부재 시 대체 토크나이저로 근사하고 보고서에 한계 명시.
4. 판정: |KO평균 − EN평균| > max(조건 내 run 간 차이) 이면 유효한 언어 효과로 보고 L-01 판정. 아니면 보류(n 증량 검토).

## 종료 후

`report.md` 작성 → `hypotheses/catalog.md`의 L-01 상태 갱신.
