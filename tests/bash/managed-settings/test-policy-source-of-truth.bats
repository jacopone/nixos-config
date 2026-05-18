#!/usr/bin/env bats
# Guard against regression to two sources of truth for company policies.
#
# After Task 7 (P0-3b), policies live in /etc/claude-code/managed-settings.json
# under the claudeMd key — root-owned and user-deletion-proof. A duplicate
# ~/.claude/CLAUDE.md symlink (the pre-Task-7 home.file deployment) would
# defeat that authority model: a user could delete the symlink and silently
# diverge from org policy.
#
# This test only runs the comparison when BOTH files exist; pre-rebuild it
# passes trivially (managed-settings.json is absent until the next rebuild).
#
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G15
# Plan:   docs/plans/2026-05-18-claudeos-p0-implementation.md (Task 7)

@test "company-policies.md is single source of truth" {
  # Verify ~/.claude/CLAUDE.md (if present) is NOT a duplicate of managed claudeMd
  if [ -f "$HOME/.claude/CLAUDE.md" ] && [ -f /etc/claude-code/managed-settings.json ]; then
    home_md=$(cat "$HOME/.claude/CLAUDE.md")
    managed=$(jq -r '.claudeMd' /etc/claude-code/managed-settings.json)
    [ "$home_md" != "$managed" ] || {
      echo "FAIL: $HOME/.claude/CLAUDE.md duplicates the managed claudeMd content"
      return 1
    }
  fi
}
