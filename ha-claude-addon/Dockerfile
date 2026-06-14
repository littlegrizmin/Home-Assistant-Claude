FROM ghcr.io/hassio-addons/base:15.0.1

ARG BUILD_ARCH=amd64

RUN apk add --no-cache nodejs npm git curl bash tmux jq

RUN case "$BUILD_ARCH" in \
      amd64)   ARCH="x86_64" ;; \
      aarch64) ARCH="aarch64" ;; \
      *)       echo "Unsupported arch: $BUILD_ARCH" >&2; exit 1 ;; \
    esac && \
    curl -L "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${ARCH}" \
        -o /usr/bin/ttyd && chmod +x /usr/bin/ttyd

RUN npm install -g @anthropic-ai/claude-code

RUN npm install -g hass-mcp 2>/dev/null || echo "hass-mcp installation failed, continuing without MCP"

COPY rootfs /

RUN chmod +x /usr/bin/start-claude.sh

ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.version=${BUILD_VERSION}
