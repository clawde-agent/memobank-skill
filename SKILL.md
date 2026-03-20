---
name: memobank
description: >
  Project memory system. Recalls relevant past decisions, lessons, and workflows
  before starting work. Captures new learnings at session end. Use when starting
  any coding task, debugging, or architectural work.
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null || true"
      async: true
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
memo init    # interactive TUI (recommended)
```

This guides you through: project name → tier selection (personal/project) → search engine → workspace remote (optional).

**Tier selection:**
- `memo init` — project tier, memories committed alongside code (default for teams)
- `memo init --global` — personal tier only, private to this machine, never committed

## Searching Memory

```bash
memo recall "query"                        # search all tiers (primary)
memo recall "query" --scope personal       # personal memories only
memo recall "query" --scope project        # project (team) memories only
memo recall "query" --scope workspace      # org-wide workspace only
memo recall "query" --explain              # show score breakdown (keyword/tags/recency)
memo search "query"                        # debug search, does not update MEMORY.md
memo search "query" --engine=lancedb       # vector search (if configured)
memo search "query" --tag=redis            # filter by tag
memo search "query" --type=decision        # filter by type
```

## Three-Tier Memory

Memobank uses three tiers with distinct scopes. Choose the right tier for each memory:

| Tier | Location | Who sees it | When to use |
|------|----------|-------------|-------------|
| **Personal** | `~/.memobank/<project>/` | Only you | Private notes, machine-specific quirks, experiments |
| **Project** | `<repo-root>/.memobank/` | Everyone who clones repo | Team lessons, ADRs, shared runbooks |
| **Workspace** | `~/.memobank/_workspace/<name>/` | Entire org (via remote repo) | Cross-repo contracts, platform patterns, org-wide decisions |

**Priority on recall:** Project > Personal > Workspace. Duplicate filenames: higher-priority tier wins.

## Workspace Memory (Org-Wide)

```bash
memo workspace init <remote-url>    # Connect to org workspace repo
memo workspace sync                 # Pull latest org memories
memo workspace sync --push          # Push changes to org remote
memo workspace publish <file>       # Promote a project memory to org workspace (+ secret scan)
memo workspace status               # Show git status of workspace clone
```

**Workspace** is optional. If not configured, recall silently skips that tier.

## Migration from Old Layout

If you have the old `personal/` + `team/` directory structure:

```bash
memo migrate --dry-run    # preview what would move
memo migrate              # execute migration
memo migrate --rollback   # restore previous layout if needed
```

## Secret Scanning

```bash
memo scan                     # Scan .memobank/ for secrets
memo scan --fix               # Auto-redact and re-stage
```

`memo workspace publish` automatically runs the scanner and blocks if secrets are found.

## Memory Lifecycle

Each memory has a `status` field that evolves based on recall frequency:

| Status | Meaning |
|--------|---------|
| `experimental` | Newly written, unverified |
| `active` | Recalled at least once; trusted |
| `needs-review` | Not recalled in 90 days; may be stale |
| `deprecated` | Excluded from default recall; still searchable |

```bash
memo lifecycle                # View lifecycle report
memo lifecycle --scan         # Run full scan, downgrade stale memories (run in CI)
memo lifecycle --reset-epoch  # Reset epoch for team handoff (new team, fresh decay tracking)
memo correct <path>           # Record a correction to a memory
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
