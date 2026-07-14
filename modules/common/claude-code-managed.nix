# Managed Claude Code settings — org-wide policies injected at /etc.
# Values placed here cannot be excluded or overridden by users (the managed
# layer wins). The company policy text is delivered ONLY here (claudeMd key);
# there is deliberately no ~/.claude/CLAUDE.md copy — a user-deletable file
# would defeat the managed authority model (see home-manager/claude-code/default.nix).
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
    #
    # Follow-up: move sandbox.enabled/failIfUnavailable HERE for hard
    # enforcement — today they are only re-asserted into user settings by
    # claude-settings-merge, so a manual opt-out survives until the next
    # rebuild. Before moving them, verify managed<->user merge granularity
    # for the `sandbox` object: the per-user seccomp applyPath
    # ($HOME-dependent) lives in user settings and must survive the overlay.
  };
in
{
  environment.etc."claude-code/managed-settings.json".source =
    pkgs.writeText "claude-code-managed-settings.json"
      (builtins.toJSON managedSettings);
}
