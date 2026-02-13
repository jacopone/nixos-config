# Shared packages — included by BOTH tech and business profiles
# Add packages here that every company workstation needs.
# Profile-specific tools go in core/packages.nix (tech) or business/packages.nix (business).
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # AI Assistant
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # Claude Code

    # Editors
    vscode-fhs # Visual Studio Code in FHS environment

    # Version control
    git
    gh

    # Browser
    google-chrome

    # Office suite
    onlyoffice-desktopeditors

    # Essential CLI (context-aware shell commands need these)
    fish
    eza # Modern ls
    fd # Modern find
    bat # Modern cat with syntax highlighting
    ripgrep # Modern grep (rg)
    fzf # Fuzzy finder
    jq # JSON processor
    glow # Markdown renderer
    pandoc # Universal document converter
    wget

    # Core development runtimes
    nodejs_20
    gcc
    gnumake
    pkg-config

    # Development infrastructure
    docker-compose
    direnv
    devenv
    cachix

    # Shell enhancements
    starship # Cross-shell prompt
    zoxide # Smart cd
    delta # Better git diffs
    tmux # Terminal multiplexer

    # Nix tooling
    shellcheck # Shell script linter
    shfmt # Shell formatter
    nixpkgs-fmt # Nix formatter
    nvd # NixOS version diff (for rebuild-nixos)
    nix-output-monitor # Build visualization (nom)

    # Remote support (TeamViewer-like, connects via ID + password)
    rustdesk-flutter

    # System utilities
    p7zip
    wl-clipboard # Wayland clipboard (wl-copy, wl-paste)
    gedit # Simple text editor

    # Fonts
    dejavu_fonts
    roboto
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];
}
