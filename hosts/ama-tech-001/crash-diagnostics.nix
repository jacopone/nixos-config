# Crash diagnostics for spontaneous reboot investigation.
#
# Context: as of 2026-04-30, this host has experienced 5+ unclean shutdowns
# over ~3 weeks (Apr 12, 20, 21, 22, 24, 30) with no kernel-side root cause
# visible in journalctl. Pattern: hard resets across multiple kernel versions
# (6.18.21 → .24), filesystems unclean on next boot, no pstore captures.
# Suspected: silent firmware-level reset on Strix Point SoC or Framework EC.
#
# This module makes the *next* crash leave more evidence:
#   1. Forces kernel oopses to become full panics so pstore captures them.
#   2. Adds a 15s panic delay so logs flush before auto-reboot.
#   3. Snapshots Framework EC console + prior-boot kernel log to disk on
#      every boot, so post-mortem data isn't lost to journald rotation.
#
# DELETE THIS FILE once the root cause is confirmed and a fix is in place.
{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [
    # Convert kernel oopses into full panics — forces pstore write before
    # reboot. Without this, an oops can leave a wounded kernel limping
    # along until something worse happens, and the original failure never
    # gets captured.
    "oops=panic"

    # Wait 15s before auto-reboot on panic. Default panic= action is 0
    # (immediate reboot). 15s gives the kernel time to fully flush
    # pstore and console output before firmware takes over.
    "panic=15"

    # OPTIONAL — uncomment for more aggressive capture. See contribution
    # request in conversation: panic_on_warn turns *every* kernel WARN()
    # into a panic, increasing captures but also raising the chance that
    # benign warnings cause real reboots. Conservative default is to omit.
    # "panic_on_warn=1"
  ];

  # Snapshot Framework EC console + prior-boot kernel log on every boot.
  # The Framework EC keeps its own console log, separate from the Linux
  # kernel ringbuffer. If a future crash is EC-triggered (e.g., the EC
  # decided to reset the SoC due to an internal fault), the EC console
  # is the only place that fault will be recorded.
  systemd.services.crash-diagnostics-snapshot = {
    description = "Capture EC console + prior-boot kernel log";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      OUTDIR=/var/log/crash-diagnostics
      ${pkgs.coreutils}/bin/mkdir -p "$OUTDIR"
      TS=$(${pkgs.coreutils}/bin/date -u +%Y%m%d-%H%M%S)
      OUT="$OUTDIR/$TS.log"
      {
        echo "=== boot_id ==="
        ${pkgs.coreutils}/bin/cat /proc/sys/kernel/random/boot_id || true
        echo ""
        echo "=== kernel cmdline ==="
        ${pkgs.coreutils}/bin/cat /proc/cmdline || true
        echo ""
        echo "=== uname / running kernel ==="
        ${pkgs.coreutils}/bin/uname -a || true
        echo ""
        echo "=== Framework EC console (cros_ec, if exposed via debugfs) ==="
        if [ -e /sys/kernel/debug/cros_ec/console_log ]; then
          ${pkgs.coreutils}/bin/cat /sys/kernel/debug/cros_ec/console_log || true
        else
          echo "(cros_ec console_log not exposed; debugfs may not be mounted)"
        fi
        echo ""
        echo "=== pstore directory listing (panic captures, if any) ==="
        ${pkgs.coreutils}/bin/ls -la /sys/fs/pstore/ 2>&1 || true
        echo ""
        echo "=== Previous boot kernel ringbuffer (tail 300 lines) ==="
        ${pkgs.systemd}/bin/journalctl -k -b -1 --no-pager 2>/dev/null \
          | ${pkgs.coreutils}/bin/tail -300 || true
        echo ""
        echo "=== Previous boot last 50 journal lines (any source) ==="
        ${pkgs.systemd}/bin/journalctl -b -1 --no-pager 2>/dev/null \
          | ${pkgs.coreutils}/bin/tail -50 || true
      } > "$OUT" 2>&1
      ${pkgs.coreutils}/bin/chmod 0644 "$OUT"
    '';
  };

  # Auto-prune snapshots older than 90 days. Each snapshot is small
  # (~50KB), but unbounded growth is sloppy.
  systemd.tmpfiles.rules = [
    "d /var/log/crash-diagnostics 0755 root root 90d -"
  ];
}
