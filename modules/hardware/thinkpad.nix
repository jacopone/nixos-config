# ThinkPad hardware configuration
# Optimized for ThinkPad X1 Carbon with Intel UHD 620
{ config, pkgs, lib, ... }:

{
  # ThinkPad-specific kernel modules
  boot.kernelModules = [ "uinput" "thinkpad_acpi" ];

  # Intel GPU stability and power management
  boot.kernelParams = [
    "i915.enable_dc=1" # Less aggressive display power states
    "i915.enable_psr=0" # Disable Panel Self Refresh (fixes video crashes)
  ];

  # uinput for Wayland input automation
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  # Intel VA-API driver for hardware video decoding
  environment.variables.LIBVA_DRIVER_NAME = "iHD";

  # Intel GPU with VA-API hardware video acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API for Intel UHD 620 (iHD driver)
      libva # VA-API core library
      libva-vdpau-driver # VA-API to VDPAU wrapper
      libvdpau-va-gl # VDPAU backend for VA-API
    ];
  };

  # ThinkPad Power Management via TLP
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };

  # Disable power-profiles-daemon (conflicts with TLP)
  services.power-profiles-daemon.enable = false;

  # Nix build settings for 8-core Intel system
  nix.settings = {
    cores = 4; # Use half CPU cores for builds
    max-jobs = 2; # Limit parallel builds
  };
}
