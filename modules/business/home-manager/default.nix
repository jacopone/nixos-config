# Business profile Home Manager entry point
# Reuses ghostty, starship, and dev tools from tech profile; adds simplified fish
# No yazi, rclone, command-tracking, idea/bug functions, or smart-office-open
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home-manager/claude-code # Company-wide Claude Code commands, sandbox, permissions
    ./fish.nix # Simplified fish (business-specific)
    ../../home-manager/terminal/ghostty.nix # Ghostty terminal (shared)
    ../../home-manager/terminal/starship.nix # Starship prompt (shared)
    ../../home-manager/development/tools.nix # direnv, git, delta, atuin, broot (shared)
    ../../home-manager/desktop/gnome.nix # GNOME desktop (Dash to Dock)
    ../../home-manager/cloud-storage/rclone.nix # Google Drive mount via rclone
    ../../home-manager/desktop/smart-office-open.nix # Default handler for office files
  ];

  # Business-specific git workflow (extends company CLAUDE.md via rules, not mkForce)
  home.file.".claude/rules/business-workflow.md".source = ./business-workflow.md;

  home.stateVersion = "24.05";

  programs.bash.enable = true;
}
