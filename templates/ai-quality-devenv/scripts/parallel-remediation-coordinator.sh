#!/usr/bin/env bash
      #!/usr/bin/env bash
      set -euo pipefail

      echo "🤖 Parallel Remediation Coordinator"
      echo ""

      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ Error: No remediation state found"
        exit 1
      fi

      # Parse arguments
      NUM_AGENTS="''${1:-2}"

      if ! [[ "$NUM_AGENTS" =~ ^[0-9]+$ ]] || [ "$NUM_AGENTS" -lt 1 ] || [ "$NUM_AGENTS" -gt 5 ]; then
        echo "Usage: parallel-remediation-coordinator [num-agents]"
        echo ""
        echo "Arguments:"
        echo "  num-agents  Number of parallel agents (1-5, default: 2)"
        exit 1
      fi

      STATE=$(cat .quality/remediation-state.json)
      PHASE=$(echo "$STATE" | jq -r '.current_phase')

      echo "⚙️  Configuration:"
      echo "   • Agents: $NUM_AGENTS"
      echo "   • Phase: $(echo "$PHASE" | tr '[:lower:]' '[:upper:]')"
      echo ""

      # Get pending targets
      PENDING_TARGETS=$(echo "$STATE" | jq --arg phase "$PHASE" '
        [.targets.pending[] | select(.category == $phase)]
      ')
      PENDING_COUNT=$(echo "$PENDING_TARGETS" | jq 'length')

      if [ "$PENDING_COUNT" -eq 0 ]; then
        echo "✅ No pending targets in current phase"
        exit 0
      fi

      echo "📋 Distributing $PENDING_COUNT targets across $NUM_AGENTS agents..."
      echo ""

      # Distribute targets across agents (round-robin)
      mkdir -p .quality/agent-queues

      for agent_id in $(seq 0 $((NUM_AGENTS - 1))); do
        echo "$PENDING_TARGETS" | jq --arg agent "$agent_id" --arg total "$NUM_AGENTS" '
          [.[] | select((.priority // 0) as $p | ($p % ($total | tonumber)) == ($agent | tonumber))]
        ' > ".quality/agent-queues/agent-$agent_id.json"

        AGENT_COUNT=$(cat ".quality/agent-queues/agent-$agent_id.json" | jq 'length')
        echo "   🤖 Agent $agent_id: $AGENT_COUNT targets assigned"
      done

      echo ""
      echo "🚀 Parallel Execution Instructions:"
      echo ""
      echo "Each agent should work independently on their assigned queue."
      echo "Coordination prevents file conflicts through target distribution."
      echo ""

      for agent_id in $(seq 0 $((NUM_AGENTS - 1))); do
        AGENT_QUEUE=".quality/agent-queues/agent-$agent_id.json"
        AGENT_COUNT=$(cat "$AGENT_QUEUE" | jq 'length')

        if [ "$AGENT_COUNT" -gt 0 ]; then
          echo "📍 Agent $agent_id Workflow:"
          echo "   1. Review queue: cat $AGENT_QUEUE | jq ."
          echo "   2. Process each target in sequence"
          echo "   3. Use validate-target-improved after each fix"
          echo "   4. Checkpoint progress with checkpoint-progress"
          echo ""
        fi
      done

      echo "⚠️  Conflict Resolution:"
      echo "   • Each agent has non-overlapping targets"
      echo "   • If merge conflicts occur, use: git checkout --ours <file>"
      echo "   • Coordinate checkpoints to avoid race conditions"
      echo ""

      echo "🔄 Progress Monitoring:"
      echo "   • Each agent updates shared remediation-state.json"
      echo "   • View overall progress: generate-progress-report"
      echo "   • Check for issues: analyze-failure-patterns"
      echo ""

      echo "✅ Coordinator setup complete!"
      echo "   Agents can now begin parallel execution."
    '';

    # ============================================================================
    # WEEK 1: DOCUMENTATION & STRUCTURE QUALITY GATES
    # ============================================================================

    assess-documentation.exec = "bash scripts/assess-documentation.sh";
    analyze-folder-structure.exec = "bash scripts/analyze-folder-structure.sh";
    check-naming-conventions.exec = "bash scripts/check-naming-conventions.sh";
  };

  # https://devenv.sh/pre-commit-hooks/
  git-hooks.hooks = {
    # JavaScript/TypeScript formatting and linting
    prettier = {
      enable = true;
      excludes = [ "dist/" "coverage/" "node_modules/" ".devenv/" "result" ];
    };

    eslint = {
      enable = true;
      files = "\.(js|ts|tsx)$";
      excludes = [ "dist/" "coverage/" "node_modules/" ];
    };

    # Python formatting and linting
    black = {
      enable = true;
      files = "\.py$";
      excludes = [ ".devenv/" "result" ];
    };

    ruff = {
      enable = true;
      files = "\.py$";
      excludes = [ ".devenv/" "result" ];
    };

    # Security scanning
    gitleaks = {
      enable = true;
      name = "gitleaks-security-scan";
      entry = "${pkgs.gitleaks}/bin/gitleaks detect --source .";
      excludes = [ ".devenv/" "result" "node_modules/" "coverage/" "dist/" "build/" ];
    };

    # Enhanced quality gates (AI code protection)
    # Note: Using system-wide tools for consistency across all projects
    complexity-check = {
      enable = true;
      name = "complexity-check";
      entry = "lizard --CCN 10 --length 50";  # Available system-wide
      files = "\.(py|js|ts|tsx)$";
      excludes = [ ".devenv/" "node_modules/" "coverage/" "dist/" ];
    };

    jscpd = {
      enable = true;
      name = "clone-detection";
      entry = "jscpd --threshold 5 --min-lines 10";  # Available system-wide via npx wrapper
      files = "\.(js|ts|tsx)$";
      excludes = [ "node_modules/" "coverage/" "dist/" ];
    };

    semgrep = {
      enable = true;
      name = "security-patterns";
      entry = "${pkgs.semgrep}/bin/semgrep --config=auto --error";
      files = "\.(py|js|ts|tsx|yaml|yml|json)$";
      excludes = [ ".devenv/" "node_modules/" "coverage/" "dist/" ];
    };

    # Commit message formatting
    commitizen = {
      enable = true;
      name = "commitizen check";
      entry = "${pkgs.python3Packages.commitizen}/bin/cz check --commit-msg-file";
      stages = [ "commit-msg" ];
    };

    # ============================================================================
    # WEEK 1: DOCUMENTATION & STRUCTURE QUALITY HOOKS
    # ============================================================================

    # Markdown linting
    markdownlint = {
      enable = true;
      files = "\.md$";
      entry = "${pkgs.nodePackages.markdownlint-cli2}/bin/markdownlint-cli2";
      excludes = [ "node_modules/" ".devenv/" "CHANGELOG.md" ".quality/" ];
    };

    # Naming conventions
    ls-lint = {
      enable = true;
      name = "naming-conventions";
      entry = "${pkgs.ls-lint}/bin/ls-lint";
      pass_filenames = false;
    };
  };

  enterShell = ''
    hello
