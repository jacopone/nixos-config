#!/usr/bin/env bash
# Generate changelog draft from git commits since last CHANGELOG.md entry
# Output: Markdown to stdout (caller redirects as needed)
#
# Filtering rules:
#   feat:     -> Always include (Added)
#   fix:      -> Always include (Fixed)
#   perf:     -> Always include (Changed/Performance)
#   chore:    -> Only if packages.nix changed
#   refactor: -> Only if user-facing files changed
#   docs/ci/test: -> Never (internal)
#
# Testability hints are generated based on changed files and commit content.

set -euo pipefail

# Configuration
CHANGELOG_FILE="CHANGELOG.md"
SINCE_COMMIT="${1:-}"  # Optional: commit hash to start from

# Colors for stderr output (info messages)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Find last dated changelog entry
find_last_changelog_date() {
    local date
    date=$(grep -oP '^\#\# \[\K\d{4}-\d{2}-\d{2}' "$CHANGELOG_FILE" 2>/dev/null | head -1)

    if [ -z "$date" ]; then
        log_error "Cannot find last changelog date in $CHANGELOG_FILE"
        exit 1
    fi

    echo "$date"
}

# Check if commit affects user-facing files
is_user_facing_commit() {
    local hash="$1"
    git diff-tree --no-commit-id --name-only -r "$hash" 2>/dev/null | \
        grep -qE "(packages\.nix|base\.nix|flake\.nix|\.desktop)" && return 0
    return 1
}

# Extract package name from commit subject (heuristic)
extract_package_name() {
    local subject="$1"
    # Try various patterns: "add X", "X and Y", etc.
    echo "$subject" | grep -oP '(add|enable|install)\s+\K[\w-]+' | head -1 || \
    echo "$subject" | grep -oP '^\w+' | head -1 || \
    echo ""
}

# Generate test hint based on context
generate_test_hint() {
    local subject="$1"
    local files="$2"
    local hint=""

    # Package addition
    if [[ "$files" =~ packages.nix ]]; then
        local pkg
        pkg=$(extract_package_name "$subject")
        if [ -n "$pkg" ]; then
            hint="Test: \`which $pkg\` or \`$pkg --version\`"
        fi
    fi

    # Fish abbreviation
    if [[ "$files" =~ base.nix ]] && [[ "$subject" =~ abbreviation|abbr ]]; then
        hint="Test: \`abbr --show | rg <abbr-name>\`"
    fi

    # ADB/Android specific
    if [[ "$subject" =~ [Aa][Dd][Bb]|[Aa]ndroid ]]; then
        hint="Test: Connect Android device, run \`adb devices\`"
    fi

    # Wayland clipboard
    if [[ "$subject" =~ wl-clip|clipboard ]]; then
        hint="Test: \`echo test | wl-copy && wl-paste\`"
    fi

    # Screen recording
    if [[ "$subject" =~ [Kk]ooha|screen.?record ]]; then
        hint="Test: Launch from application menu, verify recording works"
    fi

    # Systemd service
    if [[ "$files" =~ systemd|service ]]; then
        hint="Test: \`systemctl status <service-name>\`"
    fi

    echo "$hint"
}

# Main logic
main() {
    # Verify we're in the right directory
    if [ ! -f "$CHANGELOG_FILE" ]; then
        log_error "Cannot find $CHANGELOG_FILE - run from repo root"
        exit 1
    fi

    # Determine how to filter commits
    local git_log_range=""
    local since_marker=""

    if [ -n "$SINCE_COMMIT" ] && git rev-parse --verify "$SINCE_COMMIT" >/dev/null 2>&1; then
        # Use commit-based filtering (preferred)
        git_log_range="${SINCE_COMMIT}..HEAD"
        since_marker="commit ${SINCE_COMMIT:0:7}"
        log_info "Finding commits since $since_marker"
    else
        # Fallback to date-based filtering
        local last_date
        last_date=$(find_last_changelog_date)
        git_log_range="--since=$last_date"
        since_marker="$last_date"
        log_info "Finding commits since $since_marker (date-based fallback)"
    fi

    # Arrays for categorized entries
    declare -a ADDED=()
    declare -a CHANGED=()
    declare -a FIXED=()
    declare -a REMOVED=()

    local commit_count=0
    local included_count=0

    # Process commits
    # shellcheck disable=SC2086  # $git_log_range is "--since=DATE" or "HASH..HEAD"
    while IFS='|' read -r hash subject date; do
        ((commit_count++)) || true

        # Get changed files for this commit
        local files
        files=$(git diff-tree --no-commit-id --name-only -r "$hash" 2>/dev/null | tr '\n' ',' | sed 's/,$//')

        # Skip empty subjects
        [ -z "$subject" ] && continue

        # Categorize by conventional commit type
        if [[ "$subject" =~ ^feat(\(.+\))?:\ (.+) ]]; then
            local clean_subject="${subject#feat*: }"
            local test_hint
            test_hint=$(generate_test_hint "$clean_subject" "$files")
            ADDED+=("$clean_subject|$test_hint")
            ((included_count++)) || true

        elif [[ "$subject" =~ ^fix(\(.+\))?:\ (.+) ]]; then
            local clean_subject="${subject#fix*: }"
            FIXED+=("$clean_subject")
            ((included_count++)) || true

        elif [[ "$subject" =~ ^perf(\(.+\))?:\ (.+) ]]; then
            local clean_subject="${subject#perf*: }"
            CHANGED+=("$clean_subject (performance improvement)")
            ((included_count++)) || true

        elif [[ "$subject" =~ ^chore(\(.+\))?:\ (.+) ]]; then
            # Only include chore if it touched packages.nix (likely added tools)
            if [[ "$files" =~ packages.nix ]] && [[ ! "$subject" =~ flake.lock|analytics|refresh ]]; then
                local clean_subject="${subject#chore*: }"
                CHANGED+=("$clean_subject")
                ((included_count++)) || true
            fi

        elif [[ "$subject" =~ ^refactor(\(.+\))?:\ (.+) ]]; then
            # Only include refactor if it changed user-facing behavior
            if is_user_facing_commit "$hash"; then
                local clean_subject="${subject#refactor*: }"
                CHANGED+=("$clean_subject (restructured)")
                ((included_count++)) || true
            fi

        elif [[ "$subject" =~ ^remove|^BREAKING ]]; then
            # Handle removals and breaking changes
            REMOVED+=("$subject")
            ((included_count++)) || true
        fi
        # Skip: docs:, ci:, test:, style:, build: (internal)

    done < <(git log $git_log_range --format="%H|%s|%ad" --date=short --reverse)

    log_info "Processed $commit_count commits, included $included_count user-facing changes"

    # Generate output
    if [ $included_count -eq 0 ]; then
        echo "No user-facing changes found since $since_marker."
        echo ""
        echo "Skipped commits were internal maintenance (chore, docs, ci, test)."
        exit 0
    fi

    # Print Added section
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        for entry in "${ADDED[@]}"; do
            IFS='|' read -r subject hint <<< "$entry"
            echo "- $subject"
            if [ -n "$hint" ]; then
                echo "  ($hint)"
            fi
        done
        echo ""
    fi

    # Print Changed section
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        for entry in "${CHANGED[@]}"; do
            echo "- $entry"
        done
        echo ""
    fi

    # Print Fixed section
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "### Fixed"
        for entry in "${FIXED[@]}"; do
            echo "- $entry"
            echo "  (Test: Verify the previous issue is resolved)"
        done
        echo ""
    fi

    # Print Removed section
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        for entry in "${REMOVED[@]}"; do
            echo "- $entry"
        done
        echo ""
    fi
}

main "$@"
