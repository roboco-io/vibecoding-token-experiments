# 단일 세션 컨텍스트 재활용의 메커니즘: 프롬프트 캐싱

> EXP-001~004에서 관찰한 "단일 세션이 압도적으로 싼 이유"의 기술적 배경.
> 조사: Perplexity 경유 Anthropic 공식 문서 (2026-07-22). 관련 실험: [EXP-001](../experiments/001-ralph-vs-plan-then-execute/report.md), [EXP-003](../experiments/003-pte-skills/report.md), [EXP-004](../experiments/004-ralph-skills/report.md)

## 1. 동작 원리 — prefix 기반 캐싱

- 캐시 대상은 **프롬프트 맨 앞에서부터의 연속 prefix**. prefix 내용의 해시가 키이며, 바이트 단위로 동일한 prefix가 다시 오면 모델이 재처리 없이 서버 측 상태를 로드한다.
- `cache_control` breakpoint는 요청당 최대 4개, breakpoint 앞 최대 20개 블록의 lookback으로 최장 일치 prefix를 찾는다. 최소 캐시 길이는 Sonnet/Opus 1,024토큰.
- usage 필드의 의미 (이 리포의 `aggregate_tokens.py`가 집계하는 값):
  - `cache_creation_input_tokens` — 이번 요청에서 **새로 캐시에 쓴** 토큰
  - `cache_read_input_tokens` — **캐시 히트로 읽어온** 토큰 (재처리 안 함)
  - `input_tokens` — 캐시 범위 밖의 새 입력만
- 출처: https://platform.claude.com/docs/en/build-with-claude/prompt-caching

## 2. 수명과 가격

| 항목 | 배율 (기본 input 대비) | Opus 기준 $/M |
|------|----------------------:|--------------:|
| input (비캐시) | 1.0 | $15 |
| cache write (5분 TTL) | 1.25 | $18.75 |
| cache write (1시간 TTL) | 2.0 | $30 |
| **cache read** | **0.1** | **$1.5** |
| output | 5.0 | $75 |

- 기본 TTL 5분, **히트할 때마다 무료로 리셋** — 에이전트가 5분 내 계속 턴을 이어가면 캐시는 사실상 세션 내내 유지된다.
- 5분 캐시는 히트 1회면 손익분기(1.25+0.1 < 2.0).
- 출처: https://platform.claude.com/docs/en/about-claude/pricing

## 3. 에이전트 루프에서 왜 "재활용"이 되나

- Claude Code는 시스템 프롬프트·도구 정의·CLAUDE.md 등 불변 내용을 **자동으로 캐싱**한다 (사용자 설정 불필요).
- 대화는 **append-only**로 누적된다 → 직전까지의 히스토리 전체가 안정된 prefix가 되어, 매 턴 "이전 전부 = cache read(0.1×), 이번 턴 새 입력·출력만 정가"로 과금된다. 턴이 쌓일수록 `cache_read`가 커지는 이유다.
- 출처: https://code.claude.com/docs/en/agent-sdk/agent-loop

**실측과의 연결**: EXP-001 ralph(단일 세션 112메시지)의 cache_read 8.4M은 "같은 컨텍스트를 112번 재처리했다면 발생했을 비용"이 0.1배로 흡수된 흔적이다. 반면 PTE 16세션은 세션마다 prefix가 새로 시작돼 cache_creation이 2.04M(8.7배)으로 폭증했다.

## 4. 캐시가 깨지는 조건 (실험 설계 시 통제 대상)

- 계층 구조 **tools → system → messages**: 상위가 바뀌면 그 이하 전부 무효화. 도구 정의 변경은 전체 캐시 무효화.
- 모델 변경 시 재사용 불가. thinking 설정·이미지 유무·`tool_choice` 변경은 messages 캐시 무효화.
- prefix에 타임스탬프 등 비결정적 내용이 섞이면 바이트 불일치로 미스.
- **새 세션이 비싼 정확한 이유**: 캐시는 세션이 아니라 prefix 내용에 키잉되므로, 시스템 프롬프트·도구가 같으면 새 세션도 그 공통 부분(~20K, 우리가 "기동세"로 측정한 값)은 TTL 내 재사용될 수 있다. 그러나 **대화 히스토리·읽은 파일은 세션마다 다르므로** 그 부분은 매번 cache write(1.25×)로 재구축된다 — EXP-001 원인 1·2의 기전.
- 참고: 캐시는 동일 조직/workspace 내에서 공유되므로 병렬 세션이 같은 prefix를 히트할 수는 있으나, cold 상태의 동시 요청은 둘 다 미스할 수 있다(원자성 미보장, 공식 문서화 약함).

## 5. 측정 지표 보정: cache read는 공짜가 아니다

이 리포의 `billable = input + output + cache_creation`은 cache read(0.1×)를 제외한 근사치다. Opus 단가로 **달러 환산**하면:

| | EXP-001 ralph | EXP-001 PTE | EXP-003 pte-skills |
|---|---:|---:|---:|
| input | $0.00 | $0.02 | $0.01 |
| output ($75/M) | $6.82 | $59.84 | $26.12 |
| cache write ($18.75/M) | $4.38 | $38.26 | $25.77 |
| cache read ($1.5/M) | $12.64 | $63.78 | $40.33 |
| **합계** | **$23.8** | **$161.9** | **$92.2** |

- 달러 기준 PTE/ralph 비율은 **6.8배** (billable 토큰 기준 8.7배보다 완만 — ralph의 cache read 비중이 커서).
- 단일 세션에서도 cache read가 최대 비용 항목(ralph의 53%)이다: 0.1배라도 매 턴 히스토리 전체를 읽으므로 **세션이 길어질수록 2차 곡선으로 누적**된다. 긴 세션에서 `/compact`가 권고되는 정량적 근거.

## 6. 실험 시사점 요약

1. 단일 세션의 우위(EXP-001·004)는 "append-only 히스토리 = 안정 prefix = 0.1배 재사용"이라는 캐싱 구조의 직접 귀결이다.
2. 세션 분할(PTE)의 세금은 기동세가 아니라 **세션별 고유 컨텍스트(파일·히스토리)의 cache write 재구축**이 본체다. 스킬식 점진 공개(EXP-003)는 이 재구축량 자체를 줄여 -39.3%를 만들었다.
3. 다만 히스토리 재사용은 공짜가 아니라 0.1배 과금이므로, 매우 긴 단일 세션은 cache read 누적으로 다시 비싸진다 — "짧은 세션 여러 개 vs 긴 세션 하나"의 최적점은 과제 크기에 따라 존재할 것 (후속 실험 후보).

## 불확실 표시

- Claude Code 내부의 breakpoint 배치 세부, cold 캐시 동시 요청의 원자성, 일부 모델의 최소 캐시 길이(2,048 보고)는 공식 문서 근거가 약해 불확실로 남긴다.
