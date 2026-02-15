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
      "nkbihfbeogaeaoehlefnkodbefgpgknn" # MetaMask
      "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN proxy
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
      "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail
      "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf
      "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead
      "kadmollpgjhjcclemeliidekkajnjaih" # Project Mariner
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black (dark theme)
    ];
  };

  # State version should be set per-host (based on installation date)
}
