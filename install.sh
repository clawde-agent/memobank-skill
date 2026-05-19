#!/usr/bin/env bash
# memobank-skill installer
# Recommended: npx skills add clawde-agent/memobank-skill/memobank
# Manual:      curl -fsSL <url> -o install.sh && cat install.sh && bash install.sh
# Usage:       bash install.sh [--claude-code] [--codex] [--cursor] [--gemini] [--qwen] [--all]

set -euo pipefail

# Verify we are NOT running as root
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "Error: do not run this installer as root." >&2
  exit 1
fi

# Config
SKILL_REPO="${SKILL_REPO:-https://github.com/clawde-agent/memobank-skill}"
SKILL_DIR="${HOME}/.claude/skills/memobank"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Download a file and verify its SHA-256 matches an expected value.
# Usage: safe_download <url> <dest> <expected_sha256>
# Pass expected_sha256="" to skip verification (prints a warning).
safe_download() {
  local url="$1" dest="$2" expected_sha256="$3"
  curl -fsSL "$url" -o "$dest"

  if [[ -z "$expected_sha256" ]]; then
    echo -e "${YELLOW}⚠${NC}  No checksum provided for $(basename "$dest") — skipping verification"
    return
  fi

  local actual
  if command -v sha256sum &>/dev/null; then
    actual=$(sha256sum "$dest" | awk '{print $1}')
  elif command -v shasum &>/dev/null; then
    actual=$(shasum -a 256 "$dest" | awk '{print $1}')
  else
    echo -e "${YELLOW}⚠${NC}  sha256sum / shasum not found — skipping checksum verification"
    return
  fi

  if [[ "$actual" != "$expected_sha256" ]]; then
    echo -e "${RED}✗${NC}  Checksum mismatch for $(basename "$dest")" >&2
    echo "   expected: $expected_sha256" >&2
    echo "   actual:   $actual" >&2
    rm -f "$dest"
    exit 1
  fi
}

# Install for Claude Code
install_claude_code() {
  echo "→ Installing memobank skill for Claude Code..."
  mkdir -p "$SKILL_DIR/references"
  mkdir -p "$SKILL_DIR/scripts"

  # Check if running from local repo or remote
  if [[ -f "./SKILL.md" ]]; then
    # Local install — files already present, no download needed
    cp SKILL.md "$SKILL_DIR/SKILL.md"
    for f in cli-reference.md claude-code.md memory-protocol.md fallback.md codex.md cursor.md gemini.md qwen.md; do
      [[ -f "./references/$f" ]] && cp "./references/$f" "$SKILL_DIR/references/$f"
    done
    if [[ -f "./scripts/recall-context.sh" ]]; then
      cp ./scripts/recall-context.sh "$SKILL_DIR/scripts/recall-context.sh"
      chmod +x "$SKILL_DIR/scripts/recall-context.sh"
    fi
    mkdir -p "$SKILL_DIR/assets"
    for f in memory-decision-tree.md memory-templates.md; do
      [[ -f "./assets/$f" ]] && cp "./assets/$f" "$SKILL_DIR/assets/$f"
    done
  else
    # Remote install — download with checksum verification where available.
    # Checksums are pinned per release; set SKIP_CHECKSUM=1 to bypass.
    local raw="$SKILL_REPO/raw/main"
    safe_download "$raw/SKILL.md"                      "$SKILL_DIR/SKILL.md"                      "${SKILL_MD_SHA256:-}"
    safe_download "$raw/scripts/recall-context.sh"     "$SKILL_DIR/scripts/recall-context.sh"     "${RECALL_SH_SHA256:-}"
    for f in cli-reference.md claude-code.md memory-protocol.md fallback.md codex.md cursor.md gemini.md qwen.md; do
      safe_download "$raw/references/$f" "$SKILL_DIR/references/$f" ""
    done
    chmod +x "$SKILL_DIR/scripts/recall-context.sh"
    mkdir -p "$SKILL_DIR/assets"
    for f in memory-decision-tree.md memory-templates.md; do
      safe_download "$raw/assets/$f" "$SKILL_DIR/assets/$f" ""
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

# Install for Gemini CLI
install_gemini() {
  echo "→ Configuring Gemini CLI (~/.gemini/GEMINI.md)..."

  local gemini_dir="${HOME}/.gemini"
  local target_file="$gemini_dir/GEMINI.md"
  mkdir -p "$gemini_dir"

  # Check if already installed
  if grep -q "memobank" "$target_file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} memobank already in GEMINI.md"
    return
  fi

  local snippet
  if [[ -f "./platform/gemini/GEMINI-snippet.md" ]]; then
    snippet=$(cat ./platform/gemini/GEMINI-snippet.md)
  else
    snippet="## Memory Protocol (memobank)

At the end of each session, run: \`memo capture --auto --silent\`
At the start of each session, recall: \`memo recall \"<current task>\"\`"
  fi

  echo "" >> "$target_file"
  echo "$snippet" >> "$target_file"

  echo -e "${GREEN}✓${NC} Memory protocol appended to ~/.gemini/GEMINI.md"
}

# Install for Qwen Code
install_qwen() {
  echo "→ Configuring Qwen Code (~/.qwen/QWEN.md)..."

  local qwen_dir="${HOME}/.qwen"
  local target_file="$qwen_dir/QWEN.md"
  mkdir -p "$qwen_dir"

  # Check if already installed
  if grep -q "memobank" "$target_file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} memobank already in QWEN.md"
    return
  fi

  local snippet
  if [[ -f "./platform/qwen/QWEN-snippet.md" ]]; then
    snippet=$(cat ./platform/qwen/QWEN-snippet.md)
  else
    snippet="## Memory Protocol (memobank)

At the end of each session, run: \`memo capture --auto --silent\`
At the start of each session, recall: \`memo recall \"<current task>\"\`"
  fi

  echo "" >> "$target_file"
  echo "$snippet" >> "$target_file"

  echo -e "${GREEN}✓${NC} Memory protocol appended to ~/.qwen/QWEN.md"
}

# Install for OpenCode
install_opencode() {
  echo "→ Configuring OpenCode..."

  local opencode_json="${OPENCODE_JSON:-opencode.json}"

  if [[ ! -f "$opencode_json" ]]; then
    echo -e "${YELLOW}⚠${NC} No opencode.json found in current directory."
    echo "   Create one with: echo '{\"plugin\":[]}' > opencode.json"
    echo "   Then re-run: bash install.sh --opencode"
    echo ""
    echo "   Or follow the manual instructions in .opencode/INSTALL.md"
    return
  fi

  if grep -q "memobank" "$opencode_json" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} memobank already in opencode.json"
    return
  fi

  # Use python/node to safely inject into JSON, fall back to instructions
  if command -v node &>/dev/null; then
    node -e "
      const fs = require('fs');
      const cfg = JSON.parse(fs.readFileSync('$opencode_json', 'utf8'));
      cfg.plugin = cfg.plugin || [];
      cfg.plugin.push('memobank@git+https://github.com/clawde-agent/memobank-skill.git');
      fs.writeFileSync('$opencode_json', JSON.stringify(cfg, null, 2) + '\n');
    "
    echo -e "${GREEN}✓${NC} memobank added to opencode.json"
  else
    echo -e "${YELLOW}⚠${NC} node not found. Add manually to opencode.json:"
    echo '   "plugin": ["memobank@git+https://github.com/clawde-agent/memobank-skill.git"]'
  fi
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

# Install CLI
install_cli() {
  if command -v memo &>/dev/null; then
    echo -e "${GREEN}✓${NC} memobank-cli already installed"
    return
  fi

  echo "→ Installing memobank-cli from npm..."
  npm install -g memobank-cli

  if command -v memo &>/dev/null; then
    echo -e "${GREEN}✓${NC} memobank-cli installed"
  else
    echo -e "${YELLOW}⚠${NC} CLI installation failed. Install manually: npm install -g memobank-cli"
    return
  fi

  echo ""
  echo -e "${YELLOW}Now run interactive setup:${NC}"
  echo "  memo init"
  echo ""
  echo -e "${YELLOW}Or import existing memories:${NC}"
  echo "  memo import --claude    # From Claude Code"
  echo "  memo import --gemini    # From Gemini CLI"
  echo "  memo import --qwen      # From Qwen Code"
}

# Suggest CLI installation
suggest_cli() {
  if command -v memo &>/dev/null; then
    return
  fi

  echo ""
  echo -e "${YELLOW}Tip:${NC} Install memobank-cli for full functionality:"
  echo "  npm install -g memobank-cli"
  echo ""
  echo -e "${YELLOW}Then run interactive setup:${NC}"
  echo "  memo init"
  echo ""
  echo -e "${YELLOW}Or import existing memories:${NC}"
  echo "  memo import --claude    # From Claude Code"
  echo "  memo import --gemini    # From Gemini CLI"
  echo "  memo import --qwen      # From Qwen Code"
}

# Parse arguments
PLATFORMS=()
INSTALL_CLI=false

if [[ $# -eq 0 ]]; then
  # Default: install all
  PLATFORMS=("claude-code" "codex" "cursor" "gemini" "qwen" "opencode")
else
  for arg in "$@"; do
    case "$arg" in
      --claude-code|claude-code) PLATFORMS+=("claude-code") ;;
      --codex|codex)             PLATFORMS+=("codex") ;;
      --cursor|cursor)           PLATFORMS+=("cursor") ;;
      --gemini|gemini)           PLATFORMS+=("gemini") ;;
      --qwen|qwen)               PLATFORMS+=("qwen") ;;
      --opencode|opencode)       PLATFORMS+=("opencode") ;;
      --all|all)                 PLATFORMS=("claude-code" "codex" "cursor" "gemini" "qwen" "opencode") ;;
      --with-cli|cli)            INSTALL_CLI=true ;;
      *)
        echo "Unknown option: $arg"
        echo "Usage: bash install.sh [--claude-code] [--codex] [--cursor] [--gemini] [--qwen] [--opencode] [--all] [--with-cli]"
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
    gemini)      install_gemini ;;
    qwen)        install_qwen ;;
    opencode)    install_opencode ;;
  esac
done

# Install CLI if requested
if [[ "$INSTALL_CLI" == true ]]; then
  install_cli
else
  suggest_cli
fi

# Done
echo ""
echo -e "${GREEN}Done.${NC} Start Claude Code and try:"
echo "  /memobank <your current task>"
