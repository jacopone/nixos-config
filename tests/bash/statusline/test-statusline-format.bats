#!/usr/bin/env bats
# Format test for the Claude Code statusline. Verifies the script runs,
# emits the expected single-line bracketed format, and consumes
# /etc/claudeos/host-class when host-class.nix is rebuilt-in.
#
# Test 1 + 2: pass standalone (the script works regardless of NixOS state).
# Test 3: skips pre-rebuild when /etc/claudeos/host-class does not exist.

setup() {
  STATUSLINE="/home/guyfawkes/nixos-config/modules/home-manager/claude-code/statusline.sh"
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
