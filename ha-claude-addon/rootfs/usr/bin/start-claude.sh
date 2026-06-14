#!/usr/bin/with-contenv bashio

TMUX_ENABLED=$(bashio::config 'tmux_enabled')
AUTO_START=$(bashio::config 'auto_start_claude')
SESSION="claude-code"

if [ "${TMUX_ENABLED}" = "true" ]; then
    # Attach to existing session or create new one
    if tmux has-session -t "${SESSION}" 2>/dev/null; then
        exec tmux attach-session -t "${SESSION}"
    else
        # Create session running the inner script
        exec tmux new-session -s "${SESSION}" "/usr/bin/start-claude-inner.sh"
    fi
else
    exec /usr/bin/start-claude-inner.sh
fi
