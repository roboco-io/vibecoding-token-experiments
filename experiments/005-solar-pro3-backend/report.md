# EXP-005 결과 보고: Claude Code × Upstage Solar Pro 3 백엔드

- 실험일: 2026-07-26
- 가설: [M-01](../../hypotheses/catalog.md) — Claude Code의 백엔드를 Solar Pro 3로 교체하면 동일 과제(RealWorld 백엔드)를 무개입 완주할 수 있고, 완주 시 총비용이 Opus 대비 유의미하게 낮다.
- **판정: 보류** — solar-1 미완주(테스트 실행 0회·커밋 0회, 6/15 iteration 시점 조기 중단): 연동 스택은 검증됐으나 headless 자율 루프에서 허락-대기·컨텍스트 초과 실패 모드가 반복되어 완주 궤도에 오르지 못함.

## 실행 요약

| 항목 | solar-1 | opus 기준 (EXP-002 ko 평균) |
|------|---------|------------------------------|
| 모델 | solar-pro3-260323 (CCR 1.0.73 경유) | claude-opus-4-8 |
| 완주 (Hurl 154 100%) | **미완주** (0%) — 서버 기동 불가, `.ralph-done` 없음 | 2/2 완주 |
| iteration | 5 완료 + 6번째 중단 (상한 15의 40%) | 단일 세션 |
| wall-clock | 1시간 57분 (중단 시점) | — |
| API 요청 | 534 | 83 (평균) |
| 신규 input / output | 1.60M / 0.37M tokens | 0.9K / 85K tokens |
| cache read | 28.9M tokens | 6.0M tokens |
| **비용** | **$0.49–7.72** (캐시 read 무료–전액 가정; Upstage 캐시 할인율 미공표) | **$6.41** ($6.20 / $6.63) |
| git 커밋 | **0회** | 작업 단위별 커밋 |

- 중단 사유: 사용자 결정(2026-07-26 12:45). 사전 고정 판정 기준의 "0/2 완주 → 기각"은 15 iteration 완료가 전제라 적용 불가 → "그 외 → 보류 + 실패 모드 분석" 적용.
- 비용 비교의 함의: 보수 상한($7.72)만으로도 **미완주 상태에서 이미 Opus 완주 비용($6.41)을 초과**. 캐시가 무료여도 완주 관문을 못 넘으면 단가 우위는 무의미하다.

## 실패 모드 분석 (핵심 산출물)

1. **허락-대기 종료 (iter 1·2·4)**: headless 환경에서 "테스트를 실행할까요? (예/아니오)", "삭제할까요?" 등 확인 질문으로 턴을 끝냄. 자율 루프의 전진이 랄프 재기동에만 의존. Opus 랄프 런(EXP-001/002/004)에서는 미관찰된 Solar 특유 행동.
2. **컨텍스트 초과 크래시 (iter 3·5)**: `context_length_exceeded` 400 — 메시지 ~99K + completion 예약 32K > 한도 131K. 원인은 이중: (a) Claude Code가 컨텍스트를 200K로 가정해 컴팩션이 늦음, (b) Claude Code의 max_tokens=32K가 변환 계층에서 조정 없이 전달됨. CCR `maxtoken` transformer로 완화 가능(본 run에서는 무개입 원칙상 미적용).
3. **지시 추종력 약함**: "작업 단위마다 커밋" 지시 무시(시도 1회, 체인 실패로 커밋 0), 테스트 정본 이탈(`realworld-apps` 대신 `gothinkster` 클론), hurl을 npm 패키지로 착각, `backend/`·`realworld-backend/`·`backend/backend/` 삼중 구조 혼선.
4. **도구 호출 자체는 안정**: 534요청 동안 tool calling 형식 오류 없음(Bash 180·Read 131·Write 18 등). 실패는 프로토콜 계층이 아니라 **모델의 에이전틱 행동 계층**에서 발생.

## 조사 대비 수정된 사실

- **Upstage에 OpenAI식 자동 프롬프트 캐싱이 존재** (research.md §4.1의 "캐싱 부재" 가정 정정). CCR이 `cached_tokens`를 `cache_read_input_tokens`로 매핑해 세션 로그 집계가 그대로 동작. 단 캐시 할인율이 미공표라 비용은 범위로만 산출 가능.
- 계측 스택 확립: CCR 1.0.73 + 커스텀 `solar-fix` transformer(reasoning→`reasoning_effort`) + 내장 `streamoptions`(SSE usage 전달) 조합으로 세션 JSONL에 usage가 정상 기록됨. Phase 0 파일럿(소형 과제)은 무개입 완주 — 연동 자체는 실용 수준.

## 결론·후속

- **연동 스택은 검증, 완주는 실패.** Solar Pro 3의 tool calling·한국어·소형 과제 수행은 실용적이나, 수시간급 headless 자율 루프에는 (1) 자율성 부족(허락-대기), (2) 131K 컨텍스트 제약이 병목.
- 재실험(M-02 후보) 시 변경할 조건: CCR `maxtoken` transformer로 completion 예약 축소 + `CLAUDE_CODE_MAX_OUTPUT_TOKENS` 조정, 프롬프트에 자율 진행 지시 1줄 추가("확인 질문 없이 진행하라"). 단 프롬프트 변경 시 Opus 기준선 재실행 필요성 명시.
- 데이터: [runs/solar-1/](runs/solar-1/) (meta, ralph-run.log, 세션 로그 6개, test-result). 사전 조사: [research.md](research.md)
