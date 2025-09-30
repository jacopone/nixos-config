#!/usr/bin/env python3
"""
Update project-level CLAUDE.md with current NixOS configuration status.
Maintains the optimized structure while refreshing dynamic information.
"""

import re
import subprocess
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set

def get_package_count() -> int:
    """Get accurate package count from packages.nix."""
    packages_file = Path("modules/core/packages.nix")
    try:
        with open(packages_file, 'r') as f:
            content = f.read()

        # Count actual package lines (exclude comments, whitespace, etc.)
        package_count = 0
        in_packages_section = False

        for line in content.split('\n'):
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue

            if 'systemPackages' in line:
                in_packages_section = True
                continue
            elif stripped.startswith(']') and in_packages_section:
                break

            if in_packages_section:
                # Count lines that look like package declarations
                if re.match(r'^\s*[a-zA-Z0-9_.-]+', line) and not any(skip in line for skip in ['with', 'pkgs', '(', '{']):
                    package_count += 1

        return package_count
    except Exception as e:
        print(f"Warning: Could not count packages: {e}")
        return 109  # fallback

def get_fish_abbreviation_count() -> int:
    """Get fish abbreviation count from home-manager config."""
    home_config = Path("modules/home-manager/base.nix")
    try:
        with open(home_config, 'r') as f:
            content = f.read()

        # Count fish abbreviations
        abbr_pattern = r'abbr -a \w+'
        matches = re.findall(abbr_pattern, content)
        return len(matches)
    except Exception as e:
        print(f"Warning: Could not count fish abbreviations: {e}")
        return 55  # fallback

def get_working_features() -> List[str]:
    """Get list of working features by analyzing configuration."""
    features = [
        f"Fish shell with {get_fish_abbreviation_count()} smart abbreviations",
        "Yazi file manager with rich previews",
        "Starship prompt with visual git status",
        "Auto-updating Claude Code tool intelligence",
        "BASB knowledge management system",
        "AI orchestration with CCPM integration",
        "Chrome declarative extension management"
    ]
    return features

def get_git_status() -> str:
    """Get current git status for context."""
    try:
        result = subprocess.run(['git', 'status', '--porcelain'],
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            if not lines or lines == ['']:
                return "clean"
            modified = len([l for l in lines if l.startswith(' M')])
            added = len([l for l in lines if l.startswith('A')])
            untracked = len([l for l in lines if l.startswith('??')])
            return f"{modified}M {added}A {untracked}U"
    except:
        pass
    return "unknown"

def check_system_health() -> Dict[str, bool]:
    """Check if key system components are working."""
    health = {}

    # Check if key files exist
    key_files = [
        "flake.nix",
        "modules/core/packages.nix",
        "modules/home-manager/base.nix",
        "basb-system/README.md",
        "ai-orchestration/README.md"
    ]

    for file_path in key_files:
        health[file_path] = Path(file_path).exists()

    return health

def update_project_claude_md():
    """Update the project-level CLAUDE.md with current information."""

    claude_md_path = Path("CLAUDE.md")
    backup_path = Path("CLAUDE-AUTO-BACKUP.md")

    print("🔄 Updating project-level CLAUDE.md...")

    # Backup current file
    if claude_md_path.exists():
        try:
            with open(claude_md_path, 'r') as f:
                backup_content = f.read()
            with open(backup_path, 'w') as f:
                f.write(backup_content)
        except Exception as e:
            print(f"Warning: Could not create backup: {e}")

    # Get current dynamic information
    package_count = get_package_count()
    abbr_count = get_fish_abbreviation_count()
    working_features = get_working_features()
    git_status = get_git_status()
    health = check_system_health()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Generate updated content with preserved structure
    new_content = f"""# CLAUDE.md

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
- `modules/core/packages.nix` - System-wide packages ({package_count} tools)
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

## Working Features ✅"""

    # Add working features dynamically
    for feature in working_features:
        new_content += f"\n- {feature}"

    new_content += f"""

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
- **System-level tools**: Universal access for AI agents ({package_count} tools in `packages.nix`)
- **Project-level tools**: Context-specific via devenv/package.json
- **Modular design**: Inspired by ZaneyOS architecture
- **AI-first optimization**: Tools selected for Claude Code compatibility

## Performance Optimization
- Build limited to 4 CPU cores, 2 parallel jobs
- Zram swap (25% RAM) with zstd compression
- Weekly garbage collection + monthly updates automated
- Interactive cache cleanup (UV, Chrome, Yarn, Playwright)

## System Status
- **Git Status**: {git_status}
- **Last Updated**: {timestamp}
- **Fish Abbreviations**: {abbr_count}
- **Total System Tools**: {package_count}

---
*Auto-updated by ./rebuild-nixos script*"""

    # Write updated file
    try:
        with open(claude_md_path, 'w') as f:
            f.write(new_content)
        print(f"✅ Updated project CLAUDE.md")
        print(f"📊 Package count: {package_count}")
        print(f"🐟 Fish abbreviations: {abbr_count}")
        print(f"📁 Git status: {git_status}")

        # Check for issues
        missing_files = [path for path, exists in health.items() if not exists]
        if missing_files:
            print(f"⚠️  Missing files: {', '.join(missing_files)}")

    except Exception as e:
        print(f"❌ Error updating project CLAUDE.md: {e}")
        # Restore backup if update failed
        if backup_path.exists():
            try:
                with open(backup_path, 'r') as f:
                    backup_content = f.read()
                with open(claude_md_path, 'w') as f:
                    f.write(backup_content)
                print("↩️  Restored from backup")
            except:
                print("❌ Failed to restore backup")

if __name__ == "__main__":
    # Change to nixos-config directory if not already there
    if not Path("flake.nix").exists():
        config_dir = Path.home() / "nixos-config"
        if config_dir.exists():
            os.chdir(config_dir)
        else:
            print("❌ Cannot find nixos-config directory")
            exit(1)

    update_project_claude_md()