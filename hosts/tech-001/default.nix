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
  networking.hostName = "tech-001";

  # NVIDIA PRIME Bus IDs (from lspci: c1:00.0 = NVIDIA, c2:00.0 = AMD)
  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:194:0:0";
    nvidiaBusId = "PCI:193:0:0";
  };

  # State version - set to NixOS version at installation time
  # Update this when you install on the Framework 16
  system.stateVersion = "24.11";
}
