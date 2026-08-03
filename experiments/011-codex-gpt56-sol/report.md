# EXP-011 결과 보고: Codex CLI × gpt-5.6-sol 리얼월드 백엔드 완주 검증

- 실험일: 2026-08-03 (07:42–07:48 KST)
- 가설: [M-07](../../hypotheses/catalog.md) — Codex CLI(`codex exec`) 하네스에서 gpt-5.6-sol(effort medium)은 격리·무교란 랄프 루프로 RealWorld 백엔드(Hurl 13/13·154/154)를 상한 30 iteration 안에 무개입 완주할 수 있다.
- **판정: 검증** — **iteration 1에서 완주** (게이트 13/13·154/154 + 독립 재검증 2회 일치, codex exec 5분 46초·세션 1개·커밋 3회, 무개입).

## 결과

| run | 완주 | codex exec 시간 | 세션 | input (비캐시) | cache read | output | git 커밋 |
|-----|------|-----------------|------|----------------|------------|--------|----------|
| sol-1 | iter 1/30 | 5분 46초 (게이트 포함 5분 53초) | 1 | 75.7K | 1.11M | 13.3K | 3 |

- metrics: `1,2026-08-03 07:48:29,0,13,154,1,pass` — claim 1회, 게이트 기각 0회, 허위 신고 0
- 독립 재검증: 완료 후 measure.sh 2회 재실행 → 두 번 모두 `13,154`
- usage(스모크 세션 제외, 세션 누계 기준): input 1,181,148(그중 cached 1,105,408) / output 13,330 / total 1,194,478

## 조건 준수 확인

- 격리 `CODEX_HOME` (auth.json + 2줄 config.toml만), PROMPT는 EXP-010 정본 byte-identical, effort medium 세션 메타 실측 — [Phase 0 기록](runs/phase0.md)
- 개입 0회 (기동 후 로그 열람만)

## 관찰

1. **단일 iteration·단일 세션 완주.** 랄프 루프의 재시도 메커니즘을 쓰지 않고 첫 `codex exec` 호출에서 구현→공식 hurl vendoring→자체 검증→`.ralph-done` 생성까지 완결했다. 게이트 기각도 없었다.
2. **산출 구조는 극단적 압축형**: `src/app.ts` 436줄 단일 파일 + `server.ts` 12줄 + Prisma 스키마 60줄. 공식 hurl 13파일은 `api/hurl`로 vendored, 실행 스크립트 포함. 커밋 3회(구현/포트 정렬/완료 마킹)로 EXP-010의 Opus 4.8(1–2회)과 유사한 저커밋 프로파일.
3. **토큰 프로파일**: output 13.3K는 Claude 하네스 계열(EXP-010 Opus 4.8 29.6–37.1K, Opus 5 41.1–47.9K)보다 낮은 수치이나, 하네스·계측 방식(ccusage vs rollout 누계)이 달라 직접 비교는 참고치다. n=1이므로 효율·프로파일 서사는 하지 않는다 — 판정은 완주 여부 단일.
4. wall-clock 5.8분은 M축 전체(솔라 계열 수십 분~미완주, Opus 계열 7.8–17.6분)에서 최단이나, 위와 같은 이유로 기록으로만 남긴다.

## 한계·후속

- n=1 완주 판정 실험 — 재현성(완주율)·토큰 효율 비교는 n 확충 후속 실험 필요
- 계측이 rollout 세션 누계 방식이라 Claude 계열 실험과의 토큰 수치 직접 비교는 방법 표준화(ROADMAP Phase 3) 이후로 유보
- EXP-012(M-08): 동일 모델을 ccr로 Claude Code 백엔드에 연결해 하네스 효과 분리 — 선행 게이트는 OpenAI API 키 접근 스모크
