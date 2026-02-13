# Business workstation template
# Copy this directory for each new business deployment:
#   cp -r hosts/business-template hosts/acme-laptop-01
#   nixos-generate-config --show-hardware-config > hosts/acme-laptop-01/hardware-configuration.nix
#   Edit default.nix to set hostname, then add to flake.nix:
#     acme-laptop-01 = mkBusinessHost { hostname = "acme-laptop-01"; username = "jsmith"; };
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
  ];

  environment.variables.EDITOR = "code"; # VS Code (not Helix)

  users.users.${username} = {
    isNormalUser = true;
    description = "Business User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "changeme"; # Safety net — user should change after first login
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "business-workstation"; # Override per deployment

  system.stateVersion = "24.11";
}
