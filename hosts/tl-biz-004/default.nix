# MacBook Air 7,2 (Early 2015, Intel i5) — business workstation
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
    ../../modules/hardware/macbook-air-7.nix
  ];

  environment.variables.EDITOR = "code"; # VS Code (not Helix)

  users.users.${username} = {
    isNormalUser = true;
    description = "Business User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "changeme";
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "tl-biz-004";

  system.stateVersion = "25.11";
}
