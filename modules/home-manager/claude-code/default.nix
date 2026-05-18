# Shared Claude Code configuration — company-wide policies, commands, and sandbox
# Immutable files (CLAUDE.md, commands, seccomp): Nix store symlinks, auto-updated on rebuild.
# Mutable files (settings.json): merged on rebuild — company baseline + user additions preserved.
{ config, lib, pkgs, ... }:

let
  claude-seccomp = import ../../../pkgs/claude-seccomp.nix { inherit pkgs; };
  companyConfig = ./company-config.json;
in
{
  # Company policies are deployed via modules/common/claude-code-managed.nix
  # as /etc/claude-code/managed-settings.json (the claudeMd managed setting).
  # A ~/.claude/CLAUDE.md home.file symlink would duplicate the same content
  # and could be deleted by a user, defeating the "managed" authority model.
  # See docs/plans/2026-05-18-claude-code-advancements-audit.md §G15.

  # Shared slash commands (personal commands like /life stay as regular files alongside these)
  home.file.".claude/commands/nixos.md".source = ./commands/nixos.md;

  # Custom subagents — symlinked to ~/.claude/agents/ from the Nix store
  home.file.".claude/agents/flake-debugger.md".source = ./agents/flake-debugger.md;
  home.file.".claude/agents/package-finder.md".source = ./agents/package-finder.md;
  home.file.".claude/agents/generation-differ.md".source = ./agents/generation-differ.md;
  home.file.".claude/agents/supply-chain-auditor.md".source = ./agents/supply-chain-auditor.md;

  # Statusline script — deployed to a stable per-user path so settings.json
  # can reference it by absolute path. Marked executable so Claude Code can
  # run it directly (it's spawned, not sourced).
  home.file.".config/claude-code/statusline.sh" = {
    source = ./statusline.sh;
    executable = true;
  };

  # Seccomp sandbox filter for Claude Code native sandbox
  home.file.".claude/seccomp/apply-seccomp".source = "${claude-seccomp}/share/claude-seccomp/apply-seccomp";
  home.file.".claude/seccomp/unix-block.bpf".source = "${claude-seccomp}/share/claude-seccomp/unix-block.bpf";
  # npm global fallback path (Claude Code UI check looks here before loading settings)
  home.file.".npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64/apply-seccomp".source = "${claude-seccomp}/share/claude-seccomp/apply-seccomp";
  home.file.".npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64/unix-block.bpf".source = "${claude-seccomp}/share/claude-seccomp/unix-block.bpf";

  # Claude Code environment
  home.sessionVariables = {
    CLAUDE_CODE_MAX_OUTPUT_TOKENS = "64000";
    CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };

  # Merge company config into settings.json on every rebuild.
  # - Permissions: union (company baseline always present, user additions preserved)
  # - Plugins: company defaults, user overrides win (if Pietro disables one, his false wins)
  # - Sandbox: schema-migrated and re-asserted on every merge (idempotent)
  # - statusLine: overwritten on every merge to point at the deployed script
  # - Other settings: untouched (hooks, env, etc. stay user-managed)
  home.activation.claude-settings-merge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS="$HOME/.claude/settings.json"
    COMPANY="${companyConfig}"

    $DRY_RUN_CMD mkdir -p "$HOME/.claude"

    if [ ! -f "$SETTINGS" ]; then
      # First setup: create settings with company config + sandbox paths
      # Note: effort level and adaptive-thinking flags are managed via
      # home.sessionVariables (CLAUDE_CODE_EFFORT_LEVEL, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING)
      # — env vars override settings.json and bypass the Zod schema, which
      # currently rejects "max" as an effortLevel value.
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --arg home "$HOME" \
        '. + {
          "permissions": {"allow": .permissions.allow, "deny": []},
          "sandbox": {
            "enabled": true,
            "failIfUnavailable": true,
            "seccomp": {"applyPath": ($home + "/.claude/seccomp/apply-seccomp")}
          },
          "alwaysThinkingEnabled": true,
          "env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"},
          "statusLine": {
            "type": "command",
            "command": ($home + "/.config/claude-code/statusline.sh"),
            "padding": 0
          }
        }' "$COMPANY" > "$SETTINGS"
    else
      # Merge: union permissions, overlay plugins (user overrides win),
      # migrate sandbox schema in place (idempotent).
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --slurpfile company "$COMPANY" \
        --arg home "$HOME" \
        '
        # Union permissions arrays (deduplicate)
        .permissions.allow = ((.permissions.allow // []) + $company[0].permissions.allow | unique) |
        # Company plugins as defaults, user overrides win
        .enabledPlugins = ($company[0].enabledPlugins * (.enabledPlugins // {})) |
        # Migrate sandbox schema: drop deprecated sandbox.seccomp.bpfPath;
        # ensure sandbox.enabled and failIfUnavailable are set.
        # See: docs/plans/2026-05-18-sandbox-schema-finding.md
        .sandbox.enabled = true |
        .sandbox.failIfUnavailable = true |
        .sandbox.seccomp = (.sandbox.seccomp // {} | del(.bpfPath)) |
        # Always set statusLine to point at the home-manager-deployed script.
        # Overwriting on every merge is intentional: the path is stable, and
        # this prevents users from accidentally disabling fleet context.
        .statusLine = {
          "type": "command",
          "command": ($home + "/.config/claude-code/statusline.sh"),
          "padding": 0
        }
        ' "$SETTINGS" > "''${SETTINGS}.tmp" \
      && mv "''${SETTINGS}.tmp" "$SETTINGS"
    fi
  '';
}
