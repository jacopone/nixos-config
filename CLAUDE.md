# CLAUDE.md

> NixOS Configuration - Modern CLI Toolkit Optimization

## Tech Stack
- **OS**: NixOS 25.11 with Nix Flakes
- **Desktop**: GNOME (Wayland)
- **Shell**: Fish with Starship prompt
- **Terminal**: Kitty with JetBrains Mono Nerd Font
- **Package Manager**: Nix + Home Manager
- **Development**: DevEnv + Direnv for project environments

## Essential Commands

### System Management
- `./rebuild-nixos` - Interactive rebuild with safety checks (PREFERRED)
- `sudo nixos-rebuild switch --flake .` - Direct system rebuild
- `nix flake check` - Validate configuration syntax
- `nix develop` or `devenv shell` - Enter development environment

### Modern CLI Tools (ALWAYS USE THESE)
- `fd` instead of `find` - Fast file searching
- `eza` instead of `ls` - Enhanced directory listing
- `bat` instead of `cat` - Syntax-highlighted file viewing
- `rg` instead of `grep` - Ultra-fast text search
- `dua` instead of `du` - Interactive disk usage
- `procs` instead of `ps` - Modern process viewer

### AI Development Tools
- `serena` - Semantic code analysis and MCP server
- `aider` - AI pair programming (uvx aider-chat)
- `claude-flow` - Enterprise AI orchestration (npx claude-flow@alpha)

## Project Structure
- `modules/core/packages.nix` - System-wide packages (109 tools)
- `modules/home-manager/base.nix` - User configs and Fish shell setup

## Working Features ✅
- Fish shell with 55 smart abbreviations
- Yazi file manager with rich previews
- Starship prompt with visual git status
- Auto-updating Claude Code tool intelligence
- Serena MCP server for semantic code analysis
- BASB knowledge management system
- AI orchestration with CCPM integration


## System Status
- **Git Status**: 0M 0A 1U
- **Last Updated**: 2025-09-30 06:38:14
- **Fish Abbreviations**: 55
- **Total System Tools**: 109

---
*Auto-updated by ./rebuild-nixos script*