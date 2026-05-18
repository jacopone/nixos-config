#!/usr/bin/env bats
# Integration test: verifies Home Manager wires the 4 custom subagents into
# ~/.claude/agents/ as Nix store symlinks. These tests intentionally fail
# pre-rebuild (TDD red) — they pass only after `./rebuild-nixos --quick`
# applies the home.file declarations from modules/home-manager/claude-code/default.nix.

@test "all 4 custom subagents deployed" {
  for agent in flake-debugger package-finder generation-differ supply-chain-auditor; do
    [ -L "$HOME/.claude/agents/${agent}.md" ] || {
      echo "FAIL: ~/.claude/agents/${agent}.md missing or not a symlink"
      return 1
    }
  done
}

@test "deployed subagents point to nix store" {
  for agent in flake-debugger package-finder generation-differ supply-chain-auditor; do
    target=$(readlink "$HOME/.claude/agents/${agent}.md")
    [[ "$target" =~ ^/nix/store/ ]] || {
      echo "FAIL: ${agent}.md not pointing to nix store: $target"
      return 1
    }
  done
}
