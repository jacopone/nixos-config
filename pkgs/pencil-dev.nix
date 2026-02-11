{ lib
, appimageTools
, fetchurl
, makeWrapper
, libGL
, vulkan-loader
, wayland
, xorg
, gsettings-desktop-schemas
, gtk3
}:

let
  pname = "pencil-dev";
  version = "1.0.0"; # No version in download URL

  src = fetchurl {
    url = "https://5ykymftd1soethh5.public.blob.vercel-storage.com/Pencil-linux-x86_64.AppImage";
    sha256 = "sha256-T0JjwUgyCXZmyqGiUDvox4HDJRYrXrqodwyY8YV5JK4=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file
    install -Dm444 ${appimageContents}/*.desktop $out/share/applications/pencil-dev.desktop 2>/dev/null || true

    # Fix desktop file paths if it exists
    if [ -f $out/share/applications/pencil-dev.desktop ]; then
      substituteInPlace $out/share/applications/pencil-dev.desktop \
        --replace-quiet 'Exec=AppRun' "Exec=$out/bin/pencil-dev"
    fi

    # Install icons (search common locations)
    for size in 16 32 48 64 128 256 512; do
      if [ -f ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/*.png ]; then
        mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
        cp ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/*.png \
           $out/share/icons/hicolor/''${size}x''${size}/apps/ 2>/dev/null || true
      fi
    done

    # Fallback: copy any PNG in root
    if [ -f ${appimageContents}/*.png ]; then
      mkdir -p $out/share/icons/hicolor/128x128/apps
      cp ${appimageContents}/*.png $out/share/icons/hicolor/128x128/apps/pencil-dev.png 2>/dev/null || true
    fi

    # Wrap with runtime dependencies
    source ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/pencil-dev \
      --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name} \
      --prefix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name} \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
  '';

  extraPkgs = pkgs: with pkgs; [
    # Graphics
    libGL
    vulkan-loader
    mesa

    # Wayland
    wayland
    libxkbcommon

    # X11 fallback
    libx11
    libxcursor
    libxrandr
    libxi
    libxcb

    # Electron dependencies
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
    nss
    nspr

    # Misc
    openssl
    zlib
    stdenv.cc.cc.lib
  ];

  meta = with lib; {
    description = "Design on canvas, land in code - IDE-integrated design tool";
    homepage = "https://pencil.dev";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "pencil-dev";
  };
}
