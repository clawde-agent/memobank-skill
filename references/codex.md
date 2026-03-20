# memobank — Codex / AGENTS.md Setup

## How it works

Codex reads memory from **AGENTS.md** at session start. The skill provides a ready-to-paste snippet that adds the memory protocol to your existing AGENTS.md.

## Installation

### Option A: Interactive (recommended)

```bash
memo init
```

Select "Codex" in the platform multi-select step.

### Option B: Platform-only

```bash
memo install --platform codex
```

This appends the memory protocol snippet to `AGENTS.md` in the current directory.

### Option C: Manual

1. Copy `platform/codex/AGENTS-snippet.md`
2. Append to your project's `AGENTS.md`

## How retrieval works

In Codex, memory retrieval is **manual** at session start:

1. Open your project in Codex
2. The agent reads AGENTS.md (including the memobank snippet)
3. The snippet instructs the agent to recall memory: `memo recall "current task"`
4. Or reads `.memobank/MEMORY.md` directly if CLI is not installed

## Writing memories

```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

Types: `lesson` | `decision` | `workflow` | `architecture`

## Session end

There's no automatic capture hook in Codex. Manually run at session end:

```bash
memo capture --auto 
```

## Workspace memory

```bash
memo workspace init <remote-url>    # Link org-wide workspace repo
memo workspace sync                 # Pull + push
memo workspace publish <file>       # Promote project → workspace
```

## Searching memory

```bash
memo recall "query"                      # Primary: retrieve + write MEMORY.md
memo search "query"                      # Debug search
memo search "query" --engine=lancedb     # Vector search
memo search "query" --tag=redis          # Filter by tag
```

## Without memobank-cli

1. **Read MEMORY.md** — `.memobank/MEMORY.md` at session start
2. **Write manually** — append entries directly to MEMORY.md
3. **No auto-capture** — extract learnings manually

See [references/fallback.md](fallback.md) for the manual MEMORY.md format.

## See also

- [platform/codex/AGENTS-snippet.md](../platform/codex/AGENTS-snippet.md) — Ready-to-paste snippet
- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — Operation without CLI
