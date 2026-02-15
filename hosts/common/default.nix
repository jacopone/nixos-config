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
      "ahfgeienlihckogmohjhadlkjgocpleb"
      "dbepggeogbaibhgnhhndojpepiihcmeb"
      "jjhefcfbdhnjickkkdbjoemdmbfginb"
      "nkbihfbeogaeaoehlefnkodbefgpgknn"
      "fjoaledfpmneenckfbpdfhkmimnjocfa"
      "kbfnbcaeplbcioakkpcpgfkobkghlhen"
      "pbmlfaiicoikhdbjagjbglnbfcbcojpj"
      "ohfgljdgelakfkefopgklcohadegdpjf"
      "ipikiaejjblmdopojhpejjmbedhlibno"
      "kadmollpgjhjcclemeliidekkajnjaih"
      "niloccemoadcdkdjlinkgdfekeahmflj"
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi"
      "aghfnjkcakhmadgdomlmlhhaocbkloab"
    ];
  };

  # State version should be set per-host (based on installation date)
}
