#!/usr/bin/with-contenv bashio

# TASK-004: Setup directory structure, symlinks, and log versions for HA Claude Addon

bashio::log.info "Starting addon setup..."

# Ensure persistent storage directory exists
mkdir -p /data/claude

# Ensure /root/.claude is always a symlink to /data/claude
# If it's a real directory (e.g. from a previous bad state), migrate its contents first
if [ -d "/root/.claude" ] && [ ! -L "/root/.claude" ]; then
    bashio::log.warning "/root/.claude is a real directory, migrating contents to /data/claude..."
    cp -a /root/.claude/. /data/claude/ 2>/dev/null || true
    rm -rf /root/.claude
fi

# Remove broken symlink if present
if [ -L "/root/.claude" ] && [ ! -e "/root/.claude" ]; then
    bashio::log.warning "Removing broken symlink /root/.claude"
    rm -f /root/.claude
fi

# Create symlink if not already correct
if [ ! -L "/root/.claude" ]; then
    bashio::log.info "Creating symlink /root/.claude -> /data/claude"
    ln -s /data/claude /root/.claude
fi

# Log version information for debugging and monitoring
bashio::log.info "=== Version Information ==="
bashio::log.info "Node.js: $(node --version 2>/dev/null || echo 'not installed')"
bashio::log.info "ttyd: $(ttyd --version 2>/dev/null || echo 'not installed')"
bashio::log.info "claude-code: $(claude --version 2>/dev/null || echo 'not installed')"
bashio::log.info "=== End Version Information ==="

# Verify symlink is working correctly
if [ -L "/root/.claude" ]; then
    bashio::log.info "Symlink /root/.claude -> /data/claude verified successfully"
else
    bashio::log.warning "WARNING: Symlink /root/.claude not found or broken!"
fi

# TASK-008: MCP (Model Context Protocol) Configuration
# Check if hass-mcp is available and register the MCP server

if command -v hass-mcp >/dev/null 2>&1; then
    bashio::log.info "hass-mcp found, initializing MCP server configuration"
    
    # Ensure we have a SUPERVISOR_TOKEN for MCP registration
    if [ -z "${SUPERVISOR_TOKEN}" ]; then
        bashio::log.warning "WARNING: SUPERVISOR_TOKEN not available, MCP registration skipped"
    else
        # Create MCP configuration directory if it doesn't exist
        mkdir -p /data/.mcp
        
        # Generate MCP server configuration with Supervisor token authentication (escape special chars)
        ESCAPED_TOKEN=$(printf '%s' "${SUPERVISOR_TOKEN}" | sed 's/"/\\"/g')
        cat > /data/.mcp/config.json << EOF
        {
          "server": {
            "url": "http://localhost:7681",
            "token": "${ESCAPED_TOKEN}",
            "slug": "ha_claude"
          },
  "client": {
    "homeassistant_url": "supervisor/core/info",
    "api_base_path": "/api"
  }
}
EOF
        
        # Verify MCP configuration was created
        if [ -f "/data/.mcp/config.json" ]; then
            bashio::log.info "MCP server configuration written successfully to /data/.mcp/config.json"
            
            # Test MCP connectivity by verifying the configuration is valid JSON
            if jq . /data/.mcp/config.json >/dev/null 2>&1; then
                bashio::log.info "MCP configuration validated - JSON format is correct"
            else
                bashio::log.warning "WARNING: MCP configuration file has invalid JSON format"
            fi
            
            # Log basic MCP status information (without exposing token)
            bashio::log.info "MCP server configured for addon slug: $(jq -r '.server.slug' /data/.mcp/config.json)"
        else
            bashio::log.error "ERROR: Failed to create MCP configuration file"
        fi
    fi
else
    bashio::log.warning "WARNING: hass-mcp not found, MCP server support unavailable. Install via 'npm install -g hass-mcp'"
fi

bashio::log.info "Setup completed successfully"