# memobank — Claude Code Setup

## How it works

1. **Dynamic recall** (`!` injection): when you invoke `/memobank <task>`,
   `memo recall` runs *before* Claude reads the prompt. Top-N memories
   are injected as context. Zero MCP overhead.

2. **Auto-capture** (`hooks.Stop`): when Claude finishes responding,
   `memo capture --auto` runs silently. Any significant learnings from
   Claude's auto-memory writes are extracted and stored as structured memories.

3. **Auto-memory integration**: set `autoMemoryDirectory` in
   `~/.claude/settings.json` to point to your memobank repo's `memory/`
   directory. Claude's native auto-memory writes go there, and
   `memo capture` picks them up.

## Installation

### Option A: Manual

```bash
mkdir -p ~/.claude/skills/memobank
cp SKILL.md ~/.claude/skills/memobank/SKILL.md
cp -r references/ ~/.claude/skills/memobank/references/
```

### Option B: One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/org/memobank-skill/main/install.sh | bash --claude-code
```

or

```bash
bash install.sh --claude-code
```

## Configure autoMemoryDirectory (recommended)

### Option A: Automatic

```bash
memo install --claude-code
# This sets autoMemoryDirectory in ~/.claude/settings.json
```

### Option B: Manual

Add to `~/.claude/settings.json`:

```json
{
  "autoMemoryDirectory": "~/.memobank/<project>/memory/"
}
```

Replace `<project>` with your git repo name (e.g., `my-webapp`).

## Usage

### Manual invocation

```text
/memobank deploy the new feature
/memobank debug the Redis connection issue
/memobank refactor the auth module
```

### Automatic invocation

Claude will invoke the skill automatically when you start a coding task. The memory context appears in the prompt before Claude responds.

## How auto-recall works

When you run `/memobank <task>`:

1. The `!`command in SKILL.md runs immediately (before Claude sees your prompt)
2. `memo recall "<task>"` retrieves matching memories
3. The memories are inlined into the skill content
4. Claude reads them as context, then responds to your request

## How auto-capture works

When Claude finishes a session:

1. The `hooks.Stop` hook fires
2. `memo capture --auto` runs silently
3. It reads recently written auto-memory files
4. Extracts structured memories from them
5. Stores them as `lesson`, `decision`, `workflow`, or `architecture` files

The `|| true` ensures the hook never fails or blocks the session.

## Troubleshooting

### `/memobank` command not found

Restart Claude Code. Skill files are loaded at startup.

### Memory context not appearing

Check that `memo recall` works in your terminal:
```bash
memo recall "test"
```

If memo is not installed, you'll see the fallback message: "(no memory configured — run: memo install)"

### Auto-capture not working

Check that the hook is in `~/.claude/skills/memobank/SKILL.md`:
```yaml
hooks:
  Stop:
    - command: "memo capture --auto 2>/dev/null || true"
```

## See also

- [references/memory-protocol.md](memory-protocol.md) — Complete memory protocol
- [references/fallback.md](fallback.md) — How to use without CLI
