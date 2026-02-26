# Home Manager base configuration
# This file imports all modular configurations
{ config, pkgs, ... }:

let
  claude-seccomp = import ../../pkgs/claude-seccomp.nix { inherit pkgs; };
in
{
  # Import all modular configurations
  imports = [
    ./shell/fish.nix # Fish shell with smart commands
    ./terminal/kitty.nix # Kitty terminal emulator
    ./terminal/ghostty.nix # Ghostty terminal emulator (trial)
    ./terminal/starship.nix # Starship prompt
    ./file-management/yazi.nix # Yazi file manager
    ./development/tools.nix # Development tools (git, direnv, atuin, broot)
    ./cloud-storage/rclone.nix # Google Drive mount via rclone
    ./cloud-storage/backup-sync.nix # Periodic backup to Google Drive
    ./desktop/gnome.nix # GNOME desktop (Dash to Dock)
    # NOTE: mcps.nix removed - requires pkgs.mcp-servers which isn't in nixpkgs yet
    # Using manual .mcp.json instead (already configured with MCP-NixOS + Playwright)
  ];

  # Home Manager state version
  home.stateVersion = "24.05";

  # Environment variables for Claude Code
  home.sessionVariables = {
    CLAUDE_CODE_MAX_OUTPUT_TOKENS = "64000";
  };

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

  # Claude Code seccomp filter - deployed to ~/.claude/seccomp/ for native sandbox
  # Settings.json references these paths via sandbox.seccomp.bpfPath and applyPath
  home.file.".claude/seccomp/apply-seccomp".source = "${claude-seccomp}/share/claude-seccomp/apply-seccomp";
  home.file.".claude/seccomp/unix-block.bpf".source = "${claude-seccomp}/share/claude-seccomp/unix-block.bpf";
  # Also deploy to npm global fallback path so Claude Code's /sandbox UI check finds them
  # (the UI check runs before sandbox config is loaded from settings.json)
  home.file.".npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64/apply-seccomp".source = "${claude-seccomp}/share/claude-seccomp/apply-seccomp";
  home.file.".npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64/unix-block.bpf".source = "${claude-seccomp}/share/claude-seccomp/unix-block.bpf";

  # Enable bash for compatibility
  programs.bash.enable = true;

  # Smart Office Open - desktop application for Google Drive files
  # Opens Google native files (0 byte) in browser, regular files with OnlyOffice
  xdg.desktopEntries.smart-office-open = {
    name = "Smart Office Open";
    comment = "Opens Google Drive files in browser, others with OnlyOffice";
    exec = "smart-office-open %f";
    terminal = false;
    type = "Application";
    categories = [ "Office" ];
    mimeType = [
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/x-zerosize"
    ];
  };

  # Set smart-office-open as default handler for office files
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "smart-office-open.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "smart-office-open.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "smart-office-open.desktop";
      "application/msword" = "smart-office-open.desktop";
      "application/vnd.ms-excel" = "smart-office-open.desktop";
      "application/vnd.ms-powerpoint" = "smart-office-open.desktop";
      "application/x-zerosize" = "smart-office-open.desktop";
    };
  };
}
