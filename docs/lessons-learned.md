# Lessons Learned — 이전 위치 (이동됨)

> 이 파일은 더 이상 사용되지 않습니다. 모든 lesson 은 [`lessons/`](../lessons/) 디렉토리로 이전되었고, lesson 마다 개별 파일 + frontmatter 메타(`domain`, `applies_when`)를 갖도록 재구성되었습니다.

## 이전 이유

이전에는 `docs/lessons-learned.md` 한 파일에 모든 lesson 을 묶어 두었고, 일부 lesson 은 agents/*.md 본문에도 도메인 코드 사례와 함께 박혀 있었습니다.

이 구조에서 두 가지 문제가 있었습니다:

1. **컨텍스트 인플레이션**: agents/*.md 가 매번 모든 도메인 사례를 함께 로드 → 다음 phase 마다 같은 사례가 반복 노출.
2. **도메인 오염**: 이전 사이클의 도메인 특수 변수명(`ticker`, `watchlist` 등) 이 다른 도메인 PRD 에 적용될 때 잘못된 추론을 유발할 가능성.

## 새 구조

- 각 lesson 은 `lessons/L-XXX-<slug>.md` 단일 파일
- frontmatter `domain` / `applies_when` 으로 끌어올 조건 명시
- `lessons/README.md` 인덱스에서 한눈에 조회 가능
- agents/*.md 는 본문에 lesson 코드 사례를 박지 않고 `[[L-XXX]]` 링크만

## 새 진입점

[`lessons/README.md`](../lessons/README.md) 부터 시작하세요.
