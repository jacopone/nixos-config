{ pkgs, lib, config, ... }:

{
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

    # Code quality checks
    complexity-check = {
      enable = true;
      name = "complexity-check";
      entry = "lizard --CCN 10 --length 50";  # Available system-wide
      files = "\\.(py|js|ts|tsx)$";
      excludes = [ ".devenv/" "node_modules/" "coverage/" "dist/" "scripts/claude-automation/" ];
    };

    jscpd = {
      enable = true;
      name = "clone-detection";
      entry = "jscpd --threshold 5 --min-lines 10";  # Available system-wide
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
    # Uses Go implementation to avoid Python version dependency issues
    commitizen-check = {
      enable = true;
      name = "commitizen-conventional-commits";
      entry = "${pkgs.commitizen-go}/bin/commitizen-go";
      stages = [ "commit-msg" ];
      pass_filenames = false;
    };

    # Documentation and structure validation
    markdownlint = {
      enable = true;
      files = "\\.md$";
      # Wrap in devenv shell to ensure tool availability when running outside devenv
      entry = "devenv shell bash -c 'markdownlint-cli2'";
      language = "system";
      excludes = [ "node_modules/" ".devenv/" "CHANGELOG.md" ".quality/" ];
    };

    ls-lint = {
      enable = true;
      name = "naming-conventions";
      # Wrap in devenv shell to ensure tool availability when running outside devenv
      entry = "devenv shell bash -c 'ls-lint'";
      language = "system";
      pass_filenames = false;
    };

    # Note: Post-commit hooks run scripts/post-commit-docs.sh manually
    # or via git hooks. Pre-commit framework doesn't support post-commit hooks natively.
    # To enable: Add to .git/hooks/post-commit (done via setup-git-hooks script)
  };
}
