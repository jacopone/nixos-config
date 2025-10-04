{ pkgs, ... }:
{
  # BASB Development Environment
  # Note: Rich (Python UI library) is installed system-wide
  # This environment is for testing and linting only

  packages = with pkgs; [
    python3           # Python runtime (uses system python)
    python312Packages.ruff  # Linter
  ];

  env.PYTHONPATH = "${toString ./.}/src";

  enterShell = ''
    echo "🧪 BASB Development Environment"
    echo "   Python: $(python --version)"
    echo "   PYTHONPATH: $PYTHONPATH"
    echo ""
    echo "Note: Rich UI library is available system-wide"
    echo "      Devenv intentionally minimal to avoid tkinter build issues"
    echo ""
    echo "Commands:"
    echo "  python -c 'from readwise_basb.ui_refactored import ui' - Test UI import"
    echo "  ruff check src/         - Lint code"
    echo ""
  '';
}
