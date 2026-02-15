---
status: draft
created: 2026-02-15
updated: 2026-02-15
type: planning
lifecycle: persistent
---

# Demo Reports Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add structured visual demo report generation to autonomous agent workflow so overnight work can be visually verified during morning review.

**Architecture:** Three-layer convention: (1) per-project `.claude/demo-config.md` opts projects into visual demos, (2) `claude-autonomous.sh` injects demo report instructions into the agent prompt, (3) `claude-morning-review.sh` detects and displays `DEMO.md` alongside existing status markers.

**Tech Stack:** Bash (scripts), Markdown (config + output), Playwright MCP (screenshots via agent)

---

### Task 1: Add Demo Report Prompt Section to `claude-autonomous.sh`

**Files:**
- Modify: `scripts/claude-autonomous.sh:286` (after the PROMPT_EOF closing, before strict mode block)

**Step 1: Add demo report instructions to the prompt file**

Insert a new heredoc block after line 286 (`PROMPT_EOF`) and before line 289 (`if [[ "$STRICT_MODE" == "true" ]]`). This block appends demo report instructions to every autonomous agent prompt:

```bash
# Append demo report instructions
cat >> "$PROMPT_FILE" << 'DEMO_EOF'

## Demo Report (MANDATORY)

After completing your primary task and all verification steps, produce a demo report.

### Step 1: Check for Demo Configuration

Look for `.claude/demo-config.md` in the project root. This file tells you what to demo visually.

### Step 2a: If `.claude/demo-config.md` EXISTS (Visual Demo)

1. Create a `.demo/` directory in the worktree root
2. Start the dev server using the command specified in demo-config.md
3. Wait for the ready signal in stdout before proceeding
4. Use Playwright MCP tools to:
   - Navigate to each page affected by your changes
   - Take a screenshot of each, saving to `.demo/NN-description.png`
   - If demo-config.md specifies key pages, also screenshot those for context
5. Stop the dev server when done

### Step 2b: If `.claude/demo-config.md` DOES NOT EXIST (Text-Only Demo)

Skip screenshots. You will still write DEMO.md but without visual evidence.

### Step 3: Write DEMO.md

Create `DEMO.md` at the worktree root with this structure:

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
DEMO_EOF
```

**Step 2: Verify the script still parses correctly**

Run: `bash -n scripts/claude-autonomous.sh`
Expected: No output (clean parse)

**Step 3: Test the prompt file generation**

Run: `bash scripts/claude-autonomous.sh --help`
Expected: Normal help output (confirms script loads without errors)

**Step 4: Commit**

```bash
git add scripts/claude-autonomous.sh
git commit -m "feat(autonomous): add demo report instructions to agent prompt

Agents now produce DEMO.md after completing work. If .claude/demo-config.md
exists in the project, agents capture screenshots via Playwright MCP."
```

---

### Task 2: Add DEMO.md Detection to Morning Review Status

**Files:**
- Modify: `scripts/claude-morning-review.sh:48-77` (get_worktree_status function)

**Step 1: Add demo report detection to `get_worktree_status`**

The function currently checks for `COMPLETED.md` and `BLOCKERS.md`. It does not need a new status for demo — demo is orthogonal to completion status. Instead, add a separate helper function after `get_test_summary` (after line 119):

```bash
# Check if worktree has a demo report
has_demo_report() {
    local worktree_path="$1"
    [[ -f "$worktree_path/DEMO.md" ]]
}

# Count screenshots in demo
demo_screenshot_count() {
    local worktree_path="$1"
    if [[ -d "$worktree_path/.demo" ]]; then
        find "$worktree_path/.demo" -name "*.png" 2>/dev/null | wc -l
    else
        echo "0"
    fi
}
```

**Step 2: Verify script parses correctly**

Run: `bash -n scripts/claude-morning-review.sh`
Expected: No output (clean parse)

**Step 3: Commit**

```bash
git add scripts/claude-morning-review.sh
git commit -m "feat(morning-review): add demo report detection helpers"
```

---

### Task 3: Show Demo Report Info in Morning Review Table

**Files:**
- Modify: `scripts/claude-morning-review.sh:154-178` (show_review table rendering)

**Step 1: Add a "DEMO" column indicator to the status table**

Update the table header at line 154 to include a demo indicator. Modify the printf format and the loop body to show whether a demo report exists:

Change the header from:
```bash
    printf "  ${CYAN}%-20s %-12s %-40s${NC}\n" "SESSION" "STATUS" "CHANGES"
    printf "  %-20s %-12s %-40s\n" "────────────────────" "────────────" "────────────────────────────────────────"
```

To:
```bash
    printf "  ${CYAN}%-20s %-12s %-8s %-40s${NC}\n" "SESSION" "STATUS" "DEMO" "CHANGES"
    printf "  %-20s %-12s %-8s %-40s\n" "────────────────────" "────────────" "────────" "────────────────────────────────────────"
```

Change the row printf (line 177) from:
```bash
        printf "  %-20s %s %-10s %-40s\n" "$name" "$emoji" "$status" "$changes"
```

To:
```bash
        # Check for demo report
        local demo_indicator=""
        if has_demo_report "$wt"; then
            local screenshots=$(demo_screenshot_count "$wt")
            if [[ "$screenshots" -gt 0 ]]; then
                demo_indicator="${GREEN}${screenshots} img${NC}"
            else
                demo_indicator="${CYAN}text${NC}"
            fi
        else
            demo_indicator="${MAGENTA}-${NC}"
        fi

        printf "  %-20s %s %-10s %b%-8s %-40s\n" "$name" "$emoji" "$status" "$demo_indicator" "" "$changes"
```

**Step 2: Verify script parses correctly**

Run: `bash -n scripts/claude-morning-review.sh`
Expected: No output (clean parse)

**Step 3: Commit**

```bash
git add scripts/claude-morning-review.sh
git commit -m "feat(morning-review): show demo report column in status table"
```

---

### Task 4: Include Demo Report in Generated Report

**Files:**
- Modify: `scripts/claude-morning-review.sh:389-418` (generate_report function)

**Step 1: Add DEMO.md content to the markdown report**

After the `COMPLETED.md` block (line 406) and the `BLOCKERS.md` block (line 414), add a DEMO.md block:

```bash
            if [[ -f "$wt/DEMO.md" ]]; then
                echo ""
                echo "**Demo Report:**"
                echo ""
                cat "$wt/DEMO.md"
                echo ""
                local screenshots=$(demo_screenshot_count "$wt")
                if [[ "$screenshots" -gt 0 ]]; then
                    echo "*$screenshots screenshots in .demo/ directory*"
                    echo ""
                    echo "View screenshots:"
                    echo '```'
                    ls "$wt/.demo/"*.png 2>/dev/null | while read -r img; do
                        echo "  $(basename "$img")"
                    done
                    echo '```'
                fi
            fi
```

**Step 2: Verify script parses correctly**

Run: `bash -n scripts/claude-morning-review.sh`
Expected: No output (clean parse)

**Step 3: Commit**

```bash
git add scripts/claude-morning-review.sh
git commit -m "feat(morning-review): include demo reports in generated report"
```

---

### Task 5: Show Demo Report in Interactive Merge Flow

**Files:**
- Modify: `scripts/claude-morning-review.sh:270-281` (interactive_merge, per-worktree section)

**Step 1: Show demo report before merge confirmation**

After the diff summary display (line 279) and before the merge confirmation prompt (line 282), add:

```bash
        # Show demo report if available
        if [[ -f "$wt/DEMO.md" ]]; then
            echo -e "  ${BLUE}Demo Report:${NC}"
            # Show summary and visual demo sections
            sed -n '/^## Summary/,/^## [^V]/p' "$wt/DEMO.md" | head -20 | sed 's/^/    /'
            local screenshots=$(demo_screenshot_count "$wt")
            if [[ "$screenshots" -gt 0 ]]; then
                echo -e "    ${GREEN}$screenshots screenshots available in:${NC} $wt/.demo/"
            fi
            echo ""
        fi
```

**Step 2: Verify script parses correctly**

Run: `bash -n scripts/claude-morning-review.sh`
Expected: No output (clean parse)

**Step 3: Commit**

```bash
git add scripts/claude-morning-review.sh
git commit -m "feat(morning-review): show demo report in interactive merge flow"
```

---

### Task 6: Create Demo Config for Account Harmony AI

**Files:**
- Create: `~/account-harmony-ai-37599577/.claude/demo-config.md`

**Step 1: Write the demo configuration file**

```markdown
# Demo Configuration

This file tells autonomous Claude agents how to produce visual demo reports
for Account Harmony AI. See nixos-config design doc for the pattern.

## Dev Server

- command: `npm run dev`
- url: http://localhost:8080
- ready-signal: "ready in"

## Key Pages

- /dashboard (role: accountant) - main dashboard with metrics and task overview
- /clients (role: accountant) - client list with CRM sidebar
- /compliance (role: accountant) - compliance checker with AI analysis
- /tasks (role: accountant) - accountant task board
- /documents (role: accountant) - document management
- /client-portal (role: client) - client self-service portal

## Auth

- Test credentials from .env.example: TEST_USER_EMAIL / TEST_USER_PASSWORD
- For role-based testing, use seed data users if available

## Screenshot Guidelines

- Capture the full page viewport (1280x720)
- If the change affects a specific component, also capture a zoomed view
- For form changes: show both empty state and filled state
- For table/list changes: show with data (at least 3 rows)
- Name files descriptively: `01-dashboard-new-widget.png`, `02-filter-applied.png`
```

**Step 2: Verify the file is in the right location**

Run: `ls -la ~/account-harmony-ai-37599577/.claude/demo-config.md`
Expected: File exists with correct permissions

**Step 3: Commit in the harmony repo**

```bash
cd ~/account-harmony-ai-37599577
git add .claude/demo-config.md
git commit -m "feat: add demo report configuration for autonomous agents

Enables visual demo reports when Claude works autonomously on this project.
Agent will screenshot key pages after completing work."
```

---

### Task 7: Add `.demo/` to .gitignore in Account Harmony AI

**Files:**
- Modify: `~/account-harmony-ai-37599577/.gitignore`

**Step 1: Add .demo/ and DEMO.md to gitignore**

These are ephemeral artifacts produced in worktrees, not meant to be committed:

```gitignore
# Autonomous agent demo reports
.demo/
DEMO.md
```

**Step 2: Commit**

```bash
cd ~/account-harmony-ai-37599577
git add .gitignore
git commit -m "chore: ignore autonomous agent demo report artifacts"
```

---

### Task 8: End-to-End Smoke Test

**Files:** None (verification only)

**Step 1: Verify claude-autonomous.sh generates the correct prompt**

Run a dry test by examining what the prompt file would contain. Create a temporary test:

```bash
cd ~/nixos-config
# Verify the script parses
bash -n scripts/claude-autonomous.sh
echo "Script parses OK"
```

**Step 2: Verify claude-morning-review.sh loads without errors**

```bash
bash -n scripts/claude-morning-review.sh
echo "Script parses OK"
```

**Step 3: Test demo detection helpers with a mock worktree**

```bash
# Create a temporary mock worktree structure
MOCK_DIR=$(mktemp -d)
mkdir -p "$MOCK_DIR/.demo"
touch "$MOCK_DIR/DEMO.md"
touch "$MOCK_DIR/.demo/01-test.png"
touch "$MOCK_DIR/.demo/02-test.png"

# Source the helper functions and test them
source <(sed -n '/^has_demo_report/,/^}/p' scripts/claude-morning-review.sh)
source <(sed -n '/^demo_screenshot_count/,/^}/p' scripts/claude-morning-review.sh)

has_demo_report "$MOCK_DIR" && echo "PASS: demo detected" || echo "FAIL"
COUNT=$(demo_screenshot_count "$MOCK_DIR")
[[ "$COUNT" -eq 2 ]] && echo "PASS: found 2 screenshots" || echo "FAIL: expected 2, got $COUNT"

# Cleanup
rm -rf "$MOCK_DIR"
```

Expected: Both PASS messages.

**Step 4: Final commit (if any fixups needed)**

Only if smoke test revealed issues that needed fixing.
