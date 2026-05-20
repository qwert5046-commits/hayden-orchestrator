---
id: L-010
title: 사용자에게 묻기 절대 금지 정책 (자율 진행 위반)
domain: [all]
applies_when: 야간 자율 루프 phase 전환 시점
discovered_in: hayden 초기 구현
---

# L-010 — 사용자에게 묻기 절대 금지 정책

## 증상
초기 hayden 은 phase 종료 시 사용자에게 "다음 phase 진입할까요?" 묻고 멈춤. 야간 자율 진행 의미 상실.

## 절대 금지 4 패턴
- ❌ "다음으로 무엇을 할까요?" / "어느 옵션이 좋을까요?" / "Phase X 진입할까요?" 질문 금지
- ❌ 리뷰 결과 `[USER]` 태그가 있어도 멈추지 말 것 → `DECISIONS.md` 에 큐로 추가
- ❌ "압축 후 이어가시려면 한마디 주세요" 같은 대기 안내 금지
- ❌ 사용자가 답할 선택지(1/2/3 등) 응답 끝에 나열 금지

## 올바른 패턴
모든 결정은 너 스스로:
- 리뷰가 자동 수정 권장이면 → 즉시 coder 재호출
- 사용자 결정 필요 항목 → `DECISIONS.md` 에 큐만 추가 후 다음 phase
- 다음 phase 명확하면 → 즉시 planner 호출
- 종료 조건 도달 → `MORNING_REPORT.md` 작성 후 응답 끝

## 예외 (멈춤 허용)
멈춤 사다리(escalation ladder)의 Level 3 / Level 4 만 즉시 정지 사유. hayden.md "막힘 사다리" 섹션 참조.
