---
id: L-003
title: Codex `--base` 옵션과 `[PROMPT]` 인자는 mutex
domain: [all]
applies_when: reviewer 가 Codex CLI v0.125.0 이상 호출하는 모든 phase
discovered_in: financial_assistant Cycle 1
---

# L-003 — Codex `--base` 와 `[PROMPT]` 는 mutex

## 증상
`codex review --base <SHA> "review this carefully"` 호출 시 mutex 충돌 에러.

## 대응 (v0.125.0 기준)
- `--base` 만 주고 `[PROMPT]` 는 생략 → codex 가 default 리뷰 prompt 사용
- 추가 지시가 필요하면 `codex review "<self-prompt>"` 로 옵션 없이 호출 (변경 자동 감지)
- `--title "..."` 는 옵션과 prompt 양쪽 모두에서 사용 가능

## 주의
Codex CLI 버전이 올라가면 옵션이 바뀔 수 있다. `codex review --help` 로 본인 버전 syntax 한 번 더 확인.
