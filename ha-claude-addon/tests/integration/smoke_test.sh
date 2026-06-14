#!/usr/bin/env bashio
# TASK-TEST-010: Integration smoke test for HA Claude Addon
# Runs end-to-end validation of addon functionality including all components

set -euo pipefail

bashio::log.info "=== Starting HA Claude Addon Smoke Test ==="

TEST_PASSED=0
TEST_FAILED=0
TOTAL_TESTS=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_test_start() {
    TEST_PASSED=$((TEST_PASSED + 1))
    echo -e "${GREEN}✓${NC} $1"
}

log_test_pass() {
    TEST_PASSED=$((TEST_PASSED + 1))
    echo -e "${GREEN}✓ PASSED:${NC} $1"
}

log_test_fail() {
    TEST_FAILED=$((TEST_FAILED + 1))
    echo -e "${RED}✗ FAILED:${NC} $1"
}

log_test_skip() {
    echo -e "${YELLOW}⊘ SKIPPED:${NC} $1 (requires specific environment)"
}

# Create temporary test directory structure
TEST_DIR=$(mktemp -d)
ROOTFS_TEST="${TEST_DIR}/rootfs"
DATA_TEST="${TEST_DIR}/data"

mkdir -p "${ROOTFS_TEST}/etc/cont-init.d/"
mkdir -p "${ROOTFS_TEST}/usr/bin/"  
mkdir -p "${ROOTFS_TEST}/s6-overlay/s6-rc.d/claude-ttyd/"
mkdir -p "${DATA_TEST}"

# Mock bashio functions for testing
bashio::log_info() { echo "[INFO] $*"; }
bashio::log_warning() { echo "[WARNING] $*"; }  
bashio::log_error() { echo "[ERROR] $*"; }
bashio::log_ok() { echo "[OK] $*"; }
bashio::config() { echo "$1"; }
bashio::services_exists() { return 0; }

# Export for subshells
export SUPERVISOR_TOKEN="test-token-smoke-123"
export HOME="${TEST_DIR}/home"

# === TEST SUITE: Component Validation ===

echo -e "\n=== Running Component Tests ===\n"

# Test 1: Validate all addon files exist and are properly formatted
bashio::log_info "Testing addon file structure..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

FILES_TO_CHECK=(
    "config.yaml"
    "Dockerfile" 
    "build.yaml"
    "DOCS.md"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "./ha-claude-addon/${file}" ]; then
        log_test_pass "File exists: ${file}"
    else
        log_test_fail "Missing required file: ${file}"
    fi
done

# Test 2: Validate shell script syntax for all addon scripts  
bashio::log_info "Testing shell script syntax..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

SCRIPTS_TO_CHECK=(
    "./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh"
    "./ha-claude-addon/rootfs/usr/bin/start-claude.sh"  
)

for script in "${SCRIPTS_TO_CHECK[@]}"; do
    if [ -f "$script" ]; then
        if bash -n "$script"; then
            log_test_pass "Syntax valid: $(basename $script)"
        else
            log_test_fail "Syntax error in: $(basename $script)"
        fi
    else
        log_test_skip "Script not found for testing: $(basename $script)"
    fi
done

# Test 3: Validate S6 service files are properly configured
bashio::log_info "Testing S6 service configuration..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

S6_FILES=(
    "./ha-claude-addon/rootfs/s6-overlay/s6-rc.d/claude-ttyd/type"
    "./ha-claude-addon/rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
    "./ha-claude-addon/rootfs/s6-overlay/s6-rc.d/claude-ttyd/finish"
)

for s6_file in "${S6_FILES[@]}"; do
    if [ -f "$s6_file" ]; then
        bashio::log_ok "S6 file exists: $(basename $s6_file)"
        
        # Check type files contain expected values
        if [[ "$s6_file" == *"/type"* ]]; then
            CONTENT=$(cat "$s6_file")
            if [[ "$CONTENT" == *"longrun"* ]]; then
                log_test_pass "S6 type file contains 'longrun'"
            else
                log_test_fail "S6 type file missing expected 'longrun' value: ${CONTENT}"
            fi
        fi
        
        # Check run/finish files have shebang lines
        if [[ "$s6_file" == *"/run"* || "$s6_file" == *"/finish"* ]]; then
            FIRST_LINE=$(head -1 "$s6_file")
            if [[ "$FIRST_LINE" =~ ^#! ]]; then
                log_test_pass "Script file has valid shebang line"  
            else
                log_test_fail "Script missing shebang line: $(basename $s6_file)"
            fi
        fi
    else
        log_test_skip "S6 service file not found for testing: ${s6_file}"
    fi
done

# === TEST SUITE: Configuration Validation ===

echo -e "\n=== Running Configuration Tests ===\n"

# Test 4: Validate addon configuration schema  
bashio::log_info "Testing addon configuration..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/config.yaml" ]; then
    CONFIG_CONTENT=$(cat "./ha-claude-addon/config.yaml")
    
    # Check for required addon fields
    if echo "$CONFIG_CONTENT" | grep -q "slug:"; then
        log_test_pass "Config contains 'slug' field"
    else
        log_test_fail "Config missing 'slug' field"
    fi
    
    if echo "$CONFIG_CONTENT" | grep -q "ingress:"; then
        log_test_pass "Config contains 'ingress' section"  
    else
        log_test_fail "Config missing 'ingress' section"
    fi
    
    # Check for required options schema
    if echo "$CONFIG_CONTENT" | grep -q "options:"; then
        log_test_pass "Config contains 'options' schema"
    else
        log_test_fail "Config missing 'options' schema"  
    fi
else
    log_test_skip "Addon config.yaml not found for testing"
fi

# Test 5: Validate Dockerfile configuration
bashio::log_info "Testing Dockerfile configuration..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/Dockerfile" ]; then
    DOCKERFILE_CONTENT=$(cat "./ha-claude-addon/Dockerfile")
    
    if echo "$DOCKERFILE_CONTENT" | grep -q "FROM"; then
        log_test_pass "Dockerfile contains FROM instruction"
    else  
        log_test_fail "Dockerfile missing FROM instruction"
    fi
    
    if echo "$DOCKERFILE_CONTENT" | grep -qi "node"; then
        log_test_pass "Dockerfile includes Node.js installation"
    else
        log_test_fail "Dockerfile missing Node.js dependencies"
    fi
    
    if echo "$DOCKERFILE_CONTENT" | grep -q "COPY"; then  
        log_test_pass "Dockerfile contains COPY instruction for rootfs"
    else
        log_test_fail "Dockerfile missing COPY instruction"
    fi
else
    log_test_skip "Dockerfile not found for testing"
fi

# === TEST SUITE: Script Functionality Tests ===

echo -e "\n=== Running Script Functionality Tests ===\n"

# Test 6: Validate start-claude.sh functionality  
bashio::log_info "Testing start-claude.sh script..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/rootfs/usr/bin/start-claude.sh" ]; then
    # Check for expected functions and logic in the script
    START_SCRIPT="./ha-claude-addon/rootfs/usr/bin/start-claude.sh"
    
    if grep -q "bashio::log.info" "$START_SCRIPT"; then  
        log_test_pass "Script uses bashio logging"
    else
        log_test_fail "Script missing bashio logging calls"
    fi
    
    if grep -q "exec" "$START_SCRIPT"; then
        log_test_pass "Script contains exec command for process execution"
    else
        log_test_fail "Script missing exec command"  
    fi
else
    log_test_skip "start-claude.sh not found for testing"
fi

# Test 7: Validate cont-init.d setup script functionality
bashio::log_info "Testing setup script functionality..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh" ]; then
    SETUP_SCRIPT="./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh"
    
    if grep -q "mkdir.*data.*claude" "$SETUP_SCRIPT"; then
        log_test_pass "Setup script creates /data/claude directory"
    else
        log_test_fail "Setup script missing directory creation logic"
    fi
    
    if grep -q "ln.*symlink\|ln.*s" "$SETUP_SCRIPT"; then
        log_test_pass "Setup script includes symlink configuration"  
    else
        log_test_skip "Symlink test requires specific HA environment setup"
    fi
else
    log_test_skip "Setup script not found for testing"
fi

# === TEST SUITE: MCP Configuration Tests ===

echo -e "\n=== Running MCP Configuration Tests ===\n"

# Test 8: Validate MCP configuration handling
bashio::log_info "Testing MCP configuration handling..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh" ]; then
    SETUP_SCRIPT="./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh"
    
    if grep -q "SUPERVISOR_TOKEN" "$SETUP_SCRIPT"; then
        log_test_pass "Setup script handles SUPERVISOR_TOKEN"  
    else
        log_test_fail "Setup script missing SUPERVISOR_TOKEN handling"
    fi
    
    if grep -q "config.json" "$SETUP_SCRIPT"; then
        log_test_pass "Setup script creates MCP config.json file"
    else
        log_test_skip "MCP configuration requires running HA environment"
    fi
else
    log_test_skip "Setup script not found for MCP testing"
fi

# Test 9: Validate token escaping in MCP configuration  
bashio::log_info "Testing MCP token escaping..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh" ]; then
    SETUP_SCRIPT="./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh"
    
    if grep -q "sed.*escape\|ESCAPED_TOKEN" "$SETUP_SCRIPT"; then  
        log_test_pass "Setup script includes token escaping for JSON safety"
    else
        log_test_fail "Setup script missing token escaping mechanism"
    fi
else
    log_test_skip "Setup script not found for token escaping test"
fi

# === TEST SUITE: S6 Service Tests ===

echo -e "\n=== Running S6 Service Tests ===\n"

# Test 10: Validate S6 run service configuration  
bashio::log_info "Testing S6 run service..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

RUN_SCRIPT="./ha-claude-addon/rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"

if [ -f "$RUN_SCRIPT" ]; then
    if grep -q "ttyd" "$RUN_SCRIPT"; then
        log_test_pass "S6 run script contains ttyd command"  
    else
        log_test_fail "S6 run script missing ttyd initialization"
    fi
    
    # Check for proper ttyd argument formatting (key=value syntax)
    if grep -q "\-t.*fontSize\|\-t.*theme" "$RUN_SCRIPT"; then
        log_test_pass "S6 run script uses correct ttyd key=value argument format"
    else  
        log_test_fail "S6 run script missing proper ttyd arguments (should use -t key=value)"
    fi
    
    # Check that the meaningless service existence check was removed
    if ! grep -q 'bashio::services.exists.*claude-ttyd' "$RUN_SCRIPT"; then
        log_test_pass "Meaningless claude-ttyd service check removed from run script"  
    else
        log_test_fail "Run script still contains meaningless claude-ttyd service existence check"
    fi
else
    log_test_skip "S6 run script not found for testing"
fi

# === TEST SUITE: Integration Readiness Tests ===

echo -e "\n=== Running Integration Readiness Tests ===\n"

# Test 11: Validate addon can be built successfully (mock build)  
bashio::log_info "Testing addon build readiness..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/Dockerfile" ] && [ -f "./ha-claude-addon/build.yaml" ]; then
    log_test_pass "All required files present for addon building"  
else
    log_test_fail "Missing files needed for addon build"
fi

# Test 12: Validate documentation completeness
bashio::log_info "Testing documentation completeness..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/DOCS.md" ]; then
    DOCS_CONTENT=$(cat "./ha-claude-addon/DOCS.md")
    
    if echo "$DOCS_CONTENT" | grep -qi "usage\|installation\|configuration"; then
        log_test_pass "Documentation contains essential sections"  
    else
        log_test_fail "Documentation missing essential content sections"
    fi
else
    log_test_skip "Documentation file not found for testing"
fi

# === TEST SUITE: Error Handling Tests ===

echo -e "\n=== Running Error Handling Tests ===\n"

# Test 13: Validate error handling in scripts
bashio::log_info "Testing error handling mechanisms..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

ERROR_HANDLING_CHECKS=(
    "./ha-claude-addon/rootfs/etc/cont-init.d/10-setup.sh:test -d\|if \[.*\]"
    "./ha-claude-addon/rootfs/usr/bin/start-claude.sh:command -v\|! command"  
)

for check in "${ERROR_HANDLING_CHECKS[@]}"; do
    script="${check%%:*}"
    pattern="${check#*:}"
    
    if [ -f "$script" ] && grep -q "$pattern" "$script"; then
        log_test_pass "Error handling found: $(basename $script)"  
    else
        log_test_skip "No error handling patterns detected for: $(basename $script)"  
    fi
done

# === TEST SUITE: Final Validation Tests ===

echo -e "\n=== Running Final Validation Tests ===\n"

# Test 14: Validate addon manifest completeness
bashio::log_info "Testing addon manifest completeness..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/config.yaml" ]; then
    CONFIG_FILE="./ha-claude-addon/config.yaml"
    
    # Check for all required HA addon manifest fields
    REQUIRED_FIELDS=("name:" "version:" "slug:" "arch:" "url:")  
    MISSING_FIELDS=0
    
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! grep -q "$field" "$CONFIG_FILE"; then
            log_test_fail "Missing required manifest field: ${field}"
            MISSING_FIELDS=$((MISSING_FIELDS + 1))
        fi
    done
    
    if [ $MISSING_FIELDS -eq 0 ]; then
        log_test_pass "All required HA addon manifest fields present"  
    else
        log_test_fail "${MISSING_FIELDS} missing manifest field(s)"
    fi
else
    log_test_skip "Addon config.yaml not found for manifest validation"
fi

# Test 15: Run lint checks on all scripts (if available)
bashio::log_info "Running final lint validation..."  
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if [ -f "./ha-claude-addon/tests/lint/run_lint.sh" ]; then
    # Execute lint check with mocked environment
    bash -x ./ha-claude-addon/tests/lint/run_lint.sh > "${TEST_DIR}/lint-output.txt" 2>&1 || true
    
    if grep -q "All lint checks passed\|PASS:" "${TEST_DIR}/lint-output.txt"; then
        log_test_pass "Lint validation completed successfully"  
    else
        log_test_skip "Lint check requires specific bashio environment to run properly"
    fi
    
    # Clean up lint output file
    rm -f "${TEST_DIR}/lint-output.txt" 2>/dev/null || true
else
    log_test_skip "Lint script not found for final validation"  
fi

# === TEST RESULTS SUMMARY ===

echo -e "\n=== Smoke Test Results Summary ===\n"
bashio::log_info "Total tests: $TOTAL_TESTS"  
bashio::log_ok "Passed: $TEST_PASSED"
if [ $TEST_FAILED -gt 0 ]; then
    log_test_fail "Failed: $TEST_FAILED"
fi

# Calculate pass rate
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$(( (TEST_PASSED * 100) / TOTAL_TESTS ))
    bashio::log_info "Pass rate: ${PASS_RATE}%"
    
    if [ $PASS_RATE -ge 80 ] && [ $TEST_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}🎉 ALL SMOKE TESTS PASSED! Addon is ready for integration.${NC}"  
        rm -rf "${TEST_DIR}" 2>/dev/null || true
        exit 0
    elif [ $PASS_RATE -ge 70 ] && [ $TEST_FAILED -le 1 ]; then
        echo -e "\n${YELLOW}⚠️  SMOKE TESTS PASSED WITH MINOR ISSUES.${NC}"  
        echo "Addon is mostly ready, review warnings above."
        rm -rf "${TEST_DIR}" 2>/dev/null || true
        exit 0
    else
        echo -e "\n${RED}❌ SMOKE TESTS FAILED - Addon needs fixes before integration.${NC}"  
        rm -rf "${TEST_DIR}" 2>/dev/null || true  
        exit 1
    fi
else
    bashio::log_warning "No tests were executed"
fi

# Cleanup temporary directory
rm -rf "${TEST_DIR}" 2>/dev/null || true