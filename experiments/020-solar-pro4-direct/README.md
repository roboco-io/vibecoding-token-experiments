# EXP-020 설계: Claude Code × solar-pro4 직결 완주 검증 (n=3)

## 배경

Upstage가 2026-08-05 solar-open2 hosted API와 Anthropic 호환 경로를 회수(EXP-018 보류)한 뒤, 2026-08-19 실측에서 `/v1/messages`가 복구되고 공식 스크립트 기본 모델이 **solar-pro4**로 이관된 것을 확인했다. 본 실험은 solar-pro4 직결의 무개입 완주를 n=3으로 검증한다 — EXP-013/014(직결 완주 검증)와 동형이며, 처음부터 n=3으로 실행(EXP-016 교훈).

## 가설

[M-14](../../hypotheses/catalog.md) — Claude Code를 Upstage Anthropic 호환 엔드포인트로 solar-pro4에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다 (n=3, 완주율 판정·과금 배제).

## 조건 (사전 고정)

- **하네스**: EXP-015 driver 이식 — env에서 모델 ID만 `solar-open2`→`solar-pro4` 치환, RUN 인자화. `ANTHROPIC_BASE_URL=https://api.upstage.ai` + Bearer(`x-api-key` 401 재확인)
- **PROMPT**: EXP-010 영문 정본 byte-identical (md5 `2c28ea…`)
- **격리**: 전용 `CLAUDE_CONFIG_DIR`(EXP-015 사본, projects 제외) · 독립 빈 git repo · `env -u ANTHROPIC_API_KEY`
- **채점**: measure v4 게이트 + 완료 후 독립 재검증 2회. 실행: 순차 3 run(pro4-1..3), run별 세션 격리(message.id dedup)
- **판정 기준 (사전 등록)**: 검증(3/3 완주) / 부분 검증(1–2/3 — run별 사유 보고) / run 단위 보류(모델 외적 장애)
- **선행 게이트 통과 (2026-08-19)**: `/v1/messages` 스모크 200(Anthropic 형식·usage 정상, 모델 `solar-pro4-260806`), Claude Code 직결 스모크 `SMOKE-OK`, 공식 스크립트 `DEFAULT_MODEL=solar-pro4` 확인
- **Phase 0 하네스 조정 (iteration 1 완료 전, 사전 등록)**: 현 Claude Code 버전이 미인식 모델에 200k 창 가정·auto-compact 강제를 신규 도입한 것을 첫 기동에서 확인 — EXP-013/014/015 직결은 모두 이 강제가 없던 구버전 동작이므로, 동형성을 위해 `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1`(구동작 복원)을 driver env에 추가하고 완주 데이터 없이 재기동. 부분 산출물은 폐기

## 실행 중 게이트 오검 사건 (2026-08-19, pro4-1 iter 1–11)

- **증상**: pro4-1 iter 3~11의 `.ralph-done` 신고 9건이 전부 `hurl 0,0`으로 기각됨.
- **원인**: 2026-08-08 npm 글로벌에 설치된 무관 패키지 `@hurl/cli@1.0.5`가 asdf shim `~/.asdf/shims/hurl`을 생성, 진짜 Hurl 8.0.1(`/opt/homebrew/bin/hurl`)을 PATH에서 가림. measure.sh가 `hurl`을 상대 호출해 "Unknown arguments" 실패 → 항상 0,0. 서버 기동·포트 탐지는 정상이었음(v4 로직 무결).
- **조치**: iter 12 진행 중 measure.sh에 `HURL_BIN=/opt/homebrew/bin/hurl` 절대 경로 고정 + BASE 경로 오기(ralph-exp015 → ralph-exp020, 채점 파일은 md5 동일해 영향 없음) 수정. **모델 환경은 무개입 유지** — 수정은 채점기만.
- **판정 영향**: iter 3~11 기각은 하네스 귀책. 완료 후 iter 3 시점 HEAD를 소급 재채점해 최초 유효 완주 iteration을 확정하고, 하네스 개입(.ralph-done 9회 삭제)이 루프를 연장시킨 사실을 보고서에 명기한다. EXP-015 게이트 오검(v4 수정)에 이은 두 번째 채점기 결함 사례.

## 리스크

- solar 계열은 완주 시간이 길었다(open2 58분) — pro4는 미지, run당 상한 30 iter 내 관찰만
- EXP-015 iter 1의 tool call 텍스트 유출 같은 형식 이탈 재발 가능 — 개입 없이 기록
- 제공자 재회수 리스크 — 본 실험 자체가 시점 기록(EXP-018 교훈: 시점 명기가 재현성 주장의 한계를 규정)

## 후속

- 완주 시 대시보드에 solar-pro4 직결 조건 추가, Solar Open 2(n=1·단종) 행과 병기
