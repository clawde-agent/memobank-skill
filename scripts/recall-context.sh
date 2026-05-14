#!/usr/bin/env bash
# Invoked by SKILL.md !injection — recall with MEMORY.md fallback
set -euo pipefail

QUERY="${1:-}"

# Primary: memo recall (writes MEMORY.md and prints context)
if command -v memo &>/dev/null; then
  ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  if memo recall "$QUERY" --code --silent 2>/dev/null && [[ -n "$ROOT" && -f "$ROOT/.memobank/MEMORY.md" ]]; then
    cat "$ROOT/.memobank/MEMORY.md"
    exit 0
  fi
fi

# Fallback: read existing MEMORY.md directly
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -n "$ROOT" && -f "$ROOT/.memobank/MEMORY.md" ]]; then
  cat "$ROOT/.memobank/MEMORY.md"
  exit 0
fi

echo "(no memory configured — run: memo init)"
