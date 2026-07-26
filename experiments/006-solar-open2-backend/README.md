# EXP-006: Claude Code × Upstage Solar Open 2 백엔드 교체

> EXP-005 프로토콜 재사용 — 방법론·조건·판정 기준은 [EXP-005 README](../005-solar-pro3-backend/README.md), 사전 조사는 [EXP-005 research.md](../005-solar-pro3-backend/research.md) 참조. 본 문서는 차이점만 기록한다.

## 가설

M-02: Claude Code의 백엔드를 Upstage **Solar Open 2**로 교체하면 동일 과제(RealWorld 백엔드)를 무개입 완주할 수 있고, 완주 시 총비용(USD)이 Claude Opus 대비 유의미하게 낮다.

EXP-005(Solar Pro 3)의 보류 판정 후속: solar-open2 베타 개방에 따른 재실험 ([exp-005 메모리](../../experiments/005-solar-pro3-backend/report.md) 후속 계획).

## EXP-005 대비 차이점

| 항목 | EXP-005 (solar-1) | EXP-006 (open2-1) |
|------|-------------------|-------------------|
| 모델 | solar-pro3 (reasoning) | solar-open2 (reasoning, `reasoning_effort` 지원) |
| transformer 체인 | solar-fix + streamoptions | **open2-split** + solar-fix + streamoptions |
| 프롬프트·과제·중단 상한 | — | 동일 (PROMPT.md byte-identical, 15 iter / $15 / 8h) |

### 신규 발견: CCR 멀티 델타 유실 버그 (Phase 0)

solar-open2는 스트리밍 시 **한 SSE 청크의 `delta.tool_calls` 배열에 인자 조각 2개를 동시에** 실어 보낸다. CCR 1.0.73은 배열 첫 요소만 처리해 나머지를 버림 → tool call 인자 앞부분 유실(`python3` → `3`, `/Users/...` → `Users/...`), 파일럿 2회 연속 실패(깨진 파일, 쓰레기 디렉토리 생성, 커밋 허위 보고). solar-pro3는 청크당 1조각이라 미발현.

보정: `~/.claude-code-router/plugins/open2-split.js` — 멀티 요소 `tool_calls` 델타를 개별 SSE 이벤트로 분리 재송출. 적용 후 파일럿 3차 완주(파일 정상·실행 검증·실제 커밋 확인).

### 신규 발견 2: Upstage 공식 Claude Code 직결 경로 존재

Upstage가 공식 연동 스크립트(https://console.upstage.ai/claude-upstage.sh)를 배포 중 — `ANTHROPIC_BASE_URL=https://api.upstage.ai` 직결(Anthropic 호환 `/v1/messages` 네이티브 제공, 본 세션 키로 작동 확인). CCR 같은 변환 프록시가 불필요하며, `CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144`·`CLAUDE_CODE_MAX_OUTPUT_TOKENS=131072`로 한도 불일치 문제도 해소. EXP-005 당시 "Anthropic 호환 엔드포인트 없음" 전제가 무효화됨. open2-1은 EXP-005 비교 가능성을 위해 CCR 경유로 진행하되, 공식 직결 경로는 후속 run 후보.

## 모델 스펙 (조사 요약)

- 250B 총 / 15B 활성 MoE, 48층, 오픈웨이트 (Upstage Solar License, Apache 2.0 기반). 2026-07-22 공개, arXiv 2607.20062
- 컨텍스트: 모델 1M / API 서빙 256K (공식 스크립트 주석 기준) — EXP-005의 131K 병목 해소
- max output 128K, reasoning_effort 지원, 표준 function calling ("agentic specialist" 포지셔닝, MCP-Atlas 58.2)
- 단가 미공개 (베타) — 콘솔 과금이 정본. 한국어 토큰 효율은 글로벌 모델 대비 50–80% 수준 주장

## Phase 0 결과 (2026-07-26)

1. 일반 왕복·thinking 왕복: 통과
2. usage 회계: 세션 JSONL에 usage 기록, Upstage 자동 캐싱 → `cache_read_input_tokens` 매핑 정상
3. 파일럿: open2-split 적용 전 0/2, 적용 후 1/1 완주 → **go**

## 데이터

- `runs/open2-1/` — 본 run (진행 중)
