# PLACEHOLDER — Replace with actual hardware configuration
# Generate on the MacBook Air with:
#   nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/biz-003/hardware-configuration.nix
#
# This file must define at minimum:
#   - boot.initrd.availableKernelModules
#   - boot.kernelModules
#   - fileSystems."/"
#   - hardware.cpu.intel.updateMicrocode
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" ];
  boot.kernelModules = [ "kvm-intel" ];

  # REPLACE: Set your actual root filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # REPLACE: Set your actual boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
}
