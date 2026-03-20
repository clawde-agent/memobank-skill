# memobank

AI agents forget everything between sessions.
Static files like CLAUDE.md go stale and require manual upkeep.
Cloud memory APIs add external services your team doesn't own or control.

**memobank gives AI agents persistent, structured memory that lives in your Git repo** —
versioned alongside code, reviewed as PRs, and loaded automatically at session start.

- **Personal** — private lessons and preferences, never committed
- **Team** — shared knowledge that travels with the codebase
- **Workspace** — cross-repo patterns, synced via a separate Git remote

Works with Claude Code, Cursor, Codex, Gemini CLI, and Qwen Code.
Zero external services required.

---

## Get started

**One-liner install (skill + CLI):**

```bash
curl -fsSL https://raw.githubusercontent.com/clawde-agent/memobank-skill/main/install.sh | bash -s -- --with-cli
```

Then set up your project:

```bash
memo onboarding  # creates .memobank/ and configures your AI tool
```

**Or ask Claude Code to install it:**

> "Install this skill for me: https://github.com/clawde-agent/memobank-skill"

Claude Code will run `bash install.sh --with-cli`, then you can invoke it immediately:

```
/memobank deploy the new feature
/memobank debug the auth flow
```

**For teams** — commit `.memobank/` like source code. Teammates get the same memories on clone:

```bash
git add .memobank/
git commit -m "init team memory"
```

Claude Code loads the first 200 lines of `.memobank/MEMORY.md` at every session start — no plugins, no configuration beyond `memo onboarding`.

---

## How it works

memobank uses three memory tiers — like `git config` levels, each with a different scope:

| Tier | Location | Committed? | Scope |
|------|----------|-----------|-------|
| Personal | `~/.memobank/<project>/` | No | Your machine only |
| Project | `<repo>/<dir>/` (default: `.memobank/`) | Yes | Everyone who clones |
| Workspace | `~/.memobank/_workspace/` | Separate remote | Across multiple repos |

Most teams only ever need **Personal + Project**. Workspace is opt-in.
The project directory name (default `.memobank`) can be customized during `memo onboarding`.

When you run `memo recall`, memobank searches all active tiers and writes the top results to `.memobank/MEMORY.md`. The skill loads that file at the start of every session.

Memories are plain markdown with a small YAML header — readable, diffable, and reviewable in PRs:

```markdown
---
name: prefer-pnpm
type: decision
status: active
tags: [tooling, packages]
---
We switched from npm to pnpm in March 2026. Faster installs, better monorepo support.
```

---

## Why not just use CLAUDE.md?

CLAUDE.md is great for static rules you write once. memobank handles knowledge that accumulates over time — lessons learned, decisions made, patterns discovered. The two are complementary: CLAUDE.md for "always do X", memobank for "we learned Y".

## Why not a cloud memory API?

Tools like mem0 or Zep store memories in external services. memobank stores them in your Git repo — no API keys, no vendor lock-in, no data leaving your machine. Memory health is visible in `git diff`. Reviews happen in PRs.

## Why not Claude Code's built-in auto-memory?

Claude Code's auto-memory is personal and machine-local by default. memobank adds the team layer: `.memobank/` is committed alongside your code, so every teammate and every CI run starts with the same shared knowledge. memobank also works with Cursor, Codex, Gemini CLI, and Qwen Code.

---

## Features

**Memory management**
- Four types: `lesson`, `decision`, `workflow`, `architecture`
- Status lifecycle: `experimental → active → needs-review → deprecated`
- Automatic stale memory detection via `memo review`

**Search**
- Default: keyword + tag + recency scoring, zero external dependencies
- Optional: vector search via LanceDB (Ollama, OpenAI, Azure, Jina)

**Safety**
- Automatic secret redaction before every write (API keys, tokens, credentials)
- `memo scan` blocks workspace publish if secrets are detected

**Integrations**
- Claude Code — full skill with hooks, `!` recall injection, Stop hook auto-capture
- Cursor, Codex, Gemini CLI, Qwen Code — hooks installed via `memo onboarding`
- Import from Claude Code, Gemini, and Qwen: `memo import --claude`

**Team workflows**
- Workspace tier: cross-repo knowledge synced via separate Git remote
- Epoch-aware scoring: team knowledge naturally fades during handoffs
- `memo map` for memory statistics, `memo lifecycle` for health scans

---

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

---

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

---

## Directory Structure (v0.6.0+)

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
<repo-root>/.memobank/MEMORY.md
```

---

## Platform comparison

| Feature | Claude Code | Codex | Cursor | Gemini | Qwen |
|---|---|---|---|---|---|
| Auto recall at session start | ✅ `!` injection | Manual | Manual | Manual | Manual |
| Auto capture at session end | ✅ Stop hook | Manual | Manual | ✅ GEMINI.md | ✅ QWEN.md |
| `/memobank` skill invocation | ✅ | ❌ | ❌ | ❌ | ❌ |
| `alwaysApply` rule | ❌ | ✅ AGENTS.md | ✅ .mdc | ✅ | ✅ |

---

## References

- [references/claude-code.md](references/claude-code.md) — Claude Code full setup guide
- [references/codex.md](references/codex.md) — Codex setup guide
- [references/cursor.md](references/cursor.md) — Cursor setup guide
- [references/gemini.md](references/gemini.md) — Gemini CLI setup guide
- [references/qwen.md](references/qwen.md) — Qwen Code setup guide
- [references/memory-protocol.md](references/memory-protocol.md) — Canonical memory protocol
- [references/fallback.md](references/fallback.md) — Operation without memobank-cli
