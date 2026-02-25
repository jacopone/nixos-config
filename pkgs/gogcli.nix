{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "gogcli";
  version = "0.11.0";

  src = fetchurl {
    url = "https://github.com/steipete/gogcli/releases/download/v${version}/gogcli_${version}_linux_amd64.tar.gz";
    sha256 = "ca98ba56e29ccd3713fe7bf835fdca00ae1b97cdcb7b0bc5e393e7edb4089c84";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    install -Dm755 gog $out/bin/gog
  '';

  meta = with lib; {
    description = "Google Suite CLI: Gmail, GCal, GDrive, GContacts and more";
    homepage = "https://github.com/steipete/gogcli";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "gog";
  };
}
