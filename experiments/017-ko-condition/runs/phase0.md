# EXP-017 Phase 0 통과 기록 (2026-08-04 KST)

하네스 베이스 `~/ralph-exp017q`(qwen)·`~/ralph-exp017k`(kimi) — EXP-013/014 driver에서 BASE·PROMPT만 교체(env 동일), measure **v4**, 격리 CLAUDE_CONFIG_DIR.

## ① 번역본 검수

- `PROMPT-ko.md`는 EXP-010 en 정본(18줄)의 전항 번역: 기술 스택·범위·완료 기준 2항(공식 hurl 13파일·154요청 vendoring, 단일 명령 기동)·작업 지침 4항·`.ralph-done` 규약·PROMPT/ralph.sh 수정 금지 모두 유지. 언어 지시만 "모든 산출물 한국어"로 반전. 정본은 [PROMPT-ko.md](PROMPT-ko.md)로 커밋 — run 간 byte-identical.

## ② 한국어 지시 스모크 (모델별 1회)

- qwen3.8-max: 한국어 지시(`인사.txt`·'안녕'·커밋 '스모크') → 파일·커밋·'완료' 응답 모두 정확, exit 0
- kimi-k3: 동일 지시 → 동일 통과, exit 0
- 두 모델 모두 한국어 파일명·한국어 커밋 메시지 생성 확인. 트러블슈팅 0건.

## ③ measure v4·포트

- 양 베이스 빈 리포 → `0,0`. **포트 8000은 무관 프로세스(officeagent, 타 프로젝트) 점유 중** — measure v4의 리포 소속 판정(cwd/command)상 오탐·오살 불가, 앱들은 관례상 3000 사용이라 영향 없음으로 판단하고 기록만 남김(종료하지 않음).

## ④ usage 계측

- 스모크 세션 jsonl 정상 집계(양 베이스). Phase 0 세션은 `claude-config-projects-phase0/`로 격리, 본 실행은 run별 새 projects/에서 집계(EXP-016 방식).
