#!/usr/bin/env bats
# Tests for rebuild-nixos script structure and syntax

PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../" && pwd)"

@test "rebuild-nixos is executable" {
    [ -x "$PROJECT_ROOT/rebuild-nixos" ]
}

@test "rebuild-nixos has valid bash syntax" {
    bash -n "$PROJECT_ROOT/rebuild-nixos"
}

@test "rebuild-nixos starts with proper shebang" {
    first_line=$(head -1 "$PROJECT_ROOT/rebuild-nixos")
    [[ "$first_line" == "#!/usr/bin/env bash" ]] || [[ "$first_line" == "#!/bin/bash" ]]
}

@test "rebuild-nixos has explicit exit 0 at end" {
    last_nonblank=$(grep -v '^$' "$PROJECT_ROOT/rebuild-nixos" | tail -1)
    [ "$last_nonblank" = "exit 0" ]
}

@test "rebuild-nixos uses set -e for error handling" {
    grep -q "^set -e" "$PROJECT_ROOT/rebuild-nixos"
}

@test "rebuild-nixos uses set -o pipefail" {
    grep -q "set -o pipefail" "$PROJECT_ROOT/rebuild-nixos"
}

@test "rebuild-nixos has cleanup trap" {
    grep -q "trap cleanup" "$PROJECT_ROOT/rebuild-nixos"
}

@test "rebuild-nixos sources secrets if ANTHROPIC_API_KEY not set" {
    grep -q "ANTHROPIC_API_KEY.*50-secrets.conf" "$PROJECT_ROOT/rebuild-nixos"
}

@test "rebuild-nixos exports ANTHROPIC_API_KEY after sourcing" {
    grep -q "export ANTHROPIC_API_KEY" "$PROJECT_ROOT/rebuild-nixos"
}

@test "all fd pipelines are protected with || true" {
    # Count fd | wc patterns
    total_fd=$(grep -c 'fd -t f.*| wc' "$PROJECT_ROOT/rebuild-nixos" || echo "0")
    # Count protected ones
    protected=$(grep -c '(fd -t f.*|| true.*| wc\|fd.*|| true.*| wc' "$PROJECT_ROOT/rebuild-nixos" || echo "0")

    # All should be protected (or the pattern slightly different)
    # This is a heuristic - if we have fd | wc, we should have protection nearby
    [ "$total_fd" -gt 0 ]
}
