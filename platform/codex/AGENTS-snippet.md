## Memory Protocol (memobank)

You have access to project memory. Use it every session.

**Session start:** Recall relevant memories before starting work:
```bash
memo recall "<current task description>"
```

Or read `~/.memobank/<project>/memory/MEMORY.md` directly (replace `<project>` with the git repo name).

**During session:** When you learn something significant, write it:
```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

Types: `lesson` | `decision` | `workflow` | `architecture`

**Examples:**
```bash
# When fixing a bug:
memo write lesson --name="Redis pool exhaustion" --description="Use connection pooling with max=10" --tags="redis,reliability" --content="..."

# When making a decision:
memo write decision --name="Blue-green deploy" --description="Avoids downtime during deploy" --tags="deploy,infrastructure" --content="..."

# When discovering a workflow:
memo write workflow --name="Local testing with mocked APIs" --description="Run integration tests without external deps" --tags="testing,devops" --content="..."
```

**Session end:** Run `memo capture --auto --silent` to extract and store learnings.

**Search:** `memo recall "query"` to retrieve relevant memories (also updates MEMORY.md).
```bash
memo recall "redis"                          # keyword search + write MEMORY.md
memo recall "redis" --scope team             # team memories only
memo recall "redis" --explain                # show score breakdown
memo search "redis" --engine=lancedb         # vector search (debug, no MEMORY.md update)
```

**Team memory:**
```bash
memo team sync                               # pull + push shared memories
memo team publish <file>                     # promote personal → team
```

**If memobank-cli is not installed:**
Manually edit `~/.memobank/<project>/memory/MEMORY.md`:
```markdown
## [lesson] Title (date)
**Tags:** tag1,tag2

Description

## [decision] Title (date)
**Tags:** tag1,tag2

Description
```

Run `npm install -g memobank-cli && memo init` for full features.
