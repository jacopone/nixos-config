#!/usr/bin/env bash
# Sync master → personal branch
# Run this after making commits to master to keep personal branch up-to-date

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get repo root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Save current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --staged --quiet; then
    echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
    echo "Please commit or stash them before syncing branches"
    exit 1
fi

echo -e "${YELLOW}Syncing master → personal branch...${NC}"

# Switch to personal and merge master
git checkout personal
if git merge master --no-edit; then
    echo -e "${GREEN}✅ Merged master into personal${NC}"
else
    echo -e "${RED}❌ Merge conflict! Resolve manually then commit${NC}"
    exit 1
fi

# Push personal branch if there were new commits
if git log origin/personal..personal --oneline | grep -q .; then
    echo "Pushing personal branch to remote..."
    git push origin personal
fi

# Return to original branch
git checkout "$CURRENT_BRANCH"

echo -e "${GREEN}✅ personal branch is now synced with master${NC}"
echo ""
echo "Branch status:"
echo "  master:   $(git log master -1 --format='%h %s')"
echo "  personal: $(git log personal -1 --format='%h %s')"
