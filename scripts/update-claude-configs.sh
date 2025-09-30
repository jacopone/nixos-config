#!/usr/bin/env bash
# Standalone script to update both CLAUDE.md configurations
# Can be run independently of rebuild-nixos for quick updates

set -e

echo "🔄 Updating Claude Code configurations..."
echo

# Change to nixos-config directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
cd "$CONFIG_DIR"

echo "📁 Working directory: $PWD"
echo

# Update system-level tool inventory (~/.claude/CLAUDE.md)
echo "🛠️  Updating system-level tool inventory (~/.claude/CLAUDE.md)..."
if python3 scripts/update-system-claude.py; then
    echo "✅ System-level Claude configuration updated"
else
    echo "❌ Failed to update system-level Claude config"
    exit 1
fi
echo

# Update project-level CLAUDE.md (./CLAUDE.md)
echo "📋 Updating project-level CLAUDE.md (./CLAUDE.md)..."
if python3 scripts/update-project-claude.py; then
    echo "✅ Project-level CLAUDE.md updated"
else
    echo "❌ Failed to update project-level CLAUDE.md"
    exit 1
fi
echo

echo "🎉 All Claude Code configurations updated successfully!"
echo
echo "📊 Summary:"
echo "   - System-level: ~/.claude/CLAUDE.md (tool inventory for Claude Code)"
echo "   - Project-level: ./CLAUDE.md (project guidance and context)"
echo
echo "💡 These files are now synchronized with your current NixOS configuration."

# Show git status if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo
    echo "📝 Git status:"
    git status --porcelain CLAUDE.md 2>/dev/null || echo "   No changes to project CLAUDE.md"
fi