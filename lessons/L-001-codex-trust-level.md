---
id: L-001
title: Codex CLI는 trust_level 등록 필요
domain: [all]
applies_when: reviewer 가 Codex CLI 호출하는 모든 phase
discovered_in: financial_assistant Cycle 1
---

# L-001 — Codex CLI 는 trust_level 등록 필요

## 증상
`codex review` 호출 시 응답이 멈추거나 0 line 반환. exit code 는 0 이라 reviewer 가 "통과"로 잘못 처리.

## 원인
`~/.codex/config.toml` 의 trusted_projects 리스트에 현재 프로젝트 경로가 등록되지 않으면 sandbox 가 `read-only` 로 떨어져 codex 가 정상 응답을 stream 하지 못함.

## 대응
- reviewer Step 1 (사전 점검)에서 `grep -A1 "$(pwd)" ~/.codex/config.toml` 로 등록 여부 확인.
- 미등록이면 `BLOCKED.md` 에 "Codex trust_level 미등록" 으로 기록하고 사용자에게 보고. 직접 `~/.codex/config.toml` 수정은 사용자만 가능.
- 등록 후 sandbox=workspace-write 로 동작.
