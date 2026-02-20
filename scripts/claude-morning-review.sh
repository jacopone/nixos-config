#!/usr/bin/env bash
# claude-morning-review.sh - Review and merge overnight autonomous Claude work
#
# Usage:
#   claude-morning-review <repo-path>          # Show status of overnight work
#   claude-morning-review --merge <repo-path>  # Interactively merge completed tasks
#   claude-morning-review --report <repo-path> # Generate markdown report
#
# Scans .worktrees/ for overnight work, shows status, and assists with merge.

# shellcheck disable=SC2155
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

usage() {
    cat <<EOF
${BLUE}Claude Morning Review${NC}

Usage: $0 [options] <repo-path>

Arguments:
  repo-path       Path to the git repository with .worktrees/

Options:
  --merge         Interactively merge completed worktrees
  --report        Generate markdown report of overnight work
  --cleanup       Remove completed worktrees after review
  --help          Show this help

Examples:
  $0 ~/myproject                    # Review overnight work
  $0 --merge ~/myproject            # Merge completed tasks
  $0 --report ~/myproject > report.md

Run this in the morning after claude-night-batch has completed.
EOF
}

# Status detection for a worktree
get_worktree_status() {
    local worktree_path="$1"
    local session_name="$2"

    # Check if tmux session is still running
    if tmux has-session -t "claude-$session_name" 2>/dev/null; then
        echo "running"
        return
    fi

    # Check for completion markers
    if [[ -f "$worktree_path/COMPLETED.md" ]]; then
        echo "completed"
        return
    fi

    if [[ -f "$worktree_path/BLOCKERS.md" ]]; then
        echo "blocked"
        return
    fi

    # Check git status for changes
    local changes=$(git -C "$worktree_path" status --porcelain 2>/dev/null | wc -l)
    if [[ "$changes" -gt 0 ]]; then
        echo "incomplete"
        return
    fi

    echo "unknown"
}

# Get status emoji
status_emoji() {
    case "$1" in
        completed) echo -e "${GREEN}✓${NC}" ;;
        running)   echo -e "${YELLOW}⏳${NC}" ;;
        blocked)   echo -e "${RED}⚠${NC}" ;;
        incomplete) echo -e "${YELLOW}…${NC}" ;;
        *)         echo -e "${MAGENTA}?${NC}" ;;
    esac
}

# Count lines changed in worktree
get_changes_summary() {
    local worktree_path="$1"
    local branch="$2"

    # Get diff stats against main branch
    local stats=$(git -C "$worktree_path" diff --stat "main...$branch" 2>/dev/null | tail -1 || echo "")

    if [[ -n "$stats" ]]; then
        echo "$stats"
    else
        echo "no changes"
    fi
}

# Parse test results from COMPLETED.md or logs
get_test_summary() {
    local worktree_path="$1"

    if [[ -f "$worktree_path/COMPLETED.md" ]]; then
        # Try to extract test results from COMPLETED.md
        local tests=$(grep -E "(tests?.*pass|pass.*tests?|\d+/\d+ pass)" "$worktree_path/COMPLETED.md" 2>/dev/null | head -1 || echo "")
        if [[ -n "$tests" ]]; then
            echo "$tests"
            return
        fi
    fi

    echo "unknown"
}

# Check if worktree has a demo report
has_demo_report() {
    local worktree_path="$1"
    [[ -f "$worktree_path/DEMO.md" ]] || [[ -f "$worktree_path/.demo/DEMO.md" ]]
}

# Count screenshots in demo
demo_screenshot_count() {
    local worktree_path="$1"
    if [[ -d "$worktree_path/.demo" ]]; then
        find "$worktree_path/.demo" \( -name "*.png" -o -name "*.jpeg" -o -name "*.jpg" \) 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

show_review() {
    local repo_path="$1"
    local worktree_base="$repo_path/.worktrees"

    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Morning Review: $(basename "$repo_path")${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    if [[ ! -d "$worktree_base" ]]; then
        echo -e "  ${YELLOW}No worktrees found in $worktree_base${NC}"
        echo -e "  Run ${CYAN}claude-night-batch${NC} first to create autonomous sessions."
        exit 0
    fi

    # Find all worktrees
    local worktrees=()
    for wt in "$worktree_base"/*/; do
        if [[ -d "$wt" ]]; then
            worktrees+=("$wt")
        fi
    done

    if [[ ${#worktrees[@]} -eq 0 ]]; then
        echo -e "  ${YELLOW}No worktrees found${NC}"
        exit 0
    fi

    echo -e "  Repository: ${GREEN}$repo_path${NC}"
    echo -e "  Worktrees:  ${GREEN}${#worktrees[@]}${NC}"
    echo ""

    # Status table header
    printf "  ${CYAN}%-20s %-12s %-8s %-40s${NC}\n" "SESSION" "STATUS" "DEMO" "CHANGES"
    printf "  %-20s %-12s %-8s %-40s\n" "────────────────────" "────────────" "────────" "────────────────────────────────────────"

    local completed_count=0
    local blocked_count=0
    local running_count=0

    for wt in "${worktrees[@]}"; do
        local name=$(basename "$wt")
        local branch=$(git -C "$wt" branch --show-current 2>/dev/null || echo "unknown")
        local status=$(get_worktree_status "$wt" "$name")
        local emoji=$(status_emoji "$status")

        # Count by status
        case "$status" in
            completed) ((completed_count++)) || true ;;
            blocked)   ((blocked_count++)) || true ;;
            running)   ((running_count++)) || true ;;
        esac

        # Get change summary
        local changes=$(get_changes_summary "$wt" "$branch")

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

        printf "  %-20s %s %-10s %b%-6s${NC} %-40s\n" "$name" "$emoji" "$status" "$demo_indicator" "" "$changes"
    done

    echo ""

    # Summary
    echo -e "  ${BLUE}Summary:${NC}"
    echo -e "    Completed: ${GREEN}$completed_count${NC}"
    echo -e "    Blocked:   ${RED}$blocked_count${NC}"
    echo -e "    Running:   ${YELLOW}$running_count${NC}"
    echo ""

    # Show blocked details
    if [[ $blocked_count -gt 0 ]]; then
        echo -e "  ${RED}Blocked Tasks:${NC}"
        for wt in "${worktrees[@]}"; do
            local name=$(basename "$wt")
            if [[ -f "$wt/BLOCKERS.md" ]]; then
                echo -e "    ${CYAN}$name${NC}:"
                head -5 "$wt/BLOCKERS.md" | sed 's/^/      /'
                echo ""
            fi
        done
    fi

    # Show completed summaries
    if [[ $completed_count -gt 0 ]]; then
        echo -e "  ${GREEN}Completed Tasks:${NC}"
        for wt in "${worktrees[@]}"; do
            local name=$(basename "$wt")
            if [[ -f "$wt/COMPLETED.md" ]]; then
                echo -e "    ${CYAN}$name${NC}:"
                head -5 "$wt/COMPLETED.md" | sed 's/^/      /'
                echo ""
            fi
        done
    fi

    # Next steps
    echo -e "  ${BLUE}Next Steps:${NC}"
    if [[ $completed_count -gt 0 ]]; then
        echo -e "    Merge completed: ${CYAN}$0 --merge $repo_path${NC}"
        echo -e "    Or per-worktree: ${CYAN}cd <worktree> && claude${NC}"
        echo -e "      then use: ${CYAN}superpowers:finishing-a-development-branch${NC}"
    fi
    if [[ $running_count -gt 0 ]]; then
        echo -e "    Check running:   ${CYAN}tmux list-sessions | grep claude-${NC}"
    fi
    echo -e "    Generate report: ${CYAN}$0 --report $repo_path${NC}"
    echo ""
}

interactive_merge() {
    local repo_path="$1"
    local worktree_base="$repo_path/.worktrees"

    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Interactive Merge${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Find completed worktrees
    local completed=()
    for wt in "$worktree_base"/*/; do
        if [[ -d "$wt" ]]; then
            local name=$(basename "$wt")
            local status=$(get_worktree_status "$wt" "$name")
            if [[ "$status" == "completed" ]]; then
                completed+=("$wt")
            fi
        fi
    done

    if [[ ${#completed[@]} -eq 0 ]]; then
        echo -e "  ${YELLOW}No completed worktrees to merge${NC}"
        exit 0
    fi

    echo -e "  Found ${GREEN}${#completed[@]}${NC} completed worktrees to merge"
    echo ""

    # Ensure we're on main branch in the main repo
    local current_branch=$(git -C "$repo_path" branch --show-current)
    if [[ "$current_branch" != "main" ]] && [[ "$current_branch" != "master" ]] && [[ "$current_branch" != "personal" ]]; then
        echo -e "  ${YELLOW}Warning: Main repo is on branch '$current_branch'${NC}"
        echo -n "  Continue? [y/N] "
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # Merge each completed worktree
    for wt in "${completed[@]}"; do
        local name=$(basename "$wt")
        local branch=$(git -C "$wt" branch --show-current 2>/dev/null || echo "")

        echo -e "\n${CYAN}═══ Merging: $name ═══${NC}"

        # Show diff summary
        echo -e "  ${BLUE}Changes:${NC}"
        git -C "$wt" diff --stat "$current_branch...$branch" 2>/dev/null | head -10 | sed 's/^/    /'
        echo ""

        # Show demo report if available
        if has_demo_report "$wt"; then
            echo -e "  ${BLUE}Demo Report:${NC}"
            # Show summary and visual demo sections
            local demo_file="$wt/DEMO.md"
            [[ -f "$wt/.demo/DEMO.md" ]] && demo_file="$wt/.demo/DEMO.md"
            sed -n '/^## Summary/,/^## [^V]/p' "$demo_file" | head -20 | sed 's/^/    /'
            local screenshots=$(demo_screenshot_count "$wt")
            if [[ "$screenshots" -gt 0 ]]; then
                echo -e "    ${GREEN}$screenshots screenshots available in:${NC} $wt/.demo/"
            fi
            echo ""
        fi

        # Ask for confirmation
        echo -n "  Merge $name? [Y/n/s(kip)/q(uit)] "
        read -r answer

        case "$answer" in
            [Nn])
                echo -e "  ${YELLOW}Skipped${NC}"
                continue
                ;;
            [Ss])
                echo -e "  ${YELLOW}Skipped${NC}"
                continue
                ;;
            [Qq])
                echo -e "  ${YELLOW}Quit${NC}"
                exit 0
                ;;
            *)
                # Proceed with merge
                ;;
        esac

        # Attempt merge
        echo -e "  ${BLUE}Merging...${NC}"
        cd "$repo_path"

        if git merge --no-ff "$branch" -m "Merge autonomous/$name: overnight work"; then
            echo -e "  ${GREEN}✓ Merged successfully${NC}"

            # Ask to run tests
            echo -n "  Run tests? [Y/n] "
            read -r test_answer
            if [[ ! "$test_answer" =~ ^[Nn]$ ]]; then
                echo -e "  ${BLUE}Running tests...${NC}"
                if pytest tests/ -v --tb=short 2>/dev/null; then
                    echo -e "  ${GREEN}✓ Tests passed${NC}"
                else
                    echo -e "  ${RED}✗ Tests failed${NC}"
                    echo -n "  Revert merge? [y/N] "
                    read -r revert_answer
                    if [[ "$revert_answer" =~ ^[Yy]$ ]]; then
                        git reset --hard HEAD~1
                        echo -e "  ${YELLOW}Reverted${NC}"
                    fi
                fi
            fi
        else
            echo -e "  ${RED}✗ Merge conflict!${NC}"
            echo -e "  Resolve manually, then continue"
            git merge --abort 2>/dev/null || true
        fi
    done

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Merge session complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${BLUE}Cleanup worktrees:${NC} $0 --cleanup $repo_path"
    echo ""
}

generate_report() {
    local repo_path="$1"
    local worktree_base="$repo_path/.worktrees"
    local timestamp=$(date +"%Y-%m-%d %H:%M")

    cat <<EOF
# Overnight Work Report

**Repository**: $repo_path
**Generated**: $timestamp

## Summary

EOF

    # Count statuses
    local completed_n=0
    local blocked=0
    local running=0
    local total=0

    for wt in "$worktree_base"/*/; do
        if [[ -d "$wt" ]]; then
            local name=$(basename "$wt")
            local status=$(get_worktree_status "$wt" "$name")
            ((total++)) || true
            case "$status" in
                completed) ((completed_n++)) || true ;;
                blocked)   ((blocked++)) || true ;;
                running)   ((running++)) || true ;;
            esac
        fi
    done

    cat <<EOF
| Status | Count |
|--------|-------|
| Completed | $completed_n |
| Blocked | $blocked |
| Running | $running |
| **Total** | **$total** |

## Sessions

EOF

    for wt in "$worktree_base"/*/; do
        if [[ -d "$wt" ]]; then
            local name=$(basename "$wt")
            local status=$(get_worktree_status "$wt" "$name")
            local branch=$(git -C "$wt" branch --show-current 2>/dev/null || echo "unknown")

            echo "### $name"
            echo ""
            echo "- **Status**: $status"
            echo "- **Branch**: $branch"

            if [[ -f "$wt/COMPLETED.md" ]]; then
                echo ""
                echo "**Completed Summary:**"
                echo '```'
                head -20 "$wt/COMPLETED.md"
                echo '```'
            fi

            if [[ -f "$wt/BLOCKERS.md" ]]; then
                echo ""
                echo "**Blockers:**"
                echo '```'
                cat "$wt/BLOCKERS.md"
                echo '```'
            fi

            if has_demo_report "$wt"; then
                echo ""
                echo "**Demo Report:**"
                echo ""
                if [[ -f "$wt/.demo/DEMO.md" ]]; then
                    cat "$wt/.demo/DEMO.md"
                elif [[ -f "$wt/DEMO.md" ]]; then
                    cat "$wt/DEMO.md"
                fi
                echo ""
                local screenshots=$(demo_screenshot_count "$wt")
                if [[ "$screenshots" -gt 0 ]]; then
                    echo "*$screenshots screenshots in .demo/ directory*"
                    echo ""
                    echo "View screenshots:"
                    echo '```'
                    find "$wt/.demo/" \( -name "*.png" -o -name "*.jpeg" -o -name "*.jpg" \) 2>/dev/null | while read -r img; do
                        echo "  $(basename "$img")"
                    done
                    echo '```'
                fi
            fi

            echo ""
        fi
    done
}

cleanup_worktrees() {
    local repo_path="$1"
    local worktree_base="$repo_path/.worktrees"

    echo -e "${BLUE}Cleaning up worktrees...${NC}"

    for wt in "$worktree_base"/*/; do
        if [[ -d "$wt" ]]; then
            local name=$(basename "$wt")
            local status=$(get_worktree_status "$wt" "$name")

            if [[ "$status" == "completed" ]]; then
                echo -n "  Remove $name (completed)? [y/N] "
                read -r answer
                if [[ "$answer" =~ ^[Yy]$ ]]; then
                    git -C "$repo_path" worktree remove "$wt" --force 2>/dev/null || rm -rf "$wt"
                    echo -e "    ${GREEN}✓ Removed${NC}"
                fi
            fi
        fi
    done
}

# Parse arguments
case "${1:-}" in
    --help|-h|"")
        usage
        exit 0
        ;;
    --merge|-m)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}Error: Missing repo path${NC}"
            usage
            exit 1
        fi
        interactive_merge "$2"
        exit 0
        ;;
    --report|-r)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}Error: Missing repo path${NC}"
            usage
            exit 1
        fi
        generate_report "$2"
        exit 0
        ;;
    --cleanup|-c)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}Error: Missing repo path${NC}"
            usage
            exit 1
        fi
        cleanup_worktrees "$2"
        exit 0
        ;;
    *)
        # Default: show review
        REPO_PATH="$1"
        ;;
esac

# Validate repo path
if [[ ! -d "$REPO_PATH" ]]; then
    echo -e "${RED}Error: Directory not found: $REPO_PATH${NC}"
    exit 1
fi

if [[ ! -d "$REPO_PATH/.git" ]]; then
    echo -e "${RED}Error: Not a git repository: $REPO_PATH${NC}"
    exit 1
fi

show_review "$REPO_PATH"
