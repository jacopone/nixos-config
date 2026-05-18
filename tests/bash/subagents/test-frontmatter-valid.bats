#!/usr/bin/env bats
# Validates YAML frontmatter for declarative Claude Code subagents.
# Source files live at modules/home-manager/claude-code/agents/.

@test "flake-debugger frontmatter is valid YAML" {
  awk '/^---$/{c++; next} c==1' \
    /home/guyfawkes/nixos-config/modules/home-manager/claude-code/agents/flake-debugger.md \
    | yq eval . > /dev/null
}

@test "flake-debugger has required fields" {
  fm=$(awk '/^---$/{c++; next} c==1' \
    /home/guyfawkes/nixos-config/modules/home-manager/claude-code/agents/flake-debugger.md)
  echo "$fm" | yq eval '.name' - | grep -q flake-debugger
  echo "$fm" | yq eval '.description' - | grep -qi "flake"
  echo "$fm" | yq eval '.tools' - | grep -q Read
}

@test "package-finder frontmatter is valid YAML" {
  awk '/^---$/{c++; next} c==1' \
    /home/guyfawkes/nixos-config/modules/home-manager/claude-code/agents/package-finder.md \
    | yq eval . > /dev/null
}
