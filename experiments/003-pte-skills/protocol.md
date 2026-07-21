# EXP-003 실행 프로토콜

EXP-001 조건 B(plan-then-execute) 프로토콜과 동일하되, 프롬프트만 [prompts/](prompts/)로 교체.

## 절차

1. 빈 작업 리포 `realworld-exp003-pte-skills` 생성 (CLAUDE.md 없음).
2. **계획 세션** 1회: [prompts/plan.md](prompts/plan.md) 본문(`---` 이후)을 headless Opus로 실행 → `docs/plan.md`(200줄 이하) + `docs/tasks/`(각 200줄 이하) + `.claude/skills/*/SKILL.md`(도메인별 계약) 산출.
3. **산출물 형식 검사** (실험자): 모든 문서 200줄 이하인지, 스킬 frontmatter가 유효한지 확인. 위반 시 특이사항 기록 (수정 개입은 하지 않음 — 구조 미준수도 관찰 대상).
4. **실행 세션**: plan.md의 병렬 그룹 순서대로 태스크당 새 세션 ([prompts/execute.md](prompts/execute.md) 템플릿). 오케스트레이션(기동 순서)은 실험자.
5. **검증 게이트** 실패 시 EXP-001과 동일하게 수정 태스크를 정의해 반복.
6. 완료 판정: 실험자가 독립적으로 서버 기동 + Hurl 154요청 재실행 → `runs/pte-skills/test-result.txt`.

## 수집·분석

1. `cp ~/.claude/projects/<슬러그>/*.jsonl runs/pte-skills/logs/`
2. `python3 scripts/aggregate_tokens.py runs/pte-skills/logs` + EXP-001 수치와 비교표
3. 세션별 분해(기동세·output·cache_creation), 스킬 로드 횟수·계약 문서 반복 읽기 카운트 (EXP-001 분석 스크립트 재사용)
4. `report.md` 작성 → catalog S-02 갱신
