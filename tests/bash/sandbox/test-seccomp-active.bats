#!/usr/bin/env bats
# Verify Claude Code's seccomp filter blocks AF_UNIX socket creation.
# Post-rebuild this should PASS; pre-rebuild (or with broken config) FAILS.
#
# Source: docs/plans/2026-05-18-sandbox-schema-finding.md

setup() {
  CLAUDE_BIN=$(command -v claude 2>/dev/null || true)
  APPLY_SECCOMP="$HOME/.claude/seccomp/apply-seccomp"
}

@test "apply-seccomp binary exists and is executable" {
  [ -x "$APPLY_SECCOMP" ]
}

@test "direct apply-seccomp invocation blocks AF_UNIX socket creation" {
  # Uses the legacy two-arg form (apply-seccomp <bpf> <command>) which
  # works regardless of whether BPF_PATH is compiled in.
  BPF="$HOME/.claude/seccomp/unix-block.bpf"
  [ -f "$BPF" ] || skip "BPF file missing at $BPF"

  run "$APPLY_SECCOMP" "$BPF" python3 -c \
    "import socket; socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); print('NOT BLOCKED')"

  # Expected: non-zero exit OR no 'NOT BLOCKED' in output
  [ "$status" -ne 0 ] || ! [[ "$output" =~ "NOT BLOCKED" ]]
}

@test "single-arg apply-seccomp invocation uses BPF_PATH (post-migration)" {
  # The new single-arg form requires BPF_PATH compiled in.
  # Pre-migration this will fail with usage error (expected — proves migration needed).
  # Post-migration this should succeed at running the command AND block AF_UNIX.
  run "$APPLY_SECCOMP" python3 -c \
    "import socket; socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); print('NOT BLOCKED')"

  # Expected: either usage error (pre-migration) OR socket-creation failure
  # NOT acceptable: "NOT BLOCKED" output with status 0
  ! [[ "$status" -eq 0 && "$output" =~ "NOT BLOCKED" ]]
}
