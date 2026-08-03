# CLAUDE.md

이 리포는 토큰 사용 실험 관리 리포다. 구조·방법론은 [README.md](README.md), 가설 상태는 [hypotheses/catalog.md](hypotheses/catalog.md) 참조.

## 실험 종료 시 필수 절차

실험이 끝나 `experiments/*/report.md`를 작성·수정했다면 반드시:

1. report.md 헤더에 파싱 가능한 두 줄을 유지한다: `- 가설: [코드](...) — <문장>`, `- **판정: <판정>** — <핵심 요약 한 문장>`
2. `python3 scripts/update_readme_results.py` 실행 → README의 실험 결과 섹션이 재생성된다 (pre-commit 훅도 동일 작업을 수행하지만, 훅 미설정 환경에 대비해 직접 실행 후 커밋).
3. README의 `### 종합 인사이트` 절은 자동 생성 대상이 아니다 — 새 실험이 기존 결론을 바꾸면 이 절을 직접 갱신한다.
4. `hypotheses/catalog.md` 상태와 `ROADMAP.md` 체크박스를 갱신한다.

## 랄프 루프 벤치마크 하네스 규칙 (2026-08-04 확정)

서드파티 모델을 Claude Code에 연결하는 실험(M축)은 다음을 따른다:

1. **ccr(claude-code-router) 등 변환 계층은 사용하지 않는다.** 변환 계층은 실패 모드를 구조적으로 추가한다 — usage 유실(EXP-012 Phase 0 ④), transformer 체인 수동 조정, 스트림 스톨(EXP-012 iter 2), 변환 버그 전례(EXP-007 멀티 델타). 완주 소요도 ccr 조건(58분·173분)이 직결 조건(15–21분)보다 컸다(모델 교락 있음 — 방향성 참고).
2. **기본 연결은 제공자의 Anthropic 호환 엔드포인트 직결**(`ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN`)이다. 검증된 제공자: DashScope(EXP-013), Moonshot(EXP-014), Upstage(EXP-015, Bearer만 수용). 템플릿은 직전 실험 하네스에서 env 3요소(엔드포인트/키/모델 ID)만 치환한다.
3. Anthropic 호환 엔드포인트가 없는 모델은 벤치마크 대상에서 제외하거나, 부득이 변환 계층을 쓸 경우 설계 문서에 **사유와 계측 한계를 사전 등록**하고 결과 비교에서 별도 스택으로 표기한다.
4. 격리(`CLAUDE_CONFIG_DIR` 전용 + `hasCompletedOnboarding` 우회)·PROMPT 정본 byte-identical·세션 jsonl usage(message.id dedup) 계측은 기존 원칙(EXP-007/008) 그대로 유지한다.

## 환경 주의

- 새로 클론한 환경에서는 `git config core.hooksPath hooks` 1회 실행 (pre-commit 훅 활성화).
- README의 `<!-- RESULTS:BEGIN/END -->` 마커 사이는 직접 수정 금지 (스크립트가 덮어씀).
