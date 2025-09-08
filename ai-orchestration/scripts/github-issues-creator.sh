#!/usr/bin/env bash

# GitHub Issues Creator and AI Task Mapper
# Automatically creates GitHub Issues from CCPM epics and maps them to AI agents
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
SCRIPT_NAME="GitHub Issues Creator & AI Task Mapper"

echo -e "${PURPLE}🐙 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}=============================================${NC}"
echo ""

# Get script directory and project context
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
EPIC_NAME="$1"

# Function to check GitHub CLI and authentication
check_github_setup() {
    echo -e "${YELLOW}🔍 Checking GitHub setup...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not found. Install it first.${NC}"
        return 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not authenticated. Run: gh auth login${NC}"
        return 1
    fi
    
    # Check if we're in a git repository
    if ! git status &> /dev/null; then
        echo -e "${RED}❌ Not in a git repository.${NC}"
        return 1
    fi
    
    # Check if repository has remote
    if ! git remote get-url origin &> /dev/null; then
        echo -e "${RED}❌ No GitHub remote found.${NC}"
        return 1
    fi
    
    local repo_url=$(git remote get-url origin)
    echo -e "${GREEN}✅ GitHub setup validated${NC}"
    echo -e "${CYAN}   Repository: $(basename "$repo_url" .git)${NC}"
    
    return 0
}

# Function to validate epic exists
validate_epic() {
    local epic_name="$1"
    
    if [[ -z "$epic_name" ]]; then
        echo -e "${RED}❌ Epic name required. Usage: $0 <epic-name>${NC}"
        return 1
    fi
    
    local epic_file="$PROJECT_DIR/.claude/epics/${epic_name}-epic.md"
    
    if [[ ! -f "$epic_file" ]]; then
        echo -e "${RED}❌ Epic file not found: $epic_file${NC}"
        echo -e "${YELLOW}💡 Run prd-to-epic-converter.sh first${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Epic found: ${epic_name}-epic.md${NC}"
    return 0
}

# Function to create GitHub labels if they don't exist
setup_github_labels() {
    echo -e "${BLUE}🏷️  Setting up GitHub labels...${NC}"
    
    local labels=(
        "epic,purple,Epic-level work item"
        "backend,blue,Backend implementation work"  
        "frontend,green,Frontend implementation work"
        "integration,orange,Integration and coordination work"
        "testing,yellow,Testing and quality assurance"
        "documentation,gray,Documentation work"
        "devops,red,DevOps and deployment work"
        "ai-orchestration,magenta,AI orchestration workflow"
        "ccpm,cyan,CCPM project management"
    )
    
    for label_def in "${labels[@]}"; do
        IFS=',' read -ra parts <<< "$label_def"
        local name="${parts[0]}"
        local color="${parts[1]}"
        local description="${parts[2]}"
        
        # Check if label exists
        if ! gh label view "$name" &> /dev/null; then
            gh label create "$name" --color "$color" --description "$description"
            echo -e "${GREEN}   ✅ Created label: $name${NC}"
        else
            echo -e "${CYAN}   ℹ️  Label exists: $name${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ GitHub labels configured${NC}"
}

# Function to create GitHub Issues for epic
create_epic_issues() {
    local epic_name="$1"
    local epic_file="$PROJECT_DIR/.claude/epics/${epic_name}-epic.md"
    
    echo -e "${BLUE}🎯 Creating GitHub Issues for epic: $epic_name${NC}"
    echo ""
    
    # Issue templates with AI agent assignments
    declare -A issues=(
        ["backend-foundation"]="Backend Foundation,backend epic:${epic_name} ai-orchestration,Cursor Agent,Database schema and core API endpoints for ${epic_name} functionality"
        ["frontend-components"]="Frontend Components,frontend epic:${epic_name} ai-orchestration,v0.dev Agent,User interface components and state management for ${epic_name}"
        ["api-integration"]="API Integration,integration epic:${epic_name} ai-orchestration,Claude Code,Connect frontend components to backend API services"
        ["testing-coverage"]="Testing Coverage,testing epic:${epic_name} ai-orchestration,Gemini Pro Agent,Comprehensive test suite including unit and integration tests"
        ["documentation"]="Documentation,documentation epic:${epic_name} ai-orchestration,Claude Code,API documentation and user guides for ${epic_name}"
        ["deployment"]="Deployment & Monitoring,devops epic:${epic_name} ai-orchestration,Claude Code,CI/CD pipeline and production deployment setup"
    )
    
    local created_issues=()
    
    for issue_key in "${!issues[@]}"; do
        IFS=',' read -ra parts <<< "${issues[$issue_key]}"
        local title="[${epic_name}] ${parts[0]}"
        local labels="${parts[1]}"
        local assignee="${parts[2]}"
        local description="${parts[3]}"
        
        echo -e "${YELLOW}📝 Creating issue: $title${NC}"
        
        # Create comprehensive issue body
        local issue_body=$(cat << EOF
# ${parts[0]} for ${epic_name}

## Overview
${description}

## Epic Reference
This issue is part of the **${epic_name}** epic. See [\`${epic_name}-epic.md\`](./.claude/epics/${epic_name}-epic.md) for complete technical specifications.

## AI Agent Assignment
**Assigned Agent**: ${assignee}
- This issue will be implemented using AI-assisted development
- Agent-specific context will be provided in \`.claude/agents/\`
- Progress will be tracked through GitHub Issues and CCPM workflow

## Task Breakdown

### For Backend Foundation:
- [ ] Design database schema for ${epic_name} data
- [ ] Implement core API endpoints (CRUD operations)
- [ ] Set up authentication and authorization
- [ ] Add input validation and error handling
- [ ] Create unit tests for API endpoints
- [ ] Document API specifications

### For Frontend Components:
- [ ] Design user interface mockups/wireframes
- [ ] Implement React/Vue components for ${epic_name}
- [ ] Set up state management (Redux/Vuex/Context)
- [ ] Add form validation and error handling
- [ ] Implement responsive design
- [ ] Create component tests

### For API Integration:
- [ ] Connect frontend components to backend APIs
- [ ] Implement data fetching and caching strategies
- [ ] Add loading states and error handling
- [ ] Set up API client configuration
- [ ] Test end-to-end data flow
- [ ] Optimize API calls and performance

### For Testing Coverage:
- [ ] Write unit tests for individual functions/components
- [ ] Create integration tests for API endpoints
- [ ] Implement end-to-end user workflow tests
- [ ] Set up test data and fixtures
- [ ] Configure continuous testing in CI/CD
- [ ] Achieve >80% code coverage

### For Documentation:
- [ ] Write API documentation with examples
- [ ] Create user guides and tutorials
- [ ] Document deployment and setup procedures
- [ ] Update project README with ${epic_name} info
- [ ] Create troubleshooting guides
- [ ] Record demo videos if needed

### For Deployment:
- [ ] Update CI/CD pipeline for ${epic_name} components
- [ ] Configure production environment variables
- [ ] Set up monitoring and logging
- [ ] Create deployment runbooks
- [ ] Plan rollback procedures
- [ ] Performance testing and optimization

## Acceptance Criteria
- [ ] All functionality works as specified in the epic
- [ ] Code follows project conventions and standards
- [ ] Tests pass and coverage meets requirements
- [ ] Documentation is complete and accurate
- [ ] Performance meets defined benchmarks
- [ ] Security considerations addressed
- [ ] Deployed successfully to production

## GitHub Integration
- **Epic**: ${epic_name}
- **Labels**: ${labels}
- **Agent**: ${assignee}
- **Project**: ${PROJECT_NAME}

## CCPM Workflow
This issue follows the CCPM (Claude Code Project Management) methodology:
- Spec-driven development with full traceability
- Git worktrees for parallel development
- Real-time progress tracking
- Agent coordination through \`.claude/\` structure

## AI Orchestration Context
Agent-specific instructions and context will be provided in:
- \`.claude/agents/${assignee,,}-${issue_key}.md\`
- \`.claude/context/${epic_name}-${issue_key}.md\`

---
*Created by GitHub Issues Creator v${SCRIPT_VERSION}*  
*Part of CCPM-Enhanced AI Orchestration workflow*
EOF
)
        
        # Create the GitHub Issue
        local issue_url
        if issue_url=$(gh issue create \
            --title "$title" \
            --body "$issue_body" \
            --label "$labels" \
            2>/dev/null); then
            
            echo -e "${GREEN}   ✅ Created: $title${NC}"
            echo -e "${CYAN}   📎 URL: $issue_url${NC}"
            created_issues+=("$issue_url")
            
            # Add brief delay to avoid rate limiting
            sleep 1
        else
            echo -e "${RED}   ❌ Failed to create: $title${NC}"
        fi
        
        echo ""
    done
    
    if [[ ${#created_issues[@]} -gt 0 ]]; then
        echo -e "${PURPLE}🎉 Successfully created ${#created_issues[@]} GitHub Issues!${NC}"
        
        # Update CCPM context with issue links
        update_epic_with_issues "$epic_name" "${created_issues[@]}"
    else
        echo -e "${RED}❌ No issues were created successfully${NC}"
        return 1
    fi
}

# Function to update epic with GitHub Issue links
update_epic_with_issues() {
    local epic_name="$1"
    shift
    local issues=("$@")
    local epic_file="$PROJECT_DIR/.claude/epics/${epic_name}-epic.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${BLUE}📝 Updating epic with GitHub Issue links...${NC}"
    
    # Add GitHub Issues section to epic
    cat >> "$epic_file" << EOF

## GitHub Issues (Auto-Generated)

**Created**: ${timestamp}  
**Issues Created**: ${#issues[@]}

EOF
    
    local counter=1
    for issue_url in "${issues[@]}"; do
        local issue_number=$(echo "$issue_url" | grep -o '[0-9]*$')
        local issue_title=$(gh issue view "$issue_number" --json title --jq '.title' 2>/dev/null || echo "Issue #$issue_number")
        
        cat >> "$epic_file" << EOF
${counter}. **${issue_title}**
   - Issue: [#${issue_number}](${issue_url})
   - Status: Open
   - Agent Assignment: See issue description

EOF
        ((counter++))
    done
    
    cat >> "$epic_file" << EOF
## AI Orchestration Workflow

Use these GitHub Issues with the hybrid orchestration system:

\`\`\`bash
# Run hybrid orchestration with GitHub Issues integration
cd ${PROJECT_DIR}
~/nixos-config/ai-orchestration/scripts/ccpm-enhanced-universal.sh

# Select: "CCPM + GitHub Issues + AI Orchestration"
# The system will automatically coordinate agents based on issue assignments
\`\`\`

---
*GitHub Issues integration completed ${timestamp}*
EOF
    
    echo -e "${GREEN}✅ Epic updated with GitHub Issue links${NC}"
}

# Function to create agent-specific context files
create_agent_contexts() {
    local epic_name="$1"
    
    echo -e "${BLUE}🤖 Creating agent-specific context files...${NC}"
    
    # Ensure agents directory exists
    mkdir -p "$PROJECT_DIR/.claude/agents"
    
    # Agent context templates
    local agents=("cursor" "v0dev" "claude-code" "gemini-pro")
    
    for agent in "${agents[@]}"; do
        local context_file="$PROJECT_DIR/.claude/agents/${agent}-${epic_name}.md"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        cat > "$context_file" << EOF
# ${agent} Agent Context for ${epic_name}

**Epic**: ${epic_name}  
**Agent**: ${agent}  
**Created**: ${timestamp}  
**Project**: ${PROJECT_NAME}

## Agent Role

### For cursor (Backend Implementation):
- Implement database schema and API endpoints
- Handle authentication and authorization
- Create comprehensive backend tests
- Focus on performance and scalability

### For v0dev (Frontend Implementation):
- Create user interface components
- Implement responsive design
- Handle state management and API integration
- Ensure accessibility and user experience

### For claude-code (Coordination & Integration):
- Strategic planning and coordination
- API integration and testing
- Documentation and deployment
- Final synthesis and quality assurance

### For gemini-pro (Quality Assurance):
- Comprehensive testing strategy
- Code review and quality validation
- Performance and security testing
- Bug detection and resolution

## Epic Context

Reference the following files for complete context:
- **Epic Specification**: \`.claude/epics/${epic_name}-epic.md\`
- **Project Context**: \`.claude/context/project-epics.md\`
- **GitHub Issues**: See epic file for issue links

## Agent Instructions

1. **Review Epic**: Read the complete epic specification
2. **Check Issues**: Review your assigned GitHub Issues
3. **Plan Work**: Break down tasks into manageable chunks
4. **Coordinate**: Update context files with progress
5. **Test**: Validate your work before handoff
6. **Document**: Update relevant documentation

## Context Sharing

Update these files as you work:
- \`.claude/context/${epic_name}-progress.md\` - Overall progress
- \`.claude/context/${epic_name}-decisions.md\` - Technical decisions
- \`.claude/context/${epic_name}-integration.md\` - Integration notes

## Success Criteria

- [ ] All assigned GitHub Issues completed
- [ ] Code follows project standards
- [ ] Tests pass and coverage requirements met
- [ ] Documentation updated
- [ ] Integration with other agents successful
- [ ] Epic acceptance criteria satisfied

---
*Context prepared for ${agent} agent in ${epic_name} epic*
EOF
        
        echo -e "${GREEN}   ✅ Created: ${agent}-${epic_name}.md${NC}"
    done
    
    echo -e "${GREEN}✅ Agent contexts created${NC}"
}

# Main workflow
main() {
    if [[ -z "$EPIC_NAME" ]]; then
        echo -e "${RED}❌ Usage: $0 <epic-name>${NC}"
        echo -e "${YELLOW}💡 Example: $0 user-authentication${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Starting GitHub Issues creation for epic: $EPIC_NAME${NC}"
    echo ""
    
    # Validate setup
    if ! check_github_setup; then
        exit 1
    fi
    
    if ! validate_epic "$EPIC_NAME"; then
        exit 1
    fi
    
    # Setup and create
    setup_github_labels
    echo ""
    
    create_epic_issues "$EPIC_NAME"
    echo ""
    
    create_agent_contexts "$EPIC_NAME"
    echo ""
    
    # Summary and next steps
    echo -e "${PURPLE}🎉 GitHub Issues setup complete!${NC}"
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo -e "${CYAN}1. Review created GitHub Issues in your repository${NC}"
    echo -e "${CYAN}2. Run hybrid orchestration to implement epic:${NC}"
    echo -e "${YELLOW}   ~/nixos-config/ai-orchestration/scripts/ccmp-enhanced-universal.sh${NC}"
    echo -e "${CYAN}3. Select 'CCPM + GitHub Issues + AI Orchestration'${NC}"
    echo -e "${CYAN}4. Agents will coordinate using GitHub Issues and .claude/ context${NC}"
    echo ""
    echo -e "${GREEN}✅ Epic: $EPIC_NAME ready for AI orchestration implementation${NC}"
}

# Execute main function
main "$@"