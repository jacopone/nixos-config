# Apple Broadcom WiFi + Bluetooth firmware for T2 Macs
# Source: https://github.com/NoaHimesaka1873/apple-bcm-firmware (extracted from macOS Sonoma)
# Workaround: nixos-hardware's brcm-firmware tries to download from osrecovery.apple.com
# which returns HTTP 403. This overlay provides the same firmware from a GitHub release.
{ pkgs, lib, ... }:

let
  apple-bcm-firmware = pkgs.stdenvNoCC.mkDerivation {
    pname = "apple-bcm-firmware";
    version = "14.0";

    src = pkgs.fetchurl {
      url = "https://github.com/NoaHimesaka1873/apple-bcm-firmware/releases/download/v14.0/apple-bcm-firmware-14.0-1-any.pkg.tar.zst";
      hash = "sha256-8s1H2eP7lljxaZey2azjAztXkluMbd2GzMPQfQw+lVk=";
    };

    nativeBuildInputs = [ pkgs.zstd ];

    unpackPhase = ''
      zstd -d $src -o firmware.tar
      tar xf firmware.tar
    '';

    installPhase = ''
      mkdir -p $out/lib/firmware/brcm
      cp usr/lib/firmware/brcm/* $out/lib/firmware/brcm/
    '';

    meta = with lib; {
      description = "Wi-Fi and Bluetooth firmware for Apple T2 and M1 Macs";
      homepage = "https://github.com/NoaHimesaka1873/apple-bcm-firmware";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  };
in
{
  hardware.firmware = [ apple-bcm-firmware ];
}
