# ODCEC studio-website recovery — daily Gemini rescrape of missing studio
# websites into the local enrichment DB, with a conditional prod cluster-sync
# when new sites are found (skips the ~8-min prod-lock on no-op days).
#
# The work lives in the project repo (scripts/daily_website_recovery.sh) so
# tweaks don't need a nixos rebuild; this unit just schedules it and supplies
# PATH. devenv (system pkg) provides the python venv, cloud-sql-proxy and psql;
# gcloud/nix are system pkgs, git is in the user profile.
#
# Scheduled at 10:00 local — after the Gemini free-tier grounding quota
# (1,500/day) resets at midnight Pacific (~09:00 Europe/Rome).
{ config, pkgs, lib, ... }:

let
  project-root = "${config.home.homeDirectory}/amatino/amatino-crm";
  recovery-script = "${project-root}/scripts/daily_website_recovery.sh";
in
{
  systemd.user.services.odcec-website-recovery = {
    Unit = {
      Description = "ODCEC studio-website recovery (Gemini) + conditional prod sync";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      # devenv, gcloud and nix live in the system profile; git and other
      # per-user tools in the home-manager profile.
      Environment = [
        "PATH=/run/wrappers/bin:/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin"
      ];
      ExecStart = "${pkgs.bash}/bin/bash ${recovery-script}";
      # The batch can run ~30 min + cluster-sync ~8 min; the systemd default
      # start timeout (90s) would kill it, so allow 90 min.
      TimeoutStartSec = "5400";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.odcec-website-recovery = {
    Unit = {
      Description = "Run ODCEC website recovery daily (after Pacific quota reset)";
    };

    Timer = {
      OnCalendar = "*-*-* 10:00:00";
      # Small spread; RandomizedDelaySec only ever delays, so it stays after
      # the quota reset.
      RandomizedDelaySec = "20m";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
