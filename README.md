---
status: active
created: 2024-06-01
updated: 2025-12-18
type: reference
lifecycle: persistent
---

# NixOS for AI-Assisted Development

> A self-documenting system that keeps Claude Code synchronized with your tools

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat-square&logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-orange.svg?style=flat-square)](https://github.com/nix-community/home-manager)
[![Claude Code](https://img.shields.io/badge/Claude-Code-5A67D8.svg?style=flat-square&logo=anthropic)](https://claude.ai)
[![License](https://img.shields.io/github/license/jacopone/nixos-config?style=flat-square)](LICENSE)

## The Problem

"Claude, use `fd` instead of `find`"
"Claude, I have `bat` installed, stop suggesting `cat`"
"Claude, my system has `ripgrep`..."

**Stop explaining your environment every session.**

## The Solution

This NixOS configuration closes the loop: **System state → Documentation → AI knowledge**

```bash
./rebuild-nixos

# What happens automatically:
# ✅ System rebuilds with your changes
# ✅ Parses 145 tools from your Nix config
# ✅ Generates CLAUDE.md with tool inventory
# ✅ Updates AI context for all future sessions
```

**Result**: Claude Code automatically uses `fd`, `bat`, `rg`, and 142 other modern tools correctly—every session.

![Demo: Rebuild updates AI knowledge](docs/assets/rebuild-demo.gif)

## Quick Start

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config
./rebuild-nixos
```

**Requirements**: NixOS with Flakes enabled, 8GB+ RAM
**Time**: ~20 minutes first build

**[Full Installation Guide →](INSTALL.md)**

## Key Features

| Feature | Description |
|---------|-------------|
| **Closed-Loop Automation** | System changes automatically update AI knowledge. Your NixOS config is the source of truth. |
| **145 Curated Tools** | Modern CLI stack: `fd`, `eza`, `bat`, `rg`, `dust`, `procs`, and 139 more. |
| **Zero Configuration Drift** | AI always sees current system state. Install a tool, rebuild, AI knows instantly. |
| **Adaptive Learning** | Detects usage patterns, auto-approves frequent permissions, optimizes MCP servers. |
| **Performance Optimized** | Parallel analyzers, 2.5s faster rebuilds, battle-tested over 6 months. |

## What's Included

### Modern CLI Stack (replaces POSIX defaults)

| Old | New | Improvement |
|-----|-----|-------------|
| `find` | `fd` | 5x faster, friendlier syntax |
| `ls` | `eza` | Icons, git status, tree view |
| `cat` | `bat` | Syntax highlighting, git diffs |
| `grep` | `rg` | 10x faster, smart defaults |
| `du` | `dust` | Visual, interactive |
| `ps` | `procs` | Modern output, filtering |

### AI Development Tools

- **Claude Code** - Anthropic's CLI with auto-sync
- **Cursor** - AI editor with quality gates
- **Aider** - AI pair programming
- **Serena MCP** - Semantic code analysis

### Development Environment

- **DevEnv + Direnv** - Per-project environments
- **Fish shell** - Smart completions, context detection
- **Kitty terminal** - GPU-accelerated, optimized
- **GNOME (Wayland)** - Minimal, stable desktop

<details>
<summary><strong>Full Tool List (145 tools)</strong></summary>

**File Operations**: `fd`, `eza`, `bat`, `rg`, `dust`, `dua`, `broot`, `fzf`, `zoxide`, `yazi`

**Development**: `git`, `gh`, `delta`, `lazygit`, `devenv`, `direnv`, `just`

**Editors**: `helix`, `zed-editor`, `vscode-fhs`, `cursor`

**Languages**: `nodejs_20`, `python312`, `gcc`, `gnumake`

**Data**: `jq`, `yq-go`, `csvkit`, `miller`, `jless`, `choose`

**Monitoring**: `procs`, `bottom`, `htop`, `hyperfine`

**Quality**: `shellcheck`, `shfmt`, `ruff`, `semgrep`, `tokei`, `lizard`

**AI Tools**: `claude-code`, `cursor`, `aider`, `gemini-cli`, `serena`, `mcp-nixos`

See [`modules/core/packages.nix`](modules/core/packages.nix) for the complete list.

</details>

## Essential Commands

```bash
# System
./rebuild-nixos              # Interactive rebuild (recommended)
nix flake check              # Validate configuration

# Modern tools (automatic substitutions)
cat file.py                  # → bat (syntax highlighting)
ls                           # → eza (icons + git status)
find . -name "*.nix"         # → fd (faster)

# Development
devenv shell                 # Enter project environment
yazi                         # Terminal file manager
```

## Documentation

| Guide | Description |
|-------|-------------|
| [INSTALL.md](INSTALL.md) | Full installation and setup |
| [THE_CLOSED_LOOP.md](docs/THE_CLOSED_LOOP.md) | How auto-documentation works |
| [COMMON_TASKS.md](docs/guides/COMMON_TASKS.md) | Quick reference for daily use |
| [enhanced-tools-guide.md](docs/tools/enhanced-tools-guide.md) | Modern CLI tools deep dive |

## Ecosystem

| Repository | Purpose |
|------------|---------|
| **[nixos-config](https://github.com/jacopone/nixos-config)** | This repo - main system config |
| **[claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation)** | Auto-generate CLAUDE.md from configs |

## Repository Structure

```
nixos-config/
├── flake.nix                      # Main entry point
├── rebuild-nixos                  # Interactive rebuild script
├── hosts/nixos/                   # Host-specific config
├── modules/
│   ├── core/packages.nix          # 145 system tools
│   └── home-manager/base.nix      # User configurations
├── profiles/desktop/              # GNOME setup
├── docs/                          # Guides and references
└── CLAUDE.md                      # Auto-generated AI context
```

## Contributing

This is a personal configuration shared for learning and inspiration.

- **Fork** and adapt for your setup
- **Star** if you find it useful
- **Issues** for bugs or suggestions
- **Discussions** for questions

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

[MIT License](LICENSE) - Use freely, modify, distribute, learn from it.

---

<div align="center">

**Built over 6 months of daily use** · *NixOS meets AI-assisted development*

[Quick Start](#quick-start) · [Documentation](#documentation) · [Report Issue](https://github.com/jacopone/nixos-config/issues)

</div>
