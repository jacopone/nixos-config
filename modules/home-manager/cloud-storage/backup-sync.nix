# Periodic backup of local configs to Google Drive via rclone
# Syncs SSH, GH CLI, rclone config, and Claude Code data every 30 minutes
# Backup path: gdrive:backups/<hostname>/<config-name>/
{ config, pkgs, lib, ... }:

let
  hostname = config.home.sessionVariables.BACKUP_HOSTNAME or "unknown";

  # Script that syncs all critical configs to Google Drive
  backup-script = pkgs.writeShellScript "backup-configs-to-gdrive" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ pkgs.rclone pkgs.coreutils ]}"

    HOSTNAME="$(${pkgs.hostname}/bin/hostname)"
    BASE="gdrive:backups/$HOSTNAME"
    LOG="$HOME/.local/share/rclone/backup-sync.log"

    log() { echo "[$(date -Iseconds)] $*" >> "$LOG"; }

    log "Starting backup sync for $HOSTNAME"

    # SSH keys and config
    if [ -d "$HOME/.ssh" ]; then
      rclone sync "$HOME/.ssh/" "$BASE/ssh/" \
        --transfers 2 --quiet 2>>"$LOG" && \
        log "SSH: synced" || log "SSH: FAILED"
    fi

    # GitHub CLI config
    if [ -d "$HOME/.config/gh" ]; then
      rclone sync "$HOME/.config/gh/" "$BASE/gh-config/" \
        --transfers 2 --quiet 2>>"$LOG" && \
        log "GH: synced" || log "GH: FAILED"
    fi

    # rclone config (the config itself)
    if [ -d "$HOME/.config/rclone" ]; then
      rclone sync "$HOME/.config/rclone/" "$BASE/rclone-config/" \
        --transfers 2 --quiet 2>>"$LOG" && \
        log "rclone: synced" || log "rclone: FAILED"
    fi

    # Claude Code config (settings, permissions, memory, projects)
    if [ -d "$HOME/.claude" ]; then
      rclone sync "$HOME/.claude/" "$BASE/claude-config/" \
        --transfers 2 --quiet 2>>"$LOG" && \
        log "Claude: synced" || log "Claude: FAILED"
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
