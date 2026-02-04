# Rclone Google Drive mount configuration
# Mounts Google Drive to ~/GoogleDrive automatically at login
{ config, pkgs, ... }:

{
  # Systemd user service for rclone mount
  # Note: mount point is created by ExecStartPre, not home.file (can't write to FUSE mount)
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Mount Google Drive with rclone";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "notify";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/GoogleDrive";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount gdrive: %h/GoogleDrive \
          --allow-non-empty \
          --vfs-cache-mode full \
          --vfs-cache-max-age 72h \
          --vfs-read-chunk-size 64M \
          --vfs-read-chunk-size-limit 512M \
          --buffer-size 64M \
          --dir-cache-time 72h \
          --poll-interval 15s \
          --drive-export-formats "docx,xlsx,pptx,pdf" \
          --log-level INFO \
          --log-file %h/.local/share/rclone/gdrive.log
      '';
      ExecStop = "/run/wrappers/bin/fusermount -u %h/GoogleDrive";
      Restart = "on-failure";
      RestartSec = "10s";
      Environment = [ "PATH=/run/wrappers/bin:${pkgs.fuse}/bin:$PATH" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Create log directory
  home.file.".local/share/rclone/.keep".text = "";
}
