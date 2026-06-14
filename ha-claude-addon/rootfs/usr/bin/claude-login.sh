#!/bin/bash
# Wrapper around 'claude login' that renders the OAuth URL as a QR code
# so it can be scanned from a phone when clipboard is blocked by the iframe.

echo ""
echo "Starting Claude login..."
echo ""

# Run claude login, capture output line by line
claude login 2>&1 | while IFS= read -r line; do
    echo "$line"
    # Detect the OAuth URL line
    if [[ "$line" =~ https://claude\.com/cai/oauth ]]; then
        URL=$(echo "$line" | grep -oE 'https://[^ ]+')
        if [ -n "$URL" ]; then
            echo ""
            echo "━━━ Scan with your phone ━━━━━━━━━━━━━━━━━━━━━━━━━━"
            qrencode -t ANSIUTF8 "$URL"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
        fi
    fi
done
