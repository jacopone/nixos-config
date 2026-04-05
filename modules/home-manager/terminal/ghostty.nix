# Ghostty terminal emulator configuration
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      # Shell
      command = "${pkgs.fish}/bin/fish";

      # Font (matching Kitty setup)
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      # Catppuccin Mocha theme
      theme = "Catppuccin Mocha";

      # Window
      window-padding-x = 4;
      window-padding-y = 4;
      background-opacity = 0.95;
      window-decoration = "auto"; # Uses GTK CSD on GNOME

      # Cursor
      cursor-style = "block";
      cursor-style-blink = true;

      # Scrollback in bytes (large for AI sessions — ~10MB)
      scrollback-limit = 10000000;

      # Trackpad scroll speed (precision=touchpad, discrete=mouse wheel)
      mouse-scroll-multiplier = "precision:3,discrete:3";

      # Clipboard
      copy-on-select = "clipboard";

      # GTK/Wayland
      gtk-single-instance = true;
      window-save-state = "always";

      # Bell — disable attention hint to prevent GNOME dock notification badge
      bell-features = "no-system,no-audio,no-attention,title,no-border";

      # Working directory
      working-directory = "~/nixos-config";
    };
  };
}
