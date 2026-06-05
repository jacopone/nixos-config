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
#   4. Forces native PCIe AER ownership so the BIOS-hidden correctable-error
#      stream becomes visible AND recoverable (see 2026-06-05 update below).
#   5. Runs rasdaemon to persist correctable MCA/PCIe errors to a DB, and
#      ships nvme-cli/pciutils/dmidecode so the fault can be inspected live.
#
# ── 2026-06-05 UPDATE — ROOT CAUSE IDENTIFIED ───────────────────────────────
# The 2026-06-05 19:02 hard reset decoded as FCH S5_RESET_STATUS [0x08000800]
# "uncorrected error caused a data fabric sync flood event" — an UNAMBIGUOUS
# hardware fault. (The earlier [0x00080800] CF9 code is ALSO what a normal
# `reboot` writes, so those prior "crashes" were largely clean reboots being
# misread — the only confirmed crash in the last ~12 days is this sync flood.)
#
# Matched to Framework issue tracker #41: this host's NVMe is a DRAM-less
# WD_BLACK SN7100 500GB on firmware 7615M0WD — the exact drive+firmware the
# community confirmed emits a stream of correctable PCIe AER errors (via its
# Host Memory Buffer) that the Framework BIOS hides from the OS, until one
# escalates to uncorrectable and the Infinity Fabric sync-floods the SoC.
#
# THE FIX is a user-run `fwupdmgr update` (SN7100 7615M0WD -> 7619M0WD, on
# LVFS). The kernel params + rasdaemon below VERIFY it on THIS machine: the
# NVMe AER count should fall to zero after the firmware update. Memory was
# REFUTED upstream as the cause (1->2 DIMM swap changed nothing) — do not
# chase a memtest first.
# See docs/plans/2026-05-22-strix-point-spontaneous-reboot-investigation.md
#
# DELETE THIS FILE once the firmware fix is verified (days of zero sync floods
# AND zero NVMe AER). Before deleting, consider promoting `pcie_ports=native`
# to framework-16.nix as permanent platform hardening.
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

    # Take native OS ownership of PCIe ports + AER (2026-06-05). The Framework
    # BIOS claims PCIe error handling via ACPI _OSC and never reports the
    # SN7100's correctable AER stream to the OS — which is why our
    # /sys/.../aer_dev_correctable counters read empty and the errors silently
    # accumulate until one escalates to an uncorrectable fabric sync flood.
    # `pcie_ports=native` forces the kernel's portdrv+AER driver to own the
    # ports regardless, so: (a) the correctable errors become VISIBLE in the
    # journal (confirms the SN7100 as the source on this machine), and (b) the
    # AER driver can RECOVER a correctable error gracefully instead of letting
    # it cascade. `pcie_ecrc=on` adds end-to-end CRC so TLP corruption is
    # caught at the source. Both are the community-validated diagnostic from
    # Framework issue #41. Pairs with the SN7100 firmware update (the real fix).
    "pcie_ports=native"
    "pcie_ecrc=on"
  ];

  # Persist correctable MCA/PCIe errors to a queryable DB (2026-06-05). A sync
  # flood itself bypasses every software handler (hence empty pstore/MCE/BERT),
  # but the correctable PCIe AER precursors that lead up to it ARE pollable now
  # that `pcie_ports=native` is set. rasdaemon logs them with timestamps so the
  # "correctable error rate climbs -> uncorrectable -> sync flood" timeline is
  # captured, and so we can confirm the rate drops to zero after the SN7100
  # firmware update. Query with `ras-mc-ctl --errors` / `ras-mc-ctl --summary`.
  hardware.rasdaemon.enable = true;

  # Live hardware-inspection tools for this investigation:
  #   nvme-cli  — `nvme list` / `nvme id-ctrl /dev/nvme0` to read drive model +
  #               firmware (the SN7100 7615M0WD -> 7619M0WD check) and SMART log
  #   pciutils  — `lspci -vvv` to read per-endpoint AER capability + error counts
  #   dmidecode — DIMM part numbers / trained speed, if memory ever needs ruling out
  environment.systemPackages = with pkgs; [
    nvme-cli
    pciutils
    dmidecode
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
        echo "=== AMD last-reset reason (FCH S5_RESET_STATUS, decoded by kernel) ==="
        # The mainline "x86/CPU/AMD: Print the reason for the last reset" patch
        # (present in 6.18) reads FCH::PM::S5_RESET_STATUS (0xC0) at boot and
        # decodes the PREVIOUS reset. This is the authoritative signal for what
        # ended the prior boot. Two codes seen on this host:
        #   [0x00080800] "software wrote 0x6 to 0xCF9" — AMBIGUOUS: this is also
        #     exactly what a normal `reboot` writes, so it marks CLEAN reboots
        #     too, NOT necessarily a crash. Most prior "CF9 crashes" were reboots.
        #   [0x08000800] "data fabric sync flood (uncorrected error)" — the real
        #     hardware-fault crash (FW issue #41). First captured 2026-06-05;
        #     traced to the WD SN7100 7615M0WD HMB-firmware bug. Capture every
        #     boot so the trend is visible.
        ${pkgs.systemd}/bin/journalctl -b 0 -k --no-pager 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -i "reset reason" \
          || echo "(kernel printed no reset reason this boot)"
        echo ""
        echo "=== NVMe model + firmware (sync-flood suspect: WD SN7100 7615M0WD) ==="
        # Root cause per FW issue #41 — once the firmware is updated to
        # 7619M0WD this line proves the fix is live on the running system.
        for d in /sys/class/nvme/nvme*; do
          [ -e "$d/model" ] || continue
          echo "$(${pkgs.coreutils}/bin/cat $d/model 2>/dev/null | ${pkgs.coreutils}/bin/tr -s ' ') fw=$(${pkgs.coreutils}/bin/cat $d/firmware_rev 2>/dev/null)"
        done
        echo ""
        echo "=== PCIe AER errors — previous boot (needs pcie_ports=native) ==="
        # The correctable-error stream that precedes the sync flood. Empty here
        # AFTER the firmware fix == the trigger is gone.
        ${pkgs.systemd}/bin/journalctl -k -b -1 --no-pager 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -iE "aer|corrected error|pcieport.*error" \
          | ${pkgs.coreutils}/bin/tail -40 \
          || echo "(no AER lines in previous boot)"
        echo ""
        echo "=== PCIe AER counters — current boot (nonzero only) ==="
        for f in /sys/bus/pci/devices/*/aer_dev_correctable \
                 /sys/bus/pci/devices/*/aer_dev_nonfatal \
                 /sys/bus/pci/devices/*/aer_dev_fatal; do
          [ -e "$f" ] || continue
          if ${pkgs.gnugrep}/bin/grep -qvE " 0$" "$f" 2>/dev/null; then
            echo "$f:"; ${pkgs.coreutils}/bin/cat "$f"
          fi
        done
        echo "(empty == no AER counters tripped this boot)"
        echo ""
        echo "=== Framework EC console (cros_ec, if exposed via debugfs) ==="
        # console_log is a streaming endpoint on this EC driver — plain `cat`
        # blocks indefinitely waiting for new bytes. Cap at 5s with `timeout`
        # so the snapshot service can finish and reach `active`.
        if [ -e /sys/kernel/debug/cros_ec/console_log ]; then
          ${pkgs.coreutils}/bin/timeout 5s \
            ${pkgs.coreutils}/bin/cat /sys/kernel/debug/cros_ec/console_log || \
            echo "(read aborted after 5s — streaming source, captured what was buffered)"
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
