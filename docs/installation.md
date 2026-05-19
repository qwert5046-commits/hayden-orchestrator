# 📦 설치 가이드

Hayden 오케스트레이터를 본인 환경에 설치하는 자세한 절차입니다.

---

## 1. 사전 요구사항

### 필수
- **Claude Code CLI** 또는 동등 환경 (Cursor, Continue, Copilot CLI 등 sub-agent 지원)
- **Anthropic API 키** (또는 동등 LLM 제공자 키)
- Git, GitHub 계정

### 강력 권장
- **Superpowers 스킬 셋** — planner / coder가 사용
  - 설치: <https://github.com/obra/superpowers>
  - 포함 스킬: `brainstorming`, `writing-plans`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review` 등

### 선택
- **BMAD 메서드 스킬** — 큰 신규 제품 PRD에 사용
  - 설치: <https://github.com/bmadcode/BMAD-METHOD>
- **Codex CLI** — reviewer가 1순위로 호출
  - 설치: `npm i -g @openai/codex` 또는 <https://github.com/openai/codex>
  - 없으면 superpowers fallback으로 자동 우회
- **pr-review-toolkit 플러그인** — 더블체크 리뷰
  - Claude Code 플러그인 마켓에서 설치

---

## 2. 설치 단계

### 2.1 레포 clone

```bash
git clone https://github.com/qwert5046-commits/hayden-orchestrator.git
cd hayden-orchestrator
```

### 2.2 에이전트 파일 복사

#### 옵션 A: 글로벌 설치 (모든 프로젝트에서 사용)

```bash
mkdir -p ~/.claude/agents
cp agents/*.md ~/.claude/agents/
```

설치 후:
```bash
ls ~/.claude/agents/
# hayden.md  planner.md  coder.md  reviewer.md
```

#### 옵션 B: 프로젝트별 설치 (특정 프로젝트에서만)

프로젝트 루트에서:
```bash
mkdir -p .claude/agents
cp /path/to/hayden-orchestrator/agents/*.md .claude/agents/
```

### 2.3 Claude Code 재시작

설치 후 Claude Code를 한 번 재시작하면 4개 에이전트가 등록됩니다.

확인 명령 (Claude Code 메인 세션에서):
```
사용 가능한 에이전트 알려줘
```

`hayden`, `planner`, `coder`, `reviewer`가 목록에 보이면 OK.

---

## 3. 첫 사용

### 3.1 프로젝트 준비

```bash
mkdir my-new-project && cd my-new-project
mkdir docs
# docs/PRD.md 또는 docs/PRD_v1_xxx.md 작성 (자동 탐지)
```

### 3.2 Hayden 호출

Claude Code 메인 세션에서:

```text
hayden 에이전트로 이번 프로젝트 시작하자. docs/ 안에 PRD 있어.
```

Hayden이 Phase 0를 자동 실행하며 다음 5개 산출물을 생성합니다:

| 파일 | 용도 |
|---|---|
| `docs/PRD_REVIEW.md` | PRD 검토 코멘트 + 추가 기능 제안 |
| `docs/DECISIONS.md` | 사용자 결정 필요 항목 체크리스트 |
| `docs/PREFLIGHT.md` | 환경변수/토큰/계정 발급 가이드 |
| `docs/ENVIRONMENT.md` | 환경 타입 (`local-only` / `serverless` / `integration` / `mixed`) 판정 |
| `docs/WORK_LOG.md` | 작업 로그 (Phase별 기록) |

### 3.3 사용자 결정 → Phase 1 시작

1. `DECISIONS.md`를 열어 🔴 핵심 항목을 결정
2. `PREFLIGHT.md`의 🔴 자기 전 체크리스트를 진행 (API 키 발급, 계정 준비 등)
3. 준비 완료 시 한마디:
   ```
   Phase 1 시작
   ```
   또는
   ```
   go
   ```
4. Hayden이 자율 루프 진입 — planner / coder / reviewer를 순차 호출하며 진행

---

## 4. 자주 막히는 부분

### 4.1 "에이전트가 보이지 않음"
- Claude Code 재시작 필요
- `~/.claude/agents/` 경로가 맞는지 확인 (운영체제별로 다를 수 있음)
- 글로벌 설치 + 프로젝트별 설치가 동시에 있으면 프로젝트별이 우선

### 4.2 "Codex CLI 명령어가 다르다"
- Codex CLI 버전에 따라 `codex review` 옵션이 다를 수 있습니다
- `agents/reviewer.md` 의 §2 부분을 본인 Codex 버전에 맞게 수정
- Codex가 없거나 동작하지 않으면 자동으로 superpowers fallback 사용

### 4.3 "Phase 0가 무한 반복"
- PRD 파일이 `docs/` 안에 없거나 `PRD*.md` 패턴이 아님
- Hayden에게 직접 경로를 알려주면 진행

### 4.4 "planner가 bmad 스킬을 못 찾음"
- BMAD 스킬 셋이 설치되지 않은 경우
- 작은 프로젝트라면 hayden에게 "superpowers 스킬로 진행해줘" 라고 명시
- 또는 BMAD 설치: <https://github.com/bmadcode/BMAD-METHOD>

---

## 5. 다음 단계

- 본인 환경에 맞게 수정: [`customization.md`](customization.md)
- 전체 흐름 이해: [`workflow.md`](workflow.md)
