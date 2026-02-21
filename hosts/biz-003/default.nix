# MacBook Air 2018 (Intel i5, T2 chip) — business workstation
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
    ../../modules/hardware/macbook-air-t2.nix
    ../../overlays/apple-bcm-firmware.nix
  ];

  environment.variables.EDITOR = "code"; # VS Code (not Helix)

  users.users.${username} = {
    isNormalUser = true;
    description = "Business User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # Additional users can be added here:
  # users.users.another = {
  #   isNormalUser = true;
  #   description = "Another User";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   initialPassword = "changeme";
  # };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "biz-003";

  system.stateVersion = "25.05";
}
