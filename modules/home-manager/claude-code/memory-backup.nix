# Declarative daily backup of Claude Code's MUTABLE institutional state — the
# one thing nix cannot reproduce: per-project auto-memory, follow-up queues,
# and plans under ~/.claude/projects. Losing this disk loses the accumulated
# operational knowledge of every project (1.7MB+, hundreds of curated files).
#
# Remote: https://github.com/AmatinoTeam/claude-memory-backup (PRIVATE — memory
# files may reference credentials or sensitive context; never make it public).
# Layout: hosts/<hostname>/projects/<project-slug>/{memory/,followups.jsonl}.
# Bootstrap per machine (deliberate manual step — the timer only pushes to a
# clone the user has created; it never picks a destination itself):
#   gh repo clone AmatinoTeam/claude-memory-backup ~/.claude/memory-backup
# Until that clone exists the timer no-ops with a journal hint.
{ lib, pkgs, ... }:

let
  backupScript = pkgs.writeShellScript "claude-memory-backup" ''
    set -u
    BK="$HOME/.claude/memory-backup"
    if [ ! -d "$BK/.git" ]; then
      echo "claude-memory-backup: no clone at $BK — bootstrap: gh repo clone AmatinoTeam/claude-memory-backup ~/.claude/memory-backup"
      exit 0
    fi
    HOST="$(uname -n)"
    DEST="$BK/hosts/$HOST"
    mkdir -p "$DEST/projects"
    for d in "$HOME"/.claude/projects/*/; do
      [ -d "$d" ] || continue
      slug="$(basename "$d")"
      if [ -d "$d/memory" ]; then
        mkdir -p "$DEST/projects/$slug"
        rsync -a --delete "$d/memory/" "$DEST/projects/$slug/memory/"
      fi
      if [ -f "$d/followups.jsonl" ]; then
        mkdir -p "$DEST/projects/$slug"
        cp "$d/followups.jsonl" "$DEST/projects/$slug/followups.jsonl"
      fi
    done
    [ -d "$HOME/.claude/plans" ] && rsync -a --delete "$HOME/.claude/plans/" "$DEST/plans/"
    cd "$BK" || exit 0
    git add -A
    if git diff --cached --quiet; then
      echo "claude-memory-backup: no changes"
      exit 0
    fi
    git commit -q -m "backup: $HOST $(date -u +%F)"
    git pull --rebase -q || true
    git push -q || echo "claude-memory-backup: push failed (offline?) — retrying next run"
  '';
in
{
  systemd.user.services.claude-memory-backup = {
    Unit.Description = "Back up Claude Code memory/queues to the private backup repo";
    Service = {
      Type = "oneshot";
      ExecStart = "${backupScript}";
      Environment = "PATH=${lib.makeBinPath (with pkgs; [ bash coreutils git gh rsync openssh ])}";
    };
  };
  systemd.user.timers.claude-memory-backup = {
    Unit.Description = "Daily Claude Code memory backup";
    Timer = {
      OnCalendar = "02:15";
      Persistent = true;
      RandomizedDelaySec = "20m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
