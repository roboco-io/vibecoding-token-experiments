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
- [x] EXP-010: Opus 4.8 vs 5 순수 A/B (M-06, 동시점 교차 각 n=3) — 검증(6/6 완주, output·커밋 분포 비겹침으로 프로파일 실재 확정), [보고서](experiments/010-opus48-vs-opus5/report.md)
- [x] EXP-011: Codex CLI × gpt-5.6-sol 완주 검증 (M-07, n=1) — 검증(iteration 1 완주·독립 재검증 일치, 5분 46초·커밋 3회), [보고서](experiments/011-codex-gpt56-sol/report.md)
- [x] EXP-012: Claude Code 백엔드 × gpt-5.6-sol (ccr, M-08, n=1) — 검증(iteration 11 완주·58분·커밋 11회, 스톨 1건 하네스 복구), [보고서](experiments/012-ccr-gpt56-sol/report.md)
- [x] EXP-013: Claude Code × qwen3.8-max 직결(ANTHROPIC_BASE_URL) 완주 검증 (M-09, n=1) — 검증(iteration 1 완주·15분 5초·커밋 4회, 직결 트러블슈팅 0건·usage 정상 기록), [보고서](experiments/013-qwen38max-direct/report.md)
- [x] EXP-014: Claude Code × kimi-k3 직결(ANTHROPIC_BASE_URL) 완주 검증 (M-10, n=1) — 검증(iteration 1 완주·21분 18초·커밋 4회, EXP-013 하네스 env 치환만으로 동작), [보고서](experiments/014-kimi-k3-direct/report.md)
- [x] EXP-015: Claude Code × solar-open2 직결(ANTHROPIC_BASE_URL) 완주 검증 (M-11, n=1, EXP-008 직결 완주의 정본 조건 재현) — 검증(iteration 2 완주·58분 15초, 게이트 오검 1건 v4 수정·재채점 일치), [보고서](experiments/015-solar-open2-direct/report.md)
- [x] EXP-016: n=1 완주 조건 3종(EXP-011/013/014) 재현성 확충, 각 n=3 (M-12) — 검증(추가 6 run 전부 완주, 합산 9/9·8/9 iter 1, 완주 외 지표는 변동 큼), [보고서](experiments/016-n3-replication/report.md)
- [x] EXP-017: qwen3.8-max·kimi-k3 한국어 조건 완주 검증 (L-02, 각 n=3) — 검증(6/6 iter 1, 언어 준수 전수, qwen ko +48% 시간은 방향성 기록), [보고서](experiments/017-ko-condition/report.md)
- [x] EXP-018: solar-open2 직결 재현성 확충, n=3 (M-13, EXP-015 +2 run) — 보류(제공자 엔드포인트 회수로 검증 불가, EXP-015가 마지막 시점 기록), [보고서](experiments/018-solar-n3-replication/report.md)
- [x] EXP-019: 네이티브 Opus 4.8·5 + Codex×gpt-5.6-sol 한국어 조건, 각 n=3 (L-03) — 검증(9/9 iter 1, 언어 준수 전수·EN 분포와 겹침, 언어 반전 누적 15/15), [보고서](experiments/019-ko-native-codex/report.md)
- [ ] EXP-020: Claude Code × solar-pro4 직결 완주 검증, n=3 (M-14, 엔드포인트 복구 확인 후) — 진행중, [설계](experiments/020-solar-pro4-direct/README.md)
- [ ] Codex, Cursor 등 동일 과제 기반 도구 간 토큰 효율 비교
- [ ] 도구별 측정 방법 표준화
