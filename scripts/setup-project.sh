#!/usr/bin/env bash
# Hayden 프로젝트 셋업 스크립트
# 사용법:
#   bash scripts/setup-project.sh                   # 현재 디렉토리에 자산 scaffold
#   bash scripts/setup-project.sh /path/to/project  # 지정 디렉토리에 scaffold
#
# 이 스크립트는 다음을 사용자 프로젝트에 복사합니다:
#   - lessons/             (전체 lesson 인덱스 + 개별 파일)
#   - config/llm-routing.yml
#   - docs/COST_TRACKER.md
#
# agents 본문이 위 자산을 참조하므로, 글로벌 agents 설치(`cp agents/*.md ~/.claude/agents/`)
# 만으로는 부족합니다. 사용자 프로젝트마다 이 스크립트 한 번 실행하면 됩니다.
#
# (Codex 리뷰 M1 fix — 새 자산이 사용자 프로젝트로 자동 깔리지 않던 문제)

set -eu

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 이 스크립트 위치 = hayden-orchestrator 레포 루트의 scripts/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# 대상 디렉토리 (인자 없으면 현재 작업 디렉토리)
TARGET="${1:-$(pwd)}"

if [ "$TARGET" = "$REPO_ROOT" ]; then
  printf "%b\n" "${YELLOW}⚠ 대상이 hayden-orchestrator 레포 루트 자신입니다. 다른 프로젝트 경로를 지정하세요.${NC}"
  printf "%b\n" "   예: bash scripts/setup-project.sh /path/to/my-project"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  printf "%b\n" "${YELLOW}⚠ 대상 디렉토리가 없습니다: $TARGET${NC}"
  exit 1
fi

printf "%b\n" ""
printf "%b\n" "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "%b\n" "${BLUE}  Hayden 자산 scaffold${NC}"
printf "%b\n" "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "%b\n" ""
printf "%b\n" "  레포: $REPO_ROOT"
printf "%b\n" "  대상: $TARGET"
printf "%b\n" ""

mkdir -p "$TARGET/lessons" "$TARGET/config" "$TARGET/docs"

# 1) lessons/ — 신규 파일만 (사용자 추가 lesson 보존)
if [ -d "$REPO_ROOT/lessons" ]; then
  cp -n "$REPO_ROOT/lessons/"*.md "$TARGET/lessons/" 2>/dev/null || true
  printf "%b\n" "  ${GREEN}✓${NC} lessons/ — $(ls "$TARGET/lessons/"*.md 2>/dev/null | wc -l | tr -d ' ') 파일 보장"
fi

# 2) config/llm-routing.yml — 없으면 복사 (있으면 보존)
if [ -f "$REPO_ROOT/config/llm-routing.yml" ]; then
  if [ -f "$TARGET/config/llm-routing.yml" ]; then
    printf "%b\n" "  ${YELLOW}⊝${NC} config/llm-routing.yml — 이미 있음 (보존)"
  else
    cp "$REPO_ROOT/config/llm-routing.yml" "$TARGET/config/"
    printf "%b\n" "  ${GREEN}✓${NC} config/llm-routing.yml — 복사 완료"
  fi
fi

# 3) docs/COST_TRACKER.md — 템플릿 (있으면 보존)
if [ -f "$REPO_ROOT/docs/COST_TRACKER.md" ]; then
  if [ -f "$TARGET/docs/COST_TRACKER.md" ]; then
    printf "%b\n" "  ${YELLOW}⊝${NC} docs/COST_TRACKER.md — 이미 있음 (보존)"
  else
    cp "$REPO_ROOT/docs/COST_TRACKER.md" "$TARGET/docs/"
    printf "%b\n" "  ${GREEN}✓${NC} docs/COST_TRACKER.md — 템플릿 복사 완료"
  fi
fi

printf "%b\n" ""
printf "%b\n" "${GREEN}🎉 scaffold 완료.${NC} 다음 단계:"
printf "%b\n" ""
printf "%b\n" "  1. docs/PRD.md 작성"
printf "%b\n" "  2. (Obsidian 사용 시) export HAYDEN_VAULT_PATH=\"/path/to/vault\""
printf "%b\n" "  3. Claude Code 메인 세션에서:"
printf "%b\n" "     ${BLUE}\"hayden 에이전트를 활용해 프로젝트 시작하자. docs/ 안에 PRD 있어.\"${NC}"
printf "%b\n" ""
