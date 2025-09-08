#!/usr/bin/env bash

# Enhanced Context Sharing System
# Advanced inter-agent communication and context management
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
SCRIPT_NAME="Enhanced Context Manager"

echo -e "${PURPLE}🧠 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}=================================${NC}"
echo ""

# Configuration
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
ACTION="${1:-status}"
CONTEXT_TYPE="${2:-all}"

# Context directories
CLAUDE_DIR="$PROJECT_DIR/.claude"
CONTEXT_DIR="$CLAUDE_DIR/context"
AGENTS_DIR="$CLAUDE_DIR/agents"
EPICS_DIR="$CLAUDE_DIR/epics"

# Function to validate CCPM structure
validate_structure() {
    echo -e "${YELLOW}🔍 Validating CCPM structure...${NC}"
    
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        echo -e "${YELLOW}⚠️  .claude directory not found, initializing...${NC}"
        
        # Initialize .claude directory structure
        local ai_orchestration_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
        local ccpm_template="$ai_orchestration_root/ccpm/.claude"
        
        if [[ -d "$ccpm_template" ]]; then
            cp -r "$ccpm_template" "$CLAUDE_DIR"
            echo -e "${GREEN}✅ Initialized .claude directory structure${NC}"
        else
            echo -e "${RED}❌ CCPM template not found at: $ccpm_template${NC}"
            return 1
        fi
    fi
    
    # Create missing directories
    local dirs=("$CONTEXT_DIR" "$AGENTS_DIR" "$EPICS_DIR")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            echo -e "${GREEN}   ✅ Created: $(basename "$dir")${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ CCPM structure validated${NC}"
    return 0
}

# Function to analyze current context state
analyze_context() {
    echo -e "${BLUE}📊 Analyzing context state...${NC}"
    
    # Count files in each directory
    local context_files=$(find "$CONTEXT_DIR" -name "*.md" 2>/dev/null | wc -l)
    local agent_files=$(find "$AGENTS_DIR" -name "*.md" 2>/dev/null | wc -l)
    local epic_files=$(find "$EPICS_DIR" -name "*.md" 2>/dev/null | wc -l)
    
    echo -e "${GREEN}   📄 Context files: $context_files${NC}"
    echo -e "${GREEN}   🤖 Agent contexts: $agent_files${NC}"  
    echo -e "${GREEN}   📋 Epic files: $epic_files${NC}"
    
    # Export for other functions
    export CONTEXT_FILES="$context_files"
    export AGENT_FILES="$agent_files"
    export EPIC_FILES="$epic_files"
    
    return 0
}

# Function to create shared context templates
create_context_templates() {
    echo -e "${BLUE}📝 Creating context templates...${NC}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Project overview template
    local overview_file="$CONTEXT_DIR/project-overview.md"
    if [[ ! -f "$overview_file" ]]; then
        cat > "$overview_file" << EOF
# Project Overview: ${PROJECT_NAME}

**Created**: ${timestamp}  
**Type**: CCPM-Enhanced AI Orchestration Project  

## Project Description

[Describe your project here - what it does, who it's for, key objectives]

## Technology Stack

### Frontend
- Framework: [React/Vue/Angular]
- State Management: [Redux/Vuex/Context]
- Styling: [CSS/Styled Components/Tailwind]
- Testing: [Jest/Vitest/Cypress]

### Backend  
- Runtime: [Node.js/Python/Go/Rust]
- Framework: [Express/FastAPI/Gin/Axum]
- Database: [PostgreSQL/MySQL/MongoDB]
- Authentication: [JWT/OAuth/Custom]

### Infrastructure
- Deployment: [Docker/Kubernetes/Serverless]
- CI/CD: [GitHub Actions/GitLab CI]
- Monitoring: [DataDog/New Relic/Custom]
- Cloud: [AWS/GCP/Azure/Self-hosted]

## Architecture Overview

\`\`\`
[Add architecture diagram or description]
\`\`\`

## Key Features

1. **Feature 1**: [Description]
2. **Feature 2**: [Description]
3. **Feature 3**: [Description]

## Development Workflow

This project uses CCPM-Enhanced AI Orchestration:
- **Structured Development**: PRDs → Epics → GitHub Issues
- **AI Coordination**: Multi-agent parallel execution
- **GitHub Integration**: Real-time progress tracking
- **Context Management**: Shared knowledge between agents

## Team & Agents

### Human Team
- **Product Owner**: [Name/Role]
- **Tech Lead**: [Name/Role]
- **Developers**: [Names/Roles]

### AI Agents
- **Claude Code**: Strategic coordination and integration
- **Cursor**: Backend implementation
- **v0.dev**: Frontend implementation  
- **Gemini Pro**: Quality assurance and testing

---
*Template created by Context Manager v${SCRIPT_VERSION}*
EOF
        echo -e "${GREEN}   ✅ Created: project-overview.md${NC}"
    fi
    
    # Technical standards template
    local standards_file="$CONTEXT_DIR/technical-standards.md"
    if [[ ! -f "$standards_file" ]]; then
        cat > "$standards_file" << EOF
# Technical Standards: ${PROJECT_NAME}

**Created**: ${timestamp}  
**Purpose**: Define coding standards and conventions for all agents  

## Code Standards

### General Principles
- **DRY**: Don't Repeat Yourself
- **KISS**: Keep It Simple, Stupid
- **YAGNI**: You Aren't Gonna Need It
- **SOLID**: Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion

### Naming Conventions
- **Variables**: camelCase for JavaScript/TypeScript, snake_case for Python
- **Functions**: camelCase with descriptive names
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Files**: kebab-case for components, camelCase for utilities

### Code Organization
- **File Structure**: Follow established patterns
- **Imports**: Group by external, internal, relative
- **Comments**: Explain why, not what
- **Documentation**: JSDoc/docstrings for public APIs

## Testing Standards

### Coverage Requirements
- **Unit Tests**: >80% coverage
- **Integration Tests**: Critical paths covered
- **E2E Tests**: User workflows validated

### Testing Patterns
- **Arrange-Act-Assert**: Structure all tests consistently
- **Test Names**: Should describe the scenario and expected outcome
- **Mocking**: Use sparingly, prefer real implementations where possible

## Git Workflow

### Branch Naming
- **Features**: \`feature/epic-name-feature-description\`
- **Fixes**: \`fix/issue-description\`
- **Chores**: \`chore/task-description\`

### Commit Messages
- **Format**: \`type(scope): description\`
- **Types**: feat, fix, docs, style, refactor, test, chore
- **Description**: Imperative mood, lowercase, no period

### Pull Request Process
1. Create feature branch from main
2. Implement changes with tests
3. Update documentation
4. Create PR with description
5. Code review and approval
6. Squash and merge

## Agent-Specific Guidelines

### For Cursor (Backend)
- Follow RESTful API design principles
- Implement proper error handling and validation
- Write comprehensive tests
- Document API endpoints

### For v0.dev (Frontend)
- Follow component composition patterns
- Implement responsive design
- Ensure accessibility compliance
- Optimize for performance

### For Gemini Pro (QA)
- Focus on edge cases and error scenarios
- Validate security requirements
- Test cross-browser compatibility
- Verify performance benchmarks

### For Claude Code (Coordination)
- Maintain consistent architecture decisions
- Ensure proper integration between components
- Update documentation and context
- Coordinate release planning

---
*Standards defined by Context Manager v${SCRIPT_VERSION}*
EOF
        echo -e "${GREEN}   ✅ Created: technical-standards.md${NC}"
    fi
    
    # Communication protocol template
    local communication_file="$CONTEXT_DIR/agent-communication.md"
    if [[ ! -f "$communication_file" ]]; then
        cat > "$communication_file" << EOF
# Agent Communication Protocol

**Created**: ${timestamp}  
**Purpose**: Define how AI agents share context and coordinate work  

## Communication Principles

### Context Sharing
- **Always Update**: Agents must update context files after significant work
- **Clear Handoffs**: Document what's complete and what's needed next
- **Decision Logging**: Record architectural and technical decisions
- **Progress Tracking**: Update GitHub Issues and CCPM context

### File Conventions

#### Context Files
- \`project-overview.md\` - Overall project context
- \`technical-standards.md\` - Coding and quality standards
- \`\{epic-name\}-progress.md\` - Epic-specific progress tracking
- \`\{epic-name\}-decisions.md\` - Technical decisions for epic
- \`integration-notes.md\` - Cross-agent coordination notes

#### Agent Files
- \`\{agent\}-\{epic\}.md\` - Agent-specific context for epic
- \`\{agent\}-status.md\` - Current agent status and availability

## Handoff Protocols

### Backend → Frontend Handoff
**Cursor completes backend work and hands off to v0.dev**

1. **Update API Documentation**
   - Complete OpenAPI/Swagger specs
   - Update \`\{epic\}-api-specs.md\`
   - Include authentication details

2. **Provide Integration Details**
   - API endpoints and methods
   - Data schemas and validation
   - Error handling patterns
   - Environment setup instructions

3. **Update GitHub Issues**
   - Mark backend issues as complete
   - Comment with handoff details
   - Reference frontend issues

### Frontend → QA Handoff  
**v0.dev completes frontend work and hands off to Gemini Pro**

1. **Document UI Components**
   - Component interfaces and props
   - State management patterns
   - User interaction flows

2. **Provide Test Scenarios**
   - User workflow descriptions
   - Edge cases to validate
   - Performance expectations

3. **Setup Instructions**
   - Development environment setup
   - Build and deployment process
   - Testing data requirements

### QA → Integration Handoff
**Gemini Pro completes testing and hands off to Claude Code**

1. **Test Results Summary**
   - Pass/fail status for all test categories
   - Performance metrics
   - Security validation results

2. **Issue Documentation**
   - Bug reports with reproduction steps
   - Performance bottlenecks
   - Security concerns

3. **Deployment Readiness**
   - Production checklist completion
   - Monitoring requirements
   - Rollback procedures

## Context Update Requirements

### After Completing Work
- [ ] Update relevant context files
- [ ] Update GitHub Issue status
- [ ] Create handoff documentation
- [ ] Notify next agent (via context files)

### Before Starting Work
- [ ] Read all relevant context files
- [ ] Review previous agent's work
- [ ] Understand current project state
- [ ] Plan integration approach

## Shared Knowledge Base

### API Specifications
File: \`context/api-specifications.md\`
- Complete API documentation
- Authentication and authorization
- Data schemas and validation
- Error codes and handling

### Database Schema
File: \`context/database-schema.md\`
- Entity relationship diagrams
- Migration scripts
- Data validation rules
- Performance considerations

### User Experience Guidelines
File: \`context/ux-guidelines.md\`
- Design system components
- User interaction patterns
- Accessibility requirements
- Responsive design breakpoints

### Deployment Configuration
File: \`context/deployment-config.md\`
- Environment variables
- Infrastructure requirements
- Monitoring and logging
- Security configurations

## Emergency Protocols

### Blocking Issues
If an agent encounters a blocking issue:
1. Document the issue in \`context/blocking-issues.md\`
2. Update GitHub Issue with \`blocked\` label
3. Provide detailed problem description
4. Suggest potential solutions or workarounds

### Context Conflicts
If agents find conflicting information:
1. Create \`context/conflicts.md\` file
2. Document the conflicting information
3. Propose resolution approach
4. Update once resolved

---
*Protocol defined by Context Manager v${SCRIPT_VERSION}*
EOF
        echo -e "${GREEN}   ✅ Created: agent-communication.md${NC}"
    fi
    
    echo -e "${GREEN}✅ Context templates created${NC}"
}

# Function to create agent-specific context managers
create_agent_contexts() {
    echo -e "${BLUE}🤖 Creating agent-specific contexts...${NC}"
    
    local agents=("claude-code" "cursor" "v0dev" "gemini-pro")
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    for agent in "${agents[@]}"; do
        local agent_file="$AGENTS_DIR/${agent}-context.md"
        
        if [[ ! -f "$agent_file" ]]; then
            cat > "$agent_file" << EOF
# ${agent^} Agent Context

**Agent**: ${agent}  
**Project**: ${PROJECT_NAME}  
**Created**: ${timestamp}  
**Status**: Available  

## Agent Role & Responsibilities

### ${agent^} Specialization
$(case "$agent" in
    "claude-code")
        echo "- Strategic coordination and planning"
        echo "- Cross-agent communication and integration"
        echo "- Documentation and final synthesis"
        echo "- Deployment coordination"
        ;;
    "cursor")
        echo "- Backend development and API implementation"
        echo "- Database design and optimization"
        echo "- Server-side testing and validation"
        echo "- Performance optimization"
        ;;
    "v0dev")
        echo "- Frontend development and UI/UX"
        echo "- Component design and implementation"
        echo "- State management and data flow"
        echo "- User experience optimization"
        ;;
    "gemini-pro")
        echo "- Quality assurance and testing"
        echo "- Code review and validation"
        echo "- Security and performance testing"
        echo "- Bug detection and reporting"
        ;;
esac)

## Current Status

### Active Tasks
- [ ] No active tasks

### Completed Work
- No completed work yet

### Blocking Issues
- No blocking issues

## Context Requirements

### Required Reading
- \`context/project-overview.md\` - Project background and goals
- \`context/technical-standards.md\` - Coding and quality standards
- \`context/agent-communication.md\` - Communication protocols

### Epic-Specific Context
When working on an epic, also read:
- \`epics/\{epic-name\}-epic.md\` - Epic specification
- \`context/\{epic-name\}-progress.md\` - Current progress
- \`context/\{epic-name\}-decisions.md\` - Technical decisions

## Communication Log

### Handoffs Received
- None yet

### Handoffs Given  
- None yet

### Decisions Made
- None yet

## Work Guidelines

### Before Starting Epic Work
1. [ ] Read complete epic specification
2. [ ] Review previous agent work (if any)
3. [ ] Understand integration requirements
4. [ ] Plan implementation approach
5. [ ] Update this context with plan

### During Work
1. [ ] Update progress regularly in epic progress file
2. [ ] Document technical decisions
3. [ ] Maintain GitHub Issue status
4. [ ] Ask questions in context files if needed

### After Completing Work
1. [ ] Update all relevant context files
2. [ ] Create handoff documentation for next agent
3. [ ] Mark GitHub Issues as complete
4. [ ] Update this context with completion status

---
*Context managed by Context Manager v${SCRIPT_VERSION}*
EOF
            echo -e "${GREEN}   ✅ Created: ${agent}-context.md${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ Agent contexts created${NC}"
}

# Function to show current context status
show_context_status() {
    echo -e "${BLUE}📊 Context Status Report${NC}"
    echo ""
    
    analyze_context
    
    echo ""
    echo -e "${PURPLE}📁 Directory Structure:${NC}"
    
    if command -v tree &> /dev/null; then
        tree "$CLAUDE_DIR" -I ".git"
    else
        find "$CLAUDE_DIR" -type f -name "*.md" | head -20 | while read -r file; do
            local relative_path=${file#$CLAUDE_DIR/}
            echo -e "${CYAN}   📄 $relative_path${NC}"
        done
        
        local total_files=$(find "$CLAUDE_DIR" -type f -name "*.md" | wc -l)
        if [[ $total_files -gt 20 ]]; then
            echo -e "${YELLOW}   ... and $((total_files - 20)) more files${NC}"
        fi
    fi
    
    echo ""
    echo -e "${PURPLE}📊 Context Health:${NC}"
    
    # Check for essential files
    local essential_files=(
        "context/project-overview.md:Project overview"
        "context/technical-standards.md:Technical standards"
        "context/agent-communication.md:Communication protocol"
    )
    
    for file_desc in "${essential_files[@]}"; do
        IFS=':' read -ra parts <<< "$file_desc"
        local file_path="$CLAUDE_DIR/${parts[0]}"
        local description="${parts[1]}"
        
        if [[ -f "$file_path" ]]; then
            echo -e "${GREEN}   ✅ $description${NC}"
        else
            echo -e "${RED}   ❌ $description (missing)${NC}"
        fi
    done
    
    echo ""
}

# Function to validate context integrity
validate_context() {
    echo -e "${BLUE}🔍 Validating context integrity...${NC}"
    
    local issues=()
    
    # Check for orphaned agent contexts (agents without epics)
    if [[ -d "$AGENTS_DIR" ]]; then
        find "$AGENTS_DIR" -name "*.md" | while read -r agent_file; do
            local agent_name=$(basename "$agent_file" .md)
            # Add validation logic here if needed
        done
    fi
    
    # Check for missing context files referenced in epics
    if [[ -d "$EPICS_DIR" ]]; then
        find "$EPICS_DIR" -name "*-epic.md" | while read -r epic_file; do
            local epic_name=$(basename "$epic_file" -epic.md)
            
            # Check for expected context files
            local expected_files=(
                "$CONTEXT_DIR/${epic_name}-progress.md"
                "$CONTEXT_DIR/${epic_name}-decisions.md"
            )
            
            for expected_file in "${expected_files[@]}"; do
                if [[ ! -f "$expected_file" ]] && grep -q "$(basename "$expected_file")" "$epic_file" 2>/dev/null; then
                    echo -e "${YELLOW}   ⚠️  Referenced but missing: $(basename "$expected_file")${NC}"
                fi
            done
        done
    fi
    
    echo -e "${GREEN}✅ Context validation complete${NC}"
}

# Function to cleanup old context files
cleanup_context() {
    echo -e "${BLUE}🧹 Cleaning up old context files...${NC}"
    
    local cleanup_count=0
    
    # Remove empty files
    find "$CLAUDE_DIR" -name "*.md" -empty -type f | while read -r empty_file; do
        echo -e "${YELLOW}   🗑️  Removing empty file: $(basename "$empty_file")${NC}"
        rm "$empty_file"
        ((cleanup_count++))
    done
    
    # Archive old files (older than 30 days and not recently modified)
    local archive_dir="$CLAUDE_DIR/.archive"
    if find "$CONTEXT_DIR" -name "*.md" -mtime +30 -type f | grep -q .; then
        mkdir -p "$archive_dir"
        
        find "$CONTEXT_DIR" -name "*.md" -mtime +30 -type f | while read -r old_file; do
            local filename=$(basename "$old_file")
            local archive_path="$archive_dir/$(date +%Y%m%d)-$filename"
            
            echo -e "${YELLOW}   📦 Archiving old file: $filename${NC}"
            mv "$old_file" "$archive_path"
            ((cleanup_count++))
        done
    fi
    
    if [[ $cleanup_count -eq 0 ]]; then
        echo -e "${GREEN}   ✅ No cleanup needed${NC}"
    else
        echo -e "${GREEN}✅ Cleaned up $cleanup_count files${NC}"
    fi
}

# Main execution
main() {
    if ! validate_structure; then
        exit 1
    fi
    
    echo ""
    
    case "$ACTION" in
        "init")
            echo -e "${BLUE}🚀 Initializing enhanced context system...${NC}"
            create_context_templates
            create_agent_contexts
            echo -e "${PURPLE}✅ Context system initialized${NC}"
            ;;
        "status")
            show_context_status
            ;;
        "validate")
            validate_context
            ;;
        "cleanup")
            cleanup_context
            ;;
        "templates")
            create_context_templates
            ;;
        "agents")
            create_agent_contexts
            ;;
        *)
            echo -e "${RED}❌ Invalid action: $ACTION${NC}"
            echo -e "${YELLOW}Usage: $0 [init|status|validate|cleanup|templates|agents]${NC}"
            echo ""
            echo -e "${CYAN}Actions:${NC}"
            echo -e "${CYAN}  init      - Initialize complete context system${NC}"
            echo -e "${CYAN}  status    - Show current context status${NC}"
            echo -e "${CYAN}  validate  - Validate context integrity${NC}"
            echo -e "${CYAN}  cleanup   - Clean up old/empty context files${NC}"
            echo -e "${CYAN}  templates - Create context templates only${NC}"
            echo -e "${CYAN}  agents    - Create agent contexts only${NC}"
            exit 1
            ;;
    esac
    
    echo ""
}

# Execute main function
main "$@"