# 🔄 워크플로우 상세

Hayden 오케스트레이터의 전체 흐름을 phase 단위로 상세히 설명합니다.

---

## 전체 흐름 그림

```text
┌────────────────────────────────────────────────────────────┐
│ Phase 0 — 잠들기 전 (사용자 깨어있을 때)                  │
│  ─ PRD 자동 탐지                                          │
│  ─ PRD 리뷰 + 추가 기능 제안 → PRD_REVIEW.md              │
│  ─ 사용자 결정 항목 큐 → DECISIONS.md                     │
│  ─ 환경변수/계정 점검 가이드 → PREFLIGHT.md               │
│  ─ AI 모델 선택 (DECISIONS 추가)                          │
│  ─ 환경 타입 판정 → ENVIRONMENT.md                        │
│  ─ 작업 로그 초기화 → WORK_LOG.md                         │
│ ⛔ STOP: 사용자가 결정사항 채우고 "go" 할 때까지 대기     │
└────────────────────────────────────────────────────────────┘
                            ↓ "go"
┌────────────────────────────────────────────────────────────┐
│ Phase 1~N — 자율 루프 (사용자 자고 있음)                  │
│                                                            │
│  for phase in 1..N:                                        │
│    Step 1 (planner):  스킬 선택 → spec 작성               │
│    Step 2 (coder):    feature 브랜치에서 구현 + commit    │
│    Step 3 (reviewer): Codex 1순위 / superpowers fallback  │
│    Step 4 (반영):     P0/P1 → coder 재호출 (최대 3회)     │
│    Step 5 (머지):     테스트·빌드 통과 → develop 머지     │
│    Step 6 (로그):     WORK_LOG.md 갱신                    │
│    (선택) /context 슬래시 명령으로 컨텍스트 정리          │
│                                                            │
│  종료 조건 만족 시 break                                  │
│   - 모든 phase 완료                                       │
│   - BLOCKED 누적 5개 이상                                 │
│   - 같은 phase 3시간 진척 없음                            │
│   - critical 시스템 에러                                  │
└────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────┐
│ 종료 — 아침 보고                                          │
│  ─ MORNING_REPORT.md 생성                                 │
│  ─ (선택) Obsidian / 외부 노트 vault sync                 │
│  ─ 사용자 마무리 액션 안내 (develop → main 머지 등)       │
└────────────────────────────────────────────────────────────┘
```

---

## Phase 0 상세

### 입력
- `docs/PRD*.md` (자동 탐지, 여러 개면 가장 최신)

### Hayden의 작업 단계

#### 1. PRD 리뷰 (`PRD_REVIEW.md`)
- 모호한 요건 식별
- 누락된 비기능 요건(보안, 성능, 모니터링) 짚기
- 부드러운 톤, 지적이 아닌 제안

#### 2. 추가 기능 제안
- 사용자가 놓쳤을 만한 기능 (인증, 로깅, 에러 알림)
- 비용/시간 효율 관점의 대안

#### 3. 사용자 결정 항목 큐 (`DECISIONS.md`)
- 🔴 핵심 (Phase 1 시작 전 필수)
- 🟡 권장 (시작 전 결정하면 좋음)
- 🟢 선택 (빌드 중 결정 가능)
- 각 항목에 추천 옵션 + 이유 명시

#### 4. 사전 점검 (`PREFLIGHT.md`)
- 🔴 자기 전 반드시: API 키, OAuth 클라이언트, DB 접근
- 🟡 개발 중간: sandbox 계정
- 🟢 배포 직전: 도메인, 프로덕션 환경변수
- 각 항목에 발급처 URL + 절차 명시

#### 5. AI 모델 선택 (PRD에 LLM 호출 포함 시)
- 저비용 → 중간 → 고품질 옵션 제시
- 비용 추산 (할루시네이션 가능성 명시)

#### 6. 환경 타입 판정 (`ENVIRONMENT.md`)
- `local-only` / `serverless` / `integration` / `mixed` 중 하나
- 환경별 안전 규칙 적용

### 출력
5개 산출물 + 사용자 결정 대기

### 사용자 액션
- DECISIONS.md의 🔴 항목 결정
- PREFLIGHT.md의 🔴 항목 발급 진행
- 준비 완료 시 "Phase 1 시작" 또는 "go"

---

## Phase 1~N 상세

### Step 1 — 기획 단계 (`planner` 호출)

**스킬 선택 기준**:
- **bmad** 사용: PRD에 사용자 페르소나/여정/성공 지표가 명시되어 있거나 신규 제품·큰 기능 설계가 필요할 때
- **superpowers** 사용: 코드 작업 위주, 기존 시스템에 기능 추가, 버그 수정

산출물: `docs/plans/phase-N/`

```markdown
# Phase N 기획서
## 목표 (한 문장)
## 작업 목록 (체크리스트, 시간 추정 포함)
## 완료 기준 (Definition of Done)
## 의존성 (외부/내부)
## 리스크 / 막힐 가능성
```

### Step 2 — 구현 단계 (`coder` 호출)

1. `feature/phase-N-짧은이름` 브랜치 생성
2. superpowers TDD 스킬 활용 (테스트 먼저 → 구현 → 리팩토링)
3. 작업 단위 atomic commit, 메시지: `[Phase N] 작업명 — 한 줄 설명`
4. 린트 / 타입체크 / 테스트 자체 확인
5. 완료 보고 → planner 체크리스트 `[x]` 처리

### Step 3 — 리뷰 단계 (`reviewer` 호출)

1. `git diff develop...HEAD > /tmp/phase-N-diff.patch`
2. Codex CLI 호출 (1순위)
3. Codex 실패 / 부재 → superpowers `requesting-code-review` 또는 `pr-review-toolkit:code-reviewer` 호출 (fallback)
4. critical 영역(보안/DB/결제/외부 API)은 둘 다 동시 호출 (더블체크)
5. 결과를 P0(🔴 Critical) / P1(🟡 Major) / P2(🟢 Minor)로 분류 → `docs/reviews/phase-N.md`

### Step 4 — 반영 단계

리뷰 결과 처리:
- **🔴 Critical**: 즉시 coder 재호출
- **🟡 Major**: 즉시 coder 재호출
- **🟢 Minor**: 기록만, 다음 phase로

수정-리뷰 루프 최대 3회. 초과 시 BLOCKED.

### Step 5 — 머지 단계

머지 조건 (모두 통과해야):
- ✅ 리뷰 통과 (P0 없음)
- ✅ 테스트 모두 통과
- ✅ 빌드 / 타입체크 통과

머지: `feature/phase-N-XX` → `develop`

**`main` 머지는 사용자 작업** (아침 검토 후 직접 수행)

루프 3회 실패 시:
- commit은 그대로 보존 (revert 안 함)
- 머지 안 함
- BLOCKED.md에 브랜치명 기록
- 다음 phase로 이동

### Step 6 — 로그 단계

`WORK_LOG.md`에 phase 결과 추가:
```markdown
## Phase N — [작업명]
- 시작 / 완료 시간
- 스킬: bmad | superpowers
- 결과: 완료 | 부분완료 | blocked
- 리뷰 라운드: X회
- 변경 파일: 목록
- 비고: 한 줄 요약
```

### (선택) 컨텍스트 정리

매 phase 종료 직후, 다음 조건이면 `/context` 슬래시 명령으로 컨텍스트 비우기:
- 컨텍스트 윈도우 부담이 큼
- 다음 phase가 다른 도메인
- BLOCKED.md가 누적되어 흐름이 무거움

정리 전 반드시 WORK_LOG.md / BLOCKED.md / DECISIONS.md에 핸드오프 정보 충분히 기록.

---

## 막힘 정책

| 상황 | 대응 |
|---|---|
| 같은 에러가 3회 연속 발생 | BLOCKED 기록 → 다음 phase |
| 외부 의존성 없음 (토큰 / 키 / 계정) | BLOCKED 기록 → 의존하지 않는 phase로 |
| 같은 파일 수정-리뷰 루프 3회 초과 | BLOCKED 기록 → 다음 phase |
| 사용자 결정 필요한 분기 발생 | BLOCKED + DECISIONS.md에 결정 큐 추가 |
| 라이브러리/API 문서 모호 / deprecated | BLOCKED 기록 → 대안 검토 또는 다음 phase |
| 비용 발생 가능 작업 | BLOCKED → 사용자 승인 대기 |

기록 형식 (`BLOCKED.md`):
```markdown
## [Phase N] 작업명
- 막힌 이유:
- 시도한 방법:
- 사용자 결정/조치 필요사항:
- 우회 가능 여부: O / X
- (해당 시) 보존된 브랜치: feature/phase-N-XX
```

---

## 종료 조건 & 아침 보고

### 종료 트리거 (하나라도 만족)
1. 모든 phase 완료
2. BLOCKED 누적 5개 이상
3. 사용자 지정 종료 시각 도달
4. 같은 phase 3시간 진척 없음
5. Critical 시스템 에러

### MORNING_REPORT.md

```markdown
# 🌅 야간 작업 보고서 — YYYY-MM-DD

## 한눈에 보기
- ✅ 완료: X개 phase
- 🚧 진행 중: Y개
- 🔴 막힘: Z개
- 💡 제안: W개

## ✅ 완료한 작업 (phase별 1줄)
## 🔴 사용자 결정이 필요한 항목 (BLOCKED.md 추출)
## 💡 작업 중 발견한 개선 제안

## 🧑 사용자가 마무리해야 할 일
- [ ] develop → main 머지 검토
- [ ] BLOCKED 결정 항목 처리
- [ ] 신규 환경변수 등록
- [ ] (배포 시) 독립 코드 리뷰

## 다음에 할 일 (우선순위 순)

## 부록
- 변경 파일 목록
- 전체 작업 시간
- 외부 API 호출 횟수
- vault sync 결과 (선택)
```

---

## 핵심 원칙 재정리

1. **사용자가 자는 동안 깨우지 않는다** — 막히면 BLOCKED, 다음 phase 우회
2. **자식 응답은 휘발된다** — 모든 산출물은 반드시 파일로
3. **컨텍스트는 적극적으로 비운다** — 매 phase 종료 후 `/context`
4. **외부 LLM 리뷰는 더블체크** — Codex + superpowers, 충돌 시 엄격한 쪽
5. **결정은 추측하지 않는다** — DECISIONS.md에 큐 추가하고 대기
6. **main 브랜치는 사용자만** — develop까지만 머지, main은 아침 검토 후
7. **테스트·빌드 통과 = 머지 조건** — 깨진 상태 머지 금지
