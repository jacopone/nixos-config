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
- `modules/core/packages.nix` - System-wide packages (139 tools)
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
- Fish shell with smart abbreviations
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
- **System-level tools**: Universal access for AI agents (139 tools in `packages.nix`)
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
- **Last Updated**: 2025-12-24 15:36:18
- **Fish Abbreviations**: 0
- **Total System Tools**: 139

---
*Auto-updated by ./rebuild-nixos script*

## 📝 User Memory & Notes
<!-- USER_MEMORY_START -->
<!-- This section preserves your personal notes and #memory entries across rebuilds -->
<!-- Add your content below this line -->

### Quick Reference Commands
- Update automation: `nix run github:jacopone/claude-nixos-automation#update-all`
- Deploy hooks: `nix run github:jacopone/claude-nixos-automation#deploy-hooks`
- Check hook logs: `bat /tmp/*-log.txt`

### Hook System Notes
- **Modern CLI Enforcer**: Blocks find/ls/grep/cat/du/ps - use fd/eza/rg/bat/dust/procs
- **NixOS Safety Guard**: Warns about direct nixos-rebuild, use ./rebuild-nixos instead
- **Permission Auto-Learner**: Runs every 50 tool invocations, auto-adds high-confidence permissions

**Debug tips:**
- Hook logs: `/tmp/nixos-safety-guard-log.txt`, `/tmp/modern-cli-enforcer-log.txt`
- Disable hooks: `export NIXOS_SAFETY_GUARD=0` or `export MODERN_CLI_ENFORCER=0`
- Permission patterns: `python3 ~/claude-nixos-automation/claude_automation/tools/permission_suggester.py`

<!-- USER_MEMORY_END -->

## 🔌 MCP Servers

**Status**: 0/0 connected | Last checked: 2025-12-24 15:36:40

No MCP servers configured.


---
*MCP server status tracked automatically. Full analytics: `.claude/mcp-analytics.md`*

## 📦 System Tool Usage

**Installed**: 145 tools | **Used**: 31 (21%) | **Analysis period**: 30 days

**Top 5 tools**:
- **git**: 617 uses (H:34 C:583)
- **devenv**: 346 uses (H:9 C:337)
- **gh**: 161 uses (H:6 C:155)
- **fd**: 129 uses (H:0 C:129)
- **eza**: 74 uses (H:0 C:74)

⚠️ **114 dormant tools** found (unused in last 30 days)

**Human vs Claude**:
- 11 tools used by humans
- 25 tools used by Claude

---
*Tool analytics auto-generated. Full report: `.claude/tool-analytics.md`*
