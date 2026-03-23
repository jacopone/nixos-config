# ADE upstream monitor — checks for ADE control module and package updates
# Runs twice daily (10:00, 16:00) and 5 minutes after boot
# Alerts are written to ~/amatino/amatino-f24-compilazione/logs/
{ config, pkgs, lib, ... }:

let
  project-root = "${config.home.homeDirectory}/amatino/amatino-f24-compilazione";
  monitor-script = "${project-root}/scripts/ade_monitor_cron.sh";
in
{
  systemd.user.services.ade-monitor = {
    Unit = {
      Description = "ADE control module and upstream package monitor";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${monitor-script}";
      # Exit 1 = new modules/packages detected (alert, not failure)
      SuccessExitStatus = "0 1";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.ade-monitor = {
    Unit = {
      Description = "Run ADE monitor twice daily and on boot";
    };

    Timer = {
      OnBootSec = "5min";
      OnCalendar = "*-*-* 10,16:00:00";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
