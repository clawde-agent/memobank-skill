---
name: memobank
description: >
  Project memory system. Recalls relevant past decisions, lessons, and workflows
  before starting work. Captures new learnings at session end. Use when starting
  any coding task, debugging, or architectural work.
hooks:
  Stop:
    - command: "memo capture --auto --silent 2>/dev/null || true"
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash(memo *)
---

# memobank — Project Memory

## 🚀 Quick Install (One Command)

If this skill is not installed yet, run:

```bash
bash install.sh --with-cli
```

This installs both the skill (for Claude Code/Codex/Cursor/Gemini/Qwen) AND the CLI tool (memobank-cli).

Or for remote install:
```bash
curl -fsSL https://github.com/clawde-agent/memobank-skill/raw/main/install.sh | bash -s -- --with-cli
```

---

You have access to a structured project memory system. Use it to avoid repeating mistakes, surface relevant context, and accumulate learnings over time.

## Memory Context

!`memo recall "$ARGUMENTS" 2>/dev/null || cat ~/.memobank/$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null || echo default)/memory/MEMORY.md 2>/dev/null || echo "(no memory configured — run: memo init)"`

## Memory Protocol

**At session start (already done above via dynamic injection):**
The memory context above was retrieved before you read this. Use it.

**During the session — capture immediately when you:**
- Fix a non-obvious bug
- Make an architectural decision
- Discover a workflow or pattern worth reusing
- Learn something that would have saved time if known earlier

Run: `memo write <type> --name="..." --description="..." --tags="..." --content="..."`

Types: `lesson` | `decision` | `workflow` | `architecture`

**You do NOT need to call `memo capture` at the end** — the Stop hook does it automatically.

## First-Time Setup

For new users, run the interactive setup:

```bash
memo init    # 4-step interactive TUI (recommended)
```

This guides you through: project name → platform selection → team repo (optional) → search engine.

## Searching Memory

```bash
memo recall "query"                      # search + write to MEMORY.md (primary)
memo recall "query" --scope personal     # personal memories only
memo recall "query" --scope team         # team memories only
memo recall "query" --explain            # show score breakdown (keyword/tags/recency)
memo search "query"                      # debug search, does not update MEMORY.md
memo search "query" --engine=lancedb     # vector search (if configured)
memo search "query" --tag=redis          # filter by tag
memo search "query" --type=decision      # filter by type
```

## Team Memory

```bash
memo team init <remote-url>   # Link shared team memory repo
memo team sync                # Pull + push team memories
memo team publish <file>      # Promote a personal memory to team
memo team status              # Show team repo status
```

## Secret Scanning

```bash
memo scan                     # Scan team/ for secrets before pushing
memo scan --fix               # Auto-redact and re-stage
```

## Memory Lifecycle

```bash
memo lifecycle report         # View memory statistics and tiers
memo lifecycle --tier core    # Show frequently accessed memories
memo lifecycle flagged        # Show memories needing review
memo correct <path>           # Record a correction
```

## Checking Review Reminders

```bash
memo review --due    # show memories flagged for re-evaluation
```

## Import from Other AI Tools

```bash
memo import --claude    # Import from Claude Code
memo import --gemini    # Import from Gemini CLI
memo import --qwen      # Import from Qwen Code
memo import --all       # Import from all available tools
```

## For Setup Reference

See [references/claude-code.md](references/claude-code.md) for full configuration.
See [references/memory-protocol.md](references/memory-protocol.md) for the complete memory protocol.
See [references/fallback.md](references/fallback.md) for operation without memobank-cli.
