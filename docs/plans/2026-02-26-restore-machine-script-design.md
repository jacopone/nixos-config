---
status: active
created: 2026-02-26
updated: 2026-02-26
type: planning
lifecycle: persistent
---

# Restore Machine Script — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a restore script that clones all GitHub repos and restores gitignored backed-up data into them, closing the gap in MACHINE_RESTORE.md.

**Architecture:** Single bash script `scripts/restore-machine.sh` with two phases (clone repos → restore data). Backup module updated to sync MACHINE_RESTORE.md to Drive root. Restore guide updated with new step.

**Tech Stack:** Bash, `gh` CLI, `rclone`, existing NixOS backup infrastructure.

---

### Task 1: Create `scripts/restore-machine.sh`

**Files:**
- Create: `scripts/restore-machine.sh`

**Step 1: Write the script**

```bash
#!/usr/bin/env bash
# Restore machine: clone all GitHub repos + restore gitignored data from Drive backup
# Usage: ./restore-machine.sh <source-hostname>
# Run after MACHINE_RESTORE.md Step 3 (NixOS rebuilt, gh + rclone working)
set -euo pipefail

SOURCE_HOST="${1:-}"
GITHUB_USER="jacopone"
CLONE_DIR="$HOME"

if [ -z "$SOURCE_HOST" ]; then
  echo "Usage: $0 <source-hostname>"
  echo "Example: $0 thinkpad-x1-jacopo"
  echo ""
  echo "Available backups:"
  rclone lsd gdrive:backups/ 2>/dev/null | awk '{print "  " $NF}'
  exit 1
fi

# Verify prerequisites
command -v gh >/dev/null || { echo "ERROR: gh (GitHub CLI) not found"; exit 1; }
command -v rclone >/dev/null || { echo "ERROR: rclone not found"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated. Run: gh auth login"; exit 1; }

BASE="gdrive:backups/$SOURCE_HOST"

# Verify source backup exists
if ! rclone lsd "gdrive:backups/" 2>/dev/null | grep -q "$SOURCE_HOST"; then
  echo "ERROR: No backup found for '$SOURCE_HOST'"
  echo "Available backups:"
  rclone lsd gdrive:backups/ 2>/dev/null | awk '{print "  " $NF}'
  exit 1
fi

# ── Phase 1: Clone all GitHub repos ──────────────────────────────────

echo ""
echo "═══ Phase 1: Clone GitHub repos ═══"
echo ""

CLONED=0
SKIPPED=0

while IFS=$'\t' read -r name url; do
  target="$CLONE_DIR/$name"
  if [ -d "$target" ]; then
    echo "  SKIP  $name (already exists)"
    SKIPPED=$((SKIPPED + 1))
  else
    echo "  CLONE $name"
    git clone "$url" "$target" 2>&1 | sed 's/^/        /'
    CLONED=$((CLONED + 1))
  fi
done < <(gh repo list "$GITHUB_USER" --limit 200 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv')

echo ""
echo "Repos: $CLONED cloned, $SKIPPED already present"

# ── Phase 2: Restore gitignored data from Drive backup ───────────────

echo ""
echo "═══ Phase 2: Restore gitignored data from $SOURCE_HOST ═══"
echo ""

RESTORED=0
SKIP_RESTORE=0

restore_dir() {
  local src="$1" dest="$2" label="$3"
  local repo_dir
  repo_dir="$(dirname "$dest")"
  # Walk up to find the repo root (first level under $HOME)
  while [ "$(dirname "$repo_dir")" != "$HOME" ] && [ "$repo_dir" != "$HOME" ]; do
    repo_dir="$(dirname "$repo_dir")"
  done
  if [ ! -d "$repo_dir" ]; then
    echo "  SKIP  $label (repo dir $repo_dir not found)"
    SKIP_RESTORE=$((SKIP_RESTORE + 1))
    return
  fi
  echo "  RESTORE $label → $dest"
  mkdir -p "$dest"
  rclone sync "$BASE/$src/" "$dest/" --transfers 2 --quiet
  RESTORED=$((RESTORED + 1))
}

restore_file() {
  local src="$1" dest="$2" label="$3"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  local repo_dir="$dest_dir"
  while [ "$(dirname "$repo_dir")" != "$HOME" ] && [ "$repo_dir" != "$HOME" ]; do
    repo_dir="$(dirname "$repo_dir")"
  done
  if [ ! -d "$repo_dir" ]; then
    echo "  SKIP  $label (repo dir $repo_dir not found)"
    SKIP_RESTORE=$((SKIP_RESTORE + 1))
    return
  fi
  echo "  RESTORE $label → $dest"
  mkdir -p "$dest_dir"
  rclone copyto "$BASE/$src" "$dest" --quiet
  RESTORED=$((RESTORED + 1))
}

# Mapping: inverse of backup-sync.nix (lines 62-82)
# Project databases
restore_dir  "whatsapp-db"                                "$HOME/whatsapp-mcp/whatsapp-bridge/store"                              "WhatsApp DB"
restore_file "bimby-nutritionist/recipes.sqlite"          "$HOME/bimby-nutritionist/data/recipes.sqlite"                          "Bimby recipes"
restore_dir  "yuka-db"                                    "$HOME/bimby-hacking/yuka/database"                                    "Yuka DB"
restore_dir  "gitignored-critical/albo-commercialisti/data" "$HOME/albo-commercialisti/data"                                     "Albo data"
restore_file "gitignored-critical/albo-commercialisti/.env" "$HOME/albo-commercialisti/.env"                                     "Albo .env"
restore_file "birthday-manager/events.db"                 "$HOME/birthday-manager-ts/\$HOME/.local/share/birthday-manager/events.db" "Birthday events"
restore_dir  "pta-ledger"                                 "$HOME/pta-ledger/ledger"                                              "PTA ledger"

# Config dirs (gogcli is backed up from ~/.config but lives outside repos)
restore_dir  "gogcli"                                     "$HOME/.config/gogcli"                                                 "gogcli credentials"

echo ""
echo "Data: $RESTORED restored, $SKIP_RESTORE skipped"

echo ""
echo "═══ Restore complete ═══"
```

**Step 2: Make executable**

Run: `chmod +x scripts/restore-machine.sh`

**Step 3: Test script syntax**

Run: `bash -n scripts/restore-machine.sh`
Expected: no output (clean parse)

**Step 4: Commit**

```bash
git add scripts/restore-machine.sh
git commit -m "feat: add restore-machine.sh for repo cloning + gitignored data restore"
```

---

### Task 2: Update `backup-sync.nix` to sync MACHINE_RESTORE.md to Drive

**Files:**
- Modify: `modules/home-manager/cloud-storage/backup-sync.nix:83` (before `log "Backup sync complete"`)

**Step 1: Add sync line**

After line 82 (`sync_dir "$HOME/pta-ledger/ledger" "pta-ledger" "PTA ledger"`), add:

```nix
    # Restore guide — top-level in backups/ so it's visible on bootstrap
    sync_file "$HOME/nixos-config/docs/guides/MACHINE_RESTORE.md" "MACHINE_RESTORE.md" "Restore guide"
```

Note: this uses `$BASE` which is per-host, but we want top-level. Need to add a
direct `rclone copyto` call instead:

```bash
    # Restore guide — top-level in backups/ (not per-host)
    if [ -f "$HOME/nixos-config/docs/guides/MACHINE_RESTORE.md" ]; then
      rclone copyto "$HOME/nixos-config/docs/guides/MACHINE_RESTORE.md" \
        "gdrive:backups/MACHINE_RESTORE.md" --quiet 2>>"$LOG" && \
        log "Restore guide: synced" || log "Restore guide: FAILED"
    fi
```

**Step 2: Validate nix syntax**

Run: `nix flake check` (from repo root)
Expected: no errors

**Step 3: Commit**

```bash
git add modules/home-manager/cloud-storage/backup-sync.nix
git commit -m "feat: sync MACHINE_RESTORE.md to Drive backup root"
```

---

### Task 3: Update MACHINE_RESTORE.md with new step

**Files:**
- Modify: `docs/guides/MACHINE_RESTORE.md:112-113` (after Step 3, before Step 4)

**Step 1: Insert Step 3.5**

After the Step 3 section (line 112), insert:

```markdown
## Step 3.5: Clone repos and restore project data

After NixOS is rebuilt and you've logged in:

```bash
cd ~/nixos-config

# Clone all GitHub repos + restore gitignored data (databases, .env files)
./scripts/restore-machine.sh <source-hostname>

# Example:
./scripts/restore-machine.sh thinkpad-x1-jacopo
```

This clones all repos from GitHub that aren't already present in `~/`, then
restores gitignored project data (databases, credentials) from the Drive backup
into the correct repo directories.

Requires: `gh auth login` completed, rclone configured (Steps 1-2).
```

**Step 2: Update backup structure diagram**

Add to the backup structure section (around line 30):

```markdown
    ├── whatsapp-db/             # WhatsApp message archive
    ├── bimby-nutritionist/      # Bimby recipes database
    ├── yuka-db/                 # Yuka food/cosmetics DB
    ├── gitignored-critical/     # Albo data, .env files
    ├── birthday-manager/        # Birthday events database
    ├── pta-ledger/              # PTA financial ledger
```

And at the top level:

```markdown
backups/
├── MACHINE_RESTORE.md          # This guide (auto-synced)
└── thinkpad-x1-jacopo/         # (or framework-16, biz-003, etc.)
```

**Step 3: Renumber steps**

Rename Step 4 → Step 5, Step 5 → Step 6 (or keep as "Step 4" and "Step 5" with 3.5 inserted).

**Step 4: Commit**

```bash
git add docs/guides/MACHINE_RESTORE.md
git commit -m "docs: add repo clone + data restore step to MACHINE_RESTORE.md"
```
