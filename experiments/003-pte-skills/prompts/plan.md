# EXP-003 계획 세션 프롬프트

---

RealWorld App(https://realworld-docs.netlify.app/specifications/backend/endpoints/) 백엔드 API 구현을 위한 계획을 수립하라. 이 세션에서는 **코드를 작성하지 않는다**. 산출물은 문서와 스킬뿐이다.

- 기술 스택: TypeScript (Node.js) + Fastify + Prisma + SQLite
- 완료 기준: RealWorld 공식 Hurl API 테스트(https://github.com/realworld-apps/realworld 의 `api/hurl`, 13파일 154요청) 전체 통과, 단일 명령 서버 기동

컨텍스트 구조화 원칙 (Claude 스킬 공식 권고를 따른다):

- **모든 문서는 200줄 이하**로 유지한다.
- 세션이 상시 읽어야 하는 내용은 최소화하고, 상세 내용은 **필요할 때만 로드되는 스킬로 분리**한다 (점진 공개).

산출물:

1. `docs/plan.md` — 태스크 목록, 의존성 그래프, 병렬 실행 가능 그룹만 담는다 (200줄 이하).
2. `docs/tasks/NN-<이름>.md` — 태스크별 명세 (각 200줄 이하): 목적, 구현 범위, 대상 파일 경로, 완료 기준(테스트 방법 포함), 하단 `## 완료 기록` 빈 섹션. **인터페이스 상세를 본문에 중복 수록하지 말고**, 참조할 스킬 이름을 명시한다.
3. `.claude/skills/<도메인>/SKILL.md` — 태스크 간 공유되는 인터페이스 계약·규약·스펙 상세를 도메인별 스킬로 분할한다 (각 200줄 이하). frontmatter(`name`, `description`)를 갖추고, description만 보고도 어떤 태스크가 언제 이 스킬을 읽어야 하는지 알 수 있게 쓴다.

태스크는 가능한 한 잘게, 아토믹하게 나눈다. 각 실행 세션은 **자신의 태스크 명세와 필요한 스킬만 읽고** 독립적으로 구현할 수 있어야 한다.
