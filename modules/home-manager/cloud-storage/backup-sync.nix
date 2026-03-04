# Daily backup of local configs to Google Drive via rclone
# Syncs critical user data once per day
# Backup path: gdrive:backups/<hostname>/<config-name>/
# Matches existing backup structure from backup-thinkpad-20260211
{ config, pkgs, lib, ... }:

let
  # Script that syncs all critical configs to Google Drive
  backup-script = pkgs.writeShellScript "backup-configs-to-gdrive" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ pkgs.rclone pkgs.coreutils pkgs.findutils pkgs.gnused pkgs.hostname ]}"

    HOSTNAME="$(hostname)"
    BASE="gdrive:backups/$HOSTNAME"
    LOG="$HOME/.local/share/rclone/backup-sync.log"

    log() { echo "[$(date -Iseconds)] $*" >> "$LOG"; }

    sync_dir() {
      local src="$1" dest="$2" label="$3"
      if [ -d "$src" ]; then
        rclone sync "$src/" "$BASE/$dest/" \
          --transfers 8 --drive-chunk-size 64M --quiet 2>>"$LOG" && \
          log "$label: synced" || log "$label: FAILED"
      fi
    }

    sync_file() {
      local src="$1" dest="$2" label="$3"
      if [ -f "$src" ]; then
        rclone copyto "$src" "$BASE/$dest" \
          --quiet 2>>"$LOG" && \
          log "$label: synced" || log "$label: FAILED"
      fi
    }

    # Sync all .env* files from a project, preserving directory structure
    sync_envs() {
      local project="$1" label="$2"
      local src="$HOME/$project"
      if [ -d "$src" ]; then
        find "$src" -maxdepth 3 -name ".env*" -type f \
          ! -path "*/node_modules/*" ! -path "*/.devenv/*" ! -path "*/.git/*" \
          2>/dev/null | while IFS= read -r f; do
          local rel
          rel=$(echo "$f" | sed "s|^$HOME/||")
          rclone copyto "$f" "$BASE/gitignored-critical/$rel" \
            --quiet 2>>"$LOG"
        done
        log "$label .env files: synced"
      fi
    }

    log "Starting backup sync for $HOSTNAME"

    # Identity and auth
    sync_dir "$HOME/.ssh" "ssh" "SSH"
    sync_dir "$HOME/.config/gh" "gh" "GitHub CLI"
    sync_dir "$HOME/.gnupg" "gnupg" "GPG keys"
    sync_dir "$HOME/.config/rclone" "rclone" "rclone config"
    sync_file "$HOME/.gitconfig" "gitconfig" "Git config"

    # Claude Code (settings, permissions, memory, sessions)
    # Skip ephemeral dirs (debug, shell-snapshots, statsig) and files
    # modified in the last 5 min (active session transcripts) to avoid
    # rclone errors from files being written mid-upload.
    # Skipped files sync on the next run after the session ends.
    if [ -d "$HOME/.claude" ]; then
      rclone sync "$HOME/.claude/" "$BASE/claude/" \
        --transfers 8 --drive-chunk-size 64M --quiet \
        --exclude "debug/**" \
        --exclude "shell-snapshots/**" \
        --exclude "statsig/**" \
        --min-age 5m \
        2>>"$LOG" && \
        log "Claude Code: synced" || log "Claude Code: FAILED"
    fi

    # Shell and terminal
    sync_dir "$HOME/.local/share/atuin" "atuin" "Atuin history"
    sync_dir "$HOME/.config/fish" "fish" "Fish config"

    # Cloud and dev tools
    sync_dir "$HOME/.config/gcloud" "gcloud" "Google Cloud"

    # Desktop data
    sync_dir "$HOME/.local/share/keyrings" "keyrings" "GNOME keyrings"

    # Custom scripts
    sync_dir "$HOME/.local/bin" "local-bin" "Local scripts"

    # Project databases (irreplaceable user data)
    # WhatsApp message archive (258K+ messages)
    sync_dir "$HOME/whatsapp-mcp/whatsapp-bridge/store" "whatsapp-db" "WhatsApp DB"

    # Bimby nutritionist (10K+ recipes, meal plans, grocery data)
    sync_file "$HOME/bimby-nutritionist/data/recipes.sqlite" "bimby-nutritionist/recipes.sqlite" "Bimby recipes"

    # Yuka food/cosmetics product database
    sync_dir "$HOME/bimby-hacking/yuka/database" "yuka-db" "Yuka DB"

    # Albo commercialisti (117K+ members, leads, campaigns)
    sync_dir "$HOME/albo-commercialisti/data" "gitignored-critical/albo-commercialisti/data" "Albo data"
    sync_file "$HOME/albo-commercialisti/.env" "gitignored-critical/albo-commercialisti/.env" "Albo env"

    # Google Suite CLI credentials (gogcli)
    sync_dir "$HOME/.config/gogcli" "gogcli" "gogcli credentials"

    # Birthday manager (events DB, triage DB, auth tokens, rollback backups)
    sync_dir "$HOME/.local/share/birthday-manager" "birthday-manager" "Birthday manager"

    # Account Harmony GCP service account keys
    sync_dir "$HOME/.config/account-harmony-ai/secrets" "account-harmony-secrets" "Account Harmony secrets"

    # GNOME desktop settings (keybindings, favorites, night light, workspace config)
    sync_dir "$HOME/.config/dconf" "dconf" "GNOME dconf settings"

    # Chrome profiles (all profiles: bookmarks, passwords, cookies, settings)
    # Passwords and cookies are encrypted with GNOME Keyring (backed up above)
    CHROME_DIR="$HOME/.config/google-chrome"
    CHROME_FILES="Bookmarks Preferences Login?Data Cookies Web?Data Secure?Preferences Favicons"
    if [ -d "$CHROME_DIR" ]; then
      sync_file "$CHROME_DIR/Local State" "chrome-profiles/Local State" "Chrome Local State"
      for profile_dir in "$CHROME_DIR"/Default "$CHROME_DIR"/Profile\ *; do
        [ -d "$profile_dir" ] || continue
        profile_name="$(basename "$profile_dir")"
        # Skip backup artifacts
        case "$profile_name" in *backup*|*~) continue ;; esac
        for pattern in $CHROME_FILES; do
          # Use glob to resolve ? wildcards (e.g. Login?Data -> Login Data)
          for f in "$profile_dir"/$pattern; do
            [ -f "$f" ] || continue
            fname="$(basename "$f")"
            sync_file "$f" "chrome-profiles/$profile_name/$fname" "Chrome $profile_name/$fname"
          done
        done
        # Extension data (per profile)
        if [ -d "$profile_dir/Local Extension Settings" ]; then
          sync_dir "$profile_dir/Local Extension Settings" \
            "chrome-profiles/$profile_name/Local Extension Settings" \
            "Chrome $profile_name extensions"
        fi
      done
    fi

    # PTA ledger (financial data)
    sync_dir "$HOME/pta-ledger/ledger" "pta-ledger" "PTA ledger"

    # Non-git directories (Drive is the only backup — no GitHub repo exists)
    sync_dir "$HOME/Downloads" "Downloads" "Downloads"
    sync_dir "$HOME/Kooha" "Kooha" "Kooha recordings"
    sync_dir "$HOME/Pictures" "Pictures" "Pictures"
    sync_dir "$HOME/obsidian_brain" "obsidian_brain" "Obsidian vault"
    sync_dir "$HOME/yc-application" "yc-application" "YC application"

    # Additional project databases (gitignored, not in GitHub)
    # Paths mirror home dir structure under gitignored-critical/ for clean restore
    sync_file "$HOME/credit-finder/data/credit_finder.sqlite" "gitignored-critical/credit-finder/data/credit_finder.sqlite" "Credit Finder DB"
    sync_dir "$HOME/financial-advisor/data" "gitignored-critical/financial-advisor/data" "Financial Advisor DBs"
    sync_file "$HOME/bimby-nutritionist/data/nutritionist.db" "gitignored-critical/bimby-nutritionist/data/nutritionist.db" "Bimby nutritionist DB"
    sync_file "$HOME/bimby-nutritionist/data/bimby.db" "gitignored-critical/bimby-nutritionist/data/bimby.db" "Bimby DB"
    sync_file "$HOME/susilo/data/susilo.sqlite" "gitignored-critical/susilo/data/susilo.sqlite" "Susilo DB"

    # Project .env files (gitignored secrets, auto-discovered per project)
    sync_envs "account-harmony-ai-37599577" "Account Harmony"
    sync_envs "HealthSafe-Journal" "HealthSafe Journal"
    sync_envs "moving-agent" "Moving Agent"
    sync_envs "pediatra-digitale" "Pediatra Digitale"
    sync_envs "bimby-nutritionist" "Bimby Nutritionist"
    sync_envs "banca-piemonte-analysis" "Banca Piemonte"
    sync_envs "credit-finder" "Credit Finder"
    sync_envs "food-assistant" "Food Assistant"
    sync_envs "legis-hub" "Legis Hub"
    sync_envs "mcp-sunsama" "MCP Sunsama"
    sync_envs "mutuo-rapido-italia" "Mutuo Rapido"

    # Restore guide — top-level in backups/ (not per-host)
    if [ -f "$HOME/nixos-config/docs/guides/MACHINE_RESTORE.md" ]; then
      rclone copyto "$HOME/nixos-config/docs/guides/MACHINE_RESTORE.md" \
        "gdrive:backups/MACHINE_RESTORE.md" --quiet 2>>"$LOG" && \
        log "Restore guide: synced" || log "Restore guide: FAILED"
    fi

    log "Backup sync complete"
  '';
in
{
  # Systemd user service for periodic backup
  systemd.user.services.backup-configs = {
    Unit = {
      Description = "Backup local configs to Google Drive";
      After = [ "network-online.target" "rclone-gdrive.service" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${backup-script}";
      # Don't fail the whole timer if one sync has issues
      SuccessExitStatus = "0 1";
      # Prevent resource hogging
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  # Timer: run daily, with randomized delay to spread load
  systemd.user.timers.backup-configs = {
    Unit = {
      Description = "Daily backup of configs to Google Drive";
    };

    Timer = {
      OnBootSec = "5min";
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
