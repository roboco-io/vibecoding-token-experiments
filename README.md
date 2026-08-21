# Vibecoding Token Experiments

바이브 코딩이 표준으로 도입되면서 여러 조직이 심각한 토큰 부족 현상을 겪고 있다.
이 리포지토리는 토큰 사용에 대한 가설을 세우고, 통제된 실험으로 실제 절약 효과를 검증하기 위한 실험 관리 리포지토리이다.

## 실험 방법론

- **공통 과제**: [RealWorld App](https://github.com/gothinkster/realworld) 백엔드 구현 — 조건 간 비교를 위한 고정 벤치마크 과제. 스펙은 [`tasks/realworld-backend/`](tasks/realworld-backend/) 참조.
- **모델 고정**: 모든 실험은 **Claude Opus 단일 모델**로 수행한다 (모델 차이로 인한 교란 제거).
- **측정 도구**: 기존 도구를 활용한다 — [tokenhabit](https://github.com/epoko77-ai/tokenhabit) (`habit_scan.py`), [ccusage](https://github.com/ryoppippi/ccusage). `scripts/`에는 실험 구간 추출·비교 집계용 최소 래퍼만 둔다.
- **1차 대상 도구**: Claude Code. 타 도구 비교는 [`ROADMAP.md`](ROADMAP.md) 참조.

## 가설의 축

1. **워크플로 전략 (S축)**: 같은 과제를 어떤 전략으로 수행하느냐에 따른 토큰 차이
   - Ralph loop: 골을 지정한 뒤 랄프 루프로 자율 진행
   - Plan-then-execute: 계획 수립 → 태스크 분할 → 개별 태스크 병렬 구현
2. **토큰 습관 (H축)**: tokenhabit의 H1–H8 습관 패턴 교정 전/후의 토큰 차이
3. **언어 (L축)**: 프롬프트·산출 문서의 언어(한국어/영어)에 따른 토큰 차이

전체 가설 목록과 실험 상태는 [`hypotheses/catalog.md`](hypotheses/catalog.md)에서 관리한다.

## 실험 결과

> 아래 표와 실험별 요약은 [`scripts/update_readme_results.py`](scripts/update_readme_results.py)가 각 실험의 `report.md`에서 자동 생성한다. 실험이 끝나 `report.md`가 커밋될 때 pre-commit 훅이 자동 실행한다 (수동 실행: `python3 scripts/update_readme_results.py`).

**📊 라이브 대시보드**: [랄프 루프 모델별 완주 비교](https://claude.ai/code/artifact/137de971-ded4-4fc6-ac5e-79bc96a09237) — 최신 실험 반영: EXP-020 (2026-08-19)

<!-- RESULTS:BEGIN -->
<!-- 이 블록은 scripts/update_readme_results.py가 experiments/*/report.md에서 자동 생성한다. 직접 수정 금지. -->

| 실험 | 가설 | 판정 |
|------|------|------|
| [EXP-001](experiments/001-ralph-vs-plan-then-execute/report.md) Ralph loop vs Plan-then-execute | S-01: Plan-then-execute가 Ralph loop보다 동일 과제에서 토큰을 적게 쓴다 | **기각 (반증)** |
| [EXP-002](experiments/002-korean-vs-english/report.md) 한국어 vs 영어 파이프라인 토큰 비교 | L-01: 전 파이프라인 영어 진행이 한국어 대비 billable 토큰을 유의미하게 줄인다 | **보류** |
| [EXP-003](experiments/003-pte-skills/report.md) PTE + 스킬식 점진 공개 | S-02: 컨텍스트를 스킬 공식 권고(문서 200줄 이하, 스킬로 필요한 것만 로드)로 구조화하면 EXP-001 PTE 대비 billable 30% 이상 감소 | **검증** |
| [EXP-004](experiments/004-ralph-skills/report.md) Ralph loop + 스킬 구조 | S-03: 단일 세션 ralph에 도메인 계약 스킬을 제공하면 billable이 감소한다 | **보류 (사실상 효과 없음)** |
| [EXP-005](experiments/005-solar-pro3-backend/report.md) Claude Code × Upstage Solar Pro 3 백엔드 | M-01: Claude Code의 백엔드를 Solar Pro 3로 교체하면 동일 과제(RealWorld 백엔드)를 무개입 완주할 수 있고, 완주 시 총비용이 Opus 대비 유의미하게 낮다. | **보류** |
| [EXP-006](experiments/006-solar-open2-backend/report.md) Claude Code × Upstage Solar Open 2 백엔드 | M-02: Claude Code의 백엔드를 Solar Open 2로 교체하면 동일 과제(RealWorld 백엔드)를 무개입 완주할 수 있고, 완주 시 총비용이 Opus 대비 유의미하게 낮다. | **보류** |
| [EXP-007](experiments/007-solar-open2-autopsy/report.md) Solar Open 2 미완주 원인 부검 | M-03: EXP-006(Solar Open 2) 미완주는 수렴 속도 단일 병목이 아니라 복수 실패 요인(모델 행동 결함 · 실험 환경 오염 · 계측 왜곡)의 중첩이다. | **검증** |
| [EXP-008](experiments/008-solar-open2-clean-run/report.md) Solar Open 2 무오염 클린 run — 완주 검증 | M-04: 오염 제거(격리 설정)·무교란·상한 30 iter 조건에서 solar-open2는 랄프 루프로 RealWorld 백엔드(Hurl 154/154)를 무개입 완주할 수 있다 (과금 배제, 완주 여부 단일 판정). | **검증** |
| [EXP-009](experiments/009-opus5-ralph-en/report.md) Opus 5 랄프 루프 (EXP-002 en 조건, n=3) | M-05: Opus 5는 EXP-002 en 조건의 랄프 루프에서 단일 세션 완주를 재현하고, Opus 4.x 기준선(en 6–7분·API 38–54회) 대비 동등 이상의 효율을 보인다. | **부분 검증 (n=3)** |
| [EXP-010](experiments/010-opus48-vs-opus5/report.md) Opus 4.8 vs Opus 5 순수 A/B (동일 시점, 각 n=3) | M-06: 완전 동일 조건에서 Opus 5의 산출량 확대 프로파일(output·커밋 ↑)이 Opus 4.8 대비 재현되고 양 모델 모두 단일 세션 완주를 유지한다. | **검증** |
| [EXP-011](experiments/011-codex-gpt56-sol/report.md) Codex CLI × gpt-5.6-sol 리얼월드 백엔드 완주 검증 | M-07: Codex CLI(`codex exec`) 하네스에서 gpt-5.6-sol(effort medium)은 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-012](experiments/012-ccr-gpt56-sol/report.md) Claude Code × gpt-5.6-sol 백엔드(ccr) 리얼월드 백엔드 완주 검증 | M-08: Claude Code 백엔드를 ccr로 gpt-5.6-sol에 연결하면(reasoning effort medium) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-013](experiments/013-qwen38max-direct/report.md) Claude Code × qwen3.8-max 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증 | M-09: Claude Code를 DashScope Anthropic 호환 엔드포인트로 qwen3.8-max에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-014](experiments/014-kimi-k3-direct/report.md) Claude Code × kimi-k3 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증 | M-10: Claude Code를 Moonshot Anthropic 호환 엔드포인트로 kimi-k3에 직결하면(thinking 기본값) 격리·무개입 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-015](experiments/015-solar-open2-direct/report.md) Claude Code × solar-open2 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증 | M-11: Claude Code를 Upstage Anthropic 호환 엔드포인트로 solar-open2에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-016](experiments/016-n3-replication/report.md) n=1 완주 조건 3종의 재현성 확충 (각 n=3) | M-12: EXP-011/013/014 세 조건(Codex CLI × gpt-5.6-sol, qwen3.8-max 직결, kimi-k3 직결)의 무개입 완주는 재현된다: 각 조건 추가 2 run(총 n=3)이 모두 상한 30 iteration 안에 게이트+독립 재검증 일치로 완주한다. | **검증** |
| [EXP-017](experiments/017-ko-condition/report.md) qwen3.8-max·kimi-k3 한국어 조건 랄프 루프 완주 검증 (각 n=3) | L-02: qwen3.8-max·kimi-k3(직결, thinking 기본값)는 한국어 정본 프롬프트(전 산출물 한국어 지시 포함) 조건에서도 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-018](experiments/018-solar-n3-replication/report.md) solar-open2 직결 재현성 확충 — 제공자 엔드포인트 회수로 재현 불가 | M-13: EXP-015의 solar-open2 직결 무개입 완주는 재현된다: 추가 2 run(총 n=3) 전부 30 iteration 안에 게이트(measure v4)+재검증 완주할 수 있다. | **보류** |
| [EXP-019](experiments/019-ko-native-codex/report.md) 네이티브 Opus 4.8·Opus 5·Codex×gpt-5.6-sol 한국어 조건 완주 검증 (각 n=3) | L-03: 네이티브 Opus 4.8·Opus 5(Claude Code)와 gpt-5.6-sol(Codex CLI)은 한국어 정본 프롬프트(전 산출물 한국어 지시 포함) 조건에서도 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 iteration 안에 무개입 완주할 수 있다. | **검증** |
| [EXP-020](experiments/020-solar-pro4-direct/report.md) Claude Code × solar-pro4 직결 완주 검증 (n=3) | M-14: Claude Code를 Upstage Anthropic 호환 엔드포인트로 solar-pro4에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다 (n=3, 완주율 판정·과금 배제). | **검증** |

**EXP-001 — Ralph loop vs Plan-then-execute** (기각 (반증))  
plan-then-execute가 billable 기준 **약 8.7배 더 많은** 토큰을 사용 → [보고서](experiments/001-ralph-vs-plan-then-execute/report.md)

**EXP-002 — 한국어 vs 영어 파이프라인 토큰 비교** (보류)  
사전 등록한 판정 규칙(|KO평균−EN평균| > 조건 내 run 간 변동폭)을 충족하지 못함. 언어 효과(평균 차 29K)가 run 간 궤적 변동(최대 138K)에 묻힘 → [보고서](experiments/002-korean-vs-english/report.md)

**EXP-003 — PTE + 스킬식 점진 공개** (검증)  
**39.3% 감소** (2,839,815 → 1,723,575). 워크플로는 동일하고 컨텍스트 구조만 바꿨다. → [보고서](experiments/003-pte-skills/report.md)

**EXP-004 — Ralph loop + 스킬 구조** (보류 (사실상 효과 없음))  
평균 차 +3.5%(방향은 가설 반대)가 조건 내 변동폭(200K)에 완전히 묻힘 → [보고서](experiments/004-ralph-skills/report.md)

**EXP-005 — Claude Code × Upstage Solar Pro 3 백엔드** (보류)  
solar-1 미완주(테스트 실행 0회·커밋 0회, 6/15 iteration 시점 조기 중단): 연동 스택은 검증됐으나 headless 자율 루프에서 허락-대기·컨텍스트 초과 실패 모드가 반복되어 완주 궤도에 오르지 못함. → [보고서](experiments/005-solar-pro3-backend/report.md)

**EXP-006 — Claude Code × Upstage Solar Open 2 백엔드** (보류)  
0/2 완주이나 완전 프로토콜 run은 1회뿐(open2-1은 1 iter 만에 허위 완료 신고로 자체 종료): open2-2는 15 iteration을 소진하고도 독립 검증 3/13 파일(94/154 요청)에 그쳤지만, solar-pro3에서 부재했던 자율 TDD 루프를 확립하고 단조 수렴해 "행동 계층" 병목이 자율성에서 수렴 속도로 이동했다. → [보고서](experiments/006-solar-open2-backend/report.md)

**EXP-007 — Solar Open 2 미완주 원인 부검** (검증)  
3계층 실증: ① 계측 왜곡(usage 3.07배 과대 계상 — 실제 483요청·23.3M input, 추정 ~$3.8로 Opus $6.41보다 낮음), ② 환경 오염(superpowers 훅·글로벌 CLAUDE.md 주입으로 최소 3 iteration 잠식), ③ 모델 행동 결함(선언-실행 탈락으로 커밋 0회, thinking-only 잘림 25회, 과제 이탈 환각 2건). → [보고서](experiments/007-solar-open2-autopsy/report.md)

**EXP-008 — Solar Open 2 무오염 클린 run — 완주 검증** (검증)  
**iteration 10/30에서 완주**: `.ralph-done` 생성 → 하네스 게이트 13/13 파일·154/154 요청 통과 → 실험자 독립 재검증 2회 일치. wall-clock 약 2시간 53분, 무개입·무중단, git 커밋 4회(한국어)까지 이행. 완주 시점이 EXP-006의 상한(15) 안쪽이므로 결정 변수는 상한 증가가 아니라 **환경 오염 제거·무교란**이었다. → [보고서](experiments/008-solar-open2-clean-run/report.md)

**EXP-009 — Opus 5 랄프 루프 (EXP-002 en 조건, n=3)** (부분 검증 (n=3))  
완주 조항 검증: **3/3 run 모두 iteration 1 단일 세션 완주**(9분03초–12분22초, 게이트 13/13·154/154 + 독립 재검증 각 2회, 커밋 6–7개). 효율 조항 미충족 확정: 시간 분포(8.9–12.2분)가 4.x(5.8–6.9분)와 비겹침 — 단 원인은 서빙 속도가 아니라 **일관된 산출량 증가(+62%)를 동반한 행동 프로파일 변화**로 판별됨. → [보고서](experiments/009-opus5-ralph-en/report.md)

**EXP-010 — Opus 4.8 vs Opus 5 순수 A/B (동일 시점, 각 n=3)** (검증)  
완주 6/6 (전 run iteration 1, 게이트 13/13·154/154). 사전 등록 지표 모두 충족: **output 토큰 분포 비겹침**(4.8: 29.6–37.1K vs 5: 41.1–47.9K, +37% 평균) · **git 커밋 분포 비겹침**(1–2개 vs 4–8개), 방향 EXP-009와 동일(5 > 4.8). 세대 차는 시점·계측 아티팩트가 아닌 실재 프로파일로 확정. → [보고서](experiments/010-opus48-vs-opus5/report.md)

**EXP-011 — Codex CLI × gpt-5.6-sol 리얼월드 백엔드 완주 검증** (검증)  
**iteration 1에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, codex exec 5분 46초·세션 1개·커밋 3회, 무개입). → [보고서](experiments/011-codex-gpt56-sol/report.md)

**EXP-012 — Claude Code × gpt-5.6-sol 백엔드(ccr) 리얼월드 백엔드 완주 검증** (검증)  
**iteration 11/30에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, 총 58분·커밋 11회). 단 iteration 2에서 스트림 스톨 1건에 하네스 수준 개입(프로세스 종료로 iteration 경계 복구, 모델 산출물 불개입)이 있었다 — 아래 프로토콜 이슈 참조. → [보고서](experiments/012-ccr-gpt56-sol/report.md)

**EXP-013 — Claude Code × qwen3.8-max 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증** (검증)  
**iteration 1에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, 15분 5초·커밋 4회·개입 0, 직결 스택 트러블슈팅 0건). → [보고서](experiments/013-qwen38max-direct/report.md)

**EXP-014 — Claude Code × kimi-k3 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증** (검증)  
**iteration 1에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, 21분 18초·커밋 4회·개입 0, 직결 스택 트러블슈팅 0건). → [보고서](experiments/014-kimi-k3-direct/report.md)

**EXP-015 — Claude Code × solar-open2 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증** (검증)  
**iteration 2에서 완주** (산출물 직접 재채점 2회 모두 13/13·154/154 일치, 58분 15초·커밋 2회. 각주: 게이트 오검 1건 — measure v3 포트 탐지 결함으로 정당 완주를 기각, EXP-010 48-1 선례 적용). → [보고서](experiments/015-solar-open2-direct/report.md)

**EXP-016 — n=1 완주 조건 3종의 재현성 확충 (각 n=3)** (검증)  
**추가 6 run 전부 완주** (게이트 pass + 독립 재검증 각 2회 13/13·154/154 일치, 개입 0). 원 run 포함 세 조건 완주율 **각 3/3, 합산 9/9**. → [보고서](experiments/016-n3-replication/report.md)

**EXP-017 — qwen3.8-max·kimi-k3 한국어 조건 랄프 루프 완주 검증 (각 n=3)** (검증)  
**6/6 run 전부 iteration 1 완주** (게이트 pass + 독립 재검증 각 2회 13/13·154/154 일치, 개입 0). 언어 준수도 성립: 전 run의 커밋 메시지·README가 한국어. → [보고서](experiments/017-ko-condition/report.md)

**EXP-018 — solar-open2 직결 재현성 확충 — 제공자 엔드포인트 회수로 재현 불가** (보류)  
모델 외적 장애(사전 등록 기준): 실험 개시 시점에 Upstage가 Anthropic 호환 엔드포인트(`/v1/messages`)와 solar-open2 hosted API를 회수해 run 자체가 불가능. 가설은 기각이 아니라 **검증 불가**. → [보고서](experiments/018-solar-n3-replication/report.md)

**EXP-019 — 네이티브 Opus 4.8·Opus 5·Codex×gpt-5.6-sol 한국어 조건 완주 검증 (각 n=3)** (검증)  
**9/9 run 전부 iteration 1 완주** (게이트 pass + 독립 재검증 각 2회 13/13·154/154 일치, 개입 0). 언어 준수도 전수 성립: 9 run 모두 커밋 메시지·README 한국어 (영어권 모델 gpt-5.6-sol 포함). → [보고서](experiments/019-ko-native-codex/report.md)

**EXP-020 — Claude Code × solar-pro4 직결 완주 검증 (n=3)** (검증)  
**3/3 완주** (게이트 pass + 독립 재검증 각 2회 13/13·154/154 일치, 모델 개입 0). 단 pro4-1은 게이트 오검(하네스 귀책)으로 루프가 연장됨 — 소급 재채점으로 유효 완주 iter 3 확정. → [보고서](experiments/020-solar-pro4-direct/report.md)

<!-- RESULTS:END -->

### 종합 인사이트 (실험이 쌓일 때마다 갱신)

네 실험(RealWorld 백엔드, Opus 고정)을 관통하는 결론:

1. **토큰 비용의 지배 변수는 컨텍스트(캐시) 재사용이다.** 단일 세션 ralph(약 290K)는 한 번 만든 컨텍스트를 끝까지 재활용한다 — 기술적 배경(prefix 기반 프롬프트 캐싱, 0.1배 cache read, 달러 환산 재계산)은 [docs/context-reuse-mechanism.md](docs/context-reuse-mechanism.md) 참조. 세션을 나누는 순간 기동 고정비(세션당 약 20.6K)와 컨텍스트 재구축 비용이 누적되어 같은 과제가 6–9배 비싸진다 (EXP-001).
2. **점진 공개(스킬)는 멀티 세션 전용 처방이다.** 세션이 전체 컨텍스트의 부분집합만 필요할 때(PTE 태스크 세션) 반복 읽기와 수정 루프를 없애 -39.3% (EXP-003). 반면 전체가 필요한 단일 세션은 스킬을 전량 선로딩해 효과가 없다 (EXP-004).
3. **에이전트의 작업 궤적 변동은 ±수십만 토큰의 상수 노이즈다.** 동일 조건의 run이 2배까지 벌어진다 (EXP-002 EN 191K–329K, EXP-004 199K–400K). 약 10% 수준의 효과(예: 언어)는 n=2로 판별 불가.
4. **실용 지침**: 과제가 단일 세션에 들어가면 단일 세션으로 돌려라. 분할이 불가피하면 컨텍스트를 스킬로 구조화해 손실을 줄여라. 문서 언어(한/영)는 이 두 결정보다 훨씬 작은 변수다.
5. **"모델이 완주 못 한다"의 지배 요인은 실험 환경 오염이었다 (M축, EXP-005–008).** Solar 백엔드 4부작의 서사: EXP-005(자율성 부재로 미완주) → EXP-006(TDD 확립했으나 3/13 미완주) → EXP-007(부검: usage 3.07배 과대 계상 착시 + superpowers 훅·글로벌 CLAUDE.md 오염이 iteration 23% 잠식 + 모델 결함) → **EXP-008(오염 제거 클린 run에서 iteration 10 만에 13/13·154/154 완주, 커밋 4회까지 이행)**. 동일 모델·동일 PROMPT·동일 env에서 격리 하나로 판정이 뒤집혔고, 완주 시점이 EXP-006 상한 안쪽이라 상한 증가는 기여하지 않았다. 교훈 셋: (a) **자율 루프 실험에서 실험자 로컬 환경(훅·전역 설정) 격리는 전제 조건**이다 — 이를 어기면 "모델 능력" 측정이 "오염 순응도" 측정이 된다. (b) 완주 실패의 원인은 로그 부검 없이 모델 귀책으로 단정하지 마라 — 변환 계층 결함(CCR 멀티 델타 버그)·계측 오류(usage 행 합산, message.id dedup 필수)·환경 오염, 그리고 **채점 게이트 자체의 오검**(EXP-010 48-1 채점 파일 미복사, EXP-015 iter 2 포트 탐지 결함 — measure v4로 수정)일 수 있다. (c) 모델 내재 결함(허락-대기 1회, thinking 94%, 회차 경계 실행 불가 상태)은 잔존해도 랄프 루프의 반복 구조가 흡수 가능하다. 비용 우위 판정은 여전히 단가 미공개로 불능.
6. **랄프 루프 프로토콜은 하네스 독립적으로 이식되고, 완주는 모델·궤적은 하네스가 결정했다 (EXP-011/012 쌍).** 동일 PROMPT·게이트·모델(gpt-5.6-sol, effort medium)로 하네스만 바꾼 쌍 실험에서 둘 다 무개입 완주 — Codex CLI는 iteration 1·5분 46초·단일 파일 436줄·커밋 3회, Claude Code(ccr 경유)는 iteration 11·58분·모듈형 11파일·커밋 11회. "가장 중요한 한 조각" 지시를 Codex는 완주까지로, Claude Code 쪽은 문자 그대로 한 조각으로 해석해 소형 iteration을 랄프 루프가 흡수했다. 격리 원칙(전용 CODEX_HOME/CLAUDE_CONFIG_DIR)과 iteration별 외부 채점 게이트는 도구를 가리지 않고 성립. 도구 간 토큰 효율 비교는 계측 방식(rollout 누계 vs ccr 탭 vs ccusage) 표준화가 선행 과제다.
7. **서드파티 모델 연결은 변환 계층(ccr)보다 Anthropic 호환 엔드포인트 직결이 구조적으로 우월하고, 직결 템플릿은 제공자를 넘어 재사용된다 (EXP-013/014).** qwen3.8-max(DashScope)와 kimi-k3(Moonshot)를 `ANTHROPIC_BASE_URL` 직결로 연결하자 ccr 스택에서 반복된 실패 모드(usage 유실→별도 탭 구축, transformer 체인 조정, 스트림 스톨)가 전부 소멸 — 두 실험 모두 Phase 0 무조정 통과·iteration 1 완주(15분 5초 / 21분 18초)·세션 jsonl usage 정상. EXP-014는 EXP-013 하네스에서 env 3요소(엔드포인트/키/모델 ID)만 치환해 그대로 동작 — 방법이 제공자 독립적. 직결은 계측도 Claude 표준 경로(jsonl + message.id dedup)로 회귀시켜 6번의 표준화 선행 과제를 부분 해소하나, 캐시 계상 방식은 제공자별로 다르다(Moonshot은 cache_create 0 계상). ccr 대비 비교는 모델이 달라 스택·모델 효과 교락 — 제공자가 Anthropic 호환 엔드포인트를 제공하면 직결을 기본 선택지로 삼되, 스택 간 정량 비교는 동일 모델 실험이 필요하다. **재현성은 n=3으로 확정 (EXP-016)**: Codex×gpt-5.6-sol·qwen 직결·kimi 직결 세 조건 각 3/3 완주(합산 9/9, 8/9가 iter 1) — 단 완주 외 지표(시간·커밋·output)는 같은 조건에서도 최대 3배 변동(kimi 21분→7분대)해, S축의 "궤적 변동은 상수 노이즈" 결론이 M축에서도 성립. 완주율만이 안정된 지표다. **한국어 조건도 완주율을 훼손하지 않는다 (EXP-017/019)**: 한국어 정본(전 산출물 한국어 지시)에서 qwen·kimi·Opus 4.8·Opus 5·Codex×gpt-5.6-sol 5개 조건 각 3/3, **누적 15/15 iter 1 완주**, 커밋·README 전수 한국어·언어 이탈 0 — 영어권 모델(gpt-5.6-sol)까지 준수해 한국어 이행은 모델 계열이 아닌 지시 이행의 문제로 판명. 시간·커밋·output도 EXP-019 3조건 전부 EN 분포와 겹침 — qwen의 ko +48% 시간(EXP-017)은 예외 사례이며 방향성 기록으로만 남긴다(L-01 원칙). 모델 프로파일(4.8 단일 커밋 vs 5 잘게 이행)은 언어 반전 후에도 유지. **단 직결 재현성은 제공자에 종속된다 (EXP-018)**: EXP-015 완주 하루 뒤 Upstage가 Anthropic 호환 엔드포인트와 solar-open2 hosted API를 공지 없이 회수(신청제 베타 종료)해 재현 창이 닫혔다 — 서드파티 벤치마크는 실험 시점 명기가 재현성 주장의 한계를 규정하며, 하네스 재사용 전 제공자 스모크가 필수다. 2주 뒤 엔드포인트가 solar-pro4로 복구되어 직결 3/3 완주를 확인(EXP-020) — 완주 능력은 직결 상위권과 동급이나 유효 시간 119–258분(qwen의 8–17배)의 최장 프로파일로, 원인은 캐시 미지원(전 호출 cache 0, 매 호출 ~8만 토큰 재프리필)·왕복 37초·thinking 88%의 곱. **주의: solar-open2·solar-pro4 엔드포인트는 상용 제공(GA) API가 아닌 프리뷰(신청제 베타) 상태**로 인프라 제약(prompt caching 미지원, 긴 왕복 지연, 예고 없는 엔드포인트 회수)이 상시 걸려 있어, Solar 계열의 시간·usage 프로파일은 모델 능력과 프리뷰 인프라 특성이 교락된 값이다 — 상용 인프라 기준 성능으로 읽지 말 것. 게이트 오검 3번째 사례(글로벌 npm 오염이 hurl 바이너리를 가림)로 **채점 바이너리 절대 경로 고정** 교훈 추가.

## 실험 라이프사이클

1. `templates/experiment-readme.md`를 복사해 `experiments/NNN-이름/README.md`에 실험 설계 작성 (가설, 조건, 측정 방법, 성공 기준)
2. 조건별로 세션 수행, 세션 로그·측정 결과를 `runs/<조건명>/`에 저장
3. `report.md`에 토큰 차이 분석과 결론 작성 — 헤더에 `- 가설: [코드](...) — ...`와 `- **판정: ...** — <핵심 요약>` 형식을 지킨다 (README 자동 생성이 이 두 줄을 파싱)
4. `hypotheses/catalog.md`의 상태 갱신 (미실험 → 진행중 → 검증/기각)
5. `report.md` 커밋 시 pre-commit 훅이 README 실험 결과 섹션을 자동 갱신한다. 새로 클론했다면 최초 1회 `git config core.hooksPath hooks` 실행 (수동 갱신: `python3 scripts/update_readme_results.py`)

## 디렉토리 구조

```
├── ideation.md            # 최초 아이디에이션 (원본 유지)
├── ROADMAP.md             # 단계별 로드맵
├── hypotheses/catalog.md  # 가설 카탈로그 + 실험 상태 표
├── experiments/           # 실험 단위 디렉토리 (NNN-이름/)
│   └── 001-ralph-vs-plan-then-execute/
├── tasks/                 # 공통 과제 스펙 (조건 간 재사용)
│   └── realworld-backend/
├── templates/             # 실험 설계·보고서 템플릿
├── scripts/               # 측정·집계 래퍼 스크립트
└── docs/specs/            # 설계 문서
```
