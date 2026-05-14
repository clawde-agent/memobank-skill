# Installing memobank for OpenCode

## Prerequisites

- [OpenCode](https://opencode.ai) installed

## Installation

Add memobank to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["memobank@git+https://github.com/clawde-agent/memobank-skill.git"]
}
```

Restart OpenCode. Verify by asking: "What memory tools do you have available?"

## Manual setup (alternative)

If you prefer not to use the plugin system, append the memory protocol to your OpenCode system prompt:

1. Run `memo recall "<current task>"` at the start of each session
2. Run `memo capture --auto` at the end of each session
3. Read `.memobank/MEMORY.md` in your project root for context

## Usage

At session start, recall relevant memories:

```
memo recall "<current task description>"
```

Write memories when you learn something significant:

```
memo write lesson --name="..." --description="..." --tags="..." --content="..."
memo write decision --name="..." --description="..." --tags="..." --content="..."
```

At session end, capture learnings:

```
memo capture --auto
```

## First-time setup

```bash
npm install -g memobank-cli
memo init
```

## See also

- [README.md](../README.md) — Full documentation
- [references/memory-protocol.md](../references/memory-protocol.md) — Memory protocol reference
