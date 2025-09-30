{ pkgs, lib, config, inputs, ... }:

{
  # Environment variables
  env = {
    GREET = "CLAUDE.md Automation System";
    CLAUDE_AUTOMATION_ROOT = "$DEVENV_ROOT";
    PYTHONPATH = "$DEVENV_PROFILE/lib/python3.13/site-packages";
  };

  # Fix dotenv integration warning
  dotenv.disableHint = true;

  # Packages for CLAUDE.md automation
  packages = with pkgs; [
    # Modern Python setup with uv (2025 standard)
    uv
    python313
    python313Packages.pip
    python313Packages.jinja2
    python313Packages.pydantic
    python313Packages.pytest
    # Code quality tools
    python313Packages.black
    ruff
    # Git tools
    git
  ];

  # Languages configuration following account harmony pattern
  languages.python = {
    enable = true;
    uv.enable = true;
    uv.sync.enable = true;
  };

  # Scripts for automation
  scripts = {
    hello.exec = ''
      echo "🤖 Welcome to CLAUDE.md Automation System!"
      echo "Python: $(python --version)"
      echo "uv: $(uv --version)"
      echo "Git: $(git --version)"
      echo ""
      echo "🔧 Available Tools:"
      echo "   - Template-based CLAUDE.md generation"
      echo "   - Robust Nix configuration parsing"
      echo "   - Automatic content validation"
      echo "   - Modern dependency management with uv"
    '';

    update-system-claude.exec = ''
      echo "🔍 Updating system-level CLAUDE.md..."
      python update-system-claude-v2.py
    '';

    update-project-claude.exec = ''
      echo "📋 Updating project-level CLAUDE.md..."
      python update-project-claude-v2.py
    '';

    update-claude-configs.exec = ''
      echo "🔄 Updating both CLAUDE.md configurations..."
      python update-system-claude-v2.py
      python update-project-claude-v2.py
      echo "✅ All CLAUDE.md configurations updated!"
    '';

    test-automation.exec = ''
      echo "🧪 Running CLAUDE.md automation tests..."
      uv run python -m pytest tests/ -v
    '';

    validate-claude-files.exec = ''
      echo "🔍 Validating existing CLAUDE.md files..."
      uv run python -c "
from claude_automation.validators.content_validator import ContentValidator
from pathlib import Path

validator = ContentValidator()

# Validate system file
system_file = Path.home() / '.claude' / 'CLAUDE.md'
if system_file.exists():
    result = validator.validate_file(system_file, 'system')
    print('System CLAUDE.md validation:')
    print(validator.generate_validation_report(result))
else:
    print('System CLAUDE.md not found')

print()

# Validate project file
project_file = Path('../CLAUDE.md')
if project_file.exists():
    result = validator.validate_file(project_file, 'project')
    print('Project CLAUDE.md validation:')
    print(validator.generate_validation_report(result))
else:
    print('Project CLAUDE.md not found')
      "
    '';

    setup-claude-automation.exec = ''
      echo "🚀 Setting up CLAUDE.md automation environment..."

      # Initialize Python project with uv if pyproject.toml doesn't exist
      if [ ! -f pyproject.toml ]; then
        echo "Initializing Python project with uv..."
        uv init --no-readme --python 3.13
      fi

      # Install required packages with uv
      echo "Installing automation packages with uv..."
      uv add jinja2 pydantic pytest

      echo "✅ CLAUDE.md automation environment ready!"
      echo "📋 Available commands:"
      echo "   update-system-claude    # Update ~/.claude/CLAUDE.md (v2)"
      echo "   update-project-claude   # Update ./CLAUDE.md (v2)"
      echo "   update-claude-configs   # Update both files (v2)"
      echo "   validate-claude-files   # Validate existing files"
      echo "   test-automation         # Run test suite"
    '';
  };

  # Pre-commit hooks for code quality
  git-hooks.hooks = {
    # Python formatting and linting
    black = {
      enable = true;
      files = "\\.py$";
      excludes = [ ".devenv/" "result" ];
    };

    ruff = {
      enable = true;
      files = "\\.py$";
      excludes = [ ".devenv/" "result" ];
    };
  };

  enterShell = ''
    # Set up Python environment
    export PYTHONPATH="$DEVENV_PROFILE/lib/python3.13/site-packages:$PYTHONPATH"
    export PATH="$DEVENV_PROFILE/bin:$PATH"

    # Test dependencies
    echo "🔧 Testing Python dependencies..."
    if python -c "import jinja2, pydantic" 2>/dev/null; then
      echo "✅ Jinja2 and Pydantic loaded successfully"
    else
      echo "⚠️  Dependencies not found, but continuing..."
    fi

    hello
  '';
}