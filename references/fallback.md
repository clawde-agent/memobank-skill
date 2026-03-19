# memobank — Without the CLI

The skill works without `memobank-cli`. Functionality is reduced but still useful.

## What works without CLI

- **MEMORY.md is read at session start** — via the `cat` fallback in skill injection
- **You can manually write memories** — directly to MEMORY.md in Markdown format
- **Claude's native auto-memory** — still writes to the configured directory if `autoMemoryDirectory` is set

## What requires CLI

- **Vector search** (LanceDB engine) — requires CLI and configured index
- **Smart extraction** (`memo capture --auto --silent`) — automatic extraction from auto-memory files
- **Structured memory files** — separate `personal/lesson/`, `personal/decision/`, etc. directories
- **Team sharing** — `memo team init/sync/publish` requires CLI
- **Secret scanning** — `memo scan` requires CLI
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
```

## How fallback retrieval works

The skill's `!` injection attempts these in order:

1. `memo recall "$ARGUMENTS"` — CLI retrieval
2. `cat ~/.memobank/.../MEMORY.md` — fallback: last cached MEMORY.md
3. `echo "(no memory configured...)"` — final: graceful message

## Installing the CLI

```bash
npm install -g memobank-cli

cd /path/to/your/project
memo init    # Interactive 4-step setup
```

## Directory structure (v0.3.0+)

```
~/.memobank/<project>/
├── personal/          # Local only
│   ├── lesson/
│   ├── decision/
│   ├── workflow/
│   └── architecture/
├── team/              # Synced to shared remote (optional)
├── memory/
│   └── MEMORY.md      # Last recall result
└── meta/
    └── config.yaml
```

## Limitations without CLI

- No smart capture — must manually extract learnings
- No recall/search — must read MEMORY.md directly
- No review reminders
- No team sharing
- No secret scanning

## When to upgrade to CLI

- You have >20 memories and manual upkeep is painful
- You want automatic capture from Claude's auto-memory
- You want to share memories with your team
- You need semantic search (LanceDB engine)

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/claude-code.md](claude-code.md) — Claude Code setup with CLI
