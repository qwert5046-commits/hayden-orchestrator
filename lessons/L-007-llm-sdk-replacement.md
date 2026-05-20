---
id: L-007
title: AI/LLM SDK 교체 표준 절차 (6개 위치 동시 수정)
domain: [llm, ai-api]
applies_when: 사이클 중 LLM API 비용 정책 충돌 / 결제 문제 / 할당량 / 모델 deprecation 으로 SDK 교체 결정
discovered_in: financial_assistant Cycle 1 D-01
---

# L-007 — LLM SDK 교체 표준 절차

PRD 에서 선택한 LLM SDK 가 운영 중 비용 정책 충돌·결제 문제·할당량 등으로 교체 결정이 내려지면, 다음 6 개 위치를 동시에 수정한다.

## 6개 동시 수정 위치

| # | 위치(일반화) | 변경 내용 |
|---|---|---|
| 1 | 의존성 파일 (`requirements.txt` / `package.json` / `pyproject.toml` 등) | 기존 SDK 라인 제거 → 신규 SDK 추가 (정확한 버전 핀, 확인된 출처 코멘트) |
| 2 | 설정 모듈 (`config.*`) | 환경변수명 + Config 필드 + `_REQUIRED_VARS` 류 + 마스킹 로그 메시지 |
| 3 | LLM 호출 모듈 | SDK import / 모델 상수 / 호출 시그니처 / system prompt 전달 방식 / 응답 텍스트 추출 / usage 토큰 카운팅 / safety 설정 / 예외 분기 |
| 4 | 진입점 (`main.*`) | import + 함수 호출부 + 키워드 인자명 + 에러 메시지 |
| 5 | CI 파이프라인 (`.github/workflows/*.yml` 등) | env 블록 시크릿 매핑 |
| 6 | 문서 (`README` / `manual_test` / `DECISIONS`) | API 발급 안내 URL · 비용 추정 표 · 명령어 예시 · 전환 이력 |

## 코드 안전 패턴

- **모델 ID 환경변수 노출**: `os.environ.get("<PROVIDER>_MODEL", "<1순위>")` — 사용자가 폴백 모델로 강제 전환 가능
- **자동 폴백 로직**: `404` / `not found` / `unknown model` 패턴만 폴백 트리거. 인증 / 할당 / 타임아웃은 즉시 raise (폴백 의미 없음)
- **후방 호환 alias**: `generate_with_<old> = generate_with_<new>` — 진입점 일부 누락되어도 동작 유지
- **응답 텍스트 다단계 추출**: 단축 속성 → candidates → content → parts 순서로 폴백. safety 차단 시 ValueError 가능.
- **usage 필드 호환**: 새 SDK 필드명 + 구 SDK 필드명 모두 시도

## 사용자 액션 안내 동반

코드 변경과 별개로 사용자가 해야 할 액션을 응답에 명시:
- (A) 신규 API 키 발급 URL
- (B) `.env` 수정 (환경변수명 교체)
- (C) GitHub Secrets 갱신
- (D) 의존성 재설치 (`pip install -r requirements.txt` 등)
