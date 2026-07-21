# EXP-002 KO 조건 프롬프트 (PROMPT.md로 사용)

---

RealWorld App(https://realworld-docs.netlify.app/specifications/backend/endpoints/) 백엔드 API를 구현하라.

- 기술 스택: TypeScript (Node.js) + Fastify + Prisma + SQLite
- 범위: 인증(JWT), 유저/프로필, 아티클 CRUD, 코멘트, 즐겨찾기, 태그, 피드 — RealWorld 백엔드 스펙 전체
- 완료 기준:
  1. RealWorld 공식 Hurl API 테스트 전체 통과 — 테스트: https://github.com/realworld-apps/realworld 의 `api/hurl` (13파일, 154요청). 리포에 벤더링해 실행하라.
  2. 단일 명령으로 서버 기동 가능 (`npm run dev` 또는 동등)

언어 지침 (중요):

- 이 프로젝트에서 네가 생산하는 **모든 텍스트는 한국어**로 작성하라: README·문서, 코드 주석, git 커밋 메시지, 작업 보고. (코드 식별자·라이브러리 API는 제외)

작업 지침:

- 먼저 현재 리포 상태(파일, git log)를 파악하고, 완료 기준까지 남은 작업 중 가장 중요한 것 하나를 골라 진행하라.
- 작업 단위마다 git 커밋을 남겨라.
- 모든 완료 기준을 직접 실행·검증한 뒤에만 리포 루트에 `.ralph-done` 파일을 생성하라. 검증 없이 생성 금지.
- PROMPT.md와 ralph.sh는 수정하지 마라.
