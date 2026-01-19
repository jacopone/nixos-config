#!/usr/bin/env bash
# EOD Cleanup Script v1
# Cleans up daily files (screenshots, downloads) and shows browser activity summary

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
DOWNLOADS_DIR="${HOME}/Downloads"
SCREENSHOTS_DIR="${HOME}/Pictures/Screenshots"
CHROME_HISTORY="${HOME}/.config/google-chrome/Default/History"
ARCHIVE_DIR="${HOME}/Archive/$(date +%Y/%m)"  # BASB-style archive by year/month
TEMP_DB="/tmp/chrome_history_copy_$$.db"

# Cleanup temp files on exit
trap 'rm -f $TEMP_DB' EXIT

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${BLUE}─── $1 ───${NC}"
    echo ""
}

# ============================================================================
# CHROME HISTORY SUMMARY
# ============================================================================
show_browser_summary() {
    print_header "🌐 BROWSER ACTIVITY SUMMARY"

    if [[ ! -f "$CHROME_HISTORY" ]]; then
        echo -e "${YELLOW}Chrome history not found${NC}"
        return
    fi

    # Copy history (Chrome locks the file)
    cp "$CHROME_HISTORY" "$TEMP_DB" 2>/dev/null || {
        echo -e "${YELLOW}Could not copy Chrome history (browser might be locked)${NC}"
        return
    }

    # Calculate today's start in Chrome timestamp format (microseconds since 1601-01-01)
    local today_start
    today_start=$(python3 -c "
from datetime import datetime, timezone
d = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
print(int((d.timestamp() + 11644473600) * 1000000))
")

    # Domain categories for grouping
    declare -A CATEGORIES=(
        ["github.com"]="💻 Development"
        ["stackoverflow.com"]="💻 Development"
        ["gitlab.com"]="💻 Development"
        ["claude.ai"]="🤖 AI Tools"
        ["chat.openai.com"]="🤖 AI Tools"
        ["chatgpt.com"]="🤖 AI Tools"
        ["youtube.com"]="📺 Media"
        ["www.youtube.com"]="📺 Media"
        ["netflix.com"]="📺 Media"
        ["twitter.com"]="📱 Social"
        ["x.com"]="📱 Social"
        ["linkedin.com"]="📱 Social"
        ["www.linkedin.com"]="📱 Social"
        ["facebook.com"]="📱 Social"
        ["instagram.com"]="📱 Social"
        ["mail.google.com"]="📧 Communication"
        ["calendar.google.com"]="📅 Productivity"
        ["keep.google.com"]="📝 Notes"
        ["docs.google.com"]="📄 Documents"
        ["drive.google.com"]="📁 Storage"
        ["sunsama.com"]="📅 Productivity"
        ["app.sunsama.com"]="📅 Productivity"
        ["notion.so"]="📝 Notes"
        ["trello.com"]="📅 Productivity"
        ["amazon.com"]="🛒 Shopping"
        ["amazon.it"]="🛒 Shopping"
        ["corriere.it"]="📰 News"
        ["www.corriere.it"]="📰 News"
        ["repubblica.it"]="📰 News"
    )

    echo -e "${BOLD}Top Sites Today:${NC}"
    echo ""

    # Query and display top domains
    sqlite3 -separator '|' "$TEMP_DB" "
    SELECT
        CASE
            WHEN url LIKE 'https://%' THEN substr(url, 9, instr(substr(url, 9), '/') - 1)
            WHEN url LIKE 'http://%' THEN substr(url, 8, instr(substr(url, 8), '/') - 1)
            ELSE 'other'
        END as domain,
        COUNT(*) as page_views
    FROM urls
    WHERE last_visit_time > $today_start
      AND url NOT LIKE 'chrome-extension://%'
      AND url NOT LIKE 'chrome://%'
    GROUP BY domain
    ORDER BY page_views DESC
    LIMIT 15;
    " | while IFS='|' read -r domain views; do
        # Get category or default
        local category="${CATEGORIES[$domain]:-🔗 Other}"
        printf "  %-20s %3d views  %s\n" "$domain" "$views" "$category"
    done

    # Show category totals
    print_section "📊 Time by Category (estimated)"

    sqlite3 -separator '|' "$TEMP_DB" "
    SELECT
        CASE
            WHEN url LIKE 'https://%' THEN substr(url, 9, instr(substr(url, 9), '/') - 1)
            WHEN url LIKE 'http://%' THEN substr(url, 8, instr(substr(url, 8), '/') - 1)
            ELSE 'other'
        END as domain,
        COUNT(*) as views
    FROM urls
    WHERE last_visit_time > $today_start
      AND url NOT LIKE 'chrome-extension://%'
      AND url NOT LIKE 'chrome://%'
    GROUP BY domain;
    " | {
        declare -A cat_counts
        while IFS='|' read -r domain views; do
            local category="${CATEGORIES[$domain]:-🔗 Other}"
            cat_counts["$category"]=$((${cat_counts["$category"]:-0} + views))
        done

        # Sort and display categories
        for cat in "${!cat_counts[@]}"; do
            echo "${cat_counts[$cat]}|$cat"
        done | sort -t'|' -k1 -rn | while IFS='|' read -r count cat; do
            # Rough estimate: 2 min per page view average
            local mins=$((count * 2))
            local hours=$((mins / 60))
            local remaining_mins=$((mins % 60))
            if [[ $hours -gt 0 ]]; then
                printf "  %-20s ~%dh %dm (%d views)\n" "$cat" "$hours" "$remaining_mins" "$count"
            else
                printf "  %-20s ~%dm (%d views)\n" "$cat" "$mins" "$count"
            fi
        done
    }
}

# ============================================================================
# FILE CLEANUP
# ============================================================================
list_today_files() {
    local dir="$1"
    local label="$2"

    print_section "$label"

    if [[ ! -d "$dir" ]]; then
        echo -e "${YELLOW}Directory not found: $dir${NC}"
        return
    fi

    local files
    files=$(fd -t f --changed-within 1d . "$dir" 2>/dev/null || find "$dir" -maxdepth 1 -type f -mtime 0 2>/dev/null)

    if [[ -z "$files" ]]; then
        echo -e "${GREEN}✓ No new files today${NC}"
        return
    fi

    local count
    count=$(echo "$files" | wc -l)
    echo -e "${YELLOW}Found $count file(s):${NC}"
    echo ""

    local i=1
    echo "$files" | while read -r file; do
        local size
        size=$(du -h "$file" 2>/dev/null | cut -f1)
        local basename
        basename=$(basename "$file")
        printf "  [%2d] %-50s %8s\n" "$i" "${basename:0:50}" "$size"
        ((i++))
    done
}

cleanup_files() {
    local dir="$1"
    local label="$2"
    local _action="${3:-interactive}"  # interactive, delete, archive (future use)

    if [[ ! -d "$dir" ]]; then
        return
    fi

    local files
    files=$(fd -t f --changed-within 1d . "$dir" 2>/dev/null)

    if [[ -z "$files" ]]; then
        return
    fi

    echo ""
    echo -e "${BOLD}Actions for $label:${NC}"
    echo "  [k] Keep all"
    echo "  [d] Delete all"
    echo "  [a] Archive all (move to $ARCHIVE_DIR)"
    echo "  [i] Interactive (choose per file)"
    echo "  [s] Skip"
    echo ""
    read -rp "Choice [k/d/a/i/s]: " choice

    case "$choice" in
        d|D)
            echo "$files" | while read -r file; do
                rm -f "$file" && echo -e "${RED}Deleted: $(basename "$file")${NC}"
            done
            ;;
        a|A)
            mkdir -p "$ARCHIVE_DIR"
            echo "$files" | while read -r file; do
                mv "$file" "$ARCHIVE_DIR/" && echo -e "${BLUE}Archived: $(basename "$file")${NC}"
            done
            ;;
        i|I)
            echo "$files" | while read -r file; do
                echo ""
                echo -e "File: ${CYAN}$(basename "$file")${NC}"
                read -rp "  [k]eep / [d]elete / [a]rchive? " fchoice
                case "$fchoice" in
                    d|D) rm -f "$file" && echo -e "${RED}Deleted${NC}" ;;
                    a|A) mkdir -p "$ARCHIVE_DIR"; mv "$file" "$ARCHIVE_DIR/" && echo -e "${BLUE}Archived${NC}" ;;
                    *) echo -e "${GREEN}Kept${NC}" ;;
                esac
            done
            ;;
        k|K|s|S|*)
            echo -e "${GREEN}Files kept${NC}"
            ;;
    esac
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    local mode="${1:-interactive}"

    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║          EOD CLEANUP - $(date '+%Y-%m-%d %H:%M')               ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"

    # Browser summary
    show_browser_summary

    # File listings
    print_header "📁 TODAY'S FILES"

    list_today_files "$SCREENSHOTS_DIR" "📸 Screenshots"
    list_today_files "$DOWNLOADS_DIR" "📥 Downloads"

    # Cleanup mode
    if [[ "$mode" == "interactive" ]]; then
        print_header "🧹 CLEANUP"
        cleanup_files "$SCREENSHOTS_DIR" "Screenshots"
        cleanup_files "$DOWNLOADS_DIR" "Downloads"
    fi

    echo ""
    echo -e "${GREEN}✓ EOD Cleanup complete${NC}"
    echo ""
}

# Help
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") [--report|--interactive]"
    echo ""
    echo "Options:"
    echo "  --report       Show summary only, no cleanup prompts"
    echo "  --interactive  Interactive cleanup (default)"
    echo ""
    exit 0
fi

# Run
case "${1:-}" in
    --report|-r)
        main report
        ;;
    *)
        main interactive
        ;;
esac
