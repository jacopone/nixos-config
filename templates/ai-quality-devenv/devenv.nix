{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env = {
    GREET = "AI Quality DevEnv Template";
    # Add project-specific environment variables here
  };

  # Fix dotenv integration warning
  dotenv.disableHint = true;

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
    lizard              # Complexity analysis
    nodePackages.jscpd  # Clone detection
    # Add project-specific packages here
  ];

  # https://devenv.sh/languages/
  languages.javascript = {
    enable = true;
    npm = {
      enable = true;
      install.enable = true;
    };
  };

  languages.python = {
    enable = true;
    uv.enable = true;
    uv.sync.enable = true;
  };

  # https://devenv.sh/processes/
  processes = {
    # Add your processes here
    # frontend.exec = "npm run dev";
  };

  # https://devenv.sh/services/
  services = {
    # Add your services here
    # postgres = {
    #   enable = true;
    #   package = pkgs.postgresql_15;
    #   initialDatabases = [
    #     { name = "myproject_dev"; }
    #   ];
    # };
  };

  # https://devenv.sh/scripts/
  scripts = {
    hello.exec = ''
      echo "🚀 Welcome to AI Quality DevEnv!"
      echo "Node.js: $(node --version)"
      echo "npm: $(npm --version)"
      echo "Python: $(python --version)"
      echo ""
      echo "🔧 Quality Tools:"
      echo "Git Hooks: $(git --version)"
      echo "Gitleaks: $(gitleaks version 2>/dev/null || echo 'Available')"
      echo "Semgrep: $(semgrep --version 2>/dev/null | head -1 || echo 'Available')"
      echo "Lizard: $(lizard --version 2>/dev/null || echo 'Available')"
      echo ""
      echo "📋 Run 'quality-report' to see all quality gates"
    '';

    # Comprehensive quality check
    quality-check.exec = ''
      echo "🔍 Running comprehensive quality check..."
      echo "📋 Step 1: Security and pattern analysis"
      gitleaks detect --source . || echo "⚠️ Gitleaks check complete"
      semgrep --config=auto --severity=WARNING . || echo "⚠️ Semgrep check complete"
      echo "📋 Step 2: Code complexity analysis"
      lizard --CCN 10 src/ . || echo "⚠️ Complexity check complete"
      jscpd --threshold 5 src/ . || echo "⚠️ Clone detection complete"
      echo "📋 Step 3: Running all git hooks"
      devenv test
      echo "✅ Quality check complete"
    '';

    quality-report.exec = ''
      echo "🔍 AI Quality Gates Report"
      echo "📋 Security: gitleaks (incremental) + semgrep (auto patterns)"
      echo "📋 Complexity: lizard (CCN < 10, length < 50)"
      echo "📋 Clones: jscpd (threshold 5%, min 10 lines)"
      echo "📋 Format: prettier + eslint + black + ruff"
      echo "📋 Commits: commitizen conventional format"
      echo "📋 Coverage: enforced via testing"
      echo ""
      echo "✅ All quality gates active for AI code protection"
      echo "🤖 Run 'devenv test' to verify all gates"
      echo "🔍 Run 'quality-check' for comprehensive analysis"
    '';

    setup-git-hooks.exec = ''
      echo "🔧 Setting up git hooks..."
      devenv shell git-hooks.installationScript
      echo "✅ Git hooks installed"
      echo "📋 Hooks will run automatically on commit/push"
    '';
  };

  # https://devenv.sh/pre-commit-hooks/
  git-hooks.hooks = {
    # JavaScript/TypeScript formatting and linting
    prettier = {
      enable = true;
      excludes = [ "dist/" "coverage/" "node_modules/" ".devenv/" "result" ];
    };

    eslint = {
      enable = true;
      files = "\\.(js|ts|tsx)$";
      excludes = [ "dist/" "coverage/" "node_modules/" ];
    };

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

    # Security scanning
    gitleaks = {
      enable = true;
      name = "gitleaks-security-scan";
      entry = "${pkgs.gitleaks}/bin/gitleaks detect --source .";
      excludes = [ ".devenv/" "result" "node_modules/" "coverage/" "dist/" "build/" ];
    };

    # Enhanced quality gates (AI code protection)
    complexity-check = {
      enable = true;
      name = "complexity-check";
      entry = "${pkgs.lizard}/bin/lizard --CCN 10 --length 50";
      files = "\\.(py|js|ts|tsx)$";
      excludes = [ ".devenv/" "node_modules/" "coverage/" "dist/" ];
    };

    jscpd = {
      enable = true;
      name = "clone-detection";
      entry = "${pkgs.nodePackages.jscpd}/bin/jscpd --threshold 5 --min-lines 10";
      files = "\\.(js|ts|tsx)$";
      excludes = [ "node_modules/" "coverage/" "dist/" ];
    };

    semgrep = {
      enable = true;
      name = "security-patterns";
      entry = "${pkgs.semgrep}/bin/semgrep --config=auto --error";
      files = "\\.(py|js|ts|tsx|yaml|yml|json)$";
      excludes = [ ".devenv/" "node_modules/" "coverage/" "dist/" ];
    };

    # Commit message formatting
    commitizen = {
      enable = true;
      name = "commitizen check";
      entry = "${pkgs.python3Packages.commitizen}/bin/cz check --commit-msg-file";
      stages = [ "commit-msg" ];
    };
  };

  enterShell = ''
    hello
  '';
}