{ pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable GVFS. Google Drive in GNOME Files now comes via GNOME Online
  # Accounts (pulled in by gnomeSupport). The old libgdata-based gvfs Google
  # backend was removed upstream (libgdata archived by GNOME), taking the
  # `googleSupport` and `libgdata` override args with it — passing them now
  # fails eval with "unexpected argument 'googleSupport'". rclone handles
  # Google Drive for business users independently of gvfs.
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs.override {
      gnomeSupport = true;
    };
  };

  # Exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    baobab # disk usage analyzer
    epiphany # web browser
    simple-scan # document scanner
    totem # video player (legacy)
    showtime # video player (GTK4, GNOME 49+) - redundant with VLC
    evince # document viewer (replaced by Foliate)
    yelp # help viewer
    geary # email client
    seahorse # password manager
    decibels # audio editor
    gnome-console # terminal (replaced by Ghostty)

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
