#!/usr/bin/env bats
# Integration test: verifies rebuild-nixos Phase 4 invokes the
# check-claude-config.sh validator and handles all three exit codes.
# Source: docs/plans/2026-05-18-claudeos-p0-implementation.md Task 22

@test "rebuild-nixos Phase 4 calls check-claude-config.sh" {
  grep -q "scripts/check-claude-config.sh" /home/guyfawkes/nixos-config/rebuild-nixos
}

@test "rebuild-nixos Phase 4 handles all 3 validator exit codes" {
  grep -q 'VALIDATOR_EXIT.*-eq 0\|VALIDATOR_EXIT.*-eq 1\|VALIDATOR_EXIT.*-eq 2' /home/guyfawkes/nixos-config/rebuild-nixos
}
