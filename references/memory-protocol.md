# memobank — Memory Protocol

The canonical memory protocol for all coding agents (Claude Code, Codex, Cursor, Gemini, Qwen). Defines when and how to use project memory.

---

## When to Recall

**At session start** — Before starting any work, recall relevant memories:

```bash
memo recall "<current task>"
```

Example: `memo recall "debug the Redis connection issue"`

This retrieves top-N memories, writes them to MEMORY.md, and prints them.

**Scope options:**
```bash
memo recall "query" --scope personal   # personal memories only
memo recall "query" --scope project    # project (team) memories only
memo recall "query" --scope workspace  # org-wide workspace only
memo recall "query" --scope all        # all tiers (default)
memo recall "query" --explain          # show keyword/tags/recency score breakdown
```

---

## When to Write

Capture immediately when you:

- **Fix a non-obvious bug** — Something that took time to figure out
- **Make an architectural decision** — Why you chose X over Y
- **Discover a repeatable workflow** — Step-by-step process worth reusing
- **Find a pattern worth remembering** — Code structure, API pattern, etc.

If it would save a future developer time, write it down.

---

## Memory Types

### `lesson` — Something went wrong, fix wasn't obvious

```bash
memo write lesson \
  --name="Redis pool exhaustion" \
  --description="Use connection pooling with max=10" \
  --tags="redis,reliability" \
  --content="Production hitting timeout errors. Root cause: too many open connections. Fixed with pooling max=10 and explicit close() in finally blocks."
```

### `decision` — Why you chose X over Y

```bash
memo write decision \
  --name="Blue-green deploy" \
  --description="Avoids downtime during deploy" \
  --tags="deploy,infrastructure" \
  --content="Chose over rolling update. Zero downtime. Trade-off: requires load balancer config, slower rollback."
```

### `workflow` — Repeatable step-by-step process

```bash
memo write workflow \
  --name="Local testing with mocked APIs" \
  --description="Run integration tests without external deps" \
  --tags="testing,devops" \
  --content="1. Start mock server on localhost:9999. 2. Set MOCK_API_URL env var. 3. Run pytest. 4. Verify in mock logs."
```

### `architecture` — How the system is structured

```bash
memo write architecture \
  --name="Event-driven async pipeline" \
  --description="Decoupled data flow via message queue" \
  --tags="architecture,async" \
  --content="Producers emit events to Kafka. Workers consume and process. Results written to ClickHouse."
```

---

## Memory Lifecycle & Status

Each memory carries a `status` field that evolves automatically based on recall frequency and time:

| Status | Meaning |
|--------|---------|
| `experimental` | Newly written, unverified — deprecated automatically after 30 days if never recalled |
| `active` | Trusted; recalled at least once — downgraded to `needs-review` after 90 days without recall |
| `needs-review` | May be stale — downgraded to `deprecated` after a further 90 days without recall |
| `deprecated` | Excluded from default recall; still searchable |

**Status transition rules:**

- `experimental → active`: recalled at least once (any single recall suffices)
- `active → needs-review`: not recalled for ≥ 90 days (`active_to_review_days`)
- `needs-review → active`: recalled ≥ 3 times (deliberate re-validation; `review_recall_threshold: 3`)
- `needs-review → deprecated`: not recalled for ≥ 90 days after entering `needs-review` (`review_to_deprecated_days`)
- `experimental → deprecated`: not recalled within 30 days of creation (`experimental_ttl_days`)
- `deprecated → needs-review`: recalled at least once (recovery path)

Run the periodic scan to apply downgrade rules (safe to run in CI):

```bash
memo lifecycle --scan
```

---

## Workspace Memory (Org-Wide)

Share memories across the organisation via a shared Git remote:

```bash
memo workspace init git@github.com:your-org/platform-docs.git
memo workspace publish .memobank/lesson/2026-03-19-redis-pooling.md
memo workspace sync    # pull + push
```

Recall results label sources: `[workspace]` / `[project]` / `[personal]`.

The workspace config written to `meta/config.yaml`:

```yaml
workspace:
  remote: git@github.com:your-org/platform-docs.git
  auto_sync: false
  branch: main          # default branch to sync against
  path: .memobank       # optional — subdirectory within the remote repo
```

---

## Search & Recall Quality

**Recall scoring** combines keyword match, tag overlap, recency decay, and access frequency boost. Frequently recalled memories get up to 1.5× score multiplier.

**Embedding (vector search)** — configure via `memo onboarding` (alias: `memo init`) → lancedb engine:
- **Ollama** — local, no API key needed (model: `mxbai-embed-large`, 1024 dimensions)
- **OpenAI** — set `OPENAI_API_KEY` (model: `text-embedding-3-small`, 1536 dimensions)
- **Azure** — set `AZURE_API_KEY` (model: `text-embedding-ada-002`, 1536 dimensions)
- **Jina AI** — set `JINA_API_KEY` (model: `jina-embeddings-v3`, 1024 dimensions)

**Reranker** — optional second-pass AI reranking for better precision:
- **Jina AI** — set `JINA_API_KEY` (model: `jina-reranker-v2-base-multilingual`)
- **Cohere** — set `COHERE_API_KEY` (model: `rerank-v3.5`)

Enable during `memo onboarding` (alias: `memo init`), or manually in `meta/config.yaml`:
```yaml
reranker:
  enabled: true
  provider: jina   # or cohere
  top_n: 5         # optional — number of results to return after reranking
```

---

## Sanitization Rules

**Never include:**
- API keys, passwords, tokens
- Private IP addresses (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
- PII (personally identifiable information)
- Secret URLs or endpoints

Run `memo scan --fix` before publishing to workspace to auto-redact detected secrets.

**Always include:**
- What went wrong (the problem)
- Why it happened (the root cause)
- How to fix it (the solution)

---

## Quality Bar

Write memories that would save a future developer time. Skip obvious or trivial things.

---

## Command Reference

### Recall
```bash
memo recall "query"                      # Retrieve top-N + write MEMORY.md
memo recall "query" --scope personal     # Personal only
memo recall "query" --scope project      # Project (team) only
memo recall "query" --scope workspace    # Org-wide only
memo recall "query" --explain            # Show score breakdown
```

### Capture & Queue
```bash
memo capture --auto                      # Extract from Claude auto-memory files → pending queue
memo process-queue                       # Drain pending queue: dedup + write to memory files
memo process-queue --background          # Same, detached background process (used by Stop hook)
```

### Write
```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

### Search (debug, no MEMORY.md update)
```bash
memo search "query"                      # Keyword search
memo search "query" --engine=lancedb     # Vector search
memo search "query" --tag=redis          # Filter by tag
memo search "query" --type=decision      # Filter by type
```

### Lifecycle
```bash
memo lifecycle                # View lifecycle report
memo lifecycle --scan         # Run full scan, downgrade stale memories
memo lifecycle --reset-epoch  # Reset epoch for team handoff
memo correct <path>           # Record a correction
```

### Workspace
```bash
memo workspace init <remote-url>
memo workspace sync
memo workspace sync --push
memo workspace publish <file>
memo workspace status
```

### Scan
```bash
memo scan              # Scan .memobank/ for secrets
memo scan --fix        # Auto-redact and re-stage
```

### Review
```bash
memo review --due      # Memories flagged for review
memo map               # Memory summary
```
