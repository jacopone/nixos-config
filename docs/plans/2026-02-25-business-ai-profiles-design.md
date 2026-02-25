---
status: draft
created: 2026-02-25
updated: 2026-02-25
type: planning
lifecycle: persistent
---

# Business AI Profiles — Configurable AI Assistant per Host

## Problem

The current business profile assumes all users have a Claude/Anthropic account. In practice, business users are more likely to have Google accounts (personal or corporate). The AI assistant should default to the Google ecosystem (Gemini CLI + Chrome DevTools MCP) while supporting Claude as an opt-in alternative.

## Decision

Add an `aiProfile` parameter to `mkBusinessHost` that controls which AI assistant stack is installed. Default is `"google"`.

## Design

### aiProfile values

| Value | AI CLI | Browser AI | Browser Extensions | Fish greeting |
|---|---|---|---|---|
| `"google"` (default) | `gemini` (Gemini CLI) | Built-in Gemini in Chrome | uBlock + Docs Offline only | "Type: gemini" |
| `"claude"` | `claude` (Claude Code) | Claude in Chrome | uBlock + Docs Offline + Claude in Chrome + Playwright MCP Bridge | "Type: claude" |
| `"both"` | Both `gemini` and `claude` | Both | All extensions | "Type: gemini or claude" |

### Data flow

```
flake.nix
  mkBusinessHost { aiProfile = "google"; }
    |
    +-- specialArgs = { inherit aiProfile; }
    |
    +-- modules/business/packages.nix
    |     conditionally includes gemini/chrome-devtools-mcp or claude-code
    |
    +-- modules/business/chrome-extensions.nix
    |     conditionally includes Claude browser extensions
    |
    +-- modules/business/home-manager/fish.nix
          greeting and helper functions adapt to aiProfile
```

### Google stack components

- **Gemini CLI**: `@google/gemini-cli` via npm (pinned in `npm-versions.nix`). Command name: `gemini`. Authenticates via Google OAuth (user's existing account).
- **Chrome DevTools MCP**: `chrome-devtools-mcp` via npm (pinned in `npm-versions.nix`). MCP server exposing Chrome DevTools Protocol to Gemini CLI for browser automation.
- **Gemini in Chrome**: Built into Chrome browser (side panel). No extension needed.
- **GEMINI.md**: Project instructions file (equivalent to CLAUDE.md). Tells Gemini how to help business users manage packages.

### Claude stack components (unchanged from current)

- **Claude Code**: via `claude-code-nix` flake input. Command name: `claude`.
- **Claude in Chrome**: Extension ID `fcoeoabgfenejglbffodgkkbkcdhcgfn`.
- **Playwright MCP Bridge**: Extension ID `mmlmfjhmonkocbjadbfplnigmagldckm`.
- **CLAUDE.md**: Existing business template.

## Files to change

| File | Change |
|---|---|
| `flake.nix` | Add `aiProfile` param (default `"google"`) to `mkBusinessHost`, pass via `specialArgs` |
| `modules/core/npm-versions.nix` | Add `chrome-devtools-mcp` version |
| `modules/business/packages.nix` | Conditional AI tool packages based on `aiProfile` |
| `modules/business/chrome-extensions.nix` | Conditional Claude extensions based on `aiProfile` |
| `modules/business/home-manager/fish.nix` | Adaptive greeting and helper functions |
| `scripts/update-npm-versions.sh` | Add `chrome-devtools-mcp` version check |
| `hosts/business-template/GEMINI.md` | New: business instructions for Gemini CLI |

## Configuration scope

Per-host (set in `flake.nix` via `mkBusinessHost`). All users on a host share the same AI profile. Matches current pattern where each biz-NNN is one person's machine.

## Usage examples

```nix
# Default: Google (no aiProfile needed)
biz-001 = mkBusinessHost {
  hostname = "biz-001";
  username = "guyfawkes";
};

# Explicit Claude
biz-004 = mkBusinessHost {
  hostname = "biz-004";
  username = "someone";
  aiProfile = "claude";
};

# Both profiles
biz-005 = mkBusinessHost {
  hostname = "biz-005";
  username = "poweruser";
  aiProfile = "both";
};
```

## Admin workflow

The admin (you) continues to use Claude Code for remote management via RustDesk regardless of the user's `aiProfile`. The `aiProfile` only affects the user-facing AI assistant.
