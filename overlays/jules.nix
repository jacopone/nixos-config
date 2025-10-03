{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "google-jules";
  version = "0.1.30";

  # Fetch the actual Go binary from Google Cloud Storage
  src = fetchurl {
    url = "https://storage.googleapis.com/jules-cli/v${version}/jules_external_v${version}_linux_amd64.tar.gz";
    hash = "sha256-YSXiL+oDUUPUDWRN2ScXNSRjjXHQYuGgNyYK8DtdkB0=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib ];

  # No build phase needed - it's a pre-built binary
  dontBuild = true;
  dontConfigure = true;

  # The tarball doesn't have a single root directory
  sourceRoot = ".";

  # Extract and install
  installPhase = ''
    runHook preInstall

    # Create bin directory
    mkdir -p $out/bin

    # Install the binary (it's in the root of the extracted archive)
    install -m755 jules $out/bin/jules

    runHook postInstall
  '';

  meta = with lib; {
    description = "Jules, the asynchronous coding agent from Google, in the terminal";
    homepage = "https://jules.google";
    mainProgram = "jules";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    # License not specified - likely proprietary Google software
  };
}
