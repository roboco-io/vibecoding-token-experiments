# EXP-007 설계: Solar Open 2 미완주 원인 부검 (트랜스크립트 분석)

## 배경·목적 전환

핸드오프 시점의 EXP-007 후보는 "공식 가이드 그대로 클린 재실행"이었으나, 실험자 결정으로 목적을 전환했다: **완주 성공 여부가 아니라, solar-open2가 왜 과제를 완수하지 못하는지 특성을 규명한다.** 새 run을 돌리기 전에 EXP-006이 남긴 데이터(open2-2 세션 트랜스크립트 15개, 약 9MB)를 부검하는 것이 Phase A이고, 여기서 세운 가설을 계측 강화 run으로 검증하는 것이 Phase B(선택)다. 본 실험은 Phase A만으로 판정한다.

## 가설

[M-03](../../hypotheses/catalog.md) — EXP-006(Solar Open 2) 미완주는 "수렴 속도"라는 단일 병목이 아니라 복수 실패 요인(모델 행동 결함 · 실험 환경 오염 · 계측 왜곡)의 중첩이며, 트랜스크립트 부검으로 각 요인을 분해·실증할 수 있다.

## 데이터

- `../006-solar-open2-backend/runs/open2-2/logs/` — Claude Code 세션 JSONL 15개 (iteration당 1세션, 블록1 2 + 블록2 11 + 블록3 2)
- `../006-solar-open2-backend/runs/open2-2/ralph-run.log` — iteration 경계·재시작 이력 정본
- `../006-solar-open2-backend/runs/open2-2/meta.md` — 기존 집계 (본 부검의 정정 대상 포함)

## 방법

`scripts/analyze_transcripts.py` (Python, 표준 라이브러리만):

1. **usage 재집계**: assistant 행을 `message.id`로 중복 제거해 API 요청 수·토큰을 재산정. 같은 id의 다중 행이 동일 usage를 반복하는지 전수 검증(459/459 동일 확인)으로 행 합산 방식의 과대 계상을 판별.
2. **iteration 매핑**: 세션 타임스탬프를 ralph-run.log의 iteration 경계와 대조해 15세션을 블록·iteration에 배정, kill로 유실된 세션 식별.
3. **행동 추출**: 도구 호출 분포, 편집/생성 파일, git 명령 전수, Hurl 실행 결과(`Executed/Succeeded files` 파싱)로 수렴 궤적 재구성, stop_reason 분포(max_tokens 잘림), thinking/text 문자 비중, 스킬·서브에이전트 호출, 비활성 도구 호출.
4. **정성 부검**: 무편집 iteration의 종결 텍스트, 선언("커밋하겠습니다")과 실행(git commit)의 대조, 과제 이탈 텍스트 탐지.

## 판정 기준

- **검증**: 미완주를 설명하는 요인이 "수렴 속도" 외에 2개 계층 이상에서 실증되고, 각 요인의 크기(잠식된 iteration 수, 낭비된 API 호출 수, 계상 오차 배율)를 정량 제시할 수 있다.
- **기각**: 부검 결과 기존 결론(수렴 속도 단일 병목, 비용 초과)이 그대로 성립한다.

## 리스크·한계

- 부검은 상관·정황 증거다 — 오염 요인(주입 지시)이 없었을 때의 행동은 Phase B(오염 제거 클린 run) 없이는 반증 불가.
- open2-1(CCR 경유, 1 iter 허위 완료)은 세션 로그 1개뿐이라 부검 대상에서 제외, open2-2만 분석.
- Upstage 직결 경로가 캐시를 미보고하므로 재집계 후에도 실과금은 콘솔 확인 전까지 추정치다.
