{ pkgs, lib, config, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    # Core development tools
    nodejs_20
    git
    gh

    # Modern Python setup with uv (2025 standard)
    uv
    python313

    # Git hooks and security tools
    gitleaks
    python3Packages.commitizen
    python3Packages.black
    ruff

    # Enhanced quality gates (2025 AI code quality)
    semgrep              # Advanced security patterns

    # Documentation quality (Week 1)
    nodePackages.markdownlint-cli2  # Markdown linting
    nodePackages.typedoc            # TypeScript documentation
    python313Packages.interrogate   # Python docstring coverage

    # Naming conventions (Week 1)
    ls-lint                         # File/folder naming enforcement

    # Note: lizard and jscpd available system-wide via NixOS configuration
    # Add project-specific packages here
  ];
}
