# Enable Chrome DevTools Protocol for Playwright MCP server.
# Adds --remote-debugging-port=9222 so the MCP server can connect
# directly via --cdp-endpoint without needing the browser extension.
final: prev: {
  google-chrome = prev.google-chrome.override {
    commandLineArgs = "--remote-debugging-port=9222";
  };
}
