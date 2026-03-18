# memobank — Memory Protocol

The canonical memory protocol for all coding agents (Claude Code, Codex, Cursor). Defines when and how to use project memory.

---

## When to Recall

**At session start** — Before starting any work, recall relevant memories:

```bash
memo recall "<current task>"
```

Example: `memo recall "debug the Redis connection issue"`

This retrieves top-N memories matching your current task context.

---

## When to Write

Capture immediately when you:

- **Fix a non-obvious bug** — Something that took time to figure out
- **Make an architectural decision** — Why you chose X over Y
- **Discover a repeatable workflow** — Step-by-step process worth reusing
- **Find a pattern worth remembering** — Code structure, API pattern, etc.

If it would save a future developer time, write it down.

---

## Memory Types and When to Use Each

### `lesson`

When something went wrong and the fix wasn't obvious.

**Example:**
```bash
memo write lesson \
  --name="Redis pool exhaustion" \
  --description="Use connection pooling with max=10" \
  --tags="redis,reliability" \
  --content="Production was hitting timeout errors. Root cause: too many open connections. Added pooling with max=10 and explicit close() in finally blocks."
```

### `decision`

Why you chose one approach over another.

**Example:**
```bash
memo write decision \
  --name="Blue-green deploy" \
  --description="Avoids downtime during deploy" \
  --tags="deploy,infrastructure" \
  --content="Chose blue-green over rolling update. Requires load balancer config but eliminates deploy-time downtime. Trade-off: slower rollback."
```

### `workflow`

A repeatable step-by-step process.

**Example:**
```bash
memo write workflow \
  --name="Local testing with mocked APIs" \
  --description="Run integration tests without external deps" \
  --tags="testing,devops" \
  --content="1. Start mock server on localhost:9999. 2. Set MOCK_API_URL env var. 3. Run pytest. 4. Verify in mock logs."
```

### `architecture`

How the system is structured.

**Example:**
```bash
memo write architecture \
  --name="Event-driven async pipeline" \
  --description="Decoupled data flow via message queue" \
  --tags="architecture,async" \
  --content="Producers emit events to Kafka. Workers consume and process. Results written to ClickHouse. Enables scaling and backpressure handling."
```

---

## Sanitization Rules

**Never include:**
- API keys, passwords, tokens
- IP addresses, URLs of internal systems
- PII (personally identifiable information)
- Secret URLs, endpoints with sensitive data

**Always include:**
- What went wrong (the problem)
- Why it happened (the root cause)
- How to fix it (the solution)
- Context (what we were trying to do)

---

## Quality Bar

If it would save a future developer time → write it.
If it's obvious or trivial → skip it.

Avoid memory clutter. Write only what you'd want to find six months from now.

---

## Command Reference

### Recall
```bash
memo recall "query"                    # Retrieve top-N memories
memo recall "query" --limit=10         # Get more results
memo recall "query" --type=lesson      # Filter by type
```

### Write
```bash
memo write <type> \
  --name="short title" \
  --description="one-line summary" \
  --tags="tag1,tag2" \
  --content="detailed explanation..."
```

### Search
```bash
memo search "query"                    # Keyword search
memo search "query" --engine=lancedb   # Vector search
memo search "query" --tag=redis        # Filter by tag
memo search "query" --type=decision    # Filter by type
```

### Review
```bash
memo review --due                      # Show memories flagged for review
memo review --id <memory-id>           # Review specific memory
```

### Map
```bash
memo map                               # Visualize memory clusters
```

---

## Summary

- **Recall** at session start: `memo recall "<task>"`
- **Write** when you learn something: `memo write <type> ...`
- **Search** to find context: `memo search "query"`
- **Review** periodically: `memo review --due`
- **Capture learnings** — structured memory saves time
