# memobank-skill

One‑click installable skill for Claude Code, Codex, and Cursor that gives coding agents persistent project memory: past decisions, lessons, and workflows are recalled automatically at the start of each session, and new learnings are captured at session end.

## Features

- 🧠 **Automatic Recall**: `!memo recall` runs before the agent sees your prompt, injecting relevant memories as context.
- 💾 **Auto‑Capture**: `hooks.Stop` runs `memo capture --auto` after each response to save significant learnings.
- 🔌 **Platform Support**:
  - Claude Code: full skill with hooks
  - Codex: manual protocol injection into `AGENTS.md`
  - Cursor: `.cursor/rules/memobank.mdc` rule file (`alwaysApply: true`)
- 📦 **Zero‑Dependency Fallback**: Works even without `memobank-cli` installed (reads/writes plain `MEMORY.md`).
- 🛡️ **Secret Sanitization**: CLI redacts API keys, tokens, IPs, PII, etc. (20+ patterns).
- 📥 **Memory Import**: Import from Claude Code, Gemini CLI, Qwen Code.
- 🎯 **Interactive Setup**: Guided configuration with `memo setup`.
- 📖 **Comprehensive Docs**: references for memory protocol, platform setup, and fallback usage.

## Quick Start (One‑Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/clawde-agent/memobank-skill/main/install.sh | bash
```

This installs the skill for Claude Code, Codex, and Cursor. After installation, run:

```bash
memo onboarding    # Interactive setup (recommended for new users)
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

### Codex / Manual
Append the contents of `platform/codex/AGENTS-snippet.md` to your project's `AGENTS.md`.

### Cursor
```bash
mkdir -p .cursor/rules
cp platform/cursor/memobank.mdc .cursor/rules/
```

## Usage with memobank-cli (Recommended)

For full functionality (vector search, LLM extraction, structured files):

```bash
npm install -g memobank-cli
memo install --all   # sets up directory structure and platform integrations
```

Then the skill will automatically use the CLI for:
- Vector + BM25 hybrid search (LanceDB engine)
- Smart extraction of memories from session text
- Organized storage in `lessons/`, `decisions/`, `workflows/`, `architecture/`
- Secret sanitization and decay scoring

## Memory Protocol

See `references/memory-protocol.md` for full details on:
- When to recall (session start, before starting work)
- When to write (immediately after learning something significant)
- Memory types: `lesson`, `decision`, `workflow`, `architecture`
- Tags, confidence levels, and review dates
- Sanitization rules (never write API keys, passwords, etc.)

## Commands (when memobank-cli is installed)

| Command | Description |
|---------|-------------|
| `memo onboarding` | Interactive setup wizard (recommended for new users) |
| `memo init` | Alias for onboarding |
| `memo install` | Initialize memobank directory structure |
| `memo import` | Import memories from other AI tools (Claude Code, Gemini CLI, Qwen Code) |
| `memo recall <query>` | Search memories and update `MEMORY.md` |
| `memo search <query>` | Debug search without writing `MEMORY.md` |
| `memo capture [--auto]` | Extract learnings from session text |
| `memo write <type>` | Create a new memory (interactive or non‑interactive) |
| `memo index` | Build/update search index (for LanceDB engine) |
| `memo review [--due]` | List memories due for review |
| `memo map` | Show memory statistics and summary |
| `memo lifecycle` | View memory lifecycle report (tiers, access patterns) |
| `memo correct <path>` | Record a correction for a memory |

## CLAUDE CODE SPECIFIC

When you invoke `/memobank <task>`:
1. `!memo recall "$ARGUMENTS"` runs *before* Claude reads your prompt.
2. Top‑N memories (configured in `meta/config.yaml`) are injected as context.
3. Claude responds with the benefit of past lessons, decisions, etc.
4. When Claude finishes, `hooks.Stop` runs `memo capture --auto` to save any significant new learnings from the session.

## FALLBACK WITHOUT CLI

If `memobank-cli` is not installed, the skill gracefully falls back:
- Session start: `cat ~/.memobank/<project>/memory/MEMORY.md` (or helpful hint to run `memo install`)
- You can manually edit `MEMORY.md` to add memories in the format:

  ```markdown
  ## [lesson] Redis pool exhaustion · high confidence
  > Use connection pooling with max=10; close connections in finally blocks.
  > `lessons/2026-02-14-redis-pool.md` · tags: redis, reliability
  ```

- `memo capture` and structured file storage require the CLI.

## Development & Contributing

```bash
# Clone the skill repo
git clone https://github.com/clawde-agent/memobank-skill.git
cd memobank-skill

# Run the installer locally for testing
bash install.sh --claude-code   # or --codex, --cursor

# Verify installation
ls -la ~/.claude/skills/memobank/
```

## License

MIT © 2026 Memobank Project

