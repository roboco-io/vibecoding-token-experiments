# Solar Open 2는 코딩을 얼마나 잘할까? — AI에게 백엔드 개발을 통째로 맡겨본 실험

> 2026-07-27 실측 실험 기록. 전문 용어를 최대한 풀어 쓴 일반 독자용 요약이며, 원자료와 상세 보고는 [실험 보고서](../experiments/008-solar-open2-clean-run/report.md)에 있다.

## 한 줄 결론

**업스테이지의 AI 모델 Solar Open 2는, 사람이 한 번도 개입하지 않은 상태에서 약 3시간 만에 실전 수준의 백엔드 서버를 처음부터 끝까지 혼자 만들어냈다.** 공식 테스트 154개를 전부 통과했다.

## 어떤 실험이었나

AI 코딩 도구 **Claude Code**의 두뇌를 Claude 대신 **Solar Open 2**로 바꿔 끼우고, 다음 과제를 맡겼다.

- **과제**: "RealWorld"라는 표준 벤치마크 — 블로그 서비스(미디엄 클론)의 백엔드 API 전체. 회원가입·로그인(JWT 인증), 글 작성/수정/삭제, 댓글, 팔로우, 즐겨찾기, 태그까지 실제 서비스급 기능 전부다.
- **합격 기준**: 커뮤니티가 관리하는 **공식 자동 테스트 154개를 전부 통과**해야 한다. AI가 "다 했다"고 말해도 믿지 않고, 별도 채점 장치가 테스트를 직접 돌려 확인했다.
- **진행 방식**: "랄프 루프"라는 단순한 자동화 — AI에게 과제 지시문을 주고 알아서 일하게 두고, 한 세션이 끝나면 같은 지시문으로 다시 깨우기를 반복한다. **사람은 시작 버튼만 누르고 끝까지 구경만 한다.**

## 결과: 10번의 반복 만에 완주

| 회차 | 통과한 테스트 파일 (총 13개) | 무슨 일이 있었나 |
|------|------------------------------|------------------|
| 1–2 | 0 | 프로젝트 뼈대 세우기 (아직 서버가 안 뜨는 단계) |
| 3–5 | 3 → 4 | 서버가 돌기 시작, 테스트를 돌려가며 하나씩 수정 |
| 6–8 | 9 → 10 | 35분짜리 집중 수정 세션에서 한 번에 5개 파일 통과 |
| 9 | 0 (일시 후퇴) | 데이터베이스를 정비하다가 준비가 덜 된 상태로 회차 종료 — 모든 테스트가 일시적으로 실패 |
| **10** | **13 (완주)** | **스스로 원인을 찾아 복구하고, 나머지까지 전부 통과** |

- 총 소요: 약 **2시간 53분**, AI 호출 587회. 중간 개입·중단 0회.
- 완주 선언도 검증했다: AI가 "완료" 신호를 만들면 채점 장치가 즉시 재시험하는 구조였는데, **첫 완료 선언이 곧 실제 완주**였다 (거짓 완료 없음).
- 실험자가 이후 2번 더 독립적으로 테스트를 돌려 **154/154 통과를 재확인**했다.

### 인상적이었던 장면

1. **스스로 테스트하며 고친다.** 시키지 않아도 공식 테스트를 프로젝트에 가져와, "서버 켜기 → 실패 확인 → 원인 분석 → 수정"을 혼자 반복했다. 실패 원인 진단(예: 웹 프레임워크가 헤더 이름을 소문자로 바꾸는 문제)도 정확했다.
2. **실수를 스스로 복구한다.** 9회차의 후퇴(위 표)는 사람이라면 당황할 상황인데, 다음 회차에서 테스트 실패 메시지로 원인을 바로 특정해 복구하고 그 회차에 완주까지 했다.
3. **작업 기록을 남긴다.** 지시대로 git 커밋 4개를 **한국어 메시지**로 작업 단위마다 남겼다.

### 아쉬웠던 점

1. **가끔 허락을 구하며 멈춘다.** 아무도 없는 자동 환경인데 첫 회차에 "진행하시겠습니까?"라고 묻고 일을 멈췄다. 반복 루프가 다시 깨워서 문제가 되진 않았지만, 루프 없이 한 번에 맡기면 여기서 끝났을 것이다.
2. **속으로 생각을 아주 많이 한다.** 출력의 약 94%가 눈에 보이지 않는 추론(생각) 과정이었다. 결과 품질에는 문제가 없지만 속도와 토큰 소모에는 부담이다.
3. 회차를 마칠 때 프로젝트가 항상 "바로 실행 가능한 상태"로 정리되어 있지는 않았다 (9회차 사례).

> 참고: 1회 실험 결과라 일반화에는 주의가 필요하고, Solar Open 2는 베타라 요금이 공개되지 않아 비용 비교는 하지 않았다.

## Claude Code에서 Solar Open 2 쓰는 법

Solar Open 2는 Anthropic 호환 API를 제공해서 **변환 도구 없이 환경 변수만으로** Claude Code에 연결된다. 실험에서 실제로 검증한 설정 그대로다.

### 준비물

1. [Claude Code](https://claude.com/claude-code) 설치 (`npm install -g @anthropic-ai/claude-code` 또는 공식 설치 방법)
2. [Upstage 콘솔](https://console.upstage.ai)에서 API 키 발급 (`up_...` 형태)

### 방법 1 — 공식 런처 (대화형)

업스테이지가 제공하는 스크립트를 실행하면 환경 설정 후 Claude Code가 열린다:

```bash
bash <(curl -fsSL https://console.upstage.ai/claude-upstage.sh)
```

### 방법 2 — 환경 변수 직접 설정 (스크립트·자동화용)

공식 런처가 설정하는 값을 그대로 재현한 것이다. `<YOUR_UPSTAGE_API_KEY>`만 바꾸면 된다:

```bash
env -u ANTHROPIC_API_KEY \
  ANTHROPIC_BASE_URL=https://api.upstage.ai \
  ANTHROPIC_AUTH_TOKEN=<YOUR_UPSTAGE_API_KEY> \
  ANTHROPIC_MODEL=solar-open2 \
  ANTHROPIC_SMALL_FAST_MODEL=solar-open2 \
  ANTHROPIC_DEFAULT_HAIKU_MODEL=solar-open2 \
  ANTHROPIC_DEFAULT_SONNET_MODEL=solar-open2 \
  ANTHROPIC_DEFAULT_OPUS_MODEL=solar-open2 \
  API_TIMEOUT_MS=600000 \
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
  CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144 \
  CLAUDE_CODE_MAX_OUTPUT_TOKENS=131072 \
  CLAUDE_STREAM_IDLE_TIMEOUT_MS=600000 \
  claude
```

각 설정의 의미:

| 설정 | 왜 필요한가 |
|------|-------------|
| `env -u ANTHROPIC_API_KEY` | 기존 Anthropic 키가 있으면 충돌하므로 지우고 시작 |
| `ANTHROPIC_BASE_URL` | Claude Code의 접속처를 Upstage 서버로 변경 |
| `ANTHROPIC_AUTH_TOKEN` | Upstage API 키 |
| 모델 5종 지정 | Claude Code가 내부적으로 쓰는 모든 모델 슬롯(기본·보조·Haiku/Sonnet/Opus 대체)을 전부 solar-open2로 통일 |
| `AUTO_COMPACT_WINDOW=262144` | solar-open2의 컨텍스트 한도(256K 토큰)에 맞춰 대화 압축 시점을 조정 |
| `MAX_OUTPUT_TOKENS=131072` | solar-open2의 출력 한도(128K 토큰)에 정합 |
| TIMEOUT 2종 | 긴 추론 시 응답이 끊기지 않도록 대기 시간을 10분으로 연장 |

### 방법 3 — 무인 자동화 (이번 실험 방식)

과제 지시문을 `PROMPT.md`로 저장하고, 완료 신호 파일이 생길 때까지 세션을 반복하는 최소 스크립트:

```bash
#!/bin/bash
# ralph.sh — PROMPT.md의 과제를 완료될 때까지 반복 수행
cd "$(dirname "$0")" || exit 1
for i in $(seq 1 30); do
  env -u ANTHROPIC_API_KEY \
    ANTHROPIC_BASE_URL=https://api.upstage.ai \
    ANTHROPIC_AUTH_TOKEN=<YOUR_UPSTAGE_API_KEY> \
    ANTHROPIC_MODEL=solar-open2 ANTHROPIC_SMALL_FAST_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_SONNET_MODEL=solar-open2 \
    ANTHROPIC_DEFAULT_OPUS_MODEL=solar-open2 \
    API_TIMEOUT_MS=600000 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144 CLAUDE_CODE_MAX_OUTPUT_TOKENS=131072 \
    CLAUDE_STREAM_IDLE_TIMEOUT_MS=600000 \
    claude -p "$(cat PROMPT.md)" --dangerously-skip-permissions < /dev/null >> run.log 2>&1
  [ -f .ralph-done ] && break   # 지시문에 "완료 검증 후 .ralph-done 생성"을 포함할 것
done
```

`PROMPT.md`에는 목표, 완료 기준(테스트 통과 등), "모든 기준을 직접 검증한 뒤에만 `.ralph-done` 파일을 만들 것"을 적는다.

### 실전 팁 (실험에서 배운 것)

- **전용 폴더에서 돌려라.** 자동 모드(`--dangerously-skip-permissions`)는 확인 없이 파일을 만들고 지우므로, 새 폴더에 `git init` 하고 시작하는 것이 안전하다.
- **개인 설정과 분리하고 싶다면** `CLAUDE_CONFIG_DIR=<빈 폴더>`를 추가하라. 평소 쓰는 전역 설정·플러그인·훅의 영향 없이 깨끗한 상태로 실행된다 (무인 자동화에서 특히 권장 — 개인 설정의 대화형 지시가 자동 진행을 멈출 수 있다).
- **맥에서 장시간 돌릴 때는** `caffeinate -is ./ralph.sh`로 실행해 컴퓨터가 잠들지 않게 하라.
- **AI의 완료 선언을 그대로 믿지 마라.** 테스트가 있다면 스크립트가 `.ralph-done` 발견 시 테스트를 직접 돌려, 통과 못 하면 파일을 지우고 계속하게 만들 수 있다(이번 실험의 채점 장치가 그 방식이다).
