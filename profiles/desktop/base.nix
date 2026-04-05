{ pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Exclude also Xterm that can not be excluded with the list above
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = false; # Disabled - only needed for 32-bit games/Wine (saves ~50 i686-linux builds)
    pulse.enable = true;

    # WirePlumber bluetooth configuration (fixes GNOME crashes on BT audio connect/disconnect)
    wireplumber = {
      enable = true;
      extraConfig = {
        # Disable automatic headset profile switching — prevents gsd-media-keys
        # crash and avoids dropping from A2DP to HFP when an app opens a mic stream.
        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = false;
          };
        };
        # Restrict Bluetooth roles to A2DP only — stop advertising HFP/HSP so
        # headsets (especially AirPods) can't initiate a low-quality call profile.
        # The built-in laptop mic handles all microphone needs.
        "12-bluetooth-a2dp-only" = {
          "monitor.bluez.properties" = {
            "bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
          };
        };
        # Auto-connect only the A2DP sink profile when a device connects.
        "13-bluetooth-auto-connect" = {
          "monitor.bluez.rules" = [{
            matches = [{ "device.name" = "~bluez_card.*"; }];
            actions = {
              update-props = {
                "bluez5.auto-connect" = [ "a2dp_sink" ];
              };
            };
          }];
        };
      };
    };
  };

  # Bluetooth support (explicit config for stable audio device handling)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
        Experimental = true; # Battery reporting for BT devices
      };
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.noto-fonts-color-emoji # Color emoji for terminal and apps
  ];
}
