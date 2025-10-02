{ pkgs, lib, config, inputs, ... }:

{
  # Import quality modules from the ai-quality-devenv template
  imports = [
    ./templates/ai-quality-devenv/modules/packages.nix
    # Temporarily disable git-hooks due to nix-store availability issue in devenv
    # ./templates/ai-quality-devenv/modules/git-hooks.nix
  ];

  # Environment variables
  env = {
    GREET = "NixOS Configuration Repository";
    PROJECT_ROOT = "$DEVENV_ROOT";
  };

  # Disable dotenv hint
  dotenv.disableHint = true;

  # Additional packages for NixOS config development
  packages = with pkgs; [
    # Nix development
    nixpkgs-fmt
    nil

    # CLAUDE.md automation dependencies (keep existing)
    uv
    python313
    python313Packages.pip
    python313Packages.jinja2
    python313Packages.pydantic
    python313Packages.pytest
  ];

  # Languages configuration
  languages = {
    nix.enable = true;

    python = {
      enable = true;
      # Disable uv.sync because nixos-config root doesn't have pyproject.toml
      # UV is still available for scripts/claude-automation which has its own devenv
      uv.enable = false;
    };
  };

  # Project-specific scripts
  scripts = {
    hello.exec = ''
      echo "🏗️  NixOS Configuration Repository"
      echo "Using ai-quality-devenv template for quality gates"
      echo ""
      echo "Quality tools enabled:"
      echo "  ✅ Gitleaks (secret detection)"
      echo "  ✅ Semgrep (security patterns)"
      echo "  ✅ Commitizen (conventional commits)"
      echo "  ✅ Markdownlint (documentation quality)"
      echo "  ✅ ls-lint (naming conventions)"
      echo ""
      echo "📋 Run 'quality-report' to see current status"
    '';

    # Assess codebase quality
    assess-quality.exec = ''
      echo "📊 Assessing nixos-config codebase quality..."
      echo ""
      echo "Repository statistics:"
      tokei --sort lines
      echo ""
      echo "Security scan:"
      gitleaks detect --source . --report-path /tmp/gitleaks-report.json || true
      echo ""
      echo "Markdown files:"
      fd -e md -x echo "{}"
    '';

    # Quick rebuild wrapper
    rebuild.exec = ''
      ./rebuild-nixos
    '';
  };

  enterShell = ''
    # Set up Python environment for CLAUDE.md automation
    export PYTHONPATH="$DEVENV_PROFILE/lib/python3.13/site-packages:$PYTHONPATH"

    hello
  '';
}
