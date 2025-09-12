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
*   **Enter development shell:** `nix develop . -c -- <command>`
*   **Check package availability:** `nix-env -qaP | grep <package-name>`
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
4. **User verification** - prompts to accept or rollback changes
5. **Git integration** - stage changes and prompt for commit message
6. **Generation cleanup** - interactively remove old system generations
7. **Cache cleanup** - interactive removal of large cache directories (UV, Chrome, Yarn, Playwright)
8. **Optional push** to remote repository

**Key safety features:**
- Rollback capability if changes are rejected
- Pre-activation testing to prevent broken systems
- Interactive generation management
- Smart cache detection and cleanup with size reporting

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

### References
- **ZaneyOS inspiration**: `https://gitlab.com/Zaney/zaneyos`
- **Yazi module reference**: `https://github.com/typovrak/nixos-yazi`