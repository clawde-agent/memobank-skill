## Memory Protocol (memobank)

You have access to project memory. Use it every session.

**Session start:** Recall relevant memories before starting work:
```bash
memo recall "<current task description>"
```

Or read `.memobank/MEMORY.md` directly in your project root.

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

**Session end:** Run `memo capture --auto` to extract and store learnings.

**Search:** `memo recall "query"` to retrieve relevant memories (also updates MEMORY.md).
```bash
memo recall "redis"                          # keyword search + write MEMORY.md
memo recall "redis" --scope project          # project (team) memories only
memo recall "redis" --scope personal         # personal memories only
memo recall "redis" --explain                # show score breakdown
memo search "redis" --engine=lancedb         # vector search (debug, no MEMORY.md update)
```

**Workspace memory:**
```bash
memo workspace sync                          # pull + push shared org memories
memo workspace publish <file>                # promote project → workspace
```

**If memobank-cli is not installed:**
Manually edit `.memobank/MEMORY.md` in your project:
```markdown
## [lesson] Title (date)
**Tags:** tag1,tag2

Description

## [decision] Title (date)
**Tags:** tag1,tag2

Description
```

Run `npm install -g memobank-cli && memo onboarding` for full features.
