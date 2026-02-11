---
status: active
created: 2024-06-01
updated: 2026-02-10
type: reference
lifecycle: persistent
---

# Intelligent Permission Learning for Claude Code

> Your NixOS system learns which commands to auto-approve, reducing friction without compromising security

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Claude Code](https://img.shields.io/badge/Claude-Code-5A67D8.svg?style=flat-square&logo=anthropic)](https://claude.ai)
[![License](https://img.shields.io/github/license/jacopone/nixos-config?style=flat-square)](LICENSE)

## The Problem

Every Claude Code session:

```
Allow "git status"? [y/n]
Allow "fd -e py"? [y/n]
Allow "rg TODO"? [y/n]
... 47 more prompts ...
```

**Your options:**
1. Click approve 50+ times per session (tedious)
2. Use `--dangerously-skip-permissions` (security nightmare)
3. Manually maintain permission configs (never stays current)

**This project adds Option 4:** Let your system learn what's safe.

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│  YOUR WORKFLOW                                                  │
│                                                                 │
│  You approve "git status" → System logs it                      │
│  You approve "fd -e nix" → System logs it                       │
│  You approve "rg pattern" → System logs it                      │
│         ...approvals across sessions and projects...            │
│                                                                 │
│  ./rebuild-nixos runs → Adaptive learning with TIER ROUTING     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ TIER_1_SAFE detected: "git status", "fd", "rg", "cat"   │   │
│  │ → Added to ~/.claude/settings.json (GLOBAL)             │   │
│  │                                                         │   │
│  │ TIER_2_MODERATE detected: "git push", "npm install"     │   │
│  │ → Added to .claude/settings.local.json (per-project)    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Next session (ANY project): "fd -e py" → Auto-approved.        │
└─────────────────────────────────────────────────────────────────┘
```

**Result:** Read-only tools are learned once and applied globally. Write operations stay per-project for safety.

## Key Features

### 1. Adaptive Permission Learning with Tier Routing

The system analyzes your approval history and routes rules by tier:

| Tier | Destination | Examples |
|------|-------------|----------|
| **TIER_1_SAFE** | `~/.claude/settings.json` (global) | git status, fd, rg, cat, pytest |
| **TIER_2_MODERATE** | `.claude/settings.local.json` | git push, npm, nix build |
| **TIER_3_RISKY** | `.claude/settings.local.json` | git --force, sudo |
| **CROSS_FOLDER** | `~/.claude/settings.json` (global) | Tools used in 2+ projects |

- **Pattern detection** from actual behavior (not guesswork)
- **Tier classification** determines global vs per-project routing
- **Cross-folder promotion** - tools used across projects become global
- **Audit trail** in `.claude/permissions_auto_generated.md`

```bash
./rebuild-nixos
# Step 6/6: Adaptive learning
# TIER_1_SAFE (→ global): fd, rg, bat, cat, pytest
# TIER_2_MODERATE (→ per-project): git push, npm install
# Apply these? [y/n/review each]
```

### 2. Zero-Drift Documentation

System state automatically syncs to Claude's knowledge:

```
packages.nix changes → ./rebuild-nixos → CLAUDE.md updated
```

- **No manual docs** to maintain
- **Every tool** extracted with descriptions
- **Always current** - impossible to drift

### 3. Ephemeral Testing (NixOS-Specific)

Test anything without polluting your system:

```bash
# Test with pytest without installing it globally
nix shell nixpkgs#pytest --command pytest tests/

# Enter a reproducible dev environment
nix develop

# Exit → system unchanged. No cleanup needed.
```

**Why this matters:**
- macOS: `pip install pytest` → permanent system change
- Ubuntu: `apt install python3-pytest` → permanent system change
- NixOS: `nix shell` → temporary, atomic, reversible

### 4. Usage Analytics

Data-driven decisions about your tools:

```
Tool Usage Report (30 days)
──────────────────────────────────────
Installed: 131 tools
Used: 34 (26%)
Dormant: 97 tools (candidates for removal)

Top tools (Human vs Claude):
  git     H:28  C:989
  fd      H:0   C:152
  rg      H:0   C:100
```

## Why NixOS?

This system requires NixOS because:

| Capability | NixOS | macOS/Ubuntu |
|------------|-------|--------------|
| Atomic rebuilds | Switch or rollback completely | Partial state changes |
| Reproducible environments | `flake.lock` pins exact versions | "Works on my machine" |
| Ephemeral shells | `nix shell` - test without installing | Every install is permanent |
| Declarative config | Single source of truth | Scattered across dotfiles |
| Pure derivations | Same inputs = same outputs | Build depends on system state |

## Quick Start

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config
./rebuild-nixos
```

**Requirements:** NixOS with Flakes enabled, 8GB+ RAM
**Time:** ~20 minutes first build

**[Full Installation Guide →](INSTALL.md)**

## The Ecosystem

| Repository | Purpose |
|------------|---------|
| [nixos-config](https://github.com/jacopone/nixos-config) | System config + `rebuild-nixos` orchestration + sandboxing |
| [claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation) | **The brain:** Tier-based permission routing, global/local learning, analytics |

## How It Differs from Alternatives

| Feature | This Project | mcp-nixos | nixai | Manual Config |
|---------|-------------|-----------|-------|---------------|
| **Tier-based routing** | Global + per-project | - | - | - |
| **Cross-folder detection** | Auto-promote to global | - | - | - |
| Permission auto-learning | From behavior | - | - | - |
| Sandboxing | Anthropic srt (official) | - | - | - |
| Zero-drift docs | Automatic | - | - | Manual |
| Ephemeral testing | Nix shells | N/A | - | - |
| Tool analytics | H vs C usage | - | - | - |
| NixOS package info | Via automation | MCP | Yes | - |

## What's Included

<details>
<summary><strong>Tech Profile — Full Power-User Stack (350+ tools)</strong></summary>

**Replacements for POSIX defaults:**
| Old | New | Why |
|-----|-----|-----|
| `find` | `fd` | 5x faster, better syntax |
| `ls` | `eza` | Icons, git status |
| `cat` | `bat` | Syntax highlighting |
| `grep` | `rg` | 10x faster |
| `du` | `dust` | Visual, interactive |

**AI Development:**
- Claude Code, Cursor, Antigravity, Gemini CLI, Jules, Droid
- Anthropic [sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) (srt) for isolated execution
- VibeTyper, Whisper speech-to-text

**Development:**
- DevEnv, Direnv, Fish shell (60+ abbreviations), Kitty terminal, GNOME (Wayland)
- Yazi file manager, rclone Google Drive mount, full atuin integration

See [`modules/core/packages.nix`](modules/core/packages.nix) for the complete list.

</details>

<details>
<summary><strong>Business Profile — Office + Learning to Code (~40 tools)</strong></summary>

**Essentials:** VS Code, Google Chrome, OnlyOffice, Claude Code

**Modern CLI:** eza, fd, bat, ripgrep, fzf, jq, glow, pandoc

**Dev Runtimes:** Node.js 20, Python 3 (pytest, pydantic), GCC, Make

**Infrastructure:** Docker Compose, direnv, devenv, cachix

**Shell:** Fish with context-aware smart commands (same as tech, simplified abbreviations), Kitty, Starship prompt

See [`modules/business/packages.nix`](modules/business/packages.nix) for the complete list.

</details>

## Multi-Host Architecture

This configuration supports multiple machines and role-based profiles from a single repository. A shared base (`hosts/common/base.nix`) provides the universal foundation, while two symmetric helpers build profile-specific hosts:

```
                    hosts/common/base.nix
                    (bootloader, nix, locale, GNOME, Docker...)
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
     mkTechHost(...)           mkBusinessHost(...)
              │                         │
   modules/core/packages.nix   modules/business/packages.nix
   modules/home-manager/       modules/business/home-manager/
   (350+ packages, full        (~40 packages, simplified
    power-user setup)           office + learning-to-code)
```

### Current Hosts

| Host | Profile | Hardware | Build Command |
|------|---------|----------|---------------|
| `thinkpad-x1-jacopo` | Tech | ThinkPad X1 Carbon (Intel) | `nixos-rebuild switch --flake .#thinkpad-x1-jacopo` |
| `framework-16-jacopo` | Tech | Framework 16 (AMD + NVIDIA RTX 5070) | `nixos-rebuild switch --flake .#framework-16-jacopo` |
| `business-template` | Business | Template (copy for new deployments) | `nixos-rebuild switch --flake .#business-template` |

Hostnames follow the `model-user` convention for company asset identification.

### Adding a Tech Host
1. Create `hosts/<hostname>/default.nix` importing `../common` + hardware module
2. Generate `hardware-configuration.nix` on the machine
3. Add entry to `flake.nix`: `model-user = mkTechHost { hostname = "model-user"; username = "user"; };`

### Deploying a Business Host
1. Copy the template: `cp -r hosts/business-template hosts/<hostname>`
2. Generate hardware config on the target machine: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
3. Edit `hosts/<hostname>/default.nix` to set hostname
4. Add to `flake.nix`: `model-user = mkBusinessHost { hostname = "model-user"; username = "user"; };`
5. Build: `sudo nixos-rebuild switch --flake .#<hostname>`

The `nixos-hardware` flake provides vendor-specific optimizations (Framework LED Matrix support, NVIDIA PRIME, AMD power management).

## Repository Structure

```
nixos-config/
├── flake.nix                      # Entry point + mkTechHost/mkBusinessHost helpers
├── rebuild-nixos                  # Multi-phase rebuild with learning
├── .github/workflows/test.yml     # CI: shellcheck + BATS tests
├── hosts/
│   ├── common/
│   │   ├── base.nix               # Universal base (bootloader, nix, locale, Docker...)
│   │   └── default.nix            # Tech profile (extends base + 350+ packages)
│   ├── thinkpad-x1-jacopo/         # ThinkPad X1 host (Jacopo)
│   ├── framework-16-jacopo/        # Framework 16 host (Jacopo)
│   └── business-template/         # Template for new business deployments
│       ├── default.nix
│       └── hardware-configuration.nix  # Placeholder (replace per machine)
├── modules/
│   ├── core/packages.nix          # Tech system tools (350+)
│   ├── business/                  # Business profile modules
│   │   ├── packages.nix           # Curated business tools (~40)
│   │   ├── chrome-extensions.nix  # Minimal Chrome extensions
│   │   └── home-manager/          # Business Home Manager config
│   │       ├── default.nix        # Entry point (reuses kitty, starship, tools)
│   │       └── fish.nix           # Simplified Fish shell
│   ├── hardware/                  # Hardware-specific modules
│   └── home-manager/              # Tech Home Manager config (full)
├── tests/bash/                    # BATS unit tests for shell scripts
├── profiles/desktop/              # Desktop environment (GNOME)
├── CLAUDE.md                      # Auto-generated AI context
└── .claude/
    ├── settings.local.json        # Per-project permissions (TIER_2/3)
    └── permissions_auto_generated.md  # Audit trail

~/.claude/
├── settings.json                  # Global permissions (TIER_1_SAFE)
└── CLAUDE.md                      # System-wide AI context
```

## Essential Commands

```bash
# Full rebuild with security checks and permission learning
./rebuild-nixos

# Quick rebuild (skip security checks - fastest for iterations)
./rebuild-nixos --quick --yes    # or: ./rebuild-nixos -q -y

# Fresh rebuild (bypass eval-cache when changes seem ignored)
./rebuild-nixos --fresh          # or: ./rebuild-nixos -f

# Validate configuration syntax
nix flake check

# Build specific host
sudo nixos-rebuild switch --flake .#thinkpad-x1-jacopo   # ThinkPad (tech)
sudo nixos-rebuild switch --flake .#framework-16-jacopo  # Framework 16 (tech)
sudo nixos-rebuild switch --flake .#business-template    # Business workstation

# Ephemeral testing
nix shell nixpkgs#python312 --command python
```

**rebuild-nixos flags:**

| Flag | Short | Description |
|------|-------|-------------|
| `--quick` | `-q` | Skip security checks and cleanup (fastest) |
| `--yes` | `-y` | Auto-accept all prompts (non-interactive) |
| `--fresh` | `-f` | Bypass eval-cache (use when changes seem ignored) |
| `--verbose` | `-v` | Show detailed build output |
| `--dry-run` | `-n` | Preview changes without applying |
| `--audit` | `-a` | Export source closure for forensic audit |

## Testing

The repository includes automated testing for shell scripts and CI validation:

```bash
# Run all tests (shellcheck + BATS)
test-all

# Shell script linting only
lint-bash

# BATS unit tests only
test-bash
```

**Test coverage:**
- **Shellcheck** - Static analysis for `rebuild-nixos` and `scripts/*.sh`
- **BATS** - Unit tests for pipefail protection, input parsing, script structure
- **CI** - GitHub Actions runs all tests on push/PR to `personal` and `master` branches

Tests are located in `tests/bash/` with helper utilities in `tests/bash/helpers/`.

## Sandboxed Claude Code

For autonomous tasks, use Anthropic's official [sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) (srt):

```bash
# Run Claude in sandbox (srt is installed system-wide)
srt claude ~/my-project

# With custom settings
srt --settings ~/.srt-settings.json claude ~/my-project
```

Configure `~/.srt-settings.json` for domain filtering and filesystem restrictions:

```json
{
  "network": {
    "allowedDomains": ["api.anthropic.com", "github.com", "*.npmjs.org"]
  },
  "filesystem": {
    "allowWrite": [".", "/tmp", "~/.claude"],
    "denyRead": ["~/.ssh", "~/.gnupg", "~/.aws/credentials"]
  }
}
```

**Security features:**
- Domain-level network filtering (not just all-or-nothing)
- Mandatory protection for sensitive files (.ssh, .gitconfig, etc.)
- Linux: bubblewrap namespace isolation + seccomp BPF
- macOS: Seatbelt sandbox profiles
- Spawned processes inherit sandbox (kernel-enforced)

## Documentation

| Guide | Description |
|-------|-------------|
| [INSTALL.md](INSTALL.md) | Full installation and setup |
| [THE_CLOSED_LOOP.md](docs/architecture/THE_CLOSED_LOOP.md) | How auto-documentation works |
| [COMMON_TASKS.md](docs/guides/COMMON_TASKS.md) | Quick reference for daily use |
| [test.yml](.github/workflows/test.yml) | CI workflow for automated testing |

## Contributing

This is a personal configuration shared for learning and inspiration.

- **Fork** and adapt for your setup
- **Star** if you find it useful
- **Issues** for bugs or suggestions

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

[MIT License](LICENSE)

---

<div align="center">

**Permission learning that gets smarter with every session**

[Quick Start](#quick-start) · [Documentation](#documentation) · [Report Issue](https://github.com/jacopone/nixos-config/issues)

</div>
