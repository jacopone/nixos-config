---
status: active
created: 2024-06-01
updated: 2025-10-23
type: reference
lifecycle: persistent
---

# 🤖 NixOS for AI-Assisted Development

> A self-documenting system that keeps Claude Code automatically synchronized with your tools

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat-square&logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-orange.svg?style=flat-square)](https://github.com/nix-community/home-manager)
[![Claude Code](https://img.shields.io/badge/Claude-Code-5A67D8.svg?style=flat-square&logo=anthropic)](https://claude.ai)
[![AI Optimized](https://img.shields.io/badge/AI-Optimized-brightgreen.svg?style=flat-square)](https://github.com/jacopone/claude-nixos-automation)

## The Problem

"Claude, use `fd` instead of `find`"
"Claude, I have `bat` installed, stop suggesting `cat`"
"Claude, my system has `ripgrep`..."

**Stop explaining your environment every session.**

## The Solution

This NixOS configuration closes the loop: **System state → Documentation → AI knowledge**

Every system rebuild automatically updates Claude Code's tool knowledge. No manual documentation. No drift. No repetition.

```bash
./rebuild-nixos

# What happens automatically:
# ✅ System rebuilds with your changes
# ✅ Parses 122 tools from your Nix config
# ✅ Generates CLAUDE.md with tool inventory
# ✅ Updates AI context for all future sessions
# ✅ Runs adaptive learning (pattern detection)
# ✅ Optimizes performance (2.5s faster builds)
```

> **Result**: Claude Code automatically uses `fd`, `bat`, `rg`, and 119 other modern tools correctly—every single session.

<!-- TODO: Add demo GIF showing rebuild → auto-update → AI using correct tools -->

## ✨ Key Features

🔄 **Closed-Loop Automation**
System changes automatically update AI knowledge. Your NixOS config is the source of truth.

⚡ **Performance Optimized**
Adaptive learning with parallel analyzers. Recent improvements: 2.5s faster rebuilds.

🧠 **Intelligent Learning**
Detects usage patterns, auto-approves frequent permissions, optimizes MCP servers.

🛠️ **122 Curated Tools**
Modern CLI stack for AI development: `fd`, `eza`, `bat`, `rg`, `dust`, `procs`, and 116 more.

🎯 **Zero Configuration Drift**
AI always sees current system state. Install a tool, rebuild, AI knows instantly.

📊 **Battle-Tested**
Built over 6 months. 469+ AI coding sessions analyzed. Daily driver for agentic development.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config

# Interactive rebuild (handles hardware detection, user setup)
./rebuild-nixos
```

That's it! The script walks you through customization interactively.

**Requirements**: Fresh NixOS install, Flakes enabled, 8GB+ RAM
**Time**: ~20 minutes first build
**Result**: AI-optimized NixOS with 122 tools

<details>
<summary>📋 Detailed Installation Guide</summary>

### Prerequisites

- Fresh NixOS installation (minimal or desktop)
- Flakes enabled: `nix.settings.experimental-features = [ "nix-command" "flakes" ]`
- 8GB RAM minimum (16GB recommended)
- Internet connection for package downloads

### Step-by-Step

1. **Clone the repository**
   ```bash
   git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
   cd ~/nixos-config
   ```

2. **Generate hardware configuration**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
   ```

3. **Customize username**
   ```bash
   # Update username throughout the config
   sed -i 's/guyfawkes/yourusername/g' flake.nix hosts/nixos/default.nix
   ```

4. **Apply configuration**
   ```bash
   ./rebuild-nixos
   ```

The script will:
- Test build without activation (catches errors)
- Prompt for confirmation before applying
- Update Claude Code configurations automatically
- Offer to commit changes to git
- Display rollback instructions if needed

### Troubleshooting

**Build fails?**
```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

**Memory issues?**
```bash
# Reduce build parallelism
sudo nixos-rebuild switch --flake . --cores 2 --max-jobs 1
```

**EFI vs BIOS?**
```nix
# For EFI (most modern computers) - in hosts/nixos/default.nix:
boot.loader.systemd-boot.enable = true;

# For BIOS (older computers):
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";
```

</details>

## 💡 Why This Matters

### Before: Manual Documentation
- Install tools manually
- Try to remember all capabilities
- Explain environment every Claude session
- Documentation drifts out of sync
- AI suggests outdated commands

### After: Automated Synchronization
- Declare packages in `packages.nix`
- Run `./rebuild-nixos` once
- Claude Code learns automatically
- Zero maintenance overhead
- AI uses modern tools correctly

### Real Impact

**Time savings**: No more copy-pasting tool lists or explaining your environment
**Consistency**: Every session starts with correct tool knowledge
**Performance**: 2.5s faster rebuilds with adaptive learning
**Intelligence**: System learns from 469+ sessions to optimize itself

## 🛠️ What's Included

### Modern CLI Stack
Replace old POSIX commands automatically:
- `fd` → blazing fast file search (replaces `find`)
- `eza` → enhanced listings with icons (replaces `ls`)
- `bat` → syntax-highlighted viewing (replaces `cat`)
- `rg` → ultra-fast text search (replaces `grep`)
- `dust` → interactive disk usage (replaces `du`)
- `procs` → modern process viewer (replaces `ps`)

### AI Development Tools
- **Claude Code** - Anthropic's official CLI with auto-sync
- **Cursor** - AI-powered editor with quality gates
- **Aider** - AI pair programming in terminal
- **Serena MCP** - Semantic code analysis
- **Node.js 20 + Python 3.12** - Pre-installed runtimes

### Development Environment
- **DevEnv + Direnv** - Per-project environments
- **Git + GitHub CLI** - Enhanced diffs with `delta`
- **Multiple editors** - Helix, Zed, VSCode
- **Quality tools** - ShellCheck, Ruff, Semgrep

### Desktop Environment
- **GNOME (Wayland)** with minimal bloat
- **Kitty terminal** optimized for coding
- **Fish shell** with smart command substitutions
- **Starship prompt** with git status

<details>
<summary>📦 Complete Tool List (122 total)</summary>

### File Operations & Search
`fd`, `eza`, `bat`, `rg`, `dust`, `dua`, `broot`, `fzf`, `zoxide`, `yazi`

### Development
`git`, `gh`, `delta`, `lazygit`, `gitui`, `devenv`, `direnv`, `just`

### Editors & IDEs
`helix`, `zed-editor`, `vscode-fhs`, `cursor`

### Languages & Runtimes
`nodejs_20`, `python312`, `gcc`, `gnumake`, `pkg-config`

### Data Processing
`jq`, `yq-go`, `csvkit`, `miller`, `jless`, `choose`

### System Monitoring
`procs`, `bottom`, `htop`, `hyperfine`, `nmap`, `wireshark`

### Quality Tools
`shellcheck`, `shfmt`, `ruff`, `semgrep`, `tokei`, `lizard`

### AI Tools
`claude-code`, `cursor`, `aider`, `gemini-cli`, `serena`, `mcp-nixos`

### Containers & Orchestration
`docker-compose`, `podman`, `k9s`

### Documentation
`glow`, `vhs`, `rich-cli`, `obsidian`

See [`modules/core/packages.nix`](modules/core/packages.nix) for complete list with descriptions.

</details>

## 🎯 Key Commands

```bash
# System Management
./rebuild-nixos                    # Interactive rebuild (recommended)
nix flake check                    # Validate configuration

# Modern tools (automatic substitutions)
cat file.py                        # → bat (syntax highlighting)
cat README.md                      # → glow (rendered markdown)
ls                                 # → eza (icons + git status)
grep "pattern"                     # → rg (faster search)
find . -name "*.nix"              # → fd (faster find)

# GitHub Workflow
idea add dark mode toggle          # Capture feature idea
bug search crashes                 # Report bug
spec-it 42                        # Start spec-driven dev
build-it 43                       # Start implementation

# Development
devenv shell                      # Enter project environment
ai script.py                      # AI pair programming
yazi                              # Terminal file manager
```

## 📚 Documentation

### Core System
- **[THE_CLOSED_LOOP.md](docs/THE_CLOSED_LOOP.md)** - How auto-documentation works
- **[CLAUDE_ORCHESTRATION.md](docs/architecture/CLAUDE_ORCHESTRATION.md)** - Three-level orchestration

### Guides
- **[COMMON_TASKS.md](docs/guides/COMMON_TASKS.md)** - Quick reference
- **[GITHUB_WORKFLOW.md](docs/guides/GITHUB_WORKFLOW.md)** - Feature & bug tracking
- **[enhanced-tools-guide.md](docs/tools/enhanced-tools-guide.md)** - Modern CLI tools

## 🔧 Customization

<details>
<summary>Adding Packages</summary>

```nix
# System-wide tools (modules/core/packages.nix)
environment.systemPackages = with pkgs; [
  your-package
];

# User-specific tools (modules/home-manager/base.nix)
home.packages = with pkgs; [
  your-user-package
];
```

After adding packages, run `./rebuild-nixos` to apply and auto-update Claude Code context.

</details>

<details>
<summary>Fish Shell Abbreviations</summary>

```nix
# Add to modules/home-manager/base.nix
programs.fish.interactiveShellInit = ''
  abbr -a yourabbr 'your-command'
'';
```

Claude Code learns about new abbreviations automatically on rebuild.

</details>

<details>
<summary>Desktop Environment</summary>

```nix
# Exclude GNOME apps (profiles/desktop/gnome.nix)
environment.gnome.excludePackages = with pkgs; [
  gnome-maps
  gnome-weather
];

# Change default editor (hosts/nixos/default.nix)
environment.variables.EDITOR = "code";
```

</details>

## 🎨 Repository Structure

```
nixos-config/
├── flake.nix                      # Main configuration entry
├── rebuild-nixos                  # Interactive rebuild script ⭐
├── hosts/nixos/                   # Host-specific config
├── modules/
│   ├── core/packages.nix         # 122 system tools ⭐
│   └── home-manager/base.nix     # User configurations
├── profiles/desktop/              # GNOME setup
├── docs/
│   ├── THE_CLOSED_LOOP.md        # Auto-documentation system ⭐
│   └── guides/                   # Usage guides
└── CLAUDE.md                     # Auto-generated AI context ⭐
```

## 🚀 Recent Improvements

**October 2025** - Performance & Intelligence
- ⚡ 2.5s faster rebuilds (parallel analyzers + Python consolidation)
- 🧠 Adaptive learning system with pattern detection
- 📊 MCP server analytics (469 sessions analyzed)
- 🎯 Automatic permission learning from usage patterns

**September 2025** - GitHub Integration
- 💡 `idea`, `bug` commands for quick capture
- 🏷️ Custom label system (`status:`, `type:`, `priority:`)
- 🔄 Spec-driven workflow (`spec-it`, `build-it`)

**August 2025** - Documentation Lifecycle
- 📝 YAML frontmatter with status tracking
- 🗄️ Automatic archival of stale docs
- 🧹 Git hooks for quality enforcement

## 🤝 Contributing

This is a personal NixOS configuration shared for learning and inspiration.

**You're welcome to:**
- 🍴 Fork and adapt for your setup
- 💡 Open issues with suggestions
- 📖 Use as reference for your own NixOS journey
- ⭐ Star if you find it useful

**Related Projects:**
- [claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation) - The automation engine

## 📄 License

MIT License - Use freely, modify, distribute, learn from it.

---

<div align="center">

**Built over 6 months of daily use**

*NixOS declarative configuration meets AI-assisted development*

### 🌟 [Star this repo](https://github.com/jacopone/nixos-config) to follow development

[Try it now](#-quick-start) · [Read the docs](#-documentation) · [Report issue](https://github.com/jacopone/nixos-config/issues)

</div>
