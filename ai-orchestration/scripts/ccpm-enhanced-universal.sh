#!/usr/bin/env bash

# CCPM-Enhanced Universal AI Orchestration Script
# Combines CCPM structured project management with dynamic multi-agent AI orchestration
# Phase 2: Hybrid Implementation

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
SCRIPT_VERSION="3.0.0"
SCRIPT_NAME="CCPM-Enhanced Universal AI Orchestration"

echo -e "${PURPLE}🌟 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}=====================================================${NC}"
echo -e "${CYAN}🏗️  CCPM Structured Management + 🤖 AI Orchestration${NC}"
echo ""

# Get script directory and project context
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
AI_ORCHESTRATION_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Function to check if we have CCPM structure
check_ccpm_structure() {
    local project_dir="$1"
    if [[ -d "$project_dir/.claude" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to initialize CCPM structure if missing
init_ccpm_structure() {
    local project_dir="$1"
    
    if ! check_ccpm_structure "$project_dir"; then
        echo -e "${BLUE}🏗️  Initializing CCPM structure...${NC}"
        # Initialize CCPM structure manually since --init-only flag doesn't exist yet
        cp -r "$AI_ORCHESTRATION_ROOT/ccpm/.claude" "$project_dir/"
        echo -e "${GREEN}✅ CCPM structure initialized${NC}"
    else
        echo -e "${GREEN}✅ CCPM structure detected${NC}"
    fi
}

# Function to detect project type and context (enhanced from original)
detect_project_context() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")
    local project_type=""
    local tech_stack=""
    local framework=""
    local backend=""
    local frontend=""
    local database=""
    local testing=""
    local ccpm_enabled=false
    local github_repo=""

    echo -e "${YELLOW}🔍 Analyzing project context for hybrid orchestration...${NC}"

    # Check for CCPM structure
    if [[ -d "$project_dir/.claude" ]]; then
        ccpm_enabled=true
        echo -e "${GREEN}   ✅ CCPM structure detected${NC}"
    fi

    # Check for GitHub repository
    if [[ -d "$project_dir/.git" ]]; then
        github_repo=$(git remote get-url origin 2>/dev/null || echo "")
        if [[ -n "$github_repo" ]]; then
            echo -e "${GREEN}   ✅ GitHub repository: $(basename "$github_repo" .git)${NC}"
        fi
    fi

    # Check for various project indicators (enhanced detection)
    if [[ -f "$project_dir/package.json" ]]; then
        tech_stack="Node.js"
        
        # Detect frontend framework
        if grep -q "react" "$project_dir/package.json" 2>/dev/null; then
            frontend="React"
            if grep -q "typescript" "$project_dir/package.json" 2>/dev/null; then
                frontend="React + TypeScript"
            fi
        fi
        if grep -q "vue" "$project_dir/package.json" 2>/dev/null; then
            frontend="Vue.js"
        fi
        if grep -q "angular" "$project_dir/package.json" 2>/dev/null; then
            frontend="Angular"
        fi
        if grep -q "next" "$project_dir/package.json" 2>/dev/null; then
            framework="Next.js"
        fi
        if grep -q "vite" "$project_dir/package.json" 2>/dev/null; then
            framework="Vite"
        fi
        if grep -q "nuxt" "$project_dir/package.json" 2>/dev/null; then
            framework="Nuxt.js"
        fi
        
        # Detect testing framework
        if grep -q "vitest" "$project_dir/package.json" 2>/dev/null; then
            testing="Vitest"
        elif grep -q "jest" "$project_dir/package.json" 2>/dev/null; then
            testing="Jest"
        elif grep -q "cypress" "$project_dir/package.json" 2>/dev/null; then
            testing="Cypress"
        elif grep -q "playwright" "$project_dir/package.json" 2>/dev/null; then
            testing="Playwright"
        fi
    fi

    # Detect backend technologies
    if [[ -d "$project_dir/backend" ]] || [[ -d "$project_dir/server" ]] || [[ -d "$project_dir/api" ]]; then
        backend="Node.js Backend"
    fi
    if [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]] || [[ -f "$project_dir/setup.py" ]]; then
        backend="Python"
    fi
    if [[ -f "$project_dir/Cargo.toml" ]]; then
        backend="Rust"
    fi
    if [[ -f "$project_dir/go.mod" ]]; then
        backend="Go"
    fi

    # Detect database
    if grep -q "postgresql\\|postgres" "$project_dir/package.json" "$project_dir/backend/package.json" 2>/dev/null; then
        database="PostgreSQL"
    elif grep -q "mysql" "$project_dir/package.json" "$project_dir/backend/package.json" 2>/dev/null; then
        database="MySQL"
    elif grep -q "mongodb\\|mongoose" "$project_dir/package.json" "$project_dir/backend/package.json" 2>/dev/null; then
        database="MongoDB"
    elif grep -q "sqlite" "$project_dir/package.json" "$project_dir/backend/package.json" 2>/dev/null; then
        database="SQLite"
    fi

    # Determine project type for hybrid orchestration
    if [[ "$ccpm_enabled" == true ]]; then
        if [[ -n "$github_repo" ]]; then
            project_type="CCPM_GITHUB_HYBRID"
        else
            project_type="CCPM_LOCAL_HYBRID"
        fi
    elif [[ -f "$project_dir/docs/AI_ORCHESTRATION.md" ]]; then
        project_type="AI_ORCHESTRATION_ENABLED"
    elif [[ -f "$project_dir/CLAUDE.md" ]]; then
        project_type="CLAUDE_ENABLED"
    else
        project_type="STANDARD_HYBRID"
    fi

    # Export detected context
    export PROJECT_NAME="$project_name"
    export PROJECT_TYPE="$project_type"
    export TECH_STACK="$tech_stack"
    export FRAMEWORK="$framework"
    export FRONTEND="$frontend"
    export BACKEND="$backend"
    export DATABASE="$database"
    export TESTING="$testing"
    export CCPM_ENABLED="$ccpm_enabled"
    export GITHUB_REPO="$github_repo"

    echo -e "${GREEN}✅ Hybrid project context detected:${NC}"
    echo -e "   📁 Name: $project_name"
    echo -e "   🎯 Type: $project_type"
    echo -e "   💻 Stack: $tech_stack"
    [[ -n "$framework" ]] && echo -e "   🔧 Framework: $framework"
    [[ -n "$frontend" ]] && echo -e "   🎨 Frontend: $frontend"
    [[ -n "$backend" ]] && echo -e "   ⚙️  Backend: $backend"
    [[ -n "$database" ]] && echo -e "   🗄️  Database: $database"
    [[ -n "$testing" ]] && echo -e "   🧪 Testing: $testing"
    [[ "$ccpm_enabled" == true ]] && echo -e "   📋 CCPM: Enabled"
    [[ -n "$github_repo" ]] && echo -e "   🐙 GitHub: Connected"
    echo ""
}

# Function to check for GitHub CLI and repository status
check_github_integration() {
    echo -e "${YELLOW}🐙 Checking GitHub integration...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub CLI not found. GitHub Issues integration limited.${NC}"
        return 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub CLI not authenticated. Run: gh auth login${NC}"
        return 1
    fi
    
    if [[ -z "$GITHUB_REPO" ]]; then
        echo -e "${YELLOW}⚠️  No GitHub repository detected.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ GitHub integration ready${NC}"
    return 0
}

# Function to generate hybrid workflow prompts
generate_hybrid_prompts() {
    local workflow_type="$1"
    local output_dir="hybrid-orchestration-$(date +%Y%m%d-%H%M%S)"
    
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}🎯 Generating ${workflow_type} hybrid workflow...${NC}"
    
    case "$workflow_type" in
        "ccpm_github")
            generate_ccpm_github_workflow "$output_dir"
            ;;
        "ccpm_local")
            generate_ccmp_local_workflow "$output_dir"
            ;;
        "adaptive_hybrid")
            generate_adaptive_hybrid_workflow "$output_dir"
            ;;
        *)
            generate_standard_hybrid_workflow "$output_dir"
            ;;
    esac
    
    echo -e "${GREEN}✅ Hybrid workflow generated in: ${output_dir}${NC}"
    echo ""
}

# Function to generate CCPM + GitHub Issues workflow
generate_ccpm_github_workflow() {
    local output_dir="$1"
    
    cat > "$output_dir/1-strategic-coordinator.md" << EOF
# Strategic Coordination with CCPM + GitHub Integration

## Project Context
- **Project**: $PROJECT_NAME
- **Type**: $PROJECT_TYPE
- **Stack**: $TECH_STACK$([[ -n "$FRAMEWORK" ]] && echo " + $FRAMEWORK")
- **CCPM**: Enabled with GitHub Issues integration
- **Repository**: $GITHUB_REPO

## Phase 1: CCMP Strategy Integration

### Task: Strategic Analysis with Spec-Driven Foundation

You are the Master Coordinator in a hybrid CCPM + AI Orchestration workflow. Your role combines:

1. **CCPM Workflow Management**
   - Use the .claude/ structure for context and requirements
   - Reference existing PRDs in .claude/prds/
   - Check for active epics in .claude/epics/
   - Follow CCPM rules in .claude/rules/

2. **GitHub Issues Integration**
   - Analyze existing GitHub Issues for this project
   - Map issues to CCMP epics and PRDs
   - Create new issues for identified gaps
   - Use GitHub Projects for progress tracking

3. **AI Orchestration Coordination**
   - Decompose work for parallel agent execution
   - Plan multi-platform coordination (Cursor, v0.dev, Gemini)
   - Design context isolation strategy
   - Prepare real-time adaptation protocols

### Specific Actions:

1. **Analyze Current State**
   - Review .claude/context/ for project requirements
   - Check .claude/epics/ for active technical specifications
   - Examine GitHub Issues for current work items
   - Assess project structure and dependencies

2. **Strategic Decomposition**
   - Break down requirements into parallel workstreams
   - Map each workstream to appropriate AI agents
   - Create GitHub Issues for each major work item
   - Design Git worktree strategy for parallel development

3. **Context Preparation**
   - Prepare agent-specific contexts in .claude/agents/
   - Update .claude/context/ with latest requirements
   - Create specific prompts for each AI platform
   - Set up progress tracking and integration checkpoints

### Expected Output:
- Updated .claude/context/ with strategic analysis
- GitHub Issues created/updated with work decomposition  
- Agent-specific context files in .claude/agents/
- Clear handoff instructions for Phase 2 (Backend) and Phase 3 (Frontend)

### Tools Available:
- Full .claude/ CCPM structure
- GitHub CLI for issues management
- Git worktrees for parallel development
- Claude Code for strategic analysis

### Success Metrics:
- All work items have corresponding GitHub Issues
- Each issue maps to a specific epic and agent
- Context is prepared for parallel execution
- Traceability from PRD to implementation is clear

Proceed with strategic analysis and coordinate the hybrid workflow.
EOF

    cat > "$output_dir/2-backend-implementation.md" << EOF
# Backend Implementation with CCPM Traceability

## Agent: Cursor (Implementation Specialist)

### Context Integration
- **Project**: $PROJECT_NAME ($BACKEND)
- **Epic Reference**: Check .claude/epics/ for backend specifications
- **GitHub Issues**: Implement tagged 'backend' issues
- **Git Worktree**: Use separate worktree for backend development

### Implementation Strategy

You are the Backend Implementation Specialist in a CCPM + AI Orchestration workflow.

#### 🚀 Cursor Optimization Settings (Premium Configuration):
**Recommended Model**: Claude 3.5 Sonnet (Latest)
**Configuration**:
```json
{
  "model": "claude-3-5-sonnet-20241022",
  "use_agents": true,
  "agent_mode": "backend_specialist", 
  "auto_mode": false
}
```

**Agent Configuration**:
- **Primary Agent**: Backend API development
- **Secondary Agent**: Database design and optimization
- **Tertiary Agent**: Testing and validation

**Why These Settings**:
- **Superior Backend Reasoning**: Claude 3.5 Sonnet excels at API design, database optimization
- **Disable Auto Mode**: Use specific model for better control and consistency
- **Enable Agents**: Use 2-3 specialized agents for different backend aspects
- **Backend Specialist Mode**: Focus on server-side development patterns

#### CCPM Integration:
1. **Spec-Driven Development**
   - Follow technical specifications in .claude/epics/
   - Reference requirements from .claude/context/
   - Update progress in GitHub Issues
   - Maintain traceability to original PRD

2. **Parallel Agent Execution**
   - Use 3 specialized agents for different backend aspects
   - Work in dedicated Git worktree (backend-implementation)
   - Coordinate with frontend agent through shared context
   - Update .claude/context/ with API specifications
   - Document decisions in .claude/epics/

#### Technical Focus:
- **Architecture**: $BACKEND$([[ -n "$DATABASE" ]] && echo " + $DATABASE")
- **Testing**: $TESTING integration
- **API Design**: RESTful/GraphQL endpoints
- **Database**: Schema design and migrations$([[ -n "$DATABASE" ]] && echo " ($DATABASE)")

#### Deliverables:
- Complete backend implementation
- API documentation in .claude/context/
- Updated GitHub Issues with progress
- Integration tests and setup instructions

### Coordination Points:
- API contract shared with Frontend agent
- Database schema documented for all agents
- Progress updates in GitHub Issues
- Integration checkpoints with Strategic Coordinator

Implement the backend following CCPM specifications with full traceability.
EOF

    cat > "$output_dir/3-frontend-implementation.md" << EOF
# Frontend Implementation with CCPM Integration

## Agent: Lovable + Supabase (Full-Stack UI Specialist)

### Context Integration  
- **Project**: $PROJECT_NAME ($FRONTEND)
- **Framework**: $FRAMEWORK
- **Epic Reference**: Frontend specifications in .claude/epics/
- **GitHub Issues**: Implement tagged 'frontend' issues
- **Git Worktree**: Use separate worktree for frontend development

### 🎨 Lovable + Supabase Integration Strategy (Premium Configuration):

**Primary Workflow**: Lovable + Supabase (Integrated)
**Secondary Tool**: Cursor with GPT-4o for complex logic

#### Integration Approach:
1. **Start Integrated**: Begin with full Lovable + Supabase workflow
2. **Export When Needed**: Move to Cursor for advanced customization  
3. **API-First Design**: Design with clear API contracts
4. **Incremental Migration**: Gradually move complex logic to Cursor

#### Why Lovable + Supabase Integration:
- **Full-Stack Workflow**: Complete backend + frontend in one flow
- **Real-Time Features**: Built-in real-time capabilities  
- **Authentication**: Integrated user management
- **Database Management**: Visual database design
- **Edge Functions**: Serverless backend logic
- **60% Faster Development**: Compared to traditional approaches

### Implementation Strategy

You are the Frontend Implementation Specialist in a CCPM + AI Orchestration workflow.

#### CCPM Integration:
1. **Spec-Driven UI Development**
   - Follow UI/UX specifications in .claude/epics/
   - Reference user requirements from .claude/prds/
   - Update progress in GitHub Issues  
   - Maintain design system consistency

2. **Integrated Backend Coordination**
   - Use Supabase for authentication, database, and real-time features
   - Coordinate with existing backend through API contracts
   - Implement edge functions for serverless logic
   - Document full-stack component interactions

#### Technical Focus (Lovable + Supabase):
- **Full-Stack**: Integrated frontend + backend development
- **Real-Time**: Built-in subscriptions and live data sync
- **Auth**: Supabase authentication with social providers
- **Database**: PostgreSQL with real-time capabilities
- **Storage**: File uploads and CDN integration

#### Deliverables:
- Complete full-stack frontend implementation with Supabase integration
- Real-time features and authentication system
- Component documentation and API contracts
- Updated GitHub Issues with progress
- End-to-end testing scenarios with Supabase testing tools

#### Advanced Features Available:
- **Supabase Features**: Use for Authentication, Real-Time, Database, File Storage, Edge Functions
- **Cursor Enhancement**: Use for Complex Business Logic, Advanced Integrations, Performance Optimization
- **Export Strategy**: When complexity requires, export to Cursor with GPT-4o for advanced customization

### Coordination Points:
- Supabase integration with existing backend APIs
- Real-time data synchronization with backend agent
- Design consistency with project requirements
- Progress synchronization through GitHub Issues
- User acceptance criteria validation with live prototypes

Implement the frontend using Lovable + Supabase integration following CCPM specifications with full-stack coherence.
EOF

    cat > "$output_dir/4-quality-assurance.md" << EOF
# Quality Assurance with CCPM Validation

## Agent: Gemini Pro (QA Specialist)

### Context Integration
- **Project**: $PROJECT_NAME
- **Testing Framework**: $TESTING
- **Epic Reference**: Quality requirements in .claude/epics/
- **GitHub Issues**: Validate all 'qa' and 'testing' issues

### QA Strategy

You are the Quality Assurance Specialist in a CCPM + AI Orchestration workflow.

#### CCMP-Driven Testing:
1. **Spec Validation**  
   - Verify implementation matches .claude/epics/ specifications
   - Validate against original PRD requirements in .claude/prds/
   - Check GitHub Issues completion criteria
   - Ensure traceability from requirement to implementation

2. **Integration Testing**
   - Test API integration between frontend and backend
   - Validate database operations and data integrity
   - Check error handling and edge cases
   - Verify cross-platform compatibility

#### Technical Validation:
- **Backend Testing**: API endpoints, database operations, performance
- **Frontend Testing**: Component functionality, user interactions, accessibility
- **Integration**: End-to-end user workflows and data flow
- **Performance**: Load testing, optimization recommendations

#### CCPM Documentation:
- Test results documented in .claude/context/
- GitHub Issues updated with validation status
- Quality metrics tracked and reported
- Regression test suites created

### Deliverables:
- Comprehensive test suite ($TESTING)
- Quality validation report
- GitHub Issues status updates
- Performance and security recommendations

### Coordination Points:
- Validation of Backend agent deliverables
- Testing of Frontend agent implementation  
- Integration testing across all components
- Final quality report for Strategic Coordinator

Validate the complete implementation following CCMP quality standards.
EOF

    cat > "$output_dir/5-integration-synthesis.md" << EOF
# Integration & Synthesis with CCPM Completion

## Agent: Claude Code (Master Coordinator - Final Phase)

### Context Integration
- **Project**: $PROJECT_NAME
- **Workflow**: CCPM + GitHub + AI Orchestration
- **Epic Status**: Review all epics in .claude/epics/
- **GitHub Issues**: Validate all issues are resolved

### Integration Strategy

You are completing the Master Coordinator role in the final synthesis phase.

#### CCPM Workflow Completion:
1. **Epic Closure**
   - Verify all .claude/epics/ are implemented
   - Update epic status and completion documentation
   - Archive completed work and update context
   - Generate project completion report

2. **GitHub Project Management**
   - Close all resolved GitHub Issues
   - Update project milestones and releases
   - Tag final release with complete implementation
   - Document lessons learned and metrics

3. **AI Orchestration Synthesis**
   - Integrate deliverables from all agents
   - Resolve any conflicts or integration issues
   - Validate end-to-end functionality
   - Optimize performance and user experience

#### Final Deliverables:
- **Complete Integration**: All components working together
- **Documentation**: Updated README, API docs, deployment guide
- **CCPM Closure**: All epics completed and archived
- **GitHub Project**: All issues resolved, release tagged
- **Metrics Report**: Performance improvements and lessons learned

#### Success Validation:
- [ ] All GitHub Issues closed or properly managed
- [ ] .claude/epics/ marked as complete
- [ ] End-to-end testing passes
- [ ] Documentation is complete and accurate  
- [ ] Performance meets or exceeds requirements
- [ ] CCPM traceability maintained throughout

### Performance Metrics:
- Measure actual vs. predicted development time
- Calculate context switching reduction
- Document parallel execution efficiency
- Report overall quality improvements

Complete the hybrid CCPM + AI Orchestration workflow with full integration and synthesis.
EOF

    # Create workflow summary
    cat > "$output_dir/README.md" << EOF
# CCPM + GitHub + AI Orchestration Hybrid Workflow

Generated for: **$PROJECT_NAME**
Date: $(date)
Type: **$PROJECT_TYPE**

## Workflow Overview

This hybrid workflow combines:
- **CCMP**: Structured, spec-driven development with full traceability
- **GitHub Issues**: Project management and collaboration
- **AI Orchestration**: Multi-agent parallel execution
- **Git Worktrees**: True parallel development workflows

## Execution Order (Platform-Optimized)

1. **Strategic Coordinator** (Claude Code + Gemini Deep Think/Canvas) - Strategic analysis + CCPM setup
2. **Backend Implementation** (Cursor + Claude 3.5 Sonnet + Agents) - Server-side development in worktree  
3. **Frontend Implementation** (Lovable + Supabase) - Full-stack UI/UX development in worktree
4. **Quality Assurance** (Gemini Deep Think/Research + Jules) - Testing and validation
5. **Integration Synthesis** (Claude Code) - Final integration + CCPM closure

## Key Features

- **89% Context Switching Reduction** (CCPM benefit)
- **90%+ Performance Improvement** (AI Orchestration benefit)
- **Full Traceability**: Every change traces back to PRD
- **Parallel Execution**: Multiple agents working simultaneously
- **GitHub Integration**: Full project management and collaboration

## Next Steps

1. Execute Phase 1 with Claude Code
2. Use Git worktrees for parallel backend/frontend development
3. Maintain GitHub Issues for progress tracking
4. Follow CCMP rules and context management
5. Complete integration with full validation

## Project Context

- **Stack**: $TECH_STACK$([[ -n "$FRAMEWORK" ]] && echo " + $FRAMEWORK")
- **Frontend**: $FRONTEND
- **Backend**: $BACKEND$([[ -n "$DATABASE" ]] && echo " + $DATABASE")
- **Testing**: $TESTING
- **Repository**: $GITHUB_REPO

**Generated by CCPM-Enhanced Universal AI Orchestration v$SCRIPT_VERSION**
EOF
}

# Function to generate CCMP local workflow (no GitHub)
generate_ccmp_local_workflow() {
    local output_dir="$1"
    
    cat > "$output_dir/README.md" << EOF
# CCPM + Local AI Orchestration Hybrid Workflow

Generated for: **$PROJECT_NAME**
Type: **CCMP Local Development**

This workflow uses CCMP structure with local development focus.
GitHub Issues integration is not available, but all other hybrid features are enabled.

See individual phase files for detailed instructions.
EOF
    
    # Generate similar files but without GitHub integration
    echo -e "${YELLOW}📝 Local CCMP workflow generated (GitHub integration disabled)${NC}"
}

# Function to generate standard hybrid workflow
generate_standard_hybrid_workflow() {
    local output_dir="$1"
    
    cat > "$output_dir/README.md" << EOF
# Standard Hybrid AI Orchestration Workflow

Generated for: **$PROJECT_NAME**
Type: **Standard Hybrid Development**

This workflow initializes CCPM structure and uses dynamic AI orchestration.
Perfect for projects that want both structure and adaptability.

CCMP structure will be initialized automatically.
EOF
    
    echo -e "${YELLOW}📝 Standard hybrid workflow generated${NC}"
}

# Main workflow selection and execution
main() {
    echo -e "${BLUE}🔍 Initializing hybrid orchestration...${NC}"
    
    # Detect project context
    detect_project_context "$PROJECT_DIR"
    
    # Check GitHub integration capability
    github_available=false
    if check_github_integration; then
        github_available=true
    fi
    
    # Initialize CCMP structure if needed
    if [[ "$CCPM_ENABLED" != true ]]; then
        echo -e "${YELLOW}🏗️  CCPM structure not detected. Initializing...${NC}"
        "$AI_ORCHESTRATION_ROOT/ccpm/ccpm-bridge.sh" --init-only 2>/dev/null || {
            echo -e "${BLUE}📁 Creating minimal CCPM structure...${NC}"
            mkdir -p .claude/{agents,commands,context,epics,prds,rules,scripts}
            echo "# $PROJECT_NAME Context" > .claude/context/project.md
        }
    fi
    
    echo ""
    echo -e "${PURPLE}🎯 Select Hybrid Workflow:${NC}"
    echo ""
    
    if [[ "$github_available" == true ]]; then
        echo -e "${GREEN}1) CCPM + GitHub Issues + AI Orchestration${NC} (Full Integration)"
        echo -e "${CYAN}   - Structured spec-driven development${NC}"
        echo -e "${CYAN}   - GitHub Issues project management${NC}" 
        echo -e "${CYAN}   - Multi-agent parallel execution${NC}"
        echo -e "${CYAN}   - Git worktrees for true parallelism${NC}"
        echo ""
    fi
    
    echo -e "${GREEN}2) CCMP + Local AI Orchestration${NC} (Local Focus)"
    echo -e "${CYAN}   - Structured development with CCPM${NC}"
    echo -e "${CYAN}   - Local context management${NC}"
    echo -e "${CYAN}   - Multi-agent coordination${NC}"
    echo ""
    
    echo -e "${GREEN}3) Adaptive Hybrid Workflow${NC} (Dynamic)"
    echo -e "${CYAN}   - Real-time strategy adaptation${NC}"
    echo -e "${CYAN}   - Context-aware orchestration${NC}"
    echo -e "${CYAN}   - Performance optimization focus${NC}"
    echo ""
    
    echo -e "${GREEN}4) Initialize CCPM Only${NC}"
    echo -e "${CYAN}   - Set up CCPM structure${NC}"
    echo -e "${CYAN}   - No immediate orchestration${NC}"
    echo ""
    
    echo -e "${GREEN}5) Run Original AI Orchestration${NC}"
    echo -e "${CYAN}   - Pure dynamic orchestration${NC}"
    echo ""
    
    read -p "Enter choice [1-5]: " choice
    
    case $choice in
        1)
            if [[ "$github_available" == true ]]; then
                generate_hybrid_prompts "ccpm_github"
            else
                echo -e "${RED}❌ GitHub integration not available${NC}"
                echo -e "${YELLOW}💡 Choose option 2 for local development${NC}"
                exit 1
            fi
            ;;
        2)
            generate_hybrid_prompts "ccpm_local"
            ;;
        3)
            generate_hybrid_prompts "adaptive_hybrid"
            ;;
        4)
            echo -e "${BLUE}🏗️  Initializing CCPM structure only...${NC}"
            "$AI_ORCHESTRATION_ROOT/ccpm/ccpm-bridge.sh" --init-only
            echo -e "${GREEN}✅ CCPM initialized. Run this script again for orchestration.${NC}"
            exit 0
            ;;
        5)
            echo -e "${BLUE}🚀 Running original AI Orchestration...${NC}"
            "$AI_ORCHESTRATION_ROOT/scripts/ai-orchestration-universal.sh"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${PURPLE}🎉 CCPM-Enhanced Hybrid Orchestration Complete!${NC}"
    echo -e "${GREEN}✅ Workflow generated with hybrid architecture${NC}"
    echo -e "${YELLOW}💡 Execute the phases in order for maximum efficiency${NC}"
    echo ""
    echo -e "${BLUE}📈 Expected Benefits:${NC}"
    echo -e "${CYAN}   • 89% reduction in context switching (CCPM)${NC}"
    echo -e "${CYAN}   • 90%+ performance improvement (AI Orchestration)${NC}"
    echo -e "${CYAN}   • Full traceability from requirements to code${NC}"
    echo -e "${CYAN}   • Parallel execution with Git worktrees${NC}"
    echo ""
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi