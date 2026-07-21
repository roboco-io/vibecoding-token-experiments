# pte-skills 실행 기록

- 작업 리포: `~/Workspace/roboco-io/research/realworld-exp003-pte-skills` (빈 저장소, CLAUDE.md 없음)
- 모델: Claude Opus (headless, `env -u ANTHROPIC_API_KEY claude --model opus -p`)
- 실행 방식: EXP-001 PTE와 동일 워크플로 (계획 1회 → 태스크별 새 세션 병렬 → 검증). 차이는 컨텍스트 구조: 문서 200줄 이하 + `.claude/skills/` 도메인 스킬로 점진 공개
- 시작 시각: 2026-07-21 20:23:32 (계획 세션 시작)
- 종료 시각: 2026-07-21 20:57:38 (총 약 34분: 계획 12분 + 실행 21.5분, 수정 루프 없음)

## 결과

- 완료 판정: **통과** — 게이트(태스크 14) 첫 시도 GREEN. 실험자 독립 재검증 Hurl 13파일/154요청 100% ([test-result.txt](test-result.txt))
- 형식 준수: 모든 문서 200줄 이하 (plan.md 110줄), 스킬 6개 frontmatter 유효
- 토큰: sessions 15 (계획1+태스크14), messages 512, output 348,232, cache_creation 1,374,367, cache_read 26,885,312, **billable 1,723,575**
- Skill 호출 41회 (점진 공개 실작동), Read 25회, 세션 간 반복 읽기 사실상 소멸 (3회 이상 반복 읽기: articles.ts 3회뿐)
- 세션 로그 슬러그: `~/.claude/projects/-Users-dohyunjung-Workspace-roboco-io-research-realworld-exp003-pte-skills/`

## 세션 기록

| # | 종류 | 대상 | 시작 | 종료 | 비고 |
|---|------|------|------|------|------|
| 1 | 계획 | docs/ + .claude/skills/ | 20:23:32 | | |

## 개입 기록

(무개입 원칙. 오케스트레이션은 실험자 담당 — 측정 외)

## 특이사항

- 검증 단계에서 `node_modules/@prisma/client`가 불완전 설치 상태로 발견(`default.js` 누락 — 병렬 세션들의 npm 동시 실행 부작용 추정). 실험 종료 후 실험자가 해당 패키지만 재설치(빌드 산출물 복구, 코드 무관)하고 재검증 — 154/154 통과. 에이전트 산출물 결함 아님
