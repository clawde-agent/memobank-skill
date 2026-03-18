# memobank — Cursor Setup

## How it works

Cursor uses `.cursor/rules/*.mdc` files (Markdown with frontmatter) to enforce agent behavior. The memobank rule file (`memobank.mdc`) ensures the memory protocol is loaded every session via `alwaysApply: true`.

## Installation

### Option A: Manual

1. Copy `platform/cursor/memobank.mdc`
2. Place it in your project root: `.cursor/rules/memobank.mdc`
3. Ensure `memobank-cli` is installed (optional but recommended):
   ```bash
   npm install -g memobank-cli
   memo install
   ```

### Option B: Using install.sh

```bash
bash install.sh --cursor
```

This creates `.cursor/rules/memobank.mdc` in the current directory.

## How the rule works

The `.cursor/rules/memobank.mdc` file has:

```markdown
---
description: memobank project memory protocol for Cursor
globs: ["**/*"]
alwaysApply: true
---
```

- `globs: ["**/*"]` — Applies to all files in the project
- `alwaysApply: true` — Loads on every session (no need to manually invoke)

Cursor agents will read this rule at the start of every session.

## Memory retrieval in Cursor

Unlike Claude Code, Cursor **does not support `!` command injection**. You must manually recall memory:

1. Start a Cursor session
2. The memobank rule is automatically loaded
3. Ask Cursor: "Recall project memory for: [describe your task]"
4. Cursor will run `memo recall "[your task]"`
5. Or if CLI is not installed, Cursor will read MEMORY.md directly

The rule instructs Cursor to:
- Read `~/.memobank/<project>/memory/MEMORY.md` at session start
- Or run `memo recall "<current task description>"

## Writing memories during the session

When something significant happens, tell Cursor:

> "Write this as a [lesson|decision|workflow|architecture] memory: [describe what happened]"

Cursor will run:
```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

## Auto-capture (session end)

There's no automatic capture hook in Cursor. You must manually run at session end:

> "Capture the session learnings"

Cursor will run:
```bash
memo capture --auto
```

## Searching memory

To find specific memories:

> "Search project memory for: [query]"

Cursor will run:
```bash
memo search "query"                    # keyword search
memo search "query" --engine=lancedb   # vector search (with CLI)
memo search "query" --tag=redis        # filter by tag
```

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

## Without memobank-cli

If you don't have the CLI, the memory protocol still works:

1. **Read MEMORY.md** — `~/.memobank/<project>/memory/MEMORY.md` is loaded at session start
2. **Write manually** — append entries directly to MEMORY.md
3. **No auto-capture** — you must manually capture learnings from auto-memory files

See [references/fallback.md](fallback.md) for the manual MEMORY.md format.

## Differences from Claude Code

| Feature | Claude Code | Cursor |
|---|---|---|
| Dynamic recall (`!` injection) | ✅ Yes | ❌ No (manual) |
| Auto-capture (hooks.Stop) | ✅ Yes | ❌ No (manual) |
| Rule-based protocol (alwaysApply) | — | ✅ Yes |
| `/memobank` invocation | ✅ Direct command | ❌ No |

Cursor's rule system is powerful but lacks Claude Code's hooks. You must manually trigger recall and capture.

## Cursor rules file template

The ready-to-use file is `platform/cursor/memobank.mdc`:

```markdown
---
description: memobank project memory protocol for Cursor
globs: ["**/*"]
alwaysApply: true
---

# Memory Protocol

At the start of every session, read:
`~/.memobank/<project>/memory/MEMORY.md`
(replace `<project>` with the git repo name)

Or run: `memo recall "<current task description>"`

## When to write memories

Write immediately when you:
- Fix a non-obvious bug → `memo write lesson`
- Make an architectural decision → `memo write decision`
- Discover a repeatable workflow → `memo write workflow`

Command: `memo write <type> --name="..." --description="..." --tags="..." --content="..."`

## Session end

Run `memo capture --auto` to extract and store session learnings.
```

## See also

- [platform/cursor/memobank.mdc](../platform/cursor/memobank.mdc) — Ready-to-use rules file
- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — Operation without CLI
