# EXP-015 Phase 0 통과 기록 (2026-08-04 KST)

하네스 베이스 `~/ralph-exp015/`. EXP-014 하네스에서 BASE·RUN명·모델 env(엔드포인트/키/모델 ID)만 치환 — 직결 템플릿 3번째 적용(DashScope·Moonshot에 이어 Upstage).

## 선행 게이트 (설계 등록)

- `UPSTAGE_API_KEY` → `https://api.upstage.ai/v1/messages` 호출: **Bearer 인증 200** (thinking 블록 기본 활성). `x-api-key` 헤더는 401 — Upstage는 Bearer만 수용하며, Claude Code의 `ANTHROPIC_AUTH_TOKEN`이 Bearer 방식이라 하네스 무수정.

## ① 직결 claude -p 도구 사용 스모크

- 격리 `CLAUDE_CONFIG_DIR` + 직결 env, `ANTHROPIC_MODEL=solar-open2`(SMALL_FAST·DEFAULT_HAIKU 동일 지정).
- 파일럿(`claude -p`): hello.txt 생성 + git 커밋(smoke, hello.txt 1파일만) + "DONE", exit 0 — tool call 왕복·모델 라우팅 통과. 트러블슈팅 0건.

## ② 프롬프트 diff

- `diff ~/ralph-exp010/PROMPT.md ~/ralph-exp015/PROMPT.md` → **diff 0 (byte-identical)**. (EXP-008의 프롬프트는 정본 이전 버전으로 상이 — EXP-008과의 비교를 정성 참조로 한정하는 사유, 설계 등록)

## ③ measure.sh 치환본·포트

- EXP-014판 BASE만 치환, 빈 리포 → `0,0`. 포트 8000 비점유. hurl 13파일.

## ④ usage 계측

- 세션 jsonl usage 정상 기록: 스모크 실측 `2,46563,0,0,116` (messages,input,cache_create,cache_read,output — message.id dedup). **cache 필드 양쪽 0** — Upstage는 캐시 미계상(또는 미지원)으로 보이며 기록만 남김(제공자별 캐시 계상 차이 3번째 사례: DashScope 양쪽 계상, Moonshot read만, Upstage 무계상).
- Phase 0 세션은 `claude-config-projects-phase0/`로 격리, 본 실행은 새 projects/에서 집계.
