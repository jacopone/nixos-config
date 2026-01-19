#!/usr/bin/env bash
# Review Files - Visual review of screenshots and downloads
# Opens each file for preview, then asks keep/delete/skip

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Config
SCREENSHOTS_DIR="${HOME}/Pictures/Screenshots"
DOWNLOADS_DIR="${HOME}/Downloads"
TRASH_DIR="${HOME}/.local/share/Trash/files"

# Google Drive via GNOME Online Accounts (GVFS)
GDRIVE_BASE="/run/user/$(id -u)/gvfs/google-drive:host=gmail.com,user=jacopo.anselmi"
GDRIVE_ARCHIVE="${GDRIVE_BASE}/0ADnfB1aZUjtGUk9PVA/Archive/$(date +%Y/%m)"

# Stats
DELETED=0
KEPT=0
SKIPPED=0
ARCHIVED=0

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Open file based on type
open_file() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}"  # lowercase

    case "$ext" in
        png|jpg|jpeg|gif|webp|bmp)
            # Image: prefer kitty icat (inline, no focus switch), fallback to feh
            if [[ "$TERM" == "xterm-kitty" ]] && command -v kitten &>/dev/null; then
                # Clear previous image, then show new one inline
                # Use </dev/null to prevent consuming the while loop's stdin
                kitten icat --clear </dev/null 2>/dev/null || true
                kitten icat "$file" </dev/null
                FEH_PID=""
            else
                feh --scale-down --auto-zoom "$file" &
                FEH_PID=$!
            fi
            ;;
        pdf)
            xdg-open "$file" &
            FEH_PID=$!
            ;;
        mp4|mkv|webm|mov|avi)
            # Video: use mpv or xdg-open
            if command -v mpv &>/dev/null; then
                mpv --really-quiet "$file" &
            else
                xdg-open "$file" &
            fi
            FEH_PID=$!
            ;;
        doc|docx|xls|xlsx|ppt|pptx|odt|ods|odp)
            xdg-open "$file" &
            FEH_PID=$!
            ;;
        *)
            # Text or unknown: use bat or less
            if command -v bat &>/dev/null; then
                bat --paging=never "$file" 2>/dev/null || cat "$file"
            else
                head -50 "$file"
            fi
            FEH_PID=""
            ;;
    esac
}

close_viewer() {
    if [[ -n "${FEH_PID:-}" ]]; then
        kill "$FEH_PID" 2>/dev/null || true
        FEH_PID=""
    fi
    # Clear kitty inline image
    if [[ "$TERM" == "xterm-kitty" ]]; then
        kitten icat --clear 2>/dev/null || true
    fi
}

# Move to trash (safer than rm)
trash_file() {
    local file="$1"
    mkdir -p "$TRASH_DIR"
    mv "$file" "$TRASH_DIR/" 2>/dev/null && return 0
    # Fallback: delete if trash move fails
    rm -f "$file"
}

# Archive to Google Drive
archive_file() {
    local file="$1"

    # Check if GDrive is mounted
    if [[ ! -d "$GDRIVE_BASE" ]]; then
        echo -e "  ${RED}Google Drive not mounted. Using local archive.${NC}"
        mkdir -p "${HOME}/Archive/$(date +%Y/%m)"
        mv "$file" "${HOME}/Archive/$(date +%Y/%m)/" && return 0
        return 1
    fi

    # Create archive folder on GDrive if needed
    mkdir -p "$GDRIVE_ARCHIVE" 2>/dev/null || {
        echo -e "  ${YELLOW}Can't create GDrive folder. Using local archive.${NC}"
        mkdir -p "${HOME}/Archive/$(date +%Y/%m)"
        mv "$file" "${HOME}/Archive/$(date +%Y/%m)/" && return 0
        return 1
    }

    # Copy to GDrive then delete local (safer than mv for network drives)
    cp "$file" "$GDRIVE_ARCHIVE/" && rm -f "$file" && return 0
    return 1
}

review_files() {
    local dir="$1"
    local label="$2"
    local age="${3:-1d}"  # default: files from last 1 day

    print_header "📋 REVIEWING: $label"

    if [[ ! -d "$dir" ]]; then
        echo -e "${YELLOW}Directory not found: $dir${NC}"
        return
    fi

    # Get files into array
    local -a files_array
    mapfile -t files_array < <(fd -t f --changed-within "$age" . "$dir" 2>/dev/null | sort)

    if [[ ${#files_array[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓ No files to review${NC}"
        return
    fi

    local total=${#files_array[@]}
    local current=0

    echo -e "Found ${YELLOW}$total${NC} file(s) to review"
    echo ""
    echo -e "${BOLD}Controls:${NC}"
    echo "  [d] Delete (move to trash)"
    echo "  [a] Archive (move to GDrive/Archive)"
    echo "  [k] Keep"
    echo "  [s] Skip"
    echo "  [D] Delete ALL remaining"
    echo "  [A] Archive ALL remaining"
    echo "  [q] Quit review"
    echo ""

    for file in "${files_array[@]}"; do
        ((++current))  # prefix increment to avoid exit code 1 when current=0

        local basename
        basename=$(basename "$file")
        local size
        size=$(du -h "$file" 2>/dev/null | cut -f1)
        local mtime
        mtime=$(date -r "$file" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")

        echo ""
        echo -e "${BOLD}[$current/$total]${NC} ${CYAN}$basename${NC}"
        echo -e "  Size: $size | Modified: $mtime"

        # Open file for preview
        open_file "$file"

        # Prompt for action (read from /dev/tty to avoid conflict with file loop)
        while true; do
            read -rp "  Action [d/a/k/s/D/A/q]: " action </dev/tty
            case "$action" in
                d)
                    close_viewer
                    trash_file "$file"
                    echo -e "  ${RED}→ Deleted${NC}"
                    DELETED=$((DELETED + 1))
                    break
                    ;;
                a)
                    close_viewer
                    archive_file "$file"
                    echo -e "  ${BLUE}→ Archived${NC}"
                    ARCHIVED=$((ARCHIVED + 1))
                    break
                    ;;
                k)
                    close_viewer
                    echo -e "  ${GREEN}→ Kept${NC}"
                    KEPT=$((KEPT + 1))
                    break
                    ;;
                s)
                    close_viewer
                    echo -e "  ${YELLOW}→ Skipped${NC}"
                    SKIPPED=$((SKIPPED + 1))
                    break
                    ;;
                D)
                    close_viewer
                    # Delete this and all remaining
                    trash_file "$file"
                    DELETED=$((DELETED + 1))
                    for ((i=current; i<total; i++)); do
                        trash_file "${files_array[$i]}"
                        DELETED=$((DELETED + 1))
                    done
                    echo -e "  ${RED}→ Deleted all remaining ($((total - current + 1)) files)${NC}"
                    return
                    ;;
                A)
                    close_viewer
                    # Archive this and all remaining
                    archive_file "$file"
                    ARCHIVED=$((ARCHIVED + 1))
                    for ((i=current; i<total; i++)); do
                        archive_file "${files_array[$i]}"
                        ARCHIVED=$((ARCHIVED + 1))
                    done
                    echo -e "  ${BLUE}→ Archived all remaining ($((total - current + 1)) files)${NC}"
                    return
                    ;;
                q)
                    close_viewer
                    echo -e "  ${YELLOW}→ Quit${NC}"
                    return
                    ;;
                *)
                    echo -e "  ${YELLOW}Invalid. Use: d=delete, a=archive, k=keep, s=skip, q=quit${NC}"
                    ;;
            esac
        done
    done
}

print_summary() {
    print_header "📊 SUMMARY"
    echo -e "  ${RED}Deleted:${NC}  $DELETED"
    echo -e "  ${BLUE}Archived:${NC} $ARCHIVED"
    echo -e "  ${GREEN}Kept:${NC}     $KEPT"
    echo -e "  ${YELLOW}Skipped:${NC}  $SKIPPED"
    echo ""

    # Show trash size
    if [[ -d "$TRASH_DIR" ]]; then
        local trash_size
        trash_size=$(du -sh "$TRASH_DIR" 2>/dev/null | cut -f1)
        echo -e "  Trash size: $trash_size"
        echo -e "  ${CYAN}Tip: Empty trash with 'gio trash --empty'${NC}"
    fi

    # Show archive location
    if [[ $ARCHIVED -gt 0 ]]; then
        if [[ -d "$GDRIVE_BASE" ]]; then
            echo -e "  ${BLUE}Archived to: GDrive/Archive/$(date +%Y/%m)${NC}"
        else
            echo -e "  ${BLUE}Archived to: ~/Archive/$(date +%Y/%m)${NC}"
        fi
    fi
}

# Trap to ensure viewer is closed
trap 'close_viewer' EXIT

# Main
main() {
    local mode="${1:-all}"
    local age="${2:-1d}"

    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║          FILE REVIEW - $(date '+%Y-%m-%d %H:%M')                ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"

    case "$mode" in
        screenshots|ss)
            review_files "$SCREENSHOTS_DIR" "Screenshots" "$age"
            ;;
        downloads|dl)
            review_files "$DOWNLOADS_DIR" "Downloads" "$age"
            ;;
        all|*)
            review_files "$SCREENSHOTS_DIR" "Screenshots" "$age"
            review_files "$DOWNLOADS_DIR" "Downloads" "$age"
            ;;
    esac

    print_summary
}

# Help
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") [screenshots|downloads|all] [age]"
    echo ""
    echo "Modes:"
    echo "  screenshots, ss  Review only screenshots"
    echo "  downloads, dl    Review only downloads"
    echo "  all              Review both (default)"
    echo ""
    echo "Age (optional):"
    echo "  1d    Files from last 1 day (default)"
    echo "  1w    Files from last 1 week"
    echo "  1m    Files from last 1 month"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")              # Review today's files"
    echo "  $(basename "$0") ss           # Review only screenshots"
    echo "  $(basename "$0") dl 1w        # Review downloads from last week"
    echo ""
    exit 0
fi

main "$@"
