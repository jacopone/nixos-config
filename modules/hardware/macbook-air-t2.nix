# MacBook Air 2018 (8,1) hardware configuration
# Intel Core i5-8210Y, 8GB RAM, T2 security chip
# Complements nixos-hardware.nixosModules.apple-t2 (kernel patches, firmware, SSD, audio)
{ config, pkgs, lib, ... }:

{
  # Enable all firmware (including non-redistributable) for T2 Bluetooth support
  hardware.enableAllFirmware = true;

  # Load apple-bce in initrd for keyboard/trackpad/SSD access during early boot
  boot.initrd.kernelModules = [ "apple-bce" ];

  # T2 Broadcom WiFi workaround: disable problematic firmware features
  # Without this, brcmfmac causes intermittent disconnects and firmware crashes
  boot.kernelParams = [
    "brcmfmac.feature_disable=0x82000"
  ];

  # Use iwd backend for WiFi (wpa_supplicant 2.11 has a T2 Broadcom regression)
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  # Apple keyboard mapping
  # Swap Option (Alt) and Command (Super) to match standard PC layout
  # fn key behavior handled by hid_apple module
  boot.kernelModules = [ "hid_apple" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
    options hid_apple swap_opt_cmd=1
  '';

  # Intel UHD 617 graphics (same as ThinkPad UHD 620 family)
  environment.variables.LIBVA_DRIVER_NAME = "iHD";
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API for Intel UHD 617
      libva
      libva-vdpau-driver    # VDPAU via VA-API
      libvdpau-va-gl        # OpenGL-based VDPAU
    ];
  };

  # Intel thermal management (helps with single-fan MacBook Air thermals)
  services.thermald.enable = true;

  # Lid switch behavior
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
  };

  # Diagnostic tools for hardware debugging
  environment.systemPackages = with pkgs; [
    pciutils     # lspci
    usbutils     # lsusb
    lm_sensors   # sensors
  ];

  # Power management via TLP (good for MacBook battery life)
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
  # Higher zram ratio to effectively double usable memory
  zramSwap.memoryPercent = lib.mkForce 50; # ~4GB compressed → ~8GB effective
  # Raise swappiness so the kernel uses zram/swap before OOM-killing
  boot.kernel.sysctl."vm.swappiness" = lib.mkForce 60;
  # 4GB swapfile as safety net when zram fills up
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4096; # MB
  }];

  # Nix build settings for dual-core i5 with 8GB RAM
  nix.settings = {
    cores = 2;
    max-jobs = 1; # Conservative — only 8GB RAM
  };
}
