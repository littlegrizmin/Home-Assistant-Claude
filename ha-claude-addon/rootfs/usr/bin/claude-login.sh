#!/bin/bash
# Wrapper around 'claude login' that renders the OAuth URL as a clickable OSC 8 hyperlink.
# xterm.js (used by ttyd) supports OSC 8 — the full URL is embedded in the escape sequence
# so it is clickable as one link regardless of how long it is.

osc8_link() {
    local url="$1"
    local text="$2"
    # OSC 8 hyperlink: \e]8;;URL\e\\ TEXT \e]8;;\e\\
    printf '\e]8;;%s\e\\%s\e]8;;\e\\' "$url" "$text"
}

echo ""
echo "Starting Claude login..."
echo ""

# Run claude login, capture output line by line
claude login 2>&1 | while IFS= read -r line; do
    # Detect the OAuth URL
    if [[ "$line" =~ https://claude\.com/cai/oauth ]]; then
        URL=$(echo "$line" | grep -oE 'https://[^ ]+')
        if [ -n "$URL" ]; then
            echo ""
            echo "  Open this link in your browser to authenticate:"
            echo ""
            printf "  "
            osc8_link "$URL" "→  Click here to sign in to Claude  ←"
            echo ""
            echo ""
            echo "  (If click doesn't work, press 'c' and paste the URL manually)"
            echo ""
        fi
    else
        echo "$line"
    fi
done
