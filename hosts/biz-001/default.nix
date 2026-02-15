# ThinkPad X1 Carbon business workstation
# Intel UHD 620 + 8-core Intel CPU
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
    ../../modules/hardware/thinkpad.nix
  ];

  environment.variables.EDITOR = "code"; # VS Code (not Helix)

  users.users.${username} = {
    isNormalUser = true;
    description = "Business User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "biz-001";

  system.stateVersion = "24.11";
}
