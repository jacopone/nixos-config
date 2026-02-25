# Business profile packages — extends shared base with business-specific tools
# AI tools are conditional based on aiProfile ("google" | "claude" | "both")
{ pkgs, lib, inputs, aiProfile ? "google", ... }:

let
  npmVersions = import ../core/npm-versions.nix;
  isGoogle = aiProfile == "google" || aiProfile == "both";
  isClaude = aiProfile == "claude" || aiProfile == "both";
in
{
  imports = [ ../common/packages.nix ];

  environment.systemPackages = with pkgs;
    [
      # Business-specific CLI
      less
      rclone # Cloud storage sync and mount tool - Google Drive, S3, etc. - https://rclone.org/

      # Python for learning to code (business subset)
      (python3.withPackages (ps: with ps; [
        pytest
        pydantic
        jinja2
      ]))
    ]
    # Google AI stack
    ++ lib.optionals isGoogle [
      (writeShellScriptBin "gemini" ''
        exec ${pkgs.nodejs_20}/bin/npx --yes @google/gemini-cli@${npmVersions.gemini-cli} "$@"
      '')
      (writeShellScriptBin "chrome-devtools-mcp" ''
        exec ${pkgs.nodejs_20}/bin/npx --yes chrome-devtools-mcp@${npmVersions.chrome-devtools-mcp} "$@"
      '')
    ]
    # Claude AI stack
    ++ lib.optionals isClaude [
      inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
