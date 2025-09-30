#!/usr/bin/env python3
"""
CLAUDE.md automation fallback - works without external dependencies.
Uses the new architecture but falls back to basic validation.
"""

import logging
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


# Basic schema validation without Pydantic
class BasicValidator:
    @staticmethod
    def validate_tool_info(data: dict[str, Any]) -> bool:
        required = ["name", "description", "category"]
        return all(key in data for key in required)

    @staticmethod
    def validate_system_config(data: dict[str, Any]) -> bool:
        required = ["timestamp", "package_count", "tool_categories"]
        return all(key in data for key in required)


# Minimal template engine without Jinja2
class SimpleTemplateEngine:
    def __init__(self, template_dir: Path):
        self.template_dir = template_dir

    def render_simple_system_template(self, context: dict[str, Any]) -> str:
        """Render system template with simple string substitution."""
        template = f"""# System-Level CLAUDE.md

This file provides Claude Code with comprehensive information about all available tools and utilities on this NixOS system.

*Last updated: {context['timestamp'].strftime('%Y-%m-%d %H:%M:%S')}*

## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY

**SYSTEM OPTIMIZATION LEVEL: EXPERT**
This system has PREMIUM modern CLI tools installed.
**ALWAYS default to advanced tools, not basic POSIX commands.**
User expects Claude Code to leverage the full modern toolkit.

### MANDATORY Tool Substitutions (Use These ALWAYS)
- `find` → `fd` (ALWAYS use fd for file searching)
- `ls` → `eza` (ALWAYS use eza for directory listing)
- `cat` → `bat` (ALWAYS use bat for file viewing, except when piping)
- `grep` → `rg` (ALWAYS use ripgrep for text search)
- `du` → `dust` (ALWAYS use dust for disk usage analysis)
- `ps` → `procs` (ALWAYS use procs for process listing)

### AI DEVELOPMENT PRIORITY TOOLS
- `serena` - Semantic code analysis MCP server (PREFERRED for code analysis)
- `aider` - AI pair programming assistant (uvx aider-chat)
- `claude-code` - Primary AI coding interface
- `claude-flow` - Enterprise AI orchestration platform

## Available Command Line Tools

"""

        # Add tool categories
        for category, tools in context.get("tool_categories", {}).items():
            template += f"### {category}\n"
            for tool in tools:
                line = f"- `{tool['name']}` - {tool['description']}"
                if tool.get("url"):
                    line += f" - {tool['url']}"
                template += line + "\n"
            template += "\n"

        # Add fish abbreviations
        if context.get("fish_abbreviations"):
            template += "## Fish Shell Abbreviations (Auto-expand)\n\n"
            for abbr in context["fish_abbreviations"]:
                template += f"- `{abbr['abbr']}` → `{abbr['command']}`\n"

        return template

    def render_simple_project_template(self, context: dict[str, Any]) -> str:
        """Render project template with simple string substitution."""
        return f"""# CLAUDE.md

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
**⚠️ Note**: Claude Code cannot run `./rebuild-nixos` (requires sudo privileges)

**For Claude Code - Configuration Testing & Updates:**
- `nix flake check` - Validate configuration syntax
- `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` - Test build configuration
- `nix flake update` - Update flake inputs
- `python3 scripts/update-claude-configs-fallback.py` - Update CLAUDE.md files
- `nix-collect-garbage` - Clean nix store (user-level)

**For User - System Application:**
- `./rebuild-nixos` - Interactive rebuild with safety checks (PREFERRED)
- `sudo nixos-rebuild switch --flake .` - Direct system rebuild
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
- `modules/core/packages.nix` - System-wide packages ({context['package_count']} tools)
- `modules/home-manager/base.nix` - User configs and Fish shell setup

## Working Features ✅
{"".join(f"- {feature}" + chr(10) for feature in context.get('working_features', []))}

## System Status
- **Git Status**: {context.get('git_status', 'unknown')}
- **Last Updated**: {context['timestamp'].strftime('%Y-%m-%d %H:%M:%S')}
- **Fish Abbreviations**: {context.get('fish_abbreviation_count', 0)}
- **Total System Tools**: {context['package_count']}

---
*Auto-updated by ./rebuild-nixos script*"""


def parse_nix_file_basic(file_path: Path) -> dict[str, Any]:
    """Basic Nix file parsing without external dependencies."""
    if not file_path.exists():
        return {"packages": {}, "count": 0}

    try:
        with open(file_path, encoding="utf-8") as f:
            content = f.read()

        packages = {}
        in_packages_section = False

        for _line_num, line in enumerate(content.split("\n"), 1):
            stripped = line.strip()

            # Skip comments and empty lines
            if not stripped or stripped.startswith("#"):
                continue

            # Check if we're entering packages section
            if "systemPackages" in line or "home.packages" in line:
                in_packages_section = True
                continue
            elif stripped.startswith("]") and in_packages_section:
                in_packages_section = False
                continue

            if in_packages_section:
                # Simple regex-like parsing
                import re

                patterns = [
                    r"^\s*([a-zA-Z0-9_.-]+)\s*;\s*#\s*(.+)$",
                    r"^\s*([a-zA-Z0-9_.-]+)\s*#\s*(.+)$",
                    r"^\s*([a-zA-Z0-9_.-]+)\s*;\s*$",
                    r"^\s*([a-zA-Z0-9_.-]+)\s*$",
                ]

                for pattern in patterns:
                    match = re.match(pattern, line)
                    if match:
                        pkg_name = match.group(1).strip().replace("pkgs.", "")
                        description = (
                            match.group(2).strip()
                            if len(match.groups()) > 1
                            else f"Package: {pkg_name}"
                        )

                        if (
                            pkg_name
                            and len(pkg_name) > 1
                            and pkg_name not in ["with", "pkgs"]
                        ):
                            # Simple categorization
                            category = "Development Tools"
                            if any(
                                word in description.lower()
                                for word in ["file", "find", "search"]
                            ):
                                category = "File Management Tools"
                            elif any(
                                word in description.lower()
                                for word in ["system", "monitor", "process"]
                            ):
                                category = "System Tools"
                            elif any(
                                word in description.lower() or word in pkg_name.lower()
                                for word in [
                                    "ai",
                                    "semantic",
                                    "analysis",
                                    "serena",
                                    "mcp",
                                ]
                            ):
                                category = "AI Development Enhancement Tools"

                            packages[pkg_name] = {
                                "name": pkg_name,
                                "description": description,
                                "category": category,
                            }
                        break

        return {"packages": packages, "count": len(packages)}

    except Exception as e:
        logging.error(f"Failed to parse {file_path}: {e}")
        return {"packages": {}, "count": 0}


def get_git_status_basic() -> str:
    """Get git status without external dependencies."""
    try:
        import subprocess

        result = subprocess.run(
            ["git", "status", "--porcelain"], capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            if not result.stdout.strip():
                return "clean"
            lines = result.stdout.strip().split("\n")
            modified = sum(1 for line in lines if line.startswith(" M"))
            added = sum(1 for line in lines if line.startswith("A"))
            untracked = sum(1 for line in lines if line.startswith("??"))
            return f"{modified}M {added}A {untracked}U"
    except Exception:
        pass
    return "unknown"


def generate_system_claude(output_path: Path, config_dir: Path) -> bool:
    """Generate system-level CLAUDE.md without external dependencies."""
    try:
        print("🔍 Analyzing NixOS configuration...")

        # Parse packages
        packages_file = config_dir / "modules" / "core" / "packages.nix"
        packages_data = parse_nix_file_basic(packages_file)

        home_file = config_dir / "modules" / "home-manager" / "base.nix"
        home_data = parse_nix_file_basic(home_file)

        # Organize by category
        all_packages = {**packages_data["packages"], **home_data["packages"]}
        tool_categories = {}
        for tool in all_packages.values():
            category = tool["category"]
            if category not in tool_categories:
                tool_categories[category] = []
            tool_categories[category].append(tool)

        # Extract fish abbreviations (basic)
        fish_abbreviations = []
        if home_file.exists():
            try:
                with open(home_file) as f:
                    content = f.read()
                import re

                abbr_pattern = r'abbr -a (\w+) [\'"]([^\'"]+)[\'"]'
                matches = re.findall(abbr_pattern, content)
                fish_abbreviations = [
                    {"abbr": abbr, "command": cmd} for abbr, cmd in matches
                ]
            except Exception:
                pass

        # Prepare context
        context = {
            "timestamp": datetime.now(),
            "package_count": len(all_packages),
            "tool_categories": tool_categories,
            "fish_abbreviations": fish_abbreviations,
            "git_status": get_git_status_basic(),
        }

        print(f"Found {context['package_count']} system packages")
        print(f"Found {len(fish_abbreviations)} fish abbreviations")

        # Render template
        template_engine = SimpleTemplateEngine(Path())
        content = template_engine.render_simple_system_template(context)

        # Write file with backup
        if output_path.exists():
            backup_path = output_path.with_suffix(
                f'.backup-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
            )
            output_path.rename(backup_path)
            print(f"Created backup: {backup_path}")

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(content)

        print(f"✅ Updated {output_path}")
        print(f"📊 Total tools documented: {context['package_count']}")
        return True

    except Exception as e:
        print(f"❌ System generation failed: {e}")
        return False


def generate_project_claude(output_path: Path, config_dir: Path) -> bool:
    """Generate project-level CLAUDE.md without external dependencies."""
    try:
        print("🔄 Updating project-level CLAUDE.md...")

        # Count packages
        packages_file = config_dir / "modules" / "core" / "packages.nix"
        home_file = config_dir / "modules" / "home-manager" / "base.nix"

        packages_data = parse_nix_file_basic(packages_file)
        home_data = parse_nix_file_basic(home_file)
        total_packages = packages_data["count"] + home_data["count"]

        # Count fish abbreviations
        fish_count = 0
        if home_file.exists():
            try:
                with open(home_file) as f:
                    content = f.read()
                import re

                fish_count = len(re.findall(r"abbr -a \w+", content))
            except Exception:
                pass

        # Working features
        working_features = [
            f"Fish shell with {fish_count} smart abbreviations",
            "Yazi file manager with rich previews",
            "Starship prompt with visual git status",
            "Auto-updating Claude Code tool intelligence",
            "Serena MCP server for semantic code analysis",
            "BASB knowledge management system",
            "AI orchestration with CCPM integration",
        ]

        # Prepare context
        context = {
            "timestamp": datetime.now(),
            "package_count": total_packages,
            "fish_abbreviation_count": fish_count,
            "git_status": get_git_status_basic(),
            "working_features": working_features,
        }

        # Render template
        template_engine = SimpleTemplateEngine(Path())
        content = template_engine.render_simple_project_template(context)

        # Write file with backup
        if output_path.exists():
            backup_path = output_path.with_suffix(
                f'.backup-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
            )
            output_path.rename(backup_path)

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(content)

        print("✅ Updated project CLAUDE.md")
        print(f"📊 Package count: {total_packages}")
        print(f"🐟 Fish abbreviations: {fish_count}")
        print(f"📁 Git status: {context['git_status']}")
        return True

    except Exception as e:
        print(f"❌ Project generation failed: {e}")
        return False


def main():
    """Main function for fallback automation."""
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    script_dir = Path(__file__).parent
    config_dir = script_dir.parent

    # Generate both files
    system_path = Path.home() / ".claude" / "CLAUDE.md"
    project_path = config_dir / "CLAUDE.md"

    system_success = generate_system_claude(system_path, config_dir)
    project_success = generate_project_claude(project_path, config_dir)

    if system_success and project_success:
        print("\n🎉 All Claude Code configurations updated successfully!")
        return 0
    else:
        print("\n❌ Some configurations failed to update")
        return 1


if __name__ == "__main__":
    sys.exit(main())
