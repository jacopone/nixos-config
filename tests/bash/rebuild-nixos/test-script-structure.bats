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
    # Find fd commands piped to wc that are NOT wrapped in (fd ... || true)
    # Protected pattern: $(  (fd ... || true)  | wc -l)
    # Unprotected pattern: $(fd ... | wc -l)  — fd returns exit 1 on no matches
    #
    # grep -v returns exit 1 when no lines pass the filter (= all protected),
    # so we use wc -l with || true to handle that gracefully.
    unprotected=$(grep -E 'fd -t f' "$PROJECT_ROOT/rebuild-nixos" | grep '| wc' | { grep -v '|| true' || true; } | wc -l)

    # All fd | wc pipelines must have || true protection
    [ "$unprotected" -eq 0 ]
}
