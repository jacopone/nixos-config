{ pkgs, lib, config, inputs, ... }:

{
  # ============================================================================
  # AI Quality DevEnv Template - Modular Configuration
  # ============================================================================
  #
  # This devenv provides enterprise-grade quality gates for AI-assisted development
  # with Claude Code, Cursor AI, and other AI coding tools.
  #
  # Architecture:
  # - modules/   → Core functionality (languages, packages, git-hooks, scripts)
  # - profiles/  → Optional feature sets (legacy-rescue, minimal)
  # - scripts/   → Executable shell scripts (29 tools)
  #
  # Documentation: See docs/devenv-architecture.md
  # ============================================================================

  imports = [
    ./modules/languages.nix
    ./modules/packages.nix
    ./modules/scripts.nix
    ./modules/git-hooks.nix
  ];

  # Basic environment configuration
  env = {
    GREET = "AI Quality DevEnv Template";
    # Add project-specific environment variables here
  };

  # Fix dotenv integration warning
  dotenv.disableHint = true;

  # Optional: Enable processes
  # https://devenv.sh/processes/
  processes = {
    # frontend.exec = "npm run dev";
  };

  # Optional: Enable services
  # https://devenv.sh/services/
  services = {
    # postgres = {
    #   enable = true;
    #   package = pkgs.postgresql_15;
    #   initialDatabases = [
    #     { name = "myproject_dev"; }
    #   ];
    # };
  };

  # Shell initialization
  enterShell = ''
    hello
  '';
}
