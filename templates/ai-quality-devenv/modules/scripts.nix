{ pkgs, lib, config, ... }:

{
  # https://devenv.sh/scripts/
  # All scripts are now in scripts/ directory for better maintainability

  scripts = {
    # Core quality tools
    hello.exec = "bash scripts/hello.sh";
    quality-check.exec = "bash scripts/quality-check.sh";
    quality-report.exec = "bash scripts/quality-report.sh";
    quality-dashboard.exec = "bash scripts/quality-dashboard.sh";

    # Git hooks setup
    setup-git-hooks.exec = "bash scripts/setup-git-hooks.sh";

    # AI tools initialization
    init-ai-tools.exec = "bash scripts/init-ai-tools.sh";
    setup-cursor.exec = "bash scripts/setup-cursor.sh";
    setup-claude.exec = "bash scripts/setup-claude.sh";

    # Assessment & analysis
    assess-codebase.exec = "bash scripts/assess-codebase.sh";
    assess-documentation.exec = "bash scripts/assess-documentation.sh";
    analyze-folder-structure.exec = "bash scripts/analyze-folder-structure.sh";
    check-naming-conventions.exec = "bash scripts/check-naming-conventions.sh";

    # Remediation planning & execution
    generate-remediation-plan.exec = "bash scripts/generate-remediation-plan.sh";
    initialize-remediation-state.exec = "bash scripts/initialize-remediation-state.sh";
    autonomous-remediation-session.exec = "bash scripts/autonomous-remediation-session.sh";

    # Remediation support
    update-remediation-state.exec = "bash scripts/update-remediation-state.sh";
    identify-next-targets.exec = "bash scripts/identify-next-targets.sh";
    validate-target-improved.exec = "bash scripts/validate-target-improved.sh";
    checkpoint-progress.exec = "bash scripts/checkpoint-progress.sh";
    needs-human-checkpoint.exec = "bash scripts/needs-human-checkpoint.sh";
    mark-checkpoint-approved.exec = "bash scripts/mark-checkpoint-approved.sh";
    rollback-to-checkpoint.exec = "bash scripts/rollback-to-checkpoint.sh";

    # Quality gates & certification
    check-feature-readiness.exec = "bash scripts/check-feature-readiness.sh";
    certify-feature-ready.exec = "bash scripts/certify-feature-ready.sh";
    quality-regression-check.exec = "bash scripts/quality-regression-check.sh";

    # Advanced analysis
    estimate-token-usage.exec = "bash scripts/estimate-token-usage.sh";
    analyze-failure-patterns.exec = "bash scripts/analyze-failure-patterns.sh";
    generate-progress-report.exec = "bash scripts/generate-progress-report.sh";
    parallel-remediation-coordinator.exec = "bash scripts/parallel-remediation-coordinator.sh";
  };
}
