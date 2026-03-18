## Memory Protocol (memobank)

You have access to project memory. Use it every session.

**Session start:** Read `~/.memobank/<project>/memory/MEMORY.md` before starting work.
Replace `<project>` with the current git repo name.

Or run: `memo recall "<current task>"`

**During session:** When you learn something significant, write it:
```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

Types: `lesson` | `decision` | `workflow` | `architecture`

**Examples:**
```bash
# When fixing a bug:
memo write lesson --name="Redis pool exhaustion" --description="Use connection pooling with max=10" --tags="redis,reliability"

# When making a decision:
memo write decision --name="Blue-green deploy" --description="Avoids downtime during deploy" --tags="deploy,infrastructure"

# When discovering a workflow:
memo write workflow --name="Local testing with mocked APIs" --description="Run integration tests without external deps" --tags="testing,devops"
```

**Session end:** Run `memo capture --auto` to extract and store learnings from auto-memory files.

**Search:** `memo search "query"` to find specific memories.
```bash
memo search "redis"                      # keyword search
memo search "redis" --engine=lancedb     # vector search
memo search "redis" --tag=error           # filter by tag
memo search "redis" --type=lesson         # filter by type
```

**If memobank-cli is not installed:**
Manually edit `~/.memobank/<project>/memory/MEMORY.md` with this format:
```markdown
## [lesson] Title (date)
**Tags:** tag1,tag2

Description

## [decision] Title (date)
**Tags:** tag1,tag2

Description
```

Run `npm install -g memobank-cli && memo install` for full features (vector search, auto-capture, structured files).
