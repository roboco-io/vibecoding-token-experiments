# EXP-NNN: <실험 이름>

## 가설

<검증하려는 가설. `hypotheses/catalog.md`의 코드 인용 (예: S-01, H2-01)>

## 과제

<사용하는 공통 과제. 예: [realworld-backend](../../tasks/realworld-backend/)>

## 조건 (Conditions)

| 조건 | 설명 | runs 디렉토리 |
|------|------|---------------|
| <조건A> | | `runs/<조건A>/` |
| <조건B> | | `runs/<조건B>/` |

## 통제 변수

- 모델: Claude Opus 고정
- <기타: 스택, 초기 프롬프트, 개입 규칙 등>

## 측정 방법

- 세션 로그(`~/.claude/projects/*.jsonl`) 사본을 `runs/<조건>/`에 보관
- ccusage / tokenhabit `habit_scan.py`로 토큰 집계 (input / output / cache creation / cache read)
- <추가 지표: 소요 시간, 완료율, 테스트 통과율 등>

## 성공 기준

<과제 완료 판정 기준 + 가설 검증/기각 판정 기준 (예: 토큰 20% 이상 차이)>
