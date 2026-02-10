# Business profile packages — curated set for office workers learning to code
# ~40 packages vs ~350+ in tech profile. Focused on: Office, Chrome, VS Code, Claude Code.
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors & AI
    vscode-fhs # Visual Studio Code in FHS environment
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # Claude Code

    # Version control
    git
    gh

    # Browser
    google-chrome

    # Office suite
    onlyoffice-desktopeditors

    # Essential CLI tools (context-aware commands need these)
    fish
    eza # Modern ls (used by smart ls/ll/la)
    fd # Modern find
    bat # Modern cat with syntax highlighting
    ripgrep # Modern grep (rg)
    fzf # Fuzzy finder
    jq # JSON processor
    glow # Markdown renderer
    pandoc # Document converter
    wget
    less

    # Core development runtimes (for learning to code)
    nodejs_20
    (python3.withPackages (ps: with ps; [
      pytest
      pydantic
      jinja2
    ]))
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
