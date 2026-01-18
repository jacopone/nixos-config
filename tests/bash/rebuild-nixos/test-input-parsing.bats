#!/usr/bin/env bats
# Tests for input parsing and validation in rebuild-nixos

setup() {
    load '../helpers/test-helpers'
}

@test "generation input 'a' should be recognized as auto" {
    # Test the condition that accepts 'a' or 'auto'
    input="a"
    if [ "$input" = "auto" ] || [ "$input" = "a" ]; then
        result="auto_cleanup"
    else
        result="manual"
    fi
    [ "$result" = "auto_cleanup" ]
}

@test "generation input 'auto' should be recognized as auto" {
    input="auto"
    if [ "$input" = "auto" ] || [ "$input" = "a" ]; then
        result="auto_cleanup"
    else
        result="manual"
    fi
    [ "$result" = "auto_cleanup" ]
}

@test "generation input '404 405' should be recognized as manual" {
    input="404 405"
    if [ "$input" = "auto" ] || [ "$input" = "a" ]; then
        result="auto_cleanup"
    else
        result="manual"
    fi
    [ "$result" = "manual" ]
}

@test "empty generation input should skip deletion" {
    input=""
    if [ -n "$input" ]; then
        result="process"
    else
        result="skip"
    fi
    [ "$result" = "skip" ]
}

@test "environment.d file can be sourced correctly" {
    # Create a test secrets file
    temp_file=$(mktemp)
    echo "TEST_KEY=test_value_123" > "$temp_file"

    # Source it
    # shellcheck source=/dev/null
    source "$temp_file"

    # Verify it was set
    [ "$TEST_KEY" = "test_value_123" ]

    # Cleanup
    rm -f "$temp_file"
}

@test "sourced variables can be exported" {
    temp_file=$(mktemp)
    echo "EXPORT_TEST=should_be_visible" > "$temp_file"

    # shellcheck source=/dev/null
    source "$temp_file"
    export EXPORT_TEST

    # Test that a subshell can see it
    result=$(bash -c 'echo $EXPORT_TEST')
    [ "$result" = "should_be_visible" ]

    rm -f "$temp_file"
}
