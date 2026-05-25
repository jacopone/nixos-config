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

# format_age SECONDS → a compact human age for the last-build annotation, e.g.
# "2d", "3h", "15m", "8s". The caller wraps the result in parens and only calls
# this when the status file exists; an empty return prints no age suffix.
#
# TODO(you): implement the bucketing. The decisions that shape the UX:
#   - thresholds: secs < 60 → "Ns"; < 3600 → "Nm"; < 86400 → "Nh"; else "Nd"
#   - clock skew: a negative age (mtime in the future) should clamp to "0s"
#               so a forward NTP step never prints a garbage age.
# Must echo a non-empty token on success. See followups-queue.md #24 I1.
format_age() {
  local secs="$1"
  (( secs < 0 )) && secs=0          # clock skew / future mtime → no garbage age
  if   (( secs < 60 ));    then echo "${secs}s"
  elif (( secs < 3600 ));  then echo "$(( secs / 60 ))m"
  elif (( secs < 86400 )); then echo "$(( secs / 3600 ))h"
  else                          echo "$(( secs / 86400 ))d"
  fi
}

last="?"
last_age=""
status_file="$HOME/.local/state/rebuild-nixos/last-status"
if [ -f "$status_file" ]; then
  last=$(cat "$status_file")
  mtime=$(stat -c %Y "$status_file" 2>/dev/null || echo "")
  if [ -n "$mtime" ]; then
    age=$(format_age "$(( $(date +%s) - mtime ))")
    [ -n "$age" ] && last_age="(${age})"
  fi
fi

echo "[${host} ${host_class} | gen ${gen} | ${branch} | last:${last}${last_age}]"
