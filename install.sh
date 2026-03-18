#!/usr/bin/env bash
# memobank-skill installer
# Usage: curl -fsSL https://raw.githubusercontent.com/org/memobank-skill/main/install.sh | bash
#        Or: bash install.sh [--claude-code] [--codex] [--cursor] [--all]

set -euo pipefail

# Config
SKILL_REPO="${SKILL_REPO:-https://github.com/org/memobank-skill}"
SKILL_DIR="${HOME}/.claude/skills/memobank"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install for Claude Code
install_claude_code() {
  echo "→ Installing memobank skill for Claude Code..."
  mkdir -p "$SKILL_DIR/references"

  # Check if running from local repo or remote
  if [[ -f "./SKILL.md" ]]; then
    # Local install
    cp SKILL.md "$SKILL_DIR/SKILL.md"
    for f in claude-code.md memory-protocol.md fallback.md codex.md cursor.md; do
      [[ -f "./references/$f" ]] && cp "./references/$f" "$SKILL_DIR/references/$f"
    done
  else
    # Remote install
    curl -fsSL "$SKILL_REPO/raw/main/SKILL.md" -o "$SKILL_DIR/SKILL.md"
    for f in claude-code.md memory-protocol.md fallback.md codex.md cursor.md; do
      curl -fsSL "$SKILL_REPO/raw/main/references/$f" -o "$SKILL_DIR/references/$f"
    done
  fi

  echo -e "${GREEN}✓${NC} Skill installed: $SKILL_DIR"
}

# Install for Codex (AGENTS.md)
install_codex() {
  echo "→ Configuring Codex (AGENTS.md)..."

  local agents_file
  agents_file="${AGENTS_FILE:-AGENTS.md}"

  if [[ ! -f "$agents_file" ]]; then
    echo -e "${YELLOW}⚠${NC} No AGENTS.md found in current directory. Skipping Codex install."
    echo "   To specify a custom path, run: AGENTS_FILE=/path/to/AGENTS.md bash install.sh --codex"
    return
  fi

  # Check if already installed
  if grep -q "memobank" "$agents_file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} memobank already in AGENTS.md"
    return
  fi

  # Append snippet
  if [[ -f "./platform/codex/AGENTS-snippet.md" ]]; then
    cat ./platform/codex/AGENTS-snippet.md >> "$agents_file"
  else
    curl -fsSL "$SKILL_REPO/raw/main/platform/codex/AGENTS-snippet.md" >> "$agents_file"
  fi

  echo -e "${GREEN}✓${NC} Memory protocol appended to AGENTS.md"
}

# Install for Cursor
install_cursor() {
  echo "→ Configuring Cursor..."

  local cursor_dir=".cursor/rules"
  mkdir -p "$cursor_dir"

  local target_file="$cursor_dir/memobank.mdc"

  if [[ -f "$target_file" ]]; then
    echo -e "${GREEN}✓${NC} Cursor rule already exists: $target_file"
    return
  fi

  if [[ -f "./platform/cursor/memobank.mdc" ]]; then
    cp ./platform/cursor/memobank.mdc "$target_file"
  else
    curl -fsSL "$SKILL_REPO/raw/main/platform/cursor/memobank.mdc" -o "$target_file"
  fi

  echo -e "${GREEN}✓${NC} Cursor rule installed: $target_file"
}

# Suggest CLI installation
suggest_cli() {
  if command -v memo &>/dev/null; then
    return
  fi

  echo ""
  echo -e "${YELLOW}Tip:${NC} install memobank-cli for vector search + auto-capture:"
  echo "  npm install -g memobank-cli && memo install"
}

# Parse arguments
PLATFORMS=()
if [[ $# -eq 0 ]]; then
  # Default: install all
  PLATFORMS=("claude-code" "codex" "cursor")
else
  for arg in "$@"; do
    case "$arg" in
      --claude-code|claude-code) PLATFORMS+=("claude-code") ;;
      --codex|codex)             PLATFORMS+=("codex") ;;
      --cursor|cursor)           PLATFORMS+=("cursor") ;;
      --all|all)                 PLATFORMS=("claude-code" "codex" "cursor") ;;
      *)
        echo "Unknown option: $arg"
        echo "Usage: bash install.sh [--claude-code] [--codex] [--cursor] [--all]"
        exit 1
        ;;
    esac
  done
fi

# Run installations
for platform in "${PLATFORMS[@]}"; do
  case "$platform" in
    claude-code) install_claude_code ;;
    codex)       install_codex ;;
    cursor)      install_cursor ;;
  esac
done

# Suggest CLI
suggest_cli

# Done
echo ""
echo -e "${GREEN}Done.${NC} Start Claude Code and try:"
echo "  /memobank <your current task>"
