# Universal base configuration shared across ALL host profiles (tech, business, etc.)
# Profile-specific settings (EDITOR, user groups, Chrome extensions, packages) belong
# in the profile's own files, NOT here.
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ../../profiles/desktop
  ];

  # Bootloader (systemd-boot works for both UEFI machines)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking (host-specific hostname set in host's default.nix)
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager = {
    enable = true;
    connectionConfig = {
      "ipv6.method" = "disabled";
    };
  };

  # Nix Package Management and Flakes
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      # Host-specific cores/max-jobs can override in hardware modules
      download-buffer-size = 67108864; # 64MB (Nix default) - larger values cause failures on unstable WiFi
      download-attempts = 10; # Retry downloads more aggressively (default 5)
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-generations +5"; # Always keep last 5 generations
    };
  };

  # Memory and Swap Optimization (base settings, hosts can override)
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
    "kernel.panic" = 10;
    "kernel.sched_migration_cost_ns" = 5000000;
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
  };

  # Enable zram swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Automatic Updates
  system.autoUpgrade = {
    enable = true;
    dates = "monthly";
  };

  # Time and Locale
  services.localtimed.enable = true;
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

  # Documentation
  documentation.nixos.enable = false;

  # Common Hardware Services
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Virtualisation
  virtualisation.docker.enable = true;

  # Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Permitted Insecure Packages (shared across hosts)
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3" # Still required as of 2026-02-11
  ];

  # State version should be set per-host (based on installation date)
}
