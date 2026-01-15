{ lib
, appimageTools
, fetchurl
, makeWrapper
, wtype
, xdotool
, dotool
, pulseaudio
, alsa-lib
, libGL
, vulkan-loader
, wayland
, xorg
}:

let
  pname = "handy";
  version = "0.6.11";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    sha256 = "1phslxs3d27blr0zhk87sg9v4qhwcibivwp06x4prlck5h45k58y";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file (note: capital H in Handy.desktop)
    install -Dm444 ${appimageContents}/Handy.desktop $out/share/applications/handy.desktop

    # Fix desktop file paths
    substituteInPlace $out/share/applications/handy.desktop \
      --replace-quiet 'Exec=AppRun' "Exec=$out/bin/handy"

    # Install icons
    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp ${appimageContents}/Handy.png $out/share/icons/hicolor/128x128/apps/handy.png

    # Wrap with runtime dependencies
    source ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/handy \
      --prefix PATH : ${lib.makeBinPath [ wtype xdotool dotool ]} \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
  '';

  extraPkgs = pkgs: with pkgs; [
    # Audio
    pulseaudio
    alsa-lib
    pipewire

    # Graphics (Tauri/WebKitGTK needs these)
    libGL
    vulkan-loader
    mesa

    # Wayland
    wayland
    libxkbcommon

    # X11 fallback
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libxcb

    # WebKitGTK dependencies
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    harfbuzz

    # Misc
    openssl
    zlib
    stdenv.cc.cc.lib
  ];

  meta = with lib; {
    description = "Free, open-source, offline speech-to-text with Whisper and Parakeet models";
    homepage = "https://github.com/cjpais/Handy";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "handy";
  };
}
