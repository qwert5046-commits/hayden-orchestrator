# 🌙 Hayden — 야간 자율 개발 오케스트레이터

> PRD를 던지고 자러 가면, 아침에 진척된 코드와 리포트가 기다리는 Claude Code 서브에이전트 세트

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built for Claude Code](https://img.shields.io/badge/Built%20for-Claude%20Code-orange)](https://docs.anthropic.com/claude/docs/claude-code)

---

## ✨ 핵심 아이디어

비개발자도, 또는 잠을 자는 사이에도, **PRD 한 장으로 phase 단위 개발이 굴러가도록** 만드는 오케스트레이터입니다.

- 🌅 **Phase 0 — 잠들기 전**: Hayden이 PRD를 읽고 리뷰 코멘트, 결정 필요 항목, 환경 점검 리스트를 만들어줍니다
- 🌙 **Phase 1~N — 자는 동안**: Hayden이 planner → coder → reviewer 서브에이전트를 직접 호출하며 자율 루프 진행
- ☀️ **아침**: `MORNING_REPORT.md` 한 장으로 밤사이 진척, 막힘, 다음 액션 확인

막힘 정책, 컨텍스트 관리, 데이터 보안, 백그라운드 코드 리뷰, 사이클 종료 후처리까지 한 번에 묶여있습니다.

---

## 🏗 구성

이 레포는 **4개의 Claude Code 서브에이전트 정의 파일**입니다.

| 에이전트 | 역할 | 도구 |
|---|---|---|
| [`hayden`](agents/hayden.md) | 야간 오케스트레이터. PRD → phase 분할 → 자식 호출 → 머지 → 보고 | Read/Write/Edit/Bash/Task/Glob/Grep/WebFetch |
| [`planner`](agents/planner.md) | phase 단위 기획서 작성 (bmad 또는 superpowers 스킬) | Read/Write/Edit/Glob/Grep |
| [`coder`](agents/coder.md) | 기획서 → 실제 코드 + commit (superpowers 기반 TDD) | Read/Write/Edit/Bash/Glob/Grep |
| [`reviewer`](agents/reviewer.md) | Codex CLI 백그라운드 리뷰 + superpowers fallback | Read/Bash/Glob/Grep/Write |

전체 흐름:

```text
사용자 (PRD 전달)
     ↓
[hayden]  PRD 읽고 Phase 0 산출물 5종 생성 → 사용자 결정 대기
     ↓
[hayden]  Phase 1 시작 → planner / coder / reviewer 순차 호출
     ↓
[planner] phase별 spec 생성 (docs/plans/phase-N/)
     ↓
[coder]   feature 브랜치에서 구현 + atomic commit
     ↓
[reviewer] Codex CLI 리뷰 → P0/P1/P2 분류
     ↓
[hayden]  P0 있으면 coder 재호출 (최대 3회), 통과하면 develop 머지
     ↓
... 모든 phase 완료 또는 BLOCKED 누적 5개까지 반복 ...
     ↓
MORNING_REPORT.md + (선택) Obsidian vault sync
```

---

## 🚀 빠른 시작

> 🌱 **비개발자라면 → [`docs/install-for-beginners.md`](docs/install-for-beginners.md) 부터 보세요.**
> 터미널 처음 쓰는 분도 따라할 수 있도록 명령어 한 줄씩 풀어쓴 가이드입니다.
> 설치 끝났는지 헷갈리면 `bash scripts/check-prerequisites.sh` 한 줄로 자동 점검 가능.

### 1. 사전 요구사항

- [Claude Code CLI](https://docs.anthropic.com/claude/docs/claude-code) 설치 및 Anthropic 계정 로그인
- (강력 권장) [Superpowers](https://github.com/obra/superpowers) 스킬 셋 설치 — planner / coder가 사용
- (강력 권장) **Token Savior MCP** — user scope에 등록 시 hayden이 코드 탐색·메모리 저장에 자동 활용 (`mcp__token-savior__find_symbol` / `get_function_source` / `memory_save_*` 등). 컨텍스트 압축 대안 정책에도 사용됨
- (선택) [BMAD](https://github.com/bmadcode/BMAD-METHOD) 스킬 셋 — 대규모 신규 제품 PRD에 사용
- (선택) [Codex CLI](https://github.com/openai/codex) — reviewer가 1순위로 호출. 없으면 superpowers 리뷰로 자동 fallback
- (선택) [pr-review-toolkit](https://docs.anthropic.com/claude/docs/claude-code/sub-agents) 플러그인 — fallback 리뷰 옵션 추가

### 2. 설치 (3단계)

```bash
# 1) 이 레포 clone
git clone https://github.com/qwert5046-commits/hayden-orchestrator.git
cd hayden-orchestrator

# 2) agents 폴더 4개 파일을 Claude Code agents 디렉토리에 복사
#    글로벌 설치 (모든 프로젝트에서 사용):
cp agents/*.md ~/.claude/agents/

#    또는 프로젝트별 설치 (현재 프로젝트에서만):
mkdir -p .claude/agents
cp agents/*.md .claude/agents/

# 3) 설치 확인
ls ~/.claude/agents/  # hayden.md / planner.md / coder.md / reviewer.md 보여야 함
```

### 3. 첫 실행

1. 프로젝트 폴더에 PRD를 작성 — 파일명은 `docs/PRD.md` 또는 `docs/PRD_xxx.md` (자동 탐지)
2. Claude Code 메인 세션에서:
   ```
   hayden 에이전트를 활용해 프로젝트 시작하자. docs/ 안에 PRD 있어.
   ```
3. Hayden이 Phase 0를 실행하며 다음 5개 산출물을 생성합니다:
   - `docs/PRD_REVIEW.md` — PRD 리뷰 코멘트 + 추가 기능 제안
   - `docs/DECISIONS.md` — 사용자가 결정해야 할 항목 체크리스트
   - `docs/PREFLIGHT.md` — 환경변수/토큰/계정 사전 점검 가이드
   - `docs/ENVIRONMENT.md` — 환경 타입 판정 + 적용 안전 규칙
   - `docs/WORK_LOG.md` — 작업 로그
4. DECISIONS.md를 채우고 PREFLIGHT 체크리스트를 진행한 뒤, **"Phase 1 시작"** 또는 **"go"** 한마디로 자율 루프 시작

자세한 설치·운영 가이드는 [`docs/installation.md`](docs/installation.md) 참고.

---

## 🎛 커스터마이즈 포인트

기본 설정은 단일 사용자 + 메인 세션 직접 모드 가정입니다. 본인 환경에 맞춰 조정하세요:

- **사용자 페르소나 / 언어**: `agents/hayden.md` 끝부분 "사용자와의 커뮤니케이션 톤" 섹션
- **AI 모델 비용 정책**: `agents/hayden.md` Phase 0 산출물 #5 (저비용 → 고품질 순으로 후보 제시)
- **Obsidian / 외부 노트 sync**: `agents/hayden.md` "사이클 종료 후처리" 섹션 (선택, 본인이 노트 시스템 쓸 때만)
- **호출 모드**: 메인 세션 직접 모드가 기본. 서브에이전트 모드 전환 시 `/context` 정책 수정 필요

자세한 가이드: [`docs/customization.md`](docs/customization.md)

---

## 🧠 설계 원칙

이 오케스트레이터가 따르는 5가지 원칙:

1. **사용자가 자는 동안 깨우지 않는다** — 막히면 BLOCKED.md에 기록하고 다음 phase로 우회
2. **자식 응답은 휘발된다** — 모든 산출물은 반드시 파일로 (WORK_LOG, BLOCKED, DECISIONS, spec, review)
3. **컨텍스트는 적극적으로 비운다** — 매 phase 종료 후 외부 파일(WORK_LOG)로 핸드오프, 사용자 깨어있을 때 `/compact` 권유, 자율 루프 중에는 `mcp__token-savior__memory_save_*` 영구 저장으로 압축 대안 수행
4. **외부 LLM 리뷰는 더블체크** — Codex 1순위, 실패 시 superpowers fallback, critical 영역은 둘 다 동시 실행
5. **사용자가 결정해야 할 건 절대 추측하지 않는다** — DECISIONS.md에 적어두고 대기

자세한 흐름 설명: [`docs/workflow.md`](docs/workflow.md)

---

## 📂 레포 구조

```
hayden-orchestrator/
├── README.md              ← 지금 이 파일
├── LICENSE                ← MIT 라이선스
├── agents/                ← Claude Code에 복사할 4개 에이전트 정의
│   ├── hayden.md          ← 오케스트레이터 (메인)
│   ├── planner.md         ← 기획자
│   ├── coder.md           ← 개발자
│   └── reviewer.md        ← 리뷰어
├── docs/
│   ├── installation.md    ← 설치 절차 + 트러블슈팅
│   ├── customization.md   ← 본인 환경에 맞게 수정하는 법
│   └── workflow.md        ← Phase 0 → 1~N 흐름 상세
└── .gitignore
```

---

## 🤝 기여 / 피드백

- 버그 / 개선 제안: [Issues](https://github.com/qwert5046-commits/hayden-orchestrator/issues)
- 본인 환경에서 개선한 버전은 fork 후 PR 환영

---

## 📜 라이선스

[MIT License](LICENSE) — 자유롭게 사용·수정·재배포 가능. 책임은 사용자에게 있습니다.

---

## 🙏 영감 / 참고

- [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) — 베이스 플랫폼
- [Superpowers](https://github.com/obra/superpowers) — TDD / debugging / planning 스킬 셋
- [BMAD Method](https://github.com/bmadcode/BMAD-METHOD) — 대규모 PRD 분해 방법론
- [Codex CLI](https://github.com/openai/codex) — 외부 LLM 코드 리뷰 도구
