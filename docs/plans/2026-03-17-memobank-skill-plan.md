# memobank-skill Implementation Plan
**Date:** 2026-03-17
**Spec:** docs/specs/2026-03-17-memobank-skill-design.md
**Goal:** One-click installable skill for Claude Code, Codex, and Cursor

---

## File Map

```
memobank-skill/
├── SKILL.md                              # Main skill (AgentSkills standard)
├── install.sh                            # One-click installer
├── README.md
├── references/
│   ├── claude-code.md                    # Claude Code setup details
│   ├── codex.md                          # Codex / AGENTS.md setup details
│   ├── cursor.md                         # Cursor setup details
│   ├── memory-protocol.md                # Shared memory protocol instructions
│   └── fallback.md                       # Operation without memobank-cli
└── platform/
    ├── codex/
    │   └── AGENTS-snippet.md             # Ready-to-paste AGENTS.md section
    └── cursor/
        └── memobank.mdc                  # Cursor rules file
```

---

## Tasks

### Task 1 — `references/memory-protocol.md`

The canonical memory protocol. All other files reference this. Write first.

Content covers:
- **When to recall**: at session start (done automatically by skill injection)
- **When to write**: immediately when you learn something significant
  - Fixed a non-obvious bug
  - Made an architectural decision
  - Discovered a reusable workflow
  - Found a pattern worth remembering
- **Memory types and when to use each**:
  - `lesson`: what went wrong, what the fix was
  - `decision`: why we chose X over Y
  - `workflow`: step-by-step repeatable process
  - `architecture`: how the system is structured
- **Sanitization rules**: never write API keys, passwords, tokens, IPs, PII
- **Quality bar**: if it wouldn't save a future developer time, skip it
- **Commands reference**:
  ```bash
  memo write lesson --name="..." --description="..." --tags="..." --content="..."
  memo write decision --name="..." --description="..." --tags="..."
  memo search "query"
  memo review --due
  memo map
  ```

Test: Document is clear, under 100 lines, covers all memory types with one example each.

---

### Task 2 — `SKILL.md`

The primary artifact. Follow AgentSkills standard exactly.

```yaml
---
name: memobank
description: >
  Project memory system. Recalls relevant past decisions, lessons, and workflows
  before starting work. Captures new learnings at session end. Use when starting
  any coding task, debugging, or architectural work.
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null || true"
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash(memo *)
---
```

Body structure:
1. **Memory Context section** — the dynamic injection block:
   ```
   !`memo recall "$ARGUMENTS" 2>/dev/null || cat ~/.memobank/$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null || echo default)/memory/MEMORY.md 2>/dev/null || echo "(no memory configured — run: memo install)"`
   ```
2. **Memory Protocol section** — when and how to write memories (link to `references/memory-protocol.md`)
3. **Search commands** — quick reference for `memo search`, `memo review`, `memo map`
4. **Setup reference** — links to `references/claude-code.md` and `references/fallback.md`

Key requirements:
- Body under 80 lines (supporting detail lives in `references/`)
- The `!` injection command must have the full fallback chain
- `hooks.Stop` command must have `|| true` to never block a session
- `allowed-tools: Bash(memo *)` scopes auto-approval to memo commands only

Test: Copy SKILL.md to `~/.claude/skills/memobank/SKILL.md`. Run `/memobank "test query"` in Claude Code. Verify memory context appears in the prompt before Claude responds.

---

### Task 3 — `references/claude-code.md`

Claude Code-specific setup guide:

```markdown
# memobank — Claude Code Setup

## How it works

1. **Dynamic recall** (`!` injection): when you invoke `/memobank <task>`,
   `memo recall` runs *before* Claude reads the prompt. Top-N memories
   are injected as context. Zero MCP overhead.

2. **Auto-capture** (`hooks.Stop`): when Claude finishes responding,
   `memo capture --auto` runs silently. Any significant learnings from
   Claude's auto-memory writes are extracted and stored as structured memories.

3. **Auto-memory integration**: set `autoMemoryDirectory` in
   `~/.claude/settings.json` to point to your memobank repo's `memory/`
   directory. Claude's native auto-memory writes go there, and
   `memo capture` picks them up.

## Installation

\```bash
# Option A: manual
mkdir -p ~/.claude/skills/memobank
cp SKILL.md ~/.claude/skills/memobank/SKILL.md
cp -r references/ ~/.claude/skills/memobank/references/

# Option B: one-liner
curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash --claude-code
\```

## Configure autoMemoryDirectory (recommended)

\```bash
memo install --claude-code
# This sets autoMemoryDirectory in ~/.claude/settings.json
\```

Or manually add to `~/.claude/settings.json`:
\```json
{
  "autoMemoryDirectory": "~/.memobank/<project>/memory/"
}
\```

## Usage

\```
/memobank deploy the new feature
/memobank debug the Redis connection issue
/memobank refactor the auth module
\```

Or let Claude invoke it automatically when you start a coding task.
```

Test: A developer who has never used memobank can follow these steps and have `/memobank` working in under 5 minutes.

---

### Task 4 — `references/fallback.md`

For users without `memobank-cli` installed:

```markdown
# memobank — Without the CLI

The skill works without `memobank-cli`. Functionality is reduced but still useful.

## What works without CLI

- MEMORY.md is read at session start (via `cat` fallback in skill injection)
- You can manually write memories directly to MEMORY.md
- Claude's native auto-memory still writes to the configured directory

## What requires CLI

- Vector search (LanceDB engine)
- Smart extraction (`memo capture`)
- Structured memory files in `lessons/`, `decisions/`, etc.
- Incremental indexing

## Manual memory format (without CLI)

Add to `~/.memobank/<project>/memory/MEMORY.md`:

\```markdown
## [lesson] Redis pool exhaustion (2026-03-17)
Use connection pooling with max=10. Close connections in finally blocks.
tags: redis, reliability

## [decision] Chose blue-green deploy (2026-03-17)
Avoids downtime during deploy. Requires load balancer config.
tags: deploy, infrastructure
\```

## Installing the CLI later

\```bash
npm install -g memobank-cli
memo install --all
\```

All manually written memories remain valid — CLI reads them alongside structured files.
```

Test: A user with no CLI can manually add a memory and have it appear in the next session's context.

---

### Task 5 — `references/codex.md` + `references/cursor.md`

**`codex.md`** — Codex / OpenAI Codex setup:
- How AGENTS.md injection works
- Where `memo recall` output goes (MEMORY.md path)
- Manual recall at session start instruction
- Link to `platform/codex/AGENTS-snippet.md`

**`cursor.md`** — Cursor setup:
- How `.cursor/rules/memobank.mdc` works
- `alwaysApply: true` means memory protocol loads every session
- `memo recall` must be run manually (no `!` injection in Cursor rules)
- Link to `platform/cursor/memobank.mdc`

---

### Task 6 — `platform/codex/AGENTS-snippet.md`

Ready-to-paste section for AGENTS.md:

```markdown
## Memory Protocol (memobank)

You have access to project memory. Use it every session.

**Session start:** Read `~/.memobank/<project>/memory/MEMORY.md` before starting work.
Replace `<project>` with the current git repo name.

**During session:** When you learn something significant, write it:
\```bash
memo write lesson --name="..." --description="..." --tags="..." --content="..."
\```
Types: `lesson` | `decision` | `workflow` | `architecture`

**Session end:** Run `memo capture --auto` to extract and store learnings.

**Search:** `memo search "query"` to find specific memories.

If memobank-cli is not installed, manually edit `~/.memobank/<project>/memory/MEMORY.md`.
```

---

### Task 7 — `platform/cursor/memobank.mdc`

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

---

### Task 8 — `install.sh`

One-click installer. Must be idempotent (safe to run multiple times).

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/org/memobank-skill/main"
SKILL_DIR="${HOME}/.claude/skills/memobank"

install_claude_code() {
  echo "→ Installing memobank skill for Claude Code..."
  mkdir -p "$SKILL_DIR/references"
  curl -fsSL "$REPO_RAW/SKILL.md" -o "$SKILL_DIR/SKILL.md"
  for f in claude-code.md memory-protocol.md fallback.md codex.md cursor.md; do
    curl -fsSL "$REPO_RAW/references/$f" -o "$SKILL_DIR/references/$f"
  done
  echo "✓ Skill installed at: $SKILL_DIR"
}

install_codex() {
  local agents_file="${1:-AGENTS.md}"
  [[ ! -f "$agents_file" ]] && { echo "⚠  No AGENTS.md found. Skipping."; return; }
  grep -q "memobank" "$agents_file" && { echo "✓ Already in AGENTS.md"; return; }
  curl -fsSL "$REPO_RAW/platform/codex/AGENTS-snippet.md" >> "$agents_file"
  echo "✓ Memory protocol appended to AGENTS.md"
}

install_cursor() {
  mkdir -p ".cursor/rules"
  curl -fsSL "$REPO_RAW/platform/cursor/memobank.mdc" -o ".cursor/rules/memobank.mdc"
  echo "✓ Cursor rule installed: .cursor/rules/memobank.mdc"
}

suggest_cli() {
  command -v memo &>/dev/null && return
  echo ""
  echo "Tip: install memobank-cli for vector search + auto-capture:"
  echo "  npm install -g memobank-cli && memo install"
}

# Default: install all
PLATFORMS=("claude-code" "codex" "cursor")
[[ $# -gt 0 ]] && PLATFORMS=("$@")

for p in "${PLATFORMS[@]}"; do
  case "$p" in
    --claude-code|claude-code) install_claude_code ;;
    --codex|codex)             install_codex ;;
    --cursor|cursor)           install_cursor ;;
  esac
done

suggest_cli
echo ""
echo "Done. Start Claude Code and try: /memobank <your current task>"
```

Test: Run `bash install.sh --claude-code` in a temp directory. Verify `~/.claude/skills/memobank/SKILL.md` exists and is valid. Run again — no errors (idempotent).

---

### Task 9 — `README.md`

```markdown
# memobank-skill

One-click memory skill for Claude Code, Codex, and Cursor.

Gives coding agents persistent project memory: past decisions, lessons,
and workflows — recalled automatically at the start of each session.

## Install (one-liner)

\```bash
curl -fsSL https://raw.githubusercontent.com/org/memobank-skill/main/install.sh | bash
\```

Or for a specific platform:

\```bash
bash install.sh --claude-code   # Claude Code only
bash install.sh --codex         # Codex / AGENTS.md
bash install.sh --cursor        # Cursor rules
\```

## How it works

| Feature | Mechanism |
|---|---|
| Auto-recall at session start | `!` dynamic injection in SKILL.md |
| Auto-capture at session end | `hooks.Stop` in SKILL.md frontmatter |
| Works without CLI | Fallback to `cat MEMORY.md` |
| Token-efficient | No MCP, no persistent process |

## With memobank-cli (recommended)

\```bash
npm install -g memobank-cli
memo install
\```

Enables vector search (LanceDB), smart extraction, and structured memory files.

## Usage in Claude Code

\```
/memobank deploy the new API
/memobank debug the auth flow
/memobank refactor the data pipeline
\```

Claude recalls relevant memories before starting, captures new learnings when done.

## Platform support

| Platform | Support | Config file |
|---|---|---|
| Claude Code | ✅ Full (skill + hooks) | `~/.claude/skills/memobank/` |
| Codex | ✅ Protocol injection | `AGENTS.md` |
| Cursor | ✅ Rules file | `.cursor/rules/memobank.mdc` |
| Gemini CLI | 🔜 Planned | — |
```

---

### Task 10 — End-to-end smoke test

Manual test script (document in README under "Testing"):

```bash
# 1. Install skill
bash install.sh --claude-code

# 2. Install CLI (optional but recommended)
npm install -g memobank-cli
cd /tmp && mkdir test-project && cd test-project && git init
memo install --claude-code

# 3. Write a test memory
memo write lesson \
  --name="test-memory" \
  --description="This is a test memory for smoke testing" \
  --tags="test,smoke"

# 4. Recall it
memo recall "test smoke"
# Expected: MEMORY.md updated, test-memory appears in output

# 5. Verify Claude Code loads it
# Open Claude Code in /tmp/test-project
# Run: /memobank test task
# Expected: memory context block appears before Claude's response
```
