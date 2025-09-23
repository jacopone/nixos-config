# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/core/packages.nix
      ../../modules/chrome-profiles.nix
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

  # Chrome Profile-Specific Extension Management
  # Each profile gets its own declarative extension list with full control
  programs.chrome-profiles = {
    enable = true;

    profiles = {
      # Personal Gmail Profile - Privacy & Development focused
      personal-gmail = {
        profileName = "Personal Gmail (jacopo.anselmi@gmail.com)";
        accountType = "consumer";
        extensions = [
          # Essential Management
          "ahfgeienlihckogmohjhadlkjgocpleb" # Web Store

          # Core Productivity
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium - keyboard navigation
          "jjhefcfhmnkfeepcpnilbbkaadhngkbi" # Readwise Highlighter

          # Development Tools
          "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
          "mhjhnkcfbdhnjickkkdbjoemdmbfginb" # SelectorGadget

          # Privacy & Security (Personal)
          "nkbihfbeogaeaoehlefnkodbefgpgknn" # MetaMask
          "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN (YOU WERE RIGHT!)

          # Personal Productivity
          "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket

          # Theme & Appearance (Personal)
          "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black theme
          "djflhoibgkdhkhhcedjiklpkjnoahfmg" # User-Agent Switcher
        ];
      };

      # Tenuta Larnianone Business Profile
      tenuta-larnianone = {
        profileName = "Tenuta Larnianone Business";
        accountType = "enterprise"; # May have enterprise policies
        extensions = [
          # Essential Management
          "ahfgeienlihckogmohjhadlkjgocpleb" # Web Store

          # Core Productivity
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium - keyboard navigation

          # Business Communication
          "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly - business writing
          "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail

          # Business Tools
          "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf - document handling
          "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead - efficient reading
          "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket - business articles

          # Collaboration
          "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
        ];
      };

      # Slanciamoci Business Profile (Jacopo - Owner)
      slanciamoci-jacopo = {
        profileName = "Slanciamoci - Jacopo (Owner)";
        accountType = "enterprise";
        extensions = [
          # Essential Management
          "ahfgeienlihckogmohjhadlkjgocpleb" # Web Store

          # Core Productivity
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium - keyboard navigation

          # Business & Management
          "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly - professional communication
          "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail - clean interface

          # Administrative Tools
          "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf - document management
          "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead - efficient reading
          "kadmollpgjhjcclemeliidekkajnjaih" # Project Mariner Companion

          # Business Productivity
          "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket

          # Collaboration
          "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline

          # Development Tools (Owner needs these)
          "mhjhnkcfbdhnjickkkdbjoemdmbfginb" # SelectorGadget
        ];
      };

      # Slanciamoci Business Profile (Marina)
      slanciamoci-marina = {
        profileName = "Slanciamoci - Marina";
        accountType = "enterprise";
        extensions = [
          # Essential Management
          "ahfgeienlihckogmohjhadlkjgocpleb" # Web Store

          # Core Productivity
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium - keyboard navigation

          # Business Communication
          "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly - business writing
          "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail - clean interface

          # Business Tools
          "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf - document handling
          "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead - efficient processing
          "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket - business reading

          # Collaboration
          "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
        ];
      };
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