---
id: L-002
title: self-review 는 도메인 quirk 를 놓친다
domain: [all]
applies_when: Codex / 외부 LLM 리뷰가 부재해 self-review 로 fallback 한 critical 영역 변경
discovered_in: 다중 사이클
---

# L-002 — self-review 는 도메인 quirk 를 놓친다

## 증상
코드 작성자가 직접 self-review 로 코드 검수해도 다음 같은 도메인 이슈는 잡지 못함:
- 외부 라이브러리의 비표준 표기 관습 (예: 특정 시계열 데이터가 의도와 다른 단위로 반환)
- 빈 환경변수가 `not None` 검사에서 truthy 로 떨어져 안전 모드 꺼짐
- 안전 검수가 단위 접미사 mismatch 로 정상 입력값을 잘못된 카테고리로 분류

## 원인
self-review 는 문법 / 패턴 이슈에만 강하며, 라이브러리 표기 관습 / deprecation / 안전 정책 우회 가능 코드 같은 도메인 quirk 는 외부 시각이 필요.

## 대응
- critical 영역(보안 경계, 인증·권한, 외부 API 신규 도입, 결제, DB 마이그레이션) 변경에는 반드시 외부 LLM 리뷰(Codex 또는 superpowers code-reviewer)를 거친다.
- Codex 인프라가 일시 불가하면 BLOCKED 기록 후 복구 후 재검증.
- self-review 로만 통과시킨 경우 MORNING_REPORT 에 "외부 재검증 미완" 명시.
