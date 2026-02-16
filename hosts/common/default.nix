# Tech profile configuration — extends base.nix with power-user tools and settings
# Used by: nixos (ThinkPad X1), framework-16
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./base.nix
    ../../modules/core/packages.nix
  ];

  # Environment
  environment.variables = {
    EDITOR = "hx";
  };

  # User account (tech profile includes input + adbusers groups)
  users.users.${username} = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "adbusers" ];
    packages = with pkgs; [ ];
  };

  # Packages
  nixpkgs.config.allowUnfree = true;

  # Chrome Extension Management (full tech set)
  programs.chromium = {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN proxy
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
      "lodbfhdipoipcjmlebjbgmmgekckhpfb" # Harper (private grammar checker)
      "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail
      "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf
      "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead
      "jjhefcfhmnkfeepcpnilbbkaadhngkbi" # Readwise Highlighter
      "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome (browser automation)
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black (dark theme)
    ];
  };

  # State version should be set per-host (based on installation date)
}
