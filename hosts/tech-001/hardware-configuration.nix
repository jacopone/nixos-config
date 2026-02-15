# PLACEHOLDER - Regenerate this file on the Framework 16 laptop
# Run: sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# This file will be automatically generated during NixOS installation
# It contains machine-specific hardware detection results

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # PLACEHOLDER VALUES - Will be replaced by nixos-generate-config
  boot.initrd.availableKernelModules = [
    "nvme"           # WD_BLACK SN7100 NVMe
    "xhci_pci"       # USB 3.x/4.x
    "thunderbolt"    # Thunderbolt/USB4
    "usbhid"         # USB HID devices
    "sd_mod"         # SD card reader (if present)
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];  # AMD Ryzen AI 9 HX 370
  boot.extraModulePackages = [ ];

  # Filesystem mounts - PLACEHOLDER
  # Update with actual UUIDs after installation
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
    fsType = "ext4";  # or "btrfs" if you prefer
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  # Network interface (AMD RZ717 WiFi 7)
  networking.useDHCP = lib.mkDefault true;

  # AMD Ryzen AI 9 HX 370 (12-core)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
