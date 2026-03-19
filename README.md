# memobank-skill

One‑click installable skill for Claude Code, Codex, Cursor, Gemini CLI, and Qwen Code that gives coding agents persistent project memory: past decisions, lessons, and workflows are recalled automatically at the start of each session, and new learnings are captured at session end.

## Features

- 🧠 **Automatic Recall**: `!memo recall` runs before the agent sees your prompt, injecting relevant memories as context.
- 💾 **Auto‑Capture**: `hooks.Stop` runs `memo capture --auto --silent` after each response to save significant learnings.
- 👥 **Team Memory**: Share memories across the team via a shared Git remote (`memo team init/sync/publish`).
- 🔍 **Scoped Recall**: `--scope personal|team|all` and `--explain` score breakdown.
- 🔌 **Platform Support**:
  - Claude Code: full skill with hooks and dynamic `!` recall injection
  - Codex: memory protocol injection into `AGENTS.md`
  - Cursor: `.cursor/rules/memobank.mdc` rule file (`alwaysApply: true`)
  - Gemini CLI: protocol injected into `~/.gemini/GEMINI.md`
  - Qwen Code: protocol injected into `~/.qwen/QWEN.md`
- 📦 **Zero‑Dependency Fallback**: Works without `memobank-cli` installed (reads/writes plain `MEMORY.md`).
- 🛡️ **Secret Scanning**: `memo scan --fix` auto-redacts API keys, tokens, IPs before publishing to team.
- 📥 **Memory Import**: Import from Claude Code, Gemini CLI, Qwen Code.
- 🎯 **Interactive Setup**: 4-step TUI with `memo init`.

## Quick Start (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/clawde-agent/memobank-skill/main/install.sh | bash
```

After installation:

```bash
memo init    # Interactive 4-step setup
```

### 🤖 Ask Claude Code to Install

Just give Claude Code this repo URL and say:

> "Install this skill for me: https://github.com/clawde-agent/memobank-skill"

Claude Code will run:

```bash
bash install.sh --with-cli
```

Then start using:

```
/memobank deploy the new feature
/memobank debug the auth flow
```

## Manual Installation

### Claude Code
```bash
mkdir -p ~/.claude/skills/memobank
cp SKILL.md ~/.claude/skills/memobank/
cp -r references/ ~/.claude/skills/memobank/references/
```

### Codex
```bash
bash install.sh --codex
# or
cat platform/codex/AGENTS-snippet.md >> AGENTS.md
```

### Cursor
```bash
bash install.sh --cursor
# or
mkdir -p .cursor/rules
cp platform/cursor/memobank.mdc .cursor/rules/
```

### Gemini CLI
```bash
memo install --platform gemini
```

### Qwen Code
```bash
memo install --platform qwen
```

### All platforms
```bash
bash install.sh --all
# or
memo install --platform all
```

## Using memobank

### Invoke the skill

```text
/memobank deploy the new feature
/memobank debug the Redis connection issue
/memobank refactor the auth module
```

### Recall with options

```bash
memo recall "auth flow"                  # default: searches personal + team
memo recall "auth flow" --scope team     # team memories only
memo recall "auth flow" --explain        # show keyword/tags/recency scores
```

### Write memories

```bash
memo write lesson --name="..." --description="..." --tags="..." --content="..."
memo write decision --name="..." --description="..." --tags="..." --content="..."
memo write workflow --name="..." --description="..." --tags="..." --content="..."
memo write architecture --name="..." --description="..." --tags="..." --content="..."
```

### Team sharing

```bash
memo team init git@github.com:your-org/team-memories.git
memo team publish personal/lesson/2026-03-19-redis-pooling.md
memo team sync
```

### Secret scanning

```bash
memo scan                # scan team/ for secrets before pushing
memo scan --fix          # auto-redact and re-stage
```

## Directory structure (v0.3.0+)

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
│   └── MEMORY.md      # Last recall result
└── meta/
    └── config.yaml
```

## Platform comparison

| Feature | Claude Code | Codex | Cursor | Gemini | Qwen |
|---|---|---|---|---|---|
| Auto recall at session start | ✅ `!` injection | Manual | Manual | Manual | Manual |
| Auto capture at session end | ✅ Stop hook | Manual | Manual | ✅ GEMINI.md | ✅ QWEN.md |
| `/memobank` skill invocation | ✅ | ❌ | ❌ | ❌ | ❌ |
| `alwaysApply` rule | ❌ | ✅ AGENTS.md | ✅ .mdc | ✅ | ✅ |

## References

- [references/claude-code.md](references/claude-code.md) — Claude Code full setup guide
- [references/codex.md](references/codex.md) — Codex setup guide
- [references/cursor.md](references/cursor.md) — Cursor setup guide
- [references/gemini.md](references/gemini.md) — Gemini CLI setup guide
- [references/qwen.md](references/qwen.md) — Qwen Code setup guide
- [references/memory-protocol.md](references/memory-protocol.md) — Canonical memory protocol
- [references/fallback.md](references/fallback.md) — Operation without memobank-cli
