# Shared Claude Code configuration — company-wide policies, commands, and sandbox
# Immutable files (CLAUDE.md, commands, seccomp): Nix store symlinks, auto-updated on rebuild.
# Mutable files (settings.json): merged on rebuild — company baseline + user additions preserved.
{ config, lib, pkgs, ... }:

let
  claude-seccomp = import ../../../pkgs/claude-seccomp.nix { inherit pkgs; };
  companyConfig = ./company-config.json;
in
{
  # Company-wide coding standards — auto-updated on every rebuild
  home.file.".claude/CLAUDE.md".source = ./company-policies.md;

  # Shared slash commands (personal commands like /life stay as regular files alongside these)
  home.file.".claude/commands/nixos.md".source = ./commands/nixos.md;

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
  # - Other settings: untouched (hooks, statusLine, sandbox, etc. stay user-managed)
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
          "sandbox": {"seccomp": {
            "bpfPath": ($home + "/.claude/seccomp/unix-block.bpf"),
            "applyPath": ($home + "/.claude/seccomp/apply-seccomp")
          }},
          "alwaysThinkingEnabled": true,
          "env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}
        }' "$COMPANY" > "$SETTINGS"
    else
      # Merge: union permissions, overlay plugins (user overrides win)
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --slurpfile company "$COMPANY" \
        '
        # Union permissions arrays (deduplicate)
        .permissions.allow = ((.permissions.allow // []) + $company[0].permissions.allow | unique) |
        # Company plugins as defaults, user overrides win
        .enabledPlugins = ($company[0].enabledPlugins * (.enabledPlugins // {}))
        ' "$SETTINGS" > "''${SETTINGS}.tmp" \
      && mv "''${SETTINGS}.tmp" "$SETTINGS"
    fi
  '';
}
