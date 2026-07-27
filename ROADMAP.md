# Roadmap

## Phase 1 — Claude Code 워크플로 전략 비교 (현재)

- [x] EXP-001: Ralph loop vs Plan-then-execute (RealWorld 백엔드, Opus 고정) — S-01 기각, [보고서](experiments/001-ralph-vs-plan-then-execute/report.md)
- [x] EXP-002: 한국어 vs 영어 파이프라인 토큰 비교 (L-01, KO/EN × n=2) — 보류 판정, [보고서](experiments/002-korean-vs-english/report.md)
- [x] EXP-003: PTE + 스킬식 점진 공개 (S-02) — 검증(-39.3%), [보고서](experiments/003-pte-skills/report.md)
- [x] EXP-004: Ralph + 스킬 구조 (S-03) — 보류(무효과), [보고서](experiments/004-ralph-skills/report.md)
- [ ] 측정 파이프라인 정리 (tokenhabit + ccusage 래퍼)

## Phase 2 — 토큰 습관(H축) 실험

- [ ] tokenhabit H-코드 중 낭비 추정치가 큰 패턴부터 A/B 검증
- [ ] 습관 교정 가이드(전역 CLAUDE.md 규칙)의 실효성 정량화

## Phase 3 — 타 도구·타 모델 비교

- [x] EXP-005: Claude Code × Upstage Solar Pro 3 백엔드 (M-01) — 보류(solar-1 미완주·조기중단), [보고서](experiments/005-solar-pro3-backend/report.md)
- [x] EXP-006: Claude Code × Upstage Solar Open 2 백엔드 (M-02) — 보류(0/2 완주, 자율 TDD 루프는 확립·병목은 수렴 속도), [보고서](experiments/006-solar-open2-backend/report.md)
- [x] EXP-007: Solar Open 2 미완주 원인 부검 (M-03) — 검증(계측 3배 과대·환경 오염·모델 결함 3계층 분해, EXP-006 비용 서사 정정), [보고서](experiments/007-solar-open2-autopsy/report.md)
- [x] EXP-008: Solar Open 2 무오염 클린 run (M-04, EXP-007 Phase B) — 검증(**iteration 10에서 완주** 13/13·154/154, 오염 제거가 결정 변수, 커밋 4회 이행), [보고서](experiments/008-solar-open2-clean-run/report.md)
- [x] EXP-009: Opus 5 랄프 루프 (M-05, EXP-002 en 조건) — 부분 검증(n=3, 3/3 iteration 1 완주·9–12분, 시간 증가는 변동 아닌 산출량 +62% 프로파일), [보고서](experiments/009-opus5-ralph-en/report.md)
- [ ] Codex, Cursor 등 동일 과제 기반 도구 간 토큰 효율 비교
- [ ] 도구별 측정 방법 표준화
