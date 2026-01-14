# ThinkPad X1 Carbon host configuration
# Intel UHD 620 + 8-core Intel CPU
{ config, pkgs, inputs, username, lib, ... }:

{
  imports = [
    # Hardware scan result
    ./hardware-configuration.nix
    # Shared configuration
    ../common
    # ThinkPad hardware optimizations
    ../../modules/hardware/thinkpad.nix
  ];

  # Hostname (keeping "nixos" for backward compatibility with existing system)
  # You can rename this to "thinkpad-x1" if desired
  networking.hostName = "nixos";

  # State version - DO NOT CHANGE (set at initial installation)
  system.stateVersion = "24.05";
}
