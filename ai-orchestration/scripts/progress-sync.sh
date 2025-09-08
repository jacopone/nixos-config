#!/usr/bin/env bash

# Real-Time Progress Synchronization System
# Syncs progress between GitHub Issues, CCPM context, and AI agents
# Phase 3: Advanced Integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script version and metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Real-Time Progress Synchronization"

echo -e "${PURPLE}🔄 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}=======================================${NC}"
echo ""

# Configuration
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
SYNC_MODE="${1:-watch}"  # watch, sync-once, or status
SYNC_INTERVAL="${2:-30}"  # seconds

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check CCPM structure
    if [[ ! -d "$PROJECT_DIR/.claude" ]]; then
        echo -e "${RED}❌ CCPM structure not found${NC}"
        return 1
    fi
    
    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not found${NC}"
        return 1
    fi
    
    # Check GitHub auth
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
        return 1
    fi
    
    # Check git repository
    if ! git status &> /dev/null; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites validated${NC}"
    return 0
}

# Function to get GitHub Issues status
get_github_status() {
    echo -e "${BLUE}🐙 Fetching GitHub Issues status...${NC}"
    
    # Get all issues with ai-orchestration label
    local issues_json
    if issues_json=$(gh issue list --label "ai-orchestration" --json number,title,state,assignees,labels --limit 100 2>/dev/null); then
        
        # Parse issues and extract relevant information
        local total_issues=$(echo "$issues_json" | jq length)
        local open_issues=$(echo "$issues_json" | jq '[.[] | select(.state == "open")] | length')
        local closed_issues=$(echo "$issues_json" | jq '[.[] | select(.state == "closed")] | length')
        
        echo -e "${GREEN}   📊 Issues: $total_issues total, $open_issues open, $closed_issues closed${NC}"
        
        # Export for other functions
        export GITHUB_ISSUES_JSON="$issues_json"
        export TOTAL_ISSUES="$total_issues"
        export OPEN_ISSUES="$open_issues"
        export CLOSED_ISSUES="$closed_issues"
        
        return 0
    else
        echo -e "${RED}   ❌ Failed to fetch GitHub Issues${NC}"
        return 1
    fi
}

# Function to analyze CCPM context status
get_ccpm_status() {
    echo -e "${BLUE}📋 Analyzing CCPM context status...${NC}"
    
    local context_dir="$PROJECT_DIR/.claude/context"
    local epics_dir="$PROJECT_DIR/.claude/epics"
    
    # Count epics
    local epic_files=()
    if [[ -d "$epics_dir" ]]; then
        while IFS= read -r -d '' file; do
            if [[ "$file" == *-epic.md ]]; then
                epic_files+=("$file")
            fi
        done < <(find "$epics_dir" -name "*.md" -type f -print0)
    fi
    
    # Count context files
    local context_files=()
    if [[ -d "$context_dir" ]]; then
        while IFS= read -r -d '' file; do
            context_files+=("$file")
        done < <(find "$context_dir" -name "*.md" -type f -print0)
    fi
    
    echo -e "${GREEN}   📊 CCPM: ${#epic_files[@]} epics, ${#context_files[@]} context files${NC}"
    
    # Export for other functions
    export CCMP_EPICS="${#epic_files[@]}"
    export CCPM_CONTEXT_FILES="${#context_files[@]}"
    
    return 0
}

# Function to sync GitHub Issue status to CCMP context
sync_github_to_ccpm() {
    echo -e "${BLUE}🔄 Syncing GitHub Issues to CCPM context...${NC}"
    
    local sync_file="$PROJECT_DIR/.claude/context/github-sync.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create sync status file
    cat > "$sync_file" << EOF
# GitHub Issues Synchronization

**Last Sync**: ${timestamp}  
**Total Issues**: ${TOTAL_ISSUES}  
**Open Issues**: ${OPEN_ISSUES}  
**Closed Issues**: ${CLOSED_ISSUES}

## Issue Status Summary

EOF
    
    # Process each issue
    if [[ -n "$GITHUB_ISSUES_JSON" ]] && [[ "$GITHUB_ISSUES_JSON" != "null" ]]; then
        echo "$GITHUB_ISSUES_JSON" | jq -r '.[] | "### Issue #\(.number): \(.title)\n- **State**: \(.state)\n- **Labels**: \(.labels | map(.name) | join(", "))\n- **Assignees**: \(.assignees | map(.login) | join(", "))\n"' >> "$sync_file"
    fi
    
    cat >> "$sync_file" << EOF

## Progress Metrics

- **Completion Rate**: $((CLOSED_ISSUES * 100 / (TOTAL_ISSUES == 0 ? 1 : TOTAL_ISSUES)))%
- **Active Issues**: ${OPEN_ISSUES}
- **Epic Count**: ${CCPM_EPICS}
- **Context Files**: ${CCPM_CONTEXT_FILES}

## Agent Coordination Status

EOF
    
    # Add agent status if available
    local agents_dir="$PROJECT_DIR/.claude/agents"
    if [[ -d "$agents_dir" ]]; then
        local agent_files=$(find "$agents_dir" -name "*.md" | wc -l)
        echo "- **Agent Context Files**: $agent_files" >> "$sync_file"
        echo "- **Agents Configured**: $(find "$agents_dir" -name "*.md" | sed 's/.*\///; s/-.*\.md//' | sort -u | wc -l)" >> "$sync_file"
    fi
    
    cat >> "$sync_file" << EOF

---
*Synchronized by Progress Sync v${SCRIPT_VERSION}*
EOF
    
    echo -e "${GREEN}   ✅ Sync file updated: .claude/context/github-sync.md${NC}"
}

# Function to update GitHub Issues with CCPM progress
sync_ccpm_to_github() {
    echo -e "${BLUE}🔄 Syncing CCPM context to GitHub Issues...${NC}"
    
    # Look for progress files in context
    local progress_files=()
    if [[ -d "$PROJECT_DIR/.claude/context" ]]; then
        while IFS= read -r -d '' file; do
            if [[ "$file" == *progress*.md ]] || [[ "$file" == *status*.md ]]; then
                progress_files+=("$file")
            fi
        done < <(find "$PROJECT_DIR/.claude/context" -name "*.md" -type f -print0)
    fi
    
    if [[ ${#progress_files[@]} -gt 0 ]]; then
        echo -e "${GREEN}   📊 Found ${#progress_files[@]} progress files${NC}"
        
        # For each progress file, try to match it to GitHub Issues
        for progress_file in "${progress_files[@]}"; do
            local filename=$(basename "$progress_file")
            echo -e "${CYAN}   📝 Processing: $filename${NC}"
            
            # Extract epic/feature name from filename
            local epic_name=$(echo "$filename" | sed 's/-progress.*\.md\|//' | sed 's/-status.*\.md//')
            
            # Find matching GitHub Issues
            if [[ -n "$GITHUB_ISSUES_JSON" ]]; then
                local matching_issues=$(echo "$GITHUB_ISSUES_JSON" | jq -r --arg epic "$epic_name" '.[] | select(.title | contains($epic)) | .number')
                
                if [[ -n "$matching_issues" ]]; then
                    echo -e "${GREEN}     🎯 Found matching issues: $matching_issues${NC}"
                    
                    # Add progress comment to issues (optional - can be enabled)
                    # Uncomment the following lines to enable automatic comments
                    # for issue_num in $matching_issues; do
                    #     local progress_content=$(head -20 "$progress_file")
                    #     gh issue comment "$issue_num" --body "**CCMP Progress Update**\n\n$progress_content\n\n---\n*Auto-updated by Progress Sync*"
                    # done
                fi
            fi
        done
    else
        echo -e "${YELLOW}   ℹ️  No progress files found in .claude/context${NC}"
    fi
}

# Function to create progress dashboard
create_progress_dashboard() {
    local dashboard_file="$PROJECT_DIR/.claude/context/progress-dashboard.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${BLUE}📊 Creating progress dashboard...${NC}"
    
    cat > "$dashboard_file" << EOF
# Project Progress Dashboard

**Project**: ${PROJECT_NAME}  
**Last Updated**: ${timestamp}  
**Sync Version**: ${SCRIPT_VERSION}

## 📈 Overall Progress

### GitHub Issues
- **Total Issues**: ${TOTAL_ISSUES}
- **Open Issues**: ${OPEN_ISSUES}
- **Closed Issues**: ${CLOSED_ISSUES}
- **Completion Rate**: $((CLOSED_ISSUES * 100 / (TOTAL_ISSUES == 0 ? 1 : TOTAL_ISSUES)))%

### CCPM Status
- **Active Epics**: ${CCPM_EPICS}
- **Context Files**: ${CCPM_CONTEXT_FILES}
- **Agent Contexts**: $(find "$PROJECT_DIR/.claude/agents" -name "*.md" 2>/dev/null | wc -l)

## 🎯 Epic Progress

EOF
    
    # Add epic-specific progress
    if [[ -d "$PROJECT_DIR/.claude/epics" ]]; then
        find "$PROJECT_DIR/.claude/epics" -name "*-epic.md" | while read -r epic_file; do
            local epic_name=$(basename "$epic_file" -epic.md)
            echo "### $epic_name Epic" >> "$dashboard_file"
            
            # Count related GitHub Issues
            if [[ -n "$GITHUB_ISSUES_JSON" ]]; then
                local epic_issues=$(echo "$GITHUB_ISSUES_JSON" | jq -r --arg epic "$epic_name" '[.[] | select(.title | contains($epic))] | length')
                local epic_open=$(echo "$GITHUB_ISSUES_JSON" | jq -r --arg epic "$epic_name" '[.[] | select(.title | contains($epic)) | select(.state == "open")] | length')
                local epic_closed=$(echo "$GITHUB_ISSUES_JSON" | jq -r --arg epic "$epic_name" '[.[] | select(.title | contains($epic)) | select(.state == "closed")] | length')
                
                echo "- **Issues**: $epic_issues total ($epic_open open, $epic_closed closed)" >> "$dashboard_file"
                if [[ $epic_issues -gt 0 ]]; then
                    echo "- **Progress**: $((epic_closed * 100 / epic_issues))%" >> "$dashboard_file"
                fi
            fi
            
            # Check for progress files
            local progress_file="$PROJECT_DIR/.claude/context/${epic_name}-progress.md"
            if [[ -f "$progress_file" ]]; then
                echo "- **Status**: Active (progress tracked)" >> "$dashboard_file"
            else
                echo "- **Status**: Planning" >> "$dashboard_file"
            fi
            
            echo "" >> "$dashboard_file"
        done
    fi
    
    cat >> "$dashboard_file" << EOF
## 🤖 AI Agent Status

EOF
    
    # Add agent status
    if [[ -d "$PROJECT_DIR/.claude/agents" ]]; then
        find "$PROJECT_DIR/.claude/agents" -name "*.md" | while read -r agent_file; do
            local agent_info=$(basename "$agent_file" .md)
            echo "- **$agent_info**: Context prepared" >> "$dashboard_file"
        done
    else
        echo "- No agent contexts configured yet" >> "$dashboard_file"
    fi
    
    cat >> "$dashboard_file" << EOF

## 📋 Quick Actions

### For Developers
- Run hybrid orchestration: \`~/nixos-config/ai-orchestration/scripts/ccpm-enhanced-universal.sh\`
- Check GitHub Issues: \`gh issue list --label ai-orchestration\`
- View epic details: \`cat .claude/epics/*.md\`

### For Project Managers
- Create new epic: \`~/nixos-config/ai-orchestration/scripts/prd-to-epic-converter.sh\`
- Generate GitHub Issues: \`~/nixos-config/ai-orchestration/scripts/github-issues-creator.sh <epic-name>\`
- Sync progress: \`~/nixos-config/ai-orchestration/scripts/progress-sync.sh sync-once\`

## 🔄 Sync Status

- **Last GitHub Sync**: ${timestamp}
- **Auto-sync**: $([[ "$SYNC_MODE" == "watch" ]] && echo "Enabled (every ${SYNC_INTERVAL}s)" || echo "Disabled")
- **Integration**: GitHub Issues ↔ CCPM Context ↔ AI Agents

---
*Dashboard generated by Progress Sync v${SCRIPT_VERSION}*
EOF
    
    echo -e "${GREEN}   ✅ Progress dashboard created: .claude/context/progress-dashboard.md${NC}"
}

# Function to perform complete sync
perform_sync() {
    echo -e "${BLUE}🔄 Performing complete synchronization...${NC}"
    echo ""
    
    # Get current status from all sources
    get_github_status
    get_ccmp_status
    
    echo ""
    
    # Sync between systems
    sync_github_to_ccpm
    sync_ccpm_to_github
    
    echo ""
    
    # Create dashboard
    create_progress_dashboard
    
    echo ""
    echo -e "${PURPLE}✅ Synchronization complete!${NC}"
    echo -e "${CYAN}📊 View dashboard: .claude/context/progress-dashboard.md${NC}"
}

# Function to watch and sync continuously
watch_and_sync() {
    echo -e "${BLUE}👁️  Starting continuous sync (every ${SYNC_INTERVAL}s)${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    
    while true; do
        echo -e "${CYAN}[$(date '+%H:%M:%S')] Syncing...${NC}"
        perform_sync
        
        echo -e "${YELLOW}Waiting ${SYNC_INTERVAL}s for next sync...${NC}"
        echo ""
        
        sleep "$SYNC_INTERVAL"
    done
}

# Function to show current status
show_status() {
    echo -e "${BLUE}📊 Current Project Status${NC}"
    echo ""
    
    get_github_status
    get_ccmp_status
    
    echo ""
    echo -e "${PURPLE}Status Summary:${NC}"
    echo -e "${GREEN}   GitHub: $TOTAL_ISSUES total issues ($OPEN_ISSUES open, $CLOSED_ISSUES closed)${NC}"
    echo -e "${GREEN}   CCPM: $CCPM_EPICS epics, $CCPM_CONTEXT_FILES context files${NC}"
    
    if [[ $TOTAL_ISSUES -gt 0 ]]; then
        echo -e "${GREEN}   Progress: $((CLOSED_ISSUES * 100 / TOTAL_ISSUES))% complete${NC}"
    fi
    
    echo ""
}

# Main execution
main() {
    if ! check_prerequisites; then
        exit 1
    fi
    
    echo ""
    
    case "$SYNC_MODE" in
        "watch")
            watch_and_sync
            ;;
        "sync-once")
            perform_sync
            ;;
        "status")
            show_status
            ;;
        *)
            echo -e "${RED}❌ Invalid sync mode: $SYNC_MODE${NC}"
            echo -e "${YELLOW}Usage: $0 [watch|sync-once|status] [interval_seconds]${NC}"
            exit 1
            ;;
    esac
}

# Handle Ctrl+C gracefully
trap 'echo -e "\n${YELLOW}🛑 Sync stopped by user${NC}"; exit 0' INT

# Execute main function
main "$@"