# 사전 조사: Claude Code × Upstage Solar 백엔드 (2026-07-26)

> 조사 도구: Perplexity (sonar deep research + search). 원문 91K자 요약. 계획서: [README.md](README.md)

## 1. Upstage 최신 모델 — Solar Pro 3

| 항목 | 값 | 출처 |
|------|-----|------|
| 아키텍처 | MoE 102B (토큰당 활성 12B) | [Upstage 블로그](https://upstage.ai/ko/blog/ko/solar-pro-3-0127) |
| 공개 | 2026-01-27 (무료 프로모션 2026-03-02 종료) | 상동 |
| 컨텍스트 | 131,072 tokens (자사 API) / 128K (OpenRouter) | [models.dev](https://models.dev/providers/upstage/), runatlas.sh |
| **max output** | **8,192 tokens — reasoning(thinking) 포함** | 상동 |
| 단가 (자사 API) | **$0.25 / $0.25 per Mtok (입출력 대칭)** — thinking 토큰도 동일 단가 | 상동 |
| 단가 (OpenRouter) | $0.15 / $0.60 per Mtok | 상동 |
| 모드 | reasoning / chat 이중 모드, tool calling·structured output 지원 (스키마 준수 100% 주장) | Upstage 문서 |
| 에이전틱 | Tau2-all 72.3 (Pro 2는 36.0) — SnapPO RL 학습 | Upstage 블로그 |
| 한국어 | 최강점 (Ko-MMLU, Hae-Rae 등) — 본 리포 L-01 실험과 접점 | 상동 |
| API 형식 | **OpenAI 호환 chat completions** (`https://api.upstage.ai/v1`). **Anthropic 호환 엔드포인트 없음** | models.dev, Upstage Console |
| 특성 | 고verbosity — Artificial Analysis 평가에서 중앙값 대비 약 4배 토큰 생성(120M vs 32M) | [AA](https://artificialanalysis.ai/models/solar-pro-3) |

보조 모델 후보: `solar-mini` (32K, $0.15/$0.15, tool call 지원) — `ANTHROPIC_SMALL_FAST_MODEL` 슬롯용.

주의: 출처 간 공개일 불일치(Upstage 한국 블로그 1/27 vs AA 4/6). 실행 시점에 Console에서 모델 ID·단가 재확인 필요.

## 2. Claude Code를 타 모델로 돌리는 방법 (2026 현재)

Claude Code는 `/v1/messages`(Anthropic Messages 프로토콜)만 말한다. 백엔드 교체는 환경변수로:

```bash
ANTHROPIC_BASE_URL=<Anthropic 호환 엔드포인트>   # /v1 접미사 붙이지 않음
ANTHROPIC_AUTH_TOKEN=<해당 서비스 키>
ANTHROPIC_API_KEY=""                             # 명시적으로 비워야 자격증명 충돌 없음
ANTHROPIC_MODEL=<모델 ID> (+ ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL, ANTHROPIC_SMALL_FAST_MODEL)
CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1         # 비Anthropic 백엔드에서 beta 헤더로 인한 4xx 방지
```

Upstage는 OpenAI 형식만 제공하므로 **Anthropic↔OpenAI 변환 계층이 필수**:

| 경로 | 방식 | 평가 |
|------|------|------|
| claude-code-router (musistudio) | 로컬 게이트웨이(:3456), provider별 transformer로 형식 변환, `/model provider,model` 전환, 요청 로깅 | 커뮤니티 검증 가장 많음. transformer 품질이 tool calling 충실도를 좌우 |
| OpenRouter "Anthropic skin" | `ANTHROPIC_BASE_URL=https://openrouter.ai/api` 직결, OpenRouter가 변환. `upstage/solar-pro-3` 라우팅 가능 | 가장 단순하나 변환이 블랙박스, 단가 상이($0.15/$0.60) |
| LiteLLM proxy | `/anthropic` passthrough + provider 변환, 비용·토큰 집계 내장 | 계측에 유리, 설정 복잡 |
| y-router (Cloudflare Worker) | Anthropic→OpenAI 변환 워커 | OpenRouter 지향, 자가 호스팅 필요 |

## 3. 선행 사례

- **Solar × Claude Code 직접 벤치마크·경험 보고는 공개된 것이 없음** (딥리서치 결론). 본 실험이 사실상 첫 공개 사례가 될 수 있다.
- GPT-4o/Gemini/DeepSeek/Kimi 등은 CCR·OpenRouter 경유 사용 보고 다수 — 대화·코드 생성은 원활, **tool calling 변환 충실도와 캐시 회계가 공통 리스크**로 지적됨.
- 보고된 문제 유형: beta 헤더 비호환(4xx), `ANTHROPIC_CUSTOM_HEADERS` 다중 헤더 포맷 실수, tool 스키마 매핑 누락 시 조용한 실패(agentic 성능 저하로 오인), 라우터 경유 시 Claude Code 자체 usage 표시 부정확.

## 4. 프롬프트 캐싱과 측정 비교성 (본 실험 설계의 핵심 쟁점)

1. ~~**Solar API에 Anthropic식 서버 캐싱이 없다.**~~ **[실험에서 정정]** Upstage는 OpenAI식 자동 캐싱을 제공하며(`cached_tokens`), CCR이 이를 `cache_read_input_tokens`로 매핑한다 ([report.md](report.md) 참조). 이하 원문: 변환 계층은 cache_control 힌트를 무시하고 매 턴 전체 컨텍스트를 신규 input으로 전송 → 전량 $0.25/Mtok 과금. Opus 기준선은 cache read 90% 할인을 받았으므로 **billable 토큰 수치의 직접 비교는 무의미**.
2. **usage 필드 신뢰 불가.** 라우터가 provider의 토큰 수치를 Anthropic 형식 usage로 되돌려 넣는 방식이 제각각 — 세션 JSONL 집계(aggregate_tokens.py)는 참고치로만 쓰고, **Upstage Console 사용량 대시보드(과금 정본) + 프록시 로그와 3중 대조**해야 한다.
3. **토크나이저 상이.** 같은 텍스트의 토큰 수 자체가 다르므로 비교 단위는 토큰이 아니라 **USD 비용과 과제 성과**여야 한다.
4. 조사 보고서 권고: uncached/cached 두 모드 비교 설계도 가능하나, 본 리포 취지(실전 스택 비교)에는 각 백엔드의 실제 운용 조건 그대로 비교 + 캐싱 기여분을 보고서에서 분해 설명하는 편이 맞다.

## 5. 실험 설계에 반영한 결정

- 1차 지표를 토큰이 아닌 **완주 여부 + 총비용(USD)** 으로 설정 (→ README 측정·판정)
- Phase 0 파일럿에 **tool calling 왕복 검증**을 최우선 배치 (선행 사례 부재 + 조용한 실패 리스크)
- max output 8K(thinking 포함) → 긴 파일 Write 잘림 리스크를 파일럿 항목화
- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` 기본 적용
- 비용 정본은 Upstage Console 대시보드, 세션 로그는 보조 지표
