# Framework Laptop 16 host configuration
# AMD Ryzen AI 9 HX 370 + 64GB DDR5-5600
# Optional: NVIDIA RTX 5070 Expansion Bay (toggle via enableDGPU in flake.nix)
{ config, pkgs, inputs, username, enableDGPU ? false, lib, ... }:

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
  networking.hostName = "ama-tech-001";

  # NVIDIA PRIME Bus IDs (from lspci: c1:00.0 = NVIDIA, c2:00.0 = AMD)
  # Only applied when the expansion bay is installed.
  hardware.nvidia.prime = lib.mkIf enableDGPU {
    amdgpuBusId = "PCI:194:0:0";
    nvidiaBusId = "PCI:193:0:0";
  };

  # State version - set to NixOS version at installation time
  # Update this when you install on the Framework 16
  system.stateVersion = "24.11";
}
