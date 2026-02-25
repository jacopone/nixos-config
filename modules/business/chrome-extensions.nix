# Business profile Chrome extensions — conditional on aiProfile
# Base extensions (uBlock, Docs Offline) always installed
# Claude extensions only when aiProfile is "claude" or "both"
{ lib, aiProfile ? "google", ... }:

let
  isClaude = aiProfile == "claude" || aiProfile == "both";
in
{
  programs.chromium = {
    enable = true;
    extensions =
      [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      ]
      ++ lib.optionals isClaude [
        "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome (browser automation)
        "mmlmfjhmonkocbjadbfplnigmagldckm" # Playwright MCP Bridge (browser automation for Claude Code)
      ];
  };
}
