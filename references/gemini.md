# memobank — Gemini CLI Setup

## How it works

Gemini CLI reads `~/.gemini/GEMINI.md` as its system prompt file. The memobank adapter appends an instruction to run `memo capture --auto ` at the end of each session.

## Installation

### Option A: Interactive (recommended)

```bash
memo init
```

Select "Gemini CLI" in the platform multi-select step (auto-detected if `~/.gemini/` exists or `gemini` is in PATH).

### Option B: Platform-only

```bash
memo install --platform gemini
```

Appends the memobank protocol to `~/.gemini/GEMINI.md`.

## Memory retrieval

Gemini does not have a native hook for pre-session recall. Run manually at session start:

```bash
memo recall "<current task>"
```

Or ask Gemini at the start of your session: "Read my project memory for: [task description]"

## Session end

The instruction appended to `GEMINI.md` asks Gemini to run:

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

Gemini CLI is detected when:
- `~/.gemini/` directory exists
- OR `gemini` binary is in PATH

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — Operation without CLI
