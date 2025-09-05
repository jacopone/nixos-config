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

  programs.kitty = {
    enable = true;
    extraConfig = ''
      shell ${pkgs.fish}/bin/fish

      # BEGIN_KITTY_THEME
      # Catppuccin Mocha
      background #1e1e2e
      foreground #cdd6f4
      cursor #f5e0dc
      selection_background #585b70
      selection_foreground #cdd6f4
      url_color #89b4fa

      # Black
      color0 #45475a
      color8 #585b70

      # Red
      color1 #f38ba8
      color9 #f38ba8

      # Green
      color2 #a6e3a1
      color10 #a6e3a1

      # Yellow
      color3 #f9e2af
      color11 #f9e2af

      # Blue
      color4 #89b4fa
      color12 #89b4fa

      # Magenta
      color5 #f5c2e7
      color13 #f5c2e7

      # Cyan
      color6 #94e2d5
      color14 #94e2d5

      # White
      color7 #bac2de
      color15 #a6adc8
      # END_KITTY_THEME

      font_family Adwaita Mono
      font_size 11
    '';
  };

  # You can also manage settings for other programs, for example:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your@email.com";
  # };
}
