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

### Claude Code Sandboxing
- `claude` - Normal interactive use (full access)
- `claude-sandboxed [project-dir]` - Kernel-level isolation with network (for autonomous tasks)
- `claude-airgapped [project-dir]` - Full isolation, no network (for code review)

Use `claude-sandboxed` when running with `--dangerously-skip-permissions` for long-running autonomous tasks. It provides:
- Process/IPC/UTS namespace isolation
- Filesystem restricted to project + ~/.claude only
- All Linux capabilities dropped
- Network access preserved for API calls

Use `claude-airgapped` for pure offline code review with zero network access.

## Project Structure
- `flake.nix` - Main configuration entry point
- `modules/core/packages.nix` - System-wide packages
- `modules/home-manager/` - User configs and shell setup
- `hosts/` - Hardware-specific configuration per machine
- `scripts/` - Automation scripts (rebuild helpers, changelog, cleanup)
- `docs/` - Architecture docs, guides, and plans
- `extensions/` - Browser extensions (Playwright MCP bridge)
- `overlays/` - Nix package overlays
- `pkgs/` - Custom Nix packages

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

## Git Workflow

This repo uses a two-branch model with automatic syncing:

- **`personal`** - Primary working branch. All development happens here.
- **`master`** - Public-facing branch. Auto-synced by CI, sanitized of personal paths.

### Rules — READ BEFORE ANY GIT OPERATION
- **ALWAYS** work on `personal` branch — check with `git branch` before committing
- **ALWAYS** commit and push to `personal` — NEVER push to `master`
- **NEVER** manually merge, push, or commit to `master` (CI handles this automatically)
- If you are on `master`, switch first: `git checkout personal`
- This applies to ALL machines (Framework, MacBook, ThinkPad, any host)

### Why no manual commits to master?
CI creates new commits on master (squashed, sanitized) with different hashes. Direct pushes to master cause conflicts because the same content exists with different commit history. The CI workflow `.github/workflows/sync-to-master.yml` syncs changes with sanitization.

## Do Not Touch
- `/etc/nixos/` (use this repo instead)
- `result` symlinks (Nix build artifacts)
- `hosts/*/hardware-configuration.nix` (auto-generated per machine)

## 📝 User Memory & Notes
<!-- USER_MEMORY_START -->
<!-- This section preserves your personal notes and #memory entries across rebuilds -->
<!-- Add your content below this line -->
<!-- USER_MEMORY_END -->

---

## Dynamic Context

**MCP-NixOS** is configured in `.mcp.json` for real-time package/option queries.
Full analytics available in `.claude/tool-analytics.md` and `.claude/mcp-analytics.md`.
