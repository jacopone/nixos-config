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

  # NVIDIA-specific kernel parameters (AMD params handled by nixos-hardware)
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserve VRAM across suspend/resume
    "nvidia.NVreg_TemporaryFilePath=/var/tmp" # Temp storage for VRAM save/restore
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
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
  '';

  # Double suspend workaround (systemd v258+)
  # Block sleep for 10s after resume to prevent immediate re-suspend.
  systemd.services.inhibit-sleep-after-resume = {
    description = "Temporary sleep inhibitor after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.systemd}/bin/systemd-inhibit \
        --mode=block \
        --what=sleep:idle \
        --who="inhibit-sleep-after-resume" \
        --why="Prevent immediate re-suspend after resume" \
        ${pkgs.coreutils}/bin/sleep 10 || true
    '';
  };

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
