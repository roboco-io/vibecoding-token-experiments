# EXP-014 Phase 0 통과 기록 (2026-08-04 KST)

하네스 베이스 `~/ralph-exp014/`. EXP-013 하네스에서 BASE·RUN명·모델 env(엔드포인트/키/모델 ID)만 치환 — ccr 없음, 기존 환경 변경 없음.

## 선행 게이트 (설계 등록)

- `KIMI_API_KEY` → 국제판 `https://api.moonshot.ai/anthropic/v1/messages` 직접 호출: HTTP 200, thinking 블록 기본 활성.

## ① 직결 claude -p 도구 사용 스모크

- 격리 `CLAUDE_CONFIG_DIR` + 직결 env, `ANTHROPIC_MODEL=kimi-k3`(SMALL_FAST·DEFAULT_HAIKU 동일 지정).
- 파일럿(`claude -p`): hello.txt 생성 + git 커밋(smoke, hello.txt 1파일만) + "DONE", exit 0 — tool call 왕복·모델 라우팅·온보딩 우회 통과, **rate limit 걸림 없음**(설계 리스크였던 Tier 0 제약 미발현). 트러블슈팅 0건.

## ② 프롬프트 diff

- `diff ~/ralph-exp010/PROMPT.md ~/ralph-exp014/PROMPT.md` → **diff 0 (byte-identical)**

## ③ measure.sh 치환본·포트

- EXP-013판 BASE만 치환, 빈 리포 → `0,0`. 포트 8000 비점유. hurl 13파일.

## ④ usage 계측

- 세션 jsonl usage 정상 기록: 스모크 실측 `1,16043,0,4352,132` (messages,input,cache_create,cache_read,output — message.id dedup). cache_create 0·cache_read>0은 Moonshot 캐시 계상 방식 차이로 보이며 기록만 남김.
- Phase 0 세션은 `claude-config-projects-phase0/`로 격리, 본 실행은 새 projects/에서 집계.
