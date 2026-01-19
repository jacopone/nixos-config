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
, gsettings-desktop-schemas
, gtk3
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
    # Note: GDK_BACKEND=x11 required - WebKitGTK crashes on GNOME Wayland
    # WEBKIT_DISABLE_DMABUF_RENDERER=1 prevents GPU buffer sharing crashes
    # XDG_DATA_DIRS needed for gsettings schemas (WebKitGTK rendering)
    source ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/handy \
      --prefix PATH : ${lib.makeBinPath [ wtype xdotool dotool ]} \
      --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name} \
      --prefix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name} \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
      --set GDK_BACKEND x11
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

    # WebKitGTK and Tauri dependencies (critical for rendering)
    webkitgtk_4_1
    libsoup_3
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    harfbuzz
    at-spi2-atk
    atk
    dconf
    gsettings-desktop-schemas

    # GStreamer (for media in WebKit)
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good

    # Misc
    openssl
    zlib
    stdenv.cc.cc.lib
    icu
    libxml2
    libxslt
    sqlite
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
