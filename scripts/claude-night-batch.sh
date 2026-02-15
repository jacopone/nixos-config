#!/usr/bin/env bash
# claude-night-batch.sh - Launch parallel autonomous Claude sessions from a manifest
#
# Usage:
#   claude-night-batch <manifest-dir>              # Launch all sessions
#   claude-night-batch --dry-run <manifest-dir>   # Preview without launching
#   claude-night-batch --validate <manifest-dir>  # Validate manifest only
#   claude-night-batch --status                   # Show active batches
#
# Reads manifest.yaml and task-*.md files from the specified directory,
# validates file ownership for conflicts, and launches parallel sessions.

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
  --dry-run       Preview sessions without launching
  --validate      Validate manifest only (check structure and ownership)
  --status        Show active batch sessions
  --help          Show this help

Examples:
  $0 ~/.claude-tasks/auth-feature/
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

dry_run() {
    local manifest_dir="$1"
    local manifest_file="$manifest_dir/manifest.yaml"

    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Dry Run: Night Batch Preview${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    local feature=$(yq -r '.feature // "Unknown"' "$manifest_file")
    local repo=$(yq -r '.repo' "$manifest_file")
    local session_count=$(yq -r '.sessions | length' "$manifest_file")

    echo -e "  Feature:     ${GREEN}$feature${NC}"
    echo -e "  Repository:  ${GREEN}$repo${NC}"
    echo -e "  Sessions:    ${GREEN}$session_count${NC}"
    echo ""

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
    done

    # Show integration points
    local integration_count=$(yq -r '.integration_points | length' "$manifest_file")
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

launch_batch() {
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
    echo -e "${BLUE}  Launching Night Batch: $batch_name${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Feature:     ${GREEN}$feature${NC}"
    echo -e "  Repository:  ${GREEN}$repo${NC}"
    echo -e "  Sessions:    ${GREEN}$session_count${NC}"
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
    echo -e "${GREEN}  Batch Launch Complete${NC}"
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

# Parse arguments
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
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}Error: Missing manifest directory${NC}"
            usage
            exit 1
        fi
        validate_manifest "$2" || exit 1
        dry_run "$2"
        exit 0
        ;;
    *)
        # Regular launch
        MANIFEST_DIR="$1"
        ;;
esac

# Validate before launch
if [[ ! -d "$MANIFEST_DIR" ]]; then
    echo -e "${RED}Error: Directory not found: $MANIFEST_DIR${NC}"
    exit 1
fi

validate_manifest "$MANIFEST_DIR" || exit 1
echo ""
launch_batch "$MANIFEST_DIR"
