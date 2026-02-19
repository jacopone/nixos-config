#!/usr/bin/env bash
# claude-autonomous.sh - Run Claude autonomously in sandboxed git worktrees
#
# Usage:
#   claude-autonomous.sh <repo-path> <task-name> "<prompt>"
#
# Example:
#   claude-autonomous.sh ~/myproject feature-auth "Implement JWT authentication with refresh tokens"
#
# This will:
#   1. Create a git worktree for isolated work
#   2. Launch Claude with --dangerously-skip-permissions (native sandbox auto-enabled)
#   3. Run in background with tmux so you can sleep
#   4. Log everything for review in the morning

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<EOF
${BLUE}Claude Autonomous Worker${NC}

Usage: $0 [options] <repo-path> <task-name> "<prompt>"

Arguments:
  repo-path   Path to the git repository
  task-name   Name for the worktree/branch (e.g., feature-auth)
  prompt      The task for Claude to complete

Options:
  --strict        Enable strict mode (80% coverage required, security scan)
  --max-iter N    Max iterations before stopping (default: 5)
  --no-ralph      Single-pass mode: run once and exit (no retry loop)
  --list          List active autonomous sessions
  --stop          Stop a session: $0 --stop <task-name>
  --cleanup       Remove completed worktrees

By default, Claude runs in a loop (Ralph mode) up to 5 iterations, stopping
early when COMPLETED.md or BLOCKERS.md appears. Each iteration gets a fresh
context window — Claude reads git history to resume where it left off.

Examples:
  $0 ~/myproject feature-auth "Implement JWT authentication"
  $0 --strict ~/myproject auth-system "Implement secure authentication"
  $0 --max-iter 10 ~/myproject refactor-cache "Refactor the cache layer"
  $0 --no-ralph ~/myproject bugfix-123 "Quick single-pass fix"

The session runs in tmux. Attach with: tmux attach -t claude-<task-name>
EOF
}

list_sessions() {
    echo -e "${BLUE}Active Claude Autonomous Sessions:${NC}"
    tmux list-sessions 2>/dev/null | grep "^claude-" || echo "  (none)"
    echo ""
    echo -e "${BLUE}Active Worktrees:${NC}"
    if [[ -d "${REPO_PATH:-.}" ]]; then
        git -C "${REPO_PATH:-.}" worktree list 2>/dev/null | grep -v "^/" | head -1 || true
        git -C "${REPO_PATH:-.}" worktree list 2>/dev/null | grep "\.worktrees" || echo "  (none)"
    fi
}

stop_session() {
    local task="$1"
    echo -e "${YELLOW}Stopping session: claude-${task}${NC}"
    tmux kill-session -t "claude-${task}" 2>/dev/null && echo -e "${GREEN}✓ Session stopped${NC}" || echo -e "${RED}Session not found${NC}"
}

cleanup_worktrees() {
    echo -e "${BLUE}Cleaning up worktrees...${NC}"
    local repo="${1:-.}"
    git -C "$repo" worktree list | grep "\.worktrees" | while read -r line; do
        local wt_path
        wt_path=$(echo "$line" | awk '{print $1}')
        local branch
        branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        echo -n "  Remove $wt_path ($branch)? [y/N] "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            git -C "$repo" worktree remove "$wt_path" --force 2>/dev/null || rm -rf "$wt_path"
            echo -e "    ${GREEN}✓ Removed${NC}"
        fi
    done
}

# Parse arguments
STRICT_MODE=false
RALPH_MODE=true
RALPH_MAX=5

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list|-l)
            list_sessions
            exit 0
            ;;
        --stop|-s)
            [[ -z "${2:-}" ]] && { echo "Usage: $0 --stop <task-name>"; exit 1; }
            stop_session "$2"
            exit 0
            ;;
        --cleanup|-c)
            cleanup_worktrees "${2:-.}"
            exit 0
            ;;
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --no-ralph)
            RALPH_MODE=false
            shift
            ;;
        --max-iter)
            [[ -z "${2:-}" || ! "${2:-}" =~ ^[0-9]+$ ]] && { echo "Usage: --max-iter N"; exit 1; }
            RALPH_MAX="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Validate arguments
REPO_PATH="${1:-}"
TASK_NAME="${2:-}"
PROMPT="${3:-}"

if [[ -z "$REPO_PATH" ]] || [[ -z "$TASK_NAME" ]] || [[ -z "$PROMPT" ]]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    usage
    exit 1
fi

if [[ ! -d "$REPO_PATH/.git" ]]; then
    echo -e "${RED}Error: $REPO_PATH is not a git repository${NC}"
    exit 1
fi

# Setup paths
REPO_PATH=$(realpath "$REPO_PATH")
REPO_NAME=$(basename "$REPO_PATH")
WORKTREE_BASE="${REPO_PATH}/.worktrees"
WORKTREE_PATH="${WORKTREE_BASE}/${TASK_NAME}"
BRANCH_NAME="autonomous/${TASK_NAME}"
LOG_DIR="${HOME}/.claude/autonomous-logs"
LOG_FILE="${LOG_DIR}/${REPO_NAME}-${TASK_NAME}-$(date +%Y%m%d-%H%M%S).log"
SESSION_NAME="claude-${TASK_NAME}"

# Create directories
mkdir -p "$WORKTREE_BASE" "$LOG_DIR"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Claude Autonomous Worker Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Repository:  ${GREEN}$REPO_PATH${NC}"
echo -e "  Task:        ${GREEN}$TASK_NAME${NC}"
echo -e "  Worktree:    ${GREEN}$WORKTREE_PATH${NC}"
echo -e "  Branch:      ${GREEN}$BRANCH_NAME${NC}"
echo -e "  Log:         ${GREEN}$LOG_FILE${NC}"
if [[ "$STRICT_MODE" == "true" ]]; then
    echo -e "  Mode:        ${YELLOW}STRICT (80% coverage, security scan)${NC}"
fi
if [[ "$RALPH_MODE" == "true" ]]; then
    echo -e "  Ralph Loop:  ${YELLOW}ON (max $RALPH_MAX iterations)${NC}"
else
    echo -e "  Ralph Loop:  ${YELLOW}OFF (single pass)${NC}"
fi
echo ""

# Check if worktree already exists
if [[ -d "$WORKTREE_PATH" ]]; then
    echo -e "${YELLOW}⚠ Worktree already exists. Reusing it.${NC}"
else
    # Create branch and worktree
    echo -e "${BLUE}[1/3] Creating worktree...${NC}"
    cd "$REPO_PATH"

    # Create branch from current HEAD if it doesn't exist
    if ! git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
        git branch "$BRANCH_NAME" 2>/dev/null || true
    fi

    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
    echo -e "  ${GREEN}✓ Worktree created${NC}"
fi

# Override .mcp.json with headless Playwright (no --extension flag)
# Interactive sessions use --extension mode (connects to running Chrome),
# but autonomous sessions run unattended and need headless mode.
cat > "${WORKTREE_PATH}/.mcp.json" << 'MCP_EOF'
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
MCP_EOF
echo -e "  ${GREEN}✓ Headless Playwright MCP configured${NC}"

# Copy demo credentials if available (gitignored local file)
if [[ -f "${REPO_PATH}/.claude/demo-credentials.local" ]]; then
    cp "${REPO_PATH}/.claude/demo-credentials.local" "${WORKTREE_PATH}/.claude/demo-credentials.local" 2>/dev/null || {
        mkdir -p "${WORKTREE_PATH}/.claude"
        cp "${REPO_PATH}/.claude/demo-credentials.local" "${WORKTREE_PATH}/.claude/demo-credentials.local"
    }
    echo -e "  ${GREEN}✓ Demo credentials copied${NC}"
fi

# Check if session already running
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Session already running. Attach with: tmux attach -t ${SESSION_NAME}${NC}"
    exit 0
fi

# Create the prompt file for Claude
PROMPT_FILE="${WORKTREE_PATH}/.claude-task.md"
cat > "$PROMPT_FILE" << PROMPT_EOF
# Autonomous Task: ${TASK_NAME}

## Instructions

${PROMPT}

## Test-Driven Development (MANDATORY)

Follow this workflow strictly:

### Phase 1: Establish Baseline
Before writing any feature code:
1. Run the existing test suite and note results
2. Check current test coverage percentage
3. Document baseline in \`BASELINE.md\`:
   - Number of passing tests
   - Current coverage %
   - Any pre-existing failures

### Phase 2: Write Tests First (Red Phase)
1. Create test file: \`tests/test_<feature>.py\` (or appropriate location)
2. Write tests that define the expected behavior
3. Tests should FAIL initially (this is expected - red phase)
4. Cover: happy path, edge cases, error conditions

### Phase 3: Implement (Green Phase)
1. Write the minimum code to make tests pass
2. Run tests frequently during implementation
3. Commit when tests go from red to green

### Phase 4: Refactor (if needed)
1. Clean up code while keeping tests green
2. No new functionality in this phase

## Judge-Driven Execution (MANDATORY)

You work in **30-minute cycles** with explicit evaluation after each:

### Cycle Structure
1. **WORK (30 min)**: Focus on completing PROGRESS.md checklist items (if exists) or task deliverables
2. **VERIFY**: Run tests, check coverage, lint
3. **JUDGE**: Evaluate continue vs stop based on the matrix below

### At End of Each Cycle
If PROGRESS.md exists in the worktree, update it with:
- Check off items completed this cycle
- Add test results to Cycle History table
- Update Current Checkpoint section

### Judge Decision Matrix
| Condition | Action |
|-----------|--------|
| Items remain AND tests pass | Mark cycle complete, continue to next |
| Items remain AND tests fail | Fix tests first, then continue |
| All items complete AND tests pass | Create COMPLETED.md, stop |
| Stuck 2+ cycles on same item | Create BLOCKERS.md, stop |

### INVARIANTS.md Compliance
If INVARIANTS.md exists in the worktree, before EVERY commit verify:
- [ ] No INVARIANTS.md violations
- [ ] All tests passing
- [ ] Coverage not decreased from baseline

## Verification Requirements (MANDATORY)

Before marking this task complete, ALL must pass:

\`\`\`bash
# 1. All tests pass (zero regressions)
pytest tests/ -v --tb=short

# 2. Linting passes
ruff check . --fix

# 3. Type checking (if applicable)
mypy src/ --ignore-missing-imports || true

# 4. Coverage check (must not decrease from baseline)
pytest --cov=src --cov-report=term-missing
\`\`\`

### Failure Protocol
If ANY verification step fails:
- Fix the issue immediately
- Re-run ALL verification steps
- Do NOT mark complete until everything passes
- Document any issues that required multiple attempts

## Guidelines

- Work autonomously until the task is complete
- Create meaningful commits as you progress (small, focused commits)
- If you encounter blockers, document them in \`BLOCKERS.md\`
- When finished, create \`COMPLETED.md\` with:
  - Summary of changes
  - Test results (copy/paste actual output)
  - Coverage before/after
  - Any known limitations
- Do NOT push to remote (I'll review first)

## Context

- Working in git worktree: ${WORKTREE_PATH}
- Branch: ${BRANCH_NAME}
- Started: $(date)
PROMPT_EOF

# Append demo report instructions
cat >> "$PROMPT_FILE" << 'DEMO_EOF'

## Demo Report (MANDATORY)

After completing your primary task and all verification steps, produce a demo report.

### Step 1: Check for Demo Configuration

Look for `.claude/demo-config.md` in the working directory. This file tells you what to demo visually.

### Step 2a: If `.claude/demo-config.md` EXISTS (Visual Demo)

1. Create a `.demo/` directory in the worktree root
2. Start the dev server using the command specified in demo-config.md
3. Wait for the ready signal in stdout before proceeding
4. **Authenticate**: Check for `.claude/demo-credentials.local` in the working directory.
   If it exists, read it for per-role login credentials. The file has sections like:
   ```
   ## client
   - login_tab: Cliente
   - email: user@example.com
   - password: Pass123!
   - role: client_admin
   - pages: /client-area, /my-portal
   ```
   To log in:
   - Navigate to /auth
   - Click the correct tab (e.g., "Contabile" or "Cliente" matching `login_tab`)
   - Fill email and password fields
   - Click the login button
   - Choose the role whose `pages` list best matches the pages affected by your changes
   - If your changes affect multiple roles, log in as each role and screenshot their pages
5. Use Playwright MCP tools to:
   - Navigate to each page affected by your changes
   - Take a screenshot of each, saving to `.demo/NN-description.png`
   - If demo-config.md specifies key pages, also screenshot those for context
6. Stop the dev server when done

### Step 2b: If `.claude/demo-config.md` DOES NOT EXIST (Text-Only Demo)

Skip screenshots. You will still write DEMO.md but without visual evidence.

### Step 3: Write DEMO.md

Create `.demo/DEMO.md` (inside the `.demo/` directory alongside the screenshots) with this structure:

```
# Demo: <task-name>
**Branch:** <current branch>
**Date:** <today>

## Summary
[1-2 sentences: what you built and why]

## Changes Made
- [List each file changed with a brief description of what changed]

## Visual Demo
(Only if .claude/demo-config.md exists)
### [Page/Feature Name]
![Description](.demo/01-description.png)
[What this screenshot shows and why it matters]

## Test Results
- Unit tests: [pass/fail count from actual test run]
- E2E tests: [pass/fail count, or "not run" if not applicable]
- Build: [success/failure]
- Coverage: [percentage if available]

## Open Questions
- [Anything you were uncertain about or design decisions the reviewer should validate]
```

IMPORTANT: The demo report is the LAST thing you do. Complete all coding, testing, and verification first. The demo report documents finished work, not work in progress.

Do NOT commit DEMO.md or the .demo/ directory to git. These are review artifacts for the human reviewer, not source code.
DEMO_EOF

# Add strict mode requirements if enabled
if [[ "$STRICT_MODE" == "true" ]]; then
    cat >> "$PROMPT_FILE" << 'STRICT_EOF'

## STRICT MODE: Additional Requirements

This task runs in STRICT mode with enhanced verification:

### Coverage Requirements
- New code MUST have ≥80% test coverage
- Run: `pytest --cov=src --cov-fail-under=80`
- If coverage is below 80%, add more tests before proceeding

### Security Scan (if bandit available)
- Run: `bandit -r src/ -ll` (medium+ severity)
- Fix any security issues before marking complete
- Document any false positives in COMPLETED.md

### Type Safety
- All new functions MUST have type hints
- Run: `mypy src/ --strict` (not just ignore-missing-imports)
- Fix all type errors

### Documentation
- All public functions need docstrings
- Update README.md if adding new features
- Add inline comments for complex logic

### Commit Standards
- Each commit must pass all verification steps
- Use conventional commit format: `feat:`, `fix:`, `test:`, `docs:`
- No commits with failing tests allowed
STRICT_EOF
fi

echo -e "${BLUE}[2/3] Launching Claude in sandbox...${NC}"
echo -e "  ${YELLOW}Using Claude Code native sandbox (bubblewrap + seccomp)${NC}"

# Write the tmux runner script (avoids quoting issues with fish/bash/tmux)
RUNNER_SCRIPT="${WORKTREE_PATH}/.claude-runner.sh"
cat > "$RUNNER_SCRIPT" << RUNNER_EOF
#!/usr/bin/env bash
set -uo pipefail

# Use Max subscription, not API credits
unset ANTHROPIC_API_KEY

LOG_FILE='$LOG_FILE'
WORKTREE_PATH='$WORKTREE_PATH'
TASK_NAME='$TASK_NAME'
PROMPT_FILE='$PROMPT_FILE'

echo '═══════════════════════════════════════════════════════════' | tee -a "\$LOG_FILE"
echo "  Claude Autonomous Session: \$TASK_NAME" | tee -a "\$LOG_FILE"
echo "  Started: \$(date)" | tee -a "\$LOG_FILE"
echo "  Worktree: \$WORKTREE_PATH" | tee -a "\$LOG_FILE"
echo '═══════════════════════════════════════════════════════════' | tee -a "\$LOG_FILE"
echo '' | tee -a "\$LOG_FILE"

RUNNER_EOF

# Append the Claude invocation (Ralph loop or single pass)
if [[ "$RALPH_MODE" == "true" ]]; then
    cat >> "$RUNNER_SCRIPT" << RALPH_EOF
for i in \$(seq 1 $RALPH_MAX); do
    echo "  Ralph iteration \$i/$RALPH_MAX" | tee -a "\$LOG_FILE"
    cat "\$PROMPT_FILE" | claude "\$WORKTREE_PATH" \\
        --dangerously-skip-permissions \\
        2>&1 | tee -a "\$LOG_FILE"
    if [ -f "\$WORKTREE_PATH/COMPLETED.md" ]; then
        echo '  Ralph: COMPLETED.md found, stopping loop' | tee -a "\$LOG_FILE"
        break
    fi
    if [ -f "\$WORKTREE_PATH/BLOCKERS.md" ]; then
        echo '  Ralph: BLOCKERS.md found, stopping loop' | tee -a "\$LOG_FILE"
        break
    fi
    echo '  Ralph: No completion marker, continuing...' | tee -a "\$LOG_FILE"
done
RALPH_EOF
else
    cat >> "$RUNNER_SCRIPT" << SINGLE_EOF
cat "\$PROMPT_FILE" | claude "\$WORKTREE_PATH" \\
    --dangerously-skip-permissions \\
    2>&1 | tee -a "\$LOG_FILE"
SINGLE_EOF
fi

# Append session footer
cat >> "$RUNNER_SCRIPT" << 'FOOTER_EOF'

echo '' | tee -a "$LOG_FILE"
echo '═══════════════════════════════════════════════════════════' | tee -a "$LOG_FILE"
echo "  Session ended: $(date)" | tee -a "$LOG_FILE"
echo '  Press Enter to close...' | tee -a "$LOG_FILE"
read
FOOTER_EOF

chmod +x "$RUNNER_SCRIPT"

# Launch in tmux using the runner script (shell-agnostic)
tmux new-session -d -s "$SESSION_NAME" -c "$WORKTREE_PATH" "$RUNNER_SCRIPT"

echo -e "  ${GREEN}✓ Claude launched in tmux session${NC}"

echo ""
echo -e "${BLUE}[3/3] Session running!${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Claude is now working autonomously on: ${TASK_NAME}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BLUE}Monitor:${NC}     tmux attach -t ${SESSION_NAME}"
echo -e "  ${BLUE}View log:${NC}    tail -f ${LOG_FILE}"
echo -e "  ${BLUE}Stop:${NC}        $0 --stop ${TASK_NAME}"
echo -e "  ${BLUE}List:${NC}        $0 --list"
echo ""
echo -e "  ${YELLOW}Safe to close terminal - Claude runs in background!${NC}"
echo ""
