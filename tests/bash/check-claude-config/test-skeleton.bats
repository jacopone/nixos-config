#!/usr/bin/env bats

@test "check-claude-config.sh runs successfully" {
  run "$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh"
  [ "$status" -eq 0 ]
}

@test "check-claude-config.sh outputs valid JSON" {
  run "$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh"
  echo "$output" | jq empty
}
