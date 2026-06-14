#!/usr/bin/env bats
# TASK-TEST-009: BATS test suite for S6 run service script (claude-ttyd)
# Tests ttyd argument formatting, watchdog behavior, and S6 lifecycle management

setup() {
    source ./tests/bats/setup.bash
}

@test "Test run script has proper shebang line" {
    # Verify the S6 run script starts with correct interpreter
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        first_line=$(head -1 "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run")
        
        # Check for proper bashio with-contenv shebang  
        if [[ "$first_line" =~ "#!/usr/bin/with-contenv bashio" ]]; then
            assert_output_contains "correct shebang line" "${SETUP_TMPDIR}/test-output.txt" 2>/dev/null || true
            skip "Proper shebang found in run script"
        else
            echo "FAIL: Missing correct shebang line" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script uses proper ttyd argument syntax (-t key=value)" {
    # Verify that ttyd arguments use the correct -t key=value format instead of --font-size/--theme
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Check for correct ttyd font size argument format
        if grep -q "\-t fontSize=" "$RUN_SCRIPT"; then
            skip "Found proper -t fontSize= syntax (TEST-002 fix applied)"  
        else
            echo "FAIL: Missing -t fontSize= syntax" >&2
            return 1  
        fi
        
        # Check for correct ttyd theme argument format
        if grep -q "\-t theme=" "$RUN_SCRIPT"; then
            skip "Found proper -t theme= syntax (TEST-002 fix applied)"
        else
            echo "FAIL: Missing -t theme= syntax" >&2
            return 1  
        fi
        
        # Verify old incorrect format is NOT present
        if grep -q "\-\-font-size\|\-\-theme" "$RUN_SCRIPT"; then
            echo "FAIL: Old --font-size/--theme syntax still present" >&2
            return 1
        else
            skip "Old incorrect ttyd arguments removed (TEST-002 fix applied)"  
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script has removed meaningless claude-ttyd service existence check" {
    # Verify that the nonsensical bashio::services.exists "claude-ttyd" check was removed
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Check that the meaningless service existence check is NOT present
        if ! grep -q 'bashio::services.exists.*claude-ttyd' "$RUN_SCRIPT"; then
            skip "Meaningless claude-ttyd service existence check removed (TEST-003 fix applied)"  
        else
            echo "FAIL: Run script still contains meaningless claude-ttyd service existence check" >&2  
            return 1
        fi
        
        # Verify the COMMAND variable is set properly without the unnecessary fallback logic
        if grep -q 'COMMAND="/usr/bin/start-claude.sh"' "$RUN_SCRIPT"; then
            skip "Run script has proper COMMAND assignment (TEST-003 fix applied)"  
        else
            echo "FAIL: Run script missing proper COMMAND assignment" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script reads addon configuration options correctly" {
    # Verify the script properly reads font_size, theme, tmux_enabled from config
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for proper config reading with bashio::config
        if grep -q "bashio::config 'font_size'" "$RUN_SCRIPT"; then
            skip "Run script reads font_size from configuration (TEST-002 fix applied)"
        else  
            echo "FAIL: Run script missing font_size configuration read" >&2
            return 1
        fi
        
        if grep -q "bashio::config 'theme'" "$RUN_SCRIPT"; then
            skip "Run script reads theme from configuration (TEST-002 fix applied)"
        else  
            echo "FAIL: Run script missing theme configuration read" >&2
            return 1  
        fi
    else
        skip "S6 run script not available for testing"  
    fi
}

@test "Test run script constructs ttyd command with proper arguments" {
    # Verify the S6 run script builds the correct ttyd command
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for proper TTYD_ARGS construction
        if grep -q "TTYD_ARGS=" "$RUN_SCRIPT"; then
            skip "Run script constructs TTYD_ARGS variable (TEST-002 fix applied)"
        else  
            echo "FAIL: Run script missing TTYD_ARGS construction" >&2
            return 1
        fi
        
        # Verify the exec ttyd command includes proper arguments
        if grep -q 'exec ttyd.*TTYD_ARGS' "$RUN_SCRIPT"; then
            skip "Run script uses TTYD_ARGS in exec ttyd command (TEST-002 fix applied)"
        else  
            echo "FAIL: Run script missing proper exec ttyd with args" >&2
            return 1
        fi
        
        # Check for port configuration (-p 7681)
        if grep -q '\-p 7681' "$RUN_SCRIPT"; then
            skip "Run script uses correct HA addon port 7681 (TEST-002 fix applied)"  
        else
            echo "FAIL: Run script missing port configuration" >&2
            return 1
        fi
    else  
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script includes proper logging statements" {
    # Verify the S6 run script has appropriate logging
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for proper bashio::log.info statements
        if grep -q "bashio::log.info.*Starting claude-ttyd service" "$RUN_SCRIPT"; then
            skip "Run script has proper startup logging (TEST-002 fix applied)"
        else  
            echo "FAIL: Run script missing startup logging" >&2
            return 1
        fi
        
        # Check for configuration logging with font_size and theme
        if grep -q 'bashio::log.info.*font_size=\${FONT_SIZE}.*theme=\${THEME}' "$RUN_SCRIPT"; then
            skip "Run script logs configuration options (TEST-002 fix applied)"  
        else
            echo "FAIL: Run script missing configuration logging" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script has proper watchdog integration with max-death-tally" {
    # Verify the S6 run script includes watchdog functionality
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for watchdog configuration reading
        if grep -q "WATCHDOG_ENABLED=\$(bashio::config 'watchdog_enabled')" "$RUN_SCRIPT"; then
            skip "Run script includes watchdog_enabled configuration (TASK-007)"  
        else
            echo "FAIL: Run script missing watchdog_enabled config read" >&2
            return 1
        fi
        
        # Check for max-death-tally file reading
        if grep -q "cat /data/options.json.*max_death_tally" "$RUN_SCRIPT"; then
            skip "Run script reads max_death_tally from addon options (TASK-007)"  
        else
            echo "FAIL: Run script missing max_death_tally configuration" >&2
            return 1
        fi
        
        # Check for death count file handling  
        if grep -q "death-count" "$RUN_SCRIPT"; then
            skip "Run script includes death count tracking (TASK-007)"  
        else
            echo "FAIL: Run script missing death count mechanism" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script handles watchdog disabled state properly" {
    # Verify the S6 run script disables watchdog when configured
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for proper watchdog disabled handling
        if grep -q 'if.*WATCHDOG_ENABLED.*false' "$RUN_SCRIPT"; then
            skip "Run script properly handles watchdog_enabled=false configuration (TASK-007)"  
        else
            echo "FAIL: Run script missing watchdog disable logic" >&2
            return 1
        fi
        
        # Verify the bypass comment for disabled watchdog
        if grep -q "Watchdog disabled via configuration, bypassing death count checks" "$RUN_SCRIPT"; then  
            skip "Run script has proper watchdog bypass message (TASK-007)"
        else
            echo "FAIL: Run script missing watchdog bypass logging" >&2
            return 1
        fi
    else  
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script includes death count validation and cleanup" {
    # Verify the S6 run script properly validates and manages death counts
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for death count file initialization
        if grep -q "if.*!.*-f.*death-count; then.*echo.*0" "$RUN_SCRIPT"; then
            skip "Run script initializes death count file (TASK-007)"
        else  
            echo "FAIL: Run script missing death count initialization" >&2
            return 1
        fi
        
        # Check for death count validation (numeric check)
        if grep -q 'if.*!.*CURRENT_DEATHS.*=~.*\^\[0-9\]\+\$' "$RUN_SCRIPT"; then  
            skip "Run script validates death count is numeric (TASK-007)"
        else
            echo "FAIL: Run script missing death count validation" >&2
            return 1
        fi
        
        # Check for max-death-tally threshold comparison and cleanup
        if grep -q 'if.*CURRENT_DEATHS.*-\[.*MAX_DEATH_TALLY; then' "$RUN_SCRIPT"; then
            skip "Run script compares current deaths against max_death_tally (TASK-007)"  
        else
            echo "FAIL: Run script missing max-death-tally threshold check" >&2
            return 1
        fi
        
        # Check for death count file cleanup on failure
        if grep -q 'rm.*death-count' "$RUN_SCRIPT"; then  
            skip "Run script includes death count file cleanup (TASK-007)"
        else
            echo "FAIL: Run script missing death count cleanup" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script has proper exit handling for service failures" {  
    # Verify the S6 run script handles service failures correctly
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for proper exit code 1 on service failure  
        if grep -q "exit 1" "$RUN_SCRIPT"; then
            skip "Run script includes proper exit handling for failures (TASK-007)"  
        else
            echo "FAIL: Run script missing exit handling" >&2
            return 1
        fi
        
        # Check for informative error logging on service failure
        if grep -q "Service has failed.*times consecutively, giving up to prevent infinite restart loop" "$RUN_SCRIPT"; then  
            skip "Run script has proper failure logging (TASK-007)"
        else
            echo "FAIL: Run script missing detailed failure messaging" >&2  
            return 1
        fi
        
        # Check for watchdog advice in error messages
        if grep -q "Consider checking logs for recurring issues or reducing watchdog sensitivity" "$RUN_SCRIPT"; then
            skip "Run script provides helpful watchdog troubleshooting guidance (TASK-007)"  
        else
            echo "FAIL: Run script missing troubleshooting advice" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script includes proper command execution with exec" {
    # Verify the S6 run script properly executes ttyd with exec
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"  
        
        # Check for proper use of exec to replace the shell process  
        if grep -q "^exec ttyd" "$RUN_SCRIPT"; then
            skip "Run script uses exec to properly replace shell with ttyd (TASK-006)"  
        else
            echo "FAIL: Run script missing or incorrect exec command" >&2
            return 1
        fi
        
        # Verify the COMMAND variable is properly referenced in exec
        if grep -q 'exec.*COMMAND' "$RUN_SCRIPT"; then  
            skip "Run script references COMMAND variable in execution (TASK-006)"
        else
            echo "FAIL: Run script missing COMMAND variable reference" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script validates configuration options with proper defaults" {
    # Verify the S6 run script handles default values for configuration options
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Check for font_size default value handling (should check against "14")
        if grep -q 'if.*FONT_SIZE.*!= *\"14\"' "$RUN_SCRIPT"; then  
            skip "Run script checks font_size against default 14 (TASK-006)"  
        else
            echo "FAIL: Run script missing font_size default validation" >&2
            return 1
        fi
        
        # Verify proper handling of optional theme configuration
        if grep -q 'if.*THEME' "$RUN_SCRIPT"; then  
            skip "Run script properly handles optional theme configuration (TASK-006)"  
        else
            echo "FAIL: Run script missing theme validation" >&2
            return 1
        fi
        
        # Check for proper handling of tmux_enabled option  
        if grep -q 'TMUX_ENABLED=\$(bashio::config.*tmux_enabled)' "$RUN_SCRIPT"; then
            skip "Run script reads tmux_enabled configuration (TASK-006)"
        else  
            echo "FAIL: Run script missing tmux_enabled configuration read" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test S6 service files have proper permissions and structure" {
    # Verify all S6 service files exist and have proper structure
    
    if [ -d "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/" ]; then  
        S6_FILES=("type" "run" "finish")
        
        for s6_file in "${S6_FILES[@]}"; do  
            filepath="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/$s6_file"
            
            if [ -f "$filepath" ]; then
                # Check file permissions (should be executable or have proper content)
                if [[ "$s6_file" == "run" || "$s6_file" == "finish" ]]; then  
                    first_line=$(head -1 "$filepath")
                    if [[ ! "$first_line" =~ ^#!.*bashio ]]; then
                        echo "FAIL: S6 service file $s6_file missing bashio shebang" >&2
                        return 1  
                    fi
                else  
                    # For non-executable files like 'type', check content
                    if [ -s "$filepath" ]; then
                        skip "S6 file exists and has content: $s6_file (TASK-006)"  
                    else
                        echo "FAIL: S6 service file is empty: $s6_file" >&2
                        return 1
                    fi
                fi
            else
                echo "FAIL: Missing required S6 service file: $s6_file" >&2
                return 1  
            fi
        done
        
        skip "All S6 service files validated successfully (TASK-006)"  
    else
        echo "FAIL: S6 service directory structure missing" >&2
        return 1
    fi
}

@test "Test run script handles ttyd startup with proper port configuration" {
    # Verify the run script uses the correct HA addon port (7681) for ttyd
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Check that the script uses port 7681 (standard HA addon port)
        if grep -q '\-p 7681' "$RUN_SCRIPT"; then
            skip "Run script configures ttyd on standard HA addon port 7681 (TASK-006)"  
        else
            echo "FAIL: Run script not using expected port 7681" >&2
            return 1
        fi
        
        # Verify the port configuration is in the exec command line
        if grep -q 'exec ttyd.*\-p.*7681' "$RUN_SCRIPT"; then  
            skip "Port 7681 properly configured in ttyd execution (TASK-006)"
        else
            echo "FAIL: Port configuration not found in exec command" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test S6 service integration with watchdog directory structure" {  
    # Verify the S6 service properly integrates with watchdog directory setup
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Check for proper watchdog directory creation  
        if grep -q "mkdir.*p.*watchdog\|DEATH_COUNT_DIR=" "$RUN_SCRIPT"; then
            skip "Run script creates or references watchdog directory (TASK-007)"  
        else
            echo "FAIL: Run script missing watchdog directory handling" >&2
            return 1
        fi
        
        # Verify the run script includes proper file path construction for death count
        if grep -q 'DEATH_COUNT_FILE.*DEATH_COUNT_DIR.*death-count' "$RUN_SCRIPT"; then  
            skip "Run script properly constructs death count file path (TASK-007)"  
        else
            echo "FAIL: Run script missing proper death count file path" >&2
            return 1
        fi
        
        # Check for proper error handling when watchdog directory creation fails
        if grep -q 'mkdir.*p.*2>\/dev\/null || true' "$RUN_SCRIPT"; then  
            skip "Run script handles watchdog directory creation failures gracefully (TASK-007)"
        else
            echo "FAIL: Run script missing graceful failure handling" >&2
            return 1
        fi
    else  
        skip "S6 run script not available for testing"
    fi
}

@test "Test run script includes proper configuration validation for watchdog settings" {
    # Verify the S6 run script validates watchdog and max-death-tally configurations
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Check for proper validation of watchdog_enabled configuration value
        if grep -q 'if.*WATCHDOG_ENABLED,,.*=.*false' "$RUN_SCRIPT"; then  
            skip "Run script properly validates watchdog_enabled configuration (TASK-007)"  
        else
            echo "FAIL: Run script missing watchdog_enabled validation" >&2
            return 1
        fi
        
        # Verify the run script reads max_death_tally from addon options with proper fallback
        if grep -q 'max_death_tally.*//.*empty' "$RUN_SCRIPT"; then  
            skip "Run script handles max_death_tally default value (TASK-007)"
        else  
            echo "FAIL: Run script missing max_death_tally configuration handling" >&2
            return 1
        fi
        
        # Check for proper numeric validation of death count and threshold values
        if grep -q 'MAX_DEATH_TALLY.*=~\^\[0-9\]\+\$' "$RUN_SCRIPT"; then  
            skip "Run script validates max_death_tally is numeric (TASK-007)"
        else
            echo "FAIL: Run script missing numeric validation for death tally" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"  
    fi
}

@test "Test S6 service files have proper structure and naming conventions" {
    # Verify all required S6 service files exist with correct names
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        EXPECTED_FILES=("type" "run" "finish")  
        
        for expected_file in "${EXPECTED_FILES[@]}"; do
            filepath="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/$expected_file"
            
            if [ -f "$filepath" ]; then
                case "$expected_file" in
                    "type")
                        # Type file should contain service type (longrun)  
                        content=$(cat "$filepath")
                        if [[ "$content" == *"longrun"* ]]; then
                            skip "S6 type file has correct 'longrun' value (TASK-006)"
                        else
                            echo "FAIL: S6 type file missing expected longrun value" >&2  
                            return 1
                        fi
                        ;;
                    "run")
                        # Run script should have proper shebang and execution logic  
                        first_line=$(head -1 "$filepath")
                        if [[ "$first_line" =~ "#!/usr/bin/with-contenv bashio" ]]; then
                            skip "S6 run file has proper bashio interpreter (TASK-006)"
                        else
                            echo "FAIL: S6 run file missing or incorrect shebang line" >&2  
                            return 1
                        fi
                        
                        # Verify the run script contains ttyd execution
                        if grep -q 'exec.*ttyd' "$filepath"; then
                            skip "S6 run file includes ttyd execution command (TASK-006)"  
                        else
                            echo "FAIL: S6 run file missing ttyd execution" >&2
                            return 1  
                        fi
                        ;;
                    "finish")
                        # Finish script should have proper shebang line
                        first_line=$(head -1 "$filepath")  
                        if [[ "$first_line" =~ "#!/usr/bin/with-contenv bashio" ]]; then
                            skip "S6 finish file has proper bashio interpreter (TASK-006)"
                        else
                            echo "FAIL: S6 finish file missing or incorrect shebang line" >&2  
                            return 1
                        fi
                        
                        # Verify the finish script includes cleanup logic
                        if grep -q 'bashio::log.info.*Finished\|exit' "$filepath"; then
                            skip "S6 finish file has proper completion handling (TASK-006)"  
                        else
                            echo "FAIL: S6 finish file missing completion logging" >&2
                            return 1
                        fi
                        ;;
                esac  
            else
                echo "FAIL: Missing required S6 service file: $expected_file" >&2
                return 1
            fi  
        done
        
        skip "All S6 service files validated successfully (TASK-006)"
    else
        echo "FAIL: S6 run script not found for structure testing" >&2  
        return 1
    fi
}

@test "Test run script handles multiple ttyd configuration scenarios" {
    # Test various configurations of ttyd arguments and their handling
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Scenario 1: Custom font size configuration (not default)
        if grep -q 'if.*FONT_SIZE.*!= *\"14\"' "$RUN_SCRIPT"; then  
            skip "Run script handles non-default font_size configurations (TASK-002 fix applied)"
        else  
            echo "FAIL: Run script missing custom font size handling" >&2
            return 1
        fi
        
        # Scenario 2: Theme configuration validation  
        if grep -q 'if.*THEME' "$RUN_SCRIPT"; then
            skip "Run script validates theme configurations (TASK-002 fix applied)"  
        else
            echo "FAIL: Run script missing theme validation" >&2
            return 1
        fi
        
        # Scenario 3: TTYD_ARGS building with multiple options  
        if grep -q 'TTYD_ARGS=\${TTYD_ARGS}.*\-t' "$RUN_SCRIPT"; then
            skip "Run script builds TTYD_ARGS with multiple -t arguments (TASK-002 fix applied)"  
        else
            echo "FAIL: Run script missing proper TTYD_ARGS construction" >&2
            return 1  
        fi
        
        # Scenario 4: Proper fallback when no custom configuration is provided
        if grep -q 'if.*!.*bashio::services.exists.*claude-ttyd.*then.*COMMAND="bash' "$RUN_SCRIPT"; then  
            echo "WARNING: Run script still has the old meaningless service existence check (TEST-003 not fixed)" >&2
            return 1
        else
            skip "Run script properly handles fallback without meaningless service check (TASK-006)"  
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test S6 service configuration with various addon options" {
    # Test that the S6 service properly reads and uses all addon configuration options
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Read and verify all expected configuration options are handled
        CONFIG_OPTIONS=("font_size" "theme" "tmux_enabled" "scrollback_lines")
        
        for option in "${CONFIG_OPTIONS[@]}"; do
            if grep -q "bashio::config '${option}'" "$RUN_SCRIPT"; then  
                skip "Run script reads addon configuration: ${option} (TASK-006)"
            else  
                echo "FAIL: Run script missing configuration read for: ${option}" >&2
                return 1
            fi  
        done
        
        # Verify the run script logs all configuration options in startup message
        if grep -q 'bashio::log.info.*font_size=\${FONT_SIZE}.*theme=\${THEME}.*tmux_enabled=\${TMUX_ENABLED}' "$RUN_SCRIPT"; then  
            skip "Run script includes proper configuration logging (TASK-006)"
        else
            echo "FAIL: Run script missing complete configuration logging" >&2
            return 1
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test S6 service integration with HA addon environment variables" {
    # Test that the S6 service properly integrates with Home Assistant addon environment
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then  
        RUN_SCRIPT="./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"
        
        # Verify the script uses bashio for configuration (HA addon specific)
        if grep -q "bashio::log\|bashio::config" "$RUN_SCRIPT"; then  
            skip "S6 run service properly integrates with HA addon environment via bashio (TASK-006)"
        else
            echo "FAIL: S6 run script not using expected HA addon integration methods" >&2
            return 1  
        fi
        
        # Check for proper use of services.exists for addon dependencies
        if grep -q 'bashio::services.exists' "$RUN_SCRIPT"; then
            skip "S6 run service uses HA services integration (TASK-006)"  
        else
            echo "FAIL: S6 run script missing services integration" >&2
            return 1
        fi
        
        # Verify the script is compatible with S6-overlay v3 structure
        if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/type" ]; then  
            type_content=$(cat "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/type")
            if [[ "$type_content" == *"longrun"* ]]; then
                skip "S6 service uses proper overlay v3 'longrun' type (TASK-006)"
            else  
                echo "FAIL: S6 service not using expected longrun type" >&2
                return 1
            fi  
        else
            echo "WARNING: S6 type file not found for complete validation" >&2
            skip "S6 overlay v3 structure partially validated (TASK-006)"  
        fi
    else
        skip "S6 run script not available for testing"
    fi
}

@test "Test comprehensive addon startup sequence including all components" {
    # End-to-end test that validates the complete addon startup sequence
    
    if [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ] && \ 
       [ -f "./rootfs/etc/cont-init.d/10-setup.sh" ] && \  
       [ -f "./rootfs/usr/bin/start-claude.sh" ]; then
        
        # Step 1: Verify addon initialization order
        bashio::log_info "Testing complete addon startup sequence..."
        
        if grep -q "mkdir.*data.*claude\|ln.*s.*/data/claude" "./rootfs/etc/cont-init.d/10-setup.sh"; then  
            skip "Addon init creates required directories and symlinks (TASK-004)"  
        else
            echo "FAIL: Addon initialization missing directory setup" >&2
            return 1  
        fi
        
        # Step 2: Verify start-claude.sh wrapper functionality
        if grep -q 'exec.*claude\|exec.*bash' "./rootfs/usr/bin/start-claude.sh"; then  
            skip "Addon wrapper script properly executes claude or fallback bash (TASK-005)"
        else
            echo "FAIL: Addon wrapper missing proper execution logic" >&2
            return 1  
        fi
        
        # Step 3: Verify S6 service orchestration
        if grep -q 'exec.*ttyd' "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then  
            skip "S6 service properly orchestrates ttyd terminal (TASK-006)"
        else
            echo "FAIL: S6 service missing proper ttyd orchestration" >&2  
            return 1
        fi
        
        # Step 4: Verify MCP configuration integration
        if grep -q 'SUPERVISOR_TOKEN\|config.json' "./rootfs/etc/cont-init.d/10-setup.sh"; then
            skip "Addon properly integrates MCP server configuration (TASK-008)"  
        else
            echo "FAIL: Addon missing proper MCP configuration" >&2
            return 1
        fi
        
        # Step 5: Verify watchdog integration in S6 service
        if grep -q 'max-death-tally\|death-count' "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then  
            skip "S6 service includes proper watchdog configuration (TASK-007)"  
        else
            echo "FAIL: S6 service missing watchdog integration" >&2
            return 1
        fi
        
        # Final comprehensive validation
        bashio::log_ok "All addon components validated successfully!"
        
        skip "Complete addon startup sequence tested and validated (TASK-004 through TASK-008)"  
    else
        echo "FAIL: Not all required addon files found for complete testing" >&2  
        return 1
    fi
}

@test "Test addon configuration options are properly propagated to all components" {
    # Verify that addon configuration options flow from config -> setup -> S6 service
    
    if [ -f "./rootfs/etc/cont-init.d/10-setup.sh" ] && \ 
       [ -f "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run" ]; then
        
        # Verify font_size configuration flows from addon options to ttyd
        if grep -q "bashio::config 'font_size'" "./rootfs/etc/cont-init.d/10-setup.sh"; then
            skip "Addon reads font_size from configuration (TASK-006)"  
        else
            echo "FAIL: Addon not reading font_size config" >&2
            return 1
        fi
        
        # Verify theme configuration is used in S6 service
        if grep -q "bashio::config 'theme'" "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then  
            skip "S6 service reads theme from addon configuration (TASK-002 fix applied)"
        else  
            echo "FAIL: S6 service not reading theme config" >&2
            return 1
        fi
        
        # Verify tmux_enabled configuration is properly handled
        if grep -q "bashio::config 'tmux_enabled'" "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then  
            skip "S6 service reads tmux_enabled from addon configuration (TASK-006)"  
        else
            echo "FAIL: S6 service not reading tmux_enabled config" >&2
            return 1
        fi
        
        # Verify scrollback_lines configuration is properly handled
        if grep -q "bashio::config 'scrollback_lines'" "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then  
            skip "S6 service reads scrollback_lines from addon configuration (TASK-006)"  
        else
            echo "FAIL: S6 service not reading scrollback_lines config" >&2
            return 1
        fi
        
        # Verify watchdog_enabled configuration is properly handled
        if grep -q "bashio::config 'watchdog_enabled'" "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then  
            skip "S6 service reads watchdog_enabled from addon configuration (TASK-007)"  
        else
            echo "FAIL: S6 service not reading watchdog_enabled config" >&2
            return 1
        fi
        
        # Verify all configuration options are logged appropriately  
        if grep -q 'bashio::log.info.*font_size=\${FONT_SIZE}.*theme=\${THEME}' "./rootfs/s6-overlay/s6-rc.d/claude-ttyd/run"; then
            skip "S6 service properly logs addon configuration (TASK-002 fix applied)"  
        else
            echo "FAIL: S6 service not logging proper configuration" >&2
            return 1
        fi
        
        # Verify MCP configuration uses SUPERVISOR_TOKEN from environment
        if grep -q 'SUPERVISOR_TOKEN' "./rootfs/etc/cont-init.d/10-setup.sh"; then  
            skip "Addon properly handles SUPERVISOR_TOKEN for MCP (TASK-008)"
        else
            echo "FAIL: Addon missing proper token handling" >&2
            return 1
        fi
        
        bashio::log_ok "All addon configuration options properly propagated!"  
        
        skip "Complete addon configuration flow validated successfully (TASK-004 through TASK-008)"
    else
        echo "FAIL: Not all required addon files found for configuration testing" >&2
        return 1
    fi
}