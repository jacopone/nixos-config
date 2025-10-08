---
status: active
created: 2024-06-01
updated: 2025-10-08
type: reference
lifecycle: persistent
---

# NixOS Configuration with Auto-Documenting AI Integration

> A NixOS setup that keeps Claude Code automatically synchronized with your system state

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat-square&logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-orange.svg?style=flat-square)](https://github.com/nix-community/home-manager)
[![Claude Code](https://img.shields.io/badge/Claude-Code-5A67D8.svg?style=flat-square&logo=anthropic)](https://claude.ai)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/jacopone/nixos-config?style=flat-square)](https://github.com/jacopone/nixos-config/commits/master)
[![GitHub release](https://img.shields.io/github/v/release/jacopone/nixos-config?style=flat-square)](https://github.com/jacopone/nixos-config/releases)

## What's This About?

I spent 6 months building a NixOS configuration with an interesting feature: **every system rebuild automatically updates Claude Code's knowledge of what tools are available**.

Here's what happens when you run `./rebuild-nixos`:

```bash
--> Updating Claude Code configurations...

# This runs automatically:
nix run github:jacopone/claude-nixos-automation#update-all

    ✅ Claude Code configurations updated
       - System CLAUDE.md: ~/.claude/CLAUDE.md (updated with 122 tools)
       - Project CLAUDE.md: ./CLAUDE.md (updated)
```

**The result**: Claude Code knows about every tool on your system and uses them correctly. No more suggesting `find` when you have `fd`, or `cat` when you have `bat`.

<!-- TODO: Add GIF here showing the rebuild process -->

## How It Works

The [rebuild-nixos](rebuild-nixos) script integrates with [claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation):

1. You declare packages in [`modules/core/packages.nix`](modules/core/packages.nix)
2. On rebuild, automation parses your configuration
3. Generates CLAUDE.md with tool inventory and usage policies
4. Claude Code reads this on every new session

**The closed loop**: System state → auto-documentation → AI knowledge

See [docs/THE_CLOSED_LOOP.md](docs/THE_CLOSED_LOOP.md) for technical details.

## Why This Helps

**For AI development:**
- ✅ Claude Code uses modern tools automatically (`fd`, `eza`, `bat`, `rg`)
- ✅ Tool knowledge stays in sync with system state (zero drift)
- ✅ No manual documentation of 122+ installed tools
- ✅ Consistent behavior across sessions

**For system management:**
- ✅ Declarative NixOS configuration (reproducible builds)
- ✅ Interactive rebuild script with safety checks
- ✅ Automatic maintenance (garbage collection, cache cleanup)
- ✅ Rollback capability for failed changes

## What's Included

### Core System
- **NixOS 25.11** with Flakes + Home Manager
- **GNOME Desktop** (Wayland) with Kitty terminal
- **Fish Shell** with Starship prompt
- **122 curated tools** selected over 6 months

### Modern CLI Stack
Replace old POSIX commands with modern alternatives:
- `fd` instead of `find` - Fast file searching
- `eza` instead of `ls` - Enhanced listings with git status
- `bat` instead of `cat` - Syntax-highlighted viewing
- `rg` instead of `grep` - Blazing fast text search
- `dust` instead of `du` - Interactive disk usage
- `procs` instead of `ps` - Modern process viewer

See [docs/tools/enhanced-tools-guide.md](docs/tools/enhanced-tools-guide.md) for the complete list.

### AI Development Tools
- **Claude Code** (Anthropic's official CLI)
- **Cursor** (AI-powered code editor)
- **Serena MCP** (semantic code analysis)
- **Aider** (AI pair programming)
- **Node.js 20 + Python 3** pre-installed

### Development Environment
- **DevEnv + Direnv** for per-project environments
- **Git + GitHub CLI** with enhanced diffs (`delta`)
- **Multiple editors**: Helix, Zed, VSCode, Cursor
- **Quality tools**: ShellCheck, Semgrep, Ruff

## Quick Start

### Prerequisites
- Fresh NixOS installation (minimal or desktop)
- 8GB RAM minimum (16GB recommended)
- Nix Flakes enabled

### Installation

```bash
# 1. Enable flakes (if not already enabled)
sudo nano /etc/nixos/configuration.nix
# Add: nix.settings.experimental-features = [ "nix-command" "flakes" ];
sudo nixos-rebuild switch

# 2. Clone the repository
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config

# 3. Generate your hardware configuration
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix

# 4. Update username in configuration
sed -i 's/guyfawkes/yourusername/g' flake.nix hosts/nixos/default.nix

# 5. Apply the configuration
./rebuild-nixos
```

See the [detailed setup guide](#-detailed-setup-guide) below for more options.

## Key Commands

### System Management

```bash
./rebuild-nixos                    # Interactive rebuild (recommended)
sudo nixos-rebuild switch --flake . # Direct rebuild
nix flake check                    # Validate configuration
```

### Modern CLI Tools (Automatic Substitutions)

```bash
# These automatically use enhanced tools:
cat file.py          # → bat (syntax highlighting)
cat README.md        # → glow (rendered markdown)
ls                   # → eza (icons + git status)
grep "pattern"       # → rg (faster search)
find . -name "*.nix" # → fd (faster find)
```

### Development

```bash
devenv shell         # Enter project environment
ai script.py         # AI pair programming with Aider
yazi                 # Terminal file manager
```

## Repository Structure

```
nixos-config/
├── flake.nix                      # Main configuration entry
├── rebuild-nixos                  # Interactive rebuild script
├── hosts/nixos/                   # Host-specific config
├── modules/
│   ├── core/
│   │   └── packages.nix          # System packages (122 tools)
│   └── home-manager/
│       └── base.nix              # User configurations
├── profiles/desktop/              # Desktop environment
├── docs/
│   ├── THE_CLOSED_LOOP.md        # Auto-documentation system
│   ├── guides/                   # User guides
│   └── tools/                    # Tool-specific docs
└── CLAUDE.md                     # Auto-generated AI instructions
```

## Documentation

### Core System
- **[THE_CLOSED_LOOP.md](docs/THE_CLOSED_LOOP.md)** - How auto-documentation works
- **[CLAUDE_ORCHESTRATION.md](docs/architecture/CLAUDE_ORCHESTRATION.md)** - Three-level orchestration architecture

### Guides
- **[COMMON_TASKS.md](docs/guides/COMMON_TASKS.md)** - Quick reference for frequent operations
- **[fish-smart-commands.md](docs/tools/fish-smart-commands.md)** - Fish shell features
- **[enhanced-tools-guide.md](docs/tools/enhanced-tools-guide.md)** - Modern CLI tools

### Related Systems
- **[basb-system/](basb-system/)** - Building a Second Brain implementation
- **[stack-management/](stack-management/)** - Technology stack lifecycle management

## Safety Features

The [`./rebuild-nixos`](rebuild-nixos) script includes:
- ✅ Pre-flight validation with test builds
- ✅ User confirmation before applying changes
- ✅ Automatic rollback capability
- ✅ Git integration with commit prompts
- ✅ Generation cleanup with interactive selection
- ✅ Cache cleanup (UV, Chrome, development caches)

**Rollback if needed:**
```bash
sudo nixos-rebuild list-generations
sudo nixos-rebuild switch --rollback
```

---

## 📋 Detailed Setup Guide

<details>
<summary>Click to expand complete installation instructions</summary>

### Prerequisites & System Requirements

- **Fresh NixOS installation** (minimal or desktop)
- **Git** for cloning the repository
- **Minimum 8GB RAM** (recommended 16GB+ for optimal build performance)
- **x86_64 architecture** (Intel/AMD 64-bit)
- **SSD storage** recommended for optimal Nix store performance
- **EFI boot mode** (systemd-boot configuration)
- **Network connection** for package downloads

### Hardware Compatibility

- **Intel/AMD processors** with KVM support
- **Intel integrated graphics** or discrete GPU with Linux drivers
- **Standard USB, SATA, AHCI** storage controllers
- **ThinkPad-specific optimizations** included but compatible with other laptops

### Step-by-Step Setup

#### 1. Enable Nix Flakes (Required)

```bash
# Edit your current configuration
sudo nano /etc/nixos/configuration.nix

# Add this to the configuration:
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Apply the change
sudo nixos-rebuild switch

# Verify flakes are enabled
nix --version
```

#### 2. Clone the Repository

```bash
# Clone to home directory
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

#### 3. Generate Your Hardware Configuration

```bash
# Generate new hardware configuration
sudo nixos-generate-config --show-hardware-config > /tmp/new-hardware-config.nix

# Compare with existing config
diff hosts/nixos/hardware-configuration.nix /tmp/new-hardware-config.nix

# Replace with your hardware configuration
sudo cp /tmp/new-hardware-config.nix hosts/nixos/hardware-configuration.nix
```

**Important hardware-specific settings to verify:**
- File system UUIDs (will be different on your system)
- Boot loader configuration (EFI vs BIOS)
- Available kernel modules for your hardware
- CPU type (Intel vs AMD microcode)

#### 4. Customize User Configuration

```bash
# Update the main flake with your username
sed -i 's/guyfawkes/yourusername/g' flake.nix

# Update the host configuration
sed -i 's/guyfawkes/yourusername/g' hosts/nixos/default.nix

# Create your user directory
mkdir -p users/yourusername
cp users/guyfawkes/home.nix users/yourusername/home.nix
```

**Essential customizations in `hosts/nixos/default.nix`:**

```nix
# Update the user account definition:
users.users.yourusername = {
  isNormalUser = true;
  description = "Your Full Name";
  extraGroups = [ "networkmanager" "wheel" ];
};
```

#### 5. Review System Settings

Before applying, review these key settings in `hosts/nixos/default.nix`:

```nix
# Hostname
networking.hostName = "nixos";

# Timezone (uncomment and set)
time.timeZone = "America/New_York";  # Change to your timezone

# Locale settings
i18n.defaultLocale = "en_US.UTF-8";
```

#### 6. Apply the Configuration

```bash
# Method 1: Interactive script with safety checks (recommended)
chmod +x rebuild-nixos
./rebuild-nixos

# Method 2: Direct application (experienced users)
sudo nixos-rebuild switch --flake .
```

**The rebuild script will:**
- Update flake inputs to latest versions
- Test build without activation (catches errors early)
- Apply configuration with rollback option
- **Update Claude Code configurations automatically**
- Prompt for user confirmation
- Offer to commit changes to git

#### 7. Post-Installation Verification

```bash
# Verify Fish shell
fish --version

# Check enhanced tools
which eza bat fd rg

# Test file manager
yazi

# Verify git integration in prompt
cd ~/nixos-config  # Should show git status
```

### Troubleshooting

#### Hardware Configuration Issues

```bash
# For EFI systems (most modern computers):
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# For BIOS systems (older computers):
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";
```

#### Build Memory Issues

```bash
# Reduce build parallelism temporarily
sudo nixos-rebuild switch --flake . --cores 2 --max-jobs 1
```

#### Rollback if Something Goes Wrong

```bash
# List available generations
sudo nixos-rebuild list-generations

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

</details>

---

## 🤖 AI Tooling Details

<details>
<summary>Click to expand AI development features</summary>

### Claude Code Integration

The system includes three levels of Claude Code configuration:

1. **User Policies** (`~/.claude/CLAUDE-USER-POLICIES.md`) - Personal preferences
2. **System Context** (`~/.claude/CLAUDE.md`) - Auto-generated tool inventory
3. **Project Context** (`./CLAUDE.md`) - Project-specific instructions

All updated automatically on `./rebuild-nixos`.

### Tool Selection Policy

Claude Code is forced to use modern tools through mandatory substitution rules:

```markdown
## MANDATORY Tool Substitutions
- `find` → `fd` (ALWAYS use fd for file searching)
- `ls` → `eza` (ALWAYS use eza for directory listing)
- `cat` → `bat` (ALWAYS use bat for file viewing)
- `grep` → `rg` (ALWAYS use ripgrep)
```

### Smart Fish Shell

The Fish shell configuration includes context-aware command substitutions:

**For humans (interactive):**
- Beautiful markdown rendering, syntax highlighting
- Rich icons and git status
- Enhanced tools automatically selected

**For AI agents (scripts):**
- Plain output, no formatting
- Original commands automatically used
- Full compatibility with automation

### AI Development Tools

- **Claude Code** - Anthropic's official CLI
- **Cursor** - AI-powered editor with quality gates
- **Aider** - AI pair programming
- **Gemini CLI** - Google's Gemini models
- **Serena MCP** - Semantic code analysis
- **MCP-NixOS** - NixOS package/option info

</details>

---

## 🛠️ Complete Tool List

<details>
<summary>Click to expand full list of 122 tools</summary>

### Modern CLI Tools
- `bat` - Syntax-highlighted file viewing
- `eza` - Enhanced directory listing
- `fd` - Fast file search
- `ripgrep` - Fast text search
- `dust` - Disk usage visualization
- `procs` - Modern process viewer
- `delta` - Enhanced git diffs
- `zoxide` - Smart directory jumping
- `fzf` - Fuzzy finder

### Development
- `git`, `gh` - Version control
- `docker-compose`, `k9s` - Containers
- `nodejs`, `python3` - Runtimes
- `helix`, `zed`, `vscode` - Editors
- `devenv`, `direnv` - Environments

### Data Processing
- `jq` - JSON processor
- `yq` - YAML processor
- `csvkit` - CSV tools
- `miller` - Multi-format data processing

### System Monitoring
- `htop`, `bottom` - System monitors
- `hyperfine` - Benchmarking
- `nmap` - Network scanning
- `wireshark` - Packet analysis

### File Management
- `yazi` - Terminal file manager
- `glow` - Markdown renderer
- `jless` - JSON viewer
- `broot` - Interactive tree navigation

See [`modules/core/packages.nix`](modules/core/packages.nix) for the complete list with descriptions.

</details>

---

## 🎨 Customization

### Adding Packages

```nix
# System-wide (modules/core/packages.nix)
environment.systemPackages = with pkgs; [
  your-package
];

# User-specific (modules/home-manager/base.nix)
home.packages = with pkgs; [
  your-user-package
];
```

### Modifying Desktop

```nix
# Exclude GNOME apps (profiles/desktop/gnome.nix)
environment.gnome.excludePackages = with pkgs; [
  gnome-maps
  gnome-weather
];

# Change default editor (hosts/nixos/default.nix)
environment.variables.EDITOR = "code";
```

### Fish Shell Abbreviations

```nix
# Add to modules/home-manager/base.nix
programs.fish.interactiveShellInit = ''
  abbr -a yourabbr 'your-command'
'';
```

---

## 🤝 Contributing

This is a personal NixOS configuration, but you're welcome to:
- 🍴 Fork and adapt for your setup
- 🐛 Report issues or suggest improvements
- 💡 Share ideas for better configurations
- 📖 Use as reference for your own NixOS journey

## 📄 License

MIT License - Feel free to use, modify, and distribute.

---

<div align="center">

**Built over 6 months with NixOS and Claude Code**

*Declarative system configuration meets AI-assisted development*

[⭐ Star this repo](https://github.com/jacopone/nixos-config) if you find it useful

</div>
