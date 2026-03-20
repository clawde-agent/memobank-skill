# memobank — Claude Code Setup

## How it works

1. **Dynamic recall** (`!` injection): when you invoke `/memobank <task>`,
   `memo recall` runs *before* Claude reads the prompt. Top-N memories
   are injected as context. Zero MCP overhead.

2. **Auto-capture** (`hooks.Stop`): when Claude finishes responding,
   `memo capture --auto` runs silently in the background.
   Any significant learnings are extracted and stored as structured memories.

3. **Auto-memory integration**: `memo onboarding` (or `memo install --platform claude-code`)
   sets `autoMemoryDirectory` in `~/.claude/settings.json` to point to your
   project's `.memobank/` directory. Claude's native auto-memory writes go
   there, and `memo capture` picks them up.

## Installation

### Option A: Interactive (recommended)

```bash
memo onboarding
```

Interactive TUI: project name → **memory directory name** (default `.memobank`, or type a custom folder name) → platform selection → workspace repo → search engine.

### Option B: Platform-only install

```bash
memo install --platform claude-code
```

Sets `autoMemoryDirectory` and installs the Stop hook in `~/.claude/settings.json`.

### Option C: Manual skill copy

```bash
mkdir -p ~/.claude/skills/memobank
cp SKILL.md ~/.claude/skills/memobank/SKILL.md
cp -r references/ ~/.claude/skills/memobank/references/
```

## Configure autoMemoryDirectory

### Option A: Automatic

```bash
memo install --platform claude-code
```

### Option B: Manual

Add to `~/.claude/settings.json`:

```json
{
  "autoMemoryDirectory": "/path/to/your-project/.memobank",
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "memo capture --auto" }]
      }
    ]
  }
}
```

Replace `/path/to/your-project/.memobank` with the absolute path to your project memory directory (whatever name you chose during `memo onboarding` — default is `.memobank`).

## Usage

### Manual invocation

```text
/memobank deploy the new feature
/memobank debug the Redis connection issue
/memobank refactor the auth module
```

### Scoped recall

```bash
memo recall "auth flow" --scope personal   # personal memories only
memo recall "auth flow" --scope project    # project (team) memories only
memo recall "auth flow" --scope workspace  # org-wide workspace only
memo recall "auth flow" --explain          # show score breakdown
```

## Directory structure (v0.5.0+)

Memories are stored across three tiers:

```
Personal tier (private, never committed):
~/.memobank/<project-name>/
├── lesson/
├── decision/
├── workflow/
├── architecture/
└── meta/
    └── config.yaml

Project tier (committed alongside code):
<repo-root>/<dir>/               ← autoMemoryDirectory points here (default: .memobank/)
├── lesson/
├── decision/
├── workflow/
├── architecture/
├── MEMORY.md                    ← written by memo recall, read by Claude
└── meta/
    └── config.yaml

Workspace tier (org-wide, local clone of remote):
~/.memobank/_workspace/<workspace-name>/
├── lesson/
├── decision/
├── workflow/
└── architecture/
```

## Workspace memory setup

```bash
memo workspace init git@github.com:your-org/platform-docs.git
memo workspace sync                # pull + push
memo workspace publish <file>      # promote project → workspace
memo workspace status              # show git status
```

## Troubleshooting

### `/memobank` command not found

Restart Claude Code. Skill files are loaded at startup.

### Memory context not appearing

Check that `memo recall` works in your terminal:
```bash
memo recall "test"
```

If memo is not installed: `npm install -g memobank-cli`

### Auto-capture not working

Check `~/.claude/settings.json` has the Stop hook:
```json
"hooks": {
  "Stop": [
    { "matcher": "", "hooks": [{ "type": "command", "command": "memo capture --auto" }] }
  ]
}
```

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — How to use without CLI
