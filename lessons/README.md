# Lessons — 사이클에서 얻은 교훈 인덱스

실제 야간 사이클에서 발견된 교훈을 도메인 중립 형태로 보존한 디렉토리입니다.
한 lesson이 한 파일이며, **각 lesson은 적용 가능 조건(언제 끌어와야 하는지)**을 frontmatter로 표시합니다.

---

## 사용 원칙

- **모든 lesson은 retrievable knowledge**다. agents/*.md 본문에 박지 않는다.
- planner / coder / reviewer 가 본인 phase의 작업이 어떤 lesson 조건에 해당하는지 판단하고, 해당하면 그 lesson만 읽는다.
- hayden 은 phase 시작 시점에 "이 phase에 적용 가능한 lesson이 있나?" 자가 점검 후 결과를 `docs/WORK_LOG.md`에 1줄 기록한다 (예: `Phase 3: lessons applied = [L-003, L-007]`).
- **도메인에 적용 불가한 lesson을 끌어다 쓰지 않는다.** financial 도메인 lesson을 HR/수학 학원 앱에 적용하면 잘못된 추론을 유발한다.

---

## 인덱스

| ID | 제목 | 적용 도메인 | 한 줄 요약 |
|---|---|---|---|
| [L-001](L-001-codex-trust-level.md) | Codex trust_level 등록 필수 | 모든 도메인 | `~/.codex/config.toml` 미등록 시 sandbox=read-only → 응답 0줄 |
| [L-002](L-002-self-review-domain-quirks.md) | self-review는 도메인 quirk를 놓친다 | 모든 도메인 | critical 영역은 반드시 외부 LLM 리뷰 거쳐야 함 |
| [L-003](L-003-codex-base-mutex.md) | Codex `--base` 와 `[PROMPT]` mutex | 모든 도메인 | v0.125.0 기준 두 옵션 동시 사용 불가 |
| [L-004](L-004-external-llm-label-vs-safety.md) | 외부 LLM 위험도 ≠ 시스템 안전 정책 | 모든 도메인 | Codex P2도 안전장치 우회 가능이면 Critical 격상 |
| [L-005](L-005-gh-active-account.md) | gh CLI active 계정 점검 | 회사·개인 분리 환경 | push 전 `gh auth status` 강제 |
| [L-006](L-006-compact-not-callable.md) | `/compact` 는 Claude가 직접 호출 못 함 | 모든 도메인 | 슬래시 명령은 사용자 키 입력만 트리거 |
| [L-007](L-007-llm-sdk-replacement.md) | LLM SDK 교체 표준 절차 (6개 위치) | LLM/AI API 사용 PRD | 비용 정책 충돌 / 결제 문제 시 즉시 교체 |
| [L-008](L-008-followup-codex-review.md) | 사이클 외 follow-up Codex 리뷰 | 모든 도메인 | MORNING_REPORT 이후 추가 요청 처리 패턴 |
| [L-009](L-009-venv-pitfalls.md) | venv 환경 흔히 막히는 부분 | Python 프로젝트 | macOS python3 3.9 / 모듈 실행 / dotenv 줄바꿈 |
| [L-010](L-010-no-asking-policy.md) | 사용자에게 묻기 절대 금지 정책 | 모든 도메인 | 4가지 금지 패턴 + 올바른 우회 패턴 |
| [L-011](L-011-domain-adapter-compatibility.md) | 외부 API 어댑터 호환성 테스트 | 외부 데이터 API 사용 PRD | 어댑터 응답 자릿수·단위 mismatch 가드 |
| [L-012](L-012-llm-output-name-lookup.md) | LLM 인용 환각 → 권위 lookup 강제 교체 | LLM이 입력 데이터를 인용하는 PRD | system_prompt 만으로는 못 막음, 코드 단 override 필요 |

---

## 새 lesson 추가 규칙

신규 사이클에서 재발 가능 패턴을 발견하면 다음 형식으로 추가:

```markdown
---
id: L-XXX
title: 한 줄 제목
domain: [all | python | llm | external-api | gh-cli | ...]
applies_when: 이 lesson 끌어올 조건 한 줄
discovered_in: 발견 사이클 / 프로젝트 (도메인 익명화)
---

# L-XXX — 제목

## 증상
## 원인
## 대응
## 한계 / 적용 불가 케이스
```

도메인 특수 변수명(예: `ticker`, `watchlist`, `parse_holdings_sections`)은 lesson 본문에 노출하지 말고, **일반화된 변수명**(예: `entity_id`, `source_list`, `parse_sections`)으로 추상화한다. 원본 도메인 사례는 한 줄 `discovered_in` 메타로만 표시.
