# memobank

**AI agents forget everything between sessions. memobank teaches them to learn.**

Most tools give AI a memory. memobank gives it a learning loop — capturing what worked, surfacing it when relevant, and moving domain knowledge across teammates, tools, and time.

Works with **Claude Code, Cursor, Codex, Gemini CLI, and Qwen Code**. Zero external services.

---

## Memory isn't enough

A parrot with perfect recall is still just a parrot.

memobank borrows from how humans actually learn, not just remember:

**Spaced repetition.** Memories recalled regularly get promoted to `active`. Ones that go unused drift toward `deprecated`. The agent stops treating a three-year-old architectural decision the same as something that came up last week.

**Domain knowledge transfer.** The Workspace tier lets a team codify decisions and lessons once, then share them across every repo. A new engineer — or a fresh AI session — clones the repo and starts with months of context, not a blank slate.

**Structure over logs.** Raw chat history is noise. memobank enforces four typed formats (`lesson`, `decision`, `workflow`, `architecture`) so captured knowledge stays findable.

---

## Three storage layers, each doing what it's good at

Most memory systems pick one approach. memobank uses three:

| Layer | How it works | Good for |
|---|---|---|
| Git + Markdown | Human-readable files, committed alongside code | Long-term knowledge, team review, audit trail |
| Keyword + tag index | Full-text search with decay scoring | Fast lookups, recent context, offline use |
| Vector embeddings | Semantic similarity via Ollama / OpenAI / Azure | Fuzzy recall, code symbol search, cross-concept links |

All three run on every `memo recall`. Results are merged and re-ranked by recency and confidence, then written to `MEMORY.md`. The AI reads that file at session start. You get precise structured search and flexible semantic similarity without picking one.

---

## Get started

**Recommended — via skills CLI (no remote script execution):**

```bash
npx skills add clawde-agent/memobank-skill/memobank
memo onboarding
```

**Or ask Claude Code directly:**

> "Install this skill for me: https://github.com/clawde-agent/memobank-skill"

**Manual — review the script before running:**

```bash
# Download and inspect first
curl -fsSL https://raw.githubusercontent.com/clawde-agent/memobank-skill/main/install.sh -o install.sh
cat install.sh   # review contents
bash install.sh --with-cli
memo onboarding
```

Then use it:

```
/memobank debug the auth flow
/memobank refactor the payment module
```

For teams: commit `.memobank/` alongside your code. Every teammate and CI run starts with the same context.

```bash
git add .memobank/
git commit -m "init team memory"
```

---

## How it works

Three knowledge tiers, like `git config` levels:

| Tier | Location | Committed? | Scope |
|------|----------|-----------|-------|
| Personal | `~/.memobank/<project>/` | No | Your machine only |
| Project | `<repo>/.memobank/` | Yes | Everyone who clones |
| Workspace | `~/.memobank/_workspace/` | Separate remote | Across multiple repos |

`memo recall` searches all active tiers, merges results, and writes top matches to `.memobank/MEMORY.md`. The skill loads that file at session start. No plugins, no configuration beyond `memo onboarding`.

Memories are plain markdown with a small YAML header — readable, diffable, reviewable in PRs:

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

## Why memobank

| | memobank | CLAUDE.md | Cloud APIs (mem0, Zep) | Built-in auto-memory |
|---|---|---|---|---|
| Gets smarter over time | ✅ lifecycle scoring | ❌ manual | ✅ | partial |
| Team knowledge transfer | ✅ Git + Workspace | ✅ static | ❌ | ❌ |
| No external services | ✅ | ✅ | ❌ | ✅ |
| Works across AI tools | ✅ 5+ tools | ✅ | varies | Claude Code only |
| Auditable & reviewable | ✅ Git diff / PR | ✅ | ❌ | ❌ |
| Secrets never leave repo | ✅ auto-redact | ✅ | ❌ | ✅ |

---

## What you get

Memories move through a lifecycle: `experimental → active → needs-review → deprecated`. Frequently recalled knowledge gets promoted; unused knowledge fades. The agent's working context self-curates — you don't prune it manually.

When someone new joins a project, they clone the repo and get the team's decisions and lessons alongside the code. The Workspace tier extends this across repos. Epoch-aware scoring resets decay after team handoffs so old context doesn't crowd out new work.

`memo recall --code` searches memories and your codebase in the same query. `memo index-code` parses TypeScript, Python, Go, Rust, and more with tree-sitter. `memo recall --refs <symbol>` shows every caller of a function.

API keys, tokens, and PII are automatically redacted before any write. `memo workspace publish` refuses to run if secrets are present — nothing slips through silently.

---

## Platform support

| Feature | Claude Code | Codex | Cursor | Gemini | Qwen |
|---|---|---|---|---|---|
| Auto recall at session start | ✅ | Manual | Manual | Manual | Manual |
| Auto capture at session end | ✅ Stop hook | Manual | Manual | ✅ | ✅ |
| `/memobank` skill invocation | ✅ | ❌ | ❌ | ❌ | ❌ |
| `alwaysApply` rule | ❌ | ✅ | ✅ | ✅ | ✅ |

---

## Manual installation

### Claude Code
```bash
mkdir -p ~/.claude/skills/memobank
cp SKILL.md ~/.claude/skills/memobank/
cp -r references/ ~/.claude/skills/memobank/references/
```

### Other platforms
```bash
bash install.sh --cursor        # Cursor
bash install.sh --codex         # Codex
memo install --platform gemini  # Gemini CLI
memo install --platform qwen    # Qwen Code
bash install.sh --all           # everything at once
```

---

## References

- [CLI Reference](references/cli-reference.md) — full command and flag documentation
- [Memory Protocol](references/memory-protocol.md) — when and how to write memories
- [Claude Code setup](references/claude-code.md) — hooks, auto-memory, skill invocation
- [Cursor](references/cursor.md) · [Codex](references/codex.md) · [Gemini](references/gemini.md) · [Qwen](references/qwen.md)
- [Fallback guide](references/fallback.md) — operation without memobank-cli
