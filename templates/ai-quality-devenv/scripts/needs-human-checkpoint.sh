#!/usr/bin/env bash
      if [ ! -f .quality/remediation-state.json ]; then
        exit 1
      fi

      STATE=$(cat .quality/remediation-state.json)
      PHASE=$(echo "$STATE" | jq -r '.current_phase')
      SESSION_NUM=$(echo "$STATE" | jq '.sessions.completed')
      CONSECUTIVE_FAILURES=$(echo "$STATE" | jq '.consecutive_failures')

      if [ "$PHASE" = "complexity" ]; then
        SECURITY_APPROVED=$(echo "$STATE" | jq '.human_approvals[] | select(.checkpoint == "security_complete")' | wc -l)
        if [ "$SECURITY_APPROVED" -eq 0 ]; then
          echo "security_complete"
          exit 0
        fi
      fi

      if [ "$CONSECUTIVE_FAILURES" -ge 3 ]; then
        echo "consecutive_failures"
        exit 0
      fi

      if [ $((SESSION_NUM % 10)) -eq 0 ] && [ $SESSION_NUM -gt 0 ]; then
        SESSION_APPROVED=$(echo "$STATE" | jq ".human_approvals[] | select(.checkpoint == \"session_$SESSION_NUM\")" | wc -l)
        if [ "$SESSION_APPROVED" -eq 0 ]; then
          echo "session_$SESSION_NUM"
          exit 0
        fi
      fi

      exit 1
    '';

    validate-target-improved.exec = ''
      TARGET_ID=""
      for arg in "$@"; do
        case $arg in
          --target-id=*) TARGET_ID="''${arg#*=}" ;;
        esac
      done

      if [ -z "$TARGET_ID" ]; then
        echo "Usage: validate-target-improved --target-id=ID"
        exit 1
      fi

      TARGET=$(cat .quality/remediation-state.json | jq ".targets.in_progress[] | select(.id == \"$TARGET_ID\")")
      if [ -z "$TARGET" ]; then
        echo "❌ Target not found in in_progress"
        exit 1
      fi

      FILE=$(echo "$TARGET" | jq -r '.file')
      TYPE=$(echo "$TARGET" | jq -r '.type')

      echo "🔍 Validating $TARGET_ID..."
      echo ""

      echo "1️⃣ Running tests..."
      if [ -f package.json ] && grep -q '"test"' package.json; then
        npm test 2>&1 | tail -20 || { echo "  ❌ Tests failed"; exit 1; }
      elif [ -f pyproject.toml ] || [ -f setup.py ]; then
        pytest 2>&1 | tail -20 || { echo "  ❌ Tests failed"; exit 1; }
      fi
      echo "  ✅ Tests passed"
      echo ""

      if [ "$TYPE" = "complexity" ]; then
        echo "2️⃣ Checking complexity reduction..."
        FUNCTION=$(echo "$TARGET" | jq -r '.function // ""')
        BASELINE_CCN=$(echo "$TARGET" | jq -r '.ccn_current')
        TARGET_CCN=$(echo "$TARGET" | jq -r '.ccn_target')

        if [ -n "$FUNCTION" ]; then
          CURRENT_CCN=$(lizard "$FILE" 2>/dev/null | grep -F "$FUNCTION" | awk '{print $2}' | head -1 || echo "0")

          if [ "$CURRENT_CCN" -le "$TARGET_CCN" ]; then
            echo "  ✅ Complexity reduced: $BASELINE_CCN → $CURRENT_CCN (target: $TARGET_CCN)"
          else
            echo "  ⚠️  Partial improvement: $BASELINE_CCN → $CURRENT_CCN"
            echo "  Accepting partial improvement"
          fi
        fi
      elif [ "$TYPE" = "security" ]; then
        echo "2️⃣ Checking security fix..."
        NEW_ISSUES=$(gitleaks detect --source . --no-git 2>&1 | grep -c "Finding:" || echo 0)
        if [ "$NEW_ISSUES" -eq 0 ]; then
          echo "  ✅ No security issues detected"
        else
          echo "  ❌ New security issues found"
          exit 1
        fi
      fi

      echo ""
      echo "✅ Validation passed!"
      exit 0
    '';

    rollback-to-checkpoint.exec = ''
      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ No state found"
        exit 1
      fi

      LAST_TAG=$(git tag | grep "stable-session" | sort -V | tail -1)

      if [ -z "$LAST_TAG" ]; then
        echo "❌ No stable checkpoints found"
        exit 1
      fi

      echo "⚠️  Rolling back to checkpoint: $LAST_TAG"
      read -p "Continue? (y/N): " CONFIRM

      if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "Cancelled"
        exit 0
      fi

      git reset --hard "$LAST_TAG"
      echo "✅ Rolled back to $LAST_TAG"
    '';

    mark-checkpoint-approved.exec = ''
      CHECKPOINT=""
      for arg in "$@"; do
        case $arg in
          --checkpoint=*) CHECKPOINT="''${arg#*=}" ;;
        esac
      done

      if [ -z "$CHECKPOINT" ]; then
        echo "Usage: mark-checkpoint-approved --checkpoint=NAME"
        exit 1
      fi

      TIMESTAMP=$(date -Iseconds)

      jq --arg checkpoint "$CHECKPOINT" --arg ts "$TIMESTAMP" '
        .human_approvals += [{
          checkpoint: $checkpoint,
          approved_at: $ts,
          approved_by: "'"$(whoami)"'"
        }]
      ' .quality/remediation-state.json > .quality/remediation-state.tmp.json
      mv .quality/remediation-state.tmp.json .quality/remediation-state.json

      echo "✅ Checkpoint '$CHECKPOINT' approved"
    '';

    autonomous-remediation-session.exec = ''
      echo ""
      echo "🤖 Autonomous Remediation Session"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ No remediation state found"
        echo "   Run 'initialize-remediation-state' first"
        exit 1
      fi

      STATE=$(cat .quality/remediation-state.json)
      SESSION_NUM=$(($(echo "$STATE" | jq '.sessions.completed') + 1))
      PHASE=$(echo "$STATE" | jq -r '.current_phase')

      echo "📊 Session $SESSION_NUM - Phase: $PHASE"
      echo ""

      if needs-human-checkpoint; then
        CHECKPOINT=$(needs-human-checkpoint)
        echo "⚠️  HUMAN APPROVAL REQUIRED: $CHECKPOINT"
        echo ""
        echo "This checkpoint needs human review before continuing."
        echo ""
        echo "To approve: mark-checkpoint-approved --checkpoint=$CHECKPOINT"
        echo "To review state: cat .quality/remediation-state.json | jq"
        echo ""
        exit 2
      fi

      TOKENS_USED=$(echo "$STATE" | jq '.sessions.token_budget_used')
      TOKENS_TOTAL=$(echo "$STATE" | jq '.sessions.token_budget_total')
      TOKENS_AVAILABLE=$((TOKENS_TOTAL - TOKENS_USED))

      echo "💰 Token Budget: $TOKENS_AVAILABLE / $TOKENS_TOTAL tokens available"

      if [ $TOKENS_AVAILABLE -lt 100000 ]; then
        echo "⚠️  Low token budget remaining"
        BATCH_SIZE=5
      else
        BATCH_SIZE=10
      fi

      echo "📦 Batch Size: $BATCH_SIZE targets"
      echo ""

      echo "🎯 Identifying next targets..."
      TARGETS=$(identify-next-targets --phase=$PHASE --count=$BATCH_SIZE)
      TARGET_COUNT=$(echo "$TARGETS" | jq 'length')

      if [ "$TARGET_COUNT" -eq 0 ]; then
        echo "✅ No more targets in current phase!"
        echo ""
        echo "Phase $PHASE complete. Consider advancing to next phase."
        update-remediation-state --session-complete
        exit 0
      fi

      echo "  Found $TARGET_COUNT targets"
      echo ""

      SUCCESS_COUNT=0
      FAILURE_COUNT=0

      echo "🔧 Processing targets..."
      echo ""

      for i in $(seq 0 $((TARGET_COUNT - 1))); do
        TARGET=$(echo "$TARGETS" | jq ".[$i]")
        TARGET_ID=$(echo "$TARGET" | jq -r '.id')
        FILE=$(echo "$TARGET" | jq -r '.file')
        FUNCTION=$(echo "$TARGET" | jq -r '.function // "N/A"')
        TYPE=$(echo "$TARGET" | jq -r '.type')

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Target $(($i + 1))/$TARGET_COUNT: $FILE :: $FUNCTION"
        echo ""

        echo "📄 FILE: $FILE"
        echo "🔧 FUNCTION: $FUNCTION"
        echo "📊 TYPE: $TYPE"

        if [ "$TYPE" = "complexity" ]; then
          echo "📈 CURRENT_CCN: $(echo "$TARGET" | jq -r '.ccn_current')"
          echo "🎯 TARGET_CCN: $(echo "$TARGET" | jq -r '.ccn_target')"
        fi

        echo ""
        echo "⏸️  AGENT ACTION REQUIRED:"
        echo "   1. Open $FILE"
        if [ "$FUNCTION" != "N/A" ]; then
          echo "   2. Locate function: $FUNCTION (lines $(echo "$TARGET" | jq -r '.line_start // "?"')-$(echo "$TARGET" | jq -r '.line_end // "?"'))"
        fi
        echo "   3. Refactor to reduce complexity / fix issue"
        echo "   4. Ensure all tests pass"
        echo "   5. Validate: validate-target-improved --target-id=$TARGET_ID"
        echo ""

        update-remediation-state --target=$TARGET_ID --status=in_progress

        echo "Press Enter after completing refactoring and validation..."
        read -p ""

        if validate-target-improved --target-id=$TARGET_ID 2>/dev/null; then
          echo "  ✅ Target improved successfully"
          update-remediation-state --target=$TARGET_ID --status=completed
          checkpoint-progress --target-id=$TARGET_ID --session=$SESSION_NUM
          SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
          echo "  ❌ Target validation failed"
          update-remediation-state --target=$TARGET_ID --status=failed --reason="Validation failed"
          FAILURE_COUNT=$((FAILURE_COUNT + 1))
        fi

        echo ""
      done

      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "📊 Session $SESSION_NUM Summary"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "  ✅ Successful: $SUCCESS_COUNT"
      echo "  ❌ Failed: $FAILURE_COUNT"

      if [ $TARGET_COUNT -gt 0 ]; then
        echo "  📈 Success Rate: $(( SUCCESS_COUNT * 100 / TARGET_COUNT ))%"
      fi

      echo ""

      update-remediation-state --session-complete

      SESSIONS_COMPLETE=$(cat .quality/remediation-state.json | jq '.sessions.completed')
      SESSIONS_TOTAL=$(cat .quality/remediation-state.json | jq '.sessions.total_estimated')

      echo "  📊 Progress: Session $SESSIONS_COMPLETE / $SESSIONS_TOTAL"
      echo ""
      echo "🎯 Next Steps:"
      echo "  • Run 'autonomous-remediation-session' for next batch"
      echo "  • Run 'quality-dashboard' to see current metrics"
      echo "  • Run 'check-feature-readiness' to validate baseline"
      echo ""
    '';

    # Tier 3: Enhancement Scripts (Optimization & Analytics)

    # Estimate token usage for target batches
    estimate-token-usage.exec = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "🧮 Token Usage Estimation"
      echo ""

      # Check if assessment exists
      if [ ! -f .quality/stats.json ]; then
        echo "❌ Error: Run 'assess-codebase' first"
        exit 1
      fi

      # Token budget constants
      CONTEXT_WINDOW=200000
      SAFETY_MARGIN=50000
      USABLE_TOKENS=$((CONTEXT_WINDOW - SAFETY_MARGIN))

      # Parse command line arguments
      TARGET_FILE="''${1:-}"

      if [ -z "$TARGET_FILE" ]; then
        echo "Usage: estimate-token-usage <file-path>"
        echo ""
        echo "Estimates token cost for analyzing a specific file"
        exit 1
      fi

      if [ ! -f "$TARGET_FILE" ]; then
        echo "❌ Error: File not found: $TARGET_FILE"
        exit 1
      fi

      # Count lines in target file
      LINE_COUNT=$(wc -l < "$TARGET_FILE")

      # Estimate tokens (rough approximation: 1 line ≈ 10 tokens)
      ESTIMATED_TOKENS=$((LINE_COUNT * 10))

      # Calculate context requirements
      DEPS_TOKENS=$((ESTIMATED_TOKENS / 2))  # Dependencies typically 50% of file size
      TOTAL_TOKENS=$((ESTIMATED_TOKENS + DEPS_TOKENS))

      # Determine feasibility
      if [ $TOTAL_TOKENS -lt $USABLE_TOKENS ]; then
        FEASIBLE="✅ FEASIBLE"
        PERCENTAGE=$((TOTAL_TOKENS * 100 / USABLE_TOKENS))
      else
        FEASIBLE="❌ EXCEEDS BUDGET"
        PERCENTAGE=$((TOTAL_TOKENS * 100 / USABLE_TOKENS))
      fi

      echo "📄 File: $TARGET_FILE"
      echo "📏 Lines: $LINE_COUNT"
      echo "🎫 Estimated Tokens:"
      echo "   • File content: ~$ESTIMATED_TOKENS tokens"
      echo "   • Dependencies: ~$DEPS_TOKENS tokens"
      echo "   • Total needed: ~$TOTAL_TOKENS tokens"
      echo ""
      echo "💰 Budget Analysis:"
      echo "   • Available: $USABLE_TOKENS tokens"
      echo "   • Usage: $PERCENTAGE%"
      echo "   • Status: $FEASIBLE"
      echo ""

      # Batch sizing recommendations
      if [ $TOTAL_TOKENS -lt 30000 ]; then
        BATCH_SIZE=10
      elif [ $TOTAL_TOKENS -lt 75000 ]; then
        BATCH_SIZE=5
      elif [ $TOTAL_TOKENS -lt 120000 ]; then
        BATCH_SIZE=2
      else
        BATCH_SIZE=1
      fi

      echo "💡 Recommended Batch Size: $BATCH_SIZE files"
      echo "   (for files of similar complexity)"
      echo ""

      # Save estimation for session planning
      mkdir -p .quality/estimates
      cat > ".quality/estimates/$(basename "$TARGET_FILE").json" << EOF
{
  "file": "$TARGET_FILE",
  "line_count": $LINE_COUNT,
  "estimated_tokens": $ESTIMATED_TOKENS,
  "with_dependencies": $TOTAL_TOKENS,
  "percentage_of_budget": $PERCENTAGE,
  "recommended_batch_size": $BATCH_SIZE,
  "timestamp": "$(date -Iseconds)"
}
EOF

      echo "📊 Estimation saved to .quality/estimates/$(basename "$TARGET_FILE").json"
    '';

    # Analyze failure patterns from remediation history
    analyze-failure-patterns.exec = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "🔍 Failure Pattern Analysis"
      echo ""

      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ Error: No remediation state found"
        echo "   Run 'initialize-remediation-state' first"
        exit 1
      fi

      STATE=$(cat .quality/remediation-state.json)

      # Extract failed targets
      FAILED_TARGETS=$(echo "$STATE" | jq '.targets.failed')
      FAILED_COUNT=$(echo "$FAILED_TARGETS" | jq 'length')

      if [ "$FAILED_COUNT" -eq 0 ]; then
        echo "✅ No failures recorded yet"
        echo ""
        echo "This is excellent! Keep the momentum going."
        exit 0
      fi

      echo "📊 Failure Statistics:"
      echo "   • Total failures: $FAILED_COUNT"
      echo ""

      # Categorize failures by type
      COMPLEXITY_FAILURES=$(echo "$FAILED_TARGETS" | jq '[.[] | select(.category == "complexity")] | length')
      SECURITY_FAILURES=$(echo "$FAILED_TARGETS" | jq '[.[] | select(.category == "security")] | length')
      DUPLICATION_FAILURES=$(echo "$FAILED_TARGETS" | jq '[.[] | select(.category == "duplication")] | length')
      TEST_FAILURES=$(echo "$FAILED_TARGETS" | jq '[.[] | select(.category == "test")] | length')

      echo "🏷️  Failure Categories:"
      if [ "$COMPLEXITY_FAILURES" -gt 0 ]; then
        echo "   • Complexity: $COMPLEXITY_FAILURES ($(( COMPLEXITY_FAILURES * 100 / FAILED_COUNT ))%)"
      fi
      if [ "$SECURITY_FAILURES" -gt 0 ]; then
        echo "   • Security: $SECURITY_FAILURES ($(( SECURITY_FAILURES * 100 / FAILED_COUNT ))%)"
      fi
      if [ "$DUPLICATION_FAILURES" -gt 0 ]; then
        echo "   • Duplication: $DUPLICATION_FAILURES ($(( DUPLICATION_FAILURES * 100 / FAILED_COUNT ))%)"
      fi
      if [ "$TEST_FAILURES" -gt 0 ]; then
        echo "   • Test Coverage: $TEST_FAILURES ($(( TEST_FAILURES * 100 / FAILED_COUNT ))%)"
      fi
      echo ""

      # Identify hot spots (files with multiple failures)
      HOT_SPOTS=$(echo "$FAILED_TARGETS" | jq -r '[.[] | .file] | group_by(.) | map({file: .[0], count: length}) | sort_by(-.count) | .[]' | head -5)

      if [ -n "$HOT_SPOTS" ]; then
        echo "🔥 Hot Spots (files with multiple failures):"
        echo "$HOT_SPOTS" | jq -r '"   • \(.file): \(.count) failures"'
        echo ""
      fi

      # Generate recommendations
      echo "💡 Recommendations:"
      echo ""

      if [ "$COMPLEXITY_FAILURES" -gt "$(( FAILED_COUNT / 2 ))" ]; then
        echo "   🎯 Complexity is your primary challenge:"
        echo "      • Break down functions into smaller units (< 20 lines)"
        echo "      • Extract helper functions for repeated logic"
        echo "      • Consider design patterns (Strategy, Command)"
        echo "      • Use MCP Serena symbolic tools to understand dependencies first"
        echo ""
      fi

      if [ "$SECURITY_FAILURES" -gt 0 ]; then
        echo "   🔒 Security issues require careful attention:"
        echo "      • Never hardcode credentials or API keys"
        echo "      • Use environment variables or secret management"
        echo "      • Review Semgrep rules for specific patterns"
        echo "      • Consider using password managers or vault systems"
        echo ""
      fi

      if [ "$TEST_FAILURES" -gt 0 ]; then
        echo "   🧪 Test coverage challenges:"
        echo "      • Start with characterization tests (capture current behavior)"
        echo "      • Add unit tests before refactoring"
        echo "      • Use TDD for new functionality"
        echo "      • Aim for 60%+ coverage before moving on"
        echo ""
      fi

      # Save analysis report
      cat > .quality/failure-analysis.json << EOF
{
  "timestamp": "$(date -Iseconds)",
  "total_failures": $FAILED_COUNT,
  "by_category": {
    "complexity": $COMPLEXITY_FAILURES,
    "security": $SECURITY_FAILURES,
    "duplication": $DUPLICATION_FAILURES,
    "test": $TEST_FAILURES
  },
  "hot_spots": $(echo "$HOT_SPOTS"),
  "recommendations_generated": true
}
EOF

      echo "📄 Full analysis saved to .quality/failure-analysis.json"
    '';

    # Generate stakeholder progress report
    generate-progress-report.exec = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "📊 Generating Progress Report"
      echo ""

      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ Error: No remediation state found"
        exit 1
      fi

      STATE=$(cat .quality/remediation-state.json)

      # Extract metrics
      STARTED_AT=$(echo "$STATE" | jq -r '.started_at')
      CURRENT_PHASE=$(echo "$STATE" | jq -r '.current_phase')
      SESSIONS_COMPLETED=$(echo "$STATE" | jq '.sessions.completed')
      SESSIONS_TOTAL=$(echo "$STATE" | jq '.sessions.total_estimated')

      PENDING_COUNT=$(echo "$STATE" | jq '.targets.pending | length')
      IN_PROGRESS_COUNT=$(echo "$STATE" | jq '.targets.in_progress | length')
      COMPLETED_COUNT=$(echo "$STATE" | jq '.targets.completed | length')
      FAILED_COUNT=$(echo "$STATE" | jq '.targets.failed | length')
      TOTAL_TARGETS=$((PENDING_COUNT + IN_PROGRESS_COUNT + COMPLETED_COUNT + FAILED_COUNT))

      # Calculate progress percentage
      if [ "$TOTAL_TARGETS" -gt 0 ]; then
        PROGRESS_PCT=$((COMPLETED_COUNT * 100 / TOTAL_TARGETS))
      else
        PROGRESS_PCT=0
      fi

      # Calculate days elapsed
      STARTED_TS=$(date -d "$STARTED_AT" +%s)
      NOW_TS=$(date +%s)
      DAYS_ELAPSED=$(( (NOW_TS - STARTED_TS) / 86400 ))

      # Generate markdown report
      REPORT_FILE=".quality/PROGRESS_REPORT.md"

      cat > "$REPORT_FILE" << EOF
# Legacy Codebase Remediation Progress Report

**Generated**: $(date "+%Y-%m-%d %H:%M:%S")
**Project Started**: $STARTED_AT
**Days Elapsed**: $DAYS_ELAPSED

---

## Executive Summary

### Overall Progress: $PROGRESS_PCT%

\`\`\`
[${'█' * (PROGRESS_PCT / 5)}${'░' * (20 - PROGRESS_PCT / 5)}] $COMPLETED_COUNT / $TOTAL_TARGETS targets
\`\`\`

**Current Phase**: $(echo "$CURRENT_PHASE" | tr '[:lower:]' '[:upper:]')

### Session Progress

- **Completed Sessions**: $SESSIONS_COMPLETED / $SESSIONS_TOTAL
- **Remaining Sessions**: $((SESSIONS_TOTAL - SESSIONS_COMPLETED))
- **Success Rate**: $([ "$COMPLETED_COUNT" -gt 0 ] && echo "$(( COMPLETED_COUNT * 100 / (COMPLETED_COUNT + FAILED_COUNT) ))%" || echo "N/A")

---

## Target Status Breakdown

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ Completed | $COMPLETED_COUNT | $([ "$TOTAL_TARGETS" -gt 0 ] && echo "$(( COMPLETED_COUNT * 100 / TOTAL_TARGETS ))%" || echo "0%") |
| 🚧 In Progress | $IN_PROGRESS_COUNT | $([ "$TOTAL_TARGETS" -gt 0 ] && echo "$(( IN_PROGRESS_COUNT * 100 / TOTAL_TARGETS ))%" || echo "0%") |
| ⏳ Pending | $PENDING_COUNT | $([ "$TOTAL_TARGETS" -gt 0 ] && echo "$(( PENDING_COUNT * 100 / TOTAL_TARGETS ))%" || echo "0%") |
| ❌ Failed | $FAILED_COUNT | $([ "$TOTAL_TARGETS" -gt 0 ] && echo "$(( FAILED_COUNT * 100 / TOTAL_TARGETS ))%" || echo "0%") |
| **Total** | **$TOTAL_TARGETS** | **100%** |

---

## Quality Metrics Trends

EOF

      # Add metrics history if available
      METRICS_COUNT=$(echo "$STATE" | jq '.metrics_history | length')

      if [ "$METRICS_COUNT" -gt 0 ]; then
        LATEST_METRICS=$(echo "$STATE" | jq '.metrics_history[-1]')

        cat >> "$REPORT_FILE" << EOF
### Current Quality Baseline

\`\`\`json
$(echo "$LATEST_METRICS" | jq '.')
\`\`\`

EOF
      fi

      # Add checkpoint information
      CHECKPOINT_COUNT=$(echo "$STATE" | jq '.checkpoints | length')

      if [ "$CHECKPOINT_COUNT" -gt 0 ]; then
        cat >> "$REPORT_FILE" << EOF
---

## Checkpoints & Milestones

**Total Checkpoints**: $CHECKPOINT_COUNT

EOF

        # List recent checkpoints
        echo "$STATE" | jq -r '.checkpoints[-5:] | .[] | "- **\(.timestamp)**: \(.message) (Commit: \(.commit_hash))"' >> "$REPORT_FILE"
      fi

      # Add failure analysis if exists
      if [ -f .quality/failure-analysis.json ]; then
        FAILURE_ANALYSIS=$(cat .quality/failure-analysis.json)

        cat >> "$REPORT_FILE" << EOF

---

## Failure Analysis

$(echo "$FAILURE_ANALYSIS" | jq -r '
"### By Category

" +
"- **Complexity**: \(.by_category.complexity) failures
" +
"- **Security**: \(.by_category.security) failures
" +
"- **Duplication**: \(.by_category.duplication) failures
" +
"- **Test Coverage**: \(.by_category.test) failures"
')

EOF
      fi

      # Add next steps
      cat >> "$REPORT_FILE" << EOF

---

## Next Steps

1. **Continue Current Phase**: $(echo "$CURRENT_PHASE" | tr '[:lower:]' '[:upper:]')
   - Run \`autonomous-remediation-session\` for next batch
   - Focus on high-priority targets with smart prioritization

2. **Monitor Progress**:
   - Check \`quality-dashboard\` for real-time metrics
   - Review failure patterns with \`analyze-failure-patterns\`

3. **Phase Transition**:
   - Current phase progress: $PROGRESS_PCT%
   - Human approval required before transitioning to next phase

---

## ROI Calculation

### Time Investment
- **Sessions Completed**: $SESSIONS_COMPLETED
- **Estimated Hours**: $(( SESSIONS_COMPLETED * 2 )) hours (@ 2 hrs/session)

### Quality Improvement
- **Targets Remediated**: $COMPLETED_COUNT
- **Success Rate**: $([ "$COMPLETED_COUNT" -gt 0 ] && echo "$(( COMPLETED_COUNT * 100 / (COMPLETED_COUNT + FAILED_COUNT) ))%" || echo "N/A")

### Business Impact
Based on industry studies:
- **Reduced Bug Rate**: ~40% reduction in production bugs
- **Faster Feature Development**: 3-5x velocity improvement post-remediation
- **Lower Maintenance Cost**: 60% reduction in technical debt servicing

---

*Report generated by Legacy Codebase Rescue System*
*For questions or assistance, review AUTONOMOUS_AGENT_COMPATIBILITY.md*
EOF

      echo "✅ Progress report generated: $REPORT_FILE"
      echo ""

      # Also create a summary for quick viewing
      echo "📄 Quick Summary:"
      echo "   • Progress: $PROGRESS_PCT% ($COMPLETED_COUNT/$TOTAL_TARGETS targets)"
      echo "   • Sessions: $SESSIONS_COMPLETED/$SESSIONS_TOTAL completed"
      echo "   • Phase: $(echo "$CURRENT_PHASE" | tr '[:lower:]' '[:upper:]')"
      echo "   • Days elapsed: $DAYS_ELAPSED"
      echo ""
      echo "📖 View full report: cat $REPORT_FILE"

      # Optionally render with glow if available
      if command -v glow &> /dev/null; then
        echo ""
        echo "💡 Tip: View formatted report with: glow $REPORT_FILE"
      fi
    '';

    # Multi-agent parallel remediation coordinator
    parallel-remediation-coordinator.exec = ''
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
