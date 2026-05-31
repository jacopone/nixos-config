# Shared Claude Code configuration — company-wide policies, commands, and sandbox
# Immutable files (CLAUDE.md, commands, seccomp): Nix store symlinks, auto-updated on rebuild.
# Mutable files (settings.json): merged on rebuild — company baseline + user additions preserved.
{ config, lib, pkgs, ... }:

let
  claude-seccomp = import ../../../pkgs/claude-seccomp.nix { inherit pkgs; };
  companyConfig = ./company-config.json;
in
{
  imports = [
    ./gstack-browse-libfix.nix # Scoped libstdc++ LD_LIBRARY_PATH wrapper for gstack's `browse`
  ];

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

  # Claude Code env vars live in settings.json's `env` block (built in the merge
  # below), NOT in home.sessionVariables. hm-session-vars.sh is POSIX sh, sourced
  # only by LOGIN bash/zsh — a fish `claude` launch (especially non-login) never
  # runs it, so vars set there silently went missing. settings.json is read directly
  # by Claude Code on every launch, shell- and login-independent, and its `env`
  # block injects into the process env (verified). effortLevel also lives there.

  # Merge company config into settings.json on every rebuild.
  # - Permissions: union (company baseline always present, user additions preserved)
  # - Plugins: company defaults, user overrides win (if Pietro disables one, his false wins)
  # - Sandbox: schema-migrated and re-asserted on every merge (idempotent)
  # - statusLine: overwritten on every merge to point at the deployed script
  # - effortLevel: seeded to "medium" on first setup only, then user-controlled (/effort)
  # - env: Claude env vars (subagent model, autocompact, max-output) re-asserted;
  #   the deprecated adaptive-thinking override is scrubbed so CC scales thinking by difficulty
  # - Other settings: untouched (hooks, other env keys stay user-managed)
  home.activation.claude-settings-merge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS="$HOME/.claude/settings.json"
    COMPANY="${companyConfig}"

    $DRY_RUN_CMD mkdir -p "$HOME/.claude"

    # Dry-run safety: jq writes to stdout and we redirect into $SETTINGS, so
    # the redirection MUST NOT be prefixed by $DRY_RUN_CMD. Under home-manager
    # --dry-run, $DRY_RUN_CMD=echo, and `echo jq … > "$SETTINGS"` would write
    # the literal jq command-as-string into settings.json, corrupting config
    # in "preview" mode. Guard each branch with an explicit dry-run check.
    # Regression: tests/bash/claude-settings/test-dry-run-safety.bats
    if [ ! -f "$SETTINGS" ]; then
      # First setup: create settings with company config + sandbox paths
      # Note: effortLevel AND the Claude env vars live HERE in settings.json so they
      # are shell-independent (read directly by Claude Code; the env block injects
      # into the process env). effortLevel cannot be "max" (Zod rejects it); for a
      # one-off max run use `env CLAUDE_CODE_EFFORT_LEVEL=max claude`.
      if [ -n "$DRY_RUN_CMD" ]; then
        $DRY_RUN_CMD "would seed $SETTINGS from $COMPANY"
      else
        ${pkgs.jq}/bin/jq \
          --arg home "$HOME" \
          '. + {
            "permissions": {"allow": .permissions.allow, "deny": []},
            "sandbox": {
              "enabled": true,
              "failIfUnavailable": true,
              "seccomp": {"applyPath": ($home + "/.claude/seccomp/apply-seccomp")}
            },
            "alwaysThinkingEnabled": true,
            "effortLevel": "medium",
            "env": {
              "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
              "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet",
              "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80",
              "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "64000"
            },
            "statusLine": {
              "type": "command",
              "command": ($home + "/.config/claude-code/statusline.sh"),
              "padding": 0
            }
          }' "$COMPANY" > "$SETTINGS"
      fi
    else
      # Merge: union permissions, overlay plugins (user overrides win),
      # migrate sandbox schema in place (idempotent).
      if [ -n "$DRY_RUN_CMD" ]; then
        $DRY_RUN_CMD "would merge $COMPANY into $SETTINGS"
      else
        ${pkgs.jq}/bin/jq \
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
          # Re-assert the Claude env vars in the settings.json env block — shell-independent,
          # unlike home.sessionVariables, which a non-login fish skips. Right-hand wins;
          # any other user env keys are preserved. del() then scrubs the deprecated
          # adaptive-thinking override: `+` overlays keys but never removes them, so the
          # explicit del makes removal idempotent on hosts that already wrote it.
          .env = (((.env // {}) + {
            "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
            "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet",
            "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80",
            "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "64000"
          }) | del(.CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING)) |
          # effortLevel is deliberately NOT touched here: it is seeded once in the
          # first-setup branch above, then left fully user-controlled via /effort, so
          # model+effort combinations chosen per session persist across rebuilds. The
          # env var that used to override /effort is gone; settings.json is launch-scoped.
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
    fi
  '';
}
