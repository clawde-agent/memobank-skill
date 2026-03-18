# memobank — Without the CLI

The skill works without `memobank-cli`. Functionality is reduced but still useful.

## What works without CLI

- **MEMORY.md is read at session start** — via the `cat` fallback in skill injection
- **You can manually write memories** — directly to MEMORY.md in Markdown format
- **Claude's native auto-memory** — still writes to the configured directory if `autoMemoryDirectory` is set

## What requires CLI

- **Vector search** (LanceDB engine) — requires CLI and configured index
- **Smart extraction** (`memo capture`) — automatic extraction from auto-memory files
- **Structured memory files** — separate `lessons/`, `decisions/`, etc. directories
- **Incremental indexing** — automatic updates when memories are added

## Manual memory format (without CLI)

Add entries to `~/.memobank/<project>/memory/MEMORY.md`:

```markdown
# Project Memory — <project>

## [lesson] Redis pool exhaustion (2026-03-17)
**Tags:** redis, reliability

Use connection pooling with max=10. Close connections in finally blocks.

---

## [decision] Chose blue-green deploy (2026-03-17)
**Tags:** deploy, infrastructure

Avoids downtime during deploy. Requires load balancer config. Trade-off: slower rollback.

---

## [workflow] Local testing with mocked APIs (2026-03-17)
**Tags:** testing, devops

1. Start mock server on localhost:9999
2. Set MOCK_API_URL env var
3. Run pytest
4. Verify in mock logs

---

## [architecture] Event-driven async pipeline (2026-03-17)
**Tags:** architecture, async

Producers emit events to Kafka. Workers consume and process. Results written to ClickHouse. Enables scaling and backpressure handling.
```

### Format details

- Use `## [<type>] Title (date)` for headings
- Add `**Tags:** tag1,tag2,...` after the heading
- Use multiple entries separated by `---`
- Types: `lesson`, `decision`, `workflow`, `architecture`

## How fallback retrieval works

The skill's `!` injection attempts these in order:

1. `memo recall "$ARGUMENTS"` — CLI retrieval (vector/hybrid search)
2. `cat ~/.memobank/.../MEMORY.md` — fallback: read last cached MEMORY.md
3. `echo "(no memory configured...)"` — final: graceful message

If the CLI is not installed, step 2 loads your manually written MEMORY.md.

## Installing the CLI later

When you're ready for the full features:

```bash
# Install CLI
npm install -g memobank-cli

# Initialize for your project
cd /path/to/your/project
git init  # if not already a git repo
memo install

# Configure for Claude Code
memo install --claude-code
# Or edit ~/.claude/settings.json manually:
# "autoMemoryDirectory": "~/.memobank/<project>/memory/"
```

All your manually written memories in MEMORY.md are still valid — the CLI reads them alongside structured files.

## Migration from manual to CLI

After installing the CLI, run:

```bash
# Extract memories from manual MEMORY.md and store as structured files
memo migrate --from ~/.memobank/<project>/memory/MEMORY.md
```

This creates separate files in `lessons/`, `decisions/`, `workflow/`, and `architecture/` directories.

## Limitations without CLI

- **No smart capture** — you must manually extract learnings from auto-memory files
- **No search** — you must grep MEMORY.md or read the whole file
- **No review reminders** — no `memo review --due` for outdated memories
- **No visualization** — no `memo map` for clustering
- **Manual upkeep** — you must maintain MEMORY.md structure yourself

## When to upgrade to CLI

Upgrade when:
- You have >20 memories and search becomes painful
- You want automatic capture from Claude's auto-memory
- You need vector similarity search (semantic matching)
- You want to track review reminders for outdated info

If your project is small or you're just getting started, manual MEMORY.md works fine.

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/claude-code.md](claude-code.md) — Claude Code setup with CLI
