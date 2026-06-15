#!/usr/bin/with-contenv bashio

TMUX_ENABLED=$(bashio::config 'tmux_enabled')
SCROLLBACK_LINES=$(bashio::config 'scrollback_lines')
SESSION="claude-code"

if [ "${TMUX_ENABLED}" = "true" ]; then
    if tmux has-session -t "${SESSION}" 2>/dev/null; then
        exec tmux attach-session -t "${SESSION}"
    else
        exec tmux new-session -s "${SESSION}" \
            -x 220 -y 50 \
            "tmux set-option -g history-limit ${SCROLLBACK_LINES:-5000}; /usr/bin/start-claude-inner.sh"
    fi
else
    exec /usr/bin/start-claude-inner.sh
fi
