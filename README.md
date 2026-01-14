---
status: active
created: 2024-06-01
updated: 2026-01-14
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
<summary><strong>Modern CLI Stack (130+ tools)</strong></summary>

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

**Development:**
- DevEnv, Direnv, Fish shell, Kitty terminal, GNOME (Wayland)

See [`modules/core/packages.nix`](modules/core/packages.nix) for the complete list.

</details>

## Multi-Host Architecture

This configuration supports multiple machines from a single repository. Each host shares the same packages, profiles, and home-manager config—only hardware differs.

| Host | Hardware | Build Command |
|------|----------|---------------|
| `nixos` | ThinkPad X1 (Intel) | `nixos-rebuild switch --flake .#nixos` |
| `framework-16` | Framework 16 (AMD + NVIDIA RTX 5070) | `nixos-rebuild switch --flake .#framework-16` |

**Adding a new host:**
1. Create `hosts/<hostname>/default.nix` importing `../common` + hardware module
2. Generate `hardware-configuration.nix` on the machine
3. Add entry to `flake.nix` using the `mkHost` helper

The `nixos-hardware` flake provides vendor-specific optimizations (Framework LED Matrix support, NVIDIA PRIME, AMD power management).

## Repository Structure

```
nixos-config/
├── flake.nix                      # Main entry point + mkHost helper
├── rebuild-nixos                  # Multi-phase rebuild with learning
├── hosts/
│   ├── common/default.nix         # Shared config (locale, users, packages)
│   ├── nixos/                     # ThinkPad X1 host
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── framework-16/              # Framework 16 host
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── core/packages.nix          # System tools (130+)
│   ├── hardware/                  # Hardware-specific modules
│   │   ├── thinkpad.nix           # Intel GPU, TLP power management
│   │   └── framework-16.nix       # AMD/NVIDIA hybrid, LED Matrix
│   └── home-manager/              # User configurations
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
sudo nixos-rebuild switch --flake .#nixos        # ThinkPad
sudo nixos-rebuild switch --flake .#framework-16 # Framework 16

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
