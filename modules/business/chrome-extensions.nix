# Business profile Chrome extensions — minimal curated set
# Separate file for easy per-company customization
{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome (browser automation)
    ];
  };
}
