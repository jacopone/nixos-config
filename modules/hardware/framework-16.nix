# Framework Laptop 16 hardware configuration
# AMD Ryzen AI 9 HX 370 + NVIDIA RTX 5070 Expansion Bay
{ config, pkgs, lib, ... }:

{
  # Framework EC kernel module (battery charge limit, privacy switches, LEDs)
  # Auto-enabled by nixos-hardware on kernel >= 6.10, but explicit for clarity
  hardware.framework.enableKmod = true;

  # Framework 16-specific kernel modules
  boot.kernelModules = [ "uinput" ];

  # AMD GPU, NVIDIA, and Framework-specific kernel parameters
  boot.kernelParams = [
    "amdgpu.abmlevel=0" # Disable Active Backlight Management for accurate colors
    "nvme_core.default_ps_max_latency_us=5500" # NVMe power saving for WD_BLACK SN7100
  ];

  # Use latest kernel for best AMD/NVIDIA support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # uinput for Wayland input automation
  services.udev.extraRules = lib.mkMerge [
    ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    ''
    # Disable keyboard/trackpad USB wake (prevents backpack wake)
    ''
      SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"
    ''
  ];

  # NVIDIA proprietary drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA configuration
  hardware.nvidia = {
    # Use production driver (proprietary)
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Modesetting required for Wayland
    modesetting.enable = true;

    # Power management (experimental but needed for laptops)
    powerManagement.enable = true;
    powerManagement.finegrained = false; # RTX 5070 may not support fine-grained

    # Enable nvidia-settings GUI
    nvidiaSettings = true;

    # Open source kernel module (REQUIRED for RTX 5070 Blackwell architecture)
    open = true;

    # PRIME Offload mode (render on NVIDIA, display on AMD)
    # IMPORTANT: Update these bus IDs after running:
    # nix-shell -p pciutils --run 'lspci | grep -E "VGA|3D"'
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Provides nvidia-offload wrapper
      };
      # Bus IDs set in hosts/framework-16/default.nix (detected values)
      # Default fallbacks for Framework 16 with RTX 5070 expansion bay
      amdgpuBusId = lib.mkDefault "PCI:194:0:0"; # AMD iGPU
      nvidiaBusId = lib.mkDefault "PCI:193:0:0"; # NVIDIA dGPU
    };
  };

  # AMD + NVIDIA graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam/gaming compatibility
    extraPackages = with pkgs; [
      # AMD VA-API
      libva
      # Vulkan
      vulkan-loader
      vulkan-validation-layers
      # NVIDIA-specific
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  # Use power-profiles-daemon for AMD (NOT TLP)
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # Fingerprint reader support
  services.fprintd.enable = true;

  # Thunderbolt/USB4 hot-plug support
  services.hardware.bolt.enable = true;

  # Ambient light sensor for auto-brightness
  hardware.sensor.iio.enable = true;

  # Fan control for quieter operation
  hardware.fw-fanctrl.enable = true;

  # Double suspend workaround (systemd v258+)
  systemd.services.inhibit-sleep-after-resume = {
    description = "Temporary sleep inhibitor after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.systemd}/bin/systemd-inhibit \
        --mode=block \
        --what=sleep:idle \
        --why="Workaround: avoid second suspend" \
        ${pkgs.coreutils}/bin/sleep 60
    '';
  };

  # Framework-specific packages
  environment.systemPackages = with pkgs; [
    framework-tool # Swiss army knife for Framework laptops
    inputmodule-control # LED Matrix control
    nvtopPackages.nvidia # NVIDIA GPU monitoring
    powertop # Power consumption analysis
  ];

  # Nix build settings for 12-core AMD system with 64GB RAM
  nix.settings = {
    cores = 8; # Use 8 of 12 cores for builds
    max-jobs = 4; # More parallel builds with 64GB RAM
  };

  # Higher zram percentage with 64GB RAM
  zramSwap.memoryPercent = lib.mkForce 15; # 15% of 64GB = ~10GB compressed swap
}
