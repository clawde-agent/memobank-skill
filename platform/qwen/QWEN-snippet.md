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

**Session end:** Run to extract and store learnings:
```bash
memo capture --auto
```

**Search:**
```bash
memo recall "query"                          # retrieve + write MEMORY.md
memo recall "query" --scope project          # project (team) memories only
memo recall "query" --scope personal         # personal memories only
memo recall "query" --explain                # show score breakdown
```

**Workspace memory:**
```bash
memo workspace sync                          # pull + push shared org memories
memo workspace publish <file>                # promote project → workspace
```

**If memobank-cli is not installed:**
Read `.memobank/MEMORY.md` in your project root for context.
Run `npm install -g memobank-cli && memo init` for full features.
