# Business profile Home Manager entry point
# Reuses ghostty, starship, and dev tools from tech profile; adds simplified fish
# No yazi, rclone, command-tracking, idea/bug functions, or smart-office-open
{ config, pkgs, lib, ... }:

let
  # Guardrail hook script — blocks dangerous operations for non-developer users
  # Built as Nix derivation: executable, immutable, symlinked from ~/.claude/hooks/
  guardrailHook = pkgs.writeShellScript "business-guardrail" (builtins.readFile ./hooks/guardrail.sh);
in
{
  imports = [
    ../../home-manager/claude-code # Company-wide Claude Code commands, sandbox, permissions
    ./fish.nix # Simplified fish (business-specific)
    ../../home-manager/terminal/ghostty.nix # Ghostty terminal (shared)
    ../../home-manager/terminal/starship.nix # Starship prompt (shared)
    ../../home-manager/development/tools.nix # direnv, git, delta, atuin, broot (shared)
    ../../home-manager/desktop/gnome.nix # GNOME desktop (Dash to Dock)
    ../../home-manager/cloud-storage/rclone.nix # Google Drive mount via rclone
    ../../home-manager/desktop/smart-office-open.nix # Default handler for office files
    ../../home-manager/desktop/automatic-timezone.nix # GNOME location + automatic-timezone gsettings (clock follows travel)
    ./amatino-repos.nix # Amatino project repos, env vars, Claude Code plugins
    ./gstack-install.nix # gstack skill collection (Claude profile only)
  ];

  # Business-specific git workflow (extends company CLAUDE.md via rules, not mkForce)
  home.file.".claude/rules/business-workflow.md".source = ./business-workflow.md;

  # Claude Code guardrail hook — immutable Nix store symlink, Pietro cannot modify
  home.file.".claude/hooks/business-guardrail.sh".source = guardrailHook;

  # Wire guardrail hook into Claude Code settings (runs after company config merge)
  home.activation.claude-business-hooks = lib.hm.dag.entryAfter [ "writeBoundary" "claude-settings-merge" ] ''
    SETTINGS="$HOME/.claude/settings.json"
    HOOK_PATH="$HOME/.claude/hooks/business-guardrail.sh"

    if [ -f "$SETTINGS" ]; then
      # Dry-run safety (cf. claude-settings-merge): never prefix the jq+redirect
      # with $DRY_RUN_CMD, or `echo jq … > file` corrupts settings.json in preview.
      if [ -n "$DRY_RUN_CMD" ]; then
        $DRY_RUN_CMD "would wire business guardrail hook into $SETTINGS"
      else
        ${pkgs.jq}/bin/jq \
          --arg hook "$HOOK_PATH" \
          '.hooks.PreToolUse = [
            {"matcher": "Bash", "hooks": [{"type": "command", "command": $hook}]},
            {"matcher": "Write", "hooks": [{"type": "command", "command": $hook}]},
            {"matcher": "Edit", "hooks": [{"type": "command", "command": $hook}]}
          ]' "$SETTINGS" > "''${SETTINGS}.tmp" \
        && mv "''${SETTINGS}.tmp" "$SETTINGS"
      fi
    fi
  '';

  home.stateVersion = "24.05";

  programs.bash.enable = true;
}
