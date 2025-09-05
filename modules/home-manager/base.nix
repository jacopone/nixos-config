{ config, pkgs, ... }:

{
  # Home Manager needs a state version.
  # Please read the relevant section in the Home Manager manual
  # before changing this value.
  home.stateVersion = "23.11";

  # The home.packages option allows you to install packages in your home profile.
  home.packages = [
    # pkgs.neovim
    # pkgs.tmux
  ];

  # Let home-manager manage my shell configuration.
  programs.bash.enable = true;

  # You can also manage settings for other programs, for example:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your@email.com";
  # };
}
