# HP workstation for Pietro
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
  ];

  environment.variables.EDITOR = "code"; # VS Code (not Helix)

  # gstack (Claude Code skill pack) — host-scoped: only Pietro uses gstack here
  environment.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "Pietro";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "changeme"; # Safety net — Pietro should change this after first login
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "ama-biz-001";

  system.stateVersion = "24.11";
}
