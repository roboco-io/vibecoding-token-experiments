# Vibecoding Token Experiments

바이브 코딩이 표준으로 도입되면서 여러 조직이 심각한 토큰 부족 현상을 겪고 있다.
이 리포지토리는 토큰 사용에 대한 가설을 세우고, 통제된 실험으로 실제 절약 효과를 검증하기 위한 실험 관리 리포지토리이다.

## 실험 방법론

- **공통 과제**: [RealWorld App](https://github.com/gothinkster/realworld) 백엔드 구현 — 조건 간 비교를 위한 고정 벤치마크 과제. 스펙은 [`tasks/realworld-backend/`](tasks/realworld-backend/) 참조.
- **모델 고정**: 모든 실험은 **Claude Opus 단일 모델**로 수행한다 (모델 차이로 인한 교란 제거).
- **측정 도구**: 기존 도구를 활용한다 — [tokenhabit](https://github.com/epoko77-ai/tokenhabit) (`habit_scan.py`), [ccusage](https://github.com/ryoppippi/ccusage). `scripts/`에는 실험 구간 추출·비교 집계용 최소 래퍼만 둔다.
- **1차 대상 도구**: Claude Code. 타 도구 비교는 [`ROADMAP.md`](ROADMAP.md) 참조.

## 가설의 두 축

1. **워크플로 전략 (S축)**: 같은 과제를 어떤 전략으로 수행하느냐에 따른 토큰 차이
   - Ralph loop: 골을 지정한 뒤 랄프 루프로 자율 진행
   - Plan-then-execute: 계획 수립 → 태스크 분할 → 개별 태스크 병렬 구현
2. **토큰 습관 (H축)**: tokenhabit의 H1~H8 습관 패턴 교정 전/후의 토큰 차이

전체 가설 목록과 실험 상태는 [`hypotheses/catalog.md`](hypotheses/catalog.md)에서 관리한다.

## 실험 라이프사이클

1. `templates/experiment-readme.md`를 복사해 `experiments/NNN-이름/README.md`에 실험 설계 작성 (가설, 조건, 측정 방법, 성공 기준)
2. 조건별로 세션 수행, 세션 로그·측정 결과를 `runs/<조건명>/`에 저장
3. `report.md`에 토큰 차이 분석과 결론 작성
4. `hypotheses/catalog.md`의 상태 갱신 (미실험 → 진행중 → 검증/기각)

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
