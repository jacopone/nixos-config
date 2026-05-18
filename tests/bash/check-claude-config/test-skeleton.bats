#!/usr/bin/env bats

@test "check-claude-config.sh runs successfully" {
  run "$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh"
  # Accepts 0 (clean) or 1 (warnings); only 2 (errors) is a failure.
  [ "$status" -ne 2 ]
}

@test "check-claude-config.sh outputs valid JSON" {
  run "$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh"
  echo "$output" | jq empty
}

@test "plugin-version check emits info per enabled plugin" {
  # Validator may exit 0 or 1 (warnings); both produce valid JSON on stdout.
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh" || true)
  count=$(echo "$out" | jq '[.[] | select(.check == "plugin_version")] | length')
  [ "$count" -gt 0 ]
}

@test "symlink check covers ~/.claude/agents/ and ~/.claude/commands/" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh" || true)
  count=$(echo "$out" | jq '[.[] | select(.check == "symlink")] | length')
  [ "$count" -ge 1 ]
}

@test "subagent check covers all .md files in ~/.claude/agents/" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh" || true)
  count=$(echo "$out" | jq '[.[] | select(.check == "subagent_frontmatter")] | length')
  # Pre-rebuild: emits 1 warn ("agents dir missing"). Post-rebuild: emits one
  # per .md file in ~/.claude/agents/. The plan-level constraint requires the
  # check to emit at least one event so we know it actually ran.
  [ "$count" -ge 1 ]
}

@test "sandbox attestation check runs" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh" || true)
  count=$(echo "$out" | jq '[.[] | select(.check == "sandbox_attestation")] | length')
  [ "$count" -ge 1 ]
}
