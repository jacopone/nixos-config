{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, glib
, gtk3
, libdrm
, libnotify
, libsecret
, libuuid
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  pname = "google-antigravity";
  version = "1.11.2-6251250307170304";

  src = fetchurl {
    url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${version}/linux-x64/Antigravity.tar.gz";
    sha256 = "sha256-0bERWudsJ1w3bqZg4eTS3CDrPnLWogawllBblEpfZLc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libnotify
    libsecret
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc
    systemd
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
    zlib
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/antigravity

    # Copy all files to the installation directory
    cp -r ./* $out/lib/antigravity/

    # Create wrapper script
    makeWrapper $out/lib/antigravity/antigravity $out/bin/antigravity \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PATH : "${lib.makeBinPath [ ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Google Antigravity - Next-generation agentic IDE";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
