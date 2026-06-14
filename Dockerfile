FROM ghcr.io/hassio-addons/base:15.0.1

# Build argument for architecture mapping (amd64/aarch64)
ARG BUILD_ARCH=amd64

# Install system dependencies from Alpine repository
RUN apk add --no-cache nodejs npm git curl bash tmux jq

# Download ttyd static binary with architecture-specific URL
RUN case "$BUILD_ARCH" in \
      amd64)   ARCH="x86_64" ;; \
      aarch64) ARCH="aarch64" ;; \
      *)       echo "Unsupported arch: $BUILD_ARCH" >&2; exit 1 ;; \
    esac && \
    curl -L "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${ARCH}" \
        -o /usr/bin/ttyd && chmod +x /usr/bin/ttyd

# Install Claude Code CLI globally via npm
RUN npm install -g @anthropic-ai/claude-code

# Install hass-mcp package globally for MCP server support
RUN npm install -g hass-mcp 2>/dev/null || echo "hass-mcp installation failed, continuing without MCP"

# Copy addon root filesystem
COPY rootfs /

# Make start script executable
RUN chmod +x /usr/bin/start-claude.sh