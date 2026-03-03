# Framework Laptop 16 — extras beyond nixos-hardware
# AMD Ryzen AI 9 HX 370 + NVIDIA RTX 5070 Expansion Bay
#
# Base hardware support (AMD GPU params, fingerprint, PPD, QMK, fwupd,
# PRIME offload, Blackwell open modules) comes from:
#   nixos-hardware.nixosModules.framework-16-amd-ai-300-series-nvidia
# imported in flake.nix. This file adds NVIDIA tuning, workarounds, and extras.
{ config, pkgs, lib, ... }:

{
  boot.kernelModules = [ "uinput" ];

  boot.kernelParams = [
    # NVIDIA VRAM preservation across suspend/resume
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    # Override nixos-hardware's amd_pstate=active. Active mode CPPC is broken on
    # Strix Point / kernel 6.19: EPP hints ignored, CPU locks at 605 MHz.
    "amd_pstate=passive"
    # Force NVMe to stay at full PCIe link speed (prevents Gen 3 fallback)
    "pcie_aspm=off"
  ];

  # Always use latest kernel (nixos-hardware only sets this conditionally for < 6.15)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.udev.extraRules = lib.mkMerge [
    # uinput for Wayland input automation
    ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    ''
    # Disable keyboard/trackpad USB wake (prevents backpack wake)
    ''
      SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"
    ''
    # Auto-switch power profile: performance on AC, power-saver on battery
    ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", ACTION=="change", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
    ''
    ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", ACTION=="change", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    ''
  ];

  # NVIDIA tuning (driver, modesetting, offload, open modules handled by nixos-hardware)
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.production;
    modesetting.enable = true; # Required for Wayland
    powerManagement.finegrained = true; # RTD3 dynamic power management (Turing+)
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

  # Fix CPU frequency stuck at base clock after resume.
  # Cycle PPD profiles to force EC to re-evaluate TDP limits, then set governor
  # to performance on AC (passive mode needs explicit governor, unlike active mode).
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
      # In passive mode, explicitly set governor after PPD profile change
      for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ]; then
          echo performance > "$gov" 2>/dev/null || true
        else
          echo schedutil > "$gov" 2>/dev/null || true
        fi
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

  # Set performance profile + governor at boot.
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
        echo performance | ${pkgs.coreutils}/bin/tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
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
