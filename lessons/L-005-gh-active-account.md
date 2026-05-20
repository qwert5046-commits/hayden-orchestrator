---
id: L-005
title: 회사·개인 GitHub 계정 분리 (gh CLI active 점검)
domain: [gh-cli, multi-account]
applies_when: 사용자 머신에 GitHub 계정 2개 이상 로그인된 경우 push 직전
discovered_in: 사용자 본인 환경
---

# L-005 — 회사·개인 GitHub 계정 분리

## 증상
사용자가 push 요청 → `git push` 실행 시 `Repository not found` (private 레포는 인증 실패도 not found 로 응답).

## 원인
gh CLI 에 회사 계정과 개인 계정 둘 다 로그인되어 있고 **회사 계정이 active**. 이 상태로 개인 레포에 push 시도 → 권한 없음. 회사·개인 자원 분리 정책 위반.

## 대응
push 전 반드시 다음 절차:

```bash
gh auth status                        # 두 계정 + active 확인
gh auth switch -u <개인계정명>         # 잘못된 active 면 전환
gh auth status                        # 전환 후 다시 확인
```

push 명령 자체는 안전(non-destructive)이지만, active 계정 잘못 설정은 정책 위반이다. hayden.md "GitHub / Git push 안전 점검" 섹션을 따른다.

## 적용 제외
사용자 머신에 GitHub 계정이 1개만 있으면 이 lesson 은 끌어오지 않는다 (over-engineering).
