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

check_plugin_versions() {
  local settings="${CLAUDE_DIR}/settings.json"
  [ ! -f "$settings" ] && { emit error plugin_version "settings.json missing"; return; }

  # Get enabled plugins from settings.json (true value)
  local plugin_ids
  plugin_ids=$(jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings")

  if [ -z "$plugin_ids" ]; then
    emit info plugin_version "no plugins enabled"
    return
  fi

  while IFS= read -r plugin_id; do
    [ -z "$plugin_id" ] && continue
    # Format: name@marketplace
    local marketplace plugin_name plugin_dir
    plugin_name="${plugin_id%@*}"
    marketplace="${plugin_id##*@}"
    plugin_dir="${CLAUDE_DIR}/plugins/cache/${marketplace}/${plugin_name}"

    if [ ! -d "$plugin_dir" ]; then
      emit warn plugin_version "plugin $plugin_id enabled but not in cache at $plugin_dir"
      continue
    fi

    # Plugins are cached under a version-hash subdirectory:
    # cache/<marketplace>/<plugin>/<version>/.claude-plugin/plugin.json
    # Pick the newest plugin.json (mtime) if multiple versions exist.
    local plugin_json version
    plugin_json=$(find "$plugin_dir" -maxdepth 3 -name plugin.json -path '*/.claude-plugin/plugin.json' -printf '%T@ %p\n' 2>/dev/null \
      | sort -nr | head -1 | cut -d' ' -f2-)

    if [ -z "$plugin_json" ] || [ ! -f "$plugin_json" ]; then
      emit warn plugin_version "$plugin_id: cache dir present but no plugin.json found"
      continue
    fi

    version=$(jq -r '.version // "?"' "$plugin_json" 2>/dev/null || echo "?")
    emit info plugin_version "$plugin_id @ $version"
  done <<<"$plugin_ids"
}

check_plugin_versions

check_symlinks_valid() {
  local dir target store_target
  local emitted=0
  for dir in agents commands hooks output-styles seccomp; do
    target="${CLAUDE_DIR}/${dir}"
    [ ! -d "$target" ] && continue

    while IFS= read -r link; do
      [ -z "$link" ] && continue
      if [ ! -e "$link" ]; then
        emit error symlink "dangling symlink: $link"
      else
        store_target=$(readlink "$link")
        if [[ "$store_target" =~ ^/nix/store/ ]]; then
          emit info symlink "$(basename "$link") -> nix store (OK)"
        else
          emit warn symlink "$(basename "$link") -> $store_target (not nix store - drift?)"
        fi
      fi
      emitted=$((emitted + 1))
    done < <(find "$target" -maxdepth 1 -type l 2>/dev/null)
  done

  if [ "$emitted" -eq 0 ]; then
    emit info symlink "no symlinks found under agents/, commands/, hooks/, output-styles/, seccomp/"
  fi
}

check_symlinks_valid

check_subagents_parseable() {
  local agents_dir="${CLAUDE_DIR}/agents"
  if [ ! -d "$agents_dir" ]; then
    emit warn subagent_frontmatter "~/.claude/agents/ missing (rebuild may be pending)"
    return
  fi

  local count=0
  local name frontmatter
  for agent_file in "$agents_dir"/*.md; do
    [ -f "$agent_file" ] || continue
    name=$(basename "$agent_file" .md)
    count=$((count + 1))

    # Extract frontmatter (lines between first two ---)
    frontmatter=$(awk '/^---$/{c++; next} c==1' "$agent_file")
    if [ -z "$frontmatter" ]; then
      emit error subagent_frontmatter "$name: missing frontmatter"
      continue
    fi

    # Validate required fields
    if ! echo "$frontmatter" | grep -q '^name:'; then
      emit error subagent_frontmatter "$name: missing 'name' field"
    elif ! echo "$frontmatter" | grep -q '^description:'; then
      emit error subagent_frontmatter "$name: missing 'description' field"
    else
      emit info subagent_frontmatter "$name: valid"
    fi
  done

  if [ "$count" -eq 0 ]; then
    emit info subagent_frontmatter "no .md files in $agents_dir"
  fi
}

check_subagents_parseable

check_sandbox_attestation() {
  local seccomp_dir="${CLAUDE_DIR}/seccomp"

  if [ ! -d "$seccomp_dir" ]; then
    emit warn sandbox_attestation "no seccomp directory; sandbox may be disabled"
    return
  fi

  local required
  for required in apply-seccomp unix-block.bpf; do
    if [ ! -e "$seccomp_dir/$required" ]; then
      emit error sandbox_attestation "missing $required (Invariant #4 at risk)"
    fi
  done

  # Check apply-seccomp is executable (resolves through symlink to nix store)
  if [ -e "$seccomp_dir/apply-seccomp" ] && [ ! -x "$seccomp_dir/apply-seccomp" ]; then
    emit error sandbox_attestation "apply-seccomp not executable"
  fi

  # Check settings.json includes a sandbox block
  local settings="${CLAUDE_DIR}/settings.json"
  if [ -f "$settings" ]; then
    local has_sandbox
    has_sandbox=$(jq -r '.sandbox // {} | length' "$settings" 2>/dev/null || echo 0)
    if [ "$has_sandbox" -eq 0 ]; then
      emit error sandbox_attestation "settings.json has no sandbox block"
    else
      emit info sandbox_attestation "sandbox block present in settings.json"
    fi
  else
    emit error sandbox_attestation "settings.json missing"
  fi
}

check_sandbox_attestation

check_stale_files() {
  # Pattern: legacy files known to be orphans from removed Phase 8
  local stale_patterns=(
    "learner_counter_*"
    "security_warnings_state_*"
    "CLAUDE_CODE_ANALYSIS.md"
    "tool-analytics.md"
    "permissions_auto_generated.md"
  )

  local found=0
  local pattern matches
  for pattern in "${stale_patterns[@]}"; do
    matches=$(find "$CLAUDE_DIR" -maxdepth 2 -name "$pattern" 2>/dev/null | wc -l)
    if [ "$matches" -gt 0 ]; then
      emit warn stale_file "found $matches file(s) matching pattern $pattern"
      found=$((found + matches))
    fi
  done

  if [ "$found" -eq 0 ]; then
    emit info stale_file "no stale files found"
  fi
}

check_stale_files

# Output JSON array
echo "${EVENTS[@]}" | jq -s .

exit "$EXIT_CODE"
