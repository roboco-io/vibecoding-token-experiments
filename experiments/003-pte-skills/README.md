# EXP-003: PTE + 스킬식 점진 공개 (Progressive Disclosure)

> 실행 절차: [protocol.md](protocol.md) · 프롬프트: [prompts/](prompts/)

## 가설

[S-02](../../hypotheses/catalog.md): Plan-then-execute에서 컨텍스트 문서를 Claude 스킬 공식 권고대로 구조화(문서 200줄 이하 분할 + 스킬 메커니즘으로 필요한 것만 로드)하면, EXP-001 PTE 대비 billable 토큰이 유의미하게 줄어든다.

근거: EXP-001 분해 분석에서 PTE 비용의 주범은 컨텍스트 재구축(cache_creation 1.71M — 명세·계약 문서의 반복 읽기 포함)이었다. 점진 공개는 정확히 이 지점을 겨냥한다.

## 조건

| 조건 | 설명 | 비교 데이터 |
|------|------|------------|
| pte-skills (신규 실행) | EXP-001 PTE와 동일한 워크플로(계획 1회 → 태스크별 새 세션 병렬 → 검증). 차이는 컨텍스트 구조만: 계획 세션이 인터페이스 계약을 `.claude/skills/`의 도메인별 SKILL.md로 분할, 모든 문서 200줄 이하, 실행 세션은 필요한 스킬만 로드 | `runs/pte-skills/` |
| pte (기준) | EXP-001 PTE 결과 재사용 — billable 2,839,815, 세션 16 | EXP-001 runs |
| ralph (참조) | EXP-001 ralph 결과 재사용 — billable 324,775, 세션 1 | EXP-001 runs |

## 통제 변수

- 모델 Opus 고정, headless, 빈 작업 리포(`realworld-exp003-pte-skills`), CLAUDE.md 없음, 무개입 원칙, 오케스트레이션은 실험자(측정 외)
- 완료 판정: Hurl 13파일/154요청 100% (사전 고정). ※ EXP-001 PTE는 Newman 클래식 311 assertion이었음 — 판정 세트 차이는 한계로 기록
- 스킬은 작업 리포의 `.claude/skills/`에 계획 세션이 생성 (프로젝트 스킬로 자동 노출)

## 측정

- EXP-001과 동일: 세션 로그 수집 → `aggregate_tokens.py` → billable 분해(기동세/output/cache_creation), 세션별 비용, 반복 읽기 카운트
- 핵심 비교 지표: (1) 총 billable vs 2,839,815 (2) 실행 세션당 평균 cache_creation (3) 계약 문서 반복 읽기 횟수

## 성공 기준

- 과제 완료(Hurl 100%) 시에만 유효 비교
- S-02 판정: pte-skills billable이 EXP-001 PTE 대비 뚜렷이 감소(EXP-002 교훈상 run 간 변동 ±수십만 토큰을 감안해 30% 이상 감소를 유의미로 봄)
