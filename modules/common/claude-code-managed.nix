# Managed Claude Code settings — org-wide policies injected at /etc.
# Unlike ~/.claude/CLAUDE.md (home-manager symlink), values placed here cannot
# be excluded or overridden by users. Loaded by Claude Code at startup.
#
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G15
{ pkgs, ... }:

let
  companyPolicies = builtins.readFile ../home-manager/claude-code/company-policies.md;
  managedSettings = {
    claudeMd = companyPolicies;
    # strictKnownMarketplaces and blockedMarketplaces expect arrays of
    # source-pattern objects like [{ hostPattern = "^github\\.com$"; }
    # { source = "skills-dir"; }], NOT booleans. Configuring them correctly
    # is a separate task — see follow-up #20.
  };
in
{
  environment.etc."claude-code/managed-settings.json".source =
    pkgs.writeText "claude-code-managed-settings.json"
      (builtins.toJSON managedSettings);
}
