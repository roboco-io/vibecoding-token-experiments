# EXP-015 결과 보고: Claude Code × solar-open2 직결(ANTHROPIC_BASE_URL) 리얼월드 백엔드 완주 검증

- 실험일: 2026-08-04 (06:16–07:14 KST 본 실행, 07:16 사용자 중단, 07:2x 오검 판별·재채점)
- 가설: [M-11](../../hypotheses/catalog.md) — Claude Code를 Upstage Anthropic 호환 엔드포인트로 solar-open2에 직결하면(thinking 기본값) 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다.
- **판정: 검증** — **iteration 2에서 완주** (산출물 직접 재채점 2회 모두 13/13·154/154 일치, 58분 15초·커밋 2회. 각주: 게이트 오검 1건 — measure v3 포트 탐지 결함으로 정당 완주를 기각, EXP-010 48-1 선례 적용).

## 결과

| run | 완주 | wall-clock | input (비캐시) | cache | output | git 커밋 |
|-----|------|-----------|----------------|-------|--------|----------|
| solar-1 | iter 2/30 | 58분 15초 | 32.7M† | 미계상† | 252.3K | 2 |

- metrics: `1,…,0,0,0,na` / `2,…,0,0,1,rejected` — iter 2에서 claim 1회, **게이트 기각은 오검**(하단)
- 재채점: measure **v4**(포트 탐지 수정)로 iteration 2 산출물 직접 채점 2회 → 두 번 모두 `13,154`
- † Upstage Anthropic 경로는 usage에 cache 필드를 계상하지 않아(0/0) input 전량이 비캐시로 잡힘 — 제공자별 캐시 계상 차이(설계·phase0 등록), 타 실험과 usage 직접 비교 금지

## 프로토콜 이슈 (판정의 핵심 맥락)

1. **게이트 오검 (measure v3 결함)**: iteration 2에서 모델은 전 스위트 자가 검증(154/154) 후 커밋·`.ralph-done` 신고를 완료했으나, 게이트가 `0,0`으로 기각. 원인은 앱이 서버를 `npx tsx src/server.ts`로 실행 → npx가 tsx를 **글로벌 npx 캐시**에서 해석하고 스크립트 경로도 상대경로라, 리스닝 프로세스 command line에 리포 경로가 없어 v3의 "command 경로 grep" 소속 판정이 영구 실패. **v4에서 프로세스 CWD 판정을 추가**해 수정, 전 하네스(exp011/013/014/015)에 전파. EXP-013/014는 앱이 로컬 node_modules 경로로 서버를 실행해 우연히 미발현이었을 뿐 동일 결함에 노출되어 있었다.
2. **사용자 중단**: 오검 기각 후 iteration 3 진입 직후(1분) 원인 분석을 위해 중단. 중단은 완주 시점(iteration 2) **이후** 구간이므로 완주 판정에 영향 없음 — 무개입 조항은 iteration 2까지 유지됨.
3. **iteration 1 이상 종료**: 세션 말미에 모델이 tool call을 실제 tool_use 블록이 아닌 **텍스트로 출력**(`<function=Read>…`, `</tool_call>`, `</hint>` 등 의사 마크업 유출) 후 종료 — Upstage Anthropic 변환 또는 모델의 tool call 형식 이탈로 추정. 랄프 루프의 iteration 경계가 이를 흡수했고 iteration 2에서 정상 복귀(EXP-006/007에서 관찰된 계열의 모델 행동 결함이 직결에서도 잔존하나 루프가 흡수 가능함을 재확인).

## 조건 준수 확인

- 격리 `CLAUDE_CONFIG_DIR`, PROMPT는 EXP-010 정본 byte-identical, thinking 무지정 — [Phase 0 기록](runs/phase0.md)
- 개입: 완주 시점까지 0회 (중단·재채점은 완주 이후)

## 관찰

1. **직결 템플릿 3사 이식성 확인** — DashScope·Moonshot에 이어 Upstage도 env 3요소 치환만으로 동작(Bearer 인증 차이만 존재, `ANTHROPIC_AUTH_TOKEN`이 흡수). EXP-008(직결·정본 이전 프롬프트, iter 10·173분) 대비 정본 프롬프트 조건에서 iter 2·58분 — 프롬프트·시점이 달라 정성 참조만.
2. **모델 자가 채점과 외부 게이트가 상충할 때, 외부 게이트도 검증 대상이다.** 이번 건은 게이트가 틀렸다 — "기각"을 모델 귀책으로 단정하지 말고 채점기 로그(server-iter.log·hurl-last.log)를 부검하라(EXP-007 원칙의 게이트 버전).
3. n=1이므로 효율·프로파일 서사는 하지 않는다 — 판정은 완주 여부 단일.

## 한계·후속

- measure v4 수정이 사후 적용된 재채점 판정 — 단 채점 대상은 iteration 2 종료 시점의 커밋 산출물로 불변이며, EXP-010 선례와 동일 구조
- iteration 1의 tool call 텍스트 유출은 원인 미분해(Upstage 변환 vs 모델 이탈) — 재발 시 별도 부검 과제
- EXP-016(재현성 확충)은 v4 게이트로 진행 — 하네스 패치를 run 시작 전 사전 등록
