# EXP-018 설계: solar-open2 직결 재현성 확충 (n=3)

## 배경

EXP-015(Claude Code × solar-open2 직결)는 iteration 2 완주였으나 n=1이라 재현성(완주율) 서사가 불가능했다. EXP-016이 EXP-011/013/014를 각 n=3으로 확충한 것과 동일한 방식으로, solar-open2 직결 조건에 **run 2·3을 추가해 n=3**을 만들고 완주율을 판정한다. 원 실험(EXP-015) report는 수정하지 않는다 — 확충 판정은 본 실험이 담당한다.

## 가설

[M-13](../../hypotheses/catalog.md) — EXP-015의 solar-open2 직결 무개입 완주는 재현된다: 추가 2 run(총 n=3)이 모두 상한 30 iteration 안에 게이트(Hurl 13/13·154/154)+독립 재검증 일치로 완주한다. (과금 배제 — 완주율 단일 판정)

## 조건 (사전 고정)

- **원 실험과 동일**: 하네스 베이스(`~/ralph-exp015`)·driver(RUN명만 sed 치환)·PROMPT(EXP-010 정본 byte-identical)·env(Upstage 직결 Bearer, thinking 기본값)·격리(`CLAUDE_CONFIG_DIR` 전용)·상한 30 iter 그대로
- **measure v4 상시 적용**: EXP-015의 오검(v3 포트 탐지)이 수정된 v4가 게이트를 담당 — 본 실험은 v4 게이트가 solar의 `npx tsx` 서빙 패턴을 정상 채점하는지의 실전 검증도 겸한다 (EXP-016·017 12 run 무오검 이력 위에 추가)
- **실행 방식**: 순차 2 run (solar-2 → solar-3), 동시 실행 금지 (포트 충돌·자원 경합 방지)
- **run별 usage 분리**: solar-1 세션은 시작 전 `claude-config-projects-solar-1`로 격리 완료, 각 run 종료 시 세션 디렉토리를 run별 격리 이동 후 파싱 (message.id dedup)
- **판정 기준 (사전 등록)**: 검증(추가 2 run 전부 완주 — 완주율 3/3) / 부분 검증(1/2 완주 — run별 사유 보고) / run 단위 보류(모델 외적 장애 — 재실행 없이 사유 기록)
- **계측**: run별 wall-clock·iteration·커밋·usage(jsonl). 완주율과 조건 내 분포만 보고 — 효율 서사 금지 (기존 원칙)

## 리스크

- solar-open2는 검증된 4개 모델 중 가장 느리다(EXP-015 58분, EXP-008 클린 run은 iter 10 완주) — run당 1–3시간, 총 2–6시간 예상. 오케스트레이터 로그로 추적, run 사이 개입 금지
- EXP-015 iter 1에서 관찰된 tool call 텍스트 유출(pseudo-XML)이 재발할 수 있음 — 루프 흡수 여부를 그대로 기록 (개입 금지)
- 원 실험과 시점 차이(1일) — 서빙 변동이 섞일 수 있음, 시점 명기로 관리

## 후속

- 완주율 확보 시 README 종합 인사이트의 직결 서사(현재 25/25)를 갱신하고 아티팩트 대시보드에 solar n=3 분포 반영
