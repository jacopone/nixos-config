---
status: active
created: 2024-06-01
updated: 2025-12-18
type: reference
lifecycle: persistent
---

# NixOS for AI-Assisted Development

> Self-documenting NixOS with intelligent permission learning and usage analytics

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
| **Intelligent Permission Learning** | Analyzes 469+ sessions, auto-approves frequent commands, reduces friction |
| **Tool Usage Analytics** | Tracks which tools are used by humans vs AI, identifies dormant packages |
| **MCP Server Optimization** | Monitors server utilization, suggests project-level vs system-level placement |
| **Zero-Drift Documentation** | System state always matches AI knowledge, updated on every rebuild |
| **Adaptive Suggestions** | Recommends permission patterns, tool additions, configuration improvements |

## How It Works

The intelligence comes from [claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation):

```
./rebuild-nixos
    │
    ├─→ Parses Nix config → extracts 145 tools with descriptions
    ├─→ Analyzes Claude Code usage → learns permission patterns
    ├─→ Tracks tool usage → human vs AI over 30 days
    ├─→ Generates suggestions → permission auto-approvals, dormant cleanup
    └─→ Updates CLAUDE.md → full system context for AI
```

**Result**: Claude Code that learns your workflow and gets smarter with every session.

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
- **Antigravity** - Google's next-gen agentic IDE
- **Cursor** - AI editor with quality gates
- **Gemini CLI / Jules / Droid** - AI coding agents
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

**AI Tools**: `claude-code`, `antigravity`, `cursor`, `opencode`, `gemini-cli`, `jules`, `droid`, `serena`, `mcp-nixos`, `openspec`, `whisper-cpp`

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

| Repository | What It Does |
|------------|--------------|
| **[nixos-config](https://github.com/jacopone/nixos-config)** | System configuration + rebuild orchestration |
| **[claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation)** | **The brain**: Permission learning, usage analytics, intelligent suggestions, CLAUDE.md generation |

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
