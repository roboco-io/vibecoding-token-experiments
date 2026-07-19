# 리포지토리 구조 설계 (2026-07-20)

## 목적

바이브 코딩 토큰 사용 가설을 통제된 실험으로 검증·관리하기 위한 리포지토리 구조 확정.

## 결정 사항

1. **범위**: 문서 + 측정 스크립트. 실험 대상 코드베이스(RealWorld 구현체)는 별도 저장소로 두고 이 리포에는 링크·로그만 보관.
2. **측정 대상**: 1차는 Claude Code. 타 도구 비교는 Phase 3 로드맵으로 이연.
3. **실험 방식**: 조건(condition) 간 비교 실험. 공통 과제는 RealWorld App 백엔드 구현으로 고정, 모델은 Opus 단일.
4. **가설 두 축 병행**:
   - S축(워크플로 전략): Ralph loop vs Plan-then-execute 등
   - H축(토큰 습관): tokenhabit H1~H8 카탈로그 28패턴
5. **구조**: 실험 중심 플랫 구조 채택 (검토안 중 A안). 가설 카테고리 계층(B안)은 중첩이 깊고 복합 실험 배치가 애매하여 기각, 단일 문서(C안)는 A/B 데이터 수용 한계로 기각.
6. **anti-reinvention**: 측정은 tokenhabit·ccusage를 래핑. `scripts/`는 접착 코드만.

## 구조

```
├── ideation.md            # 최초 아이디에이션 (원본 유지)
├── README.md              # 소개, 방법론, 라이프사이클
├── ROADMAP.md             # Phase 1~3
├── hypotheses/catalog.md  # S축 + H축 가설 목록, 실험 상태 표 (인덱스 역할)
├── experiments/NNN-이름/  # 실험 단위: README(설계) + runs/<조건>/ + report.md
├── tasks/                 # 공통 과제 스펙 (실험 간 재사용, 조건 통제)
├── templates/             # experiment-readme.md, report.md
├── scripts/               # 측정·집계 래퍼
└── docs/specs/            # 설계 문서
```

## 실험 라이프사이클

템플릿 복사 → 설계 작성 → 조건별 세션 수행·로그 보관(`runs/<조건>/`) → `report.md` 분석 → `catalog.md` 상태 갱신(미실험/진행중/검증/기각/보류).
