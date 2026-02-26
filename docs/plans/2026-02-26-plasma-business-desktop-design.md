---
status: draft
created: 2026-02-26
updated: 2026-02-26
type: planning
lifecycle: persistent
---

# KDE Plasma 6 for Business Hosts

## Status: Active

## Context

Business hosts (biz-001 through biz-004) run GNOME on Wayland. GNOME uses ~600MB-1GB RAM at idle, which is significant on the 8GB MacBook Air T2 (biz-003) and the 4-8GB MacBook Air 2015 (biz-004). KDE Plasma 6 uses ~400-600MB at idle with mature Wayland support and a familiar desktop paradigm.

## Decision

Replace GNOME with KDE Plasma 6 on all business hosts. Tech hosts remain on GNOME.

## Goals

- Reduce desktop RAM overhead by ~200-400MB on business machines
- Maintain macOS-like UX (bottom dock, top menu bar) consistent with prior GNOME Dash to Dock setup
- Enable future lockdown via Plasma Kiosk features
- Architect the change so tech hosts can optionally adopt Plasma later

## Architecture

### Decouple Desktop from Shared Base

`hosts/common/base.nix` currently imports `profiles/desktop` which hardcodes GNOME for all hosts. Fix:

1. Remove `../../profiles/desktop` from `hosts/common/base.nix`
2. Add `../../profiles/desktop` to `hosts/common/default.nix` (tech path keeps GNOME)
3. Business hosts import `profiles/desktop/base.nix` + `profiles/desktop/plasma.nix`

### New Files

**`profiles/desktop/plasma.nix`** — System-level Plasma config:
- `services.desktopManager.plasma6.enable = true`
- `services.displayManager.sddm.enable = true` with Wayland
- Exclude Plasma bloat (KMail, Kontact, KOrganize, etc.)
- Keep: Dolphin, Spectacle, System Settings
- XDG portals: `xdg-desktop-portal-kde`

**`modules/home-manager/desktop/plasma.nix`** — User-level macOS layout:
- Bottom dock panel: icon-only task manager with pinned apps (Chrome, VS Code, Kitty, Dolphin)
- Top panel: global menu bar, clock, system tray (WiFi, battery, volume)
- KRunner as Spotlight-style launcher (`Alt+Space`)
- Breeze window decorations with standard title bar buttons
- Breeze Dark theme or macOS-inspired theme

### Modified Files

| File | Change |
|------|--------|
| `hosts/common/base.nix` | Remove `../../profiles/desktop` import |
| `hosts/common/default.nix` | Add `../../profiles/desktop` import |
| `modules/business/home-manager/default.nix` | Swap `gnome.nix` for `plasma.nix` |
| `hosts/biz-001/default.nix` | Add `profiles/desktop/base.nix` + `profiles/desktop/plasma.nix` imports |
| `hosts/biz-002/default.nix` | Add `profiles/desktop/base.nix` + `profiles/desktop/plasma.nix` imports |
| `hosts/biz-003/default.nix` | Add `profiles/desktop/base.nix` + `profiles/desktop/plasma.nix` imports |
| `hosts/biz-004/default.nix` | Add `profiles/desktop/base.nix` + `profiles/desktop/plasma.nix` imports |
| `hosts/business-template/default.nix` | Add `profiles/desktop/base.nix` + `profiles/desktop/plasma.nix` imports |

### Unchanged

- Tech hosts (mkTechHost) — still GNOME, unaffected
- `profiles/desktop/base.nix` — PipeWire, fonts, Bluetooth (shared by both desktops)
- `profiles/desktop/gnome.nix` — untouched, still used by tech hosts
- Kitty, Starship, Fish, dev tools — desktop-agnostic
- Business installer ISO — keeps GNOME (installation only)
- Chrome extensions, AI profile system — unchanged

## Hardware Context

| Host | Hardware | RAM | Desktop |
|------|----------|-----|---------|
| tech-001 | Framework 16 (Ryzen AI 9 + RTX 5070) | 64GB | GNOME (unchanged) |
| thinkpad-x1-jacopo | ThinkPad X1 Carbon | 8-16GB | GNOME (unchanged) |
| biz-001 | ThinkPad X1 Carbon | 8-16GB | GNOME → Plasma |
| biz-002 | HP workstation (Pietro) | unknown | GNOME → Plasma |
| biz-003 | MacBook Air 2018 T2 | 8GB | GNOME → Plasma |
| biz-004 | MacBook Air 2015 7,2 | 4-8GB | GNOME → Plasma |

## Future Considerations

- Plasma Kiosk mode can restrict panel editing, System Settings access, and widget modification
- Tech hosts can adopt Plasma later by swapping the profile import
- A `desktop` parameter on host helpers would formalize the choice but is not needed until both profiles are used by both host types
