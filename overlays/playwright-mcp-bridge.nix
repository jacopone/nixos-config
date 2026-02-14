# Overlay: auto-load Playwright MCP Bridge extension in Chrome
# Wraps google-chrome with --load-extension so the extension loads on startup.
# NOTE: This triggers Chrome's "Disable developer mode extensions" banner.
final: prev:
let
  playwright-mcp-bridge-extension = prev.stdenvNoCC.mkDerivation {
    pname = "playwright-mcp-bridge-extension";
    version = "0.0.64";
    src = ../extensions/playwright-mcp-bridge;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';
  };
in
{
  google-chrome = prev.google-chrome.override {
    commandLineArgs = "--load-extension=${playwright-mcp-bridge-extension}";
  };
}
