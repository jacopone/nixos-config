#!/usr/bin/env bash
# Restore a machine after fresh NixOS install.
# Run after MACHINE_RESTORE.md Step 3 (NixOS rebuilt, gh + rclone working).
#
# Phase 1: Clone all GitHub repos
# Phase 2: Restore gitignored data from Drive backup
#
# Usage: ./scripts/restore-machine.sh <source-hostname>

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

GITHUB_USER="jacopone"

# ============================================================================
# Helpers
# ============================================================================

print_phase() {
    echo ""
    echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

info()  { echo -e "  ${GREEN}[OK]${NC} $*"; }
skip()  { echo -e "  ${YELLOW}[SKIP]${NC} $*"; }
fail()  { echo -e "  ${RED}[ERROR]${NC} $*"; }

# ============================================================================
# Usage and argument parsing
# ============================================================================

show_usage() {
    echo "Usage: $0 <source-hostname>"
    echo ""
    echo "Restore repos and gitignored data from a Drive backup."
    echo ""
    echo "Available backups on gdrive:backups/:"
    rclone lsd gdrive:backups/ 2>/dev/null | awk '{print "  " $NF}' || {
        fail "Could not list Drive backups. Is rclone configured?"
        exit 1
    }
    echo ""
    exit 1
}

SOURCE_HOST="${1:-}"
if [[ -z "$SOURCE_HOST" ]]; then
    show_usage
fi

# ============================================================================
# Preflight checks
# ============================================================================

echo ""
echo -e "${BOLD}Preflight checks${NC}"

if ! command -v gh &>/dev/null; then
    fail "gh (GitHub CLI) is not installed"
    exit 1
fi
info "gh is installed"

if ! gh auth status &>/dev/null; then
    fail "gh is not authenticated (run: gh auth login)"
    exit 1
fi
info "gh is authenticated"

if ! command -v rclone &>/dev/null; then
    fail "rclone is not installed"
    exit 1
fi
info "rclone is installed"

BACKUP_BASE="gdrive:backups/$SOURCE_HOST"
if ! rclone lsd "$BACKUP_BASE" &>/dev/null; then
    fail "Backup not found: $BACKUP_BASE"
    echo ""
    echo "Available backups:"
    rclone lsd gdrive:backups/ 2>/dev/null | awk '{print "  " $NF}'
    exit 1
fi
info "Backup exists: $BACKUP_BASE"

# ============================================================================
# Phase 1: Clone all GitHub repos
# ============================================================================

print_phase "Phase 1: Clone GitHub repos"

cloned=0
skipped=0

while IFS=$'\t' read -r name ssh_url; do
    if [[ "$name" == "nixos-config" ]]; then
        skip "$name (already present from Step 3)"
        skipped=$((skipped + 1))
        continue
    fi

    target="$HOME/$name"
    if [[ -d "$target" ]]; then
        skip "$name (already exists)"
        skipped=$((skipped + 1))
        continue
    fi

    echo -e "  Cloning ${BOLD}$name${NC}..."
    if git clone "$ssh_url" "$target" --quiet 2>/dev/null; then
        info "$name"
        cloned=$((cloned + 1))
    else
        fail "$name (clone failed)"
    fi
done < <(gh repo list "$GITHUB_USER" --limit 200 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv')

echo ""
echo -e "  ${BOLD}Phase 1 summary:${NC} cloned $cloned, skipped $skipped"

# ============================================================================
# Phase 2: Restore gitignored data from Drive backup
# ============================================================================

print_phase "Phase 2: Restore gitignored data from Drive backup ($SOURCE_HOST)"

restored=0
phase2_skipped=0

# Restore a directory: restore_dir <drive_subpath> <local_path> <label>
restore_dir() {
    local drive_path="$BACKUP_BASE/$1"
    local local_path="$2"
    local label="$3"
    local parent_dir
    parent_dir=$(dirname "$local_path")

    # Check if the parent repo directory exists
    # For paths like ~/some-repo/sub/dir, check ~/some-repo
    local repo_dir
    repo_dir=$(echo "$local_path" | sed "s|^$HOME/||" | cut -d'/' -f1)
    repo_dir="$HOME/$repo_dir"

    if [[ ! -d "$repo_dir" ]]; then
        skip "$label (repo $repo_dir not found)"
        phase2_skipped=$((phase2_skipped + 1))
        return
    fi

    mkdir -p "$local_path"
    echo -e "  Restoring ${BOLD}$label${NC}..."
    if rclone sync "$drive_path/" "$local_path/" --transfers 4 --quiet 2>/dev/null; then
        info "$label"
        restored=$((restored + 1))
    else
        fail "$label"
    fi
}

# Restore a single file: restore_file <drive_subpath> <local_path> <label>
restore_file() {
    local drive_path="$BACKUP_BASE/$1"
    local local_path="$2"
    local label="$3"
    local parent_dir
    parent_dir=$(dirname "$local_path")

    # Check if the parent repo directory exists
    local repo_dir
    repo_dir=$(echo "$local_path" | sed "s|^$HOME/||" | cut -d'/' -f1)
    repo_dir="$HOME/$repo_dir"

    if [[ ! -d "$repo_dir" ]]; then
        skip "$label (repo $repo_dir not found)"
        phase2_skipped=$((phase2_skipped + 1))
        return
    fi

    mkdir -p "$parent_dir"
    echo -e "  Restoring ${BOLD}$label${NC}..."
    if rclone copyto "$drive_path" "$local_path" --quiet 2>/dev/null; then
        info "$label"
        restored=$((restored + 1))
    else
        fail "$label"
    fi
}

# --- Restore mappings (inverse of backup-sync.nix) ---

# WhatsApp message archive
restore_dir \
    "whatsapp-db" \
    "$HOME/whatsapp-mcp/whatsapp-bridge/store" \
    "WhatsApp DB"

# Bimby nutritionist recipes
restore_file \
    "bimby-nutritionist/recipes.sqlite" \
    "$HOME/bimby-nutritionist/data/recipes.sqlite" \
    "Bimby recipes"

# Yuka food/cosmetics database
restore_dir \
    "yuka-db" \
    "$HOME/bimby-hacking/yuka/database" \
    "Yuka DB"

# Albo commercialisti data directory
restore_dir \
    "gitignored-critical/albo-commercialisti/data" \
    "$HOME/albo-commercialisti/data" \
    "Albo commercialisti data"

# Albo commercialisti .env
restore_file \
    "gitignored-critical/albo-commercialisti/.env" \
    "$HOME/albo-commercialisti/.env" \
    "Albo commercialisti .env"

# Birthday manager events database
# Note: the repo has a literal $HOME directory inside it (not expanded)
restore_file \
    "birthday-manager/events.db" \
    "$HOME/birthday-manager-ts/\$HOME/.local/share/birthday-manager/events.db" \
    "Birthday manager events"

# PTA ledger
restore_dir \
    "pta-ledger" \
    "$HOME/pta-ledger/ledger" \
    "PTA ledger"

# gogcli credentials
# Special case: ~/.config/gogcli is not inside a repo clone
if [[ -d "$HOME/.config" ]]; then
    restore_dir \
        "gogcli" \
        "$HOME/.config/gogcli" \
        "gogcli credentials"
else
    skip "gogcli credentials (~/.config not found)"
    phase2_skipped=$((phase2_skipped + 1))
fi

echo ""
echo -e "  ${BOLD}Phase 2 summary:${NC} restored $restored, skipped $phase2_skipped"

# ============================================================================
# Done
# ============================================================================

echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  Restore complete${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
