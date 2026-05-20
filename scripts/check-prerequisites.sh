#!/usr/bin/env bash
# Hayden 사전 점검 스크립트
# 의존성을 4단 분류로 점검: 🔴 절대 필수 / 🟠 사실상 필수 / 🟡 권장 / ⚪ 선택
# 누락된 도구에 대해 설치 명령어만 안내합니다. 자동 설치는 하지 않습니다.

set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
GREY='\033[0;37m'
NC='\033[0m' # No color

ok=0
warn=0
missing=0
de_facto_missing=0

printf "%b\n" ""
printf "%b\n" "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "%b\n" "${BLUE}  Hayden 사전 점검 — 4단 분류 (실제 동작 기준)${NC}"
printf "%b\n" "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "%b\n" ""
printf "%b\n" "  🔴 절대 필수 = 없으면 동작 불가"
printf "%b\n" "  🟠 사실상 필수 = 자율 루프 품질 크게 저하"
printf "%b\n" "  🟡 권장 = 있으면 좋음 (critical 작업은 사실상 필요)"
printf "%b\n" "  ⚪ 선택 = 특정 PRD 에만"
printf "%b\n" ""

# 🔴 1) Claude Code CLI (절대 필수) ────────────────────
printf "%b\n" "${RED}🔴 1️⃣  Claude Code CLI (절대 필수)${NC}"
if command -v claude >/dev/null 2>&1; then
  ver=$(claude --version 2>/dev/null | head -1)
  printf "%b\n" "    ${GREEN}✓${NC} 설치됨 ($ver)"
  ok=$((ok+1))
else
  printf "%b\n" "    ${RED}✗${NC} 설치 안 됨 (없으면 너 자신이 동작 불가)"
  printf "%b\n" "    ${YELLOW}설치:${NC} npm install -g @anthropic-ai/claude-code"
  printf "%b\n" "    ${YELLOW}npm 없으면:${NC} Mac 'brew install node', Linux 'sudo apt install nodejs npm'"
  missing=$((missing+1))
fi
printf "%b\n" ""

# 🟠 2) Superpowers (사실상 필수) ────────────────────────
printf "%b\n" "${ORANGE}🟠 2️⃣  Superpowers 플러그인 (사실상 필수 — planner/coder 의존)${NC}"
if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -q "superpowers"; then
    printf "%b\n" "    ${GREEN}✓${NC} 설치됨"
    ok=$((ok+1))
  else
    printf "%b\n" "    ${ORANGE}✗${NC} 설치 안 됨 → planner/coder 가 적절히 동작 안 함"
    printf "%b\n" "    ${YELLOW}설치:${NC} claude plugin install superpowers@claude-plugins-official"
    de_facto_missing=$((de_facto_missing+1))
  fi
else
  printf "%b\n" "    ${GREY}⊝${NC} 건너뜀 (Claude Code 먼저 설치 필요)"
fi
printf "%b\n" ""

# 🟠 3) Token Savior MCP (사실상 필수) ─────────────────
printf "%b\n" "${ORANGE}🟠 3️⃣  Token Savior MCP (사실상 필수 — 컨텍스트 압축 정책 핵심)${NC}"
if command -v token-savior >/dev/null 2>&1; then
  if command -v claude >/dev/null 2>&1 && claude mcp list 2>/dev/null | grep -q "token-savior.*Connected"; then
    printf "%b\n" "    ${GREEN}✓${NC} 설치 + MCP 등록 + 연결 OK"
    ok=$((ok+1))
  elif command -v claude >/dev/null 2>&1; then
    printf "%b\n" "    ${ORANGE}⚠${NC} 패키지는 설치됐지만 MCP 등록·연결 안 됨"
    printf "%b\n" "    ${YELLOW}MCP 등록:${NC} claude mcp add token-savior \"\$(which token-savior)\" --scope user"
    de_facto_missing=$((de_facto_missing+1))
  else
    printf "%b\n" "    ${GREEN}✓${NC} 패키지 설치됨 (Claude Code 깔린 후 MCP 등록 필요)"
    ok=$((ok+1))
  fi
else
  printf "%b\n" "    ${ORANGE}✗${NC} 설치 안 됨 → 컨텍스트 압축 대안 작동 안 함"
  if command -v uv >/dev/null 2>&1; then
    printf "%b\n" "    ${YELLOW}설치:${NC} uv tool install token-savior-recall"
  else
    printf "%b\n" "    ${YELLOW}uv 먼저:${NC} curl -LsSf https://astral.sh/uv/install.sh | sh"
    printf "%b\n" "    ${YELLOW}그 다음:${NC} uv tool install token-savior-recall"
  fi
  printf "%b\n" "    ${YELLOW}MCP 등록:${NC} claude mcp add token-savior \"\$(which token-savior)\" --scope user"
  de_facto_missing=$((de_facto_missing+1))
fi
printf "%b\n" ""

# 🟡 4) Codex CLI (권장) ────────────────────────────────
printf "%b\n" "${YELLOW}🟡 4️⃣  Codex CLI (권장 — 없으면 self-review fallback, critical 작업은 BLOCKED)${NC}"
if command -v codex >/dev/null 2>&1; then
  printf "%b\n" "    ${GREEN}✓${NC} 설치됨"
  ok=$((ok+1))
elif command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q "codex@"; then
  printf "%b\n" "    ${GREEN}✓${NC} Claude Code 플러그인으로 설치됨"
  ok=$((ok+1))
else
  printf "%b\n" "    ${YELLOW}⚠${NC} 설치 안 됨 (없어도 superpowers fallback)"
  printf "%b\n" "    ${YELLOW}설치:${NC} claude plugin install codex@openai-codex"
  printf "%b\n" "    ${YELLOW}로그인:${NC} codex login (OpenAI 계정 + API Key)"
  printf "%b\n" "    ${GREY}참고:${NC} critical 영역(보안/인증/DB/결제) 변경에는 self-review 가 BLOCKED 처리됨"
  warn=$((warn+1))
fi
printf "%b\n" ""

# 🟡 5) Token Savior 자동화 hooks (권장) ────────────────
printf "%b\n" "${YELLOW}🟡 5️⃣  Token Savior 자동화 hooks (권장 — 적극 활용을 유도)${NC}"
settings="$HOME/.claude/settings.json"
if [ -f "$settings" ] && command -v jq >/dev/null 2>&1; then
  read_hook=$(jq -r '.hooks.PreToolUse[]?.hooks[]?.command // empty' "$settings" 2>/dev/null | grep -c "token-savior-read-warn" || true)
  stop_hook=$(jq -r '.hooks.Stop[]?.hooks[]?.command // empty' "$settings" 2>/dev/null | grep -c "token-savior-memory-reminder" || true)
  start_hook=$(jq -r '.hooks.SessionStart[]?.hooks[]?.command // empty' "$settings" 2>/dev/null | grep -c "token-savior-session-start" || true)
  total=$((read_hook + stop_hook + start_hook))

  if [ "$total" -eq 3 ]; then
    printf "%b\n" "    ${GREEN}✓${NC} 3개 hook 모두 설치됨"
    ok=$((ok+1))
  elif [ "$total" -gt 0 ]; then
    printf "%b\n" "    ${YELLOW}⚠${NC} 일부 hook 만 설치됨 ($total/3)"
    [ "$read_hook" -eq 0 ] && printf "%b\n" "        ❌ PreToolUse on Read (token-savior-read-warn.sh)"
    [ "$stop_hook" -eq 0 ] && printf "%b\n" "        ❌ Stop (token-savior-memory-reminder.sh)"
    [ "$start_hook" -eq 0 ] && printf "%b\n" "        ❌ SessionStart (token-savior-session-start.sh)"
    printf "%b\n" "    ${YELLOW}설치:${NC} Claude 메인 세션에서 \"token-savior 자동화 hook 설치해줘\""
    warn=$((warn+1))
  else
    printf "%b\n" "    ${YELLOW}⚠${NC} 자동화 hook 미설치"
    printf "%b\n" "    ${YELLOW}효과:${NC} 큰 파일 Read 자동 경고 / N턴마다 메모리 reminder / 세션 시작 memory_index 안내"
    printf "%b\n" "    ${YELLOW}설치:${NC} Claude 메인 세션에서 \"token-savior 자동화 hook 설치해줘\""
    warn=$((warn+1))
  fi
else
  printf "%b\n" "    ${GREY}⊝${NC} 건너뜀 ($settings 또는 jq 없음)"
fi
printf "\n"

# ⚪ 6) BMAD (선택) ──────────────────────────────────────
printf "%b\n" "${GREY}⚪ 6️⃣  BMAD 스킬 (선택 — 대규모 신규 제품 PRD 에만)${NC}"
if command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q "bmad"; then
  printf "%b\n" "    ${GREEN}✓${NC} 설치됨"
  ok=$((ok+1))
else
  printf "%b\n" "    ${GREY}⊝${NC} 미설치 (대규모 PRD 가 없으면 불필요)"
  printf "%b\n" "    ${GREY}설치 안내:${NC} https://github.com/bmadcode/BMAD-METHOD"
fi
printf "\n"

# 🔴 7) Hayden 에이전트 본체 (절대 필수) ────────────────
printf "%b\n" "${RED}🔴 7️⃣  Hayden 에이전트 정의 4 개 파일 (절대 필수)${NC}"
if [ -f "$HOME/.claude/agents/hayden.md" ]; then
  count=$(ls "$HOME/.claude/agents/"{hayden,planner,coder,reviewer}.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" = "4" ]; then
    printf "%b\n" "    ${GREEN}✓${NC} 4 개 에이전트 모두 ~/.claude/agents/ 에 설치됨"
    ok=$((ok+1))
  else
    printf "%b\n" "    ${YELLOW}⚠${NC} 일부만 설치됨 ($count/4)"
    printf "%b\n" "    ${YELLOW}설치:${NC} 이 레포 루트에서 'cp agents/*.md ~/.claude/agents/'"
    warn=$((warn+1))
  fi
else
  printf "%b\n" "    ${RED}✗${NC} 설치 안 됨"
  printf "%b\n" "    ${YELLOW}설치:${NC} 'mkdir -p ~/.claude/agents && cp agents/*.md ~/.claude/agents/'"
  missing=$((missing+1))
fi
printf "%b\n" ""

# 결과 요약 ─────────────────────────────────────────────
printf "%b\n" "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "%b\n" "  결과: ${GREEN}✓ $ok 통과${NC} / ${ORANGE}✗ $de_facto_missing 사실상 필수 누락${NC} / ${YELLOW}⚠ $warn 권장 누락${NC} / ${RED}✗ $missing 절대 필수 누락${NC}"
printf "%b\n" "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "%b\n" ""

if [ "$missing" -gt 0 ]; then
  printf "%b\n" "${RED}❌ 절대 필수 도구가 누락됐어요.${NC} 위 안내를 따라 설치 후 다시 실행하세요."
  exit 1
elif [ "$de_facto_missing" -gt 0 ]; then
  printf "%b\n" "${ORANGE}⚠️  사실상 필수 도구가 누락됐어요.${NC} 자율 루프 품질이 크게 떨어집니다."
  printf "%b\n" "    꼭 진행해야 한다면 사용자가 명시적으로 동의해야 합니다 (hayden 이 경고 후 진행)."
  exit 0
elif [ "$warn" -gt 0 ]; then
  printf "%b\n" "${YELLOW}⚠️  권장 도구 일부 누락.${NC} 동작은 하지만 critical 작업은 self-review 한계로 BLOCKED 가능."
  exit 0
else
  printf "%b\n" "${GREEN}🎉 모든 준비가 끝났어요! Hayden 을 호출해 보세요.${NC}"
  printf "%b\n" ""
  printf "%b\n" "    첫 사용: docs/PRD.md 작성 후 Claude Code 메인 세션에서"
  printf "%b\n" "    ${BLUE}\"hayden 에이전트를 활용해 프로젝트 시작하자. docs/ 안에 PRD 있어.\"${NC}"
  exit 0
fi
