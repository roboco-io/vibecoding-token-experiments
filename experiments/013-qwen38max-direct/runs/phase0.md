# EXP-013 Phase 0 통과 기록 (2026-08-03 KST)

하네스 베이스 `~/ralph-exp013/`. ccr 없음 — DashScope Anthropic 호환 엔드포인트 직결. 기존 환경 변경 없음(복원 절차 불필요).

## 선행 게이트 (설계 등록)

- `QWEN_API_KEY` → intl 엔드포인트 `/apps/anthropic/v1/messages` 직접 호출: HTTP 200, thinking 블록 기본 활성, usage 필드 Claude 스키마(`cache_creation_input_tokens` 등) 확인.

## ① 직결 claude -p 도구 사용 스모크

- 격리 `CLAUDE_CONFIG_DIR` + `ANTHROPIC_BASE_URL` 직결, `ANTHROPIC_MODEL=qwen3.8-max`(SMALL_FAST·DEFAULT_HAIKU 동일 지정).
- 파일럿(`claude -p`): hello.txt 생성 + git 커밋(smoke, hello.txt 1파일만) + "DONE", exit 0 — **tool call 왕복·모델 라우팅·온보딩 우회 모두 통과**. 트러블슈팅 0건 (EXP-012 대비: 변환 계층이 없어 responses 전환·transformer 체인 작업 자체가 소멸).

## ② 프롬프트 diff

- `diff ~/ralph-exp010/PROMPT.md ~/ralph-exp013/PROMPT.md` → **diff 0 (byte-identical)**

## ③ measure.sh 치환본·포트

- EXP-012판 BASE만 치환(diff로 무변경 증명), 빈 리포 → `0,0`. 포트 8000 비점유. hurl 13파일.

## ④ usage 계측

- 직결에서는 Claude 세션 jsonl usage가 **정상 기록** (EXP-012의 ccr usage 유실 문제 없음): 스모크 실측 `2,1431,23171,18866,211` (messages,input,cache_create,cache_read,output — message.id dedup). cache 필드 채워짐 = context caching도 직결 경유 동작.
- Phase 0 세션은 `claude-config-projects-phase0/`로 격리, 본 실행은 새 projects/에서 집계.
