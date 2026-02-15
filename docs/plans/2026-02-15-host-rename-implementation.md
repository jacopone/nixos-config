---
status: draft
created: 2026-02-15
updated: 2026-02-15
type: planning
lifecycle: ephemeral
---

# Host Rename Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename all hosts to asset-tag convention (biz-NNN/tech-NNN) and create business profile for ThinkPad X1.

**Architecture:** Rename host directories with git mv, update hostnames in default.nix files, create new biz-001 host from business-template pattern with ThinkPad hardware module, update flake.nix entries. Keep thinkpad-x1-jacopo as safety net.

**Tech Stack:** NixOS, Nix Flakes, Home Manager

**Design doc:** `docs/plans/2026-02-15-host-rename-business-setup.md`

---

### Task 1: Rename Framework host to tech-001

**Files:**
- Rename: `hosts/framework-16-jacopo/` -> `hosts/tech-001/`
- Modify: `hosts/tech-001/default.nix`

**Step 1: Git mv the directory**

```bash
cd /home/guyfawkes/nixos-config
git mv hosts/framework-16-jacopo hosts/tech-001
```

**Step 2: Update hostname in default.nix**

In `hosts/tech-001/default.nix`, change:
- Comment on line 1: `# Framework Laptop 16 host configuration` stays (describes hardware)
- `networking.hostName = "framework-16-jacopo";` -> `networking.hostName = "tech-001";`

**Step 3: Verify file looks correct**

Read `hosts/tech-001/default.nix` and confirm:
- imports still reference `../common` and `../../modules/hardware/framework-16.nix`
- hostName is `"tech-001"`
- Everything else unchanged

---

### Task 2: Rename HP host to biz-002

**Files:**
- Rename: `hosts/hp-pietro/` -> `hosts/biz-002/`
- Modify: `hosts/biz-002/default.nix`

**Step 1: Git mv the directory**

```bash
git mv hosts/hp-pietro hosts/biz-002
```

**Step 2: Update hostname in default.nix**

In `hosts/biz-002/default.nix`, change:
- Comment on line 1: `# HP workstation for Pietro` stays (describes hardware/user)
- `networking.hostName = "hp-pietro";` -> `networking.hostName = "biz-002";`

**Step 3: Verify file looks correct**

Read `hosts/biz-002/default.nix` and confirm:
- imports still reference `../common/base.nix`, business packages, business chrome-extensions
- hostName is `"biz-002"`
- username/user config unchanged

---

### Task 3: Create biz-001 host for business ThinkPad

**Files:**
- Create: `hosts/biz-001/default.nix`
- Copy: `hosts/thinkpad-x1-jacopo/hardware-configuration.nix` -> `hosts/biz-001/hardware-configuration.nix`

**Step 1: Create the directory**

```bash
mkdir hosts/biz-001
```

**Step 2: Copy hardware-configuration.nix as placeholder**

```bash
cp hosts/thinkpad-x1-jacopo/hardware-configuration.nix hosts/biz-001/hardware-configuration.nix
```

This is a placeholder. After fresh NixOS install, replace with the newly generated one.

**Step 3: Create default.nix**

Write `hosts/biz-001/default.nix` with this content:

```nix
# ThinkPad X1 Carbon business workstation
# Intel UHD 620 + 8-core Intel CPU
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
    ../../modules/hardware/thinkpad.nix
  ];

  environment.variables.EDITOR = "code"; # VS Code (not Helix)

  users.users.${username} = {
    isNormalUser = true;
    description = "Business User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "biz-001";

  system.stateVersion = "24.11";
}
```

Key differences from thinkpad-x1-jacopo (tech):
- Imports `../common/base.nix` directly (not `../common` which is the tech profile)
- Imports business packages and chrome-extensions instead of core/packages.nix
- Imports `thinkpad.nix` explicitly (tech profile gets it via common/default.nix)
- No `initialPassword` (set during install, or user sets their own)
- EDITOR is VS Code, not Helix

**Step 4: Verify file structure**

```bash
ls -la hosts/biz-001/
```

Should show `default.nix` and `hardware-configuration.nix`.

---

### Task 4: Update flake.nix

**Files:**
- Modify: `flake.nix`

**Step 1: Add tech-001 entry**

Replace the `framework-16-jacopo` entry with:

```nix
# Framework Laptop 16 (AMD Ryzen AI 9 HX 370 + NVIDIA RTX 5070)
# Build: nixos-rebuild switch --flake .#tech-001
tech-001 = mkTechHost {
  hostname = "tech-001";
  username = "guyfawkes";
  extraModules = [
    # NixOS Hardware module for Framework 16 with AMD AI 300 + NVIDIA
    nixos-hardware.nixosModules.framework-16-amd-ai-300-series-nvidia
  ];
};
```

**Step 2: Add biz-001 entry**

Add after the tech section:

```nix
# ThinkPad X1 Carbon (Intel UHD 620 + 8-core) — business profile
# Build: nixos-rebuild switch --flake .#biz-001
biz-001 = mkBusinessHost {
  hostname = "biz-001";
  username = "guyfawkes";
};
```

**Step 3: Rename hp-pietro entry to biz-002**

Replace the `hp-pietro` entry with:

```nix
# HP workstation for Pietro
# Build: nixos-rebuild switch --flake .#biz-002
biz-002 = mkBusinessHost {
  hostname = "biz-002";
  username = "pietro";
};
```

**Step 4: Keep thinkpad-x1-jacopo entry unchanged**

Do NOT remove or modify the existing `thinkpad-x1-jacopo` entry. It stays as a safety net.

**Step 5: Update business-template comment**

Update the copy instructions in the `business-template` comment to reference new naming convention:

```nix
# Template for new business deployments (copy and customize)
# Usage: cp -r hosts/business-template hosts/biz-NNN
#        Then add: biz-NNN = mkBusinessHost { hostname = "biz-NNN"; username = "name"; };
# Build: nixos-rebuild switch --flake .#business-template
business-template = mkBusinessHost {
  hostname = "business-template";
  username = "user";
};
```

---

### Task 5: Validate and commit

**Step 1: Run nix flake check**

```bash
nix flake check
```

Expected: no errors. All host entries resolve correctly.

**Step 2: Stage all changes**

```bash
git add hosts/biz-001/default.nix hosts/biz-001/hardware-configuration.nix
git add -u  # stages renames and edits
```

**Step 3: Commit**

```bash
git commit -m "refactor: rename hosts to asset-tag convention (biz-NNN/tech-NNN)

- framework-16-jacopo -> tech-001
- hp-pietro -> biz-002
- New biz-001 entry for ThinkPad X1 business profile
- Keep thinkpad-x1-jacopo as safety net during transition

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

**Step 4: Push**

```bash
git push origin personal
```

---

### Task 6 (later): Clean up after ThinkPad is formatted

This task is for AFTER the ThinkPad has been formatted and rebuilt as biz-001.

**Step 1: Remove old thinkpad-x1-jacopo host directory**

```bash
git rm -r hosts/thinkpad-x1-jacopo/
```

**Step 2: Remove thinkpad-x1-jacopo entry from flake.nix**

Delete the `thinkpad-x1-jacopo = mkTechHost { ... };` block.

**Step 3: Commit**

```bash
git add -u
git commit -m "chore: remove thinkpad-x1-jacopo (migrated to biz-001)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```
