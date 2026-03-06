# Business profile packages — extends shared base with business-specific tools
# AI tools are conditional based on aiProfile ("google" | "claude" | "both")
{ pkgs, lib, inputs, aiProfile ? "google", ... }:

let
  npmVersions = import ../core/npm-versions.nix;
  isGoogle = aiProfile == "google" || aiProfile == "both";
  isClaude = aiProfile == "claude" || aiProfile == "both";
  inherit (pkgs) writeShellScriptBin;
  npmPrefix = "/tmp/nix-npm-prefix";
  mkNpxWrapper = name: pkg: writeShellScriptBin name ''
    mkdir -p ${npmPrefix}/lib
    export npm_config_prefix=${npmPrefix}
    exec ${pkgs.nodejs_20}/bin/npx --yes ${pkg} "$@"
  '';
in
{
  imports = [ ../common/packages.nix ];

  environment.systemPackages = with pkgs;
    [
      # Speech-to-text
      vibetyper # AI voice typing with speech-to-text - https://vibetyper.com
      wtype # Wayland text input
      xdotool # X11 text input
      dotool # Universal text input

      # Business-specific CLI
      less
      rclone # Cloud storage sync and mount tool - Google Drive, S3, etc. - https://rclone.org/
      maestral # Open-source Dropbox client - https://maestral.app/
      # maestral-gui wrapped with GTK schemas (NixOS needs explicit XDG_DATA_DIRS)
      (symlinkJoin {
        name = "maestral-gui-wrapped";
        paths = [ maestral-gui ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/maestral_qt \
            --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name} \
            --prefix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name}
        '';
      })
      apostrophe # Distraction-free Markdown reader/editor (GTK/GNOME)
      foliate # EPUB/ebook reader (GTK/GNOME)

      # Python for learning to code (business subset)
      (python3.withPackages (ps: with ps; [
        pytest
        pydantic
        jinja2
      ]))
    ]
    # Google AI stack
    ++ lib.optionals isGoogle [
      (mkNpxWrapper "gemini" "@google/gemini-cli@${npmVersions.gemini-cli}")
      (mkNpxWrapper "chrome-devtools-mcp" "chrome-devtools-mcp@${npmVersions.chrome-devtools-mcp}")
    ]
    # Claude AI stack
    ++ lib.optionals isClaude [
      inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
