# EXP-002 EN 조건 프롬프트 (PROMPT.md로 사용)

---

Implement the RealWorld App (https://realworld-docs.netlify.app/specifications/backend/endpoints/) backend API.

- Tech stack: TypeScript (Node.js) + Fastify + Prisma + SQLite
- Scope: authentication (JWT), users/profiles, article CRUD, comments, favorites, tags, feed — the full RealWorld backend spec
- Completion criteria:
  1. All official RealWorld Hurl API tests pass — tests: `api/hurl` in https://github.com/realworld-apps/realworld (13 files, 154 requests). Vendor them into the repo and run them.
  2. The server starts with a single command (`npm run dev` or equivalent)

Language directive (important):

- **All text you produce** in this project must be written in English: README and docs, code comments, git commit messages, and progress reports. (Code identifiers and library APIs excluded.)

Working instructions:

- First inspect the current repo state (files, git log), then pick the single most important remaining piece of work toward the completion criteria and do it.
- Make a git commit for each unit of work.
- Only after directly running and verifying all completion criteria, create a `.ralph-done` file at the repo root. Never create it without verification.
- Do not modify PROMPT.md or ralph.sh.
