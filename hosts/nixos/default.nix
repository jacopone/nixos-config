# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, username, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
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

  # Enable uinput for ydotool (Wayland input automation)
  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  # Nix Package Management and Flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "root" username ]; # Enable cachix for user
    settings.cores = 4; # Use half CPU cores for builds (8-core system)
    settings.max-jobs = 2; # Limit parallel builds to reduce memory pressure
    settings.download-buffer-size = 268435456; # 256MB download buffer (default is 64MB)
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
    algorithm = "zstd"; # Better compression than default
    memoryPercent = 25; # Use 25% of RAM for compressed swap
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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${username} = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ]; # Added 'input' for whisper-overlay
    packages = with pkgs; [
      #  thunderbird
    ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;





  # Enable Gnome Online Accounts to manage Google Drive

  # Hardware Optimizations
  services.fstrim.enable = true; # Weekly SSD TRIM for disk health
  services.fwupd.enable = true; # Firmware updates for ThinkPad
  hardware.graphics.enable = true; # Graphics hardware acceleration

  # NixOS Services (replaces manual package management)
  virtualisation.docker.enable = true;

  # Development Services (enable as needed per project)
  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_15;
  # };
  #
  # services.redis.servers.default = {
  #   enable = true;
  #   port = 6379;
  # };

  # Enable fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Enable Permitted Insecure Packages
  # SECURITY NOTE: These packages have known vulnerabilities. Review quarterly.
  nixpkgs.config.permittedInsecurePackages = [
    # Obsidian dependency - Electron 24.8.6 has known CVEs
    # JUSTIFICATION: No alternative markdown knowledge base with comparable features
    # MITIGATION: Obsidian runs in user space, no network services exposed
    # TODO: Monitor https://github.com/obsidianmd/obsidian-releases for Electron 28+ support
    # REVIEW DATE: 2025-11-20 | NEXT REVIEW: 2026-02-20 (90 days)
    "electron-24.8.6"

    # GNOME Google Drive support - libsoup-2 is EOL (end-of-life)
    # JUSTIFICATION: Required for gvfs Google Drive integration until libsoup-3 migration complete
    # MITIGATION: Only used for authenticated Google Drive API calls (OAuth2)
    # TODO: Test removing when NixOS 25.05 released (GNOME 47+ has libsoup-3)
    # REVIEW DATE: 2025-11-20 | NEXT REVIEW: 2026-02-20 (90 days)
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

  # Chrome Universal Extension Management
  # Reality check: Chrome policies are browser-wide, not profile-specific
  # Solution: Install all needed extensions, manage usage per profile manually
  programs.chromium = {
    enable = true;

    # Universal Extension List - Available to all profiles
    # Each profile can enable/disable what they need
    extensions = [
      # Essential Management
      "ahfgeienlihckogmohjhadlkjgocpleb" # Web Store

      # Core Productivity (Universal)
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium - keyboard navigation
      "jjhefcfhmnkfeepcpnilbbkaadhngkbi" # Readwise Highlighter

      # Development Tools
      "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
      "mhjhnkcfbdhnjickkkdbjoemdmbfginb" # SelectorGadget

      # Security & Privacy
      "nkbihfbeogaeaoehlefnkodbefgpgknn" # MetaMask
      "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN

      # Business Communication
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
      "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail

      # Business Tools
      "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf
      "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead
      "kadmollpgjhjcclemeliidekkajnjaih" # Project Mariner Companion

      # Utilities
      "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket

      # Collaboration
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline

      # Theme & Appearance
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black theme
      "djflhoibgkdhkhhcedjiklpkjnoahfmg" # User-Agent Switcher
    ];

    # No extraOpts to avoid consumer/enterprise conflicts
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
