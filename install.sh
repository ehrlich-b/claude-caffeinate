#!/usr/bin/env bash
# Install claude-caffeinate: copy script + merge hooks into Claude settings.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
SETTINGS_FILE="$HOME/.claude/settings.json"

# --- Install script ---
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/claude-caffeinate" "$INSTALL_DIR/claude-caffeinate"
chmod +x "$INSTALL_DIR/claude-caffeinate"
echo "Installed claude-caffeinate to $INSTALL_DIR/claude-caffeinate"

# Check PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "WARNING: $INSTALL_DIR is not in your PATH."
    echo "Add this to your shell profile:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
fi

# --- Merge hooks into settings.json ---
mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
    echo "Backed up $SETTINGS_FILE to $SETTINGS_FILE.bak"
fi

python3 -c "
import json, sys, os

settings_file = os.path.expanduser('$SETTINGS_FILE')

if os.path.exists(settings_file):
    with open(settings_file) as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.setdefault('hooks', {})

new_hooks = {
    'SessionStart': [{'hooks': [{'type': 'command', 'command': 'claude-caffeinate acquire'}]}],
    'SessionEnd':   [{'hooks': [{'type': 'command', 'command': 'claude-caffeinate release'}]}],
}

for event, matchers in new_hooks.items():
    existing = hooks.get(event, [])
    # Check if already installed
    already = False
    for matcher in existing:
        for h in matcher.get('hooks', []):
            if 'claude-caffeinate' in h.get('command', ''):
                already = True
                break
    if already:
        print(f'  {event}: already configured, skipping.')
        continue
    hooks[event] = existing + matchers
    print(f'  {event}: hook added.')

settings['hooks'] = hooks

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"

echo ""
echo "Done. Verify with: claude-caffeinate status"
