#!/usr/bin/env bats
# Integration test: verifies Home Manager wires the 4 custom subagents into
# ~/.claude/agents/ as Nix store symlinks. Pre-rebuild these skip, since the
# home.file declarations in modules/home-manager/claude-code/default.nix have
# not been applied yet. Post-rebuild they assert the symlinks resolve into
# /nix/store.

AGENTS=(flake-debugger package-finder generation-differ supply-chain-auditor)

# True when at least one expected agent symlink is present under ~/.claude/agents.
agents_deployed() {
  [ -d "$HOME/.claude/agents" ] || return 1
  local agent
  for agent in "${AGENTS[@]}"; do
    [ -L "$HOME/.claude/agents/${agent}.md" ] && return 0
  done
  return 1
}

@test "all 4 custom subagents deployed" {
  agents_deployed || skip "~/.claude/agents not populated — rebuild first"
  for agent in "${AGENTS[@]}"; do
    [ -L "$HOME/.claude/agents/${agent}.md" ] || {
      echo "FAIL: ~/.claude/agents/${agent}.md missing or not a symlink"
      return 1
    }
  done
}

@test "deployed subagents point to nix store" {
  agents_deployed || skip "~/.claude/agents not populated — rebuild first"
  for agent in "${AGENTS[@]}"; do
    target=$(readlink "$HOME/.claude/agents/${agent}.md")
    [[ "$target" =~ ^/nix/store/ ]] || {
      echo "FAIL: ${agent}.md not pointing to nix store: $target"
      return 1
    }
  done
}
