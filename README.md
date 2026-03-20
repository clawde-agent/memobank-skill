# memobank-skill

One‑click installable skill for Claude Code, Codex, Cursor, Gemini CLI, and Qwen Code that gives coding agents persistent memory across three tiers: personal (private), project (team, Git-committed), and workspace (org-wide). Past decisions, lessons, and workflows are recalled automatically at the start of each session, and new learnings are captured at session end.

## Three-Tier Memory Model

Memobank organizes memory into three tiers with distinct scopes and use cases:

| Tier | Location | Committed | Who sees it |
|------|----------|-----------|-------------|
| **Personal** | `~/.memobank/<project>/` | Never | Only you |
| **Project** | `<repo-root>/.memobank/` | Yes, like source code | Everyone who clones the repo |
| **Workspace** | `~/.memobank/_workspace/<name>/` | To a remote Git repo | Entire organization |

**Personal** — Private drafts, machine-specific notes, personal experiments. Never shared.

**Project** — The team memory that lives with the code. Adding a memory = adding a file in a PR. Reviewing a memory = code review. History = `git log`. Zero extra ceremony.

**Workspace** — Cross-repo organizational knowledge: inter-service contracts, platform patterns, company-wide architecture decisions. Backed by any Git repo; updates flow through standard PRs on that repo.

**Recall priority:** Project > Personal > Workspace. All configured tiers are searched and merged automatically on every `memo recall`.

## Features

- 🗂️ **Three-Tier Memory** — Personal (private), Project (team, Git-committed), Workspace (org-wide, optional remote Git repo)
- 🧠 **Automatic Recall**: `!memo recall` runs before the agent sees your prompt, injecting relevant memories as context.
- 💾 **Auto‑Capture**: `hooks.Stop` runs `memo capture --auto` after each response to save significant learnings.
- 📈 **Status Lifecycle**: `experimental → active → needs-review → deprecated` driven by recall frequency. Stale memories fade automatically.
- 🔍 **Scoped Recall**: `--scope personal|project|workspace` and `--explain` score breakdown.
- 🌐 **Workspace Sharing**: `memo workspace init/sync/publish` — promote project memories to org-wide knowledge via standard Git PRs.
- 🔌 **Platform Support**:
  - Claude Code: full skill with hooks and dynamic `!` recall injection
  - Codex: memory protocol injection into `AGENTS.md`
  - Cursor: `.cursor/rules/memobank.mdc` rule file (`alwaysApply: true`)
  - Gemini CLI: protocol injected into `~/.gemini/GEMINI.md`
  - Qwen Code: protocol injected into `~/.qwen/QWEN.md`
- 📦 **Zero‑Dependency Fallback**: Works without `memobank-cli` installed (reads/writes plain `MEMORY.md`).
- 🛡️ **Secret Scanning**: `memo scan --fix` auto-redacts API keys, tokens, IPs before publishing to workspace.
- 📥 **Memory Import**: Import from Claude Code, Gemini CLI, Qwen Code.
- 🎯 **Interactive Setup**: TUI with `memo init`.

## Quick Start (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/clawde-agent/memobank-skill/main/install.sh | bash
```

After installation:

```bash
memo init    # Interactive setup (project tier, recommended for teams)
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
memo recall "auth flow"                    # default: searches all configured tiers
memo recall "auth flow" --scope project    # project (team) memories only
memo recall "auth flow" --scope personal   # personal memories only
memo recall "auth flow" --scope workspace  # org-wide workspace only
memo recall "auth flow" --explain          # show keyword/tags/recency scores
```

### Write memories

```bash
memo write lesson --name="..." --description="..." --tags="..." --content="..."
memo write decision --name="..." --description="..." --tags="..." --content="..."
memo write workflow --name="..." --description="..." --tags="..." --content="..."
memo write architecture --name="..." --description="..." --tags="..." --content="..."
```

### Workspace sharing (org-wide)

```bash
# Connect to your org's shared knowledge repo
memo workspace init git@github.com:your-org/platform-docs.git

# Promote a project memory to org-wide workspace
memo workspace publish .memobank/lesson/redis-pooling.md

# Pull latest org knowledge
memo workspace sync

# Push your workspace changes
memo workspace sync --push
```

### Secret scanning

```bash
memo scan                # scan .memobank/ for secrets
memo scan --fix          # auto-redact and re-stage
```

### Memory lifecycle

```bash
memo lifecycle            # view status report
memo lifecycle --scan     # run full scan, downgrade stale memories
memo lifecycle --reset-epoch  # team handoff: new team starts fresh decay tracking
```

## Directory Structure (v0.5.0+)

```
Personal tier (private, never committed):
~/.memobank/<project-name>/
├── lesson/
├── decision/
├── workflow/
├── architecture/
└── meta/
    ├── config.yaml
    └── access-log.json

Project tier (committed alongside code):
<repo-root>/.memobank/
├── lesson/
├── decision/
├── workflow/
├── architecture/
└── meta/
    ├── config.yaml
    └── access-log.json

Workspace tier (org-wide, local clone of remote):
~/.memobank/_workspace/<workspace-name>/
├── lesson/
├── decision/
├── workflow/
└── architecture/

Recall output (written on every memo recall):
~/.memobank/<project-name>/memory/MEMORY.md
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
