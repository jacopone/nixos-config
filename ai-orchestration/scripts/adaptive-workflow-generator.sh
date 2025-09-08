#!/usr/bin/env bash

# Adaptive Workflow Generator
# Generates optimized workflows based on detected tool availability

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_VERSION="1.0.0"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$HOME/.ai-orchestration-config.json"

# Project detection
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Tool configuration
declare -A TOOL_STATUS
declare -A TOOL_CAPABILITIES
declare -A FALLBACK_CHAINS

# Load configuration
load_configuration() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Tool configuration not found. Running detection...${NC}"
        "$SCRIPT_DIR/tool-detector.sh"
    fi
    
    if [[ -f "$CONFIG_FILE" ]] && command -v jq &> /dev/null; then
        # Load with jq if available
        while IFS="=" read -r key value; do
            TOOL_STATUS["$key"]="$value"
        done < <(jq -r '.tool_status | to_entries[] | .key + "=" + .value' "$CONFIG_FILE" 2>/dev/null || true)
        
        while IFS="=" read -r key value; do
            TOOL_CAPABILITIES["$key"]="$value"
        done < <(jq -r '.tool_capabilities | to_entries[] | .key + "=" + .value' "$CONFIG_FILE" 2>/dev/null || true)
        
        while IFS="=" read -r key value; do
            FALLBACK_CHAINS["$key"]="$value"
        done < <(jq -r '.fallback_chains | to_entries[] | .key + "=" + .value' "$CONFIG_FILE" 2>/dev/null || true)
    fi
}

# Function to detect project technology stack
detect_project_stack() {
    local backend="Unknown"
    local frontend="Unknown" 
    local database="Unknown"
    local testing="Unknown"
    local framework="Unknown"
    
    # Backend detection
    if [[ -f "package.json" ]]; then
        if grep -q "express\|fastify\|koa" package.json; then
            backend="Node.js"
        fi
        if grep -q "next\|nuxt" package.json; then
            framework="Next.js/Nuxt.js"
        fi
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        backend="Python"
        if grep -q "django\|flask\|fastapi" requirements.txt pyproject.toml 2>/dev/null; then
            framework="Django/Flask/FastAPI"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        backend="Rust"
    elif [[ -f "go.mod" ]]; then
        backend="Go"
    elif [[ -f "composer.json" ]]; then
        backend="PHP"
    fi
    
    # Frontend detection
    if [[ -f "package.json" ]]; then
        if grep -q "react" package.json; then
            frontend="React"
        elif grep -q "vue" package.json; then
            frontend="Vue.js"
        elif grep -q "angular" package.json; then
            frontend="Angular"
        elif grep -q "svelte" package.json; then
            frontend="Svelte"
        else
            frontend="JavaScript"
        fi
    fi
    
    # Database detection
    if [[ -f "package.json" ]]; then
        if grep -q "postgres\|pg" package.json; then
            database="PostgreSQL"
        elif grep -q "mysql" package.json; then
            database="MySQL"
        elif grep -q "mongodb\|mongoose" package.json; then
            database="MongoDB"
        fi
    fi
    
    # Testing framework detection
    if [[ -f "package.json" ]]; then
        if grep -q "vitest" package.json; then
            testing="Vitest"
        elif grep -q "jest" package.json; then
            testing="Jest"
        elif grep -q "playwright" package.json; then
            testing="Playwright"
        elif grep -q "cypress" package.json; then
            testing="Cypress"
        fi
    fi
    
    echo "BACKEND=$backend"
    echo "FRONTEND=$frontend"
    echo "DATABASE=$database"
    echo "TESTING=$testing"
    echo "FRAMEWORK=$framework"
}

# Function to generate strategic coordinator workflow
generate_strategic_coordinator() {
    local output_file="$1"
    local strategy="${FALLBACK_CHAINS["strategic_coordinator"]}"
    
    cat > "$output_file" << EOF
# Strategic Coordination - Adaptive Configuration

## Agent Configuration: $strategy

### Context Integration
- **Project**: $PROJECT_NAME
- **Stack**: $(detect_project_stack | tr '\n' ' ')
- **Configuration**: Optimized for available tools

### Implementation Strategy

EOF
    
    case "$strategy" in
        "gemini_deep_think_canvas")
            cat >> "$output_file" << EOF
#### 🌟 Premium Configuration: Gemini Deep Think + Canvas

**Platform**: Google One Ultra with Gemini Deep Think + Canvas
**Optimization Level**: Ultra Premium (98%+ efficiency)

**Usage Instructions**:
1. **Use Gemini Deep Think** for complex reasoning sessions (15-20 minutes)
   - Architectural decisions and trade-off analysis
   - System design and integration challenges  
   - Epic decomposition and strategic planning

2. **Use Canvas** for visual collaboration
   - System architecture diagrams
   - User workflow visualization
   - Progress tracking and milestone planning

**Optimal Prompts**:
- "Analyze architectural implications of implementing [feature] with these constraints..."
- "Compare approaches A, B, C considering scalability, maintainability, and performance..."
- "Design system architecture for [project] with [requirements]..."

**Expected Performance**: 40% faster strategic planning
EOF
            ;;
        "gemini_pro")
            cat >> "$output_file" << EOF
#### ⚡ Standard Configuration: Gemini Pro

**Platform**: Google Gemini Pro
**Optimization Level**: Standard Premium

**Usage Instructions**:
1. Use for strategic analysis and planning
2. Focus on architectural decisions
3. Provide comprehensive project breakdown

**Capabilities**: 
- Strategic analysis and planning
- Technology stack recommendations  
- Epic and task decomposition
EOF
            ;;
        *)
            cat >> "$output_file" << EOF
#### 🔧 Fallback Configuration: Claude Code

**Platform**: Claude Code
**Optimization Level**: Reliable Standard

**Usage Instructions**:
1. Use for strategic analysis and coordination
2. Focus on clear task decomposition
3. Provide detailed implementation guidance

**Capabilities**:
- Strategic project analysis
- Task breakdown and coordination
- Implementation planning and guidance
EOF
            ;;
    esac
    
    cat >> "$output_file" << EOF

### Key Deliverables
- Strategic project analysis
- Technology stack optimization
- Epic and task decomposition  
- Implementation roadmap
- Agent coordination plan

Proceed with strategic analysis using your configured platform.
EOF
}

# Function to generate backend implementation workflow
generate_backend_implementation() {
    local output_file="$1"
    local strategy="${FALLBACK_CHAINS["backend_implementation"]}"
    
    cat > "$output_file" << EOF
# Backend Implementation - Adaptive Configuration

## Agent Configuration: $strategy

### Context Integration
- **Project**: $PROJECT_NAME
- **Stack**: $(detect_project_stack | grep "BACKEND\|DATABASE\|TESTING" | tr '\n' ' ')
- **Configuration**: Optimized for available tools

### Implementation Strategy

EOF
    
    case "$strategy" in
        "cursor_pro_agents")
            cat >> "$output_file" << EOF
#### 🌟 Premium Configuration: Cursor Pro + Agents

**Platform**: Cursor Pro with Claude 3.5 Sonnet + Multi-Agent Setup
**Optimization Level**: Ultra Premium (35% faster development)

**Configuration**:
\`\`\`json
{
  "model": "claude-3-5-sonnet-20241022",
  "use_agents": true,
  "agent_mode": "backend_specialist",
  "auto_mode": false
}
\`\`\`

**Agent Setup**:
- **Primary Agent**: Backend API development
- **Secondary Agent**: Database design and optimization  
- **Tertiary Agent**: Testing and validation

**Usage Instructions**:
1. Configure Cursor with the above settings
2. Use 3 parallel agents for different aspects
3. Focus on API design and database optimization
4. Implement comprehensive testing

**Why These Settings**:
- Superior backend reasoning with Claude 3.5 Sonnet
- Parallel agent execution for efficiency
- Specialized backend development patterns
- Comprehensive testing integration
EOF
            ;;
        "cursor_basic")
            cat >> "$output_file" << EOF
#### ⚡ Standard Configuration: Cursor Basic

**Platform**: Cursor (Basic)
**Optimization Level**: Enhanced Standard

**Usage Instructions**:
1. Use Cursor for backend development
2. Focus on API and database implementation
3. Follow best practices for testing
4. Document API endpoints and schemas

**Capabilities**:
- Backend API development
- Database schema design
- Testing implementation
- Code quality optimization
EOF
            ;;
        *)
            cat >> "$output_file" << EOF
#### 🔧 Fallback Configuration: Claude Code

**Platform**: Claude Code
**Optimization Level**: Comprehensive Standard

**Usage Instructions**:
1. Use Claude Code for backend implementation
2. Focus on clean, maintainable code
3. Implement comprehensive testing
4. Document all APIs and database schemas

**Capabilities**:
- Full backend implementation
- API design and development
- Database integration
- Testing and validation
EOF
            ;;
    esac
    
    cat >> "$output_file" << EOF

### Technical Focus
- API development and documentation
- Database design and optimization
- Testing and validation
- Performance and security

### Key Deliverables
- Complete backend implementation
- API documentation
- Database schema and migrations
- Test suite and validation
- Performance optimization

Implement backend following your configured platform approach.
EOF
}

# Function to generate frontend implementation workflow
generate_frontend_implementation() {
    local output_file="$1"
    local strategy="${FALLBACK_CHAINS["frontend_implementation"]}"
    
    cat > "$output_file" << EOF
# Frontend Implementation - Adaptive Configuration

## Agent Configuration: $strategy

### Context Integration
- **Project**: $PROJECT_NAME
- **Stack**: $(detect_project_stack | grep "FRONTEND\|FRAMEWORK" | tr '\n' ' ')
- **Configuration**: Optimized for available tools

### Implementation Strategy

EOF
    
    case "$strategy" in
        "lovable_supabase")
            cat >> "$output_file" << EOF
#### 🌟 Premium Configuration: Lovable + Supabase Integration

**Platform**: Lovable + Supabase (Integrated Full-Stack)
**Optimization Level**: Ultra Premium (60% faster development)

**Integration Approach**:
1. **Start Integrated**: Begin with full Lovable + Supabase workflow
2. **Export When Needed**: Move to Cursor for advanced customization
3. **API-First Design**: Design with clear API contracts
4. **Incremental Migration**: Move complex logic to Cursor gradually

**Why Lovable + Supabase**:
- Full-stack workflow in one platform
- Real-time features built-in
- Integrated authentication system
- Visual database management
- Edge functions for serverless logic

**Usage Instructions**:
1. Create project in Lovable with Supabase integration
2. Design UI/UX with real-time data binding
3. Configure authentication and user management
4. Implement database operations with real-time sync
5. Export to Cursor for complex business logic (when needed)

**Available Features**:
- Authentication & user management
- Real-time data synchronization  
- Database management (PostgreSQL)
- File storage & CDN
- Edge functions (serverless)
EOF
            ;;
        "lovable_standalone")
            cat >> "$output_file" << EOF
#### ⚡ Enhanced Configuration: Lovable (Standalone)

**Platform**: Lovable
**Optimization Level**: Premium UI/UX

**Usage Instructions**:
1. Use Lovable for rapid UI/UX prototyping
2. Focus on component design and user experience
3. Export to other platforms for backend integration
4. Iterate quickly on design and functionality

**Capabilities**:
- Rapid UI/UX development
- Component-based architecture
- Interactive prototyping
- Design system integration
EOF
            ;;
        "v0_dev")
            cat >> "$output_file" << EOF
#### 🎨 Standard Configuration: v0.dev

**Platform**: v0.dev
**Optimization Level**: AI-Powered UI Generation

**Usage Instructions**:
1. Use v0.dev for component generation
2. Focus on React/Next.js components
3. Iterate on design and functionality
4. Export and customize in your preferred editor

**Capabilities**:
- AI-powered component generation
- React/Next.js specialization
- Rapid prototyping
- Component library creation
EOF
            ;;
        *)
            cat >> "$output_file" << EOF
#### 🔧 Fallback Configuration: Claude Code

**Platform**: Claude Code
**Optimization Level**: Comprehensive Development

**Usage Instructions**:
1. Use Claude Code for frontend development
2. Focus on component architecture
3. Implement responsive design
4. Ensure accessibility compliance

**Capabilities**:
- Full frontend implementation
- Component development
- State management
- Testing and validation
EOF
            ;;
    esac
    
    cat >> "$output_file" << EOF

### Technical Focus
- User interface and experience
- Component architecture
- State management
- Responsive design and accessibility

### Key Deliverables
- Complete frontend implementation
- Component library and documentation
- User interface testing
- Performance optimization
- Accessibility compliance

Implement frontend using your configured platform approach.
EOF
}

# Function to generate knowledge management workflow
generate_knowledge_management() {
    local output_file="$1"
    local strategy="${FALLBACK_CHAINS["knowledge_manager"]}"
    
    cat > "$output_file" << EOF
# Knowledge Management - Adaptive Configuration

## Agent Configuration: $strategy

### Context Integration
- **Project**: $PROJECT_NAME
- **Documentation**: All project artifacts and research materials
- **Configuration**: Optimized for available tools

### Knowledge Management Strategy

EOF
    
    case "$strategy" in
        "notebooklm_ultra")
            cat >> "$output_file" << EOF
#### 🌟 Premium Configuration: NotebookLM Ultra

**Platform**: NotebookLM Ultra (Google One Ultra)
**Optimization Level**: Ultra Premium (Maximum synthesis capability)

**Capacity**:
- **Notebooks**: ~100 notebooks for comprehensive project coverage
- **Sources per Notebook**: 50+ sources for deep context analysis
- **Audio Generation**: Unlimited audio briefings and summaries

**Usage Instructions**:
1. **Project Knowledge Base**
   - Create dedicated notebooks for different project phases
   - Upload PRDs, technical specs, research documents, and meeting notes
   - Generate comprehensive project overviews and status reports

2. **Research Synthesis**
   - Upload competitive analysis, technical documentation, API references
   - Create consolidated research summaries and insights
   - Generate audio briefings for team alignment

3. **Documentation Management**
   - Upload code documentation, test results, and deployment guides
   - Create onboarding materials and knowledge transfer content
   - Generate audio walkthroughs for complex systems

**Optimal Workflow**:
- **Phase 1**: Upload initial PRDs and research → Generate project briefing
- **Phase 2**: Add technical specs and implementation notes → Create development guide
- **Phase 3**: Include test results and deployment docs → Generate completion summary

**Expected Performance**: Comprehensive knowledge synthesis with unlimited capacity
EOF
            ;;
        "notebooklm_pro")
            cat >> "$output_file" << EOF
#### ⚡ Enhanced Configuration: NotebookLM Pro

**Platform**: NotebookLM Pro (Google One Pro)
**Optimization Level**: Premium Knowledge Management

**Capacity**:
- **Notebooks**: ~20 notebooks for focused project coverage
- **Sources per Notebook**: 20+ sources for substantial context
- **Audio Generation**: Regular audio briefings and summaries

**Usage Instructions**:
1. **Focused Project Documentation**
   - Create 2-3 notebooks for key project areas (requirements, implementation, testing)
   - Prioritize most critical documents for upload
   - Generate targeted summaries and insights

2. **Strategic Research Synthesis**
   - Focus on essential research and competitive analysis
   - Create consolidated findings for decision-making
   - Generate audio summaries for stakeholder updates

**Optimal Strategy**: Focus on quality over quantity - select most impactful documents
EOF
            ;;
        "notebooklm_free")
            cat >> "$output_file" << EOF
#### 📚 Standard Configuration: NotebookLM Free

**Platform**: NotebookLM Free
**Optimization Level**: Efficient Knowledge Management

**Capacity**:
- **Notebooks**: ~10 notebooks for essential coverage
- **Sources per Notebook**: 10 sources for core context
- **Audio Generation**: Limited audio briefings

**Usage Instructions**:
1. **Essential Documentation Only**
   - Create 1-2 notebooks for most critical project information
   - Upload only the most important PRDs, specs, and findings
   - Focus on key decision-making documents

2. **Strategic Document Selection**
   - Prioritize documents that require synthesis across multiple sources
   - Use for final project summaries and handover documentation

**Optimal Strategy**: Maximum selectivity - only upload documents that require cross-referencing
EOF
            ;;
        *)
            cat >> "$output_file" << EOF
#### 🔧 Fallback Configuration: Claude Code Documentation

**Platform**: Claude Code
**Optimization Level**: Manual Documentation Management

**Usage Instructions**:
1. Use Claude Code for document analysis and synthesis
2. Create structured documentation manually
3. Focus on clear organization and accessibility
4. Maintain comprehensive project documentation

**Capabilities**:
- Document analysis and summarization
- Structured documentation creation
- Project knowledge organization
- Manual synthesis and reporting
EOF
            ;;
    esac
    
    cat >> "$output_file" << EOF

### Knowledge Management Focus Areas
- Project documentation synthesis
- Research compilation and analysis
- Team briefing and onboarding materials
- Cross-reference analysis and insights

### Key Deliverables
- Comprehensive project knowledge base
- Synthesized research and analysis reports
- Audio briefings and summaries (when available)
- Documentation for team onboarding
- Cross-project insights and lessons learned

Manage project knowledge using your configured platform approach.
EOF
}

# Function to generate quality assurance workflow
generate_quality_assurance() {
    local output_file="$1"
    local strategy="${FALLBACK_CHAINS["quality_assurance"]}"
    
    cat > "$output_file" << EOF
# Quality Assurance - Adaptive Configuration

## Agent Configuration: $strategy

### Context Integration
- **Project**: $PROJECT_NAME
- **Testing**: $(detect_project_stack | grep "TESTING" | tr '\n' ' ')
- **Configuration**: Optimized for available tools

### Quality Assurance Strategy

EOF
    
    case "$strategy" in
        "gemini_deep_think_jules")
            cat >> "$output_file" << EOF
#### 🌟 Premium Configuration: Gemini Deep Think + Jules

**Platform**: Google One Ultra with Gemini Deep Think + Jules
**Optimization Level**: Ultra Premium (45% faster QA)

**Tool Integration**:
1. **Gemini Deep Think** for comprehensive analysis
   - Edge case identification and analysis
   - Security vulnerability assessment
   - Performance bottleneck analysis

2. **Jules** for continuous code review
   - Real-time code quality assessment
   - Security vulnerability detection
   - Performance optimization suggestions

**Usage Instructions**:
1. Use Deep Think for strategic QA planning (15-30 minutes)
2. Integrate Jules for continuous code review
3. Focus on edge case analysis and security
4. Perform comprehensive system testing

**Expected Performance**: 45% faster quality assurance
EOF
            ;;
        "gemini_pro")
            cat >> "$output_file" << EOF
#### ⚡ Standard Configuration: Gemini Pro

**Platform**: Google Gemini Pro
**Optimization Level**: Enhanced QA

**Usage Instructions**:
1. Use for comprehensive testing strategy
2. Focus on edge case identification
3. Perform security and performance analysis
4. Create detailed test plans

**Capabilities**:
- Testing strategy development
- Edge case analysis
- Security assessment  
- Performance evaluation
EOF
            ;;
        *)
            cat >> "$output_file" << EOF
#### 🔧 Fallback Configuration: Claude Code QA

**Platform**: Claude Code
**Optimization Level**: Comprehensive QA

**Usage Instructions**:
1. Perform comprehensive code review
2. Create detailed testing strategies
3. Identify potential issues and edge cases
4. Validate security and performance

**Capabilities**:
- Code review and analysis
- Test strategy development
- Security assessment
- Performance optimization
EOF
            ;;
    esac
    
    cat >> "$output_file" << EOF

### Quality Focus Areas
- Code quality and maintainability
- Security vulnerability assessment
- Performance optimization
- Edge case identification and testing

### Key Deliverables
- Comprehensive QA report
- Security assessment
- Performance analysis
- Test coverage report
- Optimization recommendations

Perform quality assurance using your configured platform approach.
EOF
}

# Function to generate complete adaptive workflow
generate_adaptive_workflow() {
    local workflow_type="${1:-adaptive}"
    local output_dir="adaptive-workflow-$(date +%Y%m%d-%H%M%S)"
    
    echo -e "${BLUE}🎯 Generating Adaptive Workflow ($workflow_type)...${NC}"
    mkdir -p "$output_dir"
    
    # Load current configuration
    load_configuration
    
    # Generate role-specific workflows
    generate_strategic_coordinator "$output_dir/1-strategic-coordinator.md"
    generate_backend_implementation "$output_dir/2-backend-implementation.md"
    generate_frontend_implementation "$output_dir/3-frontend-implementation.md"
    generate_knowledge_management "$output_dir/4-knowledge-management.md"
    generate_quality_assurance "$output_dir/5-quality-assurance.md"
    
    # Generate execution summary
    cat > "$output_dir/6-execution-summary.md" << EOF
# Adaptive Workflow Execution Summary

## Project: $PROJECT_NAME
## Configuration: Optimized for Available Tools
## Generated: $(date)

### Execution Order
1. **Strategic Coordinator**: ${FALLBACK_CHAINS["strategic_coordinator"]}
2. **Backend Implementation**: ${FALLBACK_CHAINS["backend_implementation"]}  
3. **Frontend Implementation**: ${FALLBACK_CHAINS["frontend_implementation"]}
4. **Knowledge Management**: ${FALLBACK_CHAINS["knowledge_manager"]}
5. **Quality Assurance**: ${FALLBACK_CHAINS["quality_assurance"]}
6. **Integration & Validation**: Final coordination and deployment

### Optimization Summary
$(
    premium_count=0
    total_roles=5
    
    [[ "${FALLBACK_CHAINS["strategic_coordinator"]}" == "gemini_deep_think_canvas" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["backend_implementation"]}" == "cursor_pro_agents" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["frontend_implementation"]}" == "lovable_supabase" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["knowledge_manager"]}" =~ ^notebooklm_(ultra|pro)$ ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["quality_assurance"]}" == "gemini_deep_think_jules" ]] && ((premium_count++))
    
    optimization_percent=$((premium_count * 100 / total_roles))
    
    if [[ $optimization_percent -eq 100 ]]; then
        echo "**Optimization Level**: Ultra Premium (98%+ efficiency)"
    elif [[ $optimization_percent -ge 50 ]]; then
        echo "**Optimization Level**: Premium ($((50 + optimization_percent/2))%+ efficiency)"
    else
        echo "**Optimization Level**: Standard (Reliable baseline)"
    fi
)

### Tool Configuration Summary
- **Strategic**: ${FALLBACK_CHAINS["strategic_coordinator"]}
- **Backend**: ${FALLBACK_CHAINS["backend_implementation"]}
- **Frontend**: ${FALLBACK_CHAINS["frontend_implementation"]}
- **Knowledge**: ${FALLBACK_CHAINS["knowledge_manager"]}
- **Quality**: ${FALLBACK_CHAINS["quality_assurance"]}

### Next Steps
1. Follow each role workflow in sequence
2. Use platform-specific instructions for optimal performance  
3. Coordinate between agents using shared context
4. Validate and integrate all deliverables

**Note**: This workflow is automatically optimized based on your current tool availability. Re-run tool detection to update if your setup changes.
EOF
    
    echo -e "${GREEN}✅ Adaptive workflow generated in: ${output_dir}${NC}"
    echo -e "${CYAN}💡 Workflow optimized for your current tool configuration${NC}"
    
    # Show quick summary
    echo ""
    echo -e "${BLUE}📊 Generated Workflow Summary:${NC}"
    echo -e "${PURPLE}Strategic:${NC} ${FALLBACK_CHAINS["strategic_coordinator"]}"
    echo -e "${PURPLE}Backend:${NC} ${FALLBACK_CHAINS["backend_implementation"]}"
    echo -e "${PURPLE}Frontend:${NC} ${FALLBACK_CHAINS["frontend_implementation"]}"
    echo -e "${PURPLE}Quality:${NC} ${FALLBACK_CHAINS["quality_assurance"]}"
    echo ""
}

# Main function
main() {
    case "${1:-generate}" in
        "generate"|"")
            generate_adaptive_workflow "${2:-adaptive}"
            ;;
        "verify-and-generate")
            echo -e "${BLUE}🔍 Verifying tools and generating workflow...${NC}"
            "$SCRIPT_DIR/tool-detector.sh"
            echo ""
            generate_adaptive_workflow "${2:-adaptive}"
            ;;
        "status")
            load_configuration
            echo -e "${BLUE}📊 Current Adaptive Configuration:${NC}"
            for role in strategic_coordinator backend_implementation frontend_implementation knowledge_manager quality_assurance; do
                echo -e "${PURPLE}${role}:${NC} ${FALLBACK_CHAINS[$role]}"
            done
            ;;
        *)
            echo "Usage: $0 [generate|verify-and-generate|status] [workflow-type]"
            echo "  generate           - Generate workflow with current configuration"
            echo "  verify-and-generate - Verify tools and generate workflow"
            echo "  status             - Show current configuration"
            ;;
    esac
}

# Run main function
main "$@"