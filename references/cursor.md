# memobank — Cursor Setup

## How it works

Cursor uses `.cursor/rules/*.mdc` files to enforce agent behaviour. The memobank rule file (`memobank.mdc`) ensures the memory protocol is loaded every session via `alwaysApply: true`.

## Installation

### Option A: Interactive (recommended)

```bash
memo onboarding    # alias: memo init
```

Select "Cursor" in the platform multi-select step.

### Option B: Platform-only

```bash
memo install --platform cursor
```

Creates `.cursor/rules/memobank.mdc` in the current directory.

### Option C: Manual

Copy `platform/cursor/memobank.mdc` to `.cursor/rules/memobank.mdc` in your project root.

## How the rule works

- `globs: ["**/*"]` — Applies to all files
- `alwaysApply: true` — Loads on every session

## Memory retrieval in Cursor

Unlike Claude Code, Cursor **does not support `!` command injection**. Recall is manual:

1. Start a Cursor session
2. The memobank rule is automatically loaded
3. Ask Cursor: "Recall project memory for: [your task]"
4. Cursor runs `memo recall "[your task]"`

## Writing memories

```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

## Session end

Run manually at session end:

```bash
memo capture --auto 
```

## Workspace memory

```bash
memo workspace init <remote-url>
memo workspace sync
memo workspace publish <file>
```

## Searching memory

```bash
memo recall "query"                      # Primary: retrieve + write MEMORY.md
memo search "query"                      # Debug search
memo search "query" --engine=lancedb     # Vector search
memo search "query" --tag=redis          # Filter by tag
```

## Differences from Claude Code

| Feature | Claude Code | Cursor |
|---|---|---|
| Dynamic recall (`!` injection) | ✅ Yes | ❌ No (manual) |
| Auto-capture (hooks.Stop) | ✅ Yes | ❌ No (manual) |
| Rule-based protocol (alwaysApply) | — | ✅ Yes |
| `/memobank` invocation | ✅ Direct | ❌ No |

## See also

- [platform/cursor/memobank.mdc](../platform/cursor/memobank.mdc) — Ready-to-use rules file
- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — Operation without CLI
