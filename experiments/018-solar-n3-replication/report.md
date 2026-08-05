# EXP-018 결과 보고: solar-open2 직결 재현성 확충 — 제공자 엔드포인트 회수로 재현 불가

- 실험일: 2026-08-05 (solar-2 기동 11:59 KST, 9 iteration 만에 중단)
- 가설: [M-13](../../hypotheses/catalog.md) — EXP-015의 solar-open2 직결 무개입 완주는 재현된다: 추가 2 run(총 n=3) 전부 30 iteration 안에 게이트(measure v4)+재검증 완주할 수 있다.
- **판정: 보류** — 모델 외적 장애(사전 등록 기준): 실험 개시 시점에 Upstage가 Anthropic 호환 엔드포인트(`/v1/messages`)와 solar-open2 hosted API를 회수해 run 자체가 불가능. 가설은 기각이 아니라 **검증 불가**.

## 경과

1. **solar-2 기동 (11:59:02)**: EXP-015 하네스 그대로(RUN명만 치환) 순차 오케스트레이터 시작. iteration 1–9가 각 3초 만에 즉시 실패 — Claude Code 오류 "There's an issue with the selected model (solar-open2). It may not exist or you may not have access to it." 오케스트레이터 중단(done 마커 없음, 과금·산출물 없음). 증거: [runs/metrics-solar-2.csv](runs/metrics-solar-2.csv), [runs/solar-2-error-excerpt.txt](runs/solar-2-error-excerpt.txt)
2. **원인 부검 (직접 스모크)**:
   - `GET /v1/models` 200: `solar-pro4`(신규)·pro3·pro2·mini·syn-pro — **solar-open2 없음**
   - `POST /v1/messages` **404 "invalid path"** — 모델 무관, anthropic-version 헤더 포함해도 동일. 이동 후보 경로 8종 전수 404
   - `POST /v1/chat/completions` + solar-open2 → 400 "invalid or **no longer supported**"; + solar-pro4 → 200 (사전 접근 활성 상태)
   - 공식 연동 스크립트(`console.upstage.ai/claude-upstage.sh`) 검수: `HOST=https://api.upstage.ai`, `DEFAULT_MODEL=solar-open2` — **우리 하네스와 동일 방법**. 즉 클라이언트 측 문제가 아니라 서버측 회수
3. **대체 스택 탐색 (전부 불가)**:
   - solar-pro4 직결: `/v1/messages` 경로 자체가 없어 모델 교체로 해결 불가 (실측)
   - Codex CLI: 0.144.0에서 `wire_api = "chat"` 지원 제거(responses 전용), Upstage는 `/v1/responses` 미제공(404). chat wire 마지막 지원 버전은 0.80.0으로 격차 과대
   - 변환 계층(프록시): 리포 규칙([CLAUDE.md](../../CLAUDE.md) 랄프 하네스 규칙 1) 금지
4. **외부 조사 (Perplexity, 2026-08-05)**:
   - solar-open2 hosted API는 **신청제 베타**였고 공지·마이그레이션 안내 없이 회수됨 (공식 changelog 최신 항목은 7/24, 관련 공지 없음)
   - solar-open2 모델 자체는 단종 아님 — 오픈웨이트(HF `upstage/Solar-Open2-250B`) 유지, 공식 Claude Code 연동은 자가 vLLM 서빙(H200 4장)만 문서화
   - **solar-pro4는 정식 출시 전 사전 접근 단계** (공식 문서·가격 페이지 미등재, "8월 출시 Solar Pro 4 API 사전 접근권" 파트너 안내만 존재) — Anthropic 호환 경로는 미공개

## 관찰

1. **EXP-015(2026-08-04)가 solar-open2 직결의 마지막 시점 기록이 되었다.** 하루 차이로 재현 창이 닫힘 — 서드파티 제공자 벤치마크는 재현 가능 시한이 제공자에 종속된다는 실증 사례.
2. 사전 등록한 "run 단위 보류(모델 외적 장애)" 기준이 실험 전체에 적용된 첫 사례. 판정 어휘로는 기각(가설이 틀림)과 구분해 **보류(검증 불가)**로 기록한다.
3. 즉시 실패 iteration은 3초/회로 30 iter 상한까지 방치 시에도 피해가 작지만, 오케스트레이터가 무의미한 done 마커를 남기기 전에 중단하는 개입은 무개입 원칙의 예외로 정당 (실험 대상 모델의 추론이 전혀 개입되지 않은 인프라 실패이므로).

## 한계·후속

- solar-pro4 정식 출시 시 Anthropic 호환 경로가 공개되면 그때 n=3 실험 재개 (신규 실험 번호로)
- solar-open2 재현은 자가 vLLM 서빙(H200 4장)으로만 가능 — 현 환경에서는 비현실적, 제외
- 기존 solar-open2 완주 기록(EXP-008 iter 10, EXP-015 iter 2)의 유효성은 불변 — 본 보류는 재현성 확충의 불가만 의미
