# 🚀 My NixOS Configuration

> A modern, modular NixOS configuration featuring GNOME desktop, enhanced CLI tools, and intelligent Fish shell integration

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat-square&logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-orange.svg?style=flat-square)](https://github.com/nix-community/home-manager)

## ✨ Features

### 🏗️ **Modern Modular Architecture**
- 🎯 **Flake-based configuration** for reproducible builds
- 🏠 **Home Manager integration** for user-specific configurations  
- 📦 **Modular structure** inspired by [ZaneyOS](https://gitlab.com/Zaney/zaneyos)
- 🔧 **Interactive rebuild script** with safety checks and rollback capability

### 🖥️ **Desktop Environment**
- 🌟 **GNOME Desktop** with curated application selection and Wayland optimization
- 🎨 **Kitty Terminal** with 35+ advanced optimizations, JetBrains Mono Nerd Font, and Catppuccin Mocha theme
- 📁 **Yazi File Manager** with rich preview support for 40+ file types (markdown, JSON, CSV, images, PDFs)
- 🐟 **Fish Shell** as default with intelligent command enhancements and context-aware automation
- 🚀 **Starship Prompt** with comprehensive Nerd Font symbols (`~/nixos-config  main [✱2✚1⇡3] (+15/-3) ❯`)
- 🌍 **Multi-locale Support** (US English with Italian regional settings)
- 🔧 **Helix Editor** as system default with modern modal editing

### 🛠️ **Enhanced CLI Experience**
- 🚀 **Visual Git Integration** - Real-time branch status in terminal prompt
- ⚡ **Smart Command Substitutions** - Get enhanced tools automatically  
- 🎨 **Syntax Highlighting** with `bat` instead of `cat`
- 📊 **Modern File Listing** with `eza` instead of `ls`
- 🔍 **Blazing Fast Search** with `ripgrep` and `fd`
- 🔤 **Programming Font** with JetBrains Mono Nerd Font ligatures and icons
- 🤖 **Agent-Compatible** - Scripts and AI agents get original commands automatically

### 👨‍💻 **Development Environment**
- 🔨 **Multiple Editors**: Helix, Zed, VSCode, Cursor
- 🤖 **AI Tools**: Claude Code, Plandex, Gemini CLI, Claude Flow (alpha)
- 🧠 **CCPM-Enhanced AI Orchestration**: Advanced hybrid system with 90%+ performance improvements + structured project management
- 📦 **Node.js & Python** pre-installed for instant development
- 🏗️ **DevEnv & Direnv** for per-project environments
- 🚀 **Build Optimizations**: CPU-limited builds (4 cores, 2 max jobs) for system stability

### ⚡ **Performance Optimization**
- 🧠 **Memory Management**: Optimized kernel parameters for desktop performance
- 💾 **Zram Compression**: 25% of RAM with zstd compression for faster swap
- 🔧 **Kernel Tuning**: Reduced swappiness (10), optimized VFS cache pressure (50)
- 🏗️ **Build Performance**: Limited parallel builds to prevent memory exhaustion
- 🗑️ **Automatic Maintenance**: Weekly garbage collection, monthly system updates
- 💽 **SSD Optimization**: Weekly TRIM, firmware updates, write optimization
- 📦 **Nix Store Optimization**: Auto-store optimization and download buffering

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
├── 📁 ai-orchestration/         # Multi-agent AI coordination system
│   ├── scripts/
│   │   └── ai-orchestration-universal.sh
│   ├── docs/
│   │   ├── AI_ORCHESTRATION.md
│   │   ├── WORKFLOW_EVOLUTION_PROTOCOL.md
│   │   ├── USAGE_GUIDE.md
│   │   └── UNIVERSAL_INSTALLATION.md
│   └── README.md
├── 🔧 rebuild-nixos             # Interactive rebuild script
├── 📋 flake.nix                 # Flake configuration
├── 📚 CLAUDE.md                 # AI agent instructions
├── 🐟 fish-smart-commands.md    # Fish shell documentation  
└── 📖 enhanced-tools-guide.md   # Modern CLI tools guide
```

## 🚀 Quick Start

### Prerequisites & System Requirements
- **NixOS** installed with flakes enabled
- **Git** for cloning the repository
- **Minimum 8GB RAM** (recommended 16GB+ for optimal build performance)
- **x86_64 architecture** (Intel/AMD 64-bit)
- **SSD storage** recommended for optimal Nix store performance
- **Hardware acceleration** support (automatically enabled)

### Hardware Optimizations
- **ThinkPad optimizations** included (firmware updates, power management)
- **GNOME Wayland** with hardware acceleration
- **Automatic SSD TRIM** for disk health
- **Zram compression** for memory efficiency

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

### Visual Git Prompt (Always Visible)
```bash
# Your terminal prompt now shows (with Nerd Font symbols):
~/nixos-config  main [✱2✚1⇡3] (+15/-3) ❯

# What you see:
#  main          = git branch with Nerd Font git icon
# [✱2✚1⇡3]      = git status: 2 modified, 1 staged, 3 ahead of remote  
# (+15/-3)       = git metrics: 15 lines added, 3 deleted
# ❯              = prompt character (green for success, red for errors)
```

### Enhanced CLI Tools (Automatic)
```bash
cat README.md        # → glow README.md (beautiful markdown)
cat file.py          # → bat file.py (syntax highlighted code)
ls                   # → eza --icons --git (with icons)  
ll                   # → eza -la --icons --git --group-directories-first
grep "pattern"       # → rg "pattern" (faster search)
cd desktop-assistant/ # → builtin cd (reliable for local paths)
cd project           # → zoxide smart directory jumping
```

### New Tool Abbreviations (Type + Space)
```bash
yamlcat              # → yq . (YAML processing)
csvcat               # → csvlook (CSV viewing) 
ruffcheck            # → ruff check (Python linting)
uvrun                # → uv run (fast Python execution)
dcp                  # → docker-compose
pods                 # → k9s (Kubernetes dashboard)
netscan              # → nmap -sn (network discovery)
trace                # → strace -f (system call tracing)
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
md file.md          # Enhanced markdown viewer
ff pattern          # Find files by name (fd)
search pattern      # Search text in files (rg)
```

## 🧠 AI Orchestration System

### **Universal Multi-Agent Coordination Framework**
Experience **90%+ performance improvements** through intelligent AI agent coordination:

```bash
# Quick Start - Run from any project directory
~/nixos-config/ai-orchestration/scripts/ai-orchestration-universal.sh
```

### **5-Step Orchestration Workflow**
1. **Master Coordinator** (Claude Code) - Strategic analysis and task decomposition
2. **Backend Implementation** (Cursor) - Server-side functionality  
3. **Frontend Implementation** (v0.dev) - UI/UX development
4. **Quality Assurance** (Gemini Pro) - Testing and validation
5. **Integration & Synthesis** (Claude Code) - Final coordination

### **Key Features**
🧠 **Intelligent Project Detection** - Automatically adapts to any technology stack  
⚡ **Parallel Processing** - Independent agent contexts prevent interference  
🔄 **Real-Time Adaptation** - Dynamic strategy refinement during execution  
🌐 **Cross-Platform Integration** - Works with current AI development platforms  
📈 **Evolution Protocol** - Built-in system for staying current  

### **Platform Support**
- **Master Coordinator**: Claude Code
- **Backend Development**: Cursor  
- **Frontend Development**: v0.dev
- **Quality Assurance**: Gemini Pro

### **Technology Detection**
Automatically detects and adapts to:
- React, Vue, Angular (frontend)
- Node.js, Python, Rust, Go (backend)  
- PostgreSQL, MySQL, MongoDB (databases)
- Vitest, Jest, Playwright (testing)
- Vite, Next.js, Nuxt (frameworks)

See **[ai-orchestration/README.md](ai-orchestration/README.md)** for complete documentation.

## 🧰 Installed Tools & Applications

### Development Tools
- **Editors**: Helix, Zed, VSCode, Cursor  
- **AI Agents**: Claude Code, Plandex, Gemini CLI
- **Version Control**: Git, GitHub CLI, `delta` (enhanced diffs), `gitui`, `lazygit`
- **Languages**: Node.js 20, Python 3, GCC
- **Package Managers**: `npm`, `yarn`, `pnpm` (Node.js), `uv` (Python)
- **Environment**: DevEnv, Direnv, Cachix
- **Containers**: Docker, Docker Compose, Podman, K9s (Kubernetes)
- **Database**: PostgreSQL, Redis
- **Quality**: `shellcheck` (shell scripts), `ruff` (Python), `semgrep` (security)

### CLI Enhancements  
- **File Viewing**: `glow` (markdown), `bat` (syntax highlighting), `jless` (large JSON)
- **File Listing**: `eza` (icons, git status), `dust` (disk usage), `duf` (disk free)
- **File Finding**: `fd` (fast find), `fzf`/`skim` (fuzzy finders), `choose` (text extraction)
- **Text Search**: `ripgrep` (fast grep), `ast-grep` (structural search)
- **System Monitoring**: `htop`, `gtop`, `bottom`, `procs`, `hyperfine` (benchmarking)
- **File Management**: `yazi` (terminal file manager), `zoxide` (smart directory jumping)
- **Data Processing**: `jq` (JSON), `yq` (YAML), `csvkit` (CSV), `miller` (multi-format)
- **Development**: `tmux` (sessions), `entr` (file watching), `just` (task runner)
- **Network & Debug**: `nmap`, `wireshark`, `strace`, `ltrace`
- **Python Tools**: `ruff` (linting/formatting), `uv` (package management)

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
- Beautiful markdown rendering with `glow`, syntax highlighting with `bat`
- Rich icons, git status, and enhanced tools automatically selected
- Abbreviations for quick typing (`tree` → `eza --tree`, `mdcat` → `glow`)

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
- **[ai-orchestration/README.md](ai-orchestration/README.md)** - Universal multi-agent AI coordination system
- **[fish-smart-commands.md](fish-smart-commands.md)** - Complete Fish shell documentation
- **[enhanced-tools-guide.md](enhanced-tools-guide.md)** - Modern CLI tools reference
- **[kitty-optimization-guide.md](kitty-optimization-guide.md)** - Complete Kitty terminal optimization guide

## 🛡️ Safety Features

### Interactive Rebuild Script
- **Pre-flight validation** with test builds
- **User confirmation** before applying changes
- **Automatic rollback** if changes are rejected
- **Git integration** with commit prompts
- **Generation cleanup** with interactive selection
- **Cache cleanup** with size reporting (UV, Chrome, Yarn, Playwright)

### Backup & Recovery
- **System generations** for easy rollback
- **Configuration versioning** with Git
- **Hardware configuration** isolation
- **Modular design** for selective updates

## 🔧 Advanced Configuration

### Kitty Terminal Optimizations
- **700+ lines** of advanced terminal configuration
- **Performance tuning** for AI development workflows (50k scrollback, optimized repaints)
- **Typography enhancements** with ligature control and advanced text rendering
- **Catppuccin Mocha** theme with enhanced contrast
- **Powerline tabs** with slanted segments and file path display
- **35+ keyboard shortcuts** for productivity

### Yazi File Manager Features
- **Rich preview system** with 40+ file type support
- **Custom openers** for each file type (Helix, Zed, VSCode, Cursor)
- **Image viewers** (Eye of GNOME, sxiv, feh)
- **PDF viewers** (Okular with KDE integration)
- **Office integration** (LibreOffice with CSV support)
- **Markdown rendering** with Glow integration

### Fish Shell Intelligence
- **Context detection** for automation vs interactive use
- **Smart command substitutions** (bat/cat, eza/ls, rg/grep)
- **50+ abbreviations** for rapid development
- **Git shortcuts** and development aliases
- **Agent compatibility** with fallback commands

### System Version Management
- **NixOS System Version**: 25.11 (current running version)
- **Configuration State Version**: 24.05 (for compatibility, should not be changed)
- **Automatic distinction** between system updates and state compatibility

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

## 🔧 Troubleshooting

### Common Issues & Solutions

#### **Insecure Packages (Obsidian/LibSoup)**
```bash
# Already configured in the system:
nixpkgs.config.permittedInsecurePackages = [
  "electron-24.8.6"    # For Obsidian compatibility
  "libsoup-2.74.3"     # For Google Drive support
];
```

#### **Build Memory Issues**
- System is pre-configured with 4 CPU cores and 2 max parallel jobs
- If builds still fail: temporarily reduce with `--cores 2 --max-jobs 1`

#### **Locale Configuration**
```bash
# Current setup: US English with Italian regional settings
i18n.defaultLocale = "en_US.UTF-8";
# Regional settings for Italy (dates, currency, etc.)
```

#### **Version Compatibility**
- **System Version**: 25.11 (updates with `nixos-rebuild`)
- **State Version**: 24.05 (compatibility layer, should NOT be changed)
- These are different by design for system stability

#### **Hardware Acceleration Issues**
```bash
# Check graphics status
lspci | grep -i gpu
# Hardware acceleration automatically enabled via:
hardware.graphics.enable = true;
```

#### **Fish Shell Not Default**
```bash
# Verify Fish is set as default shell
echo $SHELL  # Should show /run/current-system/sw/bin/fish
# If not, run: sudo chsh -s $(which fish) $(whoami)
```

#### **Yazi Preview Issues**
```bash
# Check required dependencies
which glow bat file ffmpegthumbnailer
# All should be available in PATH
# Rich preview plugin automatically configured
```

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