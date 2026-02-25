---
status: draft
created: 2026-02-25
updated: 2026-02-25
type: planning
lifecycle: persistent
---

# Business AI Profiles Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a configurable `aiProfile` parameter to business hosts that switches between Google (Gemini CLI + Chrome DevTools MCP) and Claude (Claude Code + browser extensions) AI assistant stacks, defaulting to Google.

**Architecture:** The `mkBusinessHost` helper in `flake.nix` gains an `aiProfile` parameter (`"google"` | `"claude"` | `"both"`, default `"google"`). This value flows through `specialArgs` and `home-manager.extraSpecialArgs` into business modules, which use `lib.optionals` to conditionally include packages, extensions, and fish shell configuration.

**Tech Stack:** NixOS modules, Nix `lib.optionals`, Home Manager, Fish shell, npm wrappers via `writeShellScriptBin`.

---

### Task 1: Add chrome-devtools-mcp to npm-versions.nix

**Files:**
- Modify: `modules/core/npm-versions.nix:8` (add new entry after gemini-cli line)

**Step 1: Add the version pin**

Add `chrome-devtools-mcp` between `gemini-cli` and `jules`:

```nix
  gemini-cli = "0.23.0"; # @google/gemini-cli
  chrome-devtools-mcp = "0.17.3"; # Chrome DevTools MCP server for AI browser automation
  jules = "0.1.42"; # @google/jules async coding agent
```

**Step 2: Add to update script**

In `scripts/update-npm-versions.sh`, add after line 42 (the gemini-cli check):

```bash
check_version "chrome-devtools-mcp" "chrome-devtools-mcp"
```

**Step 3: Verify version exists**

Run: `npm view chrome-devtools-mcp version`
Expected: A version number (confirms the package exists on npm)

**Step 4: Commit**

```bash
git add modules/core/npm-versions.nix scripts/update-npm-versions.sh
git commit -m "feat: add chrome-devtools-mcp to npm version pins"
```

---

### Task 2: Add aiProfile parameter to mkBusinessHost in flake.nix

**Files:**
- Modify: `flake.nix:138-163` (mkBusinessHost helper)

**Step 1: Add aiProfile parameter and thread it through**

Change `mkBusinessHost` at line 138 from:

```nix
mkBusinessHost = { hostname, username, system ? "x86_64-linux", extraModules ? [ ] }: nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs username; };
```

To:

```nix
mkBusinessHost = { hostname, username, system ? "x86_64-linux", aiProfile ? "google", extraModules ? [ ] }: nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs username aiProfile; };
```

**Step 2: Also thread aiProfile into Home Manager extraSpecialArgs**

Change line 159 from:

```nix
home-manager.extraSpecialArgs = { inherit inputs username; };
```

To:

```nix
home-manager.extraSpecialArgs = { inherit inputs username aiProfile; };
```

**Step 3: Validate syntax**

Run: `nix flake check 2>&1 | head -20`
Expected: No syntax errors (may have warnings about unused args in downstream modules -- that's fine, we fix those in Tasks 3-5)

**Step 4: Commit**

```bash
git add flake.nix
git commit -m "feat: add aiProfile parameter to mkBusinessHost"
```

---

### Task 3: Make packages.nix conditional on aiProfile

**Files:**
- Modify: `modules/business/packages.nix` (entire file)

**Step 1: Rewrite packages.nix with conditional AI tools**

Replace the entire file content with:

```nix
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
```

**Step 2: Validate syntax**

Run: `nix flake check 2>&1 | head -20`
Expected: No errors related to packages.nix

**Step 3: Commit**

```bash
git add modules/business/packages.nix
git commit -m "feat: conditional AI packages based on aiProfile"
```

---

### Task 4: Make chrome-extensions.nix conditional on aiProfile

**Files:**
- Modify: `modules/business/chrome-extensions.nix` (entire file)

**Step 1: Rewrite chrome-extensions.nix with conditional extensions**

Replace the entire file content with:

```nix
# Business profile Chrome extensions — conditional on aiProfile
# Base extensions (uBlock, Docs Offline) always installed
# Claude extensions only when aiProfile is "claude" or "both"
{ lib, aiProfile ? "google", ... }:

let
  isClaude = aiProfile == "claude" || aiProfile == "both";
in
{
  programs.chromium = {
    enable = true;
    extensions =
      [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      ]
      ++ lib.optionals isClaude [
        "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome (browser automation)
        "mmlmfjhmonkocbjadbfplnigmagldckm" # Playwright MCP Bridge (browser automation for Claude Code)
      ];
  };
}
```

**Step 2: Validate syntax**

Run: `nix flake check 2>&1 | head -20`
Expected: No errors

**Step 3: Commit**

```bash
git add modules/business/chrome-extensions.nix
git commit -m "feat: conditional Chrome extensions based on aiProfile"
```

---

### Task 5: Make fish.nix adaptive to aiProfile

**Files:**
- Modify: `modules/business/home-manager/fish.nix:1-4` (function args)
- Modify: `modules/business/home-manager/fish.nix:193-205` (greeting and helper functions)

**Step 1: Add aiProfile to function arguments**

Change line 4 from:

```nix
{ config, pkgs, ... }:
```

To:

```nix
{ config, pkgs, lib, aiProfile ? "google", ... }:
```

**Step 2: Add aiProfile helpers at the top of the file**

After the opening `{` of the module body (after the function args), add a `let` block:

```nix
let
  isGoogle = aiProfile == "google" || aiProfile == "both";
  isClaude = aiProfile == "claude" || aiProfile == "both";

  greetingText =
    if aiProfile == "both" then "  Type:  gemini  or  claude"
    else if aiProfile == "claude" then "  Type:  claude"
    else "  Type:  gemini";
in
```

**Step 3: Replace the greeting block (lines 193-199)**

Replace:

```fish
      # ClaudeOS greeting — only show in interactive terminals, not inside Claude
      if not _is_automated_context
          echo ""
          echo "  Need to install or change something?"
          echo "  Type:  claude"
          echo ""
      end
```

With:

```fish
      # AI assistant greeting — only show in interactive terminals
      if not _is_automated_context
          echo ""
          echo "  Need to install or change something?"
          echo "${greetingText}"
          echo ""
      end
```

Note: Use Nix string interpolation `${greetingText}` inside the Fish `interactiveShellInit` string.

**Step 4: Replace the claude function (lines 201-205)**

Replace:

```fish
      # Launch Claude Code in nixos-config directory
      function claude --description "Open Claude Code in your system config"
          builtin cd ~/nixos-config
          command claude
      end
```

With conditional function definitions using Nix string interpolation:

```nix
      ${lib.optionalString isGoogle ''
      # Launch Gemini CLI in nixos-config directory
      function gemini --description "Open Gemini CLI in your system config"
          builtin cd ~/nixos-config
          command gemini
      end
      ''}
      ${lib.optionalString isClaude ''
      # Launch Claude Code in nixos-config directory
      function claude --description "Open Claude Code in your system config"
          builtin cd ~/nixos-config
          command claude
      end
      ''}
```

**Step 5: Update automated context detection**

In the `_is_automated_context` function (line 32), add `gemini` to the process tree check:

Change:

```fish
          if string match -qr '(claude|cursor|vscode|agent|copilot)' $process_tree
```

To:

```fish
          if string match -qr '(claude|gemini|cursor|vscode|agent|copilot)' $process_tree
```

**Step 6: Validate syntax**

Run: `nix flake check 2>&1 | head -20`
Expected: No errors

**Step 7: Commit**

```bash
git add modules/business/home-manager/fish.nix
git commit -m "feat: adaptive fish greeting and AI functions based on aiProfile"
```

---

### Task 6: Create GEMINI.md business template

**Files:**
- Create: `hosts/business-template/GEMINI.md`

**Step 1: Create the file**

Create `hosts/business-template/GEMINI.md` with content adapted from the existing CLAUDE.md template:

```markdown
---
status: active
created: 2026-02-25
updated: 2026-02-25
type: guide
lifecycle: persistent
---

# NixOS Configuration — Your Computer

## What You Can Do

Ask me to install or remove programs. Examples:
- "Install Slack"
- "I need a video editor"
- "Remove LibreOffice"

You can also ask me questions about your system, or ask me to help you learn.

## How It Works

1. I find the right package and update the config
2. I save the change (git commit)
3. You run the command I give you to apply it
4. After it works, I sync the change (git push)

## My Default Behavior

- I edit `modules/business/packages.nix` to add/remove packages
- I search nixpkgs to find the correct package name
- After editing, I commit with a descriptive message
- I tell you to run: `sudo nixos-rebuild switch --flake .#HOSTNAME`
- After you confirm it worked, I run `git push`
- If the rebuild fails, I help you fix it before pushing

## Project Structure

- `modules/business/packages.nix` — your installed programs (this is what I edit)
- `modules/business/home-manager/fish.nix` — shell configuration
- `hosts/HOSTNAME/default.nix` — machine-specific hardware config
- `flake.nix` — system entry point (usually no need to touch)

## If Something Goes Wrong

Tell me the error message and I'll help fix it.
If I can't fix it, your admin can see your system remotely and push a fix.
Just run `git pull && sudo nixos-rebuild switch --flake .#HOSTNAME` when they tell you to.

## Git Workflow

- Always work on the current branch (your machine's branch)
- Never switch branches or merge
- If git has issues, tell your admin
```

**Step 2: Commit**

```bash
git add hosts/business-template/GEMINI.md
git commit -m "feat: add GEMINI.md business template for Google AI profile"
```

---

### Task 7: Full validation

**Step 1: Run nix flake check**

Run: `nix flake check`
Expected: Clean pass, no errors

**Step 2: Test each aiProfile value evaluates**

Run: `nix eval .#nixosConfigurations.biz-001.config.system.build.toplevel.drvPath 2>&1 | tail -5`
Expected: A store path (confirms "google" default works)

Run: `nix eval .#nixosConfigurations.biz-003.config.system.build.toplevel.drvPath 2>&1 | tail -5`
Expected: A store path (confirms T2 + google works)

**Step 3: Verify gemini package is included for google profile**

Run: `nix eval .#nixosConfigurations.biz-001.config.environment.systemPackages --apply 'pkgs: map (p: p.name or "unknown") pkgs' 2>&1 | grep -i gemini`
Expected: Contains "gemini" wrapper

**Step 4: Commit any remaining fixes**

If any validation steps required fixes, commit them:

```bash
git add -A
git commit -m "fix: address validation issues in business AI profiles"
```

---

### Task 8: Update design doc status

**Files:**
- Modify: `docs/plans/2026-02-25-business-ai-profiles-design.md:2`

**Step 1: Change status from draft to active**

Change `status: draft` to `status: active` in the frontmatter.

**Step 2: Final commit**

```bash
git add docs/plans/2026-02-25-business-ai-profiles-design.md
git commit -m "docs: mark business AI profiles design as active"
```
