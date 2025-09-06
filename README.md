# 🚀 My NixOS Configuration

> A modern, modular NixOS configuration featuring GNOME desktop, enhanced CLI tools, and intelligent Fish shell integration

[![NixOS](https://img.shields.io/badge/NixOS-24.05-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat-square&logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-orange.svg?style=flat-square)](https://github.com/nix-community/home-manager)
[![Agent OS](https://img.shields.io/badge/Agent-OS-purple.svg?style=flat-square)](https://buildermethods.com/agent-os)

## ✨ Features

### 🏗️ **Modern Modular Architecture**
- 🎯 **Flake-based configuration** for reproducible builds
- 🏠 **Home Manager integration** for user-specific configurations  
- 📦 **Modular structure** inspired by [ZaneyOS](https://gitlab.com/Zaney/zaneyos)
- 🔧 **Interactive rebuild script** with safety checks and rollback capability

### 🖥️ **Desktop Environment**
- 🌟 **GNOME Desktop** with curated application selection
- 🎨 **Kitty Terminal** with Catppuccin Mocha theme
- 📁 **Yazi File Manager** with rich preview support for markdown, JSON, CSV
- 🐟 **Fish Shell** as default with intelligent command enhancements

### 🛠️ **Enhanced CLI Experience**
- ⚡ **Smart Command Substitutions** - Get enhanced tools automatically
- 🎨 **Syntax Highlighting** with `bat` instead of `cat`
- 📊 **Modern File Listing** with `eza` instead of `ls`
- 🔍 **Blazing Fast Search** with `ripgrep` and `fd`
- 🤖 **Agent-Compatible** - Scripts and AI agents get original commands automatically

### 👨‍💻 **Development Environment**
- 🔨 **Multiple Editors**: Helix, Zed, VSCode, Cursor
- 🤖 **AI Tools**: Claude Code, Plandex, Gemini CLI
- 📦 **Node.js & Python** pre-installed for instant development
- 🏗️ **DevEnv & Direnv** for per-project environments
- 🎯 **Agent OS Integration** for structured AI workflows

## 📂 Repository Structure

```
nixos-config/
├── 📁 hosts/
│   └── nixos/                    # Host-specific configuration
│       ├── default.nix          # Main host config
│       └── hardware-configuration.nix
├── 📁 modules/
│   ├── core/
│   │   └── packages.nix         # System-wide packages
│   └── home-manager/
│       └── base.nix             # User-specific configurations
├── 📁 profiles/
│   └── desktop/                 # Desktop environment profiles
│       ├── default.nix
│       ├── base.nix             # Common desktop settings
│       └── gnome.nix            # GNOME configuration
├── 📁 users/
│   └── guyfawkes/
│       └── home.nix             # User home-manager entry point
├── 🔧 rebuild-nixos             # Interactive rebuild script
├── 📋 flake.nix                 # Flake configuration
├── 📚 CLAUDE.md                 # AI agent instructions
├── 🐟 fish-smart-commands.md    # Fish shell documentation  
└── 📖 enhanced-tools-guide.md   # Modern CLI tools guide
```

## 🚀 Quick Start

### Prerequisites
- NixOS installed with flakes enabled
- Git for cloning the repository

### Installation
```bash
# Clone the repository
git clone <your-repo-url> ~/nixos-config
cd ~/nixos-config

# Review and customize the configuration
# Edit hosts/nixos/hardware-configuration.nix with your hardware
# Update users/guyfawkes/home.nix with your username

# Apply the configuration
sudo nixos-rebuild switch --flake .

# Or use the interactive script (recommended)
./rebuild-nixos
```

## 🎯 Key Commands

### System Management
```bash
./rebuild-nixos                    # Interactive rebuild with safety checks
sudo nixos-rebuild switch --flake . # Direct rebuild
nix flake update                   # Update inputs
nix flake check                    # Syntax validation
```

### Enhanced CLI Tools (Automatic)
```bash
cat file.py          # → bat file.py (syntax highlighted)
ls                   # → eza --icons --git (with icons)  
ll                   # → eza -la --icons --git --group-directories-first
grep "pattern"       # → rg "pattern" (faster search)
```

### Fish Shell Help
```bash
show_enhanced_tools  # See all enhanced commands
fish_help           # Quick help overview
check_context       # Check if in automated context
what_runs cat       # See what command will actually run
```

### File Management
```bash
yazi                 # Launch modern file manager
preview file.txt     # Enhanced file preview
ff pattern          # Find files by name (fd)
search pattern      # Search text in files (rg)
```

## 🧰 Installed Tools & Applications

### Development Tools
- **Editors**: Helix, Zed, VSCode, Cursor  
- **AI Agents**: Claude Code, Plandex, Gemini CLI
- **Version Control**: Git, GitHub CLI
- **Languages**: Node.js 20, Python 3, GCC
- **Environment**: DevEnv, Direnv, Cachix

### CLI Enhancements  
- **File Viewing**: `bat` (syntax highlighting)
- **File Listing**: `eza` (icons, git status)
- **File Finding**: `fd` (fast find), `fzf` (fuzzy finder)
- **Text Search**: `ripgrep` (fast grep), `peco` (interactive filter)
- **System Monitoring**: `htop`, `gtop`, `ncdu`, `pydf`
- **File Management**: `yazi` (terminal file manager)

### Productivity Applications
- **Browser**: Google Chrome
- **Office**: LibreOffice  
- **Notes**: Obsidian
- **Learning**: Anki
- **Graphics**: GIMP with plugins
- **Media**: VLC Player

## 🧠 Smart Fish Shell System

The Fish shell configuration includes **context-aware command substitutions**:

### 👤 **For You (Interactive)**
- Rich syntax highlighting, icons, and git status
- Enhanced tools automatically selected
- Abbreviations for quick typing (`tree` → `eza --tree`)

### 🤖 **For Agents & Scripts**
- Plain output, no colors or formatting
- Original commands automatically selected  
- Full compatibility with automation

### 🔄 **Automatic Context Detection**
The system detects:
- TTY vs non-TTY usage
- Environment variables (`CI`, `AUTOMATION`, `AGENT_MODE`)
- Input/output redirection
- Agent-specific terminal indicators

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - AI agent instructions and project overview
- **[fish-smart-commands.md](fish-smart-commands.md)** - Complete Fish shell documentation
- **[enhanced-tools-guide.md](enhanced-tools-guide.md)** - Modern CLI tools reference

## 🛡️ Safety Features

### Interactive Rebuild Script
- **Pre-flight validation** with test builds
- **User confirmation** before applying changes
- **Automatic rollback** if changes are rejected
- **Git integration** with commit prompts
- **Generation cleanup** with interactive selection

### Backup & Recovery
- **System generations** for easy rollback
- **Configuration versioning** with Git
- **Hardware configuration** isolation
- **Modular design** for selective updates

## 🎨 Customization

### Adding Packages
```nix
# System packages (modules/core/packages.nix)
environment.systemPackages = with pkgs; [
  your-package
];

# User packages (modules/home-manager/base.nix)  
home.packages = with pkgs; [
  your-user-package
];
```

### Desktop Environment
- **GNOME apps** excluded in `profiles/desktop/gnome.nix`
- **Terminal themes** configured in `modules/home-manager/base.nix`
- **Window manager** settings in `profiles/desktop/base.nix`

## 🤝 Contributing

This is a personal NixOS configuration, but you're welcome to:
- 🍴 **Fork** and adapt for your setup
- 🐛 **Report issues** or suggest improvements  
- 💡 **Share ideas** for better configurations
- 📖 **Use as reference** for your own NixOS journey

## 📄 License

This configuration is provided as-is for educational and reference purposes. Feel free to use, modify, and distribute according to your needs.

---

<div align="center">

**Built with ❤️ using NixOS, enhanced by AI agents**

*"Reproducible, declarative, and just works!"*

</div>