#!/usr/bin/env bash
# Claude Code statusline for ClaudeOS — surfaces host class, generation,
# branch, last-build status. Receives session JSON on stdin (unused for now;
# kept for future per-session context).
#
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G4
set -uo pipefail

# Drain stdin (session JSON) — reserved for future use
cat > /dev/null || true

host=$(hostname -s 2>/dev/null || echo "?")
host_class="?"
if [ -f /etc/claudeos/host-class ]; then
  host_class=$(cat /etc/claudeos/host-class)
fi

gen="?"
# Generation number lives in /nix/var/nix/profiles/system → system-N-link.
# /run/current-system is the store path (no generation number embedded).
if [ -L /nix/var/nix/profiles/system ]; then
  gen_link=$(readlink /nix/var/nix/profiles/system)
  gen_num=$(echo "$gen_link" | grep -oE 'system-[0-9]+' | cut -d- -f2)
  [ -n "$gen_num" ] && gen="$gen_num"
fi

branch="?"
if [ -d "$HOME/nixos-config/.git" ]; then
  branch=$(git -C "$HOME/nixos-config" branch --show-current 2>/dev/null || echo "?")
fi

last="?"
if [ -f "$HOME/.local/state/rebuild-nixos/last-status" ]; then
  last=$(cat "$HOME/.local/state/rebuild-nixos/last-status")
fi

echo "[${host} ${host_class} | gen ${gen} | ${branch} | last:${last}]"
