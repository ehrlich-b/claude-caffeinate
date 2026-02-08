# claude-caffeinate

Prevents your Mac from sleeping during [Claude Code](https://docs.anthropic.com/en/docs/claude-code) sessions.

Uses [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) to automatically spawn a `caffeinate` process when a session starts and kill it when the session ends. No daemons, no cron jobs, no manual intervention.

## How it works

On `SessionStart`, the hook spawns `caffeinate -i -w <claude_pid>`. The `-w` flag ties caffeinate's lifetime to the Claude process — if Claude crashes or is killed, caffeinate exits automatically. Each session gets its own caffeinate process; macOS stays awake as long as **any** session is alive.

Stale session files are cleaned up opportunistically whenever a new session starts or ends.

## Install

```bash
git clone https://github.com/ehrlich-b/claude-caffeinate.git
cd claude-caffeinate
bash install.sh
```

This will:
1. Copy `claude-caffeinate` to `~/.local/bin/`
2. Merge `SessionStart` and `SessionEnd` hooks into `~/.claude/settings.json` (existing settings are backed up to `settings.json.bak`)

Make sure `~/.local/bin` is in your `PATH`. The installer will warn you if it isn't.

## Usage

Everything is automatic once installed. To check on things manually:

```bash
# Show active sessions
claude-caffeinate status

# Verify macOS sleep assertion is held
pmset -g assertions | grep caffeinate
```

## Requirements

- macOS (silently no-ops on other platforms)
- Python 3 (for JSON parsing from hook stdin)
- `~/.local/bin` in your `PATH`

## Uninstall

```bash
rm ~/.local/bin/claude-caffeinate
```

Then remove the `SessionStart` and `SessionEnd` hook entries containing `claude-caffeinate` from `~/.claude/settings.json`.

## License

MIT
