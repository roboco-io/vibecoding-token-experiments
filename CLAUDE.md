# CLAUDE.md

이 리포는 토큰 사용 실험 관리 리포다. 구조·방법론은 [README.md](README.md), 가설 상태는 [hypotheses/catalog.md](hypotheses/catalog.md) 참조.

## 실험 종료 시 필수 절차

실험이 끝나 `experiments/*/report.md`를 작성·수정했다면 반드시:

1. report.md 헤더에 파싱 가능한 두 줄을 유지한다: `- 가설: [코드](...) — <문장>`, `- **판정: <판정>** — <핵심 요약 한 문장>`
2. `python3 scripts/update_readme_results.py` 실행 → README의 실험 결과 섹션이 재생성된다 (pre-commit 훅도 동일 작업을 수행하지만, 훅 미설정 환경에 대비해 직접 실행 후 커밋).
3. README의 `### 종합 인사이트` 절은 자동 생성 대상이 아니다 — 새 실험이 기존 결론을 바꾸면 이 절을 직접 갱신한다.
4. `hypotheses/catalog.md` 상태와 `ROADMAP.md` 체크박스를 갱신한다.

## 환경 주의

- 새로 클론한 환경에서는 `git config core.hooksPath hooks` 1회 실행 (pre-commit 훅 활성화).
- README의 `<!-- RESULTS:BEGIN/END -->` 마커 사이는 직접 수정 금지 (스크립트가 덮어씀).
