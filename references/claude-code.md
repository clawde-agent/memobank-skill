# memobank — Claude Code Setup

## How it works

1. **Dynamic recall** (`!` injection): when you invoke `/memobank <task>`,
   `memo recall` runs *before* Claude reads the prompt. Top-N memories
   are injected as context. Zero MCP overhead.

2. **Auto-capture** (`hooks.Stop`): when Claude finishes responding,
   `memo capture --auto ` runs silently in the background.
   Any significant learnings are extracted and stored as structured memories.

3. **Auto-memory integration**: `memo init` (or `memo install --platform claude-code`)
   sets `autoMemoryDirectory` in `~/.claude/settings.json` to point to your
   memobank repo's `memory/` directory. Claude's native auto-memory writes go
   there, and `memo capture` picks them up.

## Installation

### Option A: Interactive (recommended)

```bash
memo init
```

4-step TUI: project name → platform selection (auto-detects Claude Code) → team repo → search engine.

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
  "autoMemoryDirectory": "~/.memobank/<project>/memory/",
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "memo capture --auto " }]
      }
    ]
  }
}
```

Replace `<project>` with your git repo name (e.g., `my-webapp`).

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
memo recall "auth flow" --scope team       # shared team memories only
memo recall "auth flow" --explain          # show score breakdown
```

## Directory structure (v0.3.0+)

Memories are stored in a two-layer layout:

```
~/.memobank/<project>/
├── personal/          # Local only, never synced
│   ├── lesson/
│   ├── decision/
│   ├── workflow/
│   └── architecture/
├── team/              # Git-tracked, synced to shared remote
│   ├── lesson/
│   └── ...
├── memory/
│   └── MEMORY.md      # Last recall result (injected via autoMemoryDirectory)
└── meta/
    └── config.yaml
```

## Team memory setup

```bash
memo team init git@github.com:your-org/team-memories.git
memo team sync                # pull + push
memo team publish <file>      # promote personal → team
memo team status              # show git status
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
    { "matcher": "", "hooks": [{ "type": "command", "command": "memo capture --auto " }] }
  ]
}
```

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — How to use without CLI
