---
id: L-006
title: `/compact` 는 Claude 가 직접 호출 못 한다
domain: [all]
applies_when: 자율 루프 중 컨텍스트가 무거워졌을 때
discovered_in: 다중 사이클
---

# L-006 — `/compact` 는 Claude 가 직접 호출 못 한다

## 증상
컨텍스트가 무거워졌을 때 Claude 스스로 `/compact` 호출 시도 → 동작 안 함.

## 원인
슬래시 명령(`/context`, `/compact` 등)은 **사용자 키 입력만 트리거**. Claude 의 도구 함수로는 호출 불가.

## 대응
- 자동 컨텍스트 압축은 한도 도달 시 시스템이 처리 (Claude 액션 아님).
- Claude 의 책무는 슬래시 명령 호출이 아니라 **외부 파일 핸드오프**. 매 phase 완료 직후 `WORK_LOG.md` / `BLOCKED.md` / `DECISIONS.md` 에 핵심 정보 저장 → 자동 압축 후에도 다음 응답이 이어받을 수 있음.
- 사용자가 깨어있고 컨텍스트 무거워졌을 때 응답에 `/compact 권장. 핸드오프는 WORK_LOG에 있어 안전합니다` 한 줄만 안내. 멈추지 않음.
- Token Savior MCP 가 있으면 `memory_save_*` 도 압축 대안으로 활용 (영구 저장 → 컨텍스트에서 제거).
