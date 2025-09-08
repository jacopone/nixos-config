#!/usr/bin/env python3
"""
Update system-level CLAUDE.md with current NixOS tool inventory.
Parses packages.nix and home-manager configuration to extract available tools.
"""

import re
import subprocess
import os
from pathlib import Path
from typing import Dict, List, Set
from datetime import datetime

def extract_packages_from_nix_file(file_path: Path) -> Dict[str, str]:
    """Extract package names and descriptions from a Nix file."""
    packages = {}
    
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Match package declarations with optional comments
        # Patterns like: pkgname # comment or pkgname; # comment
        patterns = [
            r'^\s*([a-zA-Z0-9_.-]+)\s*;\s*#\s*(.+)$',  # pkgname; # comment
            r'^\s*([a-zA-Z0-9_.-]+)\s*#\s*(.+)$',      # pkgname # comment
            r'^\s*([a-zA-Z0-9_.-]+)\s*;\s*$',          # pkgname; (no comment)
            r'^\s*([a-zA-Z0-9_.-]+)\s*$',              # pkgname (no comment, no semicolon)
        ]
        
        lines = content.split('\n')
        in_packages_section = False
        
        for line in lines:
            # Skip comments and empty lines
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue
            
            # Check if we're in a packages section
            if 'systemPackages' in line or 'home.packages' in line:
                in_packages_section = True
                continue
            elif stripped.startswith(']') and in_packages_section:
                in_packages_section = False
                continue
            
            if in_packages_section:
                # Try each pattern
                for pattern in patterns:
                    match = re.match(pattern, line)
                    if match:
                        pkg_name = match.group(1)
                        description = match.group(2) if len(match.groups()) > 1 else ""
                        
                        # Skip certain patterns
                        if pkg_name.startswith('pkgs.') or pkg_name in ['with', 'pkgs']:
                            continue
                        
                        # Clean up package name
                        pkg_name = pkg_name.replace('pkgs.', '').strip()
                        
                        # Extract meaningful package names
                        if pkg_name and not pkg_name.startswith(('(', '{')):
                            packages[pkg_name] = description.strip()
                        break
    
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    
    return packages

def extract_fish_abbreviations(home_config_path: Path) -> Dict[str, str]:
    """Extract fish shell abbreviations from home-manager config."""
    abbreviations = {}
    
    try:
        with open(home_config_path, 'r') as f:
            content = f.read()
        
        # Find abbreviations in fish config
        abbr_pattern = r'abbr -a (\w+) [\'"]([^\'"]+)[\'"]'
        matches = re.findall(abbr_pattern, content)
        
        for abbr, command in matches:
            abbreviations[abbr] = command
    
    except Exception as e:
        print(f"Error extracting fish abbreviations: {e}")
    
    return abbreviations

def get_command_description(cmd: str) -> str:
    """Get a brief description of a command using system help."""
    try:
        # Try different ways to get command description
        for help_flag in ['--help', '-h', 'help']:
            try:
                result = subprocess.run(
                    [cmd, help_flag], 
                    capture_output=True, 
                    text=True, 
                    timeout=5
                )
                if result.returncode == 0 and result.stdout:
                    # Extract first line of help that looks like a description
                    lines = result.stdout.split('\n')
                    for line in lines[:10]:  # Check first 10 lines
                        line = line.strip()
                        if line and not line.startswith(cmd) and len(line) > 20:
                            return line[:100] + "..." if len(line) > 100 else line
                break
            except:
                continue
    except:
        pass
    
    return ""

def update_claude_md():
    """Update the system-level CLAUDE.md file."""
    
    # Paths
    config_dir = Path.home() / "nixos-config"
    packages_file = config_dir / "modules" / "core" / "packages.nix"
    home_config_file = config_dir / "modules" / "home-manager" / "base.nix"
    claude_md_path = Path.home() / ".claude" / "CLAUDE.md"
    
    print("🔍 Analyzing NixOS configuration...")
    
    # Extract packages
    system_packages = extract_packages_from_nix_file(packages_file)
    print(f"Found {len(system_packages)} system packages")
    
    # Extract fish abbreviations
    fish_abbreviations = extract_fish_abbreviations(home_config_file)
    print(f"Found {len(fish_abbreviations)} fish abbreviations")
    
    # Generate tool sections
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Read current CLAUDE.md to preserve manual sections
    current_content = ""
    if claude_md_path.exists():
        with open(claude_md_path, 'r') as f:
            current_content = f.read()
    
    # Extract manual sections (everything after "## Maintenance")
    manual_sections = ""
    if "## Maintenance" in current_content:
        manual_sections = "\n## Maintenance" + current_content.split("## Maintenance", 1)[1]
    
    # Create tool categories
    dev_tools = {}
    file_tools = {}
    system_tools = {}
    network_tools = {}
    other_tools = {}
    
    # Categorize packages
    for pkg, desc in system_packages.items():
        desc_lower = (pkg + " " + desc).lower()
        
        if any(word in desc_lower for word in ['git', 'code', 'editor', 'develop', 'compile', 'build', 'debug']):
            dev_tools[pkg] = desc
        elif any(word in desc_lower for word in ['file', 'find', 'search', 'grep', 'ls', 'cat', 'tree', 'manager']):
            file_tools[pkg] = desc
        elif any(word in desc_lower for word in ['system', 'process', 'monitor', 'htop', 'disk', 'memory']):
            system_tools[pkg] = desc
        elif any(word in desc_lower for word in ['network', 'http', 'wget', 'curl', 'nmap']):
            network_tools[pkg] = desc
        else:
            other_tools[pkg] = desc
    
    # Generate new CLAUDE.md content
    new_content = f"""# System-Level CLAUDE.md

This file provides Claude Code with comprehensive information about all available tools and utilities on this NixOS system.

*Last updated: {timestamp}*

## System Information

- **OS**: NixOS (nixos-unstable)
- **Desktop**: GNOME (Wayland)
- **Shell**: Fish (with smart command substitutions)
- **Terminal**: Kitty (optimized for AI development)
- **Package Management**: Nix Flakes + Home Manager

## Available Command Line Tools

### Development Tools
"""
    
    for pkg, desc in sorted(dev_tools.items()):
        desc_text = f" - {desc}" if desc else ""
        new_content += f"- `{pkg}`{desc_text}\n"
    
    new_content += "\n### File Management & Search Tools\n"
    for pkg, desc in sorted(file_tools.items()):
        desc_text = f" - {desc}" if desc else ""
        new_content += f"- `{pkg}`{desc_text}\n"
    
    new_content += "\n### System Monitoring & Process Management\n"
    for pkg, desc in sorted(system_tools.items()):
        desc_text = f" - {desc}" if desc else ""
        new_content += f"- `{pkg}`{desc_text}\n"
    
    new_content += "\n### Network & Security Tools\n"
    for pkg, desc in sorted(network_tools.items()):
        desc_text = f" - {desc}" if desc else ""
        new_content += f"- `{pkg}`{desc_text}\n"
    
    new_content += "\n### Other Tools\n"
    for pkg, desc in sorted(other_tools.items()):
        desc_text = f" - {desc}" if desc else ""
        new_content += f"- `{pkg}`{desc_text}\n"
    
    # Add fish abbreviations
    if fish_abbreviations:
        new_content += "\n## Fish Shell Abbreviations (Auto-expand)\n\n"
        for abbr, command in sorted(fish_abbreviations.items()):
            new_content += f"- `{abbr}` → `{command}`\n"
    
    # Add preserved manual sections
    new_content += manual_sections
    
    # Write updated file
    try:
        claude_md_path.parent.mkdir(parents=True, exist_ok=True)
        with open(claude_md_path, 'w') as f:
            f.write(new_content)
        print(f"✅ Updated {claude_md_path}")
        print(f"📊 Total tools documented: {len(system_packages)}")
    except Exception as e:
        print(f"❌ Error writing CLAUDE.md: {e}")

if __name__ == "__main__":
    update_claude_md()