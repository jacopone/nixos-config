#!/usr/bin/env bash
# Enhanced standalone script to update both CLAUDE.md configurations v2.0
# Uses the new template-based automation system

set -e

echo "🔄 Updating Claude Code configurations (v2.0)..."
echo

# Change to nixos-config directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
cd "$CONFIG_DIR"

echo "📁 Working directory: $PWD"
echo

# Check if we can import required modules
echo "🔍 Checking dependencies..."
if ! python3 -c "import jinja2, pydantic" 2>/dev/null; then
    echo "⚠️  Missing required Python packages (jinja2, pydantic)"
    echo "    Consider installing with: pip install jinja2 pydantic"
    echo "    Falling back to legacy scripts..."

    # Fallback to legacy scripts
    if python3 scripts/update-system-claude.py; then
        echo "✅ System-level Claude configuration updated (legacy)"
    else
        echo "❌ Failed to update system-level Claude config"
        exit 1
    fi

    if python3 scripts/update-project-claude.py; then
        echo "✅ Project-level CLAUDE.md updated (legacy)"
    else
        echo "❌ Failed to update project-level CLAUDE.md"
        exit 1
    fi

    echo "🎉 Configurations updated using legacy scripts!"
    exit 0
fi

# Use new template-based system
echo "🛠️  Updating system-level tool inventory (~/.claude/CLAUDE.md)..."
if python3 scripts/update-system-claude-v2.py; then
    echo "✅ System-level Claude configuration updated"
else
    echo "❌ Failed to update system-level Claude config"
    exit 1
fi
echo

echo "📋 Updating project-level CLAUDE.md (./CLAUDE.md)..."
if python3 scripts/update-project-claude-v2.py; then
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