RealWorld App (https://realworld-docs.netlify.app/specifications/backend/endpoints/) 백엔드 API를 구현하라.

- 기술 스택: TypeScript (Node.js) + Fastify + Prisma + SQLite
- 범위: 인증(JWT), 사용자/프로필, 게시글 CRUD, 댓글, 즐겨찾기, 태그, 피드 — RealWorld 백엔드 스펙 전체
- 완료 기준:
  1. 공식 RealWorld Hurl API 테스트 전체 통과 — 테스트: https://github.com/realworld-apps/realworld 의 `api/hurl` (13개 파일, 154개 요청). 리포에 vendoring하여 직접 실행할 것.
  2. 단일 명령(`npm run dev` 또는 동등한 명령)으로 서버가 기동될 것

언어 지시 (중요):

- 이 프로젝트에서 **네가 생성하는 모든 텍스트**는 한국어로 작성해야 한다: README와 문서, 코드 주석, git 커밋 메시지, 진행 보고까지. (코드 식별자와 라이브러리 API는 제외.)

작업 지침:

- 먼저 현재 리포 상태(파일, git log)를 파악한 뒤, 완료 기준을 향해 남은 작업 중 가장 중요한 한 조각을 골라 수행하라.
- 작업 단위마다 git 커밋을 남겨라.
- 완료 기준 전체를 직접 실행·검증한 뒤에만 리포 루트에 `.ralph-done` 파일을 생성하라. 검증 없이 절대 생성하지 마라.
- PROMPT.md와 ralph.sh는 수정하지 마라.
