#!/usr/bin/with-contenv bashio

AUTO_START=$(bashio::config 'auto_start_claude')

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       Claude Code — Home Assistant   ║"
echo "╚══════════════════════════════════════╝"
echo ""

if ! command -v claude &>/dev/null; then
    echo "ERROR: 'claude' not found in PATH"
    exec bash -l
fi

if [ ! -f "/root/.claude/auth.json" ] && [ ! -f "/root/.claude/.credentials.json" ]; then
    echo "Not authenticated. Run: claude login"
    echo ""
fi

if [ "${AUTO_START}" = "true" ]; then
    exec env TERM=xterm-256color claude
else
    echo "Type 'claude' to start a session."
    exec bash -l
fi
