#!/usr/bin/env bash

# PRD to Epic Conversion System
# Automatically converts Product Requirements Documents to Technical Epics
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
SCRIPT_NAME="PRD to Epic Converter"

echo -e "${PURPLE}🔄 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}=================================${NC}"
echo ""

# Get script directory and project context
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
AI_ORCHESTRATION_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Function to validate CCPM structure
validate_ccpm_structure() {
    local project_dir="$1"
    
    if [[ ! -d "$project_dir/.claude" ]]; then
        echo -e "${RED}❌ CCPM structure not found. Run ccpm-bridge.sh first.${NC}"
        return 1
    fi
    
    if [[ ! -d "$project_dir/.claude/prds" ]]; then
        echo -e "${RED}❌ PRDs directory not found in .claude structure.${NC}"
        return 1
    fi
    
    if [[ ! -d "$project_dir/.claude/epics" ]]; then
        echo -e "${RED}❌ Epics directory not found in .claude structure.${NC}"
        return 1
    fi
    
    return 0
}

# Function to scan for PRDs
scan_prds() {
    local prd_dir="$1"
    local prds=()
    
    echo -e "${YELLOW}🔍 Scanning for PRDs in .claude/prds/...${NC}"
    
    if [[ -d "$prd_dir" ]]; then
        while IFS= read -r -d '' file; do
            if [[ -f "$file" && "$file" == *.md ]]; then
                prds+=("$file")
            fi
        done < <(find "$prd_dir" -name "*.md" -type f -print0)
    fi
    
    if [[ ${#prds[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  No PRD files found in .claude/prds/${NC}"
        echo -e "${BLUE}💡 Create a PRD file (e.g., user-authentication.md) to get started${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Found ${#prds[@]} PRD file(s):${NC}"
    for i in "${!prds[@]}"; do
        local filename=$(basename "${prds[$i]}")
        echo -e "   $((i+1)). $filename"
    done
    
    echo "${prds[@]}"
    return 0
}

# Function to analyze PRD and extract key components
analyze_prd() {
    local prd_file="$1"
    local prd_name=$(basename "$prd_file" .md)
    
    echo -e "${BLUE}🔍 Analyzing PRD: $prd_name${NC}"
    
    # Extract key sections from PRD
    local overview=""
    local requirements=""
    local acceptance_criteria=""
    local technical_considerations=""
    
    # Read PRD content
    local content=""
    if [[ -f "$prd_file" ]]; then
        content=$(cat "$prd_file")
    else
        echo -e "${RED}❌ PRD file not found: $prd_file${NC}"
        return 1
    fi
    
    # Extract sections using simple parsing
    # This is a basic implementation - can be enhanced with more sophisticated parsing
    
    # Look for common PRD sections
    if echo "$content" | grep -qi "overview\|summary\|description"; then
        overview=$(echo "$content" | sed -n '/[Oo]verview\|[Ss]ummary\|[Dd]escription/,/^#/p' | head -20)
    fi
    
    if echo "$content" | grep -qi "requirements\|features\|functionality"; then
        requirements=$(echo "$content" | sed -n '/[Rr]equirements\|[Ff]eatures\|[Ff]unctionality/,/^#/p' | head -30)
    fi
    
    if echo "$content" | grep -qi "acceptance\|criteria\|success"; then
        acceptance_criteria=$(echo "$content" | sed -n '/[Aa]cceptance\|[Cc]riteria\|[Ss]uccess/,/^#/p' | head -20)
    fi
    
    # Store analysis results
    export PRD_NAME="$prd_name"
    export PRD_OVERVIEW="$overview"
    export PRD_REQUIREMENTS="$requirements"  
    export PRD_ACCEPTANCE_CRITERIA="$acceptance_criteria"
    export PRD_CONTENT="$content"
    
    echo -e "${GREEN}✅ PRD analysis complete${NC}"
    return 0
}

# Function to generate technical epic from PRD analysis
generate_epic() {
    local prd_name="$1"
    local epic_file="$PROJECT_DIR/.claude/epics/${prd_name}-epic.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${BLUE}🏗️  Generating technical epic from PRD...${NC}"
    
    cat > "$epic_file" << EOF
# Technical Epic: ${prd_name}

**Generated from PRD**: ${prd_name}.md  
**Date**: ${timestamp}  
**Project**: ${PROJECT_NAME}  
**Status**: Draft  

## Epic Overview

This technical epic defines the implementation strategy for the **${prd_name}** feature based on the product requirements document.

### Product Context
${PRD_OVERVIEW}

## Technical Architecture

### System Components

#### Backend Requirements
- **API Endpoints**: Define RESTful/GraphQL endpoints for ${prd_name} functionality
- **Database Schema**: Design tables/collections for data persistence
- **Business Logic**: Implement core ${prd_name} operations
- **Authentication**: Integrate with existing auth system
- **Validation**: Input validation and error handling
- **Testing**: Unit tests and integration tests

#### Frontend Requirements  
- **User Interface**: Design ${prd_name} user interactions
- **State Management**: Handle ${prd_name} application state
- **API Integration**: Connect frontend to backend services
- **User Experience**: Responsive design and accessibility
- **Error Handling**: User-friendly error messages
- **Testing**: Component tests and e2e scenarios

#### Infrastructure Requirements
- **Deployment**: CI/CD pipeline updates for ${prd_name}
- **Monitoring**: Logging and metrics for ${prd_name} features
- **Performance**: Optimization and caching strategies
- **Security**: Security considerations and threat modeling
- **Scalability**: Handle expected load and growth

## Implementation Tasks

### Phase 1: Foundation
- [ ] **Database Design**: Create schema for ${prd_name} data
- [ ] **API Specification**: Design endpoints and data contracts
- [ ] **Authentication Integration**: Ensure proper access control
- [ ] **Basic CRUD Operations**: Implement core data operations

### Phase 2: Core Functionality
- [ ] **Business Logic**: Implement ${prd_name} core features
- [ ] **Frontend Components**: Build user interface elements
- [ ] **API Integration**: Connect frontend to backend
- [ ] **Error Handling**: Comprehensive error management

### Phase 3: Enhancement & Polish
- [ ] **User Experience**: Optimize interactions and flow
- [ ] **Performance Optimization**: Improve response times
- [ ] **Testing Coverage**: Comprehensive test suite
- [ ] **Documentation**: API docs and user guides

### Phase 4: Deployment & Monitoring
- [ ] **Production Deployment**: Release to production environment
- [ ] **Monitoring Setup**: Implement logging and alerts
- [ ] **Performance Monitoring**: Track metrics and usage
- [ ] **Bug Fixes & Iteration**: Address issues and improvements

## Technical Specifications

### API Endpoints
\`\`\`
# Primary endpoints for ${prd_name}
GET    /api/${prd_name}           # List/search ${prd_name} items
POST   /api/${prd_name}           # Create new ${prd_name}
GET    /api/${prd_name}/:id       # Get specific ${prd_name}
PUT    /api/${prd_name}/:id       # Update ${prd_name}
DELETE /api/${prd_name}/:id       # Delete ${prd_name}
\`\`\`

### Database Schema
\`\`\`sql
-- Basic schema structure for ${prd_name}
-- Adjust based on specific requirements
CREATE TABLE ${prd_name} (
  id SERIAL PRIMARY KEY,
  -- Add specific fields based on PRD requirements
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
\`\`\`

### Frontend Components
\`\`\`
${prd_name}/
├── components/
│   ├── ${prd_name}List.tsx       # List view
│   ├── ${prd_name}Detail.tsx     # Detail view  
│   ├── ${prd_name}Form.tsx       # Create/edit form
│   └── ${prd_name}Card.tsx       # Item display
├── hooks/
│   └── use${prd_name}.ts         # Custom hooks
├── services/
│   └── ${prd_name}Api.ts         # API integration
└── types/
    └── ${prd_name}.types.ts      # TypeScript definitions
\`\`\`

## Acceptance Criteria

Based on PRD requirements:
${PRD_ACCEPTANCE_CRITERIA}

### Technical Acceptance Criteria
- [ ] All API endpoints return appropriate status codes
- [ ] Frontend components render without errors
- [ ] Database operations handle edge cases properly
- [ ] Authentication and authorization work correctly
- [ ] Error messages are user-friendly and informative
- [ ] Performance meets defined benchmarks
- [ ] Security vulnerabilities addressed
- [ ] Tests achieve >80% code coverage

## GitHub Issues Mapping

This epic should be broken down into the following GitHub Issues:

1. **Backend Foundation** - Database schema and basic API
2. **Frontend Components** - UI components and state management  
3. **Integration** - Connect frontend to backend
4. **Testing** - Comprehensive test coverage
5. **Documentation** - API docs and user guides
6. **Deployment** - Production release and monitoring

## Agent Assignment

For AI Orchestration workflow:

- **Strategic Coordinator** (Claude Code): Epic planning and coordination
- **Backend Implementation** (Cursor): API, database, and server logic
- **Frontend Implementation** (v0.dev): UI components and user experience
- **Quality Assurance** (Gemini Pro): Testing and validation
- **Integration Synthesis** (Claude Code): Final integration and deployment

## Success Metrics

- [ ] Feature fully functional in production
- [ ] User acceptance criteria met
- [ ] Performance benchmarks achieved
- [ ] Security requirements satisfied
- [ ] Documentation complete
- [ ] Team knowledge transfer completed

## Notes

- This epic was automatically generated from PRD: ${prd_name}.md
- Review and refine technical specifications based on project context
- Coordinate with stakeholders before implementation begins
- Update epic status as implementation progresses

---

**Epic Status**: Draft → Planning → In Progress → Review → Complete  
**Generated by**: PRD to Epic Converter v${SCRIPT_VERSION}  
**Last Updated**: ${timestamp}
EOF

    echo -e "${GREEN}✅ Technical epic generated: ${epic_file}${NC}"
    return 0
}

# Function to update context with new epic
update_context() {
    local prd_name="$1"
    local context_file="$PROJECT_DIR/.claude/context/project-epics.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${BLUE}📝 Updating project context...${NC}"
    
    # Create or update the project epics context file
    if [[ ! -f "$context_file" ]]; then
        cat > "$context_file" << EOF
# Project Epics Context

This file tracks all technical epics for the $PROJECT_NAME project.

**Last Updated**: ${timestamp}

## Active Epics

### ${prd_name}-epic
- **Status**: Draft
- **Generated**: ${timestamp}
- **PRD Source**: ${prd_name}.md
- **Epic File**: epics/${prd_name}-epic.md

EOF
    else
        # Append to existing file
        cat >> "$context_file" << EOF

### ${prd_name}-epic
- **Status**: Draft  
- **Generated**: ${timestamp}
- **PRD Source**: ${prd_name}.md
- **Epic File**: epics/${prd_name}-epic.md
EOF
    fi
    
    echo -e "${GREEN}✅ Context updated: ${context_file}${NC}"
    return 0
}

# Function to suggest GitHub Issues
suggest_github_issues() {
    local prd_name="$1"
    
    echo -e "${CYAN}🐙 Suggested GitHub Issues for ${prd_name}:${NC}"
    echo ""
    
    cat << EOF
Create these GitHub Issues to track epic implementation:

1. **[Backend] ${prd_name} Foundation**
   - Labels: backend, epic:${prd_name}
   - Assignee: Backend Developer / Cursor Agent
   - Description: Database schema and basic API endpoints

2. **[Frontend] ${prd_name} UI Components** 
   - Labels: frontend, epic:${prd_name}
   - Assignee: Frontend Developer / v0.dev Agent
   - Description: User interface and state management

3. **[Integration] ${prd_name} API Integration**
   - Labels: integration, epic:${prd_name}
   - Assignee: Full-stack Developer / Claude Code
   - Description: Connect frontend to backend services

4. **[Testing] ${prd_name} Test Coverage**
   - Labels: testing, epic:${prd_name}
   - Assignee: QA Engineer / Gemini Pro Agent
   - Description: Unit, integration, and e2e tests

5. **[Docs] ${prd_name} Documentation**
   - Labels: documentation, epic:${prd_name}
   - Assignee: Technical Writer / Claude Code
   - Description: API docs and user guides

6. **[DevOps] ${prd_name} Deployment**
   - Labels: devops, epic:${prd_name}
   - Assignee: DevOps Engineer / Claude Code
   - Description: CI/CD and production deployment

To create these issues automatically, run:
cd $PROJECT_DIR && ~/nixos-config/ai-orchestration/scripts/github-issues-creator.sh ${prd_name}
EOF
    
    echo ""
}

# Main conversion workflow
main() {
    echo -e "${BLUE}🔄 Starting PRD to Epic conversion...${NC}"
    
    # Validate CCPM structure
    if ! validate_ccmp_structure "$PROJECT_DIR"; then
        exit 1
    fi
    
    # Scan for PRDs
    local prds_output
    if ! prds_output=$(scan_prds "$PROJECT_DIR/.claude/prds"); then
        exit 1
    fi
    
    # Convert output to array
    read -ra prds <<< "$prds_output"
    
    if [[ ${#prds[@]} -eq 1 ]]; then
        # Single PRD - convert automatically
        local prd_file="${prds[0]}"
        local prd_name=$(basename "$prd_file" .md)
        
        echo -e "${GREEN}➡️  Converting PRD: $prd_name${NC}"
        
        if analyze_prd "$prd_file"; then
            generate_epic "$prd_name"
            update_context "$prd_name"
            suggest_github_issues "$prd_name"
            
            echo ""
            echo -e "${PURPLE}🎉 PRD to Epic conversion complete!${NC}"
            echo -e "${GREEN}✅ Epic generated: .claude/epics/${prd_name}-epic.md${NC}"
            echo -e "${GREEN}✅ Context updated: .claude/context/project-epics.md${NC}"
            echo ""
        fi
    else
        # Multiple PRDs - let user choose
        echo ""
        echo -e "${YELLOW}Select PRD to convert:${NC}"
        for i in "${!prds[@]}"; do
            local filename=$(basename "${prds[$i]}")
            echo -e "${GREEN}$((i+1)))${NC} $filename"
        done
        echo -e "${GREEN}$((${#prds[@]}+1)))${NC} Convert all PRDs"
        echo ""
        
        read -p "Enter choice [1-$((${#prds[@]}+1))]: " choice
        
        if [[ "$choice" -eq "$((${#prds[@]}+1))" ]]; then
            # Convert all PRDs
            echo -e "${BLUE}🔄 Converting all PRDs...${NC}"
            for prd_file in "${prds[@]}"; do
                local prd_name=$(basename "$prd_file" .md)
                echo -e "${GREEN}➡️  Converting: $prd_name${NC}"
                
                if analyze_prd "$prd_file"; then
                    generate_epic "$prd_name"
                    update_context "$prd_name"
                fi
            done
            
            echo ""
            echo -e "${PURPLE}🎉 All PRDs converted to epics!${NC}"
            echo ""
        elif [[ "$choice" -ge 1 && "$choice" -le "${#prds[@]}" ]]; then
            # Convert selected PRD
            local prd_file="${prds[$((choice-1))]}"
            local prd_name=$(basename "$prd_file" .md)
            
            echo -e "${GREEN}➡️  Converting PRD: $prd_name${NC}"
            
            if analyze_prd "$prd_file"; then
                generate_epic "$prd_name"
                update_context "$prd_name" 
                suggest_github_issues "$prd_name"
                
                echo ""
                echo -e "${PURPLE}🎉 PRD to Epic conversion complete!${NC}"
                echo -e "${GREEN}✅ Epic generated: .claude/epics/${prd_name}-epic.md${NC}"
                echo ""
            fi
        else
            echo -e "${RED}❌ Invalid choice${NC}"
            exit 1
        fi
    fi
    
    echo -e "${BLUE}💡 Next Steps:${NC}"
    echo -e "${CYAN}1. Review generated epic in .claude/epics/${NC}"
    echo -e "${CYAN}2. Create GitHub Issues for epic tasks${NC}"
    echo -e "${CYAN}3. Run hybrid orchestration to implement epic${NC}"
    echo -e "${CYAN}4. Track progress in GitHub and .claude/context${NC}"
    echo ""
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi