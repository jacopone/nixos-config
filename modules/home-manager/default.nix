# Home Manager base configuration — tech profile
# This file imports all modular configurations
{ config, pkgs, ... }:

{
  # Import all modular configurations
  imports = [
    ./claude-code # Company-wide Claude Code policies, commands, sandbox
    ./shell/fish.nix # Fish shell with smart commands
    ./terminal/ghostty.nix # Ghostty terminal emulator
    ./terminal/starship.nix # Starship prompt
    ./file-management/yazi.nix # Yazi file manager
    ./development/tools.nix # Development tools (git, direnv, atuin, broot)
    # ./development/ade-monitor.nix # Retired: migrated to GitHub Actions (.github/workflows/monitor-ade.yml)
    ./development/lsp.nix # LSP servers for Claude Code plugins (TS, Python, Nix, JSON, YAML, Bash)
    ./cloud-storage/rclone.nix # Google Drive mount via rclone
    ./cloud-storage/backup-sync.nix # Periodic backup to Google Drive
    ./desktop/smart-office-open.nix # Default handler for office files
    # NOTE: Dash to Dock (desktop/gnome.nix) is business-only — imported in modules/business/home-manager/
    # NOTE: mcps.nix removed - requires pkgs.mcp-servers which isn't in nixpkgs yet
    # Using manual .mcp.json instead (already configured with MCP-NixOS + Playwright)
  ];

  # Home Manager state version
  home.stateVersion = "24.05";

  # Home packages (minimal - most tools are system-wide)
  home.packages = [
    # Project-specific packages go here
  ];

  # Command tracking system for tool adoption baseline study
  home.file.".config/fish/conf.d/command-tracking.fish".text = builtins.readFile ../../config/fish/conf.d/command-tracking.fish;
  home.file.".config/fish/functions/tracking-analyze.fish".text = builtins.readFile ../../config/fish/functions/tracking-analyze.fish;
  home.file.".config/fish/functions/tracking-export.fish".text = builtins.readFile ../../config/fish/functions/tracking-export.fish;

  # GitHub issue tracking functions for idea/bug capture across projects
  home.file.".config/fish/functions/idea.fish".text = builtins.readFile ../../config/fish/functions/idea.fish;
  home.file.".config/fish/functions/bug.fish".text = builtins.readFile ../../config/fish/functions/bug.fish;
  home.file.".config/fish/functions/review-ideas.fish".text = builtins.readFile ../../config/fish/functions/review-ideas.fish;
  home.file.".config/fish/functions/review-bugs.fish".text = builtins.readFile ../../config/fish/functions/review-bugs.fish;
  home.file.".config/fish/functions/spec-it.fish".text = builtins.readFile ../../config/fish/functions/spec-it.fish;
  home.file.".config/fish/functions/build-it.fish".text = builtins.readFile ../../config/fish/functions/build-it.fish;
  home.file.".config/fish/functions/fix-it.fish".text = builtins.readFile ../../config/fish/functions/fix-it.fish;
  home.file.".config/fish/functions/defer-it.fish".text = builtins.readFile ../../config/fish/functions/defer-it.fish;

  # Enable bash for compatibility
  programs.bash.enable = true;

  # XDG user directories — disable unused defaults to keep ~ clean
  # On fresh installs, GNOME creates Desktop, Documents, Music, Templates, etc.
  # We only keep Downloads and Pictures; everything else points to $HOME (disabled).
  xdg.userDirs = {
    enable = true;
    setSessionVariables = false;
    createDirectories = true;
    desktop = "$HOME";
    documents = "$HOME";
    download = "$HOME/Downloads";
    music = "$HOME";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME";
    templates = "$HOME";
    videos = "$HOME";
  };
}
