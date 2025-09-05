# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Nix Package Management and Flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.experimental-features = [ "nix-command"  "flakes" ];
    settings.trusted-users = [ "root" "guyfawkes" ];  # Enable cachix for user
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than +2";
    };
  };

  # Automatic Updates
  system.autoUpgrade = {
    enable = true;
    dates = "monthly";
  };

  # Set your time zone.
  #time.timeZone = "Europe/Rome";
  #services.automatic-timezoned.enable = true;
  services.localtimed.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

    # Exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    baobab             # disk usage analyzer
    epiphany           # web browser
    simple-scan        # document scanner
    totem              # video player
    yelp               # help viewer
    evince             # document viewer
    file-roller        # archive manager
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

  # Exclude also Xterm that can not be excluded with the list above
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  # Exclude Nixos Documentation
  documentation.nixos.enable = false;

  # Try to change the default Editor of the whole system
  environment.variables.EDITOR = "hx";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.guyfawkes = {
    isNormalUser = true;
    description = "Guy Fawkes";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };


    # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = [
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # dev tools
    helix               # A post-modern modal text editor - https://helix-editor.com/
    zed-editor          # A high-performance, multiplayer code editor - https://zed.dev/
    vscode-fhs          # Visual Studio Code in an FHS-like environment - https://code.visualstudio.com/
    code-cursor         # An AI-powered code editor based on VSCode - https://cursor.so/
    plandex             # An open-source, terminal-based AI coding agent - https://plandex.ai/
    claude-code         # A code-generation tool using Anthropic's Claude model
    gemini-cli          # A command-line interface for Google's Gemini models
    git                 # A free and open source distributed version control system - https://git-scm.com/
    gh                  # GitHub's official command-line tool - https://cli.github.com/
    wget                # A free software package for retrieving files using HTTP, HTTPS, FTP and FTPS - https://www.gnu.org/software/wget/
    fish                # A smart and user-friendly command line shell - https://fishshell.com/
    fishPlugins.z       # A z-like directory jumping plugin for fish
    warp-terminal       # A blazingly fast, Rust-based terminal reimagined from the ground up - https://www.warp.dev/
    eza                 # A modern replacement for ls - https://eza.rocks/
    peco                # Simplistic interactive filtering tool
    gedit               # The official text editor of the GNOME desktop environment - https://wiki.gnome.org/Apps/Gedit
    jq                  # JSON processor - essential for development
    tree                # Directory visualization  
    htop                # Better system monitoring
    ripgrep             # Super fast grep (rg command)
    fd                  # Modern find alternative
    bat                 # Better cat with syntax highlighting
    docker
    
    # Core development tools (for instant AI agent commands)
    nodejs_20           # Node.js 20.19.4 with npm - eliminates devenv activation overhead
    python3             # Python for build scripts and native modules
    gcc                 # GCC compiler for native dependencies
    gnumake             # GNU Make for build systems
    pkg-config          # Package config tool for native module builds
    
    # Development environment management (completes AI agent optimization)
    direnv              # Automatic per-directory environment activation - enables .envrc
    devenv              # Fast, declarative development environments - instant service commands
    cachix              # Binary cache for faster Nix builds - system-wide availability

    # system tools
    fastfetch           # A neofetch-like tool for fetching system information and displaying them in a pretty way
    pydf                # A df-like utility that displays disk usage in a more human-readable format
    gparted             # A free partition editor for graphically managing your disk partitions - https://gparted.org/
    gtop                # A system monitoring dashboard for your terminal
    usbimager           # A minimalist GUI application to write compressed disk images to USB drives
    p7zip               # A file archiver with a high compression ratio - https://www.7-zip.org/

    # productivity tools
    google-chrome       # Google's web browser - https://www.google.com/chrome/
    obsidian            # A powerful knowledge base that works on top of a local folder of plain text Markdown files - https://obsidian.md/
    anki-bin            # A program which makes remembering things easy - https://apps.ankiweb.net/
    gimp-with-plugins   # The GNU Image Manipulation Program, with a set of popular plugins - https://www.gimp.org/
    vlc                 # A free and open source cross-platform multimedia player and framework - https://www.videolan.org/vlc/
    libreoffice         # A powerful and free office suite - https://www.libreoffice.org/

    # fonts
    dejavu_fonts        # A font family based on the Vera Fonts
    roboto              # Google's signature font family

    # useseless tools
    cmatrix             # A terminal-based "Matrix" screen saver
  ];

  # Enable Gnome Online Accounts to manage Google Drive

  # Enable fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Enable Permitted Insecure Packages to solve a dipendency needed to install Obsidian
  nixpkgs.config.permittedInsecurePackages = [
                "electron-24.8.6"
              ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
