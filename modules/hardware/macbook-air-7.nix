# MacBook Air 7,2 (Early 2015) hardware configuration
# Intel Broadwell i5-5350U, 8GB RAM, Broadcom BCM4360 WiFi
# Complements nixos-hardware.nixosModules.apple-macbook-air-7
{ config, pkgs, lib, ... }:

{
  # Zen kernel: fixes Broadcom wl driver initialization race
  # (default kernel requires manual `modprobe -r wl && modprobe wl` after boot)
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Apple keyboard mapping
  boot.kernelModules = [ "hid_apple" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
    options hid_apple swap_opt_cmd=1
  '';

  # Intel HD Graphics 6000 (Broadwell)
  environment.variables.LIBVA_DRIVER_NAME = "iHD";
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Intel thermal management (single-fan MacBook Air)
  services.thermald.enable = true;

  # Lid switch behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
  };

  # Diagnostic tools for hardware debugging
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    lm_sensors
  ];

  # Power management via TLP
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };
  services.power-profiles-daemon.enable = false;

  # Memory management for 8GB RAM
  zramSwap.memoryPercent = lib.mkForce 50;
  boot.kernel.sysctl."vm.swappiness" = lib.mkForce 60;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4096;
  }];

  # Nix build settings for dual-core i5 with 8GB RAM
  nix.settings = {
    cores = 2;
    max-jobs = 1;
  };
}
