#!/usr/bin/env bats
# Validates YAML frontmatter for declarative Claude Code subagents.
# Source files live at modules/home-manager/claude-code/agents/.

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  AGENTS_DIR="$REPO_ROOT/modules/home-manager/claude-code/agents"
}

# Extract the YAML frontmatter block (between the first two --- fences).
frontmatter() {
  awk '/^---$/{c++; next} c==1' "$1"
}

# Assert an agent's frontmatter parses as YAML and carries the required
# fields: a .name matching the filename, a .description, and a non-empty
# .tools list with at least one tool. $2 is a description keyword to match.
assert_required_fields() {
  local agent="$1" desc_pattern="$2"
  local fm
  fm=$(frontmatter "$AGENTS_DIR/${agent}.md")
  echo "$fm" | yq eval . > /dev/null
  echo "$fm" | yq eval '.name' - | grep -q "^${agent}\$"
  echo "$fm" | yq eval '.description' - | grep -qi "$desc_pattern"
  # .tools is a comma-separated string; reject empty output and the literal
  # "null" that yq emits when the key is absent (which would pass vacuously).
  local tools
  tools=$(echo "$fm" | yq eval '.tools' -)
  [[ -n "$tools" && "$tools" != "null" ]]
}

@test "flake-debugger frontmatter is valid YAML" {
  frontmatter "$AGENTS_DIR/flake-debugger.md" | yq eval . > /dev/null
}

@test "package-finder frontmatter is valid YAML" {
  frontmatter "$AGENTS_DIR/package-finder.md" | yq eval . > /dev/null
}

@test "generation-differ frontmatter is valid YAML" {
  frontmatter "$AGENTS_DIR/generation-differ.md" | yq eval . > /dev/null
}

@test "supply-chain-auditor frontmatter is valid YAML" {
  frontmatter "$AGENTS_DIR/supply-chain-auditor.md" | yq eval . > /dev/null
}

@test "flake-debugger has required fields" {
  assert_required_fields flake-debugger "flake"
}

@test "package-finder has required fields" {
  assert_required_fields package-finder "package"
}

@test "generation-differ has required fields" {
  assert_required_fields generation-differ "generation"
}

@test "supply-chain-auditor has required fields" {
  assert_required_fields supply-chain-auditor "supply\|audit"
}
