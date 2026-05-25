#!/usr/bin/env bats
# Format test for the Claude Code statusline. Verifies the script runs,
# emits the expected single-line bracketed format, and consumes
# /etc/claudeos/host-class when host-class.nix is rebuilt-in.
#
# Test 1 + 2: pass standalone (the script works regardless of NixOS state).
# Test 3: skips pre-rebuild when /etc/claudeos/host-class does not exist.

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  STATUSLINE="$REPO_ROOT/modules/home-manager/claude-code/statusline.sh"
}

@test "statusline produces output" {
  out=$(echo '{}' | bash "$STATUSLINE")
  [ -n "$out" ]
}

@test "statusline format matches expected pattern" {
  out=$(echo '{}' | bash "$STATUSLINE")
  # Expect: [hostname class | gen N | branch | last:?]
  [[ "$out" =~ ^\[.+\ .+\ \|\ gen\ .+\ \|\ .+\ \|\ last:.+\]$ ]] || {
    echo "Unexpected format: $out"
    return 1
  }
}

@test "statusline reads host-class from /etc/claudeos/host-class" {
  [ ! -f /etc/claudeos/host-class ] && skip "/etc/claudeos/host-class missing — rebuild first"
  expected=$(cat /etc/claudeos/host-class)
  out=$(echo '{}' | bash "$STATUSLINE")
  [[ "$out" == *" $expected "* ]] || {
    echo "Expected '$expected' in output: $out"
    return 1
  }
}

@test "statusline annotates last-status with its age" {
  tmp_home=$(mktemp -d)
  mkdir -p "$tmp_home/.local/state/rebuild-nixos"
  printf 'succ' > "$tmp_home/.local/state/rebuild-nixos/last-status"
  # Pin mtime 200000s (~2.3 days) in the past so the day bucket is unambiguous
  # and immune to millisecond timing flake at the bucket boundary.
  touch -d "@$(( $(date +%s) - 200000 ))" "$tmp_home/.local/state/rebuild-nixos/last-status"
  out=$(echo '{}' | HOME="$tmp_home" bash "$STATUSLINE")
  rm -rf "$tmp_home"
  [[ "$out" == *"last:succ(2d)"* ]] || {
    echo "Expected 'last:succ(2d)' in output: $out"
    return 1
  }
}

@test "statusline age uses sub-day buckets (not a hardcoded day)" {
  # Guards the 2d test against a vacuous format_age that just echoes a constant:
  # a 2-hour-old file must read (2h), proving the bucketing actually computes.
  tmp_home=$(mktemp -d)
  mkdir -p "$tmp_home/.local/state/rebuild-nixos"
  printf 'succ' > "$tmp_home/.local/state/rebuild-nixos/last-status"
  touch -d "@$(( $(date +%s) - 7200 ))" "$tmp_home/.local/state/rebuild-nixos/last-status"
  out=$(echo '{}' | HOME="$tmp_home" bash "$STATUSLINE")
  rm -rf "$tmp_home"
  [[ "$out" == *"last:succ(2h)"* ]] || {
    echo "Expected 'last:succ(2h)' in output: $out"
    return 1
  }
}

@test "statusline shows no age suffix when last-status is absent" {
  tmp_home=$(mktemp -d)   # deliberately no last-status file
  out=$(echo '{}' | HOME="$tmp_home" bash "$STATUSLINE")
  rm -rf "$tmp_home"
  [[ "$out" == *"last:?"* ]] || { echo "Expected 'last:?' in output: $out"; return 1; }
  [[ "$out" != *"last:?("* ]] || { echo "Unexpected age suffix on missing status: $out"; return 1; }
}
