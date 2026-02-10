# Framework Laptop 16 host configuration
# AMD Ryzen AI 9 HX 370 + NVIDIA RTX 5070 + 64GB DDR5-5600
{ config, pkgs, inputs, username, lib, ... }:

{
  imports = [
    # Hardware scan result (regenerate with nixos-generate-config on the machine)
    ./hardware-configuration.nix
    # Shared configuration
    ../common
    # Framework 16 hardware optimizations
    ../../modules/hardware/framework-16.nix
  ];

  # Hostname
  networking.hostName = "framework-16-jacopo";

  # NVIDIA PRIME Bus IDs
  # IMPORTANT: Update these after running on actual hardware:
  # nix-shell -p pciutils --run 'lspci | grep -E "VGA|3D"'
  # Convert hex (e.g., c1:00.0) to decimal using:
  # echo "ibase=16; C1" | bc  (gives 193)
  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:193:0:0"; # Update after lspci
    nvidiaBusId = "PCI:1:0:0"; # Update after lspci
  };

  # State version - set to NixOS version at installation time
  # Update this when you install on the Framework 16
  system.stateVersion = "24.11";
}
