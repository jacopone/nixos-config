#!/usr/bin/env bash
# Script to extract inline scripts from devenv.nix to scripts/ directory

set -e

SCRIPTS_DIR="scripts"
mkdir -p "$SCRIPTS_DIR"

# List of scripts to extract (excluding already extracted ones)
SCRIPTS=(
  "hello"
  "quality-check"
  "quality-report"
  "setup-git-hooks"
  "init-ai-tools"
  "setup-cursor"
  "setup-claude"
  "assess-codebase"
  "generate-remediation-plan"
  "quality-dashboard"
  "initialize-remediation-state"
  "update-remediation-state"
  "check-feature-readiness"
  "certify-feature-ready"
  "quality-regression-check"
  "identify-next-targets"
  "checkpoint-progress"
  "needs-human-checkpoint"
  "validate-target-improved"
  "mark-checkpoint-approved"
  "rollback-to-checkpoint"
  "autonomous-remediation-session"
  "estimate-token-usage"
  "analyze-failure-patterns"
  "generate-progress-report"
  "parallel-remediation-coordinator"
)

echo "Extracting ${#SCRIPTS[@]} scripts from devenv.nix..."

for script_name in "${SCRIPTS[@]}"; do
  echo "  → Extracting $script_name..."

  # Use awk to extract the script content between .exec = '' and the closing '';
  awk -v name="$script_name" '
    $0 ~ name "\\.exec = '\'\''" {
      in_script = 1
      next
    }
    in_script && /^[[:space:]]*'\'';$/ {
      in_script = 0
      exit
    }
    in_script {
      print
    }
  ' devenv.nix > "$SCRIPTS_DIR/$script_name.sh"

  # Add shebang if not present
  if [ -s "$SCRIPTS_DIR/$script_name.sh" ]; then
    if ! head -1 "$SCRIPTS_DIR/$script_name.sh" | grep -q "^#!"; then
      echo -e "#!/usr/bin/env bash\n$(cat "$SCRIPTS_DIR/$script_name.sh")" > "$SCRIPTS_DIR/$script_name.sh"
    fi
    chmod +x "$SCRIPTS_DIR/$script_name.sh"
    echo "     ✓ Created $SCRIPTS_DIR/$script_name.sh"
  else
    echo "     ⚠️  Failed to extract $script_name"
    rm -f "$SCRIPTS_DIR/$script_name.sh"
  fi
done

echo ""
echo "✅ Extraction complete!"
echo "📊 Scripts in $SCRIPTS_DIR/:"
ls -1 "$SCRIPTS_DIR"/*.sh | wc -l
