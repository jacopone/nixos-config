# Daily backup of local configs to Google Drive via rclone
# Syncs critical user data once per day
# Backup path: gdrive:backups/<hostname>/<config-name>/
# Matches existing backup structure from backup-thinkpad-20260211
{ config, pkgs, lib, ... }:

let
  # Script that syncs all critical configs to Google Drive
  backup-script = pkgs.writeShellScript "backup-configs-to-gdrive" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ pkgs.rclone pkgs.coreutils pkgs.hostname ]}"

    HOSTNAME="$(hostname)"
    BASE="gdrive:backups/$HOSTNAME"
    LOG="$HOME/.local/share/rclone/backup-sync.log"

    log() { echo "[$(date -Iseconds)] $*" >> "$LOG"; }

    sync_dir() {
      local src="$1" dest="$2" label="$3"
      if [ -d "$src" ]; then
        rclone sync "$src/" "$BASE/$dest/" \
          --transfers 2 --quiet 2>>"$LOG" && \
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

    log "Starting backup sync for $HOSTNAME"

    # Identity and auth
    sync_dir "$HOME/.ssh" "ssh" "SSH"
    sync_dir "$HOME/.config/gh" "gh" "GitHub CLI"
    sync_dir "$HOME/.gnupg" "gnupg" "GPG keys"
    sync_dir "$HOME/.config/rclone" "rclone" "rclone config"

    # Claude Code (settings, permissions, memory, sessions)
    sync_dir "$HOME/.claude" "claude" "Claude Code"

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

    # Birthday manager events database
    sync_file "$HOME/birthday-manager/\$HOME/.local/share/birthday-manager/events.db" "birthday-manager/events.db" "Birthday events"

    # PTA ledger (financial data)
    sync_dir "$HOME/pta-ledger/ledger" "pta-ledger" "PTA ledger"

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
