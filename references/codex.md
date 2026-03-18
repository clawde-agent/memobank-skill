# memobank — Codex / AGENTS.md Setup

## How it works

Codex (and OpenAI Codex-like agents) read memory from **AGENTS.md** at session start. The skill provides a ready-to-paste snippet that adds memory protocol instructions to your existing AGENTS.md.

## Installation

### Option A: Manual

1. Copy `platform/codex/AGENTS-snippet.md`
2. Append it to your project's `AGENTS.md` file
3. Ensure `memobank-cli` is installed (optional but recommended):
   ```bash
   npm install -g memobank-cli
   memo install
   ```

### Option B: Using install.sh

```bash
bash install.sh --codex
```

This appends the memory protocol snippet to `AGENTS.md` in the current directory.

## How retrieval works

In Codex, memory retrieval is **manual** at session start:

1. Open your project in Codex
2. The agent reads AGENTS.md (including the memobank snippet)
3. The snippet instructs the agent to read `~/.memobank/<project>/memory/MEMORY.md`
4. You can also explicitly ask: "Read the project memory"
5. The agent will run `memo recall "current task"` if CLI is installed

## Where memory is stored

Memory files live in:
```
~/.memobank/<project>/memory/
├── MEMORY.md           # Consolidated view (plain text)
├── lessons/            # Structured lesson files (with CLI)
├── decisions/          # Structured decision files (with CLI)
├── workflows/          # Structured workflow files (with CLI)
└── architecture/       # Structured architecture files (with CLI)
```

Replace `<project>` with your git repo name (e.g., `my-webapp`).

## Manual recall at session start

When starting a new session with Codex, tell the agent:

> "First, recall the project memory for: [describe your task]"

The agent will run:
```bash
memo recall "[your task description]"
```

Or if CLI is not installed, it will read MEMORY.md directly.

## Writing memories during the session

When something significant happens, instruct Codex:

> "Write this as a memory: [describe what happened]"

The agent will run:
```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

Types: `lesson` | `decision` | `workflow` | `architecture`

## Auto-capture (session end)

There's no automatic capture hook in Codex. You must manually run at session end:

> "Capture the session learnings"

The agent will run:
```bash
memo capture --auto
```

This extracts memories from any auto-memory files written during the session.

## Searching memory

To find specific memories:

> "Search project memory for: [query]"

The agent will run:
```bash
memo search "query"                    # keyword search
memo search "query" --engine=lancedb   # vector search (with CLI)
memo search "query" --tag=redis        # filter by tag
```

## Without memobank-cli

If you don't have the CLI, the memory protocol still works:

1. **Read MEMORY.md** — `~/.memobank/<project>/memory/MEMORY.md` is loaded at session start
2. **Write manually** — append entries directly to MEMORY.md
3. **No auto-capture** — you must manually capture learnings from auto-memory files

See [references/fallback.md](fallback.md) for the manual MEMORY.md format.

## AGENTS.md snippet

The ready-to-paste snippet is in `platform/codex/AGENTS-snippet.md`. It adds these instructions to your agent's behavior:

- Read memory at session start
- Write memories when learning something significant
- Run `memo capture --auto` at session end
- Search memory with `memo search "query"`

## See also

- [platform/codex/AGENTS-snippet.md](../platform/codex/AGENTS-snippet.md) — Ready-to-paste snippet
- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — Operation without CLI
