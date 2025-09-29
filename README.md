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

### 🤖 AI Tooling & Automation
- 🧠 **Intelligent Claude Code Integration**: Revolutionary automated system that forces Claude Code to use your premium modern CLI tools instead of basic POSIX commands
- ⚡ **Tool Selection Policy Engine**: Automatically generates mandatory substitution rules (`find` → `fd`, `ls` → `eza`, `cat` → `bat`, etc.)
- 🔄 **Self-Updating System**: Every `./rebuild-nixos` automatically updates Claude Code's tool knowledge with your latest 121+ installed tools
- 📋 **Behavioral Enforcement**: Claude Code now defaults to advanced tools with specific command examples and usage patterns
- 🎯 **Expert-Level Optimization**: System declares "EXPERT" optimization level, ensuring Claude Code leverages your sophisticated toolkit
- 🔧 **Zero Manual Intervention**: Tool inventory, behavioral policies, and command examples stay automatically synchronized

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
├── 📁 scripts/
│   └── update-claude-tools.py    # Enhanced Claude Code behavior automation engine
├── 🔧 rebuild-nixos             # Interactive rebuild script
├── 📋 flake.nix                 # Flake configuration
├── 📚 CLAUDE.md                 # AI agent instructions
├── 🤖 CLAUDE-CODE-AUTOMATION.md # Claude Code tool selection automation
├── 🐟 fish-smart-commands.md    # Fish shell documentation
└── 📖 enhanced-tools-guide.md   # Modern CLI tools guide
```

## 🚀 Setup Instructions

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

---

## 📋 Step-by-Step Setup Guide

### 1. **Enable Nix Flakes (Required)**

If starting from a fresh NixOS installation, first enable flakes system-wide:

```bash
# Edit your current configuration
sudo nano /etc/nixos/configuration.nix

# Add this to the configuration:
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Apply the change
sudo nixos-rebuild switch

# Verify flakes are enabled
nix --version  # Should show flake support
```

### 2. **Clone the Repository**

```bash
# Clone to a temporary location first
cd /tmp
git clone https://github.com/your-username/nixos-config.git
cd nixos-config

# Or clone directly if you're confident:
git clone https://github.com/your-username/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 3. **Generate Your Hardware Configuration**

Your system needs its own hardware configuration:

```bash
# Generate new hardware configuration
sudo nixos-generate-config --show-hardware-config > /tmp/new-hardware-config.nix

# Compare with existing config to see what needs updating
diff hosts/nixos/hardware-configuration.nix /tmp/new-hardware-config.nix

# Replace with your hardware configuration
sudo cp /tmp/new-hardware-config.nix hosts/nixos/hardware-configuration.nix
```

**Important hardware-specific settings to verify:**
- **File system UUIDs** (will be different on your system)
- **Boot loader configuration** (EFI vs BIOS)
- **Available kernel modules** for your hardware
- **CPU type** (Intel vs AMD microcode)

### 4. **Customize User Configuration**

Update the configuration for your username and preferences:

```bash
# Create your user directory (if your username isn't 'guyfawkes')
mkdir -p users/yourusername

# Update the main flake.nix with your username
sed -i 's/guyfawkes/yourusername/g' flake.nix

# Update the host configuration
sed -i 's/guyfawkes/yourusername/g' hosts/nixos/default.nix

# Copy and customize the user configuration
cp users/guyfawkes/home.nix users/yourusername/home.nix
```

**Essential customizations in `hosts/nixos/default.nix`:**
```nix
# Update the user account definition:
users.users.yourusername = {
  isNormalUser = true;
  description = "Your Full Name";
  extraGroups = [ "networkmanager" "wheel" ];
  packages = with pkgs; [
    # Your additional packages
  ];
};
```

### 5. **Review System Settings**

Before applying, review these key settings in `hosts/nixos/default.nix`:

```nix
# Hostname (change if desired)
networking.hostName = "nixos";

# Timezone (uncomment and set)
# time.timeZone = "Europe/Rome";  # Change to your timezone

# Locale settings (modify for your region)
i18n.defaultLocale = "en_US.UTF-8";
i18n.extraLocaleSettings = {
  LC_ADDRESS = "en_US.UTF-8";      # Change from "it_IT.UTF-8" if needed
  LC_IDENTIFICATION = "en_US.UTF-8";
  # ... update other locale settings as needed
};
```

### 6. **Apply the Configuration**

Now apply the configuration to your system:

```bash
# Method 1: Direct application (experienced users)
sudo nixos-rebuild switch --flake .

# Method 2: Interactive script with safety checks (recommended)
chmod +x rebuild-nixos
./rebuild-nixos
```

**The rebuild script will:**
- ✅ Update flake inputs to latest versions
- ✅ Test build without activation (catches errors early)
- ✅ Apply configuration with rollback option
- ✅ **Update Claude Code tool intelligence** (forces modern CLI usage)
- ✅ Prompt for user confirmation
- ✅ Offer to commit changes to git
- ✅ Clean up old generations and caches

### 7. **Post-Installation Setup**

After successful installation:

```bash
# Verify Fish shell is working
fish --version

# Check enhanced tools
show_enhanced_tools

# Test file manager
yazi

# Verify git integration in prompt
cd ~/nixos-config  # Should show git status in prompt

# Test smart commands
cat README.md      # Should use glow for markdown
ls                 # Should use eza with icons
```

### 8. **Optional: Configure Additional Settings**

#### **Set up Git (if not already configured)**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### **Configure locale and timezone**
```bash
# Check current timezone
timedatectl

# Set timezone (if using localtimed)
sudo timedatectl set-timezone Europe/Rome  # or your timezone
```

#### **Install additional fonts (if needed)**
Additional fonts can be added to `modules/core/packages.nix`:
```nix
# Add to environment.systemPackages
nerd-fonts.fira-code
nerd-fonts.source-code-pro
# ... other fonts
```

---

## 🔧 Customization Guide

### **Adding Your Own Packages**

#### System-wide packages (`modules/core/packages.nix`):
```nix
environment.systemPackages = with pkgs; [
  # Development tools
  your-editor
  your-language-runtime

  # Productivity apps
  your-browser
  your-office-suite

  # System utilities
  your-monitoring-tool
];
```

#### User-specific packages (`modules/home-manager/base.nix`):
```nix
home.packages = with pkgs; [
  your-personal-tools
];
```

### **Modifying Desktop Environment**

#### Remove unwanted GNOME apps (`profiles/desktop/gnome.nix`):
```nix
environment.gnome.excludePackages = with pkgs; [
  # Add more GNOME apps to exclude
  gnome-maps
  gnome-weather
];
```

#### Change default editor (`hosts/nixos/default.nix`):
```nix
environment.variables.EDITOR = "code";  # Change from "hx"
```

### **Customizing Terminal and Shell**

#### Modify Kitty theme (`modules/home-manager/base.nix`):
```nix
programs.kitty.settings = {
  # Change theme colors
  background = "#your-color";
  foreground = "#your-color";
};
```

#### Add Fish abbreviations:
```nix
# In programs.fish.interactiveShellInit section
abbr -a yourabbr 'your-command'
```

---

## 🛠️ Troubleshooting Setup Issues

### **Common Setup Problems**

#### **1. Hardware Configuration Issues**
```bash
# Error: "could not find any boot loader"
# Solution: Ensure your hardware-configuration.nix has correct boot settings

# For EFI systems (most modern computers):
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# For BIOS systems (older computers):
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";  # Your disk
```

#### **2. Flakes Not Working**
```bash
# Error: "experimental feature 'flakes' is not enabled"
# Solution: Enable flakes in current configuration first

sudo nano /etc/nixos/configuration.nix
# Add: nix.settings.experimental-features = [ "nix-command" "flakes" ];
sudo nixos-rebuild switch
```

#### **3. Username/UID Conflicts**
```bash
# Error: user already exists
# Solution: Either use different username or remove existing user

# Check existing users
cat /etc/passwd | grep 1000

# Option 1: Use different username in configuration
# Option 2: Remove existing user (careful!)
sudo userdel -r existinguser
```

#### **4. Build Memory Issues**
```bash
# Error: out of memory during build
# Solution: Temporarily reduce build parallelism

sudo nixos-rebuild switch --flake . --cores 2 --max-jobs 1

# Or edit hosts/nixos/default.nix to permanently reduce:
nix.settings.cores = 2;
nix.settings.max-jobs = 1;
```

#### **5. Network/DNS Issues**
```bash
# Error: cannot fetch packages
# Solution: Check network and DNS

ping 8.8.8.8
nslookup cache.nixos.org

# If DNS fails, temporarily use public DNS:
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

#### **6. Permission Issues**
```bash
# Error: permission denied for flake operations
# Solution: Ensure user is in trusted-users

# Check current setting in hosts/nixos/default.nix:
nix.settings.trusted-users = [ "root" "yourusername" ];
```

### **Rollback if Something Goes Wrong**

```bash
# List available generations
sudo nixos-rebuild list-generations

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or rollback to specific generation
sudo nixos-rebuild switch --switch-generation 42
```

### **Starting Over (Nuclear Option)**

If the configuration is completely broken:

```bash
# Boot from NixOS installer USB
# Mount your existing system
sudo mount /dev/your-root-partition /mnt
sudo mount /dev/your-boot-partition /mnt/boot

# Restore original configuration
sudo cp /mnt/etc/nixos/configuration.nix.backup /mnt/etc/nixos/configuration.nix

# Rebuild from installer
sudo nixos-install --root /mnt

# Reboot and try again
```

---

## 📋 Pre-Installation Checklist

Before starting, ensure you have:

- [ ] **Fresh NixOS installation** completed
- [ ] **Internet connection** working
- [ ] **Your hardware details** noted (GPU type, CPU type, storage layout)
- [ ] **Backup** of important data (this config replaces your current setup)
- [ ] **GitHub account** and SSH keys (for pushing changes)
- [ ] **Username chosen** (if different from 'guyfawkes')
- [ ] **Timezone identified** (e.g., "America/New_York", "Europe/London")
- [ ] **Locale preferences** decided (language, region, keyboard layout)

## ⚡ Quick Verification Commands

After installation, verify everything works:

```bash
# System info
fastfetch

# Package managers
which nix && nix --version
which npm && npm --version
which python3 && python3 --version

# Enhanced CLI tools
which eza && eza --version
which bat && bat --version
which rg && rg --version

# Desktop environment
echo $XDG_CURRENT_DESKTOP  # Should show "GNOME"
echo $XDG_SESSION_TYPE     # Should show "wayland"

# Shell integration
echo $SHELL                # Should show fish path
fish -c "echo 'Fish works'"

# Development editors
which hx && hx --version
which code && code --version
```

## 🎯 Next Steps After Setup

1. **Explore the enhanced CLI tools**: Run `show_enhanced_tools`
2. **Set up development projects**: The system includes DevEnv and Direnv
3. **Configure AI tools**: Claude Code, Plandex, and Gemini CLI are ready
4. **Customize the configuration**: Add your preferred packages and settings
5. **Set up the AI orchestration system**: Try the multi-agent coordination
6. **Join the community**: Share your configuration improvements

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
- **Quality**: `shellcheck` (shell scripts), `semgrep` (security)
- **Database CLI**: `pgcli` (PostgreSQL), `mycli` (MySQL), `usql` (universal)
- **API Testing**: `hurl` (file-based HTTP testing), `httpie`/`xh` (interactive)

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
- **Python Tools**: `uv` (package management)
- **AI Development**: `aider` (pair programming), `atuin` (smart history), `mise` (runtime management)

### System vs Project-Level Architecture

**🔧 System-Level Tools (Universal Utilities)**
- **Database CLI tools**: Always available for any project (`pgcli`, `mycli`, `usql`)
- **AI development tools**: Universal AI agent support (`aider`, `atuin`, `broot`, `mise`)
- **API testing**: Generic HTTP utilities (`hurl`, `httpie`, `xh`)
- **File management**: Universal navigation and processing tools

**📋 Project-Level Tools (Context-Specific)**
- **Code quality**: `gitleaks`, `typos`, `pre-commit` via `devenv.nix` or `package.json`
- **Formatters/Linters**: `ruff`, `black`, `eslint`, `prettier` with project-specific configs
- **Testing frameworks**: Project-appropriate versions and configurations
- **Language tools**: Runtime-specific tools managed via project environments

**Benefits:**
- ✅ AI agents get consistent, universal tool access
- ✅ Projects maintain reproducible, team-specific configurations
- ✅ No version conflicts between system and project requirements
- ✅ Optimal balance of convenience and precision

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
- **[CLAUDE-CODE-AUTOMATION.md](CLAUDE-CODE-AUTOMATION.md)** - Revolutionary Claude Code tool selection automation system
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
- **Claude Code tool intelligence update** - automatically updates AI behavior policies for 121 system tools

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