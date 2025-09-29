# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# NixOS Configuration

## Project Overview

This repository contains a NixOS configuration managed with Nix Flakes. It defines the complete configuration for a NixOS system, including system-level packages, services, and user-specific settings managed by `home-manager`.

The system is configured with:
*   **Hostname:** `nixos`
*   **Desktop Environment:** GNOME
*   **User:** `guyfawkes`

## Essential Commands

### System Management
*   **Apply configuration and switch:** `sudo nixos-rebuild switch --flake .`
*   **Test configuration without switching:** `nixos-rebuild test --flake .`
*   **Interactive rebuild with safety checks:** `./rebuild-nixos`
*   **Update flake inputs:** `nix flake update`
*   **Check for syntax errors:** `nix flake check`
*   **Build without switching:** `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`

### Development Environment
*   **Enter development shell:** `nix develop` or `devenv shell`
*   **Ad-hoc packages:** `nix shell nixpkgs#<package-name>`
*   **Search nixpkgs:** `nix search nixpkgs <package-name>`

### AI Orchestration System
*   **Master Orchestrator:** `./ai-orchestration/scripts/master-orchestrator.sh`
*   **Project Inception Wizard:** Select option 0 after choosing "Experienced User" mode
*   **Platform Optimization:** Supports Google One Ultra, Cursor Pro, Lovable + Supabase
*   **CCPM Integration:** Complete project management with PRD → Epic → Issues workflow
*   **Claude Flow:** `claude-flow` or `npx claude-flow@alpha` - Enterprise-grade AI agent orchestration platform
    - Quick start: `npx claude-flow@alpha init` or `npx claude-flow@alpha hive-mind wizard`
    - Swarm intelligence: `claude-flow swarm "build API"` 
    - Hive mind coordination with multi-agent workflows


## Architecture Overview

This configuration uses a modular structure with separation of concerns:

### Core Structure
*   **`flake.nix`**: Entry point defining inputs (nixpkgs, home-manager) and system configuration
*   **`hosts/nixos/`**: Host-specific configuration including hardware settings and system-level imports
*   **`modules/`**: Reusable configuration modules
    - `core/packages.nix`: System-wide package definitions 
    - `home-manager/base.nix`: User-specific configurations and dotfiles
*   **`users/guyfawkes/`**: User-specific home-manager configuration (imports base.nix)
*   **`profiles/desktop/`**: Desktop environment profiles (GNOME setup)

### Package Management Strategy
*   **System packages**: Defined in `modules/core/packages.nix` via `environment.systemPackages`
*   **User packages**: Managed through home-manager in `modules/home-manager/base.nix`
*   **Dotfiles**: Configured via `home.file` declarations in home-manager modules

## Development Conventions

### Adding Packages
*   **System-wide tools**: Add to `modules/core/packages.nix` in `environment.systemPackages`
*   **User-specific programs**: Add to `home.packages` in `modules/home-manager/base.nix`
*   **Program configuration**: Use `home.file` for dotfiles or enable programs via home-manager modules

### Configuration Changes
*   **Test before switching**: Always use `nixos-rebuild test --flake .` first
*   **Use the rebuild script**: `./rebuild-nixos` provides interactive safety checks
*   **Hardware-specific changes**: Modify files in `hosts/nixos/` directory
*   **Keep modules focused**: Each module should have a single responsibility

## Rebuild Script Workflow

The `./rebuild-nixos` script provides a safe, interactive rebuild process:

1. **Update flake inputs** (`nix flake update`)
2. **Test build** without activation to catch errors early
3. **Switch configuration** (`sudo nixos-rebuild switch --flake .`)
4. **🤖 Update Claude Code tool intelligence** - automatically generates behavioral policies for AI agents
5. **User verification** - prompts to accept or rollback changes
6. **Git integration** - stage changes and prompt for commit message
7. **Generation cleanup** - interactively remove old system generations
8. **Cache cleanup** - interactive removal of large cache directories (UV, Chrome, Yarn, Playwright)
9. **Optional push** to remote repository

**Key safety features:**
- Rollback capability if changes are rejected
- Pre-activation testing to prevent broken systems
- Interactive generation management
- Smart cache detection and cleanup with size reporting
- **Automated Claude Code intelligence updates** - ensures AI agents use modern tools

## Current Status & Working Features

### Successfully Implemented ✅
- **Modular Configuration**: Fully migrated to ZaneyOS-inspired structure with `hosts/`, `modules/`, `users/`, and `profiles/` directories
- **Kitty Terminal**: Advanced optimizations with JetBrains Mono Nerd Font, programming ligatures, performance tuning for AI tool outputs, powerline tabs, and comprehensive keyboard shortcuts
- **Yazi File Manager**: Full rich preview functionality working with enhanced file previews for markdown, JSON, CSV, and other formats
- **Fish Shell**: Set as default user shell with z plugin for directory jumping and smart command substitutions
- **Starship Prompt**: Visual git display with Nerd Font symbols (`~/nixos-config  main [✱2✚1⇡3] (+15/-3) ❯`)
- **Development Environment**: Comprehensive tool setup with multiple editors (Helix, Zed, VSCode, Cursor)
- **AI Orchestration System**: Complete CCPM integration with Project Inception Wizard, platform optimization for Google One Ultra/Cursor Pro/Lovable, and unified Master Orchestrator interface
- **Performance Optimization**: Memory management tuning with optimized swap settings, zram compression, and build process limitations
- **Automated Maintenance**: Enhanced rebuild script with cache cleanup, weekly garbage collection, and monthly system updates
- **Chrome Configuration**: Consumer account-compatible policy management with extension lifecycle tracking

### Tool Configurations Working
- **Rich Preview**: Successfully rendering markdown files with syntax highlighting and formatting
- **File Dependencies**: All yazi dependencies resolved including `fdfind` compatibility symlink
- **System Packages**: Proper linking and availability in PATH
- **Home Manager Integration**: Seamless integration for user-specific configurations
- **Visual Git Integration**: Starship prompt shows real-time git branch, status indicators, and change metrics
- **Smart Fish Commands**: Context-aware command substitutions (bat/eza for interactive, cat/ls for scripts)

### Migration Completed
The NixOS configuration has been successfully migrated from a monolithic structure to a modular, maintainable system:
- Host-specific configurations isolated in `hosts/nixos/`
- Reusable modules organized in `modules/core/` and `modules/home-manager/`
- User configurations managed through `users/guyfawkes/`
- Desktop profiles properly structured in `profiles/desktop/`

## Performance Optimization & Maintenance

### Memory Management
The system includes optimized kernel parameters for desktop performance:
- **Swappiness**: Reduced from 60 to 10 for desktop use
- **VFS Cache Pressure**: Set to 50 for better file cache management  
- **Zram Swap**: 25% of RAM with zstd compression for faster swap
- **Build Limitations**: CPU cores limited to 4, max parallel jobs to 2

### Automated Maintenance Schedule
| **Frequency** | **Task** | **Status** |
|---------------|----------|-----------|
| **Weekly** | Nix garbage collection | ✅ **Automated** |
| **Monthly** | System updates | ✅ **Automated** |
| **Interactive** | Cache cleanup via rebuild script | ✅ **Enhanced** |
| **Interactive** | Generation management | ✅ **Enhanced** |

### System Monitoring Commands
```bash
# Quick system health check
free -h && uptime && df -h / | tail -1

# Process monitoring
htop          # Interactive process viewer
procs         # Modern process list
btm           # System monitor

# Disk analysis  
dua           # Disk usage analyzer
dust          # Directory sizes
```

### Cache Management
The rebuild script automatically detects and offers to clean:
- **UV Python cache** (typically 1-6GB)
- **Google Chrome cache** (typically 1-5GB)
- **Yarn/PNPM caches** (typically 0.5-2GB each)
- **MS Playwright cache** (typically 1-2GB)
- **Other development caches**

## Chrome Configuration Notes (Final Solution - Universal Extensions)

### Current Architecture: Universal Extension Management
- **Declarative Extension Control**: All extensions managed via NixOS `programs.chromium`
- **Universal Availability**: All 15 extensions available in every profile
- **No Policy Conflicts**: Only extension management, no settings policies
- **Reality-Based Solution**: Works within Chrome's browser-wide policy limitations

### Final Solution Summary
After discovering that **Chrome enterprise policies are browser-wide, not profile-specific**, the system evolved to a practical universal extension approach:

```nix
programs.chromium = {
  enable = true;
  extensions = [
    # All 15 extensions available to all profiles
    "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    "nkbihfbeogaeaoehlefnkodbefgpgknn" # MetaMask
    "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN
    # ... complete list
  ];
};
```

### Profile Usage Strategy
| Profile | Account Type | Extension Usage Strategy |
|---------|--------------|------------------------|
| Default (Gmail) | Consumer | Use: MetaMask, NordVPN, React DevTools, themes |
| Profile 1 (Tenuta) | Corporate | Use: Grammarly, Google Docs, business tools |
| Profile 2 (Slanciamoci-J) | Corporate | Use: Business tools + admin extensions |
| Profile 6 (Slanciamoci-M) | Corporate | Use: Role-specific business tools |

### Key Evolution & Lessons Learned
- ✅ **Phase 1**: Removed conflicting enterprise policies from NixOS
- ✅ **Phase 2**: Built enterprise policy detection and profile-specific strategies
- ✅ **Phase 3**: **Discovered Chrome Limitation** - policies are browser-wide only
- ✅ **Phase 3**: **Implemented Universal Solution** - all extensions available everywhere
- ✅ **Final**: Simple, declarative, working system within Chrome's constraints

### Documentation Location
- **Primary Strategy**: `~/nixos-config/stack-management/chrome-profiles/CHROME-MULTI-PROFILE-STRATEGY.md`
- **Analysis Tools**: `~/nixos-config/stack-management/chrome-profiles/automation/`
- **Legacy Docs**: Preserved for reference but superseded by universal approach

**Result**: Pragmatic solution that provides full declarative extension management while working within Chrome's technical limitations.

## Advanced Claude Code Integration System

### Revolutionary Tool Selection Automation

This system features **automated Claude Code behavior optimization** that ensures AI agents leverage the full sophisticated CLI toolkit instead of defaulting to basic POSIX commands.

#### **The Problem We Solved**
- Claude Code was defaulting to `find`, `ls`, `cat`, `grep` instead of modern alternatives
- Despite having 110+ premium CLI tools installed, AI agents used basic commands
- Manual intervention was required to specify tool preferences
- Tool knowledge was static and became outdated with system changes

#### **The Solution: Intelligent Tool Selection Policy Engine**

**Automated System Components:**
1. **`scripts/update-claude-tools.py`** - Enhanced automation engine
2. **Behavioral Policy Generation** - Mandatory tool substitution rules
3. **System-Level Context Updates** - Updates `~/.claude/CLAUDE.md` automatically
4. **Integration with `./rebuild-nixos`** - Zero-maintenance automation

#### **How It Works**

**Every `./rebuild-nixos` execution:**
```bash
# Lines 24-30 in rebuild-nixos script
echo "--> Updating Claude Code tool inventory..."
if python3 scripts/update-claude-tools.py; then
    echo "✅ Claude tools inventory updated successfully"
```

**What the enhanced script generates:**
- **Tool inventory**: All 110+ installed tools with descriptions
- **Mandatory substitution rules**: `find` → `fd`, `ls` → `eza`, etc.
- **Command examples**: Specific usage patterns for each tool
- **File analysis priorities**: JSON→jless, YAML→yq, CSV→csvlook
- **Expert-level declarations**: Forces Claude Code to use advanced tools

**Result**: Claude Code automatically receives this context:
```markdown
## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY
**SYSTEM OPTIMIZATION LEVEL: EXPERT**
**ALWAYS default to advanced tools, not basic POSIX commands.**

### MANDATORY Tool Substitutions (Use These ALWAYS)
- `find` → `fd` (ALWAYS use fd for file searching)
- `ls` → `eza` (ALWAYS use eza for directory listing)
- `cat` → `bat` (ALWAYS use bat for file viewing)
```

#### **Key Benefits**

✅ **Self-Maintaining**: Updates automatically with system changes
✅ **Behavioral Enforcement**: Claude Code can't ignore tool preferences
✅ **Zero Manual Work**: No need to manually specify tool choices
✅ **Expert-Level Optimization**: Forces use of sophisticated toolkit
✅ **Context-Aware**: Adapts to current system state and available tools

#### **Technical Implementation Details**

**Script Location**: `scripts/update-claude-tools.py`
**Target File**: `~/.claude/CLAUDE.md` (system-level Claude Code instructions)
**Trigger**: Automatically executed by `./rebuild-nixos`
**Scope**: 110+ tools across development, file management, system monitoring, data processing

**Example Output Categories:**
- **Development Tools**: ast-grep, semgrep, tokei, hyperfine
- **File Operations**: fd, eza, bat, dust, procs, jless
- **Data Processing**: jq, yq, miller, choose, csvkit
- **System Monitoring**: procs, bottom, duf, dust

**The system ensures that every Claude Code session automatically leverages the full modern CLI ecosystem while maintaining optimal system/project-level tool distribution.**

### **Strategic Tool Distribution**

**System-Level (Universal)**: Database CLI tools (`pgcli`, `mycli`, `usql`), AI development tools (`aider`, `atuin`, `broot`, `mise`), API testing (`hurl`), universal file processing tools.

**Project-Level (Context-Specific)**: Code quality tools (`gitleaks`, `typos`, `pre-commit`) managed via `devenv.nix` or `package.json` with project-specific configurations, formatters/linters with team-specific rules, testing frameworks appropriate to each project.

This architecture provides AI agents with consistent tool access while ensuring projects maintain reproducible, team-collaborative configurations without version conflicts.

### References
- **ZaneyOS inspiration**: `https://gitlab.com/Zaney/zaneyos`
- **Yazi module reference**: `https://github.com/typovrak/nixos-yazi`
- **Chrome Enterprise Policies**: `https://chromeenterprise.google/policies/`
- **Enhanced Script**: `scripts/update-claude-tools.py` (automated tool selection engine)