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

You have access to a structured project memory system. Use it to avoid repeating mistakes, surface relevant context, and accumulate learnings over time.

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

Run: `memo write <type> --name="..." --description="..." --tags="..." --content="..."`

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

## Interactive Setup

For guided setup with tool configuration and memory import:

```bash
memo setup    # Interactive wizard
```

## Import from Other AI Tools

Import existing memories from Claude Code, Gemini CLI, or Qwen Code:

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
