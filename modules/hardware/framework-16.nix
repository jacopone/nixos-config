# Framework Laptop 16 — extras beyond nixos-hardware
# AMD Ryzen AI 9 HX 370 + NVIDIA RTX 5070 Expansion Bay
#
# Base hardware support (AMD GPU params, fingerprint, PPD, QMK, fwupd,
# PRIME offload, Blackwell open modules) comes from:
#   nixos-hardware.nixosModules.framework-16-amd-ai-300-series-nvidia
# imported in flake.nix. This file adds NVIDIA tuning, workarounds, and extras.
{ config, pkgs, lib, inputs, ... }:

{
  # Disable nixos-hardware's amd_pstate module — it sets amd_pstate=active for
  # kernel >= 6.3, but having both active and passive on the cmdline corrupts
  # CPPC initialization on Strix Point (CPU locks at 605 MHz).
  disabledModules = [ "${inputs.nixos-hardware}/common/cpu/amd/pstate.nix" ];

  # Re-add the microcode update that pstate.nix's parent (default.nix) provides,
  # since disabling pstate.nix also removes its import of default.nix.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = [ "uinput" ];

  boot.kernelParams = [
    # NVIDIA VRAM preservation across suspend/resume
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
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
  ];

  # Use default kernel (6.18 LTS) instead of latest (6.19) — 6.19 has critical
  # amdgpu regressions on Strix Point. 6.18 includes AMD HFI for proper
  # heterogeneous Zen 5/5c core scheduling.
  # boot.kernelPackages = pkgs.linuxPackages_latest;  # Uncomment to return to bleeding edge

  services.udev.extraRules = lib.mkMerge [
    # uinput for Wayland input automation
    ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    ''
    # Disable keyboard/trackpad USB wake (prevents backpack wake)
    ''
      SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"
    ''
    # Auto-switch power profile on AC plug/unplug via systemd service trigger
    ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}="set-power-profile-ac.service"
    ''
  ];

  # NVIDIA tuning (driver, modesetting, offload, open modules handled by nixos-hardware)
  hardware.nvidia = {
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

  # Vulkan + VA-API support for AMD iGPU and NVIDIA dGPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/gaming compatibility
    extraPackages = with pkgs; [
      libva
      vulkan-loader
      vulkan-validation-layers
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
  # On resume, block sleep for 10s so the system doesn't immediately re-suspend.
  # Waits 1s for the suspend operation to fully complete before taking the inhibit
  # lock — without this, systemd-inhibit fails with "already running".
  systemd.services.inhibit-sleep-after-resume = {
    description = "Temporary sleep inhibitor after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/sleep 1
      ${pkgs.systemd}/bin/systemd-inhibit \
        --mode=block \
        --what=sleep:idle \
        --who="inhibit-sleep-after-resume" \
        --why="Prevent immediate re-suspend after resume" \
        ${pkgs.coreutils}/bin/sleep 10 || true
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
    nvtopPackages.nvidia
    powertop
  ];

  # Build settings for 12-core AMD / 64GB RAM
  nix.settings = {
    cores = 8;
    max-jobs = 4;
  };

  zramSwap.memoryPercent = lib.mkForce 15; # ~10GB compressed swap
}
