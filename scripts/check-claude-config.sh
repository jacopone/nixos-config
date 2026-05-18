#!/usr/bin/env bash
# Claude Code configuration validator.
# Replaces the stub at rebuild-nixos:919-935 with real checks that catch
# drift between declarative intent (NixOS / Home Manager) and the actual
# state of ~/.claude/.
#
# Exit code:
#   0 — all checks passed
#   1 — warnings (cosmetic, not blocking)
#   2 — errors (declarative drift, must investigate)
#
# Output: structured JSON (consumable by P1-2 telemetry MCP).
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G5
set -uo pipefail

CLAUDE_DIR="${HOME}/.claude"
NIXOS_CONFIG="${HOME}/nixos-config"
EXIT_CODE=0

# Collect events as JSON objects, print as a single array at end
declare -a EVENTS=()

emit() {
  local level="$1"  # info, warn, error
  local check="$2"
  local message="$3"
  EVENTS+=("$(jq -n --arg level "$level" --arg check "$check" --arg message "$message" \
    '{level: $level, check: $check, message: $message}')")
  case "$level" in
    error) EXIT_CODE=2 ;;
    warn) [ "$EXIT_CODE" -lt 1 ] && EXIT_CODE=1 ;;
  esac
}

# Checks go here in subsequent tasks
# check_plugin_versions
# check_symlinks_valid
# check_subagents_parseable
# check_sandbox_attestation
# check_stale_files

# Output JSON array
echo "${EVENTS[@]}" | jq -s .

exit "$EXIT_CODE"
