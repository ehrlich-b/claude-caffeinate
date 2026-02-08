# claude-caffeinate

Keeps your Mac awake during Claude Code sessions using `caffeinate`. Runs as a Claude Code hook — no background daemons, no manual intervention.

## How it works

When a Claude Code session starts, a `caffeinate -i -w <claude_pid>` process is spawned. The `-w` flag ties caffeinate's lifetime to the Claude process — if Claude crashes, caffeinate exits automatically. Multiple sessions each get their own caffeinate process; macOS stays awake until all sessions end.

## Prerequisites

- macOS (silently no-ops on other platforms)
- `~/.local/bin` in your `PATH`

## Install

```bash
cd claude-caffeinate
bash install.sh
```

This will:
1. Copy `claude-caffeinate` to `~/.local/bin/`
2. Add `SessionStart` and `SessionEnd` hooks to `~/.claude/settings.json` (backs up existing file first)

## Verify

```bash
# No sessions yet
claude-caffeinate status

# Start a Claude Code session, then in another terminal:
claude-caffeinate status
pmset -g assertions | grep caffeinate
```

## Uninstall

```bash
rm ~/.local/bin/claude-caffeinate
rm -rf /tmp/claude-caffeinate
```

Then remove the `SessionStart` and `SessionEnd` hook entries containing `claude-caffeinate` from `~/.claude/settings.json`.
