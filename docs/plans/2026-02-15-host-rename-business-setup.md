---
status: draft
created: 2026-02-15
updated: 2026-02-15
type: planning
lifecycle: ephemeral
---

# Host Renaming and Business ThinkPad Setup

## Goal

Migrate all hosts to asset-tag naming convention (`type-NNN`) and prepare
the ThinkPad X1 Carbon for conversion from tech to business profile.

## Naming Convention

Format: `type-NNN` where type is `biz` or `tech`, NNN is zero-padded sequential.

| Machine | Old Hostname | New Hostname | Username | Profile |
|---------|-------------|-------------|----------|---------|
| Framework 16 | `framework-16-jacopo` | `tech-001` | `guyfawkes` | mkTechHost |
| ThinkPad X1 (current) | `thinkpad-x1-jacopo` | kept temporarily | `guyfawkes` | mkTechHost |
| ThinkPad X1 (after format) | — | `biz-001` | `guyfawkes` | mkBusinessHost |
| HP workstation | `hp-pietro` | `biz-002` | `pietro` | mkBusinessHost |
| Template | `business-template` | unchanged | `user` | mkBusinessHost |

## Execution Sequence

1. Rename `hosts/framework-16-jacopo/` to `hosts/tech-001/`, update hostName
2. Rename `hosts/hp-pietro/` to `hosts/biz-002/`, update hostName
3. Create `hosts/biz-001/` with business profile for ThinkPad X1 hardware
4. Update `flake.nix` with new entries; keep `thinkpad-x1-jacopo` as safety net
5. Run `nix flake check` to validate
6. Commit and push

## Transition Plan

- ThinkPad stays on `thinkpad-x1-jacopo` config until formatted
- Framework rebuilds as `tech-001` (becomes primary tech machine)
- After Framework is set up: format ThinkPad, fresh NixOS install, build as `biz-001`
- After `biz-001` is live: delete `thinkpad-x1-jacopo` entry and host directory

## File Changes

### Renamed (git mv)

- `hosts/framework-16-jacopo/` -> `hosts/tech-001/`
- `hosts/hp-pietro/` -> `hosts/biz-002/`

### Created

- `hosts/biz-001/default.nix` — business profile, imports:
  - `./hardware-configuration.nix`
  - `../common/base.nix`
  - `../../modules/business/packages.nix`
  - `../../modules/business/chrome-extensions.nix`
  - `../../modules/hardware/thinkpad.nix`
- `hosts/biz-001/hardware-configuration.nix` — copied from thinkpad-x1-jacopo (placeholder, replace after fresh install)

### Edited

- `hosts/tech-001/default.nix` — hostName to "tech-001"
- `hosts/biz-002/default.nix` — hostName to "biz-002"
- `flake.nix` — new entries for tech-001, biz-001, biz-002

### Untouched

- `hosts/thinkpad-x1-jacopo/` — kept until after format
- `hosts/business-template/` — copy-paste template
- `hosts/common/` — base.nix and default.nix unchanged
- All modules, profiles, overlays unchanged

### Deleted (later)

- `hosts/thinkpad-x1-jacopo/` and its flake.nix entry (after biz-001 is live)

## Notes

- Hostnames use hyphens only (no underscores) per RFC 1123
- Username is personal choice, not tied to hostname convention
- `rebuild-nixos` may need manual `--flake .#tech-001` on first rebuild after rename
- Business installer ISO unchanged
