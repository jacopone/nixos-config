{ pkgs, lib, config, inputs, ... }:

{
  # Quality gates configuration (no longer using template imports)
  # Git hooks configured inline below

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
    nix # Required for git-hooks installation (provides nix-store command)

    # CLAUDE.md automation dependencies (keep existing)
    uv
    python313
    python313Packages.pip
    python313Packages.jinja2
    python313Packages.pydantic
    python313Packages.pytest

    # Playwright MCP for browser automation
    playwright-mcp

    # Testing infrastructure
    bats # Bash Automated Testing System
    shellcheck # Static analysis for shell scripts
  ];

  # Languages configuration
  languages = {
    nix.enable = true;

    python = {
      enable = true;
      # Disable uv.sync because nixos-config root doesn't have pyproject.toml
      uv.enable = false;
    };
  };

  # Project-specific scripts
  scripts = {
    hello.exec = ''
      echo "🏗️  NixOS Configuration Repository"
      echo ""
      echo "Quality tools enabled:"
      echo "  ✅ Gitleaks (secret detection)"
      echo "  ✅ Semgrep (security patterns)"
      echo "  ✅ Commitizen (conventional commits)"
      echo "  ✅ Markdownlint (documentation quality)"
      echo "  ✅ Prettier (formatting)"
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

    # Testing commands
    test-bash.exec = ''
      echo "🧪 Running BATS tests..."
      bats tests/bash/
    '';

    lint-bash.exec = ''
      echo "🔍 Running shellcheck on scripts..."
      shellcheck -x rebuild-nixos scripts/*.sh
    '';

    test-all.exec = ''
      echo "🧪 Running all tests..."
      echo ""
      echo "=== Shellcheck ==="
      shellcheck -x rebuild-nixos scripts/*.sh || exit 1
      echo ""
      echo "=== BATS tests ==="
      bats tests/bash/
    '';
  };

  enterShell = ''
    # Set up Python environment for CLAUDE.md automation
    export PYTHONPATH="$DEVENV_PROFILE/lib/python3.13/site-packages:$PYTHONPATH"
  '';
}
