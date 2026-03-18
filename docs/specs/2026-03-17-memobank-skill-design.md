# memobank-skill — Design Spec
**Date:** 2026-03-17
**Status:** Draft
**Role in system:** Integration layer — skill, hooks, and one-click install across coding agents

---

## 1. Purpose

`memobank-skill` is the distribution package that connects `memobank-cli` to coding agent platforms. It provides:

1. A **SKILL.md** for Claude Code (AgentSkills open standard) with native hooks and dynamic context injection
2. An **`install.sh`** for one-click setup across Claude Code, Codex, Cursor, and Gemini CLI
3. **Platform reference files** with per-tool configuration details

---

## 2. Design Goals

1. **One-command install** — `curl -fsSL https://raw.githubusercontent.com/org/memobank-skill/main/install.sh | bash`
2. **Auto-recall without MCP** — `!`memo recall`` injects memory before Claude sees the prompt
3. **Auto-capture without user action** — `hooks.Stop` triggers `memo capture` silently
4. **Token-efficient** — no persistent process, no protocol overhead; output ≤500 tokens per recall
5. **Degrade gracefully** — works with or without `memobank-cli` installed; falls back to plain MEMORY.md read
6. **Portable** — same memory protocol across Claude Code, Codex, Cursor

---

## 3. Repository Structure

```
memobank-skill/
├── SKILL.md                        # Main skill (Claude Code / AgentSkills standard)
├── install.sh                      # One-click installer
├── README.md
├── references/
│   ├── claude-code.md              # Claude Code setup details
│   ├── codex.md                    # Codex / AGENTS.md setup details
│   ├── cursor.md                   # Cursor setup details
│   ├── memory-protocol.md          # Memory protocol instructions (shared)
│   └── fallback.md                 # How to operate without memobank-cli
└── platform/
    ├── codex/
    │   └── AGENTS-snippet.md       # Ready-to-paste AGENTS.md section
    └── cursor/
        └── memobank.mdc            # Cursor rules file
```

---

## 4. SKILL.md

This is the primary artifact. It follows the Claude Code AgentSkills standard with native features.

```yaml
---
name: memobank
description: >
  Project memory system. Recalls relevant past decisions, lessons, and workflows
  before starting work. Captures new learnings at session end. Use when starting
  any coding task, debugging, or architectural work.
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null || true"
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash(memo *)
---

# memobank — Project Memory

You have access to a structured project memory system. Use it to avoid repeating
mistakes, surface relevant context, and accumulate learnings over time.

## Memory Context

!`memo recall "$ARGUMENTS" 2>/dev/null || cat ~/.memobank/$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null || echo default)/memory/MEMORY.md 2>/dev/null || echo "(no memory configured — run: memo install)"`

## Memory Protocol

**At session start (already done above via dynamic injection):**
The memory context above was retrieved before you read this. Use it.

**During the session — capture immediately when you:**
- Fix a non-obvious bug
- Make an architectural decision
- Discover a workflow or pattern worth reusing
- Learn something that would have saved time if known earlier

Run: `memo write <type> --title="..." --tags="..." --content="..."`

Types: `lesson` | `decision` | `workflow` | `architecture`

**You do NOT need to call `memo capture` at the end** — the Stop hook does it automatically.

## Searching Memory

```bash
memo search "query"                    # keyword search (default)
memo search "query" --engine=lancedb   # vector search (if configured)
memo search "query" --tag=redis        # filter by tag
memo search "query" --type=decision    # filter by type
```

## Checking Review Reminders

```bash
memo review --due    # show memories flagged for re-evaluation
```

## For Setup Reference

See [references/claude-code.md](references/claude-code.md) for full configuration.
See [references/memory-protocol.md](references/memory-protocol.md) for the complete memory protocol.
See [references/fallback.md](references/fallback.md) for operation without memobank-cli.
```

### Key design elements in SKILL.md

**`!`memo recall "$ARGUMENTS"`` — dynamic injection:**
The `!`...`` syntax executes before Claude sees any prompt. The output of `memo recall` (the top-N memories formatted as Markdown) is inlined into the skill content. Claude reads it as context, not as a tool result. Zero token overhead from MCP protocol.

**Fallback chain in the `!`...`` command:**
```bash
memo recall "$ARGUMENTS" 2>/dev/null   # primary: CLI retrieval
|| cat ~/.memobank/.../MEMORY.md       # fallback: read last cached MEMORY.md
|| echo "(no memory configured...)"    # final: graceful message
```

**`hooks.Stop` — auto-capture:**
```yaml
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null || true"
```
Runs when Claude stops responding. `--auto` reads recently written auto-memory files and extracts structured memories from them. `|| true` ensures hook never fails the session.

**`allowed-tools: Bash(memo *)`:**
Grants permission to run `memo` commands without per-call approval when this skill is active.

---

## 5. `install.sh`

One-click installer that handles all platforms.

```bash
#!/usr/bin/env bash
# memobank-skill installer
# Usage: curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash
#        Or: bash install.sh [--claude-code] [--codex] [--cursor] [--all]

set -euo pipefail

SKILL_REPO="https://github.com/org/memobank-skill"
SKILL_DIR="${HOME}/.claude/skills/memobank"

install_claude_code() {
  echo "→ Installing memobank skill for Claude Code..."
  mkdir -p "$SKILL_DIR"
  # Download SKILL.md and references/
  curl -fsSL "$SKILL_REPO/raw/main/SKILL.md" -o "$SKILL_DIR/SKILL.md"
  mkdir -p "$SKILL_DIR/references"
  for f in claude-code.md memory-protocol.md fallback.md; do
    curl -fsSL "$SKILL_REPO/raw/main/references/$f" -o "$SKILL_DIR/references/$f"
  done
  echo "✓ Skill installed: ~/.claude/skills/memobank/"
}

install_codex() {
  echo "→ Configuring Codex (AGENTS.md)..."
  local agents_file="AGENTS.md"
  if [[ ! -f "$agents_file" ]]; then
    echo "⚠  No AGENTS.md found in current directory. Skipping Codex install."
    return
  fi
  # Check if already installed
  if grep -q "memobank" "$agents_file" 2>/dev/null; then
    echo "✓ memobank already in AGENTS.md"
    return
  fi
  cat platform/codex/AGENTS-snippet.md >> "$agents_file"
  echo "✓ Memory protocol appended to AGENTS.md"
}

install_cursor() {
  echo "→ Configuring Cursor..."
  mkdir -p ".cursor/rules"
  cp platform/cursor/memobank.mdc .cursor/rules/memobank.mdc
  echo "✓ Cursor rule installed: .cursor/rules/memobank.mdc"
}

suggest_cli() {
  if ! command -v memo &>/dev/null; then
    echo ""
    echo "Optional: install memobank-cli for vector search and auto-capture:"
    echo "  npm install -g memobank-cli && memo install"
  fi
}

# Parse flags
PLATFORMS=()
for arg in "$@"; do
  case $arg in
    --claude-code) PLATFORMS+=("claude-code") ;;
    --codex)       PLATFORMS+=("codex") ;;
    --cursor)      PLATFORMS+=("cursor") ;;
    --all|"")      PLATFORMS=("claude-code" "codex" "cursor") ;;
  esac
done

for platform in "${PLATFORMS[@]}"; do
  case $platform in
    claude-code) install_claude_code ;;
    codex)       install_codex ;;
    cursor)      install_cursor ;;
  esac
done

suggest_cli

echo ""
echo "memobank-skill installed. Start a Claude Code session and try:"
echo "  /memobank <your current task>"
```

---

## 6. Platform Reference Files

### `references/memory-protocol.md`

The authoritative memory protocol instructions, shared across all platforms. Defines:
- When to recall (session start)
- When to write (during session on significant learning)
- When to capture (session end — automatic via hook)
- Memory types and when to use each
- Sanitization rules (never write API keys, passwords, PII)

### `references/claude-code.md`

Claude Code-specific:
- How `autoMemoryDirectory` works
- How the `!`memo recall`` injection works
- How `hooks.Stop` captures
- Manual `/memobank` invocation patterns

### `references/fallback.md`

For users without `memobank-cli`:
- Direct MEMORY.md file format
- How to manually write memories
- When to upgrade to memobank-cli

### `platform/codex/AGENTS-snippet.md`

```markdown
## Memory Protocol (memobank)

You have access to project memory at `~/.memobank/<project>/memory/MEMORY.md`.

**Session start:** Read `~/.memobank/<project>/memory/MEMORY.md` before starting work.

**During session:** When you learn something significant, write it:
`memo write lesson --title="..." --tags="..." --content="..."`

**Session end:** Run `memo capture --auto` to extract and store learnings.

If memobank-cli is not installed, manually append to `~/.memobank/<project>/memory/MEMORY.md`.
```

### `platform/cursor/memobank.mdc`

```markdown
---
description: memobank project memory protocol
globs: ["**/*"]
alwaysApply: true
---

# Memory Protocol

Read `~/.memobank/<project>/memory/MEMORY.md` at the start of every session.

When you learn something significant (bug fixed, decision made, workflow discovered):
- Run `memo write <type> --title="..." --tags="..." --content="..."`
- Or append directly to `~/.memobank/<project>/memory/MEMORY.md`

Run `memo capture --auto` at end of session if memobank-cli is installed.
```

---

## 7. Degradation Modes

| Scenario | Behavior |
|---|---|
| `memo` installed, Mode A repo | Full: vector/hybrid recall, structured capture, git-tracked |
| `memo` installed, Mode B | Full: CLI recall writes MEMORY.md, auto-capture via hook |
| `memo` NOT installed, MEMORY.md exists | Fallback: `!`cat MEMORY.md`` inlines last cached memory |
| `memo` NOT installed, no MEMORY.md | Graceful: message tells user to run `memo install` |
| Hook fails | `|| true` ensures session is never blocked |

---

## 8. Plugin Distribution (Future)

When Claude Code's plugin marketplace is available, `memobank-skill` can be packaged as a plugin:

```
memobank-skill/
├── .claude-plugin/
│   └── plugin.json    # { name, version, author, description }
└── skills/
    └── memobank/
        └── SKILL.md   # Same SKILL.md as above
```

Install via: `/plugin install memobank`

---

## 9. Design Decisions

**Why `hooks.Stop` instead of a PostToolUse hook?**
`Stop` fires once per session end — exactly when we want to capture. `PostToolUse` would fire after every tool call, causing duplicate captures and wasted API calls.

**Why `!`...`` injection instead of an always-loaded CLAUDE.md section?**
`!`memo recall`` runs a fresh retrieval on each invocation. A static CLAUDE.md section would show stale cached results. Dynamic injection ensures the most relevant memories for the current task.

**Why `allowed-tools: Bash(memo *)` scope instead of full Bash?**
Restricts Claude's auto-approved tools to only `memo` commands when this skill is active. Prevents accidental broad Bash execution.

**Why not use `user-invocable: false`?**
Users should be able to invoke `/memobank` directly to force a recall on a specific query. The skill is useful both auto-triggered and manually.

**Why include Cursor and Codex even though the skill format is Claude Code native?**
The `install.sh` generates platform-native files (`.mdc`, `AGENTS.md` snippet). The memory protocol is universal even if the trigger mechanism differs per platform.
