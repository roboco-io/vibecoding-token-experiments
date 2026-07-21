# skills-2 실행 기록

- 작업 리포: `~/Workspace/roboco-io/research/realworld-exp004-skills-2` (빈 저장소 + `.claude/skills/` 6개 사전 배치)
- 조건: ralph + 스킬 (skills-1과 동일)
- 시작: 2026-07-21 23:13:03 / 종료: 23:20:48 (이터레이션 1회, 약 7.5분)

## 결과

- 완료 판정: 통과 — Hurl 154/154 독립 재검증 ([test-result.txt](test-result.txt))
- 토큰: messages 87, output 48,625, cache_creation 150,030, **billable 198,819** — 전체 ralph 실행 중 최저
- 스킬 소비: skills-1과 동일하게 SKILL.md 6개 전부 Read(전량 선로딩), Skill 도구 호출 0회

## 특이사항

- 같은 처치의 skills-1(billable 399,604)과 2배 차이 — output 147K vs 49K. 구현 궤적(코드·설명 분량)의 run 간 변동이 처치 효과를 압도함을 재확인
