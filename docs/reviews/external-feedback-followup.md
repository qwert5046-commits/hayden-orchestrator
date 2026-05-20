# 외부 피드백 반영 commit (eca5101) Codex 리뷰

- 리뷰 대상: `944c34a..eca5101` (외부 피드백 반영 refactor)
- 리뷰 도구: Codex CLI v0.125.0, model `gpt-5.5`, reasoning effort `xhigh`
- 응답 검증: 6104 줄 / verdict marker 102 건 / `^codex` 본문 마커 line 6079 — 모두 통과
- Raw 결과: `/tmp/hayden-orchestrator-codex-review.txt`

## Codex 종합 평가

> The new workflow introduces external assets and cost/lesson mechanisms, but the documented install path does not deploy those assets, cost accounting lacks required model rates, and direct lesson references do not resolve. These issues can break core Phase 0/lesson/cost-guard behavior for users following the updated instructions.

새 메커니즘(외부 자산 / 비용 가드 / lesson 참조) 자체는 좋은데 실제 사용 흐름에서 막히는 3 곳을 짚었다.

---

## 🟡 Major (안전 재분류 적용 후 — 수정 권장)

### M1. 새 런타임 자산이 설치 경로로 같이 안 깔림 — `README.md:97-106`

Codex 등급: P1
재분류 후: **Major** (사용자 첫 설치 동작 차단)

**현재 문제**:

```bash
# README 빠른 시작 — agents/*.md 만 복사
cp agents/*.md ~/.claude/agents/
```

agents 본문이 `lessons/`, `config/llm-routing.yml`, `docs/COST_TRACKER.md` 를 참조하는데 글로벌 설치만 따라하면 이 자산들이 사용자 프로젝트에 없어 Phase 0 / 모델 선택 / lesson 조회가 모두 실패.

**처방 후보**:

1. README quick-start 에 자산 복사 단계 추가 (사용자 프로젝트마다)
2. agents 가 자산을 hayden-orchestrator 설치 위치에서 resolve 하도록 변경
3. `scripts/setup-project.sh` 신설해서 한 줄로 모든 자산을 사용자 프로젝트에 scaffold

### M2. orchestrator 모델 단가 누락 — `config/llm-routing.yml:32-36`

Codex 등급: P2
재분류 후: **Major** ([L-004](../../lessons/L-004-external-llm-label-vs-safety.md) — 안전장치 우회 가능 패턴: 비용 가드가 우회됨)

**현재**:

```yaml
orchestrator:
  hayden: claude-opus-4-7
  planner: claude-sonnet-4-6
  coder: claude-sonnet-4-6
  reviewer: claude-sonnet-4-6
```

모델명만 있고 단가 없음. `docs/COST_TRACKER.md` 의 80 / 90 / 100% 가드가 orchestrator(Hayden + 서브에이전트) 호출 비용을 계산할 수 없어 **undercount → 가드 우회 가능**.

**처방**: 각 항목에 `cost_per_1m_input_usd` / `cost_per_1m_output_usd` 추가.

---

## 🟢 Minor

### m1. Wikilink 해상도 — `agents/*.md` 전반

Codex 등급: P2
재분류 후: **Minor 유지**

`[[lessons/L-006]]` 형식 wikilink 가 실제 파일명(`lessons/L-006-compact-not-callable.md`)과 매칭 안 됨. Obsidian 외 환경에서 클릭 불가.

**완화 가능 사유 — Minor 로 유지**: lesson 자체는 `lessons/README.md` 인덱스가 진짜 진입점이며 거기엔 정확한 마크다운 링크가 있음. lookup 자체는 인덱스로 가능. 단 GitHub 페이지에서 직접 wikilink 만 보고 따라가면 안 됨.

**처방 후보**:

1. Wikilink 를 마크다운 링크로 전환: `[L-006](../lessons/L-006-compact-not-callable.md)`
2. 또는 frontmatter `id` 만 사용해 인덱스로 redirect (현재 패턴 유지)

---

## 안전 재분류 사유 표 ([L-004](../../lessons/L-004-external-llm-label-vs-safety.md))

| 사례 | Codex 등급 | 재분류 | 사유 |
|---|---|---|---|
| 새 자산 미설치 | P1 | Major 유지 | 첫 설치 동작 차단 — critical 까지는 아님 (실행 결함 아님) |
| orchestrator 단가 누락 | P2 | **Major 격상** | 비용 가드 우회 가능 — 안전장치 우회 패턴 |
| Wikilink 해상도 | P2 | **Minor 로 완화** | 인덱스가 진짜 진입점이므로 lookup 작동 |

---

## 보고 요약 (Hayden 패턴)

- Critical: 0
- Major: 2 (M1 자산 설치 누락 / M2 단가 누락)
- Minor: 1 (wikilink)
- 자동 수정 권장: 예 (Major 2 개 — 사용자 첫 설치 + 비용 가드 정확성)
- 안전 재분류 발생: 1 건 (M2 — P2 → Major)
