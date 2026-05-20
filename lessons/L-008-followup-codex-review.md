---
id: L-008
title: 사이클 외 follow-up Codex 리뷰 (MORNING_REPORT 이후)
domain: [all]
applies_when: MORNING_REPORT 종결 후 사용자가 "전체 코드 리뷰 추가로 돌려줘" 요청
discovered_in: financial_assistant Cycle 1 follow-up
---

# L-008 — 사이클 외 follow-up Codex 리뷰

## 증상
hayden 사이클이 MORNING_REPORT 로 종결된 후 사용자가 "전체 코드 리뷰 추가로 돌려줘" 요청.

## 대응
reviewer 서브에이전트 호출 없이 hayden 직접 처리 가능 (단일 작업이라 격리 불필요). 단:

- 응답 검증, 안전 재분류([L-004](./L-004-external-llm-label-vs-safety.md)), 자동 수정 루프 등 reviewer 정책은 그대로 차용
- 결과 `docs/reviews/full-review.md` 로 저장
- Major / Critical 즉시 자동 수정 (사용자에게 묻지 않음)
- 수정 commit + `MORNING_REPORT.md` 끝에 "🔁 추가 Codex 사이클" 섹션 append
- 비용 트래커가 활성화돼 있으면 `docs/COST_TRACKER.md` 의 "사이클 외" 섹션에 호출 횟수 추가
