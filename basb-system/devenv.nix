{ pkgs, ... }:
{
  # BASB Development Environment
  # Note: Rich is available from system Python (installed in packages.nix)
  # This keeps devenv minimal and avoids tkinter/pytest-cov build issues

  packages = with pkgs; [
    python3 # System Python (already has rich from packages.nix)
    python312Packages.ruff # Linter
  ];

  env.PYTHONPATH = "${toString ./.}/src";

  enterShell = ''
    echo "🧪 BASB Development Environment"
    echo "   Python: $(python --version)"
    echo "   PYTHONPATH: $PYTHONPATH"
    echo "   Rich UI: $(python -c 'import rich; print(rich.__version__)' 2>/dev/null || echo '⚠️  Not available - run ./rebuild-nixos')"
    echo ""
    echo "Commands:"
    echo "  ./scripts/readwise-basb chrome - Launch Chrome bookmarks UI"
    echo "  python -c 'from readwise_basb.ui_refactored import ui' - Test UI import"
    echo "  ruff check src/         - Lint code"
    echo ""
  '';
}
