---
id: L-009
title: 사용자 venv 환경에서 흔히 막히는 부분
domain: [python]
applies_when: Python 프로젝트 PRD + 비개발자 사용자가 manual_test 로 직접 venv 검증
discovered_in: financial_assistant Cycle 1
---

# L-009 — venv 환경 흔히 막히는 부분

## 자주 발생하는 3개 시나리오

### 1. macOS 기본 `python3` 가 3.9.x
`python3 -m venv .venv` 로 만들면 3.9 가 잡혀 PEP 585 generic 문법(`dict[str, X]` 등)에서 부분 동작 안 됨.

**대응**:
- `python3.11 -m venv .venv` 로 명시
- `brew install python@3.11` 안내

### 2. `python src/main.py` 직접 실행
`from src.config import ...` ModuleNotFoundError 발생.

**대응**:
- `python -m src.main` 모듈 방식 강제
- GitHub Actions yml 도 동일 패턴

### 3. dotenv 줄바꿈 문제
JSON 시크릿(예: 서비스 계정 키)을 그대로 `.env` 에 붙여넣음 → dotenv 파싱 실패.

**대응**:
- `jq -c . <json파일> | tr -d '\n'` 으로 한 줄 압축 후 `.env` 에 단일 라인으로 명시
- `manual_test.md` 단계 1 에 굵게 명시

## 적용
Python 프로젝트가 아닌 경우 (Node.js / Go 등) 이 lesson 은 끌어오지 않는다. 다만 "모듈 실행 강제" 일반 패턴(Node 의 ESM resolution / Go 의 module path 등)은 같은 관점으로 별도 lesson 추가 후보.
