# 💰 Cost Tracker — Cycle YYYY-MM-DD

> 이 파일은 **템플릿**입니다. 신규 사이클이 시작될 때 hayden 이 사이클 시작 시각 / 한도를 본 파일에 채우고, 매 phase 종료 시점에 호출 횟수와 비용을 누적합니다.

---

## 한도 (사용자가 사이클 시작 전 설정)

- **사이클 상한**: $10
- **Phase 별 상한**: $1.5
- 한도는 `docs/DECISIONS.md` 에 사용자가 직접 적은 값을 그대로 옮긴다 (없으면 위 디폴트).

## 가드 발동 시점

| 도달 | 동작 |
|---|---|
| 사이클 상한 80% (예: $8) | `MORNING_REPORT.md` 상단에 ⚠️ 경고 1줄 추가 |
| 사이클 상한 90% (예: $9) | **신규 phase 진입 정지** (현재 phase 는 완료까지 진행) → `BLOCKED.md` 에 비용 한도 도달 기록 |
| 사이클 상한 초과 (예: $10) | 즉시 BLOCKED + MORNING_REPORT 작성 |

추가로 phase 별 상한 초과는 해당 phase 끝나면 자동 BLOCKED, 다음 phase 진입 차단.

---

## 누적 (hayden 이 매 phase 종료 시 갱신)

| Phase | 시작 | 종료 | Codex 호출 | Claude API (planner/coder/reviewer 자체) | 생성 코드의 외부 LLM 호출 (Gemini 등) | 재시도 횟수 | Phase 누적 |
|---|---|---|---|---|---|---|---|
| Phase 1 | 22:10 | 22:48 | 2 회 | planner 1, coder 1 | 0 (코드 작성만) | 0 | $0.42 |
| Phase 2 | 22:48 | 23:31 | 3 회 (1 회 재호출) | planner 1, coder 2 | 0 | 1 | $0.67 |
| ... | ... | ... | ... | ... | ... | ... | ... |

**누적**: $1.09 / $10

> 비용 추정은 모델별 단가(`config/llm-routing.yml`)와 호출 횟수 / 토큰량 추정으로 계산. 정확도는 ±30% 수준이지만 **상대적인 누적 흐름**으로 사이클당 어느 정도 쓰는지 감을 잡을 수 있다.

---

## 사이클 외 (Follow-up 추가 호출)

MORNING_REPORT 종결 후 사용자 추가 요청으로 발생한 비용은 별도 섹션:

| 사유 | 시간 | 호출 | 비용 |
|---|---|---|---|
| full Codex 리뷰 follow-up | 다음날 09:30 | Codex 1 회 | $0.18 |

---

## 비용 산정 방식 (참고)

- Codex CLI: 호출당 입력 토큰 × cost_per_1m_input + 출력 토큰 × cost_per_1m_output (OpenAI 단가)
- Claude (orchestrator / 서브에이전트): 동일하게 `config/llm-routing.yml` 의 `orchestrator` 모델 단가 적용
- 생성 코드의 외부 LLM 호출: `config/llm-routing.yml` 의 `models.cheap` 단가 기준. 단 PRD 가 명시한 모델이 있으면 그쪽 우선.

추정치이므로 한도가 빠듯한 사이클은 사용자에게 **사전 안내** 권장.
