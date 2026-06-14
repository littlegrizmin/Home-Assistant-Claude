#!/usr/bin/with-contenv bashio

# TASK-005: Start script for HA Claude Addon with welcome message, auth check, and auto_start logic

bashio::log.info "================================"
bashio::log.info "  Welcome to HA Claude Addon!"
bashio::log.info "================================"

# Check if claude code is available on PATH
if ! command -v claude &> /dev/null; then
    bashio::log.error "ERROR: 'claude' command not found in PATH!"
    bashio::log.info "Please install claude-code package or ensure it's available"
    # Fall back to shell if claude is not available
    exec bash -l
fi

# Check authentication status for Claude CLI
bashio::log.info "Checking Claude authentication..."

if [ ! -d "/root/.claude" ]; then
    bashio::log.warning "WARNING: /root/.claude directory not found!"
    bashio::log.info "Please run 'claude login' to authenticate first"
    
    # Check if claude has any auth tokens or sessions
    if [ ! -f "/root/.claude/sessions.json" ]; then
        bashio::log.warning "No Claude sessions found. Please authenticate before continuing."
        
        # If auto_start_claude is disabled, just start shell
        AUTO_START=$(bashio::config 'auto_start_claude')
        if [ "${AUTO_START,,}" != "true" ]; then
            bashio::log.info "auto_start_claude is disabled. Starting shell session..."
            exec bash -l
        fi
        
        # If claude login is needed and auto_start is enabled, start with warning
        bashio::log.warning "Please run 'claude login' in a separate terminal to authenticate"
    else
        bashio::log.info "Claude sessions found. Attempting to continue..."
    fi
else
    bashio::log.info "Claude authentication directory exists: /root/.claude"
    
    # Check if claude can be invoked (basic auth check)
    if claude --help &> /dev/null; then
        bashio::log.info "Claude CLI is authenticated and ready to use!"
    else
        bashio::log.warning "WARNING: Claude CLI may not be properly authenticated."
        bashio::log.info "Please run 'claude login' to authenticate"
        
        # If auto_start_claude is disabled, just start shell
        AUTO_START=$(bashio::config 'auto_start_claude')
        if [ "${AUTO_START,,}" != "true" ]; then
            bashio::log.info "auto_start_claude is disabled. Starting shell session..."
            exec bash -l
        fi
    fi
fi

# Check auto_start_claude configuration option
AUTO_START=$(bashio::config 'auto_start_claude')
if [ "${AUTO_START,,}" = "true" ]; then
    bashio::log.info "Starting Claude Code session (auto_start enabled)..."
    
    # Start claude with basic terminal settings for better compatibility
    exec env TERM=xterm-256color claude 2>&1
else
    bashio::log.info "auto_start_claude is disabled. Starting shell session instead."
    bashio::log.info "You can start Claude manually by running 'claude' in the terminal."
    exec bash -l
fi
