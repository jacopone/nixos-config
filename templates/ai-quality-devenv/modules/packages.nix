{ pkgs, lib, config, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    # Development tools
    nodejs_20
    git
    gh

    # Python environment with uv package manager
    uv
    python313

    # Git hooks and security
    gitleaks
    commitizen-go           # Go implementation (avoids Python version dependency issues)
    black
    ruff

    # Static analysis
    semgrep                 # Pattern-based security and code quality scanning

    # Documentation tooling
    nodePackages.markdownlint-cli2  # Markdown linting
    nodePackages.jsdoc              # JavaScript API documentation
    python313Packages.sphinx        # Python documentation generator

    # Optional: Install per-project via npm/uv if needed
    # - TypeDoc (TypeScript):  npm install -D typedoc
    # - Interrogate (Python):  uv add --dev interrogate

    # File and folder naming validation
    ls-lint

    # Note: lizard and jscpd available system-wide via NixOS configuration
    # Add project-specific packages here
  ];
}
