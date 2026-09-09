# EXP-021 설계: Codex CLI × gpt-6-astra 랄프 루프 완주 검증 (n=3)

## 배경

OpenAI가 2026-09 초 GPT-6 세대 첫 모델 **gpt-6-astra**를 출시했다. 사전 조사(2026-09-10) 결과:

- GPT-6 계열은 현재 `gpt-6-astra` 단일 모델 — mini/codex 등 변형 없음. 코딩 적합 옵션 = gpt-6-astra 자체 (OpenAI가 "agentic execution·Codex 장기 세션 코딩"용으로 공식 포지셔닝, Terminal-Bench 4.0 57.7% vs gpt-5.6-sol 37.3%)
- 스펙: 입력 $10 / 출력 $50 per 1M, 컨텍스트 1.05M, reasoning effort 5단계(low–max), cutoff 2026-04-30
- OpenAI는 Anthropic 호환 `/v1/messages` 엔드포인트 미제공 → 리포 규칙(변환 계층 금지)상 Claude Code 직결 불가, **Codex CLI 하네스(EXP-011 방식)가 유일한 정합 경로**
- Codex CLI rust-v0.153.4(로컬 설치 버전과 일치)부터 gpt-6-astra 지원

## 가설

[M-15](../../hypotheses/catalog.md) — Codex CLI(`codex exec`) 하네스에서 gpt-6-astra(effort medium)는 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iter 안에 무개입 완주할 수 있다 (n=3, 완주율 판정·과금 배제).

## 조건 (사전 고정)

- **PROMPT**: EN 정본 byte-identical (md5 `2c28ea6b7f16125d9b3105f5ee00b126`, EXP-011과 동일)
- **하네스**: EXP-011/016/019 Codex driver 이식 — 치환은 모델 ID 1요소(`gpt-6-astra`)만
  - effort **medium** 고정 — Astra는 5단계(low–max)를 지원하나 M-07(sol, medium) 기준선과의 하네스 동등성을 우선. effort 축 비교는 후속 실험 후보로 남긴다
  - 전용 CODEX_HOME(`~/ralph-exp021/codex-home`) — auth.json + config.toml만으로 신규 구성(세션·캐시 무잔재)
  - 상한 30 iter, `--sandbox danger-full-access`, 개입 금지
- **채점**: measure v4 게이트 + 완료 후 독립 재검증 2회. **hurl은 절대 경로(`/opt/homebrew/bin/hurl`) 고정** — EXP-020 게이트 오검(@hurl/cli shim이 Hurl 가림) 재발 방지
- **실행**: 순차 3 run (astra-1 → astra-2 → astra-3), run별 세션 격리 이동(`codex-sessions-<run>`) 후 rollout 누계로 usage 계측. 동시 실행 금지
- **판정 기준 (사전 등록)**: 검증(3/3 완주) / 부분 검증(1–2/3 — run별 사실 보고) / run 단위 보류(모델 외적 장애)
- **과금 배제**: 완주율 단일 판정. usage는 기록만 (예상 규모: EXP-011 sol run당 ~1.2M tokens → Astra 단가로 run당 약 $3, iter 수 비례 증가 가능)

## 리스크

- gpt-6-astra는 출시 직후 모델 — 서빙 불안정(스톨·5xx) 발생 시 iteration 로그에 기록하고 루프 자체 복원력으로 흡수 (EXP-012 선례), run 단위 장애만 보류 처리
- 신규 세대 모델의 산출량 프로파일 변화 가능(EXP-009/010 Opus 5 선례) — 완주 판정에는 영향 없음, usage 기록으로 관찰
- 1.05M 컨텍스트로 EXP-005류 컨텍스트 초과 크래시 리스크는 낮음

## Phase 0 (기동 전 스모크)

- 전용 CODEX_HOME에서 `codex exec --model gpt-6-astra`로 SMOKE-OK 정확 출력 확인 (모델 ID 유효성 + 인증 게이트)
- 스모크 세션은 본 계측에서 제외(sessions 초기화 후 기동)

## 후속

- 완주 시 대시보드 아티팩트(랄프 루프 모델별 완주 비교, `137de971-…`)에 astra 조건 추가 — 기존 URL 재배포
- README 실험 결과 재생성(`scripts/update_readme_results.py`), catalog·ROADMAP 갱신
