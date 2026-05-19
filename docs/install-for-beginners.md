# 🌱 비개발자를 위한 Hayden 설치 가이드

> 이 문서는 **터미널을 거의 써 본 적 없는 분**을 위한 가이드입니다.
> 명령어 한 줄 한 줄 복사-붙여넣기로 따라 하면 됩니다.

---

## 🍎 시작하기 전 — 30초 마음의 준비

- 총 소요 시간: **약 25~40분** (계정 만들고 로그인하는 시간 포함)
- 필요한 것: 인터넷 연결된 Mac 또는 Linux 컴퓨터 (Windows는 별도 안내 참고)
- 막혔다면 [`docs/installation.md`](installation.md) 트러블슈팅 또는 GitHub Issues 활용

> 💡 **"왜 이렇게 많이 설치해야 하나요?"**
> Hayden은 본인이 모든 걸 다 하는 게 아니라, **여러 전문 도구를 조율**하는 오케스트레이터입니다.
> 마치 식당 매니저(Hayden)가 셰프(coder), 영양사(planner), 감사관(reviewer)에게 일을 시키는 구조예요. 각 도구가 그 전문가들입니다.

---

## 🧭 설치할 도구 한눈에 보기

| 순서 | 도구 | 왜 필요? | 필수도 | 시간 |
|---|---|---|---|---|
| 1 | **Claude Code CLI** | Hayden이 동작하는 베이스 플랫폼 | 🔴 필수 | 5분 |
| 2 | **Superpowers** | planner/coder가 사용하는 개발 방법론 스킬 | 🟢 강력 권장 | 2분 |
| 3 | **Token Savior MCP** | 토큰 절약 + 세션 간 기억. Hayden이 적극 활용 | 🟢 강력 권장 | 5분 |
| 4 | **Codex CLI** | reviewer가 1순위로 호출하는 외부 코드 리뷰 도구 | 🟡 권장 (있으면 리뷰 품질↑) | 10분 |
| 5 | **BMAD** | 대규모 신제품 PRD에 사용 (소규모면 불필요) | ⚪ 선택 | 5분 |

---

## 0️⃣ 터미널 열기

### Mac
- `⌘ + Space` → "터미널" 검색 → 엔터
- 또는 `Finder → 응용 프로그램 → 유틸리티 → 터미널`

### Linux
- 보통 `Ctrl + Alt + T`

### Windows
- **WSL (Windows Subsystem for Linux)** 설치를 추천합니다. Claude Code는 WSL 환경을 가장 잘 지원해요.
- 설치: PowerShell을 관리자 권한으로 열고 `wsl --install` 실행 후 재부팅. 이후 Ubuntu가 깔리면 Ubuntu 터미널에서 아래 단계 진행.
- WSL 안내: <https://learn.microsoft.com/windows/wsl/install>

> ✅ 검증: 터미널에 `echo hello` 입력 후 엔터. `hello`가 나오면 성공.

---

## 1️⃣ Claude Code CLI 설치 (필수)

### Mac / Linux

```bash
# npm 기반 설치 (가장 일반적)
npm install -g @anthropic-ai/claude-code
```

> ⚠️ `npm: command not found` 오류가 나면 Node.js부터 설치하세요.
> Mac: `brew install node` (Homebrew가 있는 경우) — Homebrew 없으면 <https://brew.sh> 에서 먼저 설치.
> Linux (Ubuntu): `sudo apt install nodejs npm`

### 로그인

```bash
claude login
```

브라우저가 열리며 Anthropic 계정 로그인 화면이 나옵니다. 계정 없으면 회원가입.

### 검증

```bash
claude --version
```

`2.x.x (Claude Code)` 형식이 나오면 성공. 🎉

> 📖 공식 문서: <https://docs.anthropic.com/claude/docs/claude-code>

---

## 2️⃣ Superpowers 설치 (강력 권장)

Hayden의 planner/coder가 사용하는 개발 방법론 스킬 셋입니다.

```bash
# Claude Code 플러그인 마켓플레이스에서 설치
claude plugin install superpowers@claude-plugins-official
```

> 💡 위 명령이 안 먹으면, Claude Code 안에서 `/plugins` 입력 → 메뉴에서 superpowers 찾아 설치.

### 검증

```bash
claude plugin list | grep superpowers
```

`superpowers@claude-plugins-official` 한 줄 보이면 성공.

---

## 3️⃣ Token Savior MCP 설치 (강력 권장)

토큰 절약(코드 탐색 효율화)과 세션 간 기억을 담당합니다. Hayden이 자동으로 활용해요.

### 3-1. uv 설치 (Python 패키지 관리자)

```bash
# Mac / Linux 공통
curl -LsSf https://astral.sh/uv/install.sh | sh
```

설치 후 터미널을 한 번 닫고 다시 열거나, `source ~/.zshrc` (Mac 기본 zsh) 또는 `source ~/.bashrc` (Linux 기본 bash) 실행.

### 3-2. token-savior 패키지 설치

```bash
uv tool install token-savior-recall
```

> ✅ 검증: `which token-savior` → 경로가 나오면 OK.

### 3-3. Claude Code에 MCP 서버로 등록

```bash
claude mcp add token-savior "$(which token-savior)" --scope user
```

> `--scope user` = 모든 프로젝트에서 자동 사용. 한 번만 등록하면 끝.

### 검증

```bash
claude mcp list | grep token-savior
```

`✓ Connected` 가 보이면 성공. 🎉

### (선택) 자동화 hook 켜기 — 한 줄 요청으로 끝

Token Savior가 더 적극 활용되도록 Claude Code에 자동 reminder hook 3개를 설치하면 좋아요:
- 큰 파일 Read 시 "더 가벼운 도구 쓰지 그래?" 자동 안내
- N턴마다 "이번 대화 중 기억할 거 있어?" 자동 점검
- 세션 시작 시 과거 메모리 자동 조회 안내

비개발자가 직접 손댈 필요 없이, **Claude Code 메인 세션에서 한 줄만** 요청하면 됩니다:

> 💬 "token-savior 자동화 hook 설치해줘"

Claude가 알아서 `~/.claude/scripts/` 에 스크립트 만들고 `~/.claude/settings.json` 의 hooks 섹션에 등록까지 처리해줘요. 설치 후 Claude Code 재시작 또는 `/hooks` 메뉴 한 번 열기로 활성화.

---

## 4️⃣ Codex CLI 설치 (권장 — 리뷰 품질 ↑)

reviewer 서브에이전트가 1순위로 호출하는 외부 코드 리뷰 도구입니다. 없어도 superpowers로 fallback되지만 있는 게 훨씬 좋아요.

```bash
# Claude Code 플러그인으로 설치 (가장 쉬움)
claude plugin install codex@openai-codex
```

> 또는 직접 CLI 설치: <https://github.com/openai/codex>

### OpenAI 계정 로그인

Codex는 OpenAI API를 사용하므로 OpenAI 계정과 API Key가 필요해요.

1. <https://platform.openai.com/api-keys> 에서 API Key 발급
2. 터미널에서 `codex login` 또는 환경변수 `OPENAI_API_KEY` 설정

### 검증

```bash
codex --version
```

> ⚠️ Codex는 사용량 기반 비용이 발생합니다. 사용 한도를 미리 설정하세요: <https://platform.openai.com/account/limits>

---

## 5️⃣ BMAD 설치 (선택 — 대규모 PRD에만)

소규모 기능 추가나 일반적인 작업에는 불필요합니다. **새 제품을 처음부터 만드는 PRD** 같은 대규모 작업에 도움됩니다.

설치 방법은 공식 가이드 참조: <https://github.com/bmadcode/BMAD-METHOD>

---

## 6️⃣ Hayden 에이전트 본체 설치

마지막 단계입니다.

```bash
# 1) 이 레포 clone
git clone https://github.com/qwert5046-commits/hayden-orchestrator.git
cd hayden-orchestrator

# 2) 4개 에이전트 정의 파일을 Claude Code의 agents 폴더로 복사
mkdir -p ~/.claude/agents
cp agents/*.md ~/.claude/agents/

# 3) 설치 확인
ls ~/.claude/agents/
```

`hayden.md`, `planner.md`, `coder.md`, `reviewer.md` 4개 파일이 보이면 성공.

---

## ✅ 마지막 점검 — 자동 스크립트

설치가 다 끝났는지 한 번에 확인할 수 있어요:

```bash
bash scripts/check-prerequisites.sh
```

누락된 도구가 있으면 어떤 명령어로 설치하면 되는지 알려줍니다.

---

## 🚀 첫 실행

1. 본인 프로젝트 폴더로 이동
2. `docs/PRD.md` 파일에 PRD 작성 (또는 `docs/PRD_xxx.md`)
3. Claude Code 메인 세션에서:

   ```text
   hayden 에이전트를 활용해 프로젝트 시작하자. docs/ 안에 PRD 있어.
   ```

4. Hayden이 Phase 0를 자동 실행하며 5개 산출물을 만들어 줍니다.

---

## 🆘 자주 막히는 부분

### "command not found: claude"
→ Claude Code 설치가 안 됐거나 PATH가 안 잡혔어요. 터미널 재시작 또는 `export PATH="$HOME/.local/bin:$PATH"` 시도.

### "permission denied" 오류
→ `sudo` 가 필요한 경우가 있습니다. `npm install -g` 가 막히면: Mac은 `brew install node`로 다시 설치 권장. Linux는 `sudo npm install -g @anthropic-ai/claude-code`.

### "uv: command not found" (Step 3-1 이후)
→ 터미널 재시작 안 했거나, PATH에 `$HOME/.local/bin` 이 없어요. `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc` 실행.

### MCP 등록 시 "conflicting scopes"
→ 같은 이름의 MCP가 이미 다른 scope에 등록되어 있어요. `claude mcp remove token-savior -s local` (또는 project) 로 잘못된 것 제거 후 재시도.

### Codex 로그인 실패
→ API Key가 잘못됐거나 OpenAI 계정 결제 정보가 없을 수 있어요. <https://platform.openai.com/account/billing> 확인.

---

## 🙋 그래도 막혔다면

- GitHub Issues: <https://github.com/qwert5046-commits/hayden-orchestrator/issues>
- Claude Code 자체 도움: 터미널에서 `claude` 실행 후 `/help`

문제 보고 시 다음 3가지를 알려주시면 빠르게 해결됩니다:
1. OS (Mac / Linux / Windows WSL)
2. 어느 Step에서 막혔는지
3. 에러 메시지 전문 (스크린샷도 OK)
