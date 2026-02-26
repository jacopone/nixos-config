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

      # Scrollback (large for AI sessions)
      scrollback-limit = 50000;

      # Clipboard
      copy-on-select = "clipboard";

      # GTK/Wayland
      gtk-single-instance = true;
      window-save-state = "always";

      # Working directory
      working-directory = "~/nixos-config";
    };
  };
}
