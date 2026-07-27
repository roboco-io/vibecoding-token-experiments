# opus5-1 run meta (EXP-009)

- 실행: 2026-07-27 17:39:02 – 17:51:24 KST (**12분 22초**, 무개입·무중단)
- 모델: `claude --model claude-opus-5`, 기타 슬롯 기본값. 환경: 기본 `~/.claude` (EXP-002 기준선과 동일, 비격리 — README 참조)
- PROMPT.md: EXP-002 en run 실제 프롬프트 byte-identical (1,230 bytes)
- 하네스: EXP-008 이식 (상한 10 iter, `.ralph-done` 게이트, iteration별 Hurl 채점, caffeinate + 터미널 분리)

## 결과

- **완주: iteration 1** — `.ralph-done` 생성(시작 12분 시점) → 게이트 13/13 파일·154/154 요청 통과 → 독립 재검증 2회 일치
- git 커밋: **6개, 영문 메시지, 작업 단위별** (scaffolding → 테스트 벤더링 → API 구현 → README → 러너 정비 → 완료 검증 기록)
- usage (message.id dedup, run 세션 단독): API 67회, input 0.6K(신규), output 48.4K, **cache read 6.64M** tokens
- thinking 블록 0 (기본 설정에서 미발동), 허락-대기 0회, 허위 신고 0회
- 도구: Bash 39 · Write 26 · Read 15 · Edit 13 (스모크 포함 집계 기준 — run 단독은 근소 차)
- 로그: `logs/459f425a...jsonl` (466행). `phase0-smoke.jsonl`은 Phase 0 스모크 세션(집계 제외)

## Opus 4.x 기준선 대비 (EXP-001/002)

| | Opus 4.x (en 2 run) | Opus 5 (본 run) |
|---|---------------------|-----------------|
| 완주 | 2/2, 단일 세션 | 1/1, 단일 세션(iteration 1) |
| 시간 | 6–7분 | 12분 22초 (약 1.8배) |
| API 호출 | 약 38–54회 | 67회 |
| output | 29–38K | 48.4K |
| 커밋 | 0–2회 | **6회** |
| 산출 범위 | 최소 구현 중심 | 구현 + README 문서 + 자가진단형 테스트 러너 + 완료 검증 커밋 |

시간·호출 수는 4.x보다 늘었으나, 늘어난 만큼 산출물 범위(문서화·검증 절차·커밋 규율)가 넓다 — "더 느리게, 더 완전하게" 프로파일.
