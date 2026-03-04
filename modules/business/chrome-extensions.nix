# Business profile Chrome extensions — conditional on aiProfile
# Base extensions (Docs Offline) always installed
# Claude extensions only when aiProfile is "claude" or "both"
# Uses Google Chrome policy path (/etc/opt/chrome/policies/managed/)
{ lib, pkgs, aiProfile ? "google", ... }:

let
  isClaude = aiProfile == "claude" || aiProfile == "both";

  extensions =
    [
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
    ]
    ++ lib.optionals isClaude [
      "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome (browser automation)
      "mmlmfjhmonkocbjadbfplnigmagldckm" # Playwright MCP Bridge (browser automation for Claude Code)
    ];

  extensionPolicy = builtins.map
    (id: {
      installation_mode = "normal_installed";
      update_url = "https://clients2.google.com/service/update2/crx";
    })
    extensions;

  policyJson = builtins.toJSON {
    ExtensionSettings = builtins.listToAttrs (
      builtins.map
        (id: {
          name = id;
          value = {
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
        })
        extensions
    );
  };
in
{
  # Write policy to Google Chrome's policy path
  environment.etc."opt/chrome/policies/managed/business-extensions.json".text = policyJson;
}
