#!/usr/bin/env bash
# claude-night-batch.sh - Launch autonomous Claude sessions from a manifest
#
# Supports two execution strategies:
#   gated    - Sequential with review gates between sessions (default for v3+)
#   parallel - All sessions launch at once (legacy behavior, default for v1/v2)
#
# Usage:
#   claude-night-batch <manifest-dir>              # Launch using manifest strategy
#   claude-night-batch --parallel <manifest-dir>   # Force parallel mode
#   claude-night-batch --dry-run <manifest-dir>    # Preview without launching
#   claude-night-batch --validate <manifest-dir>   # Validate manifest only
#   claude-night-batch --status                    # Show active batches
#
# Reads manifest.yaml and task-*.md files from the specified directory,
# validates file ownership for conflicts, and launches sessions.

# shellcheck disable=SC2155
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    cat <<EOF
${BLUE}Claude Night Batch Launcher${NC}

Usage: $0 [options] <manifest-dir>

Arguments:
  manifest-dir    Directory containing manifest.yaml and task-*.md files

Options:
  --parallel      Force parallel mode (all sessions at once, no review gates)
  --dry-run       Preview sessions without launching
  --validate      Validate manifest only (check structure and ownership)
  --status        Show active batch sessions
  --help          Show this help

Execution strategies (set in manifest.yaml or via flags):
  gated     Sequential launch with review gates between sessions.
            After each session completes, a lightweight review checks
            the work before launching the next session. (default for v3+)
  parallel  All sessions launch simultaneously. (default for v1/v2)

Examples:
  $0 ~/.claude-tasks/auth-feature/
  $0 --parallel ~/.claude-tasks/auth-feature/
  $0 --dry-run ~/.claude-tasks/auth-feature/
  $0 --validate ~/.claude-tasks/auth-feature/

The manifest is created by running '/export-night' in a Claude planning session.
EOF
}

show_status() {
    echo -e "${BLUE}Active Batch Sessions:${NC}"
    echo ""

    # Find all batch logs
    local batch_log_dir="$HOME/.claude/batch-logs"
    if [[ -d "$batch_log_dir" ]]; then
        local found=false
        for batch_dir in "$batch_log_dir"/*/; do
            if [[ -d "$batch_dir" ]]; then
                local batch_name=$(basename "$batch_dir")
                local manifest_file="$batch_dir/manifest.yaml"

                if [[ -f "$manifest_file" ]]; then
                    found=true
                    local feature=$(yq -r '.feature // "Unknown"' "$manifest_file")
                    local repo=$(yq -r '.repo // "Unknown"' "$manifest_file")
                    local session_count=$(yq -r '.sessions | length' "$manifest_file")

                    echo -e "  ${CYAN}$batch_name${NC}"
                    echo -e "    Feature: $feature"
                    echo -e "    Repo: $repo"
                    echo -e "    Sessions: $session_count"

                    # Check tmux sessions
                    local running=0
                    for session_id in $(yq -r '.sessions[].id' "$manifest_file"); do
                        if tmux has-session -t "claude-$session_id" 2>/dev/null; then
                            ((running++))
                        fi
                    done
                    echo -e "    Running: $running/$session_count"
                    echo ""
                fi
            fi
        done

        if [[ "$found" == "false" ]]; then
            echo "  (no active batches)"
        fi
    else
        echo "  (no batch logs found)"
    fi
}

validate_manifest() {
    local manifest_dir="$1"
    local manifest_file="$manifest_dir/manifest.yaml"

    echo -e "${BLUE}Validating manifest...${NC}"

    # Check manifest exists
    if [[ ! -f "$manifest_file" ]]; then
        echo -e "${RED}Error: manifest.yaml not found in $manifest_dir${NC}"
        return 1
    fi

    # Check YAML is valid
    if ! yq '.' "$manifest_file" > /dev/null 2>&1; then
        echo -e "${RED}Error: Invalid YAML in manifest.yaml${NC}"
        return 1
    fi

    # Check required fields
    local version=$(yq -r '.version // ""' "$manifest_file")
    local repo=$(yq -r '.repo // ""' "$manifest_file")
    local sessions=$(yq -r '.sessions // ""' "$manifest_file")

    if [[ -z "$version" ]]; then
        echo -e "${RED}Error: Missing 'version' field${NC}"
        return 1
    fi

    if [[ -z "$repo" ]]; then
        echo -e "${RED}Error: Missing 'repo' field${NC}"
        return 1
    fi

    if [[ "$sessions" == "null" ]] || [[ -z "$sessions" ]]; then
        echo -e "${RED}Error: Missing or empty 'sessions' field${NC}"
        return 1
    fi

    # Check repo exists
    if [[ ! -d "$repo" ]]; then
        echo -e "${RED}Error: Repository not found: $repo${NC}"
        return 1
    fi

    # Check each session
    local session_count=$(yq -r '.sessions | length' "$manifest_file")
    echo -e "  Found ${GREEN}$session_count${NC} sessions"

    for ((i=0; i<session_count; i++)); do
        local session_id=$(yq -r ".sessions[$i].id // \"\"" "$manifest_file")
        local spec_file=$(yq -r ".sessions[$i].spec_file // \"\"" "$manifest_file")
        local owns=$(yq -r ".sessions[$i].owns // []" "$manifest_file")

        if [[ -z "$session_id" ]]; then
            echo -e "${RED}Error: Session $i missing 'id' field${NC}"
            return 1
        fi

        if [[ -n "$spec_file" ]] && [[ ! -f "$manifest_dir/$spec_file" ]]; then
            echo -e "${YELLOW}Warning: Spec file not found: $manifest_dir/$spec_file${NC}"
        fi

        echo -e "  ✓ Session: ${CYAN}$session_id${NC}"
    done

    # Validate ownership (no overlaps)
    echo -e "\n${BLUE}Checking file ownership...${NC}"

    local all_paths=()
    for ((i=0; i<session_count; i++)); do
        local session_id=$(yq -r ".sessions[$i].id" "$manifest_file")
        local owns_count=$(yq -r ".sessions[$i].owns | length" "$manifest_file")

        for ((j=0; j<owns_count; j++)); do
            local path=$(yq -r ".sessions[$i].owns[$j]" "$manifest_file")
            all_paths+=("$session_id:$path")
        done
    done

    # Check for overlapping paths (simple check)
    local overlap_found=false
    for ((i=0; i<${#all_paths[@]}; i++)); do
        local entry1="${all_paths[$i]}"
        local session1="${entry1%%:*}"
        local path1="${entry1#*:}"

        for ((j=i+1; j<${#all_paths[@]}; j++)); do
            local entry2="${all_paths[$j]}"
            local session2="${entry2%%:*}"
            local path2="${entry2#*:}"

            # Simple overlap check: if one path is a prefix of another
            if [[ "$path1" == "$path2"* ]] || [[ "$path2" == "$path1"* ]]; then
                echo -e "${RED}Error: Ownership overlap detected!${NC}"
                echo -e "  $session1 owns: $path1"
                echo -e "  $session2 owns: $path2"
                overlap_found=true
            fi
        done
    done

    if [[ "$overlap_found" == "true" ]]; then
        echo -e "\n${RED}Validation failed: Fix ownership overlaps before launching${NC}"
        return 1
    fi

    echo -e "  ${GREEN}✓ No ownership conflicts${NC}"
    echo -e "\n${GREEN}✓ Manifest validation passed${NC}"
    return 0
}

# ── Strategy detection ─────────────────────────────────────

get_strategy() {
    local manifest_file="$1"
    local override="${2:-}"

    # CLI override takes precedence
    if [[ -n "$override" ]]; then
        echo "$override"
        return
    fi

    # Check manifest for explicit strategy
    local strategy=$(yq -r '.strategy // ""' "$manifest_file")
    if [[ -n "$strategy" ]]; then
        echo "$strategy"
        return
    fi

    # Default based on manifest version
    local version=$(yq -r '.version // "1"' "$manifest_file")
    if [[ "$version" -ge 3 ]]; then
        echo "gated"
    else
        echo "parallel"
    fi
}

# ── Gated mode helpers ─────────────────────────────────────

# Wait for a session to complete by polling for markers
wait_for_session() {
    local worktree_path="$1"
    local session_id="$2"
    local poll_interval="${3:-60}"

    echo -e "  ${BLUE}Waiting for session $session_id to complete...${NC}"

    while true; do
        # Check completion markers (works even while session is running via Ralph)
        if [[ -f "$worktree_path/COMPLETED.md" ]]; then
            echo -e "  ${GREEN}✓ Session $session_id completed${NC}"
            return 0
        elif [[ -f "$worktree_path/BLOCKERS.md" ]]; then
            echo -e "  ${RED}⚠ Session $session_id hit blockers${NC}"
            return 1
        fi

        # Check if tmux session has exited without markers
        if ! tmux has-session -t "claude-$session_id" 2>/dev/null; then
            # Final check for markers (might have been written just before exit)
            if [[ -f "$worktree_path/COMPLETED.md" ]]; then
                echo -e "  ${GREEN}✓ Session $session_id completed${NC}"
                return 0
            elif [[ -f "$worktree_path/BLOCKERS.md" ]]; then
                echo -e "  ${RED}⚠ Session $session_id hit blockers${NC}"
                return 1
            else
                echo -e "  ${YELLOW}Session $session_id exited without completion markers${NC}"
                return 2
            fi
        fi

        sleep "$poll_interval"
    done
}

# Run a lightweight Claude review of a completed session's work
run_review_gate() {
    local worktree_path="$1"
    local session_id="$2"
    local batch_log_dir="$3"
    local repo="$4"

    echo -e "  ${BLUE}Running review gate for $session_id...${NC}"

    local branch=$(git -C "$worktree_path" branch --show-current 2>/dev/null || echo "unknown")

    # Detect base branch
    local base_branch
    base_branch=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||') || base_branch="main"

    # Collect context for the review
    local diff_stat=$(git -C "$worktree_path" diff --stat "${base_branch}...${branch}" 2>/dev/null || echo "no changes")
    local diff_content=$(git -C "$worktree_path" diff "${base_branch}...${branch}" 2>/dev/null | head -500 || echo "")
    local completed_content=""
    [[ -f "$worktree_path/COMPLETED.md" ]] && completed_content=$(cat "$worktree_path/COMPLETED.md")
    local invariants_content=""
    [[ -f "$worktree_path/INVARIANTS.md" ]] && invariants_content=$(cat "$worktree_path/INVARIANTS.md")

    # Build review prompt
    local review_prompt
    review_prompt=$(cat <<REVIEW_EOF
You are a code review gate for an autonomous coding session.
Review the work and respond EXACTLY in this format (no other text before or after):

VERDICT: PASS or FAIL
QUALITY: 1-5
SUMMARY: One paragraph summary of what was built and whether it meets requirements
ISSUES: Comma-separated list of issues, or "none"

Rules for verdict:
- PASS if: code compiles/runs, tests exist and pass, no obvious bugs, follows INVARIANTS
- FAIL if: missing tests, broken functionality, INVARIANTS violations, architectural problems

## Session: $session_id

### Diff Stats
$diff_stat

### Diff (first 500 lines)
\`\`\`diff
$diff_content
\`\`\`

### COMPLETED.md
$completed_content

### INVARIANTS.md
$invariants_content
REVIEW_EOF
)

    local review_log="$batch_log_dir/review-${session_id}.log"
    local review_output=""

    # Run review with 5-minute timeout using Claude print mode
    if review_output=$(echo "$review_prompt" | timeout 300 claude -p 2>&1); then
        echo "$review_output" > "$review_log"
        echo "$review_output" > "$worktree_path/REVIEW.md"

        # Parse verdict
        if echo "$review_output" | grep -qi "VERDICT:.*PASS"; then
            local quality=$(echo "$review_output" | grep -oi "QUALITY:.*[0-5]" | grep -o "[0-5]" | head -1)
            echo -e "  ${GREEN}✓ Review: PASS (quality: ${quality:-?}/5)${NC}"
            return 0
        elif echo "$review_output" | grep -qi "VERDICT:.*FAIL"; then
            local issues=$(echo "$review_output" | sed -n 's/^ISSUES: *//Ip' | head -1)
            echo -e "  ${RED}✗ Review: FAIL${NC}"
            [[ -n "$issues" ]] && echo -e "  ${RED}  Issues: $issues${NC}"
            return 1
        fi
    fi

    # Review was inconclusive — don't block the pipeline on infra issues
    echo -e "  ${YELLOW}Review gate inconclusive, defaulting to PASS${NC}"
    return 0
}

# Generate context about completed sessions for the next session
generate_prior_context() {
    local repo="$1"
    shift
    local completed_sessions=("$@")

    local context="# Prior Session Results"
    context+="\n\nThe following sessions have already completed in this batch."
    context+="\nUse this context to ensure your work integrates well with theirs.\n"

    local base_branch
    base_branch=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||') || base_branch="main"

    for session_id in "${completed_sessions[@]}"; do
        local worktree_path="$repo/.worktrees/$session_id"
        [[ -d "$worktree_path" ]] || continue

        local branch=$(git -C "$worktree_path" branch --show-current 2>/dev/null || echo "unknown")
        local diff_stat=$(git -C "$worktree_path" diff --stat "${base_branch}...${branch}" 2>/dev/null | tail -1 || echo "no changes")
        local files_changed=$(git -C "$worktree_path" diff --name-only "${base_branch}...${branch}" 2>/dev/null || echo "")

        context+="\n## $session_id (completed)"
        context+="\n- **Branch**: $branch"
        context+="\n- **Changes**: $diff_stat"
        context+="\n- **Files modified**:"

        if [[ -n "$files_changed" ]]; then
            while IFS= read -r file; do
                [[ -n "$file" ]] && context+="\n  - \`$file\`"
            done <<< "$files_changed"
        fi

        # Include review verdict if available
        if [[ -f "$worktree_path/REVIEW.md" ]]; then
            local verdict=$(grep -i "^VERDICT:" "$worktree_path/REVIEW.md" | head -1 || echo "")
            local summary=$(grep -i "^SUMMARY:" "$worktree_path/REVIEW.md" | head -1 || echo "")
            [[ -n "$verdict" ]] && context+="\n- **Review**: $verdict"
            [[ -n "$summary" ]] && context+="\n- $summary"
        fi

        context+="\n"
    done

    echo -e "$context"
}

# Run integration gate: merge all branches and run tests
run_integration_gate() {
    local repo="$1"
    local manifest_dir="$2"
    local batch_log_dir="$3"
    local manifest_file="$manifest_dir/manifest.yaml"

    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Integration Gate${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Detect base branch
    local base_branch
    base_branch=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||') || base_branch="main"

    # Get session order (prefer merge_order, fall back to session order)
    local ordered_sessions=()
    local merge_order_count=$(yq -r '.merge_order | length // 0' "$manifest_file" 2>/dev/null || echo "0")
    if [[ "$merge_order_count" -gt 0 ]]; then
        while IFS= read -r sid; do
            ordered_sessions+=("$sid")
        done < <(yq -r '.merge_order[]' "$manifest_file")
    else
        while IFS= read -r sid; do
            ordered_sessions+=("$sid")
        done < <(yq -r '.sessions[].id' "$manifest_file")
    fi

    # Create integration worktree
    local integration_ts=$(date +%Y%m%d-%H%M%S)
    local integration_branch="autonomous/integration-${integration_ts}"
    local integration_path="$repo/.worktrees/integration-check"

    # Clean up any previous integration worktree
    if [[ -d "$integration_path" ]]; then
        git -C "$repo" worktree remove "$integration_path" --force 2>/dev/null || rm -rf "$integration_path"
    fi

    git -C "$repo" branch "$integration_branch" "$base_branch" 2>/dev/null || true
    git -C "$repo" worktree add "$integration_path" "$integration_branch" 2>/dev/null

    echo -e "  ${CYAN}Merging session branches...${NC}"

    # Merge each session branch
    local merge_failed=false
    local failed_session=""
    cd "$integration_path"
    for session_id in "${ordered_sessions[@]}"; do
        local branch="autonomous/$session_id"
        if ! git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
            echo -e "  ${YELLOW}Skipping $session_id (branch not found)${NC}"
            continue
        fi
        echo -ne "  Merging $session_id... "
        if git merge --no-ff "$branch" -m "Integration: merge $session_id" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}conflict!${NC}"
            git merge --abort 2>/dev/null || true
            merge_failed=true
            failed_session="$session_id"
            break
        fi
    done

    local report_file="$integration_path/INTEGRATION-REPORT.md"

    if [[ "$merge_failed" == "true" ]]; then
        cat > "$report_file" << EOF
# Integration Report

**Status**: FAILED - Merge conflict
**Date**: $(date)
**Conflict**: Merging session \`$failed_session\` caused conflicts

## Action Required
Merge conflicts need manual resolution. This typically means two sessions
modified the same file or adjacent lines.

## Sessions Attempted
$(for s in "${ordered_sessions[@]}"; do echo "- $s"; done)
EOF
        echo -e "\n  ${RED}Integration: MERGE CONFLICT at $failed_session${NC}"
    else
        # Run tests if available
        echo -e "\n  ${BLUE}Running integration tests...${NC}"
        local test_output=""
        local test_exit=0
        if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] || [[ -d "tests" ]]; then
            test_output=$(pytest tests/ -v --tb=short 2>&1) || test_exit=$?
        elif [[ -f "package.json" ]]; then
            test_output=$(npm test 2>&1) || test_exit=$?
        else
            test_output="No test runner detected"
            test_exit=0
        fi

        local status_text="PASS"
        [[ $test_exit -ne 0 ]] && status_text="TESTS FAILED"

        cat > "$report_file" << EOF
# Integration Report

**Status**: $status_text
**Date**: $(date)

## Merged Sessions
$(for s in "${ordered_sessions[@]}"; do echo "- $s"; done)

## Test Results
\`\`\`
$test_output
\`\`\`
EOF

        if [[ $test_exit -eq 0 ]]; then
            echo -e "  ${GREEN}✓ Integration: ALL TESTS PASS${NC}"
        else
            echo -e "  ${RED}✗ Integration: TESTS FAILED${NC}"
        fi
    fi

    # Copy report to batch log
    cp "$report_file" "$batch_log_dir/INTEGRATION-REPORT.md" 2>/dev/null || true

    echo -e "  ${CYAN}Report: $batch_log_dir/INTEGRATION-REPORT.md${NC}"

    # Clean up integration worktree (leave report in batch log)
    cd "$repo"
    git -C "$repo" worktree remove "$integration_path" --force 2>/dev/null || true
    git branch -D "$integration_branch" 2>/dev/null || true
}

# ── Dry run ────────────────────────────────────────────────

dry_run() {
    local manifest_dir="$1"
    local strategy_override="${2:-}"
    local manifest_file="$manifest_dir/manifest.yaml"

    local strategy=$(get_strategy "$manifest_file" "$strategy_override")

    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Dry Run: Night Batch Preview${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    local feature=$(yq -r '.feature // "Unknown"' "$manifest_file")
    local repo=$(yq -r '.repo' "$manifest_file")
    local session_count=$(yq -r '.sessions | length' "$manifest_file")
    local version=$(yq -r '.version // "1"' "$manifest_file")

    echo -e "  Feature:     ${GREEN}$feature${NC}"
    echo -e "  Repository:  ${GREEN}$repo${NC}"
    echo -e "  Sessions:    ${GREEN}$session_count${NC}"
    echo -e "  Manifest:    ${GREEN}v$version${NC}"
    echo -e "  Strategy:    ${GREEN}$strategy${NC}"
    echo ""

    if [[ "$strategy" == "gated" ]]; then
        echo -e "  ${CYAN}Gated mode: sessions run sequentially with review gates${NC}"
        echo -e "  ${CYAN}After each session → review gate → prior context → next session${NC}"
        echo -e "  ${CYAN}After all sessions → integration gate (merge + tests)${NC}"
        echo ""
    fi

    echo -e "${BLUE}Sessions to launch:${NC}"
    for ((i=0; i<session_count; i++)); do
        local session_id=$(yq -r ".sessions[$i].id" "$manifest_file")
        local mode=$(yq -r ".sessions[$i].mode // \"standard\"" "$manifest_file")
        local owns=$(yq -r ".sessions[$i].owns | join(\", \")" "$manifest_file")
        local spec_file=$(yq -r ".sessions[$i].spec_file // \"\"" "$manifest_file")

        echo ""
        echo -e "  ${CYAN}[$((i+1))] $session_id${NC}"
        echo -e "      Mode: $mode"
        echo -e "      Owns: $owns"
        if [[ -n "$spec_file" ]]; then
            echo -e "      Spec: $spec_file"
        fi

        # Show command that would be run
        local strict_flag=""
        if [[ "$mode" == "strict" ]]; then
            strict_flag="--strict "
        fi
        echo -e "      ${YELLOW}Command: claude-autonomous $strict_flag$repo $session_id \"<prompt from spec>\"${NC}"

        if [[ "$strategy" == "gated" ]]; then
            echo -e "      ${YELLOW}  → wait for completion → review gate → deploy context${NC}"
        fi
    done

    # Show merge order if gated
    if [[ "$strategy" == "gated" ]]; then
        local merge_order_count=$(yq -r '.merge_order | length // 0' "$manifest_file" 2>/dev/null || echo "0")
        if [[ "$merge_order_count" -gt 0 ]]; then
            echo ""
            echo -e "${BLUE}Execution order (from merge_order):${NC}"
            local idx=1
            while IFS= read -r sid; do
                echo -e "  $idx. $sid"
                ((idx++))
            done < <(yq -r '.merge_order[]' "$manifest_file")
        fi

        echo ""
        echo -e "${BLUE}Post-completion:${NC}"
        echo -e "  → Integration gate: merge all branches + run tests"
    fi

    # Show integration points
    local integration_count=$(yq -r '.integration_points | length' "$manifest_file" 2>/dev/null || echo "0")
    if [[ "$integration_count" -gt 0 ]]; then
        echo ""
        echo -e "${BLUE}Integration points for morning:${NC}"
        for ((i=0; i<integration_count; i++)); do
            local file=$(yq -r ".integration_points[$i].file" "$manifest_file")
            local desc=$(yq -r ".integration_points[$i].description" "$manifest_file")
            echo -e "  - $file: $desc"
        done
    fi

    echo ""
    echo -e "${YELLOW}This is a dry run. No sessions were launched.${NC}"
    echo -e "Remove --dry-run to launch: $0 $manifest_dir"
}

# ── Parallel launch (legacy) ──────────────────────────────

launch_batch_parallel() {
    local manifest_dir="$1"
    local manifest_file="$manifest_dir/manifest.yaml"

    # Generate batch ID
    local batch_id=$(date +%Y%m%d-%H%M%S)
    local batch_name=$(basename "$manifest_dir")
    local batch_log_dir="$HOME/.claude/batch-logs/$batch_name-$batch_id"

    mkdir -p "$batch_log_dir"

    # Copy manifest to batch log for reference
    cp "$manifest_file" "$batch_log_dir/manifest.yaml"

    local feature=$(yq -r '.feature // "Unknown"' "$manifest_file")
    local repo=$(yq -r '.repo' "$manifest_file")
    local session_count=$(yq -r '.sessions | length' "$manifest_file")

    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Launching Night Batch: $batch_name (parallel)${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Feature:     ${GREEN}$feature${NC}"
    echo -e "  Repository:  ${GREEN}$repo${NC}"
    echo -e "  Sessions:    ${GREEN}$session_count${NC}"
    echo -e "  Strategy:    ${GREEN}parallel${NC}"
    echo -e "  Batch ID:    ${GREEN}$batch_id${NC}"
    echo -e "  Batch Log:   ${GREEN}$batch_log_dir${NC}"
    echo ""

    # Launch each session
    local launched=0
    for ((i=0; i<session_count; i++)); do
        local session_id=$(yq -r ".sessions[$i].id" "$manifest_file")
        local mode=$(yq -r ".sessions[$i].mode // \"standard\"" "$manifest_file")
        local spec_file=$(yq -r ".sessions[$i].spec_file // \"\"" "$manifest_file")

        echo -e "${BLUE}[Session $((i+1))/$session_count] Launching: ${CYAN}$session_id${NC}"

        # Build prompt from spec file or inline prompt
        local prompt=""
        if [[ -n "$spec_file" ]] && [[ -f "$manifest_dir/$spec_file" ]]; then
            prompt=$(cat "$manifest_dir/$spec_file")
        else
            prompt=$(yq -r ".sessions[$i].prompt // \"\"" "$manifest_file")
        fi

        if [[ -z "$prompt" ]]; then
            echo -e "  ${RED}Error: No prompt found for session $session_id${NC}"
            continue
        fi

        # Build command
        local strict_flag=""
        if [[ "$mode" == "strict" ]]; then
            strict_flag="--strict"
        fi

        # Launch claude-autonomous
        if claude-autonomous $strict_flag "$repo" "$session_id" "$prompt"; then
            echo -e "  ${GREEN}✓ Launched successfully${NC}"
            ((launched++))

            # Deploy PROGRESS.md and INVARIANTS.md into worktree (v2 manifests from /export-night)
            local worktree_path="$repo/.worktrees/$session_id"
            if [[ -d "$worktree_path" ]]; then
                if [[ -f "$manifest_dir/PROGRESS.md" ]]; then
                    cp "$manifest_dir/PROGRESS.md" "$worktree_path/PROGRESS.md"
                    echo -e "  ${CYAN}  → Deployed PROGRESS.md${NC}"
                fi
                if [[ -f "$manifest_dir/INVARIANTS.md" ]]; then
                    cp "$manifest_dir/INVARIANTS.md" "$worktree_path/INVARIANTS.md"
                    echo -e "  ${CYAN}  → Deployed INVARIANTS.md${NC}"
                fi
            fi
        else
            echo -e "  ${RED}✗ Failed to launch${NC}"
        fi

        echo ""

        # Small delay between launches to avoid overwhelming the system
        sleep 2
    done

    # Summary
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Batch Launch Complete (parallel)${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Launched: ${GREEN}$launched/$session_count${NC} sessions"
    echo ""
    echo -e "  ${BLUE}Monitor all:${NC}"
    for ((i=0; i<session_count; i++)); do
        local session_id=$(yq -r ".sessions[$i].id" "$manifest_file")
        echo -e "    tmux attach -t claude-$session_id"
    done
    echo ""
    echo -e "  ${BLUE}View batch log:${NC}  ls $batch_log_dir/"
    echo -e "  ${BLUE}Morning review:${NC}  claude-morning-review $repo"
    echo ""
    echo -e "  ${YELLOW}Safe to close terminal - Claude runs in background!${NC}"
    echo ""
}

# ── Gated launch (v3) ─────────────────────────────────────

launch_batch_gated() {
    local manifest_dir="$1"
    local manifest_file="$manifest_dir/manifest.yaml"

    # Generate batch ID
    local batch_id=$(date +%Y%m%d-%H%M%S)
    local batch_name=$(basename "$manifest_dir")
    local batch_log_dir="$HOME/.claude/batch-logs/$batch_name-$batch_id"

    mkdir -p "$batch_log_dir"
    cp "$manifest_file" "$batch_log_dir/manifest.yaml"

    local feature=$(yq -r '.feature // "Unknown"' "$manifest_file")
    local repo=$(yq -r '.repo' "$manifest_file")
    local session_count=$(yq -r '.sessions | length' "$manifest_file")

    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Launching Night Batch: $batch_name (gated)${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Feature:     ${GREEN}$feature${NC}"
    echo -e "  Repository:  ${GREEN}$repo${NC}"
    echo -e "  Sessions:    ${GREEN}$session_count${NC}"
    echo -e "  Strategy:    ${GREEN}gated (sequential + review gates)${NC}"
    echo -e "  Batch ID:    ${GREEN}$batch_id${NC}"
    echo -e "  Batch Log:   ${GREEN}$batch_log_dir${NC}"
    echo ""

    # Determine execution order (prefer merge_order, fall back to session order)
    local ordered_ids=()
    local merge_order_count=$(yq -r '.merge_order | length // 0' "$manifest_file" 2>/dev/null || echo "0")
    if [[ "$merge_order_count" -gt 0 ]]; then
        while IFS= read -r sid; do
            ordered_ids+=("$sid")
        done < <(yq -r '.merge_order[]' "$manifest_file")
    else
        while IFS= read -r sid; do
            ordered_ids+=("$sid")
        done < <(yq -r '.sessions[].id' "$manifest_file")
    fi

    echo -e "  ${CYAN}Execution order:${NC}"
    for ((i=0; i<${#ordered_ids[@]}; i++)); do
        echo -e "    $((i+1)). ${ordered_ids[$i]}"
    done
    echo ""

    # Track completed sessions for prior context
    local completed_sessions=()
    local completed=0
    local failed=0
    local total=${#ordered_ids[@]}

    for ((idx=0; idx<total; idx++)); do
        local session_id="${ordered_ids[$idx]}"

        echo -e "${BLUE}═══ [$((idx+1))/$total] Session: ${CYAN}$session_id${BLUE} ═══${NC}"

        # Find the session config in the manifest
        local session_index=-1
        for ((i=0; i<session_count; i++)); do
            local sid=$(yq -r ".sessions[$i].id" "$manifest_file")
            if [[ "$sid" == "$session_id" ]]; then
                session_index=$i
                break
            fi
        done

        if [[ $session_index -eq -1 ]]; then
            echo -e "  ${RED}Error: Session $session_id not found in manifest${NC}"
            ((failed++))
            continue
        fi

        local mode=$(yq -r ".sessions[$session_index].mode // \"standard\"" "$manifest_file")
        local spec_file=$(yq -r ".sessions[$session_index].spec_file // \"\"" "$manifest_file")

        # Build prompt
        local prompt=""
        if [[ -n "$spec_file" ]] && [[ -f "$manifest_dir/$spec_file" ]]; then
            prompt=$(cat "$manifest_dir/$spec_file")
        else
            prompt=$(yq -r ".sessions[$session_index].prompt // \"\"" "$manifest_file")
        fi

        if [[ -z "$prompt" ]]; then
            echo -e "  ${RED}Error: No prompt found for session $session_id${NC}"
            ((failed++))
            continue
        fi

        local strict_flag=""
        [[ "$mode" == "strict" ]] && strict_flag="--strict"

        # Launch the session
        echo -e "  ${BLUE}Launching...${NC}"
        if ! claude-autonomous $strict_flag "$repo" "$session_id" "$prompt"; then
            echo -e "  ${RED}✗ Failed to launch session $session_id${NC}"
            ((failed++))
            continue
        fi
        echo -e "  ${GREEN}✓ Launched${NC}"

        # Deploy support files to the worktree
        local worktree_path="$repo/.worktrees/$session_id"
        if [[ -d "$worktree_path" ]]; then
            if [[ -f "$manifest_dir/PROGRESS.md" ]]; then
                cp "$manifest_dir/PROGRESS.md" "$worktree_path/PROGRESS.md"
                echo -e "  ${CYAN}  → Deployed PROGRESS.md${NC}"
            fi
            if [[ -f "$manifest_dir/INVARIANTS.md" ]]; then
                cp "$manifest_dir/INVARIANTS.md" "$worktree_path/INVARIANTS.md"
                echo -e "  ${CYAN}  → Deployed INVARIANTS.md${NC}"
            fi

            # Deploy prior sessions context (if any sessions completed before this one)
            if [[ ${#completed_sessions[@]} -gt 0 ]]; then
                generate_prior_context "$repo" "${completed_sessions[@]}" > "$worktree_path/PRIOR-SESSIONS.md"
                echo -e "  ${CYAN}  → Deployed PRIOR-SESSIONS.md (${#completed_sessions[@]} prior sessions)${NC}"
            fi
        fi

        # Wait for session to complete
        echo ""
        local wait_result=0
        wait_for_session "$worktree_path" "$session_id" 60 || wait_result=$?

        if [[ $wait_result -eq 0 ]]; then
            # Session completed — run review gate
            echo ""
            local review_result=0
            run_review_gate "$worktree_path" "$session_id" "$batch_log_dir" "$repo" || review_result=$?

            if [[ $review_result -eq 0 ]]; then
                completed_sessions+=("$session_id")
                ((completed++))
            else
                # Review failed — retry once with feedback
                echo -e "  ${YELLOW}Retrying session with review feedback...${NC}"

                # Append review feedback to the task and rerun
                if [[ -f "$worktree_path/REVIEW.md" ]]; then
                    local review_feedback=$(cat "$worktree_path/REVIEW.md")
                    local retry_prompt="$prompt

## Review Feedback (fix these issues)

The previous attempt was reviewed and FAILED. Address these issues:

$review_feedback

Fix the issues above, then re-verify everything passes."

                    # Kill existing session if still running
                    tmux kill-session -t "claude-$session_id" 2>/dev/null || true

                    # Relaunch with feedback
                    if claude-autonomous $strict_flag "$repo" "${session_id}-retry" "$retry_prompt"; then
                        local retry_worktree="$repo/.worktrees/${session_id}-retry"
                        # Deploy same support files
                        [[ -f "$manifest_dir/INVARIANTS.md" ]] && cp "$manifest_dir/INVARIANTS.md" "$retry_worktree/INVARIANTS.md" 2>/dev/null || true

                        local retry_wait=0
                        wait_for_session "$retry_worktree" "${session_id}-retry" 60 || retry_wait=$?

                        if [[ $retry_wait -eq 0 ]]; then
                            echo -e "  ${GREEN}✓ Retry completed${NC}"
                            completed_sessions+=("${session_id}-retry")
                            ((completed++))
                        else
                            echo -e "  ${RED}✗ Retry also failed, continuing...${NC}"
                            ((failed++))
                        fi
                    else
                        echo -e "  ${RED}✗ Failed to launch retry${NC}"
                        ((failed++))
                    fi
                else
                    # No review file, just mark as failed and continue
                    ((failed++))
                fi
            fi
        elif [[ $wait_result -eq 1 ]]; then
            # Session hit blockers
            echo -e "  ${YELLOW}Session blocked, continuing to next...${NC}"
            ((failed++))
        else
            # Session exited without markers
            echo -e "  ${YELLOW}Session exited unexpectedly, continuing...${NC}"
            ((failed++))
        fi

        echo ""
    done

    # ── Integration gate ──
    if [[ $completed -gt 0 ]]; then
        run_integration_gate "$repo" "$manifest_dir" "$batch_log_dir"
    else
        echo -e "\n  ${YELLOW}No sessions completed — skipping integration gate${NC}"
    fi

    # Summary
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Gated Batch Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Completed:   ${GREEN}$completed/$total${NC}"
    echo -e "  Failed:      ${RED}$failed/$total${NC}"
    echo ""
    echo -e "  ${BLUE}Batch log:${NC}       ls $batch_log_dir/"
    echo -e "  ${BLUE}Integration:${NC}     cat $batch_log_dir/INTEGRATION-REPORT.md"
    echo -e "  ${BLUE}Morning review:${NC}  claude-morning-review $repo"
    echo ""
    echo -e "  ${BLUE}Review gates:${NC}"
    for session_id in "${completed_sessions[@]}"; do
        echo -e "    cat $repo/.worktrees/$session_id/REVIEW.md"
    done
    echo ""
    echo -e "  ${BLUE}Next steps:${NC}"
    echo -e "    Open Claude and use: ${CYAN}superpowers:finishing-a-development-branch${NC}"
    echo ""
}

# ── CLI parsing ────────────────────────────────────────────

STRATEGY_OVERRIDE=""

case "${1:-}" in
    --status|-s)
        show_status
        exit 0
        ;;
    --help|-h|"")
        usage
        exit 0
        ;;
    --validate|-v)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}Error: Missing manifest directory${NC}"
            usage
            exit 1
        fi
        validate_manifest "$2"
        exit $?
        ;;
    --dry-run|-d)
        shift
        # Check for strategy override before manifest dir
        if [[ "${1:-}" == "--parallel" ]]; then
            STRATEGY_OVERRIDE="parallel"
            shift
        fi
        if [[ -z "${1:-}" ]]; then
            echo -e "${RED}Error: Missing manifest directory${NC}"
            usage
            exit 1
        fi
        validate_manifest "$1" || exit 1
        dry_run "$1" "$STRATEGY_OVERRIDE"
        exit 0
        ;;
    --parallel)
        STRATEGY_OVERRIDE="parallel"
        shift
        MANIFEST_DIR="${1:-}"
        ;;
    *)
        # Regular launch
        MANIFEST_DIR="$1"
        ;;
esac

# Validate before launch
if [[ -z "${MANIFEST_DIR:-}" ]] || [[ ! -d "$MANIFEST_DIR" ]]; then
    echo -e "${RED}Error: Directory not found: ${MANIFEST_DIR:-<not specified>}${NC}"
    exit 1
fi

validate_manifest "$MANIFEST_DIR" || exit 1
echo ""

# Determine strategy and launch
MANIFEST_FILE="$MANIFEST_DIR/manifest.yaml"
STRATEGY=$(get_strategy "$MANIFEST_FILE" "$STRATEGY_OVERRIDE")

case "$STRATEGY" in
    gated)
        launch_batch_gated "$MANIFEST_DIR"
        ;;
    parallel)
        launch_batch_parallel "$MANIFEST_DIR"
        ;;
    *)
        echo -e "${RED}Error: Unknown strategy '$STRATEGY' (expected: gated, parallel)${NC}"
        exit 1
        ;;
esac
