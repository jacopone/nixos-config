# Language Server Protocol servers for Claude Code LSP plugins
# Tech profile only — provides go-to-definition, find-refs, and real-time diagnostics
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # TypeScript/JavaScript/TSX/JSX — account-harmony, digital-invoice-to-pdf
    typescript-language-server

    # Python — automation scripts, scrapers, experiments
    pyright

    # Nix — nixos-config flakes, modules, overlays
    nil

    # JSON + HTML + CSS (3-in-1 from VS Code) — i18n files, config, frontend
    vscode-langservers-extracted

    # YAML — GitHub Actions workflows, docker-compose, CI configs
    yaml-language-server

    # Bash/Shell — scripts, CI
    bash-language-server
  ];
}
