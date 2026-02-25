#!/usr/bin/env bash
# Check npm package versions and show available updates
# Usage: ./scripts/update-npm-versions.sh

set -e

cd "$(dirname "$0")/.."

VERSIONS_FILE="modules/core/npm-versions.nix"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "❌ Versions file not found: $VERSIONS_FILE"
    exit 1
fi

echo "🔍 Checking npm package versions..."
echo ""

check_version() {
    local name="$1"
    local pkg="$2"
    local current
    local latest

    # Extract current version from nix file
    current=$(grep "$name" "$VERSIONS_FILE" | grep -oP '"\K[^"]+' | head -1)

    # Get latest version from npm
    latest=$(npm view "$pkg" version 2>/dev/null || echo "unknown")

    if [ "$current" = "$latest" ]; then
        echo "  ✅ $name: $current (current)"
    elif [ "$latest" = "unknown" ]; then
        echo "  ⚠️  $name: $current (npm lookup failed)"
    else
        echo "  📦 $name: $current → $latest (update available)"
    fi
}

check_version "claude-flow" "claude-flow"
check_version "bmad-method" "bmad-method"
check_version "gemini-cli" "@google/gemini-cli"
check_version "chrome-devtools-mcp" "chrome-devtools-mcp"
check_version "jules" "@google/jules"
check_version "openspec" "@fission-ai/openspec"
check_version "jscpd" "jscpd"

echo ""
echo "To update, edit $VERSIONS_FILE manually"
echo "Then run: ./rebuild-nixos"
