#!/usr/bin/env bash

# Post-commit hook: Auto-update documentation based on changes
# Runs after successful commits to keep docs in sync with code

echo ""
echo "📝 Auto-Documentation Update (Post-Commit)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get last commit info
LAST_COMMIT=$(git log -1 --pretty=format:"%H")
COMMIT_MSG=$(git log -1 --pretty=format:"%s")

echo "📋 Last commit: $COMMIT_MSG"
echo ""

# Detect what changed in the last commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

# Check if code files changed (requiring API doc updates)
CODE_CHANGED=false
if echo "$CHANGED_FILES" | grep -qE '\.(js|ts|tsx|py)$'; then
  CODE_CHANGED=true
fi

# Check if config files changed (requiring setup doc updates)
CONFIG_CHANGED=false
if echo "$CHANGED_FILES" | grep -qE '(package\.json|pyproject\.toml|\.env\.example|devenv\.nix)$'; then
  CONFIG_CHANGED=true
fi

# 1. Update API documentation (if TypeScript/JavaScript changed)
if [ "$CODE_CHANGED" = true ]; then
  if [ -f package.json ] && grep -q '"typedoc"' package.json 2>/dev/null; then
    echo "📚 Updating API documentation (TypeDoc)..."
    npm run docs 2>/dev/null && echo "  ✅ API docs updated" || echo "  ⚠️  TypeDoc not configured (skipping)"
  elif [ -f pyproject.toml ]; then
    echo "📚 Checking Python docstring coverage..."
    # Note: interrogate not in nixpkgs, would need to be in project's uv dependencies
    if command -v interrogate &> /dev/null; then
      interrogate -v . > .quality/docstring-coverage.txt 2>&1 && echo "  ✅ Docstring coverage recorded"
    else
      echo "  ℹ️  Install interrogate via 'uv add interrogate' for docstring tracking"
    fi
  fi
fi

# 2. Update README badges/stats (if significant changes)
if [ -f README.md ]; then
  echo "📊 Checking if README stats need updating..."

  # Extract current stats
  if [ -f .quality/stats.json ]; then
    TOTAL_LOC=$(cat .quality/stats.json | jq '.Total.code' 2>/dev/null || echo "N/A")
    echo "  • Total LOC: $TOTAL_LOC"
  fi

  # If README has a stats section, remind to update it
  if grep -q "<!-- STATS -->" README.md 2>/dev/null; then
    echo "  ℹ️  README has stats section - consider updating"
  fi
fi

# 3. Update CHANGELOG (if not already part of commit)
if [ ! -f CHANGELOG.md ]; then
  echo ""
  echo "💡 Tip: Consider creating CHANGELOG.md to track changes"
  echo "   Template: https://keepachangelog.com/"
fi

# 4. Check for undocumented new features
NEW_EXPORTS=$(git diff HEAD~1 HEAD | grep -E '^\+.*export (function|class|const)' | wc -l)
if [ "$NEW_EXPORTS" -gt 0 ]; then
  echo ""
  echo "⚠️  Detected $NEW_EXPORTS new exports in this commit"
  echo "   Remember to add JSDoc/docstrings for public APIs"
fi

# 5. Folder structure documentation update
if echo "$CHANGED_FILES" | grep -qE '(^[^/]+/$|/.*/$)'; then
  echo ""
  echo "📁 Directory structure changed"
  echo "   Consider updating ARCHITECTURE.md if structure significantly changed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Post-commit documentation check complete"
echo ""
echo "💡 Best Practices:"
echo "   • Run 'assess-documentation' to verify doc quality"
echo "   • Update README.md when adding major features"
echo "   • Keep ARCHITECTURE.md in sync with structure changes"
echo ""
