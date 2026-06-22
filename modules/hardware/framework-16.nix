# Framework Laptop 16 — extras beyond nixos-hardware
# AMD Ryzen AI 9 HX 370 + optional NVIDIA RTX 5070 Expansion Bay
#
# Base hardware support (AMD GPU params, fingerprint, PPD, QMK, fwupd, PRIME
# offload if applicable, Blackwell open modules) comes from the matching
# nixos-hardware module, chosen in flake.nix based on enableDGPU.
# This file adds shared Framework 16 tuning plus NVIDIA bits gated on enableDGPU.
{ config, pkgs, lib, inputs, enableDGPU ? false, ... }:

{
  # Disable nixos-hardware's amd_pstate module — it sets amd_pstate=active for
  # kernel >= 6.3, but having both active and passive on the cmdline corrupts
  # CPPC initialization on Strix Point (CPU locks at 605 MHz).
  disabledModules = [ "${inputs.nixos-hardware}/common/cpu/amd/pstate.nix" ];

  # Re-add the microcode update that pstate.nix's parent (default.nix) provides,
  # since disabling pstate.nix also removes its import of default.nix.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # uvcvideo: the Laptop Webcam Module (2nd Gen, 32ac:001c) is a class-compliant
  # UVC device, but udev coldplug auto-load of uvcvideo is unreliable on the
  # internal-hub topology — the device, driver, and all deps (videodev, mc,
  # videobuf2-*) are present, yet the module is sometimes never loaded, leaving
  # no /dev/video* so every app reports "no camera". Load it explicitly.
  boot.kernelModules = [ "uinput" "uvcvideo" ];

  # Blacklist ucsi_acpi — the UCSI driver fires error 256 on every boot, resume,
  # and random EC PD renegotiation, causing DP alt-mode link drops and display
  # flickers. The Framework EC handles all USB-C PD autonomously; the UCSI driver
  # is a read-only status reporter that causes more harm than value.
  # Only loss: /sys/class/typec/ entries disappear (no OS visibility into PD state).
  boot.blacklistedKernelModules = [ "ucsi_acpi" ];

  boot.kernelParams = lib.mkMerge [
    ([
      # Guided mode: OS sets min/max bounds, firmware picks optimal frequency.
      # Passive/active modes fail on Strix Point — firmware ignores CPPC requests.
      # Guided cooperates with the firmware's autonomous frequency control.
      "amd_pstate=guided"
      # Disable CWSR on iGPU — kernel 6.18/6.19 CWSR bug causes MES ring
      # saturation and GPU reset loops on Strix Point under compute workloads.
      # No downside for display-only iGPU usage.
      "amdgpu.cwsr_enable=0"
      # Force NVMe to stay at full PCIe link speed (prevents Gen 3 fallback)
      "pcie_aspm=off"
    ] ++ lib.optionals enableDGPU [
      # NVIDIA VRAM preservation across suspend/resume
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      # Explicitly disable NVIDIA dynamic power management (RTD3).
      # Open kernel modules (565+) default to 0x03 (fine-grained) on laptops,
      # which causes UCSI link drops on the USB-C DP alt-mode path.
      # Must be set explicitly — finegrained=false alone just removes NixOS's
      # override, letting the driver pick an even more aggressive default.
      "nvidia.NVreg_DynamicPowerManagement=0x00"
    ])
    # Override nixos-hardware/framework/16-inch/amd-ai-300-series/default.nix
    # (which sets amdgpu.dcdebugmask=0x410). Both definitions appear on the
    # kernel cmdline; amdgpu's module_param uint parsing is last-wins, so the
    # mkAfter value below is what the kernel actually uses.
    #
    # Bit reference — drivers/gpu/drm/amd/include/amd_shared.h @ kernel v6.18:
    #   0x10    DC_DISABLE_PSR            disables PSR v1 AND PSR-SU (per docstring)
    #   0x400   DC_DISABLE_REPLAY         what nixos-hardware's 0x410 actually sets
    #   0x800   DC_DISABLE_IPS            IPS off always (incl. suspend)
    #   0x1000  DC_DISABLE_IPS_DYNAMIC    IPS off at runtime, allowed in suspend
    #   0x2000  DC_DISABLE_IPS2_DYNAMIC   only deeper IPS2 stage off, IPS1 allowed
    #   0x4000  DC_FORCE_IPS_ENABLE       the actual force-IPS bit
    #
    # Symptom on this host: silent horizontal-band flicker on the BOE
    # NE160QDM-NZ6 eDP panel. No kernel events when it fires (rules out GPU
    # faults and DP encoder timeouts), which points to a panel-side power-state
    # transition. PSR/PSR-SU is already disabled by 0x10, so the remaining
    # suspect is IPS state-transition glitches on DCN 3.5.
    #
    (lib.mkAfter [
      # WHY: 0x2010 (IPS2-only disable) is sufficient on kernel ≥6.18.31 — the
      # amdgpu DC backend fix that makes IPS1 transitions glitch-free landed in
      # 6.18.27-6.18.31, and the kernel now tracks main nixpkgs (6.18.35+).
      # 0x10 (DC_DISABLE_PSR) + 0x2000 (DC_DISABLE_IPS2_DYNAMIC): PSR off and only
      # the deeper IPS2 runtime stage disabled; IPS1 stays on.
      #
      # We briefly ran 0x1010 (disable runtime IPS entirely) from 2026-05-22 to
      # 2026-06-17, while the kernel was pinned back to 6.18.20 for the MT7925 BT
      # regression and thus lacked that DC fix. Pin lifted → 0x2010 correct again.
      #
      # Escalation path if the BOE NE160QDM-NZ6 panel flickers again (silent
      # horizontal-band flicker, multiple times per 10 min): 0x1010 (runtime IPS
      # off), then 0x810 (DC_DISABLE_IPS, off even in suspend — more battery cost).
      "amdgpu.dcdebugmask=0x2010"
    ])
  ];

  # Override NixOS's nvidia-drm.fbdev=1 (unconditionally set by nixos/modules/
  # hardware/video/nvidia.nix when modesetting + driver >= 545). With PRIME
  # offload the AMD iGPU owns all displays; the NVIDIA fbdev is redundant and
  # can cause DRM contention during VT switches and suspend/resume.
  # Must use modprobe options — kernel cmdline param is silently overridden
  # because NixOS appends fbdev=1 AFTER our params (last-wins).
  boot.extraModprobeConfig = lib.optionalString enableDGPU ''
    options nvidia-drm fbdev=0
  '';

  # Kernel series: 6.18 LTS, not 6.19 — 6.19 has critical amdgpu regressions on
  # Strix Point. 6.18 also includes AMD HFI for proper heterogeneous Zen 5/5c
  # core scheduling. Tracks main nixpkgs (6.18.35+).
  #
  # HISTORY: pinned to 6.18.20 via a dedicated `nixpkgs-kernel` flake input from
  # 2026-05-22 to 2026-06-17 to dodge the MT7925 Bluetooth regression — mainline
  # commit 634a4408 ("btmtk: validate WMT event SKB length before struct access",
  # 2026-05-06), backported into 6.18.27..6.18.31, rejected the MT7925 FUNC_CTRL
  # event as too short → `wmt func ctrl (-22)`, BlueZ saw no adapter. Fixed by the
  # follow-up e3ac0d9f ("btmtk: accept too short WMT FUNC_CTRL events",
  # 2026-05-14), verified present in 6.18.35 (FUNC_CTRL handler now sets
  # BTMTK_WMT_ON_UNDONE for the short event instead of -EINVAL). Pin lifted.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  services.udev.extraRules = lib.mkMerge [
    # uinput for Wayland input automation
    ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    ''
    # Disable keyboard/trackpad USB wake (prevents backpack wake)
    ''
      SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"
    ''
    # Disable USB autosuspend on the MT7925 Bluetooth controller (0e8d:0717).
    # The MT7925 firmware handles USB remote wakeup poorly — the controller
    # becomes unresponsive during Bluetooth audio streaming, causing A2DP
    # transport failures ("Failure in Bluetooth audio transport").
    # Default is autosuspend=2s with control=auto, which is far too aggressive.
    ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0e8d", ATTRS{idProduct}=="0717", ATTR{power/autosuspend}="-1"
    ''
    # Disable USB autosuspend on the Goodix fingerprint sensor (27c6:609c).
    # The Goodix firmware's USB runtime PM is flaky: it auto-suspends after 2s
    # idle and fails to wake cleanly, causing repeated xhci resets ("usb 3-4.1:
    # reset full-speed USB device") that correlate with cros-ec LPC channel
    # overflow ("cros-ec-dev: Some logs may have been dropped"). Observed in
    # every boot regardless of whether fprintd is active. Default is
    # autosuspend=2s with control=auto, which is far too aggressive.
    ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="609c", ATTR{power/autosuspend}="-1"
    ''
    # Auto-switch power profile on AC plug/unplug via systemd service trigger
    ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}="set-power-profile-ac.service"
    ''
  ];

  # NVIDIA tuning (driver, modesetting, offload, open modules handled by nixos-hardware)
  hardware.nvidia = lib.mkIf enableDGPU {
    package = config.boot.kernelPackages.nvidiaPackages.production;
    modesetting.enable = true; # Required for Wayland
    # RTD3 fine-grained PM disabled — causes UCSI link drops on the rear USB-C
    # expansion bay DP alt-mode path, leading to external monitor disconnects.
    # The GPU power-state transitions disturb the EC's UCSI layer (error 256),
    # which cascades into display hotplug storms and amdgpu DP encoder timeouts.
    powerManagement.finegrained = false;
    nvidiaPersistenced = true; # Keep GPU initialized for nvidia-smi/nvtop
    nvidiaSettings = true;
  };

  # Vulkan + VA-API support for AMD iGPU (plus NVIDIA dGPU when present)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/gaming compatibility
    extraPackages = with pkgs; [
      libva
      vulkan-loader
      vulkan-validation-layers
    ] ++ lib.optionals enableDGPU [
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  # Disable GNOME idle suspend — PIXA3854 touchpad kernel bug discards valid
  # touches as "touch jumps", triggering false idle detection.
  # Lid close still suspends normally (HandleLidSwitch = "suspend").
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
  '';

  # Double suspend workaround (systemd v258+)
  # On resume, block sleep for 15s so the system doesn't immediately re-suspend.
  # Uses Type=simple with exec so systemd-inhibit acquires the lock immediately
  # (within ms of service start) — the previous oneshot+sleep-1 approach left a
  # 1-second window where the second suspend could fire before the lock existed.
  systemd.services.inhibit-sleep-after-resume = {
    description = "Temporary sleep inhibitor after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig.Type = "simple";
    script = ''
      exec ${pkgs.systemd}/bin/systemd-inhibit \
        --mode=block \
        --what=sleep:idle \
        --who="inhibit-sleep-after-resume" \
        --why="Prevent immediate re-suspend after resume" \
        ${pkgs.coreutils}/bin/sleep 15
    '';
  };

  # Fix CPU frequency after resume — cycle PPD profile to force EC to
  # re-evaluate TDP limits (CPPC registers can corrupt during shallow suspend).
  systemd.services.fix-cpu-freq-after-resume = {
    description = "Reset CPU frequency scaling after resume";
    after = [ "post-resume.target" ];
    wantedBy = [ "post-resume.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
      ${pkgs.coreutils}/bin/sleep 1
      if [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      fi
    '';
  };

  # Detect the EC-level CPU clamp that fix-cpu-freq-after-resume CANNOT fix.
  # The Strix Point EC can wedge every core at lowest_perf (~600 MHz) in a state
  # that survives a warm reboot and ignores every OS lever — PPD cycle, amd_pstate
  # re-init, scaling_min_freq override all bounce off it (confirmed 2026-06-14).
  # Only a physical EC power-drain recovers it. We can neither prevent it (BIOS
  # 03.06 is already the latest firmware) nor fix it in software, so this detector
  # RECOGNISES it and tells the user how to recover — turning a multi-hour "why is
  # Chrome slow" misdiagnosis into a 90-second drain. Runs as a user service so
  # notify-send reaches the GNOME session; it probes only when no core is already
  # boosting, so it never adds load to a busy machine. See the auto-memory note
  # framework-16-power.md ("EC-level clamp — survives a warm reboot").
  systemd.user.services.detect-cpu-clamp = {
    description = "Detect EC-level CPU frequency clamp; warn to power-drain";
    serviceConfig.Type = "oneshot";
    script = ''
      set -u
      THRESH=1200000   # 1.2 GHz: far above the 605 MHz floor, far below any real boost

      # Peg cpu0 for ~200ms and echo its frequency (kHz). A healthy core jumps to
      # multiple GHz; a clamped one stays ~600 MHz.
      probe() {
        ${pkgs.util-linux}/bin/taskset -c 0 \
          ${pkgs.coreutils}/bin/timeout 0.3 sh -c 'while :; do :; done' >/dev/null 2>&1 &
        ${pkgs.coreutils}/bin/sleep 0.2
        cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 0
        wait 2>/dev/null || true
      }

      # Cheap pre-check: if any core is already boosting we're clearly not clamped.
      # Skip the active probe (don't load an already-busy machine).
      maxf=0
      for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        v=$(cat "$f" 2>/dev/null || echo 0)
        [ "$v" -gt "$maxf" ] && maxf=$v
      done
      [ "$maxf" -gt 1500000 ] && exit 0

      # All cores low (idle OR clamped) — an active probe tells them apart.
      p1=$(probe)
      [ "''${p1:-0}" -gt "$THRESH" ] && exit 0

      # Clamped. Try the cheap remedy first (rescues the mild post-suspend variant).
      echo "detect-cpu-clamp: cpu0 stuck at ''${p1} kHz under load — trying PPD cycle"
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver || true
      ${pkgs.coreutils}/bin/sleep 1
      if [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance || true
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced || true
      fi
      ${pkgs.coreutils}/bin/sleep 2
      p2=$(probe)
      if [ "''${p2:-0}" -gt "$THRESH" ]; then
        echo "detect-cpu-clamp: recovered via PPD cycle (mild variant)"
        exit 0
      fi

      # Still clamped after the cheap fix → severe EC wedge. Warn the user, but
      # debounce to once per 30 min so we don't nag.
      stamp="''${XDG_RUNTIME_DIR:-/tmp}/cpu-clamp-warned"
      if [ -z "$(${pkgs.findutils}/bin/find "$stamp" -mmin -30 2>/dev/null)" ]; then
        ${pkgs.coreutils}/bin/touch "$stamp"
        echo "detect-cpu-clamp: SEVERE EC clamp (cpu0 ''${p2} kHz) — OS cannot fix, power-drain required"
        ${pkgs.libnotify}/bin/notify-send -u critical \
          "CPU stuck at 600 MHz — EC wedged" \
          "Software can't fix this. Recover: shut down, unplug AC + all USB-C, hold power 60s, then boot." || true
      fi
    '';
  };

  systemd.user.timers.detect-cpu-clamp = {
    description = "Periodically probe for the EC-level CPU clamp";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "5min";
    };
  };

  # Restart NetworkManager after resume — shallow suspends on Strix Point can
  # cause wpa_supplicant to fully deinit (nl80211 teardown) instead of pausing,
  # leaving WiFi dead after resume. Restarting NM re-initializes the stack.
  systemd.services.fix-wifi-after-resume = {
    description = "Restart NetworkManager after resume";
    after = [ "post-resume.target" ];
    wantedBy = [ "post-resume.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/sleep 3
      ${pkgs.systemd}/bin/systemctl restart NetworkManager
    '';
  };

  # Display recovery watchdog — Framework 16 with NVIDIA expansion bay GPU
  # experiences intermittent display drops from multiple triggers:
  # 1. UCSI error 256 (EC USB-C PD policy conflict) → DP alt-mode link drop
  # 2. amdgpu enc1_stream_encoder_dp_blank timeout during display reconfiguration
  # 3. Unknown triggers (possibly NVIDIA RTD3 or DRM hotplug race conditions)
  #
  # All paths produce the same amdgpu DP encoder timeout, after which Mutter
  # loses logical monitor state and may leave the external monitor dark.
  #
  # This watchdog monitors the kernel log for the amdgpu DP encoder timeout
  # (the common signal across all trigger paths), waits for the reconfiguration
  # storm to settle, then forces Mutter to re-initialize all displays via VT
  # switch (release + reclaim DRM master, re-read monitors.xml).
  # The user sees a ~1s flash to a text console, then displays restore correctly.
  systemd.services.display-recovery-watchdog = {
    description = "Recover display after amdgpu DP encoder timeout";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
    script = ''
      ${pkgs.systemd}/bin/journalctl -kf --no-pager \
        | ${pkgs.gnugrep}/bin/grep --line-buffered 'stream_encoder_dp_blank' \
        | while read -r line; do
          echo "amdgpu DP encoder timeout detected, waiting 5s for storm to settle..."
          ${pkgs.coreutils}/bin/sleep 5
          echo "Forcing Mutter display re-initialization via VT switch"
          ${pkgs.kbd}/bin/chvt 3
          ${pkgs.coreutils}/bin/sleep 1
          ${pkgs.kbd}/bin/chvt 2
          echo "Display recovery complete, debouncing 60s"
          ${pkgs.coreutils}/bin/sleep 60
        done
    '';
  };

  # Battery charge limit — preserve battery health when mostly plugged in.
  # 80% ≈ 2-3x cycle life vs 100%. Reapplied after boot and resume because
  # the EC resets the threshold on power state changes.
  systemd.services.battery-charge-limit = {
    description = "Set battery charge limit to 80%";
    after = [ "multi-user.target" "post-resume.target" ];
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ -f /sys/class/power_supply/BAT1/charge_control_end_threshold ]; then
        echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold
      fi
    '';
  };

  # Set power profile when AC state changes (triggered by udev).
  systemd.services.set-power-profile-ac = {
    description = "Set power profile based on AC state";
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/sleep 1
      if [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
      fi
    '';
  };

  # Set power profile at boot based on AC state.
  # Uses graphical.target to avoid ordering cycle with PPD via multi-user.target.
  systemd.services.power-profile-boot = {
    description = "Set power profile based on AC state at boot";
    wantedBy = [ "graphical.target" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/sleep 2
      if [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      fi
    '';
  };

  # VA-API driver for AMD iGPU hardware video decode (used by Chrome, Firefox)
  environment.variables.LIBVA_DRIVER_NAME = "radeonsi";

  # LED Matrix input modules
  hardware.inputmodule.enable = true;

  # Framework-specific packages
  environment.systemPackages = with pkgs; [
    framework-tool
    powertop
  ] ++ lib.optionals enableDGPU [
    nvtopPackages.nvidia
  ];

  # Build settings for 12-core AMD / 64GB RAM
  nix.settings = {
    cores = 8;
    max-jobs = 4;
  };

  zramSwap.memoryPercent = lib.mkForce 15; # ~10GB compressed swap
}
