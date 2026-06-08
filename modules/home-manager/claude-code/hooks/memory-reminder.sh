#!/usr/bin/env bash
# PostToolUse(Bash) hook: after a `git commit`, remind the model to review the
# commit for memory-worthy learnings. Fleet-general — resolves the CURRENT
# project's Claude memory dir from the hook event and fires only if it exists
# (silent in projects with no memory dir).
#
# Fixes both bugs the old inline hook had:
#  - input: $TOOL_INPUT is NOT a real env var; tool data arrives as JSON on
#    stdin, with the bash command at .tool_input.command.
#  - output: plain stdout from a PostToolUse hook reaches debug logs only; to
#    reach the model you must emit {hookSpecificOutput.additionalContext}.
set -uo pipefail

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)

case "$command" in
  *"git commit"*) : ;;
  *) exit 0 ;;
esac

[ -n "$cwd" ] || exit 0
slug=$(printf '%s' "$cwd" | sed 's#/#-#g')
memdir="$HOME/.claude/projects/$slug/memory"
[ -d "$memdir" ] || exit 0

jq -n --arg dir "$memdir" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("MEMORY UPDATE REMINDER: review this commit for new learnings (CI/CD patterns, bug fixes, architecture decisions, gotchas) and update memory files in " + $dir + " if applicable.")
  }
}'
exit 0
