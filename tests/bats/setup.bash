#!/usr/bin/env bashio
# TASK-TEST-006: BATS test suite setup for HA Claude Addon
# Initializes mock environment and helpers for testing addon scripts

setup() {
    # Create temporary directories for test data
    SETUP_TMPDIR=$(mktemp -d)
    export DATA_DIR="${SETUP_TMPDIR}/data"
    export ROOTFS_DIR="${SETUP_TMPDIR}/rootfs"
    
    mkdir -p "${DATA_DIR}"
    mkdir -p "${ROOTFS_DIR}/etc/cont-init.d/"
    mkdir -p "${ROOTFS_DIR}/usr/bin/"
    mkdir -p "${ROOTFS_DIR}/s6-overlay/s6-rc.d/claude-ttyd/"
}

teardown() {
    # Clean up temporary directory
    rm -rf "${SETUP_TMPDIR}"
}

# Mock bashio functions for testing
bashio::log_info() { echo "[INFO] $*"; }
bashio::log_warning() { echo "[WARNING] $*"; }
bashio::log_error() { echo "[ERROR] $*"; }
bashio::config() { echo "$1"; }
bashio::services_exists() { return 0; }

# Mock environment variables for tests
export SUPERVISOR_TOKEN="test-token-123"
export HOME="/root"

# Helper function to run addon scripts in test context
run_test_script() {
    local script_path="$1"
    local test_name="${TEST_DESCRIPTION:-unknown}"
    
    bashio::log_info "Running test: ${test_name} on ${script_path}"
    
    # Copy the actual script content to test location and run it
    cp "${script_path}" "${ROOTFS_DIR}/$(basename "${script_path}")" 2>/dev/null || true
    
    # Execute with mocked dependencies
    bash -x "${ROOTFS_DIR}/$(basename "${script_path}")" 2>&1 | tee "${SETUP_TMPDIR}/test-output.txt"
}

# Helper function to assert file exists
assert_file_exists() {
    local expected_path="$1"
    if [[ ! -f "$expected_path" ]]; then
        echo "FAIL: Expected file not found: ${expected_path}" >&2
        return 1
    fi
    bashio::log_info "PASS: File exists: ${expected_path}"
}

# Helper function to assert command output contains string
assert_output_contains() {
    local expected_string="$1"
    local actual_output_file="$2"
    
    if ! grep -q "${expected_string}" "${actual_output_file}"; then
        echo "FAIL: Output does not contain '${expected_string}'" >&2
        return 1
    fi
    bashio::log_info "PASS: Found expected output in file"
}

# Helper function to assert JSON validity
assert_json_valid() {
    local json_file="$1"
    
    if ! jq . "${json_file}" >/dev/null 2>&1; then
        echo "FAIL: Invalid JSON format in ${json_file}" >&2
        return 1
    fi
    bashio::log_info "PASS: Valid JSON file: ${json_file}"
}

# Helper function to assert symlink exists
assert_symlink_exists() {
    local link_path="$1"
    
    if [[ ! -L "$link_path" ]]; then
        echo "FAIL: Symlink not found: ${link_path}" >&2
        return 1
    fi
    bashio::log_info "PASS: Symlink exists: ${link_path}"
}

# Helper function to assert shell syntax is valid
assert_syntax_valid() {
    local script_file="$1"
    
    if ! bash -n "${script_file}"; then
        echo "FAIL: Syntax errors in ${script_file}" >&2
        return 1
    fi
    bashio::log_info "PASS: Valid syntax in file: ${script_file}"
}

# Export all helper functions for use in test files
export -f run_test_script
export -f assert_file_exists
export -f assert_output_contains
export -f assert_json_valid
export -f assert_symlink_exists
export -f assert_syntax_valid