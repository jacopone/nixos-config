#!/usr/bin/env bash
# Test helpers for BATS tests

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"

# Source rebuild-nixos functions without executing main script
# This extracts just the function definitions
extract_functions() {
    local script="$PROJECT_ROOT/rebuild-nixos"
    # Extract everything between the function definitions and the main execution
    # We'll source a temporary file with just the functions
    local temp_file
    temp_file=$(mktemp)

    # Extract color definitions and functions (up to argument parsing)
    sed -n '1,/^# Parse command line arguments/p' "$script" | head -n -1 > "$temp_file"

    # Remove the trap and cleanup that would interfere with tests
    sed -i '/^trap /d' "$temp_file"
    sed -i '/^set -e/d' "$temp_file"
    sed -i '/^set -o pipefail/d' "$temp_file"

    echo "$temp_file"
}

# Setup function to source rebuild-nixos functions
setup_rebuild_functions() {
    local func_file
    func_file=$(extract_functions)
    # shellcheck source=/dev/null
    source "$func_file"
    rm -f "$func_file"
}

# Mock sudo to avoid permission issues in tests
mock_sudo() {
    sudo() {
        # In tests, just run the command without sudo
        "$@"
    }
    export -f sudo
}

# Create a temporary test environment
create_test_env() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    cd "$TEST_DIR" || exit 1
}

# Cleanup test environment
cleanup_test_env() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}
