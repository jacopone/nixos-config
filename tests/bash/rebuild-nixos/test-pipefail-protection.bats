#!/usr/bin/env bats
# Tests for pipefail protection patterns in rebuild-nixos
# These tests verify that commands don't fail with set -o pipefail

setup() {
    load '../helpers/test-helpers'
}

@test "fd with no matches returns exit 0 with protection pattern" {
    set -o pipefail
    # This pattern should NOT fail even when fd finds nothing
    result=$( (fd -t f -s +100M '\.nonexistent$' /tmp 2>/dev/null || true) | wc -l)
    [ "$result" -eq 0 ]
}

@test "grep with no matches returns exit 0 with protection pattern" {
    set -o pipefail
    # This pattern should NOT fail even when grep finds nothing
    result=$(echo "no match here" | { grep "NOTFOUND" || true; } | wc -l)
    [ "$result" -eq 0 ]
}

@test "grep -v excluding all lines returns exit 0 with protection pattern" {
    set -o pipefail
    # When grep -v excludes ALL lines, it returns 1 - we need protection
    result=$(echo -e "exclude\nexclude" | { grep -v "exclude" || true; } | wc -l)
    [ "$result" -eq 0 ]
}

@test "ls with glob no match returns fallback with protection" {
    set -o pipefail
    # ls with non-matching glob fails - protection pattern should catch it
    # Trim whitespace and handle potential double output from || echo
    result=$(ls -1 /tmp/nonexistent-pattern-* 2>/dev/null | wc -l || echo "0")
    result=$(echo "$result" | tr -d '[:space:]' | head -c 1)
    [ "$result" = "0" ]
}

@test "chained pipeline with multiple potential failures" {
    set -o pipefail
    # Complex pipeline like in rebuild-nixos disk analysis
    result=$( (fd -t f -s +1M '\.nonexistent$' /tmp 2>/dev/null || true) | { grep -v "exclude" || true; } | wc -l)
    [ "$result" -eq 0 ]
}

@test "awk with empty input produces valid output" {
    set -o pipefail
    # awk should handle empty input gracefully
    result=$(echo "" | awk '{sum+=$1} END {print int(sum/1024)}' || echo "0")
    [ "$result" = "0" ]
}
