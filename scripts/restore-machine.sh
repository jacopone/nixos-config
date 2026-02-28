#!/usr/bin/env bash
# Restore a machine after fresh NixOS install.
# Run after MACHINE_RESTORE.md Step 1 (rclone bootstrapped).
#
# Phase 1: Restore system configs (SSH, GPG, Claude, shell history, etc.)
# Phase 2: Clone all GitHub repos
# Phase 3: Restore gitignored project data (databases, .env files)
# Phase 4: Verify restore (functional + existence checks)
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
# Phase 1: Restore system configs from Drive backup
# ============================================================================

print_phase "Phase 1: Restore system configs from $SOURCE_HOST"

config_restored=0
config_failed=0

# restore_config: like restore_dir but no repo-exists check (system dirs)
restore_config() {
    local drive_path="$BACKUP_BASE/$1"
    local local_path="$2"
    local label="$3"

    mkdir -p "$local_path"
    echo -e "  Restoring ${BOLD}$label${NC}..."
    if rclone copy "$drive_path/" "$local_path/" --transfers 4 --quiet 2>/dev/null; then
        info "$label"
        config_restored=$((config_restored + 1))
    else
        fail "$label"
        config_failed=$((config_failed + 1))
    fi
}

# Identity and auth
restore_config "ssh"       "$HOME/.ssh"                  "SSH keys"
restore_config "gh"        "$HOME/.config/gh"            "GitHub CLI"
restore_config "gnupg"     "$HOME/.gnupg"                "GPG keys"
restore_config "rclone"    "$HOME/.config/rclone"        "rclone config"

# Fix permissions (SSH and GPG require strict perms)
chmod 700 "$HOME/.ssh" 2>/dev/null || true
chmod 600 "$HOME/.ssh"/id_* 2>/dev/null || true
chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
chmod 700 "$HOME/.gnupg" 2>/dev/null || true

# Register SSH key with GitHub (new machine needs the key associated)
if gh auth status &>/dev/null; then
    pub_key=$(find "$HOME/.ssh" -name "*.pub" -type f | head -1)
    if [[ -n "$pub_key" ]]; then
        key_name="$(hostname)-$(date +%Y%m%d)"
        if gh ssh-key add "$pub_key" --title "$key_name" 2>/dev/null; then
            info "SSH key registered with GitHub as $key_name"
        else
            skip "SSH key already registered with GitHub (or scope missing)"
        fi
    fi
fi

# Claude Code (settings, permissions, memory, sessions)
restore_config "claude"    "$HOME/.claude"               "Claude Code"

# Shell and terminal
restore_config "atuin"     "$HOME/.local/share/atuin"    "Atuin history"
restore_config "fish"      "$HOME/.config/fish"          "Fish config"

# Cloud and dev tools
restore_config "gcloud"    "$HOME/.config/gcloud"        "Google Cloud"

# Desktop data
restore_config "keyrings"  "$HOME/.local/share/keyrings" "GNOME keyrings"

# Custom scripts
restore_config "local-bin" "$HOME/.local/bin"            "Local scripts"

# Clean up stale lock files from the source machine
# Chrome Singleton files contain the old hostname/PID and block launch
for f in SingletonLock SingletonCookie SingletonSocket; do
    if [[ -e "$HOME/.config/google-chrome/$f" ]]; then
        rm -f "$HOME/.config/google-chrome/$f"
        info "Removed stale Chrome $f"
    fi
done

echo ""
echo -e "  ${BOLD}Phase 1 summary:${NC} restored $config_restored, failed $config_failed"

# ============================================================================
# Phase 2: Clone all GitHub repos
# ============================================================================

print_phase "Phase 2: Clone GitHub repos"

cloned=0
skipped=0
clone_failed=0

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
        clone_failed=$((clone_failed + 1))
    fi
done < <(gh repo list "$GITHUB_USER" --limit 200 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv')

echo ""
echo -e "  ${BOLD}Phase 2 summary:${NC} cloned $cloned, skipped $skipped, failed $clone_failed"

# ============================================================================
# Phase 3: Restore gitignored project data from Drive backup
# ============================================================================

print_phase "Phase 3: Restore gitignored project data from $SOURCE_HOST"

restored=0
phase2_skipped=0
restore_failed=0

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
    if rclone copy "$drive_path/" "$local_path/" --transfers 4 --quiet 2>/dev/null; then
        info "$label"
        restored=$((restored + 1))
    else
        fail "$label"
        restore_failed=$((restore_failed + 1))
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
        restore_failed=$((restore_failed + 1))
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
    "$HOME/birthday-manager/\$HOME/.local/share/birthday-manager/events.db" \
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

# Chrome extension data (Simplify Gmail settings)
# Special case: Chrome extension storage, not inside a repo clone
# Chrome must be closed or it overwrites restored data on exit
if [[ -d "$HOME/.config/google-chrome/Default/Local Extension Settings" ]]; then
    if pgrep -f "google-chrome" &>/dev/null; then
        echo -e "  ${YELLOW}Closing Chrome to restore extension data...${NC}"
        pkill -TERM -f "google-chrome" 2>/dev/null
        sleep 3
        # Force kill if still running
        pkill -9 -f "google-chrome" 2>/dev/null || true
        sleep 1
    fi
    restore_dir \
        "chrome-extensions/simplify-gmail" \
        "$HOME/.config/google-chrome/Default/Local Extension Settings/pbmlfaiicoikhdbjagjbglnbfcbcojpj" \
        "Simplify Gmail settings"
    # Clean up stale lock files from source machine
    for f in SingletonLock SingletonCookie SingletonSocket; do
        rm -f "$HOME/.config/google-chrome/$f" 2>/dev/null
    done
else
    skip "Simplify Gmail settings (Chrome extension storage not found)"
    phase2_skipped=$((phase2_skipped + 1))
fi

echo ""
echo -e "  ${BOLD}Phase 3 summary:${NC} restored $restored, skipped $phase2_skipped, failed $restore_failed"

# ============================================================================
# Phase 4: Verify restore
# ============================================================================

print_phase "Phase 4: Verify restore"

verify_ok=0
verify_warn=0

check_ok()   { info "$*"; verify_ok=$((verify_ok + 1)); }
check_warn() { skip "$*"; verify_warn=$((verify_warn + 1)); }

# --- Phase 1: System configs ---

echo -e "  ${BOLD}System configs${NC}"

# SSH: functional check (ssh -T exits 1 on success with GitHub)
if ssh -T git@github.com 2>&1 | grep -qi "successfully authenticated"; then
    check_ok "SSH → GitHub authenticated"
elif [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]; then
    check_warn "SSH → key exists but GitHub auth failed (check known_hosts or key registration)"
else
    check_warn "SSH → no key found"
fi

# GitHub CLI
if gh auth status &>/dev/null; then
    check_ok "GitHub CLI → authenticated"
else
    check_warn "GitHub CLI → not authenticated"
fi

# GPG
if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q sec; then
    check_ok "GPG → secret keys present"
else
    check_warn "GPG → no secret keys found"
fi

# rclone
if rclone listremotes 2>/dev/null | grep -q "gdrive:"; then
    check_ok "rclone → gdrive remote configured"
else
    check_warn "rclone → gdrive remote not found"
fi

# Claude Code
if [[ -f "$HOME/.claude/settings.json" ]]; then
    check_ok "Claude Code → settings.json exists"
else
    check_warn "Claude Code → settings.json missing"
fi

# Atuin
if [[ -f "$HOME/.local/share/atuin/history.db" ]]; then
    check_ok "Atuin → history.db exists"
else
    check_warn "Atuin → history.db missing"
fi

# Fish
if [[ -f "$HOME/.config/fish/fish_variables" ]]; then
    check_ok "Fish → fish_variables exists"
else
    check_warn "Fish → fish_variables missing"
fi

# gcloud
if [[ -d "$HOME/.config/gcloud" ]] && [[ -n "$(ls -A "$HOME/.config/gcloud" 2>/dev/null)" ]]; then
    check_ok "gcloud → config directory has files"
else
    check_warn "gcloud → config directory empty or missing"
fi

# Keyrings
if [[ -d "$HOME/.local/share/keyrings" ]] && [[ -n "$(ls -A "$HOME/.local/share/keyrings" 2>/dev/null)" ]]; then
    check_ok "GNOME keyrings → keyring files present"
else
    check_warn "GNOME keyrings → no keyring files found"
fi

# Local scripts
if [[ -d "$HOME/.local/bin" ]] && [[ -n "$(ls -A "$HOME/.local/bin" 2>/dev/null)" ]]; then
    check_ok "Local scripts → ~/.local/bin has files"
else
    check_warn "Local scripts → ~/.local/bin empty or missing"
fi

# --- Phase 2: GitHub repos ---

echo ""
echo -e "  ${BOLD}GitHub repos${NC}"

gh_count=$(gh repo list "$GITHUB_USER" --limit 200 --json name --jq 'length' 2>/dev/null || echo "0")
# Count directories in $HOME that are git repos (excluding common non-repo dirs)
local_repos=0
for d in "$HOME"/*/; do
    if [[ -d "$d/.git" ]]; then
        local_repos=$((local_repos + 1))
    fi
done

if [[ "$local_repos" -ge "$gh_count" ]] && [[ "$gh_count" -gt 0 ]]; then
    check_ok "Repos → $local_repos local git repos (GitHub has $gh_count)"
elif [[ "$gh_count" -gt 0 ]]; then
    check_warn "Repos → $local_repos local git repos vs $gh_count on GitHub ($(( gh_count - local_repos )) missing)"
else
    check_warn "Repos → could not query GitHub repo count"
fi

# --- Phase 3: Project data ---

echo ""
echo -e "  ${BOLD}Project data${NC}"

# Helper: check file exists (skip if parent repo missing)
check_project_file() {
    local file_path="$1"
    local label="$2"
    local repo_dir
    repo_dir=$(echo "$file_path" | sed "s|^$HOME/||" | cut -d'/' -f1)
    repo_dir="$HOME/$repo_dir"

    if [[ ! -d "$repo_dir" ]]; then
        check_warn "$label → repo not cloned, skipped"
        return
    fi

    if [[ -f "$file_path" ]]; then
        check_ok "$label"
    else
        check_warn "$label → file missing"
    fi
}

# Helper: check directory has files (skip if parent repo missing)
check_project_dir() {
    local dir_path="$1"
    local label="$2"
    local repo_dir
    repo_dir=$(echo "$dir_path" | sed "s|^$HOME/||" | cut -d'/' -f1)
    repo_dir="$HOME/$repo_dir"

    if [[ ! -d "$repo_dir" ]]; then
        check_warn "$label → repo not cloned, skipped"
        return
    fi

    if [[ -d "$dir_path" ]] && [[ -n "$(ls -A "$dir_path" 2>/dev/null)" ]]; then
        check_ok "$label"
    else
        check_warn "$label → directory empty or missing"
    fi
}

check_project_dir  "$HOME/whatsapp-mcp/whatsapp-bridge/store"  "WhatsApp DB"
check_project_file "$HOME/bimby-nutritionist/data/recipes.sqlite" "Bimby recipes"
check_project_dir  "$HOME/bimby-hacking/yuka/database"         "Yuka DB"
check_project_dir  "$HOME/albo-commercialisti/data"             "Albo data"
check_project_file "$HOME/albo-commercialisti/.env"             "Albo .env"
check_project_file "$HOME/birthday-manager/\$HOME/.local/share/birthday-manager/events.db" "Birthday events"
check_project_dir  "$HOME/pta-ledger/ledger"                    "PTA ledger"

# gogcli is a config dir, not inside a repo
if [[ -d "$HOME/.config/gogcli" ]] && [[ -n "$(ls -A "$HOME/.config/gogcli" 2>/dev/null)" ]]; then
    check_ok "gogcli credentials"
else
    check_warn "gogcli credentials → missing or empty"
fi

# Simplify Gmail extension data
simplify_dir="$HOME/.config/google-chrome/Default/Local Extension Settings/pbmlfaiicoikhdbjagjbglnbfcbcojpj"
if [[ -d "$simplify_dir" ]] && [[ -n "$(ls -A "$simplify_dir" 2>/dev/null)" ]]; then
    check_ok "Simplify Gmail settings"
else
    check_warn "Simplify Gmail settings → missing or empty"
fi

# --- System services ---

echo ""
echo -e "  ${BOLD}System services${NC}"

if systemctl --user is-active rclone-gdrive &>/dev/null; then
    check_ok "rclone-gdrive mount → active"
else
    check_warn "rclone-gdrive mount → not active (may need nixos-rebuild first)"
fi

if systemctl --user is-active backup-configs.timer &>/dev/null; then
    check_ok "backup-configs timer → active"
else
    check_warn "backup-configs timer → not active (run: systemctl --user enable --now backup-configs.timer)"
fi

# --- Verification summary ---

echo ""
echo -e "  ${BOLD}Phase 4 summary:${NC} $verify_ok passed, $verify_warn warnings"

if [[ $verify_warn -gt 0 ]]; then
    echo -e "  ${YELLOW}Review warnings above. Some may resolve after nixos-rebuild or reboot.${NC}"
fi

# ============================================================================
# Done
# ============================================================================

total_failed=$((config_failed + clone_failed + restore_failed))
if [[ $total_failed -gt 0 ]]; then
    echo ""
    echo -e "${BOLD}${RED}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${RED}  Restore finished with $total_failed failure(s). Review output above.${NC}"
    echo -e "${BOLD}${RED}════════════════════════════════════════════════════════════${NC}"
    echo ""
    exit 1
fi

echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  Restore complete${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
