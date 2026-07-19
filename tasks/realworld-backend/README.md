# 공통 과제: RealWorld App 백엔드

모든 워크플로 전략 실험에서 동일하게 사용하는 벤치마크 과제.

## 과제 정의

[RealWorld](https://github.com/gothinkster/realworld) 스펙("Medium 클론")의 백엔드 API를 구현한다.

- **스펙**: [RealWorld API 스펙](https://realworld-docs.netlify.app/specifications/backend/endpoints/) — 인증(JWT), 유저/프로필, 아티클 CRUD, 코멘트, 즐겨찾기, 태그, 피드
- **기술 스택**: TypeScript (Node.js) + Fastify + Prisma + SQLite — 모든 조건에 동일 적용
  - 선정 근거(2026-07 Perplexity 조사): Stack Overflow 2025 설문에서 Node.js 백엔드 1위, AI 스택 가이드들이 Node+Prisma 조합으로 수렴, LLM 학습 데이터가 풍부해 에이전트 코딩 오류율이 낮다고 평가됨. 차점 후보는 Python+FastAPI(AI 특화 백엔드용)였으나 본 과제는 일반 REST API이므로 제외.
  - DB는 조사 1위인 PostgreSQL 대신 **SQLite** 사용: DB 서버 기동·설정 없이 파일 기반으로 즉시 실행 가능해 실험 반복이 빠르고, 환경 설정 토큰(교란 변수)을 줄임. Prisma가 SQLite를 지원하므로 스키마·CRUD 생성 품질에는 영향 없음.
- **시작 상태**: 빈 저장소에서 시작 (스캐폴딩 없음)

## 완료 기준 (Definition of Done)

- [ ] RealWorld 공식 API 테스트(Postman/Newman collection) 전체 통과
- [ ] 로컬에서 단일 명령으로 서버 기동 가능

## 통제 조건

- 모델: Claude Opus 고정
- 동일한 초기 프롬프트 자료(이 과제 스펙)를 조건별로 동일하게 제공
- 실험자 개입 규칙은 각 실험 README에 명시
