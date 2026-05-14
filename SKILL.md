---
name: memobank
description: >
  Project memory system. Recalls relevant past decisions, lessons, and workflows
  before starting work. Captures new learnings at session end. Use when starting
  any coding task, debugging, or architectural work.
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null && memo process-queue --background 2>/dev/null || true"
      async: true
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash(memo *)
---

# memobank — Project Memory

## Quick Install

```bash
bash install.sh --with-cli
```

Or remote:
```bash
curl -fsSL https://github.com/clawde-agent/memobank-skill/raw/main/install.sh | bash -s -- --with-cli
```

---

You have access to a structured project memory system. Use it to avoid repeating mistakes, surface relevant context, and accumulate learnings over time.

## Memory Context

!`~/.claude/skills/memobank/scripts/recall-context.sh "$ARGUMENTS"`

## Memory Protocol

**At session start (already done above via dynamic injection):**
The memory context above was retrieved before you read this. Use it.

**During the session — capture immediately when you:**
- Fix a non-obvious bug
- Make an architectural decision
- Discover a workflow or pattern worth reusing
- Learn something that would have saved time if known earlier

```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

Types: `lesson` | `decision` | `workflow` | `architecture`

Optional: `--symbol <symbol>` to anchor the memory to a specific code symbol.

**You do NOT need to call `memo capture` at the end** — the Stop hook does it automatically.

## Common Commands

```bash
memo recall "query"           # search memory (primary — also updates MEMORY.md)
memo recall "query" --code    # dual-track: memories + code symbols (v0.8.0+)
memo search "query"           # debug search — does NOT update MEMORY.md
memo map                      # show memory statistics
memo study [lesson-name]      # promote lesson to CLAUDE.md conditional block
```

## Three-Tier Memory

| Tier | Location | Who sees it | When to use |
|------|----------|-------------|-------------|
| **Personal** | `~/.memobank/<project>/` | Only you | Private notes, machine-specific quirks |
| **Project** | `<repo-root>/.memobank/` | Everyone who clones repo | Team lessons, ADRs, runbooks |
| **Workspace** | `~/.memobank/_workspace/<name>/` | Entire org | Cross-repo contracts, org-wide decisions |

**Priority on recall:** Project > Personal > Workspace.

## First-Time Setup

```bash
memo init              # auto-detect project name + platforms (recommended)
memo onboarding        # interactive 13-step wizard (alias: memo setup)
```

For personal-only (never committed): `memo tier-init --global`

## References

- [CLI Reference](references/cli-reference.md) — full command and flag documentation
- [Memory Protocol](references/memory-protocol.md) — detailed when/how to write memories
- [Platform Setup](references/claude-code.md) — Claude Code-specific configuration
- [Fallback Guide](references/fallback.md) — operation without memobank-cli
