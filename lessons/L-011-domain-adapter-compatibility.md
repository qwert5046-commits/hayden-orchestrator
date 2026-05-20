---
id: L-011
title: 외부 데이터 API 어댑터 호환성 테스트 (자릿수·단위·부호 mismatch)
domain: [external-api]
applies_when: phase plan 에 신규 외부 데이터 API 어댑터 추가가 포함된 경우
discovered_in: financial_assistant Cycle 2 hotfix
---

# L-011 — 외부 데이터 API 어댑터 호환성 테스트

신규 외부 API 어댑터(시계열 / 가격 / 검색 / 인덱스 / 분석 데이터 등)를 추가할 때, 응답 형식의 **자릿수 · 단위 · 부호 표기 관습**이 기존 정규화 로직과 mismatch 일 가능성을 가드해야 한다. 첫 운영 호출에서 잘못 분류 / 환각 false positive 가 다발한다.

## phase plan 의무 task

플랜에 아래 두 항목을 반드시 명시한다:

- [ ] 어댑터 응답이 기존 정규화 / 검증 로직과 호환되는지 단위 테스트 추가
  - 음수 부호 / 자릿수 round / ratio↔% 변환 / regression 가드 케이스 포함
- [ ] 응답 값의 단위·자릿수(% / 배 / raw float / 분 / 초 등)를 일반화된 `memory/project_*_normalization.md` 와 대조

## 일반화된 위험 패턴

- 한 API 가 비율을 `0.123` 으로 주고 다른 API 는 `12.3` 으로 줄 때 (×100 mismatch)
- 같은 도메인에서 한 필드는 raw float, 다른 필드는 % suffix 가 붙어 있을 때
- 결손값(NaN / null / -999 / 빈 문자열) 표기가 어댑터마다 다를 때
- 시간대(UTC / local / epoch ms / epoch s) 표기 mismatch
- 어떤 외부 API 는 음수를 `-12.3` 으로 주고 다른 곳은 괄호 `(12.3)` 으로 줄 때

## 한계

이 lesson 은 "외부 데이터 API" 도메인이다. 내부 DB / 정적 설정 파일을 읽는 경우엔 끌어오지 않는다. PRD 가 LLM 출력만 다루면 [L-012](./L-012-llm-output-name-lookup.md) 가 더 적합.
