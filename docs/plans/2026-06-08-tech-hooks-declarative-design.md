# Declarative tech-profile Claude hooks — design (2026-06-08)

## Problem
Two tech-profile Claude Code hooks live imperatively in `~/.claude/settings.json`,
so a fresh machine (or a settings.json re-seed) does not reproduce them:
- `SessionStart` -> gstack `gstack-session-update` (fleet-general)
- `PostToolUse` -> a memory-update reminder (amatino-specific, doubly broken: it
  read `$TOOL_INPUT` (not a real env var) and `echo`'d to stdout (which a
  PostToolUse hook sends to debug logs, never to the model)).

## Decision
Manage both declaratively in `modules/home-manager/claude-code/default.nix`,
mirroring `claude-business-hooks`. Generalize the reminder to a fleet hook that
resolves the current project's memory dir dynamically and fires only where one
exists. Fix its mechanics: read stdin `.tool_input.command`, surface via
`hookSpecificOutput.additionalContext`.

## Implementation
- New `hooks/memory-reminder.sh` (Nix-store symlink to `~/.claude/hooks/`).
- New `home.activation.claude-tech-hooks` (entryAfter `claude-settings-merge`)
  jq-sets `.hooks.SessionStart` (gstack) + `.hooks.PostToolUse` (reminder),
  overwriting the old broken pair. Dry-run safe (guards the jq+redirect).

## Trade-off
The activation OWNS user-level SessionStart + PostToolUse (overwrites each
rebuild), as claude-business-hooks owns PreToolUse. Hand-added user-level hooks
of those events get clobbered — put them in project settings instead.

## Edge case
Committing inside a worktree: the cwd slug won't match the main project's memory
dir, so the reminder stays silent there (existence guard). Acceptable.

## Bonus
`claude-business-hooks` had a dry-run corruption bug (unguarded `$DRY_RUN_CMD jq
... > tmp && mv`); fixed here with the same guard `claude-settings-merge` uses.

## E2E Test Impact
None — Claude Code tooling config, invisible to the amatino app E2E walkthrough.
