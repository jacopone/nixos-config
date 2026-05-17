# gstack install — clones garrytan/gstack into ~/.claude/skills/gstack on first
# activation, then lets gstack manage its own updates via /gstack-upgrade and
# its hourly auto-check. Soft-fails on network errors so offline rebuilds work.
#
# Active only when aiProfile is "claude" or "both" (Pietro's ama-biz-001,
# Jacopo's tl-biz-001). Requires `bun` from modules/business/packages.nix.
{ config, pkgs, lib, aiProfile ? "google", ... }:

let
  isClaude = aiProfile == "claude" || aiProfile == "both";
in
{
  home.activation = lib.mkIf isClaude {
    gstack-install = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      GSTACK_DIR="$HOME/.claude/skills/gstack"
      GSTACK_REPO="https://github.com/garrytan/gstack.git"
      BROWSE_BIN="$GSTACK_DIR/browse/dist/browse"

      $DRY_RUN_CMD mkdir -p "$HOME/.claude/skills"

      if [ ! -d "$GSTACK_DIR/.git" ]; then
        echo "→ gstack: cloning $GSTACK_REPO"
        if ! $DRY_RUN_CMD ${pkgs.git}/bin/git clone --single-branch --depth 1 \
            "$GSTACK_REPO" "$GSTACK_DIR"; then
          echo "⚠ gstack: clone failed (offline?). Re-run home-manager switch when online." >&2
          exit 0
        fi
      fi

      if [ -d "$GSTACK_DIR/.git" ] && [ ! -x "$BROWSE_BIN" ]; then
        echo "→ gstack: running ./setup (builds browse binary)"
        if ! $DRY_RUN_CMD env PATH="${pkgs.bun}/bin:${pkgs.nodejs_20}/bin:${pkgs.git}/bin:$PATH" \
            ${pkgs.bash}/bin/bash -c "cd '$GSTACK_DIR' && ./setup --quiet"; then
          echo "⚠ gstack: setup failed. Run '$GSTACK_DIR/setup' manually." >&2
          exit 0
        fi
      fi
    '';
  };
}
