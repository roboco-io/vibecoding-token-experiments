# plan-then-execute 계획 세션 프롬프트

---

RealWorld App(https://realworld-docs.netlify.app/specifications/backend/endpoints/) 백엔드 API 구현을 위한 계획을 수립하라. 이 세션에서는 **코드를 작성하지 않는다**. 산출물은 문서뿐이다.

- 기술 스택: TypeScript (Node.js) + Fastify + Prisma + SQLite
- 완료 기준: RealWorld 공식 API 테스트(Postman/Newman) 전체 통과, 단일 명령 서버 기동

산출물:

1. `docs/plan.md` — 전체 아키텍처, 태스크 목록과 의존성 그래프, 병렬 실행 가능 그룹
2. `docs/tasks/NN-<이름>.md` — 태스크별 명세. 각 명세는 **그 문서만 읽고 새 세션에서 독립적으로 구현 가능**해야 한다:
   - 목적, 구현 범위, 대상 파일 경로
   - 선행 태스크와 그 산출물 중 이 태스크가 의존하는 인터페이스 (스키마, 타입, 함수 시그니처)
   - 완료 기준 (테스트 방법 포함)
   - 하단에 `## 완료 기록` 빈 섹션 (실행 세션이 채움)

태스크는 가능한 한 잘게, 아토믹하게 나눈다. 한 태스크는 한 세션이 컨텍스트 부담 없이 끝낼 수 있는 크기여야 한다.
