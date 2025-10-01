# Legacy Codebase Rescue System

**AI-Powered Assessment & Remediation Planning for Poorly Managed Codebases**

> **Problem**: Most real-world projects have low quality, high complexity, poor testing, and accumulated technical debt. Traditional approaches fail because they don't account for AI limitations or provide phased, safe refactoring plans.

> **Solution**: A comprehensive assessment and remediation planning system that:
> - Deeply analyzes codebase quality with multiple metrics
> - **Acknowledges AI limitations** (token budgets, context windows, capability boundaries)
> - Generates phased implementation plans based on self-awareness
> - Provides incremental refactoring workflows
> - Tracks progress toward maintainability goals

---

## 🎯 Use Cases

### Scenario 1: The Inherited Mess
- 50K LOC JavaScript app, no tests, CCN avg 25, 40% duplication
- Previous team gone, no documentation
- Need to add features but terrified of breaking things

### Scenario 2: The Zombie Monolith
- 200K LOC Python backend, 15 years old
- 3% test coverage, multiple architectural patterns mixed
- Performance issues, security vulnerabilities
- Can't deploy without 2-week QA cycle

### Scenario 3: The Startup

 Hack
- Fast-growing startup, MVP-to-production code
- Technical debt from "ship it" culture
- Now need enterprise-grade quality
- Team scaling, can't onboard new devs

---

## 🧠 AI Self-Awareness Framework

### Token Budget Reality

**Claude Code (Sonnet 4) Capabilities:**
```
Context Window: 200,000 tokens (standard)
                1,000,000 tokens (extended, expensive)

Average File Sizes:
  - Simple utility: ~500 tokens
  - Standard component: ~1,000 tokens
  - Complex module: ~2,000 tokens
  - Large file: ~5,000+ tokens

Safe Batch Sizes:
  - Small batch: 20-30 files (~30K tokens)
  - Medium batch: 50-75 files (~75K tokens)
  - Large batch: 100-150 files (~150K tokens)
  - Leave ~50K tokens for responses and overhead
```

### Capability Boundaries

#### ✅ What Claude Code CAN Do

**Isolated Refactoring:**
- Reduce complexity in individual functions (up to ~200 lines)
- Extract helper methods from complex functions
- Fix security issues in bounded modules
- Add unit tests for specific functions
- Eliminate duplication within a module

**Pattern Application:**
- Apply consistent formatting across files
- Enforce coding standards in batch
- Extract common utilities
- Rename variables/functions consistently
- Add type hints/annotations

**Analysis:**
- Identify high-complexity functions
- Find security vulnerabilities
- Detect code duplication
- Suggest architectural improvements
- Generate test coverage reports

#### ❌ What Claude Code CANNOT Do (Requires Human)

**Strategic Decisions:**
- Architecture redesign (microservices vs monolith)
- Technology stack migration (React → Vue)
- Database schema changes
- API versioning strategy
- Performance optimization (needs profiling)

**Domain Knowledge:**
- Business logic correctness
- Regulatory compliance requirements
- User experience decisions
- Feature prioritization
- Risk assessment

**Large-Scale Changes:**
- Entire codebase restructuring in one shot
- Breaking API changes without stakeholder input
- Database migrations without testing
- Deployment strategy changes

### Session Planning

**Small Codebase (<10K LOC):**
- Sessions needed: 1-3
- Duration: 2-6 hours total
- Approach: Can analyze most of codebase at once

**Medium Codebase (10-100K LOC):**
- Sessions needed: 5-15
- Duration: 1-3 days total
- Approach: Chunk by module/feature
- Focus: High-priority areas first

**Large Codebase (>100K LOC):**
- Sessions needed: 20-50+
- Duration: 1-2 weeks total
- Approach: Incremental, phased over weeks
- Focus: Critical paths, then expand

---

## 📊 Assessment System

### Phase 1: Automated Analysis

Run comprehensive quality assessment:

```bash
# In your legacy project
assess-codebase

# Generates:
# - .quality/assessment-report.json
# - .quality/ASSESSMENT_SUMMARY.md
# - .quality/metrics.db (SQLite database)
```

**Metrics Collected:**

1. **Code Statistics** (tokei)
   - Total files, lines of code
   - Language breakdown
   - Comment ratio

2. **Complexity** (lizard, radon)
   - Cyclomatic complexity (CCN)
   - Cognitive complexity
   - Function length
   - Top 50 most complex functions

3. **Duplication** (JSCPD)
   - Duplicate percentage
   - Duplicate blocks
   - Clone families

4. **Security** (Gitleaks, Semgrep)
   - Exposed secrets
   - Security vulnerabilities
   - Unsafe patterns

5. **Test Coverage** (language-specific)
   - Line coverage %
   - Branch coverage %
   - Uncovered critical paths

6. **Dependencies** (npm audit, pip-audit)
   - Vulnerable dependencies
   - Outdated packages
   - License issues

7. **Code Churn** (git log analysis)
   - Most-changed files
   - Change frequency
   - Hotspot analysis

8. **Architecture** (dependency analysis)
   - Module coupling
   - Circular dependencies
   - Dependency depth

### Phase 2: AI-Powered Analysis

Generate self-aware remediation plan:

```bash
# Generate intelligent plan with AI self-awareness
generate-remediation-plan

# Generates:
# - REMEDIATION_PLAN.md (phased approach)
# - .quality/ai-limitations.md (known boundaries)
# - .quality/session-plan.md (chunking strategy)
```

**Plan Includes:**

1. **Executive Summary**
   - Codebase health score (0-100)
   - Critical issues count
   - Estimated remediation time
   - AI session requirements

2. **Phased Roadmap**
   - Phase 1: Critical security (Week 1)
   - Phase 2: Complexity reduction (Weeks 2-3)
   - Phase 3: Test coverage (Weeks 4-5)
   - Phase 4: Duplication elimination (Week 6)
   - Phase 5: Architecture improvements (Weeks 7-8)

3. **AI Session Planning**
   - Total sessions needed
   - Files per session
   - Suggested batching strategy
   - Human decision points

4. **Risk Assessment**
   - High-risk refactorings
   - Rollback points
   - Testing requirements
   - Validation criteria

---

## 🔧 Remediation Workflows

### Workflow 1: Security-First Rescue

**Priority**: Fix critical security issues immediately

```bash
# 1. Identify security issues
assess-security

# 2. Generate security remediation plan
plan-security-fixes

# 3. Apply fixes in batches
fix-security-batch --batch=1
# Runs tests, commits with detailed message

# 4. Verify fixes
verify-security-fixes
```

**AI Self-Awareness:**
- Each batch: 10-20 files max
- Gitleaks findings: Can auto-fix most
- Semgrep findings: May need human review
- Session time: 30-60 min per batch

### Workflow 2: Complexity Reduction

**Priority**: Reduce cyclomatic complexity in hotspots

```bash
# 1. Identify high-complexity functions
identify-complexity-hotspots
# Lists functions with CCN > 15

# 2. Generate refactoring plan for top 20
plan-complexity-reduction --top=20

# 3. Refactor batch by batch
refactor-complexity-batch --batch=1
# Refactors 5 functions at a time
# Adds characterization tests first

# 4. Verify improvements
verify-complexity-reduction
```

**AI Self-Awareness:**
- Can handle functions up to ~200 lines
- Needs characterization tests for safety
- Extracts helper methods automatically
- Reviews diffs before committing

### Workflow 3: Test Coverage Expansion

**Priority**: Add tests for critical, untested paths

```bash
# 1. Identify coverage gaps
identify-coverage-gaps

# 2. Prioritize by criticality & complexity
prioritize-test-targets
# Scores: (criticality × complexity × change_frequency)

# 3. Generate tests in batches
generate-tests-batch --batch=1
# Creates tests for 10 functions

# 4. Review and refine
review-generated-tests
# Human reviews, AI refines based on feedback
```

**AI Self-Awareness:**
- Generates characterization tests first
- Then proper unit tests
- Can't verify business logic correctness
- Needs human review for edge cases

### Workflow 4: Duplication Elimination

**Priority**: Extract common code into utilities

```bash
# 1. Find duplication clusters
find-duplication-clusters
# Groups similar code blocks

# 2. Plan extraction strategy
plan-duplication-removal --threshold=5

# 3. Extract utilities batch by batch
extract-utilities-batch --batch=1
# Creates shared utilities
# Updates call sites
# Adds tests for utilities

# 4. Verify behavior unchanged
verify-refactoring-safety
```

**AI Self-Awareness:**
- Extracts utilities for 3+ duplicates
- Updates call sites automatically
- Adds tests for new utilities
- Verifies via existing tests

### Workflow 5: Incremental Architecture Improvement

**Priority**: Improve module structure over time

```bash
# 1. Analyze current architecture
analyze-architecture
# Generates dependency graphs
# Identifies circular dependencies
# Suggests module boundaries

# 2. Plan restructuring (requires human decisions)
plan-architecture-improvements
# AI suggests, human approves

# 3. Apply Strangler Fig Pattern
strangle-module --old=legacy/auth --new=core/auth
# Gradually redirects imports
# Tests both paths
# Switches when confident

# 4. Monitor migration progress
track-strangler-progress
```

**AI Self-Awareness:**
- Cannot decide architecture
- Can suggest module boundaries
- Can implement approved plans
- Needs human approval at each phase

---

## 📈 Progress Tracking

### Quality Dashboard

```bash
# View current quality metrics
quality-dashboard

# Output:
┌─────────────────────────────────────────────┐
│     Codebase Quality Dashboard              │
├─────────────────────────────────────────────┤
│ Health Score:        45/100  (🔴 Poor)      │
│ Technical Debt:      $125K   (High)         │
│ Trend:               ▲ +5 pts (improving)   │
├─────────────────────────────────────────────┤
│ Complexity:          AVG 18  (🔴 High)      │
│   Functions >15:     234     (Target: <50)  │
│   Max CCN:           47      (Worst: auth)  │
├─────────────────────────────────────────────┤
│ Test Coverage:       23%     (🔴 Low)       │
│   Critical paths:    12%     (Dangerous!)   │
│   Changed files:     8%      (Very risky)   │
├─────────────────────────────────────────────┤
│ Duplication:         18%     (🔴 High)      │
│   Clone families:    67      (Target: <20)  │
│   Wasted LOC:        ~9K     (Cost: $45K)   │
├─────────────────────────────────────────────┤
│ Security:            🔴 12 Critical Issues   │
│   Secrets exposed:   3       (Fix NOW!)     │
│   Vulnerabilities:   9       (High risk)    │
└─────────────────────────────────────────────┘
```

### Progress Tracking

```bash
# Compare to baseline
quality-progress --since=baseline

# Show improvement trends
quality-trends --weeks=4

# Generate stakeholder report
generate-progress-report --format=pdf
```

**Tracked Metrics:**
- Health score trend (weekly)
- Complexity reduction (# functions fixed)
- Test coverage growth (% increase)
- Duplication elimination (% decrease)
- Security issues resolved (count)
- Technical debt reduction ($)

### Burndown Chart

```bash
# Visualize remediation progress
show-remediation-burndown

# ASCII chart:
Technical Debt Burndown

$150K ┤                                    ●
      │                                ●
$125K ┤                            ●
      │                        ●
$100K ┤                    ●
      │                ●
 $75K ┤            ●
      │        ●
 $50K ┤    ●
      │●
 $25K ┼────┬────┬────┬────┬────┬────┬────
      W1   W2   W3   W4   W5   W6   W7   W8

Target: $50K by Week 8 (on track!)
```

---

## 🎯 Prioritization Framework

### Priority Matrix

```
High Impact, Low Effort (DO FIRST):
├─ Security fixes (exposed secrets)
├─ High-complexity functions in hotspots
├─ Test coverage for critical paths
└─ Obvious code duplication

High Impact, High Effort (SCHEDULE):
├─ Architecture restructuring
├─ Database schema improvements
├─ API redesign
└─ Performance optimization

Low Impact, Low Effort (QUICK WINS):
├─ Code formatting
├─ Dead code removal
├─ Comment improvements
└─ Variable renaming

Low Impact, High Effort (AVOID):
├─ Over-engineering
├─ Premature optimization
├─ Nice-to-have features
└─ Vanity metrics
```

### Scoring Algorithm

```python
Priority Score = (
    Criticality × 0.40 +      # Business impact
    Complexity × 0.25 +        # Current complexity
    Change_Frequency × 0.20 +  # Hotspot analysis
    Test_Coverage_Gap × 0.15   # Risk level
)

Where:
  Criticality: 1-10 (business impact)
  Complexity: CCN / 10
  Change_Frequency: commits_last_30d / 10
  Test_Coverage_Gap: (100 - coverage%) / 10
```

---

## 🔄 Incremental Refactoring Patterns

### Pattern 1: Strangler Fig

**Use Case**: Gradually replace old system with new

```bash
# 1. Create new implementation alongside old
create-new-module --name=auth --alongside=legacy/auth

# 2. Add feature toggle
add-feature-toggle --name=use_new_auth --default=false

# 3. Route percentage of traffic to new
route-traffic --new=10%  # Start small

# 4. Monitor for issues
monitor-strangler --module=auth --duration=1week

# 5. Increase traffic gradually
route-traffic --new=25%
route-traffic --new=50%
route-traffic --new=100%

# 6. Remove old code
remove-strangled-module --name=legacy/auth
```

### Pattern 2: Characterization Tests

**Use Case**: Test existing behavior before refactoring

```bash
# 1. Generate characterization tests
characterize-function --file=utils.js --function=processPayment

# Creates tests that capture CURRENT behavior
# (even if it's buggy - we'll fix separately)

# 2. Refactor with confidence
refactor-function --file=utils.js --function=processPayment

# 3. Verify behavior unchanged
run-characterization-tests

# 4. Now fix bugs with proper tests
fix-bugs-with-tests --function=processPayment
```

### Pattern 3: Branch by Abstraction

**Use Case**: Change implementation without changing interface

```bash
# 1. Extract interface
extract-interface --from=LegacyEmailSender --to=IEmailSender

# 2. Create new implementation
create-implementation --interface=IEmailSender --name=ModernEmailSender

# 3. Use feature toggle
toggle-implementation --interface=IEmailSender --impl=ModernEmailSender --toggle=use_modern_email

# 4. Test both implementations
test-implementations --interface=IEmailSender

# 5. Switch gradually
enable-toggle --name=use_modern_email --rollout=gradual
```

### Pattern 4: Parallel Run

**Use Case**: Run old and new code, compare results

```bash
# 1. Setup parallel execution
setup-parallel-run --old=calculateDiscount --new=calculateDiscountV2

# 2. Run both, log differences
enable-parallel-run --log-differences=true

# 3. Analyze differences over time
analyze-parallel-results --days=7

# 4. When confident, switch
switch-to-new --function=calculateDiscountV2

# 5. Remove old code
remove-old-function --name=calculateDiscount
```

---

## 🛠️ Available Scripts

### Assessment

- **`assess-codebase`** - Comprehensive quality analysis
- **`assess-security`** - Security-focused scan
- **`assess-complexity`** - Complexity hotspots
- **`assess-coverage`** - Test coverage gaps
- **`assess-duplication`** - Code duplication analysis

### Planning

- **`generate-remediation-plan`** - AI-powered phased plan with self-awareness
- **`plan-security-fixes`** - Security remediation strategy
- **`plan-complexity-reduction`** - Complexity reduction roadmap
- **`plan-test-expansion`** - Test coverage expansion plan
- **`plan-architecture-improvements`** - Architecture refactoring suggestions

### Execution

- **`fix-security-batch`** - Apply security fixes incrementally
- **`refactor-complexity-batch`** - Reduce complexity in batches
- **`generate-tests-batch`** - Add tests incrementally
- **`extract-utilities-batch`** - Eliminate duplication
- **`strangle-module`** - Apply Strangler Fig pattern

### Tracking

- **`quality-dashboard`** - Real-time quality metrics
- **`quality-progress`** - Progress since baseline
- **`quality-trends`** - Trend analysis over time
- **`show-remediation-burndown`** - Burndown chart
- **`generate-progress-report`** - Stakeholder report

---

## 📚 Case Study Example

### Before: The E-Commerce Mess

```
Codebase: 75K LOC JavaScript/Python
Age: 5 years
Team: 8 developers
```

**Metrics:**
- Health Score: 32/100 (Critical)
- Avg Complexity: 24 CCN
- Test Coverage: 8%
- Duplication: 35%
- Security Issues: 23 critical
- Technical Debt: $450K

**Pain Points:**
- 3-week deployment cycles
- 40% of deploys have rollbacks
- Can't onboard new developers (<3 months)
- Features take 3x longer than estimated

### Remediation Journey

**Week 1-2: Critical Security**
```bash
assess-security
fix-security-batch --all-critical
# Fixed: 23 → 0 critical issues
# Time: 12 hours across 8 sessions
```

**Week 3-4: Complexity Hotspots**
```bash
identify-complexity-hotspots
refactor-complexity-batch --top=30
# Reduced: AVG 24 → 16 CCN
# Fixed: Top 30 most complex functions
# Time: 20 hours across 15 sessions
```

**Week 5-7: Test Coverage**
```bash
generate-tests-batch --priority=critical
# Coverage: 8% → 45%
# Added: 1,200 tests
# Time: 30 hours across 20 sessions
```

**Week 8-9: Duplication Elimination**
```bash
extract-utilities-batch --threshold=3
# Duplication: 35% → 12%
# Extracted: 45 utility functions
# Time: 15 hours across 10 sessions
```

**Week 10-12: Architecture Improvements**
```bash
strangle-module --old=legacy/checkout --new=core/checkout
# Migrated: 30% of checkout flow
# (Ongoing via Strangler Fig)
```

### After: The Transformed Codebase

**Metrics (12 weeks later):**
- Health Score: 72/100 (Good)
- Avg Complexity: 11 CCN
- Test Coverage: 68%
- Duplication: 8%
- Security Issues: 0 critical
- Technical Debt: $180K (60% reduction)

**Business Impact:**
- Deployment cycle: 3 weeks → 2 days
- Rollback rate: 40% → 5%
- Onboarding time: 3 months → 3 weeks
- Feature velocity: 3x → 1.2x (improving)

**AI Sessions Used:**
- Total sessions: 65
- Total AI time: ~95 hours
- Human oversight: ~40 hours
- Total investment: $15K (AI) + $8K (human)
- ROI: $270K debt reduction / $23K cost = 11.7x

---

## 🚨 Common Pitfalls & Solutions

### Pitfall 1: Trying to Fix Everything at Once

**Problem**: Overwhelming scope leads to analysis paralysis

**Solution**:
```bash
# Start with security
assess-security && fix-security-batch --critical-only

# Then complexity in ONE module
refactor-complexity-batch --module=auth --top=10

# Build momentum with wins
```

### Pitfall 2: Ignoring AI Token Limits

**Problem**: Trying to analyze 200K LOC in one session

**Solution**:
```bash
# Let AI plan the chunking
generate-remediation-plan

# Follow the session plan
# Session 1: Module A (50 files)
# Session 2: Module B (50 files)
# etc.
```

### Pitfall 3: Refactoring Without Tests

**Problem**: Breaking functionality while improving code

**Solution**:
```bash
# ALWAYS characterize first
characterize-function --before-refactoring

# Then refactor
refactor-with-tests --function=processOrder

# Verify behavior unchanged
verify-characterization-tests
```

### Pitfall 4: Ignoring Business Context

**Problem**: AI doesn't understand business criticality

**Solution**:
```bash
# Human prioritizes
prioritize-modules --by=business-impact

# AI executes within constraints
refactor-batch --modules=$(cat priority-modules.txt)
```

### Pitfall 5: No Progress Tracking

**Problem**: Can't prove ROI to stakeholders

**Solution**:
```bash
# Baseline at start
assess-codebase --save-baseline

# Track weekly
quality-progress --weekly-report

# Generate stakeholder reports
generate-progress-report --format=pdf --send-to=stakeholders@company.com
```

---

## 🎓 Best Practices

### 1. Start with Security
Always fix critical security issues first. Nothing else matters if you're leaking data.

### 2. Small Batches, Frequent Commits
Refactor 5-10 files at a time, commit after each batch. Easy to review, easy to rollback.

### 3. Tests Before Refactoring
Add characterization tests, then refactor, then improve tests. Never refactor without a safety net.

### 4. Monitor Metrics Weekly
Track progress every week. Celebrate wins, adjust strategy based on data.

### 5. Human-in-the-Loop
AI suggests, human approves critical decisions. Never blindly apply AI suggestions.

### 6. Strangler Over Rewrite
Gradually replace old code with new. Rewrites fail 80% of the time.

### 7. Automate Quality Gates
Once improved, add pre-commit hooks to prevent regression.

### 8. Document Decisions
Record why you made architectural choices. Future you (and team) will thank you.

---

## 📖 Further Reading

- **Working Effectively with Legacy Code** - Michael Feathers
- **Refactoring** - Martin Fowler
- **The Strangler Fig Pattern** - Martin Fowler
- **Technical Debt Management** - Best practices from industry

---

**Ready to rescue your legacy codebase?** Start with `assess-codebase` and let the AI-powered remediation planning begin!
