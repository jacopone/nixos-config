#!/usr/bin/env bash

# Universal AI Orchestration Script
# Designed to be stored globally (e.g., in nixos-config) and work across all projects
# Detects project context and generates appropriate prompts with evolution protocol

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script version and metadata
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="Universal AI Orchestration Generator"

echo -e "${BLUE}🤖 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to detect project type and context
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

    echo -e "${YELLOW}🔍 Analyzing project context...${NC}"

    # Check for various project indicators
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

    # Detect backend
    if [[ -d "$project_dir/backend" ]]; then
        backend="Node.js Backend"
    fi
    if [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
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
    fi

    # Check for AI orchestration markers
    if [[ -f "$project_dir/docs/AI_ORCHESTRATION.md" ]]; then
        project_type="AI_ORCHESTRATION_ENABLED"
    elif [[ -f "$project_dir/CLAUDE.md" ]]; then
        project_type="CLAUDE_ENABLED"
    else
        project_type="STANDARD"
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

    echo -e "${GREEN}✅ Project detected:${NC}"
    echo -e "   📁 Name: $project_name"
    echo -e "   🏗️  Type: $project_type"
    echo -e "   💻 Stack: $tech_stack"
    [[ -n "$framework" ]] && echo -e "   🔧 Framework: $framework"
    [[ -n "$frontend" ]] && echo -e "   🎨 Frontend: $frontend"
    [[ -n "$backend" ]] && echo -e "   ⚙️  Backend: $backend"
    [[ -n "$database" ]] && echo -e "   🗄️  Database: $database"
    [[ -n "$testing" ]] && echo -e "   🧪 Testing: $testing"
    echo ""
}

# Function to validate project is suitable for AI orchestration
validate_project() {
    local project_dir="$1"
    
    echo -e "${YELLOW}🔍 Validating project for AI orchestration...${NC}"
    
    # Check for basic project structure
    if [[ ! -f "$project_dir/package.json" ]] && [[ ! -f "$project_dir/pyproject.toml" ]] && [[ ! -f "$project_dir/Cargo.toml" ]] && [[ ! -f "$project_dir/go.mod" ]]; then
        echo -e "${RED}❌ No recognized project files found. This doesn't appear to be a development project.${NC}"
        echo -e "${YELLOW}💡 Looking for: package.json, pyproject.toml, Cargo.toml, or go.mod${NC}"
        return 1
    fi

    # Check if it's a git repository
    if [[ ! -d "$project_dir/.git" ]]; then
        echo -e "${YELLOW}⚠️  Warning: This doesn't appear to be a git repository.${NC}"
        echo -e "${YELLOW}💡 AI orchestration works best with version-controlled projects.${NC}"
    fi

    echo -e "${GREEN}✅ Project validation passed${NC}"
    echo ""
    return 0
}

# Function to generate project-specific technical context
generate_tech_context() {
    local context=""
    
    # Build technical context based on detected stack
    if [[ "$FRONTEND" == *"React"* ]]; then
        context+="- Framework: $FRONTEND + $FRAMEWORK\n"
        context+="- Components: Modern React patterns with hooks\n"
        context+="- State Management: Context API or state management library\n"
        context+="- Styling: CSS modules, Tailwind CSS, or styled-components\n"
    fi
    
    if [[ -n "$BACKEND" ]]; then
        context+="- Backend: $BACKEND\n"
        if [[ "$BACKEND" == *"Node.js"* ]]; then
            context+="- API: RESTful endpoints with Express.js or similar\n"
        fi
    fi
    
    if [[ -n "$DATABASE" ]]; then
        context+="- Database: $DATABASE\n"
        context+="- ORM/Query: Database abstraction layer\n"
    fi
    
    if [[ -n "$TESTING" ]]; then
        context+="- Testing: $TESTING for unit and integration tests\n"
    fi

    echo -e "$context"
}

# Function to get user story input
get_user_story() {
    echo -e "${BLUE}📝 Please paste your Gherkin user story below, then press Ctrl+D when finished:${NC}"
    echo ""
    
    # Read multiline input until EOF
    local story=""
    while IFS= read -r line; do
        story+="$line"$'\n'
    done
    
    # Remove trailing newline
    story=${story%$'\n'}
    
    if [[ -z "$story" ]]; then
        echo -e "${RED}❌ No user story provided. Exiting.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ User story received (${#story} characters)${NC}"
    echo ""
    
    echo "$story"
}

# Function to create session directory
create_session_directory() {
    local project_dir="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local session_dir="$project_dir/ai-orchestration-sessions/$timestamp"
    
    mkdir -p "$session_dir"
    echo "$session_dir"
}

# Function to generate master coordinator prompt
generate_coordinator_prompt() {
    local session_dir="$1"
    local user_story="$2"
    local tech_context="$3"
    
    cat > "$session_dir/01-claude-coordinator.md" << EOF
# Step 1: Master Coordinator (Claude Code)

**Project Context**: $PROJECT_NAME ($PROJECT_TYPE)
**Technology Stack**: $TECH_STACK

## Master Coordinator Activation

**Exact prompt to paste in Claude Code:**

\`\`\`markdown
Activate Master Coordinator for $PROJECT_NAME:

**Mission**: Act as intelligent orchestrator using Anthropic Research System pattern

**Current Request**: Implement this Gherkin user story:

\`\`\`gherkin
$user_story
\`\`\`

**Project Technical Context**:
$tech_context

**Orchestration Protocol**:
1. Analyze this Gherkin story complexity and domain impact
2. Decompose into backend, frontend, and testing tasks
3. Assign specialized agents with isolated contexts
4. Define A2A communication protocol for coordination
5. Establish success metrics and validation checkpoints

**Expected Output**:
- Dynamic task decomposition with agent assignments
- Specific context isolation strategy for this project
- Coordination plan with success metrics
- Ready-to-use prompts for Cursor, v0.dev, and Gemini Pro

**Project-Specific Adaptations**:
- Consider existing architecture and patterns in $PROJECT_NAME
- Align with current technology stack: $TECH_STACK
- Maintain consistency with project conventions
- Optimize for detected framework patterns

**Begin intelligent orchestration analysis now.**
\`\`\`

## Instructions

1. **Paste this prompt in Claude Code**
2. **Wait for complete task decomposition** and agent assignments
3. **Copy the specific requirements** for each agent from the coordination plan
4. **Proceed to Step 2** (Cursor) with backend requirements
5. **Use session tracker** to monitor progress across all agents

## Success Criteria

✅ Complete breakdown of Gherkin story into actionable tasks  
✅ Clear agent assignments with isolated contexts  
✅ Project-specific technical guidance provided  
✅ Coordination protocol established for A2A communication  
✅ Performance metrics defined for 90%+ improvement target  
EOF
}

# Function to generate backend implementation prompt
generate_backend_prompt() {
    local session_dir="$1"
    local user_story="$2"
    local tech_context="$3"
    
    cat > "$session_dir/02-cursor-backend.md" << EOF
# Step 2: Backend Implementation (Cursor)

**Project**: $PROJECT_NAME
**Backend Stack**: $BACKEND
**Database**: $DATABASE

## Backend Implementation Protocol

**Wait for Claude Code coordination plan, then use this prompt in Cursor:**

\`\`\`markdown
Execute backend implementation task in isolated context:

**Agent**: CURSOR
**Task ID**: [FROM_CLAUDE_COORDINATION_PLAN]
**Context Isolation**: Independent backend workspace

**Gherkin Requirements Analysis**:
[PASTE_SPECIFIC_BACKEND_REQUIREMENTS_FROM_CLAUDE]

**Implementation Scope**:
[FROM_CLAUDE_ANALYSIS - SPECIFIC TO YOUR GHERKIN STORY]

**Project Technical Context ($PROJECT_NAME)**:
$tech_context

**Success Criteria**:
✅ All Gherkin acceptance criteria implemented
✅ API endpoints validated with comprehensive tests
✅ Database schema changes properly migrated
✅ Integration points with frontend clearly defined
✅ Error handling and validation implemented
✅ Performance requirements met

**A2A Communication Protocol**:
- Report implementation progress to Master Coordinator
- Coordinate API contracts with v0.dev
- Share schema changes with Gemini Pro for documentation
- Communicate any blockers or design decisions immediately

**Adaptive Execution Strategy**:
1. **Start with core business logic** (highest complexity first)
2. **Create well-tested API endpoints** with proper error handling
3. **Implement data persistence** with appropriate validation
4. **Add real-time features** if required by Gherkin scenarios
5. **Ensure comprehensive test coverage** for all new functionality
6. **Document API contracts** for seamless frontend integration

**Project-Specific Guidelines**:
- Follow existing code patterns and architecture in $PROJECT_NAME
- Use established testing frameworks ($TESTING)
- Maintain consistency with current database patterns
- Consider existing error handling and logging conventions

**Begin implementation with TDD approach now.**
\`\`\`

## Template Sections to Customize

**Replace these placeholders with Claude Code coordination output:**
- \`[FROM_CLAUDE_COORDINATION_PLAN]\` → Specific task requirements
- \`[PASTE_SPECIFIC_BACKEND_REQUIREMENTS_FROM_CLAUDE]\` → Backend-specific needs
- \`[FROM_CLAUDE_ANALYSIS - SPECIFIC TO YOUR GHERKIN STORY]\` → Implementation scope

## Coordination Checklist

- [ ] Received specific backend requirements from Claude Code
- [ ] Understanding of API endpoints needed
- [ ] Database schema changes identified
- [ ] Integration points with frontend clarified
- [ ] Performance and security requirements understood
- [ ] Test strategy aligned with project standards
EOF
}

# Function to generate frontend implementation prompt  
generate_frontend_prompt() {
    local session_dir="$1"
    local user_story="$2"
    local tech_context="$3"
    
    cat > "$session_dir/03-lovable-frontend.md" << EOF
# Step 3: Frontend Implementation (v0.dev)

**Project**: $PROJECT_NAME
**Frontend Stack**: $FRONTEND
**Framework**: $FRAMEWORK

## Frontend Implementation Protocol

**After backend coordination, use this prompt in v0.dev:**

\`\`\`markdown
Execute UI/UX implementation task in isolated design context:

**Agent**: V0_DEV  
**Task ID**: [FROM_CLAUDE_COORDINATION_PLAN]
**Context Isolation**: Independent frontend workspace

**Gherkin UI Requirements**:
[PASTE_SPECIFIC_FRONTEND_REQUIREMENTS_FROM_CLAUDE]

**Component Development Scope**:
[FROM_CLAUDE_ANALYSIS - UI COMPONENTS FOR YOUR GHERKIN STORY]

**Project Design System Context ($PROJECT_NAME)**:
$tech_context

**User Experience Requirements**:
✅ Intuitive user interface aligned with Gherkin scenarios
✅ Responsive design that works across all device sizes
✅ Accessibility compliance (WCAG 2.1 AA minimum)
✅ Performance optimization (fast loading, smooth interactions)
✅ Clear visual feedback for all user actions
✅ Comprehensive error handling and user guidance

**A2A Communication Protocol**:
- Coordinate API integration points with Cursor
- Report UI development progress to Master Coordinator  
- Share component specifications with Gemini Pro for documentation
- Validate user experience flows against Gherkin acceptance criteria

**Implementation Strategy**:
1. **Create component structure** following project conventions
2. **Implement user interaction flows** matching Gherkin scenarios
3. **Integrate with backend APIs** using established patterns
4. **Add comprehensive form validation** and error states
5. **Ensure accessibility compliance** throughout all components
6. **Create thorough component tests** following project standards
7. **Optimize performance** for smooth user experience

**Integration Points from Backend**:
- API endpoints: [COORDINATE_WITH_CURSOR]
- Real-time features: [IF_WEBSOCKETS_OR_SSE_REQUIRED]  
- Data models: [SYNC_WITH_DATABASE_SCHEMA]
- Authentication: [COORDINATE_AUTH_INTEGRATION]

**Project-Specific Guidelines**:
- Follow existing component patterns in $PROJECT_NAME
- Use established state management approach
- Maintain consistency with current styling methodology
- Integrate with existing routing and navigation structure

**Begin component development with design system consistency.**
\`\`\`

## Template Sections to Customize

**Replace these placeholders with Claude Code coordination output:**
- \`[FROM_CLAUDE_COORDINATION_PLAN]\` → Specific UI task requirements
- \`[PASTE_SPECIFIC_FRONTEND_REQUIREMENTS_FROM_CLAUDE]\` → Frontend-specific needs
- \`[FROM_CLAUDE_ANALYSIS - UI COMPONENTS FOR YOUR GHERKIN STORY]\` → Component scope

## Frontend Coordination Checklist

- [ ] Received specific UI/UX requirements from Claude Code
- [ ] Component architecture and hierarchy defined
- [ ] API integration points identified with Cursor
- [ ] User experience flows mapped to Gherkin scenarios
- [ ] Accessibility and performance requirements understood
- [ ] Design system integration approach clarified
EOF
}

# Function to generate quality assurance prompt
generate_qa_prompt() {
    local session_dir="$1"
    local user_story="$2"
    local tech_context="$3"
    
    cat > "$session_dir/04-gemini-quality.md" << EOF
# Step 4: Quality Assurance & Analysis (Gemini Pro)

**Project**: $PROJECT_NAME
**Testing Framework**: $TESTING
**Full Stack**: $TECH_STACK

## Quality Assurance Protocol

**Execute in parallel with implementation agents:**

\`\`\`markdown
Execute comprehensive analysis and quality assurance in independent research context:

**Agent**: GEMINI_PRO
**Task ID**: [FROM_CLAUDE_COORDINATION_PLAN]  
**Context Isolation**: Independent QA workspace

**Gherkin Story for Validation**:
\`\`\`gherkin
$user_story
\`\`\`

**Quality Assurance Scope for $PROJECT_NAME**:
- **Requirements Traceability**: Map every Gherkin line to implementation requirements
- **Test Strategy Design**: Comprehensive testing approach using $TESTING
- **Security Analysis**: Authentication, authorization, input validation, data protection
- **Performance Review**: Load times, response efficiency, scalability considerations
- **Accessibility Audit**: WCAG compliance, inclusive design principles
- **Code Quality Assessment**: Architecture consistency, maintainability, technical debt
- **Documentation Generation**: API docs, component guides, user documentation

**Project-Specific Analysis Framework**:
$tech_context

**Gherkin Acceptance Criteria Mapping**:
[MAP_EACH_GHERKIN_SCENARIO_TO_TESTABLE_REQUIREMENTS]
- Given statements → Setup and precondition validation
- When statements → Action implementation verification  
- Then statements → Result assertion and success criteria
- And statements → Additional requirement validation

**Cross-Agent Coordination Review**:
- **Backend-Frontend Integration**: API contract alignment and data flow consistency
- **Real-time Communication**: WebSocket/SSE implementation if required
- **Database Layer**: Schema consistency and query optimization
- **Authentication Flow**: Security implementation across full stack
- **Error Handling**: Consistent error management and user feedback

**Quality Gates for $PROJECT_NAME**:
✅ All Gherkin scenarios testable and automatable
✅ Security vulnerabilities identified and mitigation planned
✅ Performance benchmarks defined and achievable
✅ Accessibility compliance verified across all components
✅ Code quality meets project standards
✅ Documentation comprehensive and accurate
✅ Integration testing strategy complete

**A2A Communication Tasks**:
- Review and validate backend implementation from Cursor
- Analyze frontend components and UX flows from v0.dev
- Report comprehensive findings to Master Coordinator
- Provide actionable improvement recommendations
- Coordinate test execution strategy across agents

**Testing Specifications to Generate**:
1. **Unit Tests**: Core business logic validation using $TESTING
2. **Integration Tests**: API endpoints, database operations, service interactions
3. **Component Tests**: UI component behavior, user interactions, accessibility
4. **E2E Tests**: Complete user journeys matching Gherkin scenarios exactly
5. **Performance Tests**: Load testing, response time validation, resource usage
6. **Security Tests**: Input validation, authentication flows, authorization checks

**Research and Best Practices Analysis**:
- Industry best practices for similar functionality
- Security considerations specific to the feature type
- Performance optimization opportunities for $TECH_STACK
- Accessibility guidelines for the user interaction patterns
- Testing strategies optimized for the technology stack

**Project-Specific Quality Considerations**:
- Alignment with existing architecture patterns in $PROJECT_NAME
- Consistency with established code quality standards
- Integration with current CI/CD pipeline requirements
- Compliance with project-specific security guidelines

**Begin comprehensive quality analysis and test strategy development now.**
\`\`\`

## Quality Analysis Checklist

- [ ] Every Gherkin scenario mapped to testable requirements
- [ ] Security analysis completed for all new functionality
- [ ] Performance benchmarks defined and measurable
- [ ] Accessibility audit planned for all user interfaces
- [ ] Test strategy covers unit, integration, and E2E testing
- [ ] Documentation requirements identified and specified
- [ ] Cross-agent coordination validated for consistency
EOF
}

# Function to generate synthesis prompt
generate_synthesis_prompt() {
    local session_dir="$1"
    local user_story="$2"
    
    cat > "$session_dir/05-claude-synthesis.md" << EOF
# Step 5: Integration & Synthesis (Claude Code)

**Project**: $PROJECT_NAME
**Final Integration**: All Agent Coordination Results

## Integration and Synthesis Protocol

**After ALL agents complete their tasks, use this prompt in Claude Code:**

\`\`\`markdown
Execute intelligent result synthesis for $PROJECT_NAME Gherkin user story implementation:

**Integration Context**: All specialized agents have completed their tasks for:

**Gherkin User Story**:
\`\`\`gherkin  
$user_story
\`\`\`

**Agent Implementation Results**:
- **Cursor (Backend)**: [PASTE_COMPLETE_BACKEND_RESULTS_HERE]
- **v0.dev (Frontend)**: [PASTE_COMPLETE_FRONTEND_RESULTS_HERE]  
- **Gemini Pro (Quality Analysis)**: [PASTE_COMPLETE_QA_ANALYSIS_HERE]

**Synthesis Protocol for $PROJECT_NAME**:
1. **Integration Validation**: Verify all components work together seamlessly within existing architecture
2. **Gherkin Compliance**: Confirm every acceptance criterion is fully implemented and testable
3. **Performance Verification**: Validate 90%+ improvement metrics against baseline
4. **Quality Assurance Integration**: Address all issues and recommendations from Gemini Pro
5. **Project Consistency**: Ensure alignment with $PROJECT_NAME conventions and patterns
6. **Deployment Preparation**: Create comprehensive deployment and rollback strategy

**Success Metrics Validation**:
- Feature implements ALL Gherkin scenarios: ✓/✗
- Backend implementation complete and tested: ✓/✗
- Frontend components functional and accessible: ✓/✗
- Integration between backend and frontend verified: ✓/✗
- Performance targets achieved: ✓/✗
- Security requirements satisfied: ✓/✗  
- Quality gates passed: ✓/✗
- Documentation updated: ✓/✗

**Final Integration Tasks**:
- **Full Test Suite Execution**: Run complete project test suite
- **E2E Scenario Validation**: Verify all Gherkin scenarios work end-to-end
- **Cross-Agent Coordination Review**: Validate successful A2A communication results
- **Performance Benchmark Testing**: Confirm 90%+ improvement achievement
- **Security Validation**: Complete security review of all new functionality
- **Documentation Updates**: Ensure all changes properly documented
- **Deployment Package Creation**: Prepare production-ready deployment
- **User Acceptance Criteria**: Create validation checklist for stakeholders

**Adaptive Learning Integration**:
- **Pattern Recognition**: Document successful orchestration strategies used
- **Process Optimization**: Identify improvements for future orchestrations  
- **Knowledge Integration**: Capture lessons learned specific to $PROJECT_NAME
- **Strategy Refinement**: Update coordination approaches based on results
- **Performance Analytics**: Record efficiency gains and quality improvements

**Project-Specific Final Validations**:
- Consistency with $PROJECT_NAME architecture and conventions
- Integration with existing systems and workflows
- Alignment with project's technical stack and patterns
- Compliance with established coding standards and practices
- Proper integration with current deployment and CI/CD processes

**Deliverable**: Complete, production-ready implementation of the Gherkin user story, fully integrated with $PROJECT_NAME and validated against all success criteria.

**Begin final synthesis and integration validation now.**
\`\`\`

## Final Integration Checklist

### Pre-Synthesis Validation
- [ ] All three agents (Cursor, Lovable, Gemini) completed their tasks
- [ ] Results from each agent collected and organized
- [ ] No blocking issues or incomplete implementations
- [ ] Ready for comprehensive integration analysis

### Post-Synthesis Validation  
- [ ] All Gherkin acceptance criteria confirmed implemented
- [ ] Full integration testing completed successfully
- [ ] Performance benchmarks achieved (90%+ improvement)
- [ ] Security and quality requirements satisfied
- [ ] Documentation updated and complete
- [ ] Deployment package ready for production
- [ ] User acceptance criteria clearly defined

### Success Metrics
- **Development Velocity**: Compared to manual implementation approach
- **Quality Score**: Based on comprehensive testing and validation
- **Integration Success**: Seamless operation within existing $PROJECT_NAME
- **User Experience**: Alignment with Gherkin user story requirements
- **Technical Excellence**: Architecture consistency and maintainability
EOF
}

# Function to generate evolution protocol prompts
generate_evolution_prompts() {
    local session_dir="$1"
    
    cat > "$session_dir/06-evolution-quarterly-review.md" << EOF
# Evolution Protocol: Quarterly Review

**Project**: $PROJECT_NAME
**Review Frequency**: Every 3 months
**Technology Stack**: $TECH_STACK

## Quarterly AI Orchestration Evolution Assessment

**Use this prompt for comprehensive quarterly reviews:**

\`\`\`markdown
**AI Orchestration Evolution Assessment - [QUARTER] [YEAR]**

Conduct comprehensive evaluation of current AI orchestration framework for $PROJECT_NAME against latest industry developments:

**Current System Analysis for $PROJECT_NAME**:
1. **Performance Metrics Review**:
   - Development velocity trends over past quarter
   - Quality metrics and error rates for orchestrated implementations
   - Agent coordination efficiency across Cursor, v0.dev, Gemini Pro
   - User satisfaction and adoption rates within development team
   - Success rate of Gherkin story implementations via orchestration

2. **Industry Research Scan**:
   - Latest releases from Anthropic (Claude models, research papers)
   - Google AI updates (Gemini evolution, Vertex AI, ADK improvements)
   - Microsoft developments (Copilot Studio, A2A protocol updates)
   - OpenAI innovations (GPT models, agent frameworks, API updates)
   - LangGraph/LangChain framework evolution
   - CrewAI, AutoGen, and emerging framework developments
   - $TECH_STACK specific AI tool improvements

3. **Competitive Analysis**:
   - New orchestration patterns and architectures
   - Performance benchmarks and comparative studies
   - Enterprise adoption trends and case studies
   - Security and compliance standard updates relevant to $TECH_STACK

4. **Technology Stack Assessment for $PROJECT_NAME**:
   - Model capability improvements affecting $TECH_STACK development
   - Tool integration opportunities specific to detected tech stack
   - Infrastructure optimization possibilities
   - Cost-effectiveness analysis of current orchestration approach

**Evaluation Framework**:
✅ **Performance Gap Analysis**: Compare current vs. industry benchmarks
✅ **Feature Obsolescence Check**: Identify outdated orchestration components
✅ **Opportunity Assessment**: Evaluate new capabilities worth adopting for $PROJECT_NAME
✅ **Risk Evaluation**: Assess potential vulnerabilities or limitations
✅ **ROI Analysis**: Cost-benefit of potential upgrades

**Output Required**:
1. **Status Assessment**: Current system rating (1-10) vs. industry standard
2. **Recommended Updates**: Prioritized list of improvements for $PROJECT_NAME
3. **Implementation Roadmap**: Phased upgrade plan with timeline
4. **Risk Mitigation**: Strategies for safe transition without disrupting $PROJECT_NAME
5. **Performance Projections**: Expected improvements from updates
\`\`\`

## Implementation Schedule

- **Q1 Review**: January (Focus: Annual planning alignment)
- **Q2 Review**: April (Focus: Mid-year optimization)
- **Q3 Review**: July (Focus: Technology refresh assessment)
- **Q4 Review**: October (Focus: Year-end evaluation and next year planning)

## Success Metrics to Track

- **Orchestration Efficiency**: Time savings vs. manual development
- **Quality Improvements**: Reduced bugs and better architecture consistency
- **Team Productivity**: Developer satisfaction and adoption rates
- **Innovation Index**: Integration of cutting-edge AI orchestration patterns
EOF

    cat > "$session_dir/07-evolution-monthly-health.md" << EOF
# Evolution Protocol: Monthly Health Check

**Project**: $PROJECT_NAME
**Review Frequency**: Monthly (1st Monday of each month)
**Last Updated**: [UPDATE_DATE]

## Monthly Orchestration Health Assessment

**Use this prompt for regular monthly health monitoring:**

\`\`\`markdown
**Monthly Orchestration Health Assessment - [MONTH] [YEAR]**

Perform rapid health check of AI orchestration system for $PROJECT_NAME:

**Performance Monitoring**:
- Development velocity trends using orchestration vs. manual implementation
- Agent coordination success rates (Claude, Cursor, v0.dev, Gemini Pro)
- Context isolation effectiveness during multi-agent workflows
- Error patterns and resolution times in orchestrated implementations
- Gherkin user story completion rates and quality scores

**Usage Pattern Analysis for $PROJECT_NAME**:
- Most/least utilized orchestration patterns in recent implementations
- Agent workload distribution and effectiveness
- Bottleneck identification in the coordination workflow
- User experience feedback from development team members
- Technology stack specific challenges with $TECH_STACK

**Quick Industry Scan**:
- Major AI model releases this month affecting development workflows
- New framework announcements relevant to $TECH_STACK
- Security updates or vulnerabilities in AI orchestration tools
- Performance benchmarking updates from industry leaders

**Health Score Calculation**:
Rate each area (1-10) for $PROJECT_NAME:
- Orchestration Efficiency: [SCORE]/10
- Agent Coordination Quality: [SCORE]/10  
- Technology Currency: [SCORE]/10
- Security Compliance: [SCORE]/10
- Developer Satisfaction: [SCORE]/10

**Action Items**:
- Immediate fixes needed: [LIST_SPECIFIC_TO_PROJECT]
- Optimization opportunities: [LIST_TECH_STACK_SPECIFIC]
- Monitoring recommendations: [LIST_PROJECT_IMPROVEMENTS]
\`\`\`

## Monthly Health Tracking Template

| Month | Efficiency Score | Coordination Score | Tech Currency | Security | Satisfaction | Overall Health |
|-------|-----------------|-------------------|---------------|----------|--------------|---------------|
| [MONTH] | /10 | /10 | /10 | /10 | /10 | /10 |

## Alert Thresholds

- **🚨 Critical**: Overall health < 6/10 → Immediate action required
- **⚠️ Warning**: Overall health 6-7/10 → Schedule improvement sprint  
- **✅ Good**: Overall health 8-9/10 → Maintain current approach
- **🎯 Excellent**: Overall health 10/10 → Document best practices for replication
EOF

    cat > "$session_dir/08-evolution-breakthrough-detection.md" << EOF
# Evolution Protocol: Breakthrough Detection

**Project**: $PROJECT_NAME
**Technology Stack**: $TECH_STACK
**Purpose**: Rapid assessment of AI orchestration breakthroughs

## Breakthrough Detection Protocol

**Use this prompt when new AI orchestration developments emerge:**

\`\`\`markdown
**AI Orchestration Breakthrough Detection Alert**

Analyze recent development for potential impact on $PROJECT_NAME orchestration:

**Development Details**:
- Source: [COMPANY/RESEARCH_ORG]
- Announcement: [SPECIFIC_UPDATE]
- Release Date: [DATE]
- Availability Timeline: [TIMELINE]
- Relevance to $TECH_STACK: [DIRECT/INDIRECT/NONE]

**Impact Assessment for $PROJECT_NAME**:
1. **Relevance Analysis**:
   - Direct impact on multi-agent orchestration workflows
   - Compatibility with current $TECH_STACK architecture  
   - Performance improvement potential for our use cases
   - Cost implications and ROI considerations
   - Integration complexity with existing $PROJECT_NAME setup

2. **Integration Feasibility**:
   - Technical compatibility with $FRONTEND, $BACKEND, $DATABASE stack
   - Implementation complexity and resource requirements
   - Migration path from current orchestration approach
   - Risk factors and potential disruptions to $PROJECT_NAME
   - Timeline for integration and full deployment

3. **Competitive Advantage**:
   - Differentiation potential in our development workflow
   - Industry adoption timeline and early adopter benefits  
   - Strategic positioning impact for $PROJECT_NAME development
   - Long-term sustainability and vendor lock-in considerations

4. **Decision Framework**:
   - Immediate action required: YES/NO
   - Pilot testing recommended: YES/NO  
   - Full integration timeline estimate: [WEEKS/MONTHS]
   - Risk level assessment: LOW/MEDIUM/HIGH
   - Resource allocation needed: [TEAM_DAYS]

**Recommendation for $PROJECT_NAME**:
[WAIT/PILOT/IMPLEMENT/IGNORE] with detailed rationale considering our current tech stack and development priorities.

**Next Steps**:
1. [IMMEDIATE_ACTIONS_IF_ANY]
2. [EVALUATION_TIMELINE]
3. [DECISION_POINT]
\`\`\`

## Breakthrough Monitoring Sources

### Primary Sources (Check Weekly)
- Anthropic research publications and model releases
- Google AI and DeepMind announcements  
- Microsoft Copilot Studio and Azure AI updates
- OpenAI API and framework developments

### Secondary Sources (Check Monthly)
- LangGraph and LangChain framework updates
- CrewAI and AutoGen community developments  
- Academic papers on multi-agent orchestration
- Industry case studies and benchmarking reports

### Technology Stack Specific Sources
- **$TECH_STACK** specific AI tool announcements
- Framework-specific AI integration updates
- Developer community discussions and best practices

## Decision Matrix Template

| Criteria | Score (1-5) | Weight | Weighted Score |
|----------|-------------|---------|----------------|
| Relevance to $PROJECT_NAME | | 0.3 | |
| Implementation Feasibility | | 0.2 | |  
| Performance Impact | | 0.2 | |
| Cost-Benefit Ratio | | 0.15 | |
| Risk Level (inverted) | | 0.15 | |
| **Total** | | **1.0** | |

**Decision Threshold**: 
- Score ≥ 4.0: IMPLEMENT
- Score 3.0-3.9: PILOT  
- Score 2.0-2.9: EVALUATE_FURTHER
- Score < 2.0: IGNORE
EOF
}

# Function to generate session tracker
generate_session_tracker() {
    local session_dir="$1"
    local user_story="$2"
    
    cat > "$session_dir/session-tracker.md" << EOF
# AI Orchestration Session Tracker

**Project**: $PROJECT_NAME
**Technology Stack**: $TECH_STACK  
**Session Started**: $(date)

## Gherkin User Story
\`\`\`gherkin
$user_story
\`\`\`

## Agent Progress Tracking

| Step | Agent | Status | Start Time | Complete Time | Key Results | Blockers | Notes |
|------|-------|--------|------------|---------------|-------------|----------|-------|
| 1 | Claude Code (Coordinator) | ⏳ Pending | | | | | |
| 2 | Cursor (Backend) | ⏳ Pending | | | | | |  
| 3 | v0.dev (Frontend) | ⏳ Pending | | | | | |
| 4 | Gemini Pro (Quality) | ⏳ Pending | | | | | |
| 5 | Claude Code (Synthesis) | ⏳ Pending | | | | | |

**Status Legend**: ⏳ Pending | 🔄 In Progress | ✅ Complete | ❌ Blocked | ⚠️ Issues

## A2A Communication Log

### Backend ↔ Frontend Coordination
- [ ] API contracts defined and shared
- [ ] Data model alignment confirmed  
- [ ] Integration points documented
- [ ] Error handling approach agreed

### Quality Assurance Coordination  
- [ ] Requirements traceability completed
- [ ] Test strategy approved by all agents
- [ ] Security analysis reviewed
- [ ] Performance benchmarks established

### Master Coordinator Oversight
- [ ] Initial task decomposition completed
- [ ] Agent assignments confirmed
- [ ] Progress monitoring checkpoints established
- [ ] Final synthesis criteria defined

## Success Metrics Dashboard

### Performance Metrics
- **Development Velocity**: [MEASURE_AGAINST_MANUAL_APPROACH]
- **Quality Score**: [BASED_ON_TESTING_AND_VALIDATION]  
- **Coordination Efficiency**: [A2A_COMMUNICATION_SUCCESS_RATE]
- **User Story Compliance**: [GHERKIN_CRITERIA_FULFILLMENT_%]

### Technical Metrics
- **Backend Test Coverage**: _%
- **Frontend Component Tests**: _%
- **Integration Test Success**: _%
- **Performance Benchmarks Met**: _%
- **Security Validations Passed**: _%

## Implementation Results Summary

### Backend Implementation (Cursor)
**Status**: [PENDING/IN_PROGRESS/COMPLETE]
**Key Deliverables**:
- [ ] API endpoints implemented
- [ ] Database schema updated
- [ ] Business logic validated
- [ ] Integration tests passing
- [ ] API documentation updated

**Results**: [PASTE_CURSOR_RESULTS_HERE]

### Frontend Implementation (v0.dev)  
**Status**: [PENDING/IN_PROGRESS/COMPLETE]
**Key Deliverables**:
- [ ] Components developed  
- [ ] User interactions implemented
- [ ] API integration complete
- [ ] Accessibility validated
- [ ] Component tests passing

**Results**: [PASTE_LOVABLE_RESULTS_HERE]

### Quality Assurance (Gemini Pro)
**Status**: [PENDING/IN_PROGRESS/COMPLETE] 
**Key Deliverables**:
- [ ] Requirements analysis complete
- [ ] Test strategy documented
- [ ] Security analysis finished
- [ ] Performance validation done
- [ ] Documentation updated

**Results**: [PASTE_GEMINI_RESULTS_HERE]

## Final Integration Status

### Integration Validation (Step 5)
- [ ] All components integrated successfully
- [ ] End-to-end testing complete
- [ ] Performance targets achieved (90%+ improvement)
- [ ] All Gherkin acceptance criteria validated
- [ ] Production deployment ready

### Lessons Learned
**What Worked Well**:
- [RECORD_SUCCESSFUL_PATTERNS]

**Areas for Improvement**:
- [IDENTIFY_OPTIMIZATION_OPPORTUNITIES]

**Recommendations for Next Orchestration**:
- [PROCESS_IMPROVEMENTS_FOR_FUTURE]

## Project-Specific Notes

**Technology Stack Considerations**:
- [TECH_STACK_SPECIFIC_INSIGHTS]

**Architecture Integration**:  
- [HOW_WELL_INTEGRATED_WITH_EXISTING_CODEBASE]

**Performance Impact**:
- [MEASURED_IMPROVEMENTS_VS_BASELINE]

**Team Productivity**:
- [DEVELOPER_EXPERIENCE_AND_SATISFACTION]

---

**Session Completion**: [DATE_TIME]
**Overall Success Rating**: [1-10]/10
**Recommendation for Future Use**: [YES/NO/WITH_MODIFICATIONS]
EOF
}

# Function to generate quick reference
generate_quick_reference() {
    local session_dir="$1"
    
    cat > "$session_dir/quick-reference.md" << EOF
# AI Orchestration Quick Reference

**Project**: $PROJECT_NAME
**Tech Stack**: $TECH_STACK
**Session**: $(date +%Y-%m-%d)

## 5-Step Orchestration Workflow

### 1. 🧠 Master Coordinator (Claude Code)
- **Purpose**: Analyze Gherkin story and create coordination plan
- **Input**: Gherkin user story + project context
- **Output**: Task decomposition and agent assignments
- **Key Action**: Paste coordinator prompt, wait for complete breakdown

### 2. ⚙️ Backend Implementation (Cursor)  
- **Purpose**: Implement server-side functionality
- **Input**: Backend requirements from Claude coordination
- **Output**: APIs, database changes, business logic
- **Key Action**: Focus on TDD approach, coordinate with frontend

### 3. 🎨 Frontend Implementation (v0.dev)
- **Purpose**: Build user interface and interactions  
- **Input**: UI requirements from Claude coordination
- **Output**: Components, user flows, API integration
- **Key Action**: Maintain design consistency, ensure accessibility

### 4. 🔍 Quality Assurance (Gemini Pro)
- **Purpose**: Analyze quality, security, and testing strategy
- **Input**: Original Gherkin story + implementation context
- **Output**: Test strategy, security analysis, documentation
- **Key Action**: Run in parallel, focus on comprehensive analysis

### 5. 🔧 Integration & Synthesis (Claude Code)
- **Purpose**: Combine all results into final solution
- **Input**: Results from all three implementation agents
- **Output**: Production-ready integrated solution
- **Key Action**: Validate all requirements met, prepare for deployment

## Key Success Rules

### ✅ Always Follow This Sequence
1. **Start with Claude Code** - Never skip the coordination step
2. **Wait for coordination plan** - Don't proceed without task breakdown
3. **Maintain context isolation** - Each agent works independently  
4. **Share specific results** - Coordinate through Claude Code
5. **Complete with synthesis** - Final integration is mandatory

### ✅ A2A Communication Protocol
- **Report progress** to Master Coordinator regularly
- **Share blockers immediately** - Don't wait for completion
- **Coordinate integration points** - Especially backend ↔ frontend
- **Document decisions** - Important for final synthesis

### ✅ Quality Gates
- All Gherkin acceptance criteria must be implemented
- Backend and frontend must integrate seamlessly
- Security and performance requirements must be met
- Comprehensive testing strategy must be executed
- Documentation must be updated and complete

## Project-Specific Guidelines

### Technology Stack: $TECH_STACK
- Follow existing patterns and conventions in $PROJECT_NAME
- Use established testing frameworks and approaches
- Maintain consistency with current architecture
- Consider existing deployment and CI/CD processes

### Performance Targets
- **90%+ improvement** over manual implementation approach
- **Seamless integration** with existing $PROJECT_NAME codebase
- **Full compliance** with all Gherkin acceptance criteria
- **Production-ready quality** with comprehensive testing

## Emergency Protocols

### If Agents Conflict
- **Action**: Return to Claude Code for conflict resolution
- **Don't**: Try to resolve conflicts directly between agents
- **Do**: Provide specific details about the conflict

### If Implementation Blocked  
- **Action**: Report blocker to Master Coordinator immediately
- **Include**: Specific details about the blocking issue
- **Expect**: Adaptive strategy refinement from coordination

### If Quality Issues Found
- **Action**: Address all issues before final synthesis
- **Priority**: Security and performance issues first
- **Validation**: Re-test after fixes implemented

### If Performance Targets Missed
- **Action**: Iterate with Gemini Pro recommendations
- **Focus**: Optimization opportunities identified in QA analysis
- **Measure**: Validate improvements before proceeding

## Session Success Indicators

- ✅ All 5 steps completed successfully
- ✅ Every Gherkin acceptance criterion implemented  
- ✅ Backend and frontend working together seamlessly
- ✅ Performance improvement of 90%+ achieved
- ✅ Quality gates passed (security, testing, documentation)
- ✅ Ready for production deployment
- ✅ Team satisfied with orchestration process

## Next Steps After Session

1. **Deploy** the integrated solution following project procedures
2. **Monitor** performance and user feedback post-deployment
3. **Document** lessons learned for future orchestrations
4. **Schedule** next quarterly evolution review if needed
5. **Update** orchestration approach based on insights gained

---

**Remember**: This orchestration system achieves 90%+ performance improvement through intelligent coordination. Trust the process, follow the sequence, maintain communication, and deliver exceptional results! 🚀
EOF
}

# Main execution function
main() {
    # Get current directory (should be project root)
    local current_dir="$(pwd)"
    
    echo -e "${YELLOW}🔍 Current directory: $current_dir${NC}"
    
    # Validate this is a suitable project
    if ! validate_project "$current_dir"; then
        echo -e "${RED}❌ Project validation failed. Exiting.${NC}"
        exit 1
    fi
    
    # Detect project context
    detect_project_context "$current_dir"
    
    # Generate technical context
    local tech_context=$(generate_tech_context)
    
    # Get user story from input
    local user_story=$(get_user_story)
    
    # Create session directory
    local session_dir=$(create_session_directory "$current_dir")
    
    echo -e "${YELLOW}🚀 Generating orchestration session...${NC}"
    
    # Generate all prompts and supporting files
    generate_coordinator_prompt "$session_dir" "$user_story" "$tech_context"
    generate_backend_prompt "$session_dir" "$user_story" "$tech_context"
    generate_frontend_prompt "$session_dir" "$user_story" "$tech_context"
    generate_qa_prompt "$session_dir" "$user_story" "$tech_context"
    generate_synthesis_prompt "$session_dir" "$user_story"
    generate_evolution_prompts "$session_dir"
    generate_session_tracker "$session_dir" "$user_story"
    generate_quick_reference "$session_dir"
    
    # Success summary
    echo ""
    echo -e "${GREEN}🎉 Universal AI Orchestration Session Generated Successfully!${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo ""
    echo -e "${BLUE}📁 Session Location:${NC} $session_dir"
    echo ""
    echo -e "${BLUE}📋 Generated Files:${NC}"
    echo -e "   ${GREEN}01-claude-coordinator.md${NC}      - Master Coordinator (START HERE)"
    echo -e "   ${GREEN}02-cursor-backend.md${NC}          - Backend Implementation"  
    echo -e "   ${GREEN}03-lovable-frontend.md${NC}        - Frontend Implementation"
    echo -e "   ${GREEN}04-gemini-quality.md${NC}          - Quality Assurance & Testing"
    echo -e "   ${GREEN}05-claude-synthesis.md${NC}        - Final Integration & Synthesis"
    echo -e "   ${YELLOW}06-evolution-quarterly-review.md${NC} - Quarterly System Evolution"
    echo -e "   ${YELLOW}07-evolution-monthly-health.md${NC}   - Monthly Health Checks"
    echo -e "   ${YELLOW}08-evolution-breakthrough-detection.md${NC} - Breakthrough Analysis"
    echo -e "   ${BLUE}session-tracker.md${NC}            - Progress Tracking Dashboard"
    echo -e "   ${BLUE}quick-reference.md${NC}            - Workflow Reminder Guide"
    echo ""
    echo -e "${GREEN}🎯 Project-Specific Adaptations:${NC}"
    echo -e "   📂 Project: $PROJECT_NAME"
    echo -e "   🏗️  Type: $PROJECT_TYPE"  
    echo -e "   💻 Stack: $TECH_STACK"
    [[ -n "$FRONTEND" ]] && echo -e "   🎨 Frontend: $FRONTEND"
    [[ -n "$BACKEND" ]] && echo -e "   ⚙️  Backend: $BACKEND"
    [[ -n "$DATABASE" ]] && echo -e "   🗄️  Database: $DATABASE"
    [[ -n "$TESTING" ]] && echo -e "   🧪 Testing: $TESTING"
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo -e "   1. ${GREEN}Open 01-claude-coordinator.md${NC} and paste prompt in Claude Code"
    echo -e "   2. ${GREEN}Use session-tracker.md${NC} to monitor progress across all agents"
    echo -e "   3. ${GREEN}Follow the 5-step workflow${NC} for 90%+ performance improvement"
    echo -e "   4. ${YELLOW}Use evolution prompts${NC} for periodic system updates"
    echo ""
    echo -e "${GREEN}✨ Ready for next-generation AI orchestration with intelligent project adaptation!${NC}"
}

# Execute main function
main "$@"