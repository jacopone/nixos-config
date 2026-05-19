#!/usr/bin/env bats
# Regression test for followups queue #18.
#
# The home.activation.claude-settings-merge block in
# modules/home-manager/claude-code/default.nix used the Home Manager
# `$DRY_RUN_CMD` prefix in front of a `jq ... > "$SETTINGS"` pipeline.
# When Home Manager runs in --dry-run, $DRY_RUN_CMD=echo, so the shell
# evaluates `echo jq ... > "$SETTINGS"` — writing the literal jq
# command-as-string into $SETTINGS (or its .tmp sibling that is then
# `mv`d into place) and destroying real user config in "preview" mode.
#
# Two checks:
#   1. Structural — the source no longer contains the unsafe prefix.
#   2. Behavioral — a synthetic reproducer with the bare pattern DOES
#      corrupt the target, and the guarded pattern does NOT. The
#      reproducer keeps the test self-validating against shell changes.
#
# See: docs/plans/2026-05-19-followups-queue.md #18

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  NIX_FILE="$REPO_ROOT/modules/home-manager/claude-code/default.nix"
  TMP="$(mktemp -d)"
}

teardown() {
  [ -n "$TMP" ] && [ -d "$TMP" ] && rm -rf "$TMP"
}

@test "default.nix exists" {
  [ -f "$NIX_FILE" ]
}

@test "default.nix does not invoke jq under bare \$DRY_RUN_CMD prefix" {
  # The buggy shape: a line beginning with `$DRY_RUN_CMD ${pkgs.jq}/bin/jq`
  # followed by a redirection to settings.json. The fix replaces this with
  # an explicit `if [ -n "$DRY_RUN_CMD" ]; then ... else jq ... fi` guard,
  # or with `$DRY_RUN_CMD bash -c '...'` so the redirect lives inside the
  # subshell whose entire command echo prints rather than executes.
  run grep -F '$DRY_RUN_CMD ${pkgs.jq}/bin/jq' "$NIX_FILE"
  [ "$status" -ne 0 ] || {
    echo "Unsafe pattern found — see followups #18 and the comment block in this test."
    echo "Matched lines:"
    echo "$output"
    return 1
  }
}

@test "unsafe pattern (control): bare \$DRY_RUN_CMD with redirect DOES corrupt target" {
  # Reproduces the bug in isolation. If this ever fails, the bash semantics
  # the structural test relies on have changed and the guard needs revisiting.
  target="$TMP/settings.json"
  echo '{"keep": "me"}' > "$target"
  original_sha="$(sha256sum "$target" | cut -d' ' -f1)"

  DRY_RUN_CMD=echo bash -c "
    \$DRY_RUN_CMD jq '.added = true' '$target' > '$target'
  "

  new_sha="$(sha256sum "$target" | cut -d' ' -f1)"
  [ "$original_sha" != "$new_sha" ]
  # Confirm the file now holds the echoed command, not the original JSON
  grep -q "jq" "$target"
}

@test "guarded pattern: explicit DRY_RUN_CMD check preserves target byte-for-byte" {
  # The shape the fix should adopt. Evidence that the chosen guard is
  # actually dry-run-safe.
  target="$TMP/settings.json"
  echo '{"keep": "me"}' > "$target"
  original_sha="$(sha256sum "$target" | cut -d' ' -f1)"

  DRY_RUN_CMD=echo bash -c "
    SETTINGS='$target'
    if [ -n \"\$DRY_RUN_CMD\" ]; then
      \$DRY_RUN_CMD \"would merge into \$SETTINGS\"
    else
      jq '.added = true' \"\$SETTINGS\" > \"\$SETTINGS\"
    fi
  "

  new_sha="$(sha256sum "$target" | cut -d' ' -f1)"
  [ "$original_sha" = "$new_sha" ]
}

@test "guarded pattern: real-mode (DRY_RUN_CMD unset) still mutates target" {
  # Sanity check — the guard must not block the normal-mode write path.
  target="$TMP/settings.json"
  echo '{"keep": "me"}' > "$target"

  unset DRY_RUN_CMD
  bash -c "
    SETTINGS='$target'
    if [ -n \"\${DRY_RUN_CMD:-}\" ]; then
      echo \"would merge into \$SETTINGS\"
    else
      jq '.added = true' \"\$SETTINGS\" > \"\$SETTINGS.tmp\" && mv \"\$SETTINGS.tmp\" \"\$SETTINGS\"
    fi
  "

  run jq -e '.added == true' "$target"
  [ "$status" -eq 0 ]
}
