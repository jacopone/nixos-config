# Periodic backup of local configs to Google Drive via rclone
# Syncs critical user data every 30 minutes
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

  # Timer: run every 30 minutes, with randomized delay to avoid thundering herd
  systemd.user.timers.backup-configs = {
    Unit = {
      Description = "Periodic backup of configs to Google Drive";
    };

    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
      RandomizedDelaySec = "5min";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
