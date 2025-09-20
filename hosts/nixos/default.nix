# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/core/packages.nix
      ../../profiles/desktop
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
    settings.cores = 4;  # Use half CPU cores for builds (8-core system)
    settings.max-jobs = 2;  # Limit parallel builds to reduce memory pressure
    settings.download-buffer-size = 268435456;  # 256MB download buffer (default is 64MB)
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than +2";
    };
  };

  # Memory and Swap Optimization
  boot.kernel.sysctl = {
    # Reduce swap aggressiveness (default 60 -> 10 for desktop use)
    "vm.swappiness" = 10;
    # Improve memory management for interactive desktop
    "vm.vfs_cache_pressure" = 50;
    # Better dirty page management for SSD
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
  };

  # Enable zram swap for better memory compression
  zramSwap = {
    enable = true;
    algorithm = "zstd";  # Better compression than default
    memoryPercent = 25;  # Use 25% of RAM for compressed swap
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

  

  # Exclude Nixos Documentation
  documentation.nixos.enable = false;

  # Try to change the default Editor of the whole system
  environment.variables.EDITOR = "hx";

  

  

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

  

  

  # Enable Gnome Online Accounts to manage Google Drive

  # Hardware Optimizations
  services.fstrim.enable = true;  # Weekly SSD TRIM for disk health
  services.fwupd.enable = true;   # Firmware updates for ThinkPad
  hardware.graphics.enable = true;  # Graphics hardware acceleration

  # Enable fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Enable Permitted Insecure Packages to solve a dipendency needed to install Obsidian
  # and temporarily allow libsoup-2 for Google Drive support
  nixpkgs.config.permittedInsecurePackages = [
                "electron-24.8.6"
                "libsoup-2.74.3"
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

  # Chrome/Chromium System-wide Settings & Policies
  # (stack-management: consistent UX across machines)
  programs.chromium = {
    enable = true;

    # Managed Extensions (stack-management: core extensions)
    extensions = [
      "ahfgeienlihckogmohjhadlkjgocpleb" # Web Store

      # Core Productivity Extensions (stack-management: always installed)
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium - keyboard navigation
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly - writing assistant
      "jjhefcfhmnkfeepcpnilbbkaadhngkbi" # Readwise Highlighter

      # Development Tools (stack-management: dev workflow)
      "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
      "mhjhnkcfbdhnjickkkdbjoemdmbfginb" # SelectorGadget

      # Security & Privacy (stack-management: essential security)
      "nkbihfbeogaeaoehlefnkodbefgpgknn" # MetaMask
      "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN

      # Utilities (stack-management: workflow enhancers)
      "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket
      "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf
      "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail
      "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead
      "kadmollpgjhjcclemeliidekkajnjaih" # Project Mariner Companion

      # Theme & Appearance (stack-management: UI preferences)
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black theme
      "djflhoibgkdhkhhcedjiklpkjnoahfmg" # User-Agent Switcher
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
    ];

    extraOpts = {
      # ═══════════════════════════════════════════════════════════════════
      # EXTRACTED CHROME SETTINGS (2025 Structure)
      # Generated on 2025-09-18 12:51:43
      # Moved to system-wide config for compatibility
      # ═══════════════════════════════════════════════════════════════════

      # Zoom & Display Settings (using correct decimal values)
      "DefaultZoomLevel" = 1.1;  # 110% zoom (1.1 = 110%)

      # UI & Appearance
      "BookmarkBarEnabled" = false;
      "ShowHomeButton" = false;
      "HomepageLocation" = "http://www.google.com/";
      "HomepageIsNewTabPage" = true;

      # Download Settings
      "DownloadDirectory" = "/home/guyfawkes/Downloads";
      "PromptForDownloadLocation" = true;

      # Privacy & Security
      "SafeBrowsingProtectionLevel" = 1;
      "PasswordManagerEnabled" = true;

      # Performance & Features
      "HardwareAccelerationModeEnabled" = true;
      "BackgroundModeEnabled" = false;
      "NetworkPredictionOptions" = 0;

      # Content & Security Defaults
      "DefaultJavaScriptSetting" = 1;
      "DefaultImagesSetting" = 1;
      "DefaultPopupsSetting" = 2;
      "DefaultNotificationsSetting" = 3;
      "DeveloperToolsAvailability" = 1;

      # Font Settings (Chrome policy defaults)
      "DefaultFontSize" = 16;
      "MinimumFontSize" = 0;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}