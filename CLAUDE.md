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

### AI Orchestration
- `./ai-orchestration/scripts/master-orchestrator.sh` - Master control system
- `claude-flow` or `npx claude-flow@alpha` - Enterprise AI coordination
- `ai filename.py` - Quick AI pair programming session
- `aicode src/*.py` - Pre-configured Claude Sonnet session

### Modern CLI Tools (ALWAYS USE THESE)
- `fd` instead of `find` - Fast file searching
- `eza` instead of `ls` - Enhanced directory listing
- `bat` instead of `cat` - Syntax-highlighted file viewing
- `rg` instead of `grep` - Ultra-fast text search
- `dua` instead of `du` - Interactive disk usage
- `procs` instead of `ps` - Modern process viewer
- `jless` instead of `less` for JSON files
- `yq` for YAML processing
- `glow` for markdown rendering

## Project Structure
- `flake.nix` - Main configuration entry point
- `modules/core/packages.nix` - System-wide packages (113 tools)
- `modules/home-manager/base.nix` - User configs and Fish shell setup
- `hosts/nixos/` - Hardware-specific configuration
- `basb-system/` - Building a Second Brain knowledge management
- `ai-orchestration/` - Multi-agent AI coordination system
- `stack-management/` - Technology stack lifecycle management

## Development Conventions

### Adding Packages
- **System tools**: Add to `modules/core/packages.nix`
- **User programs**: Add to `modules/home-manager/base.nix`
- **Project-specific**: Use `devenv.nix` or `shell.nix`

### Configuration Changes
- Always run `nix flake check` before rebuilding
- Use `./rebuild-nixos` for interactive safety checks
- Test with `nixos-rebuild test --flake .` first
- Keep modules focused on single responsibilities

### Code Style
- Follow existing Nix formatting conventions
- Use descriptive comments for complex configurations
- Group related packages logically
- Include URLs for package references when helpful

## Working Features ✅
- Fish shell with 57 smart abbreviations
- Yazi file manager with rich previews
- Starship prompt with visual git status
- Auto-updating Claude Code tool intelligence
- BASB knowledge management system
- AI orchestration with CCPM integration
- Chrome declarative extension management

## Do Not Touch
- `/etc/nixos/` (use this repo instead)
- `result` symlinks (Nix build artifacts)
- Files in `hosts/nixos/hardware-configuration.nix` (auto-generated)

## Special Notes
- System uses automated Claude Code optimization (updates tool knowledge automatically)
- Fish shell context-aware commands (different behavior for interactive vs automated)
- Chrome extensions managed declaratively via NixOS
- BASB system integrated with Google Workspace + Sunsama + Readwise

## Architecture Philosophy
- **System-level tools**: Universal access for AI agents (113 tools in `packages.nix`)
- **Project-level tools**: Context-specific via devenv/package.json
- **Modular design**: Inspired by ZaneyOS architecture
- **AI-first optimization**: Tools selected for Claude Code compatibility

## Performance Optimization
- Build limited to 4 CPU cores, 2 parallel jobs
- Zram swap (25% RAM) with zstd compression
- Weekly garbage collection + monthly updates automated
- Interactive cache cleanup (UV, Chrome, Yarn, Playwright)

## System Status
- **Git Status**: clean
- **Last Updated**: 2025-09-30 10:41:54
- **Fish Abbreviations**: 57
- **Total System Tools**: 113

---
*Auto-updated by ./rebuild-nixos script*