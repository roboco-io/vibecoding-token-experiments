# EXP-006 결과 보고: Claude Code × Upstage Solar Open 2 백엔드

- 실험일: 2026-07-26 – 2026-07-27
- 가설: [M-02](../../hypotheses/catalog.md) — Claude Code의 백엔드를 Solar Open 2로 교체하면 동일 과제(RealWorld 백엔드)를 무개입 완주할 수 있고, 완주 시 총비용이 Opus 대비 유의미하게 낮다.
- **판정: 보류** — 0/2 완주이나 완전 프로토콜 run은 1회뿐(open2-1은 1 iter 만에 허위 완료 신고로 자체 종료): open2-2는 15 iteration을 소진하고도 독립 검증 3/13 파일(94/154 요청)에 그쳤지만, solar-pro3에서 부재했던 자율 TDD 루프를 확립하고 단조 수렴해 "행동 계층" 병목이 자율성에서 수렴 속도로 이동했다.

## 실행 요약

| 항목 | open2-1 (CCR) | open2-2 (공식 직결) | opus 기준 (EXP-002 ko 평균) |
|------|---------------|---------------------|------------------------------|
| 경로 | CCR 1.0.73 + open2-split | api.upstage.ai Anthropic 호환 직결 | Anthropic API |
| 완주 (Hurl 154 100%) | 미완주 (0%) | **미완주 — 3/13 파일 (23.1%), 94/154 요청** | 2/2 완주 |
| iteration | 1 (허위 `.ralph-done`으로 자체 종료) | 15/15 소진 (완주 13 + 외부 kill 유실 2) | 단일 세션 |
| 실가동 wall-clock | 14분 | 약 1시간 56분 | — |
| API 요청 | 54 | 1,481 | 83 (평균) |
| 신규 input / output | 0.23M / 0.07M | **67.0M / 1.30M** | 0.9K / 85K tokens |
| cache read | 1.82M | **0 (미보고 — 실제 캐싱 여부 불명)** | 6.0M tokens |
| 추정 비용 | ~$0.1 | **$10.8** (solar-pro3 단가 $0.15/$0.60 가정, 캐시 무시) — 단가 미공개(베타)라 참고치, 콘솔 과금이 정본 | **$6.41** |
| git 커밋 | 0회 | 0회 | 작업 단위별 커밋 |

- 독립 검증: 공식 스위트를 실험자가 재실행해 모델 자체 보고와 일치 확인. 통과 3파일 = auth(20요청 전체)·errors_articles(20)·pagination(7). 서버 단일 명령 기동(`npm run start`)은 충족.
- 테스트 정본성 검증: 벤더링된 13개 hurl + 실행 스크립트가 공식 realworld-apps/realworld `specs/api/hurl`과 **byte-identical** (solar-pro3의 정본 이탈과 대조).
- 비용의 함의: EXP-005와 동일 구조 — 보수 추정만으로 미완주 상태에서 Opus 완주 비용($6.41)을 초과. 단 직결 경로가 캐시를 미보고하므로 실비는 이보다 낮을 수 있고, 베타 기간 무료일 가능성도 있다.

## solar-pro3 대비 행동 계층 개선 (핵심 산출물)

| 행동 | solar-pro3 (EXP-005) | solar-open2 (본 실험) |
|------|----------------------|----------------------|
| 자율성 | 허락-대기로 매 iteration 정지 | **확인 질문 없이 자율 진행** (재개 후 10 iteration 연속) |
| 테스트 | 실행 0회, 정본 이탈 | 정본 벤더링 + **12개 세션에서 반복 실행** (TDD 루프) |
| 수렴 | 없음 | 요청 실행 64→94, 파일 통과 1→3 단조 개선 |
| 컨텍스트 | 131K 초과 크래시 2회 | 크래시 0회 (서빙 256K + 한도 정합 env) |
| 남은 병목 | 자율성 자체 | **수렴 속도** — status code·응답 필드 세부 불일치 다수 잔존 |

## 실패 모드 분석

1. **완료 허위 신고 (open2-1)**: 작업 미완 상태(커밋 0·테스트 0·라우터 구현 중이라 자인)에서 `.ralph-done` Write — PROMPT의 "검증 없이 생성 금지" 위반. 신형 실패 모드로, 랄프 루프가 완료 신호를 검증 없이 신뢰하는 설계 취약점을 드러냄. 공식 직결의 open2-2에서는 15 iteration 동안 미재발.
2. **커밋 지시 무시 (두 run 공통)**: "작업 단위마다 커밋" 지시에도 커밋 0회 — solar-pro3와 동일한 solar 계열 공통 패턴.
3. **수렴 속도 부족 (open2-2)**: 10개 파일이 초반 3–5 요청에서 실패(status code assert 다수). iteration당 개선 폭 기준 완주까지 상한의 수 배가 필요한 추세.
4. **환경 교란 (모델 귀책 아님)**: 외부 kill 2회 + 시스템 슬립 1회로 iteration 2개 유실·일정 지연. API 오류는 전 구간 0건.

## 신규 발견 (인프라 계층)

1. **CCR 1.0.73 멀티 델타 유실 버그**: solar-open2는 한 SSE 청크의 `delta.tool_calls` 배열에 인자 조각 2개를 실어 보내는데 CCR이 첫 요소만 처리 → tool call 인자 앞부분 유실(`python3`→`3`, `/Users/...`→`Users/...`), 파일럿 2회 연속 실패. 커스텀 `open2-split` transformer(멀티 델타를 개별 이벤트로 분리)로 해결. solar-pro3는 청크당 1조각이라 미발현 — **"모델 품질 저하"로 보이는 증상이 변환 계층 결함일 수 있음을 재확인** (EXP-005 리스크 항목의 실증 사례).
2. **Upstage 공식 Claude Code 직결 경로**: claude-upstage.sh가 `ANTHROPIC_BASE_URL=https://api.upstage.ai` 직결(Anthropic 호환 네이티브, thinking 포함)을 제공 — EXP-005의 "변환 프록시 필수" 전제가 무효화됨. 256K/128K 한도 정합 env까지 공식 제공.
3. **직결 경로의 캐시 미보고**: Anthropic 형식 usage에 cache 필드가 전부 0 — 비용 분해가 불가능해 계측 관점에서는 CCR 경유(cached_tokens 매핑)보다 열위.

## 결론·후속

- **행동 계층은 세대 개선, 완주 관문은 여전히 미돌파.** solar-open2는 Claude Code 자율 루프에서 "일하는 방법"(자율 진행·정본 테스트·TDD)을 갖췄으나, 스펙 세부 정합의 수렴 속도가 상한 내 완주에 못 미쳤다. 비용 우위 가설은 단가 미공개로 판정 불능.
- 재실험 조건 후보: iteration 상한 상향(15→30) 또는 wall-clock 기준 단일 상한으로 전환, Upstage 콘솔 실과금 확인 후 비용 재산정, 랄프 루프에 `.ralph-done` 외부 검증 게이트 추가(허위 신고 대책).
- 데이터: [runs/open2-1/](runs/open2-1/) (CCR, 허위 완료), [runs/open2-2/](runs/open2-2/) (직결, meta·ralph-run.log·세션 로그 15개·test-result). 실험 설계·Phase 0: [README.md](README.md)
