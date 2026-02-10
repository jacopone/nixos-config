# Business profile Home Manager entry point
# Reuses kitty, starship, and dev tools from tech profile; adds simplified fish
# No yazi, rclone, command-tracking, idea/bug functions, or smart-office-open
{ config, pkgs, ... }:

{
  imports = [
    ./fish.nix # Simplified fish (business-specific)
    ../../home-manager/terminal/kitty.nix # Kitty terminal (shared)
    ../../home-manager/terminal/starship.nix # Starship prompt (shared)
    ../../home-manager/development/tools.nix # direnv, git, delta, atuin, broot (shared)
  ];

  home.stateVersion = "24.05";

  programs.bash.enable = true;
}
