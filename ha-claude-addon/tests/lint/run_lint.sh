#!/usr/bin/env bashio
# TASK-TEST-005: Lint script for shell files in the addon
# Runs basic syntax checks on all .sh and S6 service files

set -euo pipefail

bashio::log.info "Running lint check on addon scripts..."

ERRORS=0

# Check bash syntax of all shell scripts
for file in $(find rootfs -name "*.sh" -type f); do
    bashio::log.info "Checking ${file} for syntax errors..."
    if ! bash -n "$file"; then
        bashio::log.error "FAIL: Syntax error found in ${file}"
        ERRORS=$((ERRORS + 1))
    else
        bashio::log.ok "PASS: No syntax errors in ${file}"
    fi
done

# Check S6 service files (type, run, finish) for basic issues
for file in $(find rootfs -path "*s6-rc.d/*" \( -name "run" -o -name "finish" \)); do
    bashio::log.info "Checking ${file} for shell compliance..."
    
    # Check if it has a shebang line
    first_line=$(head -1 "$file")
    if [[ ! "$first_line" =~ ^#! ]]; then
        bashio::log.error "FAIL: Missing shebang in ${file}"
        ERRORS=$((ERRORS + 1))
    else
        bashio::log.ok "PASS: Has valid shebang line in ${file}"
    fi
    
    # Check for bashio usage if applicable
    if grep -q "bashio::" "$file"; then
        if [[ ! "$first_line" =~ with-contenv ]]; then
            bashio::log.error "FAIL: File uses bashio but missing with-contenv shebang in ${file}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

if [ $ERRORS -gt 0 ]; then
    bashio::log.error "Lint check failed with $ERRORS error(s)"
    exit 1
else
    bashio::log.ok "All lint checks passed!"
fi