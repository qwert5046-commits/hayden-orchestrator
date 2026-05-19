#!/usr/bin/env bash
# Hayden 사전 점검 스크립트
# 4개 의존성(Claude Code / Superpowers / Token Savior / Codex) 설치 여부를 확인하고,
# 누락된 도구에 대해 설치 명령어만 안내합니다. 자동 설치는 하지 않습니다.

set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

ok=0
warn=0
missing=0

printf "%b\n" ""
printf "%b\n" "${BLUE}═══════════════════════════════════════════════${NC}"
printf "%b\n" "${BLUE}  Hayden 사전 점검 — 의존성 설치 여부 확인${NC}"
printf "%b\n" "${BLUE}═══════════════════════════════════════════════${NC}"
printf "%b\n" ""

# 1) Claude Code CLI ─────────────────────────────────────
printf "%b\n" "1️⃣  Claude Code CLI..."
if command -v claude >/dev/null 2>&1; then
  ver=$(claude --version 2>/dev/null | head -1)
  printf "%b\n" "   ${GREEN}✓${NC} 설치됨 ($ver)"
  ok=$((ok+1))
else
  printf "%b\n" "   ${RED}✗${NC} 설치 안 됨 (필수)"
  printf "%b\n" "   ${YELLOW}설치 명령:${NC} npm install -g @anthropic-ai/claude-code"
  printf "%b\n" "   ${YELLOW}npm이 없다면:${NC} Mac은 'brew install node', Linux는 'sudo apt install nodejs npm'"
  missing=$((missing+1))
fi
printf "%b\n" ""

# 2) Superpowers 플러그인 ─────────────────────────────────
printf "%b\n" "2️⃣  Superpowers 플러그인..."
if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -q "superpowers"; then
    printf "%b\n" "   ${GREEN}✓${NC} 설치됨"
    ok=$((ok+1))
  else
    printf "%b\n" "   ${YELLOW}⚠${NC} 설치 안 됨 (강력 권장 — planner/coder 가 사용)"
    printf "%b\n" "   ${YELLOW}설치 명령:${NC} claude plugin install superpowers@claude-plugins-official"
    warn=$((warn+1))
  fi
else
  printf "%b\n" "   ${YELLOW}⊝${NC} 건너뜀 (Claude Code 먼저 설치 필요)"
fi
printf "%b\n" ""

# 3) Token Savior MCP ───────────────────────────────────
printf "%b\n" "3️⃣  Token Savior MCP..."
if command -v token-savior >/dev/null 2>&1; then
  # MCP 등록 여부도 확인
  if command -v claude >/dev/null 2>&1 && claude mcp list 2>/dev/null | grep -q "token-savior.*Connected"; then
    printf "%b\n" "   ${GREEN}✓${NC} 설치 + MCP 등록 + 연결 OK"
    ok=$((ok+1))
  elif command -v claude >/dev/null 2>&1; then
    printf "%b\n" "   ${YELLOW}⚠${NC} 패키지는 설치됐지만 MCP 등록이 안 됨/연결 안 됨"
    printf "%b\n" "   ${YELLOW}MCP 등록:${NC} claude mcp add token-savior \"\$(which token-savior)\" --scope user"
    warn=$((warn+1))
  else
    printf "%b\n" "   ${GREEN}✓${NC} 패키지 설치됨 (Claude Code 깔린 후 MCP 등록 필요)"
    ok=$((ok+1))
  fi
else
  printf "%b\n" "   ${YELLOW}⚠${NC} 설치 안 됨 (강력 권장 — 토큰 절약 + 세션 간 기억)"
  if command -v uv >/dev/null 2>&1; then
    printf "%b\n" "   ${YELLOW}설치 명령:${NC} uv tool install token-savior-recall"
  else
    printf "%b\n" "   ${YELLOW}먼저 uv 설치:${NC} curl -LsSf https://astral.sh/uv/install.sh | sh"
    printf "%b\n" "   ${YELLOW}그 다음:${NC} uv tool install token-savior-recall"
  fi
  printf "%b\n" "   ${YELLOW}그 다음 MCP 등록:${NC} claude mcp add token-savior \"\$(which token-savior)\" --scope user"
  warn=$((warn+1))
fi
printf "%b\n" ""

# 4) Codex CLI ──────────────────────────────────────────
printf "%b\n" "4️⃣  Codex CLI..."
if command -v codex >/dev/null 2>&1; then
  printf "%b\n" "   ${GREEN}✓${NC} 설치됨"
  ok=$((ok+1))
elif command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q "codex@"; then
  printf "%b\n" "   ${GREEN}✓${NC} Claude Code 플러그인으로 설치됨"
  ok=$((ok+1))
else
  printf "%b\n" "   ${YELLOW}⚠${NC} 설치 안 됨 (권장 — reviewer 가 1순위로 호출)"
  printf "%b\n" "   ${YELLOW}설치 명령:${NC} claude plugin install codex@openai-codex"
  printf "%b\n" "   ${YELLOW}로그인:${NC} codex login  (OpenAI 계정 + API Key 필요)"
  printf "%b\n" "   ${YELLOW}참고:${NC} 없으면 superpowers 리뷰로 자동 fallback — 그래도 동작은 함"
  warn=$((warn+1))
fi
printf "%b\n" ""

# 5) Token Savior 자동화 hooks (선택, 있으면 더 강력) ────
printf "%b\n" "5️⃣  Token Savior 자동화 hooks..."
settings="$HOME/.claude/settings.json"
if [ -f "$settings" ] && command -v jq >/dev/null 2>&1; then
  read_hook=$(jq -r '.hooks.PreToolUse[]?.hooks[]?.command // empty' "$settings" 2>/dev/null | grep -c "token-savior-read-warn" || true)
  stop_hook=$(jq -r '.hooks.Stop[]?.hooks[]?.command // empty' "$settings" 2>/dev/null | grep -c "token-savior-memory-reminder" || true)
  start_hook=$(jq -r '.hooks.SessionStart[]?.hooks[]?.command // empty' "$settings" 2>/dev/null | grep -c "token-savior-session-start" || true)
  total=$((read_hook + stop_hook + start_hook))

  if [ "$total" -eq 3 ]; then
    printf "%b\n" "   ${GREEN}✓${NC} 3개 hook 모두 설치됨 (Read 경고 + Stop 메모리 reminder + SessionStart 부팅)"
    ok=$((ok+1))
  elif [ "$total" -gt 0 ]; then
    printf "%b\n" "   ${YELLOW}⚠${NC} 일부 hook만 설치됨 ($total/3)"
    [ "$read_hook" -eq 0 ] && printf "%b\n" "       ❌ PreToolUse on Read (token-savior-read-warn.sh)"
    [ "$stop_hook" -eq 0 ] && printf "%b\n" "       ❌ Stop (token-savior-memory-reminder.sh)"
    [ "$start_hook" -eq 0 ] && printf "%b\n" "       ❌ SessionStart (token-savior-session-start.sh)"
    printf "%b\n" "   ${YELLOW}설치 안내:${NC} Claude Code 메인 세션에서"
    printf "%b\n" "     ${BLUE}\"token-savior 자동화 hook 설치해줘\"${NC} 라고 요청하면"
    printf "%b\n" "     Claude가 ~/.claude/scripts/ 에 스크립트 3개 만들고 settings.json hooks 등록까지 자동 처리합니다."
    warn=$((warn+1))
  else
    printf "%b\n" "   ${YELLOW}⚠${NC} 자동화 hook 미설치 (선택 — 있으면 Claude가 token-savior 도구를 더 적극 활용)"
    printf "%b\n" "   ${YELLOW}효과:${NC} 큰 파일 Read 시 자동 경고, N턴마다 메모리 저장 reminder, 세션 시작 시 memory_index 안내"
    printf "%b\n" "   ${YELLOW}설치 안내:${NC} Claude Code 메인 세션에서"
    printf "%b\n" "     ${BLUE}\"token-savior 자동화 hook 설치해줘\"${NC} 라고 요청하세요."
    printf "%b\n" "     Claude가 ~/.claude/scripts/ 에 스크립트 3개 만들고 settings.json hooks 등록까지 자동 처리합니다."
    warn=$((warn+1))
  fi
else
  printf "%b\n" "   ${YELLOW}⊝${NC} 건너뜀 ($settings 또는 jq 없음 — Claude Code 먼저 설치 필요)"
fi
printf "\n"

# 6) Hayden 에이전트 본체 ────────────────────────────────
printf "%b\n" "6️⃣  Hayden 에이전트 정의 파일..."
if [ -f "$HOME/.claude/agents/hayden.md" ]; then
  count=$(ls "$HOME/.claude/agents/"{hayden,planner,coder,reviewer}.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" = "4" ]; then
    printf "%b\n" "   ${GREEN}✓${NC} 4개 에이전트 모두 ~/.claude/agents/ 에 설치됨"
    ok=$((ok+1))
  else
    printf "%b\n" "   ${YELLOW}⚠${NC} 일부만 설치됨 ($count/4)"
    printf "%b\n" "   ${YELLOW}설치:${NC} 이 레포 루트에서 'cp agents/*.md ~/.claude/agents/'"
    warn=$((warn+1))
  fi
else
  printf "%b\n" "   ${RED}✗${NC} 설치 안 됨 (필수)"
  printf "%b\n" "   ${YELLOW}설치:${NC} 이 레포 루트에서 'mkdir -p ~/.claude/agents && cp agents/*.md ~/.claude/agents/'"
  missing=$((missing+1))
fi
printf "%b\n" ""

# 결과 요약 ─────────────────────────────────────────────
printf "%b\n" "${BLUE}═══════════════════════════════════════════════${NC}"
printf "%b\n" "  결과: ${GREEN}✓ $ok${NC} / ${YELLOW}⚠ $warn${NC} / ${RED}✗ $missing${NC}"
printf "%b\n" "${BLUE}═══════════════════════════════════════════════${NC}"
printf "%b\n" ""

if [ "$missing" -gt 0 ]; then
  printf "%b\n" "${RED}❌ 필수 도구가 누락됐어요.${NC} 위 안내를 따라 설치 후 다시 실행하세요."
  exit 1
elif [ "$warn" -gt 0 ]; then
  printf "%b\n" "${YELLOW}⚠️  강력 권장 도구가 누락됐어요.${NC} Hayden은 동작하지만 품질·효율이 떨어집니다."
  printf "%b\n" "   괜찮다면 그냥 진행해도 되고, 위 안내대로 추가 설치하면 더 좋아요."
  exit 0
else
  printf "%b\n" "${GREEN}🎉 모든 준비가 끝났어요! Hayden을 호출해 보세요.${NC}"
  printf "%b\n" ""
  printf "%b\n" "   첫 사용: docs/PRD.md 작성 후 Claude Code 메인 세션에서"
  printf "%b\n" "   ${BLUE}\"hayden 에이전트를 활용해 프로젝트 시작하자. docs/ 안에 PRD 있어.\"${NC}"
  exit 0
fi
