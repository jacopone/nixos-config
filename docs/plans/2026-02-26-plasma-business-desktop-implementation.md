---
status: draft
created: 2026-02-26
updated: 2026-02-26
type: planning
lifecycle: persistent
---

# KDE Plasma 6 Business Desktop Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace GNOME with KDE Plasma 6 on all business hosts while keeping tech hosts on GNOME, with a macOS-like panel layout via plasma-manager.

**Architecture:** Decouple desktop profile from shared base config. Create new system-level `profiles/desktop/plasma.nix` and user-level `modules/home-manager/desktop/plasma.nix`. Add `plasma-manager` flake input for declarative Plasma configuration. Wire business hosts to use new Plasma profile.

**Tech Stack:** NixOS 25.11, KDE Plasma 6, SDDM, plasma-manager (nix-community), Home Manager

**Design doc:** `docs/plans/2026-02-26-plasma-business-desktop-design.md`

---

### Task 1: Add plasma-manager Flake Input

**Files:**
- Modify: `flake.nix` (inputs section ~line 80, outputs function signature ~line 87)

**Step 1: Add plasma-manager input to flake.nix**

In the `inputs` section, after the `antigravity-nix` input block (~line 70), add:

```nix
# Plasma Manager - Declarative KDE Plasma config for Home Manager
# MAINTAINER: nix-community | AUTO-UPDATE: Via rebuild-nixos --refresh
plasma-manager = {
  url = "github:nix-community/plasma-manager";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

Then update the `outputs` function signature to include `plasma-manager`:

```nix
outputs = { self, nixpkgs, home-manager, nixos-hardware, claude-code-nix, code-cursor-nix, whisper-dictation, claude-automation, antigravity-nix, plasma-manager, ... }@inputs:
```

**Step 2: Validate flake parses**

Run: `nix flake check --no-build 2>&1 | head -20`
Expected: No parse errors (may show warnings, no errors about plasma-manager)

**Step 3: Lock the new input**

Run: `nix flake lock --update-input plasma-manager`
Expected: `flake.lock` updated with plasma-manager hash

**Step 4: Commit**

```bash
git add flake.nix flake.lock
git commit -m "feat: add plasma-manager flake input for declarative KDE config"
```

---

### Task 2: Create System-Level Plasma Profile

**Files:**
- Create: `profiles/desktop/plasma.nix`

**Step 1: Create the Plasma system profile**

Create `profiles/desktop/plasma.nix`:

```nix
{ pkgs, ... }:

{
  # KDE Plasma 6 desktop environment
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = false; # Pure Qt 6 — no legacy Qt5 theming
  };

  # SDDM display manager (Plasma's native DM)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Default to Plasma Wayland session
  services.displayManager.defaultSession = "plasma";

  # Remove Plasma bloat — business users use Kitty, Chrome, VS Code
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole                        # Terminal (using Kitty)
    elisa                          # Music player
    kate                           # Text editor (using VS Code)
    ktexteditor                    # Kate text editor framework
    khelpcenter                    # KDE help docs
    kwin-x11                       # X11 window manager (Wayland-only)
    aurorae                        # Legacy window decorations
    plasma-browser-integration     # Browser-Plasma integration
    plasma-workspace-wallpapers    # Default wallpaper collection
    krdp                           # Remote desktop
  ];
}
```

**Step 2: Validate file syntax**

Run: `nix-instantiate --parse profiles/desktop/plasma.nix > /dev/null && echo OK`
Expected: `OK`

**Step 3: Commit**

```bash
git add profiles/desktop/plasma.nix
git commit -m "feat: add Plasma 6 system-level desktop profile"
```

---

### Task 3: Create Home Manager Plasma Config

**Files:**
- Create: `modules/home-manager/desktop/plasma.nix`

**Step 1: Create the Plasma Home Manager module**

Create `modules/home-manager/desktop/plasma.nix`:

```nix
# KDE Plasma 6 desktop customizations — macOS-like layout
# Top panel: global menu bar + system tray + clock
# Bottom panel: icon-only dock with pinned apps
{ config, pkgs, lib, ... }:

{
  programs.plasma = {
    enable = true;

    # ── Theme ──
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "breeze-dark";
    };

    # ── Top Panel: macOS-style menu bar ──
    # ── Bottom Panel: macOS-style dock ──
    panels = [
      # Top panel — menu bar with system tray and clock
      {
        location = "top";
        height = 28;
        floating = false;
        widgets = [
          {
            kickoff = {
              icon = "nix-snowflake-white";
              sortAlphabetically = true;
            };
          }
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.volume"
                "org.kde.plasma.networkmanagement"
              ];
              hidden = [
                "org.kde.plasma.clipboard"
                "org.kde.plasma.mediacontroller"
              ];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time = {
                format = "24h";
                showSeconds = "never";
              };
              date.enable = true;
            };
          }
        ];
      }

      # Bottom panel — macOS-style dock
      {
        location = "bottom";
        height = 56;
        floating = true;
        hiding = "dodgewindows";
        alignment = "center";
        lengthMode = "fit";
        opacity = "translucent";
        widgets = [
          {
            iconTasks = {
              launchers = [
                "preferred://browser"
                "applications:code.desktop"
                "applications:kitty.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.spectacle.desktop"
                "applications:systemsettings.desktop"
              ];
            };
          }
        ];
      }
    ];

    # ── Keyboard shortcuts (macOS-inspired) ──
    shortcuts = {
      kwin = {
        "Overview" = "Meta+Tab";
        "Window Maximize" = "Meta+Up";
        "Window Minimize" = "Meta+Down";
      };
      "org.kde.krunner.desktop"."_launch" = "Meta+Space";
      ksmserver = {
        "Lock Session" = [ "Screensaver" "Meta+Ctrl+L" ];
      };
    };

    hotkeys.commands."launch-kitty" = {
      name = "Launch Kitty";
      key = "Meta+Return";
      command = "kitty";
    };

    # ── Low-level config ──
    configFile = {
      # Center KRunner on screen (Spotlight-style)
      "krunnerrc"."General"."FreeFloating" = true;
      # Window buttons on left (macOS-style)
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "XIA";
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight" = "";
    };
  };
}
```

**Step 2: Validate file syntax**

Run: `nix-instantiate --parse modules/home-manager/desktop/plasma.nix > /dev/null && echo OK`
Expected: `OK`

**Step 3: Commit**

```bash
git add modules/home-manager/desktop/plasma.nix
git commit -m "feat: add Plasma Home Manager config with macOS-like layout"
```

---

### Task 4: Decouple Desktop from Shared Base

This is the critical structural change. We must ensure no host is left without a desktop.

**Files:**
- Modify: `hosts/common/base.nix` (remove desktop import, line 8)
- Modify: `hosts/common/default.nix` (add desktop import)

**Step 1: Move desktop import from base.nix to default.nix**

In `hosts/common/base.nix`, remove the `profiles/desktop` import. Change:

```nix
  imports = [
    ../../profiles/desktop
  ];
```

To:

```nix
  imports = [
  ];
```

In `hosts/common/default.nix`, add the desktop import. Change:

```nix
  imports = [
    ./base.nix
    ../../modules/core/packages.nix
  ];
```

To:

```nix
  imports = [
    ./base.nix
    ../../profiles/desktop
    ../../modules/core/packages.nix
  ];
```

**Step 2: Verify tech hosts still build**

Run: `nix build .#nixosConfigurations.thinkpad-x1-jacopo.config.system.build.toplevel --dry-run 2>&1 | tail -5`
Expected: Dry-run succeeds (no missing module errors)

**Step 3: Verify business hosts fail (expected — they lost their desktop)**

Run: `nix build .#nixosConfigurations.biz-001.config.system.build.toplevel --dry-run 2>&1 | tail -10`
Expected: Build should still work since base.nix no longer imports desktop, but biz-001 imports `../common/base.nix` which no longer brings in a desktop. No display manager = still builds but no graphical session. This confirms the decoupling.

**Step 4: Commit**

```bash
git add hosts/common/base.nix hosts/common/default.nix
git commit -m "refactor: decouple desktop profile from shared base config

Tech hosts import profiles/desktop via hosts/common/default.nix.
Business hosts will import their own desktop profile directly."
```

---

### Task 5: Wire Business Hosts to Plasma

**Files:**
- Modify: `hosts/biz-001/default.nix`
- Modify: `hosts/biz-002/default.nix`
- Modify: `hosts/biz-003/default.nix`
- Modify: `hosts/biz-004/default.nix`
- Modify: `hosts/business-template/default.nix`

**Step 1: Add Plasma desktop imports to each business host**

For each business host file, add the desktop profile imports. The pattern is the same for all five files. Add these two imports to each host's `imports` list:

```nix
../../profiles/desktop/base.nix
../../profiles/desktop/plasma.nix
```

Example for `hosts/biz-001/default.nix` — change imports from:

```nix
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
    ../../modules/hardware/thinkpad.nix
  ];
```

To:

```nix
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../../profiles/desktop/base.nix
    ../../profiles/desktop/plasma.nix
    ../../modules/business/packages.nix
    ../../modules/business/chrome-extensions.nix
    ../../modules/hardware/thinkpad.nix
  ];
```

Apply the same pattern to biz-002, biz-003, biz-004, and business-template.

**Step 2: Verify a business host evaluates**

Run: `nix build .#nixosConfigurations.biz-001.config.system.build.toplevel --dry-run 2>&1 | tail -5`
Expected: Dry-run succeeds (SDDM + Plasma modules resolved)

**Step 3: Commit**

```bash
git add hosts/biz-001/default.nix hosts/biz-002/default.nix hosts/biz-003/default.nix hosts/biz-004/default.nix hosts/business-template/default.nix
git commit -m "feat: wire business hosts to Plasma 6 desktop profile"
```

---

### Task 6: Wire Business Home Manager to Plasma

**Files:**
- Modify: `modules/business/home-manager/default.nix` (swap gnome.nix for plasma.nix, add plasma-manager import)
- Modify: `flake.nix` (pass plasma-manager HM module to business Home Manager)

**Step 1: Update flake.nix to pass plasma-manager module to business Home Manager**

In `flake.nix`, in the `mkBusinessHost` helper, add plasma-manager's Home Manager module to the Home Manager imports. Change the business Home Manager block from:

```nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username aiProfile; };
            home-manager.users.${username} = import ./modules/business/home-manager;
          }
```

To:

```nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username aiProfile; };
            home-manager.sharedModules = [
              inputs.plasma-manager.homeManagerModules.plasma-manager
            ];
            home-manager.users.${username} = import ./modules/business/home-manager;
          }
```

**Step 2: Swap gnome.nix for plasma.nix in business Home Manager**

In `modules/business/home-manager/default.nix`, change:

```nix
    ../../home-manager/desktop/gnome.nix # GNOME desktop (Dash to Dock)
```

To:

```nix
    ../../home-manager/desktop/plasma.nix # Plasma desktop (macOS-like layout)
```

**Step 3: Validate full config evaluates**

Run: `nix flake check --no-build 2>&1 | head -30`
Expected: No errors (warnings acceptable)

Run: `nix build .#nixosConfigurations.biz-001.config.system.build.toplevel --dry-run 2>&1 | tail -5`
Expected: Dry-run succeeds with Plasma + plasma-manager modules

**Step 4: Verify tech hosts are unaffected**

Run: `nix build .#nixosConfigurations.thinkpad-x1-jacopo.config.system.build.toplevel --dry-run 2>&1 | tail -5`
Expected: Dry-run succeeds (still GNOME, no plasma-manager dependency)

**Step 5: Commit**

```bash
git add flake.nix modules/business/home-manager/default.nix
git commit -m "feat: wire business Home Manager to Plasma with plasma-manager

Business users get macOS-like Plasma layout (top menu bar, bottom dock).
Tech users remain on GNOME, unaffected."
```

---

### Task 7: Full Validation and Final Commit

**Step 1: Run nix flake check**

Run: `nix flake check 2>&1 | tail -20`
Expected: All configurations evaluate without errors

**Step 2: Verify all hosts build (dry-run)**

Run each in sequence:

```bash
nix build .#nixosConfigurations.thinkpad-x1-jacopo.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.tech-001.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.biz-001.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.biz-002.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.biz-003.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.biz-004.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.business-template.config.system.build.toplevel --dry-run
```

Expected: All succeed

**Step 3: Update design doc status**

In `docs/plans/2026-02-26-plasma-business-desktop-design.md`, change:

```
status: draft
```

To:

```
status: active
```

**Step 4: Commit**

```bash
git add docs/plans/2026-02-26-plasma-business-desktop-design.md
git commit -m "docs: mark Plasma business desktop design as active"
```

---

### Post-Implementation Notes

**Testing on real hardware:**
- Rebuild a business host with `sudo nixos-rebuild switch --flake .#biz-001`
- Verify SDDM login screen appears (not GDM)
- Verify Plasma Wayland session loads
- Verify top panel shows global menu + system tray
- Verify bottom dock shows pinned apps
- Verify Meta+Space opens KRunner
- Verify Meta+Return opens Kitty

**Tuning after first boot:**
- Use `rc2nix` tool (`nix run github:nix-community/plasma-manager`) to capture any manual Plasma settings changes back to Nix
- Adjust panel widget order, icon sizes, or launcher list based on user feedback
- Consider `programs.plasma.overrideConfig = true` once config is stable (fully declarative mode)

**Future:**
- Plasma Kiosk mode for lockdown
- Custom SDDM theme
- Wallpaper management via `programs.plasma.workspace.wallpaper`
