{ pkgs, ... }:
{
  # Minimal devenv for BASB system testing/development
  # Runtime has NO Python dependencies - uses system tools (httpie, curl, gum)
  # This environment is ONLY for testing, linting, and type checking

  packages = with pkgs; [
    # Python runtime
    python311

    # Testing (minimal - just pytest)
    python311Packages.pytest
    python311Packages.pytest-mock

    # Linting & Formatting
    python311Packages.ruff
    # Note: black, mypy, pytest-cov excluded due to tkinter/GUI dependency issues
  ];

  env.PYTHONPATH = "${toString ./.}/src";

  enterShell = ''
    echo "🧪 BASB Development Environment"
    echo "   Python: $(python --version)"
    echo "   Pytest: $(pytest --version | head -1)"
    echo ""
    echo "Commands:"
    echo "  pytest tests/           - Run all tests"
    echo "  pytest tests/unit/      - Run unit tests only"
    echo "  ruff check src/         - Lint code"
    echo ""
  '';
}
