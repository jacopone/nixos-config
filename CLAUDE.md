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
7. **Optional push** to remote repository

**Key safety features:**
- Rollback capability if changes are rejected
- Pre-activation testing to prevent broken systems
- Interactive generation management

## Known Issues & Current Status

### System Package Linking Issue (High Priority)
**Problem**: Executables from `environment.systemPackages` are not being linked into `/run/current-system/sw/bin/` during `nixos-rebuild switch`, despite successful build completion.

**Symptoms**:
- `which kitty` returns "no kitty" even though kitty is in `environment.systemPackages`
- Yazi rich previews fail because `bat` and `glow` are "not found"
- System appears to build successfully but packages are not available in PATH

**Investigation needed**: Why system activation is not correctly creating symlinks for system packages.

### Current Tool Configurations
- **Kitty**: Configured with Catppuccin Mocha theme and Fish shell integration
- **Yazi**: Configured with rich-preview plugin for enhanced file previews  
- **Fish**: Set as default user shell with z plugin for directory jumping
- **Development tools**: Comprehensive setup including multiple editors (Helix, Zed, VSCode, Cursor)

### References
- **ZaneyOS inspiration**: `https://gitlab.com/Zaney/zaneyos`
- **Yazi module reference**: `https://github.com/typovrak/nixos-yazi`