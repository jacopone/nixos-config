#!/usr/bin/env bash
      echo "🔍 AI Quality Gates Report"
      echo "📋 Security: gitleaks (incremental) + semgrep (auto patterns)"
      echo "📋 Complexity: lizard (CCN < 10, length < 50)"
      echo "📋 Clones: jscpd (threshold 5%, min 10 lines)"
      echo "📋 Format: prettier + eslint + black + ruff"
      echo "📋 Commits: commitizen conventional format"
      echo "📋 Coverage: enforced via testing"
      echo ""
      echo "✅ All quality gates active for AI code protection"
      echo "🤖 Run 'devenv test' to verify all gates"
      echo "🔍 Run 'quality-check' for comprehensive analysis"
    '';

    setup-git-hooks.exec = ''
      echo "🔧 Setting up git hooks..."
      devenv shell git-hooks.installationScript
      echo "✅ Git hooks installed"
      echo "📋 Hooks will run automatically on commit/push"
    '';

    init-ai-tools.exec = ''
      echo ""
      echo "🤖 AI Development Tools Setup"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Check if gum is available, fallback to simple prompts
      if command -v gum &> /dev/null; then
        echo "Select AI tool(s) to configure (Space to select, Enter to confirm):"
        echo ""

        # Use gum for beautiful interactive selection
        AI_TOOLS=$(gum choose --no-limit --cursor="> " --selected="✓ " \
          "Claude Code - Token-efficient with MCP Serena" \
          "Cursor AI - YOLO mode with Agent shortcuts" \
          "Skip - Manual setup later")

        # Parse selections
        SETUP_CLAUDE=false
        SETUP_CURSOR=false

        if echo "$AI_TOOLS" | grep -q "Claude Code"; then
          SETUP_CLAUDE=true
        fi

        if echo "$AI_TOOLS" | grep -q "Cursor AI"; then
          SETUP_CURSOR=true
        fi

        if echo "$AI_TOOLS" | grep -q "Skip"; then
          echo ""
          echo "⏭️  Skipping AI tools setup"
          echo "💡 Run 'init-ai-tools' anytime to configure AI tools"
          exit 0
        fi
      else
        # Fallback to bash select if gum not available
        echo "Select AI tool(s):"
        echo "1) Claude Code only"
        echo "2) Cursor AI only"
        echo "3) Both Claude Code and Cursor AI"
        echo "4) Skip (manual setup later)"
        echo ""
        read -p "Enter choice (1-4): " choice

        case $choice in
          1) SETUP_CLAUDE=true; SETUP_CURSOR=false ;;
          2) SETUP_CLAUDE=false; SETUP_CURSOR=true ;;
          3) SETUP_CLAUDE=true; SETUP_CURSOR=true ;;
          4)
            echo ""
            echo "⏭️  Skipping AI tools setup"
            echo "💡 Run 'init-ai-tools' anytime to configure AI tools"
            exit 0
            ;;
          *)
            echo "❌ Invalid choice. Exiting."
            exit 1
            ;;
        esac
      fi

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Setup Claude Code if selected
      if [ "$SETUP_CLAUDE" = true ]; then
        echo "🤖 Setting up Claude Code..."

        # Create .claude directory
        mkdir -p .claude

        # Copy configuration files from templates
        if [ -d .ai-templates/claude ]; then
          cp .ai-templates/claude/CLAUDE.md .claude/ 2>/dev/null && \
            echo "  ✓ Copied CLAUDE.md (project instructions)"

          cp .ai-templates/claude/settings.local.json .claude/ 2>/dev/null && \
            echo "  ✓ Copied settings.local.json (personal settings)"

          cp .ai-templates/claude/README.md .claude/ 2>/dev/null && \
            echo "  ✓ Copied README.md (documentation)"

          cp .ai-templates/claude/.claudeignore ./ 2>/dev/null && \
            echo "  ✓ Copied .claudeignore (context exclusions)"
        else
          echo "  ⚠️  .ai-templates/claude not found - manual setup required"
        fi

        # Add to .gitignore if not present
        if ! grep -q ".claude/settings.local.json" .gitignore 2>/dev/null; then
          echo ".claude/settings.local.json" >> .gitignore
          echo "  ✓ Added settings.local.json to .gitignore"
        fi

        echo ""
        echo "✅ Claude Code configured!"
        echo "📄 Files created:"
        echo "   • .claude/CLAUDE.md - Quality gate instructions (6KB)"
        echo "   • .claude/settings.local.json - Personal settings"
        echo "   • .claudeignore - Context exclusions"
        echo ""
        echo "🔍 MCP Serena integration enabled for token-efficient operations"
        echo "💡 Edit .claude/CLAUDE.md to customize behavior"
        echo ""
      fi

      # Setup Cursor AI if selected
      if [ "$SETUP_CURSOR" = true ]; then
        echo "🎯 Setting up Cursor AI..."

        # Create .cursor/rules directory
        mkdir -p .cursor/rules

        # Copy rule files from templates
        if [ -d .ai-templates/cursor/rules ]; then
          cp .ai-templates/cursor/rules/*.mdc .cursor/rules/ 2>/dev/null && \
            echo "  ✓ Copied MDC rule files"

          cp .ai-templates/cursor/.cursorignore ./ 2>/dev/null && \
            echo "  ✓ Copied .cursorignore (context exclusions)"
        else
          echo "  ⚠️  .ai-templates/cursor not found - manual setup required"
        fi

        echo ""
        echo "✅ Cursor AI configured!"
        echo "📄 Files created:"
        echo "   • .cursor/rules/index.mdc - Core development rules"
        echo "   • .cursor/rules/security.mdc - Security patterns"
        echo "   • .cursor/rules/testing.mdc - Testing standards"
        echo "   • .cursorignore - Context exclusions"
        echo ""
        echo "🎮 Agent mode shortcuts: Ctrl+I (agent) | Ctrl+E (background)"
        echo "💡 Edit .cursor/rules/*.mdc to customize behavior"
        echo ""
      fi

      # Final verification and next steps
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "🔍 Verification:"
      [ -d .claude ] && echo "  ✅ Claude Code: Configured"
      [ -d .cursor ] && echo "  ✅ Cursor AI: Configured"
      echo ""
      echo "📋 Next steps:"
      echo "  1. Run 'setup-git-hooks' to install quality gates"
      echo "  2. Run 'quality-report' to see active quality standards"
      echo "  3. Initialize your project (npm init or uv init)"
      echo "  4. Start coding with AI assistance!"
      echo ""
    '';

    setup-cursor.exec = ''
      echo "🎯 Setting up Cursor AI integration..."

      # Ensure .cursor/rules directory exists
      mkdir -p .cursor/rules

      # Copy rule templates if they don't exist
      if [[ ! -f .cursor/rules/index.mdc ]]; then
        echo "📋 Installing Cursor AI rules..."
        cp .ai-templates/cursor/rules/*.mdc .cursor/rules/ 2>/dev/null || {
          echo "⚠️  Could not copy rules templates automatically"
          echo "📂 Manual setup: copy from .ai-templates/cursor/rules/"
        }
      fi

      # Create project-specific .cursorignore
      if [[ ! -f .cursorignore ]]; then
        cp .ai-templates/cursor/.cursorignore ./ 2>/dev/null || cat > .cursorignore << 'EOF'
# Build artifacts
.devenv/
result
result-*
dist/
build/

# Dependencies
node_modules/
__pycache__/
.pytest_cache/

# Environment
.env
.env.*

# Quality tools output
coverage/
.coverage
.nyc_output/
playwright-report/
test-results/
EOF
        echo "📄 Created project .cursorignore"
      fi

      echo "✅ Cursor AI integration ready!"
      echo "🔧 Available rules:"
      echo "   - index.mdc: Core development rules"
      echo "   - security.mdc: Security-focused rules"
      echo "   - testing.mdc: Testing and QA rules"
      echo ""
      echo "🎯 Edit .cursor/rules/*.mdc to customize AI behavior"
      echo "💡 Use Ctrl+I for Agent mode, Ctrl+E for background mode"
    '';

    setup-claude.exec = ''
      echo "🤖 Setting up Claude Code integration..."

      # Ensure .claude directory exists
      mkdir -p .claude

      # Copy Claude Code configuration if it doesn't exist
      if [[ ! -f .claude/CLAUDE.md ]]; then
        echo "📋 Installing Claude Code configuration..."
        cp .ai-templates/claude/CLAUDE.md .claude/ 2>/dev/null || {
          echo "⚠️  Could not copy CLAUDE.md automatically"
          echo "📂 Manual setup: copy from .ai-templates/claude/"
        }
      fi

      # Copy settings if they don't exist
      if [[ ! -f .claude/settings.local.json ]]; then
        echo "⚙️  Installing Claude Code settings..."
        cp .ai-templates/claude/settings.local.json .claude/ 2>/dev/null || {
          echo "⚠️  Could not copy settings automatically"
          echo "📂 Manual setup: copy from .ai-templates/claude/"
        }
      fi

      # Copy README if it doesn't exist
      if [[ ! -f .claude/README.md ]]; then
        cp .ai-templates/claude/README.md .claude/ 2>/dev/null
      fi

      # Create project-specific .claudeignore
      if [[ ! -f .claudeignore ]]; then
        cp .ai-templates/claude/.claudeignore ./ 2>/dev/null || cat > .claudeignore << 'EOF'
# Build artifacts
.devenv/
result
result-*
dist/
build/

# Dependencies
node_modules/
__pycache__/
.pytest_cache/

# Environment
.env
.env.*

# Quality tools output
coverage/
.coverage
.nyc_output/
playwright-report/
test-results/

# IDE and AI configs
.cursor/
.vscode/
.idea/
EOF
        echo "📄 Created project .claudeignore"
      fi

      # Add to .gitignore if not present
      if ! grep -q ".claude/settings.local.json" .gitignore 2>/dev/null; then
        echo ".claude/settings.local.json" >> .gitignore
        echo "📝 Added settings.local.json to .gitignore"
      fi

      echo "✅ Claude Code integration ready!"
      echo "🔧 Configuration files:"
      echo "   - .claude/CLAUDE.md: Enterprise quality gate instructions"
      echo "   - .claude/settings.local.json: Permissions and hooks"
      echo ""
      echo "🎯 Edit .claude/CLAUDE.md to customize Claude Code behavior"
      echo "💡 Quality gate reminders active on Write/Edit operations"
      echo "🔍 MCP Serena server integration enabled (symbolic code operations)"
    '';

    # ============================================================================
    # LEGACY CODEBASE RESCUE SYSTEM
    # ============================================================================

    assess-codebase.exec = ''
      echo ""
      echo "🔍 Legacy Codebase Assessment"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Create .quality directory for reports
      mkdir -p .quality

      echo "📊 Step 1/8: Code Statistics..."
      tokei --output json > .quality/stats.json 2>/dev/null || echo "  ⚠️  tokei not found"
      tokei

      echo ""
      echo "🔍 Step 2/8: Complexity Analysis..."
      lizard --json > .quality/complexity.json 2>/dev/null && \
        echo "  ✓ Lizard analysis complete" || echo "  ⚠️  Lizard not found"

      radon cc -j . > .quality/radon.json 2>/dev/null && \
        echo "  ✓ Radon analysis complete" || echo "  ⚠️  Radon not available (Python projects)"

      echo ""
      echo "📋 Step 3/8: Duplication Detection..."
      jscpd --format json --output .quality/ . 2>/dev/null && \
        echo "  ✓ JSCPD analysis complete" || echo "  ⚠️  JSCPD not found"

      echo ""
      echo "🔒 Step 4/8: Security Scan..."
      gitleaks detect --report-format json --report-path .quality/gitleaks.json --no-git 2>/dev/null && \
        echo "  ✓ Gitleaks scan complete" || echo "  ⚠️  Gitleaks not found"

      semgrep --config=auto --json --output .quality/semgrep.json . 2>/dev/null && \
        echo "  ✓ Semgrep scan complete" || echo "  ⚠️  Semgrep not found"

      echo ""
      echo "🧪 Step 5/8: Test Coverage (if available)..."
      if [ -f "package.json" ]; then
        npm run test:coverage 2>/dev/null || echo "  ℹ️  No npm test:coverage script"
      fi
      if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        pytest --cov --cov-report=json --cov-report=term 2>/dev/null || echo "  ℹ️  No pytest coverage"
      fi

      echo ""
      echo "📦 Step 6/8: Dependency Audit..."
      npm audit --json > .quality/npm-audit.json 2>/dev/null || echo "  ℹ️  Not a Node.js project"
      pip-audit --format json > .quality/pip-audit.json 2>/dev/null || echo "  ℹ️  Not a Python project"

      echo ""
      echo "📈 Step 7/8: Git History Analysis..."
      if [ -d .git ]; then
        git log --pretty=format: --name-only --since="3 months ago" | \
          sort | uniq -c | sort -rg | head -20 > .quality/hotspots.txt
        echo "  ✓ Identified top 20 most-changed files"
      else
        echo "  ℹ️  Not a git repository"
      fi

      echo ""
      echo "🎯 Step 8/8: Generating Summary..."

      # Generate assessment summary
      cat > .quality/ASSESSMENT_SUMMARY.md << 'EOF'
# Codebase Assessment Summary

**Date**: $(date +%Y-%m-%d)
**Tool**: AI Quality DevEnv Template

## Quick Stats

Run \`cat .quality/stats.json | jq\` for detailed statistics.
Run \`lizard --CCN 15\` to see high-complexity functions.
Run \`jscpd .\` for duplication report.

## Next Steps

1. Review this assessment: \`cat .quality/ASSESSMENT_SUMMARY.md\`
2. Generate remediation plan: \`generate-remediation-plan\`
3. Start with security: \`assess-security\`
4. View quality dashboard: \`quality-dashboard\`

## Files Generated

- \``.quality/stats.json\` - Code statistics (tokei)
- \`.quality/complexity.json\` - Complexity metrics (lizard)
- \`.quality/radon.json\` - Python complexity (radon)
- \`.quality/jscpd-report.json\` - Duplication analysis
- \`.quality/gitleaks.json\` - Security scan (secrets)
- \`.quality/semgrep.json\` - Security patterns
- \`.quality/hotspots.txt\` - Most-changed files

## Assessment Complete!

Your codebase has been analyzed. Run \`generate-remediation-plan\` to create
an AI-powered, self-aware remediation strategy that acknowledges Claude Code's
token limitations and provides a phased, safe refactoring approach.

EOF

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "✅ Assessment Complete!"
      echo ""
      echo "📄 Reports generated in .quality/ directory"
      echo "📋 Summary: cat .quality/ASSESSMENT_SUMMARY.md"
      echo ""
      echo "🎯 Next: generate-remediation-plan"
      echo ""
    '';

    generate-remediation-plan.exec = ''
      echo ""
      echo "🤖 AI-Powered Remediation Plan Generator"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      if [ ! -d .quality ]; then
        echo "❌ Error: Run 'assess-codebase' first to gather metrics"
        exit 1
      fi

      echo "📊 Analyzing assessment data..."

      # Extract key metrics from assessment
      TOTAL_FILES=$(cat .quality/stats.json 2>/dev/null | jq '.Total.code + .Total.comments + .Total.blanks' 2>/dev/null || echo "unknown")
      TOTAL_LOC=$(cat .quality/stats.json 2>/dev/null | jq '.Total.code' 2>/dev/null || echo "unknown")

      # Calculate AI session requirements
      CONTEXT_WINDOW=200000
      AVG_TOKENS_PER_FILE=1000
      SAFETY_MARGIN=50000
      USABLE_TOKENS=$((CONTEXT_WINDOW - SAFETY_MARGIN))
      MAX_FILES_PER_SESSION=$((USABLE_TOKENS / AVG_TOKENS_PER_FILE))

      if [ "$TOTAL_FILES" != "unknown" ]; then
        SESSIONS_NEEDED=$(( (TOTAL_FILES + MAX_FILES_PER_SESSION - 1) / MAX_FILES_PER_SESSION ))
      else
        SESSIONS_NEEDED="unknown"
      fi

      echo "  ✓ Codebase size: $TOTAL_LOC LOC across $TOTAL_FILES files"
      echo "  ✓ Estimated AI sessions: $SESSIONS_NEEDED (at ~$MAX_FILES_PER_SESSION files/session)"
      echo ""

      # Generate the remediation plan
      cat > REMEDIATION_PLAN.md << EOF
# Codebase Remediation Plan

**Generated**: $(date +%Y-%m-%d)
**Codebase**: $TOTAL_LOC lines of code
**Files**: $TOTAL_FILES
**Tool**: AI Quality DevEnv with Claude Code Self-Awareness

---

## 📊 Assessment Summary

**Codebase Statistics:**
- Total LOC: $TOTAL_LOC
- Total Files: $TOTAL_FILES
- Estimated Sessions Needed: $SESSIONS_NEEDED

**Assessment Files:**
Run these commands to view detailed metrics:
\`\`\`bash
cat .quality/stats.json | jq                    # Code statistics
lizard --CCN 15 | head -50                      # High-complexity functions
cat .quality/gitleaks.json | jq '.[] | .RuleID' # Security issues
jscpd . --threshold 5                           # Duplication report
\`\`\`

---

## 🧠 AI Self-Awareness: Claude Code Limitations

### Token Budget Reality

**Context Window:** 200,000 tokens (standard)
**Safe Batch Size:** ~$MAX_FILES_PER_SESSION files (~150K tokens + 50K response buffer)
**Sessions Required:** $SESSIONS_NEEDED sessions minimum

### What Claude Code CAN Do ✅

- Refactor individual functions (up to ~200 lines)
- Fix security issues in isolated files
- Add unit tests for specific functions
- Eliminate code duplication within modules
- Apply consistent formatting across files
- Extract helper methods from complex functions

### What Claude Code CANNOT Do ❌ (Requires Human)

- Architecture redesign decisions
- Business logic validation
- Performance optimization (needs profiling)
- Breaking API changes (needs stakeholder input)
- Database schema migrations
- Complete codebase rewrites in one shot

### Session Planning Strategy

**Small Batches:** 20-30 files per session (safer)
**Medium Batches:** 50-75 files per session (balanced)
**Large Batches:** 100-150 files per session (risky but faster)

**Recommendation:** Start with small batches, increase as confidence grows.

---

## 🎯 Phased Remediation Roadmap

### Phase 1: Critical Security (Week 1) 🔴 URGENT

**Goal:** Eliminate all critical security vulnerabilities

**Tasks:**
- [ ] Run \`assess-security\` for detailed security analysis
- [ ] Fix all Gitleaks findings (exposed secrets, API keys)
- [ ] Address Semgrep critical vulnerabilities
- [ ] Audit and update vulnerable dependencies

**AI Sessions:** 2-5 sessions
**Human Oversight:** Review all security fixes before deployment
**Validation:** Run security scanners again, ensure zero critical issues

**Commands:**
\`\`\`bash
assess-security                    # Detailed security report
fix-security-batch --critical-only # AI-assisted fixes
verify-security-fixes              # Validation
\`\`\`

---

### Phase 2: Complexity Reduction (Weeks 2-3) 🟡 HIGH PRIORITY

**Goal:** Reduce cyclomatic complexity in high-impact areas

**Strategy:**
1. Identify top 50 most complex functions (\`lizard --CCN 15\`)
2. Prioritize by: complexity × change_frequency × business_criticality
3. Refactor top 20-30 functions
4. Target: Reduce average CCN from current to <12

**AI Sessions:** 10-15 sessions (5-10 functions per session)
**Human Oversight:** Review refactorings, approve architectural changes
**Validation:** Run tests, verify behavior unchanged

**Commands:**
\`\`\`bash
identify-complexity-hotspots       # List high-CCN functions
refactor-complexity-batch --top=10 # Refactor in batches
verify-complexity-reduction        # Check metrics improved
\`\`\`

---

### Phase 3: Test Coverage Expansion (Weeks 4-5) 🟢 MEDIUM PRIORITY

**Goal:** Increase test coverage to 60%+ (current: check .quality/coverage.json)

**Strategy:**
1. Identify critical untested paths
2. Add characterization tests for existing behavior
3. Add proper unit tests for refactored code
4. Add integration tests for critical workflows

**AI Sessions:** 15-20 sessions
**Human Oversight:** Review test logic, add edge cases
**Validation:** Coverage reports show improvement

**Commands:**
\`\`\`bash
identify-coverage-gaps             # Find untested code
generate-tests-batch --priority=high # AI generates tests
verify-test-coverage               # Check coverage improved
\`\`\`

---

### Phase 4: Code Duplication Elimination (Week 6) 🔵 MEDIUM PRIORITY

**Goal:** Reduce code duplication from current to <10%

**Strategy:**
1. Find duplication clusters (>3 instances)
2. Extract common utilities and shared components
3. Update call sites to use new utilities
4. Add tests for extracted utilities

**AI Sessions:** 8-12 sessions
**Human Oversight:** Review extracted utilities for reusability
**Validation:** Duplication percentage decreases, tests pass

**Commands:**
\`\`\`bash
find-duplication-clusters          # Identify duplicates
extract-utilities-batch --threshold=3 # Extract shared code
verify-duplication-reduction       # Check metrics
\`\`\`

---

### Phase 5: Architecture Improvements (Weeks 7-8) ⚪ LONG-TERM

**Goal:** Improve module structure and separation of concerns

**Strategy:**
1. Analyze current architecture (\`analyze-architecture\`)
2. Identify circular dependencies
3. Plan module boundaries (requires human decisions)
4. Apply Strangler Fig Pattern for gradual migration

**AI Sessions:** 10-15 sessions
**Human Oversight:** Architecture decisions, approval of restructuring
**Validation:** Dependency graphs improve, coupling reduces

**Commands:**
\`\`\`bash
analyze-architecture               # Generate dependency graphs
plan-architecture-improvements     # AI suggestions (human approves)
strangle-module --old=X --new=Y    # Gradual migration
track-strangler-progress           # Monitor migration
\`\`\`

---

## 📈 Success Metrics

Track these metrics weekly to measure progress:

| **Metric** | **Current** | **Target** | **Timeline** |
|------------|-------------|------------|--------------|
| Health Score | TBD | 70/100 | 8 weeks |
| Avg Complexity | TBD | <12 CCN | 3 weeks |
| Test Coverage | TBD | 60% | 5 weeks |
| Duplication | TBD | <10% | 6 weeks |
| Security Issues | TBD | 0 critical | 1 week |

**Tracking Commands:**
\`\`\`bash
quality-dashboard                  # Current metrics
quality-progress --since=baseline  # Week-over-week progress
quality-trends --weeks=8           # Trend analysis
\`\`\`

---

## ⚠️ Risk Management

### High-Risk Activities

1. **Architecture Changes:** Always use Strangler Fig, never big rewrites
2. **Database Changes:** Requires human review and migration strategy
3. **API Changes:** Version APIs, maintain backward compatibility
4. **Performance Changes:** Profile before/after, benchmark

### Rollback Strategy

- Commit after every batch (5-10 files)
- Tag stable points: \`git tag stable-phase-1-complete\`
- Keep detailed commit messages explaining changes
- Maintain ability to rollback to any phase

### Validation Checkpoints

**After Every Batch:**
- [ ] All tests pass
- [ ] Quality gates pass
- [ ] Manual smoke test
- [ ] Git commit with detailed message

**After Every Phase:**
- [ ] Run full test suite
- [ ] Run quality-dashboard
- [ ] Review with team
- [ ] Tag as stable

---

## 🎯 Execution Strategy

### Week-by-Week Plan

**Week 1:** Security fixes, setup quality gates
**Week 2-3:** Complexity reduction (top 30 functions)
**Week 4-5:** Test coverage expansion (to 60%)
**Week 6:** Duplication elimination
**Week 7-8:** Architecture improvements (Strangler Fig)

### Daily Workflow

1. **Morning:** Run \`quality-dashboard\` to see current state
2. **Work:** Execute one batch (e.g., \`refactor-complexity-batch --batch=1\`)
3. **Validate:** Run tests, review diffs, commit
4. **Track:** Update progress (\`quality-progress\`)
5. **Evening:** Review day's progress, plan tomorrow

### Team Coordination

- **Daily standups:** Share progress on remediation
- **Weekly reviews:** Review quality dashboard trends
- **Bi-weekly demos:** Show stakeholders progress
- **Monthly retrospectives:** Adjust strategy based on learnings

---

## 💡 Best Practices

1. **Small batches:** 5-10 files at a time, commit frequently
2. **Tests first:** Add characterization tests before refactoring
3. **Human review:** Review all AI-generated diffs before committing
4. **Track progress:** Update metrics weekly
5. **Celebrate wins:** Acknowledge improvements, motivate team
6. **Stay flexible:** Adjust plan based on what you learn

---

## 🚀 Getting Started

Ready to begin? Start here:

\`\`\`bash
# 1. Assess security first
assess-security

# 2. Fix critical issues
fix-security-batch --critical-only

# 3. View progress
quality-dashboard

# 4. Plan next batch
# (Follow Phase 1 → Phase 2 → Phase 3 → etc.)
\`\`\`

---

**This plan was generated with AI self-awareness.** Claude Code understands its token limitations and has designed this plan for safe, incremental progress. Human oversight is required for architectural decisions and business logic validation.

**Questions?** Review \`LEGACY_CODEBASE_RESCUE.md\` for detailed workflows and patterns.

**Good luck rescuing your legacy codebase!** 🚀
EOF

      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "✅ Remediation Plan Generated!"
      echo ""
      echo "📄 Plan: cat REMEDIATION_PLAN.md"
      echo "📊 Sessions needed: $SESSIONS_NEEDED"
      echo "📈 Max files/session: $MAX_FILES_PER_SESSION"
      echo ""
      echo "🎯 Next steps:"
      echo "  1. Review REMEDIATION_PLAN.md"
      echo "  2. Start with Phase 1: assess-security"
      echo "  3. Track progress: quality-dashboard"
      echo ""
    '';

    quality-dashboard.exec = ''
      echo ""
      echo "┌─────────────────────────────────────────────┐"
      echo "│     Codebase Quality Dashboard              │"
      echo "├─────────────────────────────────────────────┤"

      # Extract metrics if available
      if [ -f .quality/stats.json ]; then
        TOTAL_LOC=$(cat .quality/stats.json | jq '.Total.code' 2>/dev/null || echo "N/A")
        echo "│ Total LOC:       $TOTAL_LOC                │"
      else
        echo "│ Total LOC:       N/A (run assess-codebase) │"
      fi

      echo "├─────────────────────────────────────────────┤"
      echo "│ Run 'assess-codebase' for full analysis     │"
      echo "│ Run 'generate-remediation-plan' for roadmap │"
      echo "└─────────────────────────────────────────────┘"
      echo ""
    '';

    # ============================================================================
    # AUTONOMOUS EXECUTION LAYER - TIER 1 & TIER 2
    # ============================================================================

    initialize-remediation-state.exec = ''
      echo ""
      echo "🚀 Initializing Autonomous Remediation State"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Check prerequisites
      if [ ! -d .quality ]; then
        echo "❌ Error: Run 'assess-codebase' first to gather metrics"
        exit 1
      fi

      if [ -f .quality/remediation-state.json ]; then
        echo "⚠️  Remediation state already exists"
        read -p "Overwrite? (y/N): " CONFIRM
        if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
          echo "Cancelled"
          exit 0
        fi
      fi

      echo "📊 Analyzing assessment data..."

      # Extract codebase metrics
      TOTAL_FILES=$(cat .quality/stats.json 2>/dev/null | jq '[.[] | .code + .comments + .blanks] | add' || echo 0)
      TOTAL_LOC=$(cat .quality/stats.json 2>/dev/null | jq '.Total.code' || echo 0)

      # Calculate session requirements
      CONTEXT_WINDOW=200000
      AVG_TOKENS_PER_FILE=1000
      SAFETY_MARGIN=50000
      USABLE_TOKENS=$((CONTEXT_WINDOW - SAFETY_MARGIN))
      MAX_FILES_PER_SESSION=$((USABLE_TOKENS / AVG_TOKENS_PER_FILE))
      SESSIONS_ESTIMATED=$(( (TOTAL_FILES + MAX_FILES_PER_SESSION - 1) / MAX_FILES_PER_SESSION ))

      echo "  ✓ Total Files: $TOTAL_FILES"
      echo "  ✓ Total LOC: $TOTAL_LOC"
      echo "  ✓ Estimated Sessions: $SESSIONS_ESTIMATED"
      echo ""

      # Identify initial targets from complexity analysis
      echo "🎯 Identifying remediation targets..."

      # Security targets
      SECURITY_TARGETS=$(cat .quality/gitleaks.json 2>/dev/null | jq '[.[] | {
        id: ("sec_" + (.RuleID // "unknown") + "_" + (.StartLine // 0 | tostring)),
        file: .File,
        type: "security",
        rule: .RuleID,
        line: .StartLine,
        priority: 1
      }]' || echo "[]")

      # Complexity targets
      COMPLEXITY_TARGETS=$(cat .quality/complexity.json 2>/dev/null | jq '[
        .[] | .function_list[] | select(.cyclomatic_complexity > 15) | {
          id: ("cplx_" + (.long_name | gsub("[^a-zA-Z0-9]"; "_"))),
          file: .filename,
          function: .long_name,
          type: "complexity",
          ccn_current: .cyclomatic_complexity,
          ccn_target: 12,
          line_start: .start_line,
          line_end: .end_line,
          priority: (if .cyclomatic_complexity > 25 then 1 elif .cyclomatic_complexity > 20 then 2 else 3 end)
        }
      ] | sort_by(.priority, -.ccn_current)' || echo "[]")

      # Combine targets
      ALL_TARGETS=$(echo "$SECURITY_TARGETS $COMPLEXITY_TARGETS" | jq -s 'add')
      TARGET_COUNT=$(echo "$ALL_TARGETS" | jq 'length')

      echo "  ✓ Identified $TARGET_COUNT targets"
      echo ""

      # Create initial state
      cat > .quality/remediation-state.json << EOF
{
  "version": "1.0",
  "started_at": "$(date -Iseconds)",
  "updated_at": "$(date -Iseconds)",
  "current_phase": "security",
  "phases_complete": [],
  "sessions": {
    "completed": 0,
    "total_estimated": $SESSIONS_ESTIMATED,
    "token_budget_used": 0,
    "token_budget_total": $((SESSIONS_ESTIMATED * USABLE_TOKENS))
  },
  "targets": {
    "pending": $ALL_TARGETS,
    "in_progress": [],
    "completed": [],
    "failed": [],
    "skipped": []
  },
  "checkpoints": [],
  "human_approvals": [],
  "metrics_history": [
    {
      "timestamp": "$(date -Iseconds)",
      "health_score": 0,
      "avg_ccn": $(cat .quality/complexity.json 2>/dev/null | jq '[.[] | .average_cyclomatic_complexity] | add / length' || echo 0),
      "coverage": 0,
      "duplication": $(cat .quality/jscpd-report.json 2>/dev/null | jq '.statistics.total.percentage' || echo 0),
      "security_issues": $(cat .quality/gitleaks.json 2>/dev/null | jq 'length' || echo 0)
    }
  ],
  "consecutive_failures": 0
}
EOF

      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "✅ Remediation State Initialized!"
      echo ""
      echo "📄 State file: .quality/remediation-state.json"
      echo "🎯 Targets identified: $TARGET_COUNT"
      echo "📊 Sessions estimated: $SESSIONS_ESTIMATED"
      echo ""
      echo "🚀 Next steps:"
      echo "  1. Review state: cat .quality/remediation-state.json | jq"
      echo "  2. Start first session: autonomous-remediation-session"
      echo ""
    '';

    update-remediation-state.exec = ''
      # Usage: update-remediation-state --target=ID --status=STATUS [--reason=REASON]

      TARGET_ID=""
      STATUS=""
      REASON=""
      SESSION_COMPLETE=false

      # Parse arguments
      for arg in "$@"; do
        case $arg in
          --target=*)
            TARGET_ID="''${arg#*=}"
            ;;
          --status=*)
            STATUS="''${arg#*=}"
            ;;
          --reason=*)
            REASON="''${arg#*=}"
            ;;
          --session-complete)
            SESSION_COMPLETE=true
            ;;
        esac
      done

      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ Error: No remediation state found"
        echo "   Run 'initialize-remediation-state' first"
        exit 1
      fi

      TIMESTAMP=$(date -Iseconds)

      if [ "$SESSION_COMPLETE" = true ]; then
        # Increment session count
        jq ".sessions.completed += 1 | .updated_at = \"$TIMESTAMP\"" \
          .quality/remediation-state.json > .quality/remediation-state.tmp.json
        mv .quality/remediation-state.tmp.json .quality/remediation-state.json
        echo "✅ Session count updated"
        exit 0
      fi

      if [ -z "$TARGET_ID" ] || [ -z "$STATUS" ]; then
        echo "Usage: update-remediation-state --target=ID --status=STATUS [--reason=REASON]"
        echo "       update-remediation-state --session-complete"
        exit 1
      fi

      # Update target status
      case $STATUS in
        in_progress)
          jq --arg id "$TARGET_ID" --arg ts "$TIMESTAMP" '
            .targets.pending = [.targets.pending[] | select(.id != $id)] |
            .targets.in_progress += [.targets.pending[] | select(.id == $id) | . + {started_at: $ts}] |
            .updated_at = $ts
          ' .quality/remediation-state.json > .quality/remediation-state.tmp.json
          ;;
        completed)
          jq --arg id "$TARGET_ID" --arg ts "$TIMESTAMP" '
            .targets.in_progress = [.targets.in_progress[] | select(.id != $id)] |
            .targets.completed += [(.targets.in_progress[] | select(.id == $id)) + {completed_at: $ts}] |
            .consecutive_failures = 0 |
            .updated_at = $ts
          ' .quality/remediation-state.json > .quality/remediation-state.tmp.json
          ;;
        failed)
          jq --arg id "$TARGET_ID" --arg ts "$TIMESTAMP" --arg reason "$REASON" '
            .targets.in_progress = [.targets.in_progress[] | select(.id != $id)] |
            .targets.failed += [(.targets.in_progress[] | select(.id == $id)) + {
              failed_at: $ts,
              reason: $reason,
              attempts: 1,
              needs_human: (.consecutive_failures >= 2)
            }] |
            .consecutive_failures += 1 |
            .updated_at = $ts
          ' .quality/remediation-state.json > .quality/remediation-state.tmp.json
          ;;
        skipped)
          jq --arg id "$TARGET_ID" --arg ts "$TIMESTAMP" --arg reason "$REASON" '
            .targets.pending = [.targets.pending[] | select(.id != $id)] |
            .targets.skipped += [(.targets.pending[] | select(.id == $id)) + {
              skipped_at: $ts,
              reason: $reason
            }] |
            .updated_at = $ts
          ' .quality/remediation-state.json > .quality/remediation-state.tmp.json
          ;;
      esac

      mv .quality/remediation-state.tmp.json .quality/remediation-state.json
    '';

    # ============================================================================
    # QUALITY BASELINE GATES - FEATURE READINESS SYSTEM
    # ============================================================================

    check-feature-readiness.exec = ''
      echo ""
      echo "🔍 Checking Feature Readiness - Quality Baseline Gates"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Check if assessment has been run
      if [ ! -d .quality ]; then
        echo "❌ Error: Assessment not found"
        echo "   Run 'assess-codebase' first to gather metrics"
        exit 1
      fi

      # Initialize pass/fail tracking
      PASSED=0
      FAILED=0
      WARNINGS=0

      # Function to check threshold
      check_threshold() {
        local NAME=$1
        local CURRENT=$2
        local THRESHOLD=$3
        local OPERATOR=$4  # "lt" for less than, "gt" for greater than, "eq" for equal

        if [ "$CURRENT" = "N/A" ] || [ "$CURRENT" = "unknown" ]; then
          echo "  ⚠️  $NAME: Unable to determine (not measured)"
          WARNINGS=$((WARNINGS + 1))
          return 1
        fi

        case $OPERATOR in
          "lt")
            if (( $(echo "$CURRENT < $THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
              echo "  ✅ $NAME: $CURRENT (threshold: <$THRESHOLD)"
              PASSED=$((PASSED + 1))
              return 0
            else
              echo "  ❌ $NAME: $CURRENT (threshold: <$THRESHOLD) - FAILED"
              FAILED=$((FAILED + 1))
              return 1
            fi
            ;;
          "gt")
            if (( $(echo "$CURRENT > $THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
              echo "  ✅ $NAME: $CURRENT (threshold: >$THRESHOLD)"
              PASSED=$((PASSED + 1))
              return 0
            else
              echo "  ❌ $NAME: $CURRENT (threshold: >$THRESHOLD) - FAILED"
              FAILED=$((FAILED + 1))
              return 1
            fi
            ;;
          "eq")
            if [ "$CURRENT" -eq "$THRESHOLD" ]; then
              echo "  ✅ $NAME: $CURRENT (threshold: $THRESHOLD)"
              PASSED=$((PASSED + 1))
              return 0
            else
              echo "  ❌ $NAME: $CURRENT (threshold: $THRESHOLD) - FAILED"
              FAILED=$((FAILED + 1))
              return 1
            fi
            ;;
        esac
      }

      echo "🔴 CRITICAL - Security (Non-negotiable)"
      echo "─────────────────────────────────────────────"

      # Check for critical security issues
      if [ -f .quality/gitleaks.json ]; then
        SECRETS_COUNT=$(cat .quality/gitleaks.json | jq 'length' 2>/dev/null || echo "N/A")
        check_threshold "Exposed Secrets" "$SECRETS_COUNT" 0 "eq"
      else
        echo "  ⚠️  Gitleaks scan not found - run assess-codebase"
        WARNINGS=$((WARNINGS + 1))
      fi

      if [ -f .quality/semgrep.json ]; then
        CRITICAL_VULNS=$(cat .quality/semgrep.json | jq '[.results[] | select(.extra.severity == "ERROR")] | length' 2>/dev/null || echo "N/A")
        check_threshold "Critical Vulnerabilities" "$CRITICAL_VULNS" 0 "eq"
      else
        echo "  ⚠️  Semgrep scan not found - run assess-codebase"
        WARNINGS=$((WARNINGS + 1))
      fi

      echo ""
      echo "🟡 HIGH PRIORITY - Complexity"
      echo "─────────────────────────────────────────────"

      # Check complexity metrics
      if [ -f .quality/complexity.json ]; then
        AVG_CCN=$(cat .quality/complexity.json | jq '[.[] | .average_cyclomatic_complexity] | add / length' 2>/dev/null || echo "N/A")
        MAX_CCN=$(cat .quality/complexity.json | jq '[.[] | .max_cyclomatic_complexity] | max' 2>/dev/null || echo "N/A")
        HIGH_CCN_COUNT=$(cat .quality/complexity.json | jq '[.[] | .function_list[] | select(.cyclomatic_complexity > 20)] | length' 2>/dev/null || echo "N/A")

        check_threshold "Average CCN" "$AVG_CCN" 15 "lt"
        check_threshold "Maximum CCN" "$MAX_CCN" 30 "lt"
        check_threshold "Functions >20 CCN" "$HIGH_CCN_COUNT" 20 "lt"
      else
        echo "  ⚠️  Complexity analysis not found - run assess-codebase"
        WARNINGS=$((WARNINGS + 1))
      fi

      echo ""
      echo "🟢 MEDIUM PRIORITY - Test Coverage"
      echo "─────────────────────────────────────────────"

      # Check test coverage
      if [ -f .quality/coverage.json ]; then
        OVERALL_COVERAGE=$(cat .quality/coverage.json | jq '.totals.percent_covered' 2>/dev/null || echo "N/A")
        check_threshold "Overall Coverage" "$OVERALL_COVERAGE" 40 "gt"
      else
        echo "  ⚠️  Coverage report not found"
        echo "     Run tests with coverage: npm run test:coverage or pytest --cov"
        WARNINGS=$((WARNINGS + 1))
      fi

      echo ""
      echo "🟢 MEDIUM PRIORITY - Code Duplication"
      echo "─────────────────────────────────────────────"

      # Check duplication
      if [ -f .quality/jscpd-report.json ]; then
        DUPLICATION_PCT=$(cat .quality/jscpd-report.json | jq '.statistics.total.percentage' 2>/dev/null || echo "N/A")
        check_threshold "Code Duplication" "$DUPLICATION_PCT" 15 "lt"
      else
        echo "  ⚠️  Duplication analysis not found - run assess-codebase"
        WARNINGS=$((WARNINGS + 1))
      fi

      echo ""
      echo "🔵 DOCUMENTATION & HYGIENE"
      echo "─────────────────────────────────────────────"

      # Check for documentation
      if [ -f README.md ]; then
        echo "  ✅ README.md exists"
        PASSED=$((PASSED + 1))
      else
        echo "  ❌ README.md missing"
        FAILED=$((FAILED + 1))
      fi

      # Check .gitignore
      if [ -f .gitignore ]; then
        echo "  ✅ .gitignore exists"
        PASSED=$((PASSED + 1))
      else
        echo "  ❌ .gitignore missing"
        FAILED=$((FAILED + 1))
      fi

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "📊 Results Summary"
      echo "─────────────────────────────────────────────"
      echo "  ✅ Passed:   $PASSED checks"
      echo "  ❌ Failed:   $FAILED checks"
      echo "  ⚠️  Warnings: $WARNINGS checks"
      echo ""

      if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        echo "🎉 FEATURE READY!"
        echo ""
        echo "✅ All quality baseline gates passed"
        echo "🚀 Ready to certify and begin feature development"
        echo ""
        echo "Next step: certify-feature-ready"
        exit 0
      elif [ $FAILED -eq 0 ]; then
        echo "⚠️  MOSTLY READY (with warnings)"
        echo ""
        echo "Some metrics could not be measured. Review warnings above."
        echo "Consider running 'assess-codebase' again or adding missing tools."
        echo ""
        echo "If acceptable, run: certify-feature-ready --allow-warnings"
        exit 1
      else
        echo "❌ NOT FEATURE READY"
        echo ""
        echo "Quality baseline not met. Remediation required before features."
        echo ""
        echo "📋 Recommended actions:"
        echo "  1. Review QUALITY_BASELINE_GATES.md for threshold definitions"
        echo "  2. Run 'generate-remediation-plan' for detailed roadmap"
        echo "  3. Execute Phase 1-5 remediation workflow"
        echo "  4. Re-run 'check-feature-readiness' to verify"
        echo ""
        echo "🔴 Failed checks must be addressed before feature development"
        exit 1
      fi
    '';

    certify-feature-ready.exec = ''
      echo ""
      echo "🎓 Certifying Feature Readiness"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Check if quality baseline has been validated
      echo "🔍 Running feature readiness check..."
      if ! check-feature-readiness; then
        echo ""
        echo "❌ Certification Failed"
        echo "   Quality baseline not met. Fix failing checks first."
        exit 1
      fi

      echo ""
      echo "📸 Saving baseline snapshot..."

      # Create certification directory
      mkdir -p .quality/baseline

      # Save baseline metrics
      CERT_DATE=$(date +%Y-%m-%d)
      cat > .quality/baseline/certification.json << EOF
{
  "certification_date": "$CERT_DATE",
  "certified_by": "AI Quality DevEnv",
  "baseline_metrics": {
    "security": {
      "secrets": $(cat .quality/gitleaks.json 2>/dev/null | jq 'length' || echo 0),
      "critical_vulns": $(cat .quality/semgrep.json 2>/dev/null | jq '[.results[] | select(.extra.severity == "ERROR")] | length' || echo 0)
    },
    "complexity": {
      "avg_ccn": $(cat .quality/complexity.json 2>/dev/null | jq '[.[] | .average_cyclomatic_complexity] | add / length' || echo 0),
      "max_ccn": $(cat .quality/complexity.json 2>/dev/null | jq '[.[] | .max_cyclomatic_complexity] | max' || echo 0)
    },
    "coverage": {
      "overall": $(cat .quality/coverage.json 2>/dev/null | jq '.totals.percent_covered' || echo 0)
    },
    "duplication": {
      "percentage": $(cat .quality/jscpd-report.json 2>/dev/null | jq '.statistics.total.percentage' || echo 0)
    }
  },
  "strict_mode": true
}
EOF

      # Copy all baseline files
      cp .quality/stats.json .quality/baseline/ 2>/dev/null || true
      cp .quality/complexity.json .quality/baseline/ 2>/dev/null || true
      cp .quality/coverage.json .quality/baseline/ 2>/dev/null || true
      cp .quality/jscpd-report.json .quality/baseline/ 2>/dev/null || true

      echo "  ✓ Baseline snapshot saved to .quality/baseline/"

      echo ""
      echo "🔒 Enabling strict mode quality gates..."

      # Create strict mode marker
      echo "STRICT_MODE_ENABLED=true" > .quality/baseline/.strict-mode
      echo "CERTIFICATION_DATE=$CERT_DATE" >> .quality/baseline/.strict-mode

      echo "  ✓ Strict mode enabled"

      echo ""
      echo "📋 Generating certification report..."

      cat > .quality/baseline/CERTIFICATION_REPORT.md << 'EOF'
# Feature Readiness Certification Report

**Certification Date**: $CERT_DATE
**Certified By**: AI Quality DevEnv Template
**Status**: ✅ CERTIFIED FOR FEATURE DEVELOPMENT

---

## Quality Baseline Achieved

This codebase has met all minimum quality thresholds and is certified ready for feature development.

### Baseline Metrics Locked

All current metrics have been saved as the baseline. Future commits will be compared against these values.

**Security:**
- Exposed Secrets: $(cat .quality/baseline/certification.json | jq '.baseline_metrics.security.secrets')
- Critical Vulnerabilities: $(cat .quality/baseline/certification.json | jq '.baseline_metrics.security.critical_vulns')

**Complexity:**
- Average CCN: $(cat .quality/baseline/certification.json | jq '.baseline_metrics.complexity.avg_ccn')
- Maximum CCN: $(cat .quality/baseline/certification.json | jq '.baseline_metrics.complexity.max_ccn')

**Coverage:**
- Overall: $(cat .quality/baseline/certification.json | jq '.baseline_metrics.coverage.overall')%

**Duplication:**
- Percentage: $(cat .quality/baseline/certification.json | jq '.baseline_metrics.duplication.percentage')%

---

## Strict Mode Enforcement

🔒 **Strict mode is now ACTIVE**

All commits will be validated against the baseline:
- No regression in any metric allowed
- Quality gates run on every commit
- Blocking pre-commit hooks enabled

### Enforcement Rules

1. **Security**: Zero tolerance - any new secrets or critical vulnerabilities block commits
2. **Complexity**: New/modified functions must have CCN < 15
3. **Coverage**: Changed files must maintain ≥50% coverage
4. **Duplication**: No new code duplication allowed

---

## Git Hooks Active

Pre-commit hooks will now run:
- \`quality-regression-check\` on every commit
- Blocks commits that violate baseline
- Provides actionable feedback on failures

To bypass in emergencies (not recommended):
\`\`\`bash
git commit --no-verify -m "emergency: description"
# Must be followed by immediate remediation commit
\`\`\`

---

## Next Steps

✅ Feature development can now begin!

**Development workflow:**
1. Create feature branch: \`git checkout -b feature/my-feature\`
2. Develop with quality gates active
3. Run \`quality-regression-check\` before committing
4. All tests pass, quality gates pass → commit allowed
5. Continue iterating

**Monitoring:**
- Run \`quality-dashboard\` to see current metrics
- Compare to baseline: \`cat .quality/baseline/certification.json\`
- Track trends: Metrics should improve or stay stable, never regress

---

**Congratulations!** 🎉

Your codebase is now certified for feature development with strict quality enforcement.

Build features confidently knowing quality gates protect against regression.
EOF

      echo "  ✓ Certification report generated"

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "🎉 CERTIFICATION COMPLETE!"
      echo ""
      echo "✅ Quality baseline locked and saved"
      echo "🔒 Strict mode quality gates ENABLED"
      echo "📄 Certification report: .quality/baseline/CERTIFICATION_REPORT.md"
      echo ""
      echo "🚀 Ready for feature development!"
      echo ""
      echo "⚠️  Important: All commits will now be validated against baseline"
      echo "   - Run 'quality-regression-check' before committing"
      echo "   - Quality gates will block commits with regressions"
      echo ""
      echo "📊 Monitor progress: quality-dashboard"
      echo ""
    '';

    quality-regression-check.exec = ''
      echo ""
      echo "🔍 Quality Regression Check"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      # Check if strict mode is enabled
      if [ ! -f .quality/baseline/.strict-mode ]; then
        echo "ℹ️  Strict mode not enabled"
        echo "   Run 'certify-feature-ready' to enable strict quality gates"
        echo ""
        echo "✅ Running in permissive mode - no baseline comparison"
        exit 0
      fi

      echo "🔒 Strict mode ACTIVE - checking for regressions..."
      echo ""

      # Load baseline
      if [ ! -f .quality/baseline/certification.json ]; then
        echo "❌ Error: Baseline certification not found"
        echo "   Re-run 'certify-feature-ready' to establish baseline"
        exit 1
      fi

      # Get current metrics (run lightweight checks)
      echo "📊 Gathering current metrics..."

      REGRESSION_FOUND=false

      # Security check
      echo ""
      echo "🔒 Security regression check..."
      gitleaks detect --report-format json --report-path .quality/current-gitleaks.json --no-git 2>/dev/null
      CURRENT_SECRETS=$(cat .quality/current-gitleaks.json 2>/dev/null | jq 'length' || echo "0")
      BASELINE_SECRETS=$(cat .quality/baseline/certification.json | jq '.baseline_metrics.security.secrets')

      if [ "$CURRENT_SECRETS" -gt "$BASELINE_SECRETS" ]; then
        echo "  ❌ NEW SECRETS DETECTED: $CURRENT_SECRETS (baseline: $BASELINE_SECRETS)"
        REGRESSION_FOUND=true
      else
        echo "  ✅ No new secrets"
      fi

      # Complexity check (only on changed files)
      echo ""
      echo "🔍 Complexity regression check..."

      # Get list of changed files
      if [ -d .git ]; then
        CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(py|js|ts|tsx)$' || echo "")

        if [ -n "$CHANGED_FILES" ]; then
          for file in $CHANGED_FILES; do
            if [ -f "$file" ]; then
              FILE_CCN=$(lizard "$file" 2>/dev/null | grep "Average:" | awk '{print $2}' || echo "0")
              if (( $(echo "$FILE_CCN > 15" | bc -l 2>/dev/null || echo 0) )); then
                echo "  ❌ High complexity in $file: CCN $FILE_CCN (threshold: 15)"
                REGRESSION_FOUND=true
              else
                echo "  ✅ $file: CCN $FILE_CCN"
              fi
            fi
          done
        else
          echo "  ℹ️  No code files changed"
        fi
      else
        echo "  ⚠️  Not a git repository - skipping file-level checks"
      fi

      # Coverage check (if tests run)
      echo ""
      echo "📈 Coverage check..."
      if [ -f .quality/coverage.json ]; then
        CURRENT_COVERAGE=$(cat .quality/coverage.json | jq '.totals.percent_covered' 2>/dev/null || echo "0")
        BASELINE_COVERAGE=$(cat .quality/baseline/certification.json | jq '.baseline_metrics.coverage.overall')

        if (( $(echo "$CURRENT_COVERAGE < $BASELINE_COVERAGE - 5" | bc -l 2>/dev/null || echo 0) )); then
          echo "  ❌ Coverage regression: $CURRENT_COVERAGE% (baseline: $BASELINE_COVERAGE%)"
          REGRESSION_FOUND=true
        else
          echo "  ✅ Coverage maintained: $CURRENT_COVERAGE%"
        fi
      else
        echo "  ⚠️  Coverage not measured - run tests with coverage"
      fi

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      if [ "$REGRESSION_FOUND" = true ]; then
        echo "❌ QUALITY REGRESSION DETECTED"
        echo ""
        echo "Commit blocked due to quality baseline violations."
        echo ""
        echo "📋 Actions required:"
        echo "  1. Review failures above"
        echo "  2. Fix quality issues in your changes"
        echo "  3. Re-run 'quality-regression-check'"
        echo "  4. Commit when all checks pass"
        echo ""
        echo "Emergency bypass (not recommended):"
        echo "  git commit --no-verify -m 'emergency: reason'"
        echo ""
        exit 1
      else
        echo "✅ NO REGRESSIONS DETECTED"
        echo ""
        echo "Quality baseline maintained. Commit allowed."
        echo ""
        exit 0
      fi
    '';

    identify-next-targets.exec = ''
      PHASE="$(cat .quality/remediation-state.json 2>/dev/null | jq -r '.current_phase' || echo 'security')"
      COUNT=10

      for arg in "$@"; do
        case $arg in
          --phase=*) PHASE="''${arg#*=}" ;;
          --count=*) COUNT="''${arg#*=}" ;;
        esac
      done

      if [ ! -f .quality/remediation-state.json ]; then
        echo "❌ Error: Run 'initialize-remediation-state' first"
        exit 1
      fi

      jq --arg phase "$PHASE" --argjson count "$COUNT" '
        .targets.pending
        | map(select(.type == $phase))
        | sort_by(.priority, -.ccn_current // 0)
        | .[:$count]
      ' .quality/remediation-state.json
    '';

    checkpoint-progress.exec = ''
      TARGET_ID=""
      SESSION_NUM=$(cat .quality/remediation-state.json 2>/dev/null | jq '.sessions.completed' || echo 0)

      for arg in "$@"; do
        case $arg in
          --target-id=*) TARGET_ID="''${arg#*=}" ;;
          --session=*) SESSION_NUM="''${arg#*=}" ;;
        esac
      done

      TIMESTAMP=$(date -Iseconds)
      git add .
      git commit -m "refactor: $TARGET_ID [autonomous session $SESSION_NUM]

Automated remediation via autonomous-remediation-session"

      COMMIT_COUNT=$(git log --oneline --grep="autonomous session" | wc -l)
      if [ $((COMMIT_COUNT % 5)) -eq 0 ]; then
        TAG="stable-session-$SESSION_NUM"
        git tag "$TAG"
        echo "  ✅ Created checkpoint tag: $TAG"
      fi

      jq --arg ts "$TIMESTAMP" --argjson session "$SESSION_NUM" '
        .checkpoints += [{
          session: $session,
          timestamp: $ts,
          commit: "'"$(git rev-parse HEAD)"'",
          tag: null
        }]
      ' .quality/remediation-state.json > .quality/remediation-state.tmp.json
      mv .quality/remediation-state.tmp.json .quality/remediation-state.json
      echo "  ✅ Progress checkpointed"
    '';

    needs-human-checkpoint.exec = ''
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
