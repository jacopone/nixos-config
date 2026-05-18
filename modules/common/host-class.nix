# Writes /etc/claudeos/host-class so the Claude Code statusline can read the
# host class without parsing the hostname at runtime. Pattern: hostnames
# matching "*-biz-*" classify as "biz"; everything else is "tech".
#
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G4
{ config, lib, ... }:

let
  hostname = config.networking.hostName;
  isBusinessHost = lib.hasInfix "-biz-" hostname;
  hostClass = if isBusinessHost then "biz" else "tech";
in
{
  environment.etc."claudeos/host-class".text = hostClass;
}
