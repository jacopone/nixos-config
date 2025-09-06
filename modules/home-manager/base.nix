{ config, pkgs, ... }:

{
  # Home Manager needs a state version.
  # Please read the relevant section in the Home Manager manual
  # before changing this value.
  home.stateVersion = "24.05";

  # The home.packages option allows you to install packages in your home profile.
  home.packages = [
    # pkgs.neovim
    # pkgs.tmux
  ];

  # Let home-manager manage my shell configuration.
  programs.bash.enable = true;

  # Enable and configure Yazi file manager
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
      };
      plugin = {
        prepend_previewers = [
          { name = "*.csv"; run = "rich-preview"; }
          { name = "*.md"; run = "rich-preview"; }
          { name = "*.rst"; run = "rich-preview"; }
          { name = "*.ipynb"; run = "rich-preview"; }
          { name = "*.json"; run = "rich-preview"; }
        ];
      };
    };
    plugins = {
      rich-preview = pkgs.yaziPlugins.rich-preview;
    };
  };

  # Enable and configure Kitty terminal
  programs.kitty = {
    enable = true;
    font = {
      name = "Adwaita Mono";
      size = 11;
    };
    settings = {
      # Shell
      shell = "${pkgs.fish}/bin/fish";
      
      # Catppuccin Mocha theme
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";
      selection_background = "#585b70";
      selection_foreground = "#cdd6f4";
      url_color = "#89b4fa";
      
      # Colors
      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      color7 = "#bac2de";
      color15 = "#a6adc8";
      
      # Zoom settings - start with one increment above base size
      font_size = 12.1; # Equivalent to base size (11) + one Ctrl+Plus increment
      remember_window_size = true;
      initial_window_width = 120; # columns
      initial_window_height = 30; # rows
    };
  };

  # You can also manage settings for other programs, for example:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your@email.com";
  # };
}
