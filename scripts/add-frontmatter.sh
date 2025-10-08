#!/usr/bin/env bash
# Script to add YAML frontmatter to markdown files
# Usage: ./scripts/add-frontmatter.sh

set -euo pipefail
shopt -s globstar nullglob  # Enable ** glob and handle no matches gracefully

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROCESSED=0
SKIPPED=0
TODAY=$(date +%Y-%m-%d)

add_frontmatter() {
    local file="$1"
    local status="$2"
    local type="$3"
    local lifecycle="$4"
    local created="${5:-$TODAY}"

    # Check if frontmatter already exists
    if head -1 "$file" | grep -q '^---$'; then
        echo -e "${YELLOW}⏭️  Skipping (has frontmatter): $file${NC}"
        ((SKIPPED++))
        return
    fi

    # Create temporary file with frontmatter
    cat > "${file}.tmp" << EOF
---
status: $status
created: $created
updated: $TODAY
type: $type
lifecycle: $lifecycle
---

EOF

    # Append original content
    cat "$file" >> "${file}.tmp"

    # Replace original
    mv "${file}.tmp" "$file"

    echo -e "${GREEN}✅ Added frontmatter: $file${NC}"
    echo "   status=$status, type=$type, lifecycle=$lifecycle"
    ((PROCESSED++))
}

echo "📋 Adding YAML frontmatter to markdown files..."
echo ""

# ARCHITECTURE DOCS (persistent, active)
if [ -f "docs/architecture/CLAUDE_ORCHESTRATION.md" ]; then
    add_frontmatter "docs/architecture/CLAUDE_ORCHESTRATION.md" "active" "architecture" "persistent" "2025-10-03"
fi
if [ -f "docs/THE_CLOSED_LOOP.md" ]; then
    add_frontmatter "docs/THE_CLOSED_LOOP.md" "active" "architecture" "persistent" "2025-10-06"
fi

# GUIDES (persistent, active)
for file in docs/guides/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "active" "guide" "persistent"
done

for file in docs/tools/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "active" "guide" "persistent"
done

for file in docs/analysis/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "active" "guide" "persistent"
done

# BASB GUIDES (persistent, active)
for file in basb-system/BASB-*.md; do
    if [[ "$file" =~ (IMPLEMENTATION-SUMMARY|CHROME-) ]]; then
        continue  # Skip session notes
    fi
    [ -f "$file" ] && add_frontmatter "$file" "active" "guide" "persistent"
done

# BASB SESSION NOTES (ephemeral, archived)
for file in basb-system/*SUMMARY*.md basb-system/CHROME-*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "archived" "session-note" "ephemeral" "2025-10-01"
done

# PLANNING DOCS (ephemeral, draft - should be archived)
for file in docs/planning/active/**/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "draft" "planning" "ephemeral" "2025-10-05"
done

# AUTOMATION DOCS (ephemeral/planning, draft)
for file in docs/automation/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "draft" "planning" "ephemeral" "2025-10-07"
done

# STACK MANAGEMENT (reference, active)
if [ -f "stack-management/README.md" ]; then
    add_frontmatter "stack-management/README.md" "active" "reference" "persistent"
fi

for file in stack-management/active/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "active" "reference" "persistent"
done

for file in stack-management/chrome-profiles/**/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "active" "reference" "persistent"
done

if [ -f "stack-management/CHROME-EXTENSIONS.md" ]; then
    add_frontmatter "stack-management/CHROME-EXTENSIONS.md" "active" "reference" "persistent"
fi

# STACK DISCOVERY (ephemeral, draft)
for file in stack-management/discovery/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "draft" "reference" "ephemeral"
done

# DEPRECATED (archived or deprecated)
for file in stack-management/deprecated/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "deprecated" "reference" "ephemeral"
done

# ROOT DOCS (reference, active)
if [ -f "README.md" ]; then
    add_frontmatter "README.md" "active" "reference" "persistent" "2024-06-01"
fi

if [ -f "CHANGELOG.md" ]; then
    add_frontmatter "CHANGELOG.md" "active" "reference" "persistent" "2024-06-01"
fi

# TEMPLATES (reference, active)
if [ -f "templates/README.md" ]; then
    add_frontmatter "templates/README.md" "active" "reference" "persistent"
fi

# INTEGRATIONS (reference, active)
for file in docs/integrations/*.md; do
    [ -f "$file" ] && add_frontmatter "$file" "active" "reference" "persistent"
done

# BASB README (reference, active)
if [ -f "basb-system/README.md" ]; then
    add_frontmatter "basb-system/README.md" "active" "reference" "persistent" "2024-08-01"
fi

if [ -f "basb-system/README-QUICKSTART.md" ]; then
    add_frontmatter "basb-system/README-QUICKSTART.md" "active" "guide" "persistent"
fi

echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "   ✅ Processed: $PROCESSED files"
echo "   ⏭️  Skipped: $SKIPPED files"
echo ""
echo -e "${GREEN}✨ Done!${NC}"
