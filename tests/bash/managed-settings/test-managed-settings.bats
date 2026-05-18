#!/usr/bin/env bats
# Verify /etc/claude-code/managed-settings.json is installed by NixOS and
# contains the company-policies.md content byte-for-byte under claudeMd.
#
# Pre-rebuild this FAILS (the file does not yet exist).
# Post-rebuild this PASSES on any host that imports hosts/common/base.nix
# (which is every host in the fleet).
#
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G15
# Plan:   docs/plans/2026-05-18-claudeos-p0-implementation.md (Task 6)

setup() {
  MANAGED="/etc/claude-code/managed-settings.json"
  POLICIES_SOURCE="$(git rev-parse --show-toplevel)/modules/home-manager/claude-code/company-policies.md"
}

@test "managed-settings.json exists at /etc/claude-code/" {
  [ -f "$MANAGED" ]
}

@test "managed-settings.json is valid JSON" {
  run jq -e . "$MANAGED"
  [ "$status" -eq 0 ]
}

@test "managed-settings.json contains claudeMd key" {
  run jq -e 'has("claudeMd")' "$MANAGED"
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}

@test "managed-settings.json claudeMd matches company-policies.md byte-for-byte" {
  [ -f "$POLICIES_SOURCE" ] || skip "source policies file missing at $POLICIES_SOURCE"

  # `jq -j` writes the raw string without appending a trailing newline (which
  # `jq -r` would do), so this is a true byte-for-byte comparison including any
  # trailing newline that builtins.readFile preserves from the source file.
  diff <(jq -j '.claudeMd' "$MANAGED") "$POLICIES_SOURCE"
}
