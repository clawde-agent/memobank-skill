# memobank-skill

One-click memory skill for Claude Code, Codex, and Cursor.

Gives coding agents persistent project memory: past decisions, lessons, and workflows — recalled automatically at the start of each session.

## Features

| Feature | Claude Code | Codex | Cursor |
|---|---------|-------|--------|
| **Auto-recall at session start** | ✅ `!` injection | ✅ Protocol instruction | ✅ Rules file |
| **Auto-capture at session end** | ✅ `hooks.Stop` | ⚠️ Manual | ⚠️ Manual |
| **Vector search (LanceDB)** | ✅ With CLI | ✅ With CLI | ✅ With CLI |
| **Structured memory files** | ✅ With CLI | ✅ With CLI | ✅ With CLI |
| **Works without CLI** | ✅ Fallback | ✅ Fallback | ✅ Fallback |

## Quick Start

### Install (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/org/memobank-skill/main/install.sh | bash
```

Or for a specific platform:

```bash
bash install.sh --claude-code   # Claude Code only
bash install.sh --codex         # Codex / AGENTS.md
bash install.sh --cursor        # Cursor rules
```

### Install memobank-cli (recommended)

For full features (vector search, auto-capture, structured files):

```bash
npm install -g memobank-cli
cd /path/to/your/project
git init  # if not already a git repo
memo install
```

## Usage in Claude Code

```
/memobank deploy the new API
/memobank debug the auth flow
/memobank refactor the data pipeline
```

Claude recalls relevant memories before starting, captures new learnings when done.

### How it works

1. **Dynamic recall** (`!` injection): `memo recall` runs *before* Claude reads the prompt. Top-N memories are inlined as context.
2. **Auto-capture** (`hooks.Stop`): When Claude finishes, `memo capture --auto` runs silently to extract learnings.
3. **Token-efficient**: No MCP, no persistent process.

## Configuration (Claude Code)

### autoMemoryDirectory (recommended)

Set where Claude's native auto-memory writes go:

```bash
memo install --claude-code
```

Or manually add to `~/.claude/settings.json`:

```json
{
  "autoMemoryDirectory": "~/.memobank/<project>/memory/"
}
```

Replace `<project>` with your git repo name.

## Without memobank-cli

The skill works without the CLI. Features are reduced but still useful:

✅ **Works:**
- MEMORY.md is read at session start (fallback)
- Manual memory writes to MEMORY.md
- Claude's native auto-memory

❌ **Requires CLI:**
- Vector search
- Smart extraction (`memo capture`)
- Structured memory files in `lessons/`, `decisions/`, etc.
- Incremental indexing

### Manual memory format

Add to `~/.memobank/<project>/memory/MEMORY.md`:

```markdown
## [lesson] Redis pool exhaustion (2026-03-17)
**Tags:** redis, reliability

Use connection pooling with max=10. Close connections in finally blocks.

## [decision] Chose blue-green deploy (2026-03-17)
**Tags:** deploy, infrastructure

Avoids downtime during deploy. Requires load balancer config.
```

See [`references/fallback.md`](references/fallback.md) for details.

## Memory Protocol

### When to recall

At session start: `memo recall "<current task>"`

### When to write

Capture immediately when you:
- **Fix a non-obvious bug** → `memo write lesson`
- **Make an architectural decision** → `memo write decision`
- **Discover a repeatable workflow** → `memo write workflow`
- **Document system architecture** → `memo write architecture`

### Memory types

| Type | When to use |
|---|---|
| `lesson` | Something went wrong, fix wasn't obvious |
| `decision` | You chose X over Y, why |
| `workflow` | Repeatable step-by-step process |
| `architecture` | How the system is structured |

### Example

```bash
memo write lesson \
  --name="Redis pool exhaustion" \
  --description="Use connection pooling with max=10" \
  --tags="redis,reliability" \
  --content="Production timeouts. Root cause: too many open connections. Fixed with pooling."
```

## Commands Reference

### Recall
```bash
memo recall "query"                # Retrieve top-N memories
memo recall "query" --limit=10     # Get more results
```

### Search
```bash
memo search "query"                    # keyword search
memo search "query" --engine=lancedb   # vector search
memo search "query" --tag=redis        # filter by tag
memo search "query" --type=decision    # filter by type
```

### Review
```bash
memo review --due          # show memories flagged for review
memo review --id <id>      # review specific memory
```

### Map
```bash
memo map                   # visualize memory clusters
```

## Platform-Specific Setup

### Claude Code
- See [`references/claude-code.md`](references/claude-code.md)
- Install: `bash install.sh --claude-code`

### Codex / AGENTS.md
- See [`references/codex.md`](references/codex.md)
- Snippet: [`platform/codex/AGENTS-snippet.md`](platform/codex/AGENTS-snippet.md)
- Install: `bash install.sh --codex`

### Cursor
- See [`references/cursor.md`](references/cursor.md)
- Rules file: [`platform/cursor/memobank.mdc`](platform/cursor/memobank.mdc)
- Install: `bash install.sh --cursor`

## File Structure

```
memobank-skill/
├── SKILL.md                              # Main skill (AgentSkills standard)
├── install.sh                            # One-click installer
├── README.md
├── references/
│   ├── claude-code.md                    # Claude Code setup
│   ├── codex.md                          # Codex / AGENTS.md setup
│   ├── cursor.md                         # Cursor setup
│   ├── memory-protocol.md                # Shared memory protocol
│   └── fallback.md                       # Operation without CLI
└── platform/
    ├── codex/
    │   └── AGENTS-snippet.md             # Ready-to-paste AGENTS.md section
    └── cursor/
        └── memobank.mdc                  # Cursor rules file
```

## Testing

### Manual smoke test

```bash
# 1. Install skill
bash install.sh --claude-code

# 2. Install CLI (optional)
npm install -g memobank-cli
cd /tmp && mkdir test-project && cd test-project && git init
memo install

# 3. Write a test memory
memo write lesson \
  --name="test-memory" \
  --description="This is a test" \
  --tags="test"

# 4. Recall it
memo recall "test"
# Expected: MEMORY.md updated with test-memory

# 5. Verify Claude Code loads it
# Open Claude Code in /tmp/test-project
# Run: /memobank test task
# Expected: memory context block appears before Claude's response
```

## Design Decisions

- **`hooks.Stop` instead of PostToolUse**: Fires once per session end, not after every tool call
- **`!` injection vs static CLAUDE.md**: Fresh retrieval on each invocation, not stale cache
- **`allowed-tools: Bash(memo *)`**: Scoped auto-approval to only memo commands
- **Graceful degradation**: Works with or without CLI, with helpful fallback chain
- **Platform-agnostic protocol**: Same memory rules across Claude Code, Codex, Cursor

## Troubleshooting

### `/memobank` command not found

Restart Claude Code. Skill files are loaded at startup.

### Memory context not appearing

Check that `memo recall` works in your terminal:
```bash
memo recall "test"
```

If memo is not installed, you'll see: "(no memory configured — run: memo install)"

### Auto-capture not working (Claude Code)

Check that the hook is in `~/.claude/skills/memobank/SKILL.md`:
```yaml
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null || true"
```

## Contributing

Contributions welcome! Please read the design spec in `docs/specs/2026-03-17-memobank-skill-design.md`.

## License

MIT

## See Also

- [memobank-cli](https://github.com/org/memobank-cli) — Core CLI for memory management
- [AgentSkills](https://github.com/Anthropic/agentskills) — Claude Code skills standard
