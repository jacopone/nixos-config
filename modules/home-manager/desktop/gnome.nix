# GNOME desktop customizations
# Dash to Dock: always-visible macOS-style dock at the bottom
{ config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.gnomeExtensions.dash-to-dock
  ];

  dconf.settings = {
    # Enable Dash to Dock in GNOME Shell
    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
      ];
    };

    # Dash to Dock configuration — macOS-style always-visible dock
    "org/gnome/shell/extensions/dash-to-dock" = {
      # Position & layout
      dock-position = "BOTTOM";
      extend-height = false;

      # Always visible (no auto-hide)
      dock-fixed = true;
      autohide = false;
      intellihide = false;

      # Icon sizing
      dash-max-icon-size = 48;

      # Translucent background (macOS frosted glass feel)
      transparency-mode = "FIXED";
      background-opacity = 0.7;

      # Running app indicators (dots below active apps)
      show-running = true;
      running-indicator-style = "DOTS";

      # Show favorites and running apps
      show-favorites = true;
      show-trash = false;
      show-mounts = false;

      # Click behavior
      click-action = "focus-minimize-or-previews";
    };
  };
}
