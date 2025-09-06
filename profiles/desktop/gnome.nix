{ pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    baobab             # disk usage analyzer
    epiphany           # web browser
    simple-scan        # document scanner
    totem              # video player
    yelp               # help viewer
    geary              # email client
    seahorse           # password manager
    decibels           # audio editor 

    # these should be self explanatory
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-screenshot
    gnome-system-monitor
    gnome-weather
    gnome-disk-utility
    gnome-connections
    gnome-tour
    gnome-text-editor
    ];
}
