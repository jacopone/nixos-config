# Development tools configuration (direnv, atuin, broot, git)
{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Configure atuin for intelligent shell history
  programs.atuin = {
    enable = true;
    enableFishIntegration = false;  # Disabled to fix bind -k deprecation warning
    settings = {
      # AI workflow optimizations
      auto_sync = true;
      sync_frequency = "1h";
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";
      show_preview = true;
      max_preview_height = 4;
      # Better context for AI agents
      history_filter = [
        "^\\s"        # Skip commands starting with space
        "^exit$"      # Skip exit commands
        "^clear$"     # Skip clear commands
      ];
    };
  };

  # Enable broot for interactive directory navigation
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      # Rewrite SSH URLs to HTTPS for GitHub (fixes plugin marketplace cloning)
      url."https://github.com/".insteadOf = "git@github.com:";
    };
  };

  # Delta (better git diff) configuration
  programs.delta = {
    enable = true;
    enableGitIntegration = true;  # Explicitly enable git integration
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
    };
  };
}
