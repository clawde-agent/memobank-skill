# memobank — Qwen Code Setup

## How it works

Qwen Code reads `~/.qwen/QWEN.md` as its system prompt file. The memobank adapter appends an instruction to run `memo capture --auto ` at the end of each session.

## Installation

### Option A: Interactive (recommended)

```bash
memo init
```

Select "Qwen Code" in the platform multi-select step (auto-detected if `~/.qwen/` exists or `qwen` is in PATH).

### Option B: Platform-only

```bash
memo install --platform qwen
```

Appends the memobank protocol to `~/.qwen/QWEN.md`.

## Memory retrieval

Qwen does not have a native hook for pre-session recall. Run manually at session start:

```bash
memo recall "<current task>"
```

Or ask Qwen at the start of your session: "Read my project memory for: [task description]"

## Session end

The instruction appended to `QWEN.md` asks Qwen to run:

```bash
memo capture --auto 
```

## Writing memories

```bash
memo write <type> --name="..." --description="..." --tags="..." --content="..."
```

## Workspace memory

```bash
memo workspace init <remote-url>
memo workspace sync
memo workspace publish <file>
```

## Detection

Qwen Code is detected when:
- `~/.qwen/` directory exists
- OR `qwen` binary is in PATH

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — Operation without CLI
