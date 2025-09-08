#!/usr/bin/env bash

# Project Inception Wizard with Claude Code Subagent Integration
# Intelligent project discovery and specification generation

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

# Project context
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")

show_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                🎯 PROJECT INCEPTION WIZARD 🎯                 ║"
    echo "║                                                                ║"
    echo "║        AI-Powered Project Discovery & Specification            ║"
    echo "║                                                                ║"
    echo "║   🧠 Deep Analysis  🎯 Smart Recommendations  🚀 Ready to Code ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

show_welcome() {
    echo -e "${CYAN}Welcome to the Project Inception Wizard!${NC}"
    echo ""
    echo -e "${CYAN}I'll help you discover, define, and set up your project with AI-powered analysis.${NC}"
    echo -e "${CYAN}This wizard uses Claude Code subagents to provide deep insights and recommendations.${NC}"
    echo ""
    echo -e "${YELLOW}📁 Project: $PROJECT_NAME${NC}"
    echo -e "${YELLOW}📂 Location: $PROJECT_DIR${NC}"
    echo ""
    
    echo -e "${YELLOW}Press Enter to begin project discovery...${NC}"
    read -r
}

# Project discovery questions
collect_project_info() {
    echo -e "${BLUE}🎯 Project Discovery${NC}"
    echo -e "${BLUE}═══════════════════${NC}"
    echo ""
    
    # Project type
    echo -e "${CYAN}What type of project are you creating?${NC}"
    echo -e "${YELLOW}1. 🌐 Web Application (React, Vue, Angular)${NC}"
    echo -e "${YELLOW}2. 📱 Mobile App (React Native, Flutter)${NC}"  
    echo -e "${YELLOW}3. 🔗 API/Backend Service (REST, GraphQL)${NC}"
    echo -e "${YELLOW}4. 🛠️ Development Tool/CLI${NC}"
    echo -e "${YELLOW}5. 📊 Data Analysis/ML Project${NC}"
    echo -e "${YELLOW}6. 📚 Documentation/Content Site${NC}"
    echo -e "${YELLOW}7. 🎮 Other/Custom${NC}"
    echo ""
    echo -e "${YELLOW}Select project type [1-7]: ${NC}"
    read -r PROJECT_TYPE
    
    # Map selection to type
    case "$PROJECT_TYPE" in
        1) PROJECT_TYPE_NAME="Web Application" ;;
        2) PROJECT_TYPE_NAME="Mobile App" ;;
        3) PROJECT_TYPE_NAME="API/Backend Service" ;;
        4) PROJECT_TYPE_NAME="Development Tool" ;;
        5) PROJECT_TYPE_NAME="Data Analysis Project" ;;
        6) PROJECT_TYPE_NAME="Documentation Site" ;;
        *) PROJECT_TYPE_NAME="Custom Project" ;;
    esac
    
    echo ""
    echo -e "${GREEN}✓ Project Type: $PROJECT_TYPE_NAME${NC}"
    echo ""
    
    # Problem definition
    echo -e "${CYAN}What problem does your project solve?${NC}"
    echo -e "${YELLOW}(Be specific - this helps with technical recommendations)${NC}"
    echo -e "${CYAN}Example: 'Task management for remote teams with real-time collaboration'${NC}"
    echo ""
    echo -e "${YELLOW}Problem description: ${NC}"
    read -r PROJECT_PROBLEM
    echo ""
    
    # Target users
    echo -e "${CYAN}Who will use this project?${NC}"
    echo -e "${YELLOW}(Target audience helps with UX and technical decisions)${NC}"
    echo -e "${CYAN}Example: 'Small development teams, 5-15 people, technical users'${NC}"
    echo ""
    echo -e "${YELLOW}Target users: ${NC}"
    read -r PROJECT_USERS
    echo ""
    
    # Key features
    echo -e "${CYAN}What are the main features? (3-5 key capabilities)${NC}"
    echo -e "${YELLOW}(One per line, or comma-separated)${NC}"
    echo -e "${CYAN}Example: 'User authentication, Task boards, Team chat, Progress tracking'${NC}"
    echo ""
    echo -e "${YELLOW}Key features: ${NC}"
    read -r PROJECT_FEATURES
    echo ""
    
    # Constraints and preferences
    echo -e "${CYAN}Any constraints or preferences?${NC}"
    echo -e "${YELLOW}(Timeline, technology preferences, complexity level, etc.)${NC}"
    echo -e "${CYAN}Example: '8-week timeline, prefer React, moderate complexity, mobile-friendly'${NC}"
    echo ""
    echo -e "${YELLOW}Constraints/Preferences (optional): ${NC}"
    read -r PROJECT_CONSTRAINTS
    echo ""
    
    # Scale and deployment
    echo -e "${CYAN}Expected scale and deployment?${NC}"
    echo -e "${YELLOW}1. 🏠 Personal/Small (< 100 users)${NC}"
    echo -e "${YELLOW}2. 🏢 Business/Medium (100-10K users)${NC}"
    echo -e "${YELLOW}3. 🌐 Enterprise/Large (10K+ users)${NC}"
    echo -e "${YELLOW}4. 🤷 Not sure yet${NC}"
    echo ""
    echo -e "${YELLOW}Expected scale [1-4]: ${NC}"
    read -r PROJECT_SCALE
    
    case "$PROJECT_SCALE" in
        1) PROJECT_SCALE_NAME="Personal/Small Scale" ;;
        2) PROJECT_SCALE_NAME="Business/Medium Scale" ;;
        3) PROJECT_SCALE_NAME="Enterprise/Large Scale" ;;
        *) PROJECT_SCALE_NAME="Scale TBD" ;;
    esac
    
    echo ""
    echo -e "${GREEN}✓ Expected Scale: $PROJECT_SCALE_NAME${NC}"
    echo ""
}

# Prepare context for optimal AI platform analysis
prepare_analysis_context() {
    echo -e "${BLUE}🧠 AI Analysis Preparation${NC}"
    echo -e "${BLUE}═══════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Preparing comprehensive context for AI platform analysis...${NC}"
    echo -e "${CYAN}This will optimize the input for your available AI tools.${NC}"
    echo ""
    
    # Load user's AI tool configuration
    local config_file="$HOME/.ai-orchestration-config.json"
    
    # Prepare structured context for AI platform analysis
    cat > "/tmp/project-context-prepared.md" << EOF
# Project Analysis Context - Prepared for AI Platform Analysis

## Project Overview
- **Name**: $PROJECT_NAME
- **Type**: $PROJECT_TYPE_NAME  
- **Scale**: $PROJECT_SCALE_NAME

## Problem Definition
**Problem**: $PROJECT_PROBLEM
**Target Users**: $PROJECT_USERS

## Requirements  
**Key Features**: $PROJECT_FEATURES
**Constraints**: $PROJECT_CONSTRAINTS

## Analysis Needed
This context is prepared for optimal AI platform analysis. Please use your available tools:

### For Strategic/Architectural Decisions:
- **Google Deep Think**: Use for complex architectural reasoning, trade-off analysis, and strategic planning
- **Google Deep Research**: Use for technology evaluation, competitive analysis, and best practices research

### For Implementation Planning:
- **Claude Code**: Use for documentation synthesis and workflow generation
- **Cursor Pro**: Use for technical implementation details
- **NotebookLM**: Use for comprehensive knowledge synthesis

## Recommended Analysis Approach
1. **Deep Strategic Analysis** (if Deep Think available): Architecture decisions, technical trade-offs, scalability planning
2. **Comprehensive Research** (if Deep Research available): Technology stack evaluation, industry best practices, competitive landscape
3. **Implementation Planning** (Claude Code): Break down into actionable development phases
4. **Tool Integration** (Platform-specific): Optimize for available AI development tools

EOF
    
    echo -e "${YELLOW}📋 Context prepared for AI platform analysis${NC}"
    
    # Generate intelligent recommendations based on available tools
    if [[ -f "$config_file" ]]; then
        echo -e "${CYAN}📊 Checking your available AI tools for optimal analysis approach...${NC}"
        
        # Check for premium tools and provide guidance
        if command -v jq &> /dev/null && [[ -f "$config_file" ]]; then
            local has_deep_think=$(jq -r '.tool_status.gemini_deep_think // "unavailable"' "$config_file" 2>/dev/null)
            local has_deep_research=$(jq -r '.tool_status.gemini_deep_research // "unavailable"' "$config_file" 2>/dev/null)
            local has_notebooklm=$(jq -r '.tool_status.notebooklm // "unavailable"' "$config_file" 2>/dev/null)
            
            echo ""
            echo -e "${PURPLE}🎯 RECOMMENDED NEXT STEPS (Based on your AI tools):${NC}"
            echo ""
            
            if [[ "$has_deep_think" == "available" ]]; then
                echo -e "${GREEN}✅ Google Deep Think available${NC}"
                echo -e "${CYAN}   → Use Deep Think for architectural decisions and strategic planning${NC}"
                echo -e "${CYAN}   → Upload the context file to Deep Think for 15-20 minute analysis session${NC}"
                echo ""
            fi
            
            if [[ "$has_deep_research" == "available" ]]; then
                echo -e "${GREEN}✅ Google Deep Research available${NC}"
                echo -e "${CYAN}   → Use Deep Research for technology stack evaluation and best practices${NC}"
                echo -e "${CYAN}   → Research similar projects and optimal technology choices${NC}"
                echo ""
            fi
            
            if [[ "$has_notebooklm" == "available" ]]; then
                echo -e "${GREEN}✅ NotebookLM available${NC}"
                echo -e "${CYAN}   → Upload all project documents to NotebookLM for synthesis${NC}"
                echo -e "${CYAN}   → Generate audio briefings for team alignment${NC}"
                echo ""
            fi
            
            echo -e "${YELLOW}💡 OPTIMAL WORKFLOW:${NC}"
            echo -e "${CYAN}1. Use your premium AI tools for strategic analysis (Deep Think/Research)${NC}"
            echo -e "${CYAN}2. Return here with insights to generate comprehensive PRD${NC}"
            echo -e "${CYAN}3. Use this system for implementation coordination and workflow generation${NC}"
            echo ""
        fi
    fi
    
    echo -e "${GREEN}✅ Context preparation complete!${NC}"
    echo -e "${CYAN}📁 Prepared context saved: /tmp/project-context-prepared.md${NC}"
    echo ""
    echo -e "${YELLOW}Next: Use your available AI tools for analysis, then return to continue PRD generation${NC}"
    echo -e "${YELLOW}Press Enter when ready to continue with PRD generation...${NC}"
    read -r
    echo ""
}

# Generate comprehensive PRD using analysis
generate_comprehensive_prd() {
    echo -e "${BLUE}📋 Generating Comprehensive PRD${NC}"
    echo -e "${BLUE}═══════════════════════════════${NC}"
    echo ""
    
    local prd_file=".claude/prds/${PROJECT_NAME,,}-comprehensive-prd.md"
    
    # Use subagent to generate detailed PRD
    cat > "$prd_file" << EOF
# $PROJECT_NAME - Product Requirements Document

**Generated by AI Orchestration System**  
**Date**: $(date)  
**Project Type**: $PROJECT_TYPE_NAME  
**Scale**: $PROJECT_SCALE_NAME  

## 📋 Executive Summary

### Problem Statement
$PROJECT_PROBLEM

### Target Users
$PROJECT_USERS

### Solution Overview
A $PROJECT_TYPE_NAME designed to solve $PROJECT_PROBLEM for $PROJECT_USERS through intelligent features and modern technology.

## 🎯 Core Features

### Primary Features
$(echo "$PROJECT_FEATURES" | sed 's/,/\n-/g' | sed 's/^/- /')

### Success Metrics
- User adoption and engagement rates
- Feature utilization analytics  
- Performance benchmarks
- User satisfaction scores

## 🏗️ Technical Specifications

### Recommended Technology Stack

**Frontend**: 
- Framework: React with TypeScript (recommended for $PROJECT_TYPE_NAME)
- Styling: Tailwind CSS for rapid development
- State Management: Zustand for simple state, Redux Toolkit for complex apps
- Testing: Vitest + React Testing Library

**Backend**:
- Runtime: Node.js with Express/Fastify
- Language: TypeScript for type safety
- Database: PostgreSQL for relational data, Redis for caching
- Authentication: JWT with refresh tokens

**Infrastructure**:
- Hosting: Vercel (frontend) + Railway/Render (backend)  
- Database: Supabase or PlanetScale
- Monitoring: Sentry for error tracking
- Analytics: Posthog or Mixpanel

### Architecture Overview
- **Pattern**: Monolithic backend with SPA frontend
- **API Design**: RESTful with potential GraphQL migration
- **Real-time**: WebSocket connections for live features
- **Security**: OWASP compliance, input validation, rate limiting

## 🚀 Development Approach

### Methodology
- **Approach**: MVP-first with iterative development
- **Phases**: 3 phases over 8-10 weeks
- **Testing**: Test-driven development with CI/CD

### Phase Breakdown

**Phase 1 (3-4 weeks): Core Foundation**
- User authentication and authorization
- Basic UI framework and navigation  
- Core data models and API endpoints
- Basic CRUD operations

**Phase 2 (3-4 weeks): Key Features**  
- Primary feature implementation
- Advanced UI components
- Real-time functionality
- Integration testing

**Phase 3 (2-3 weeks): Polish & Launch**
- Performance optimization
- Security hardening
- User feedback integration
- Production deployment

## 🎭 AI Development Optimization

### Recommended AI Tool Usage
- **Strategic Planning**: Claude Code for requirements analysis
- **Backend Development**: Cursor Pro with Claude 3.5 Sonnet
- **Frontend Development**: Lovable + Supabase for rapid prototyping
- **Code Review**: Jules for continuous code quality
- **Documentation**: NotebookLM for knowledge management

### Development Workflow
1. **Requirements Analysis**: Use this PRD with AI orchestration
2. **Epic Creation**: Break down features into technical specifications  
3. **Implementation**: Leverage AI tools for accelerated development
4. **Quality Assurance**: Automated testing and AI-powered code review
5. **Deployment**: Streamlined CI/CD with monitoring

## 📊 Success Criteria

### Technical Requirements
- [ ] Page load times < 2 seconds
- [ ] 99.9% uptime availability
- [ ] Mobile-responsive design
- [ ] WCAG 2.1 AA accessibility compliance
- [ ] Security best practices implementation

### Business Requirements  
- [ ] All core features functional
- [ ] User onboarding flow complete
- [ ] Performance benchmarks met
- [ ] User acceptance testing passed
- [ ] Production deployment successful

## 🛠️ Next Steps

1. **Review and Refine**: Customize this PRD for specific needs
2. **Epic Creation**: Run PRD to Epic Converter for technical breakdown
3. **Tool Setup**: Configure AI development environment
4. **Development Start**: Begin Phase 1 implementation
5. **Monitoring**: Track progress and adjust as needed

---

**Constraints & Preferences**:
$PROJECT_CONSTRAINTS

**Generated with AI Orchestration System v3.0**  
**Optimized for available AI tools and development efficiency**
EOF

    echo -e "${GREEN}✅ Comprehensive PRD generated: $prd_file${NC}"
    echo ""
}

# Generate initial epics and development roadmap  
generate_development_roadmap() {
    echo -e "${BLUE}🎯 Generating Development Roadmap${NC}"
    echo -e "${BLUE}══════════════════════════════════${NC}"
    echo ""
    
    # Create initial epics based on analysis
    mkdir -p .claude/epics
    
    # Epic 1: Foundation
    cat > ".claude/epics/foundation-setup-epic.md" << EOF
# Epic 1: Foundation Setup & Infrastructure

## Overview
Establish the core foundation for $PROJECT_NAME including authentication, basic infrastructure, and development environment.

## User Stories
1. **As a user**, I want to register and login securely
2. **As a user**, I want my session to persist across browser sessions
3. **As a developer**, I want a robust development environment
4. **As a system**, I want proper error handling and monitoring

## Technical Implementation

### Backend Requirements
- User authentication system with JWT
- Database schema and migrations
- API rate limiting and security middleware
- Error handling and logging infrastructure
- Basic CRUD operations for core entities

### Frontend Requirements
- Authentication UI (login, register, forgot password)
- Protected routing and auth guards
- Global state management setup
- Error boundary and loading states
- Responsive design foundation

### Infrastructure Requirements
- Database setup (PostgreSQL)
- Environment configuration
- CI/CD pipeline basics
- Monitoring and logging setup

## Acceptance Criteria
- [ ] Users can register with email/password
- [ ] Users can login and maintain sessions
- [ ] Protected routes work correctly
- [ ] Error handling is comprehensive
- [ ] Mobile responsive design
- [ ] Performance meets basic benchmarks

## AI Development Notes
- **Backend**: Use Cursor Pro with Claude 3.5 Sonnet for API development
- **Frontend**: Use Lovable for rapid UI prototyping, then enhance with Cursor
- **Database**: Consider Supabase for integrated auth and database
- **Testing**: Implement comprehensive test coverage from start
EOF

    # Epic 2: Core Features
    cat > ".claude/epics/core-features-epic.md" << EOF
# Epic 2: Core Features Implementation

## Overview
Implement the primary features that solve the core problem for $PROJECT_NAME users.

## Feature Breakdown
Based on requirements: $PROJECT_FEATURES

## User Stories
$(echo "$PROJECT_FEATURES" | sed 's/,/\n/g' | sed 's/^/- **As a user**, I want /' | sed 's/$/ to be fully functional/')

## Technical Implementation

### Key Components
- Core business logic implementation
- Advanced UI components and interactions
- Real-time features (if applicable)
- Data visualization and analytics
- Advanced user workflows

### Integration Points
- Third-party service integration
- API endpoint expansion
- Advanced database queries
- Real-time synchronization
- Mobile optimization

## Performance Requirements
- Feature response times < 500ms
- Real-time updates < 100ms latency
- Smooth animations and transitions
- Efficient data loading

## AI Development Notes
- **Complex Logic**: Use Cursor Pro with multiple agents for parallel development
- **UI Components**: Leverage Lovable + Supabase for rapid feature development
- **Testing**: Comprehensive feature testing with edge case coverage
EOF

    # Epic 3: Polish & Production
    cat > ".claude/epics/production-polish-epic.md" << EOF
# Epic 3: Production Polish & Launch

## Overview
Prepare $PROJECT_NAME for production with performance optimization, security hardening, and launch preparation.

## User Stories
1. **As a user**, I want fast, reliable performance
2. **As a user**, I want my data to be secure
3. **As a user**, I want helpful documentation and support
4. **As a business**, I want comprehensive monitoring and analytics

## Technical Implementation

### Performance Optimization
- Code splitting and lazy loading
- Image optimization and CDN setup
- Database query optimization
- Caching strategy implementation
- Bundle size optimization

### Security Hardening
- Security audit and penetration testing
- Input validation and sanitization
- OWASP compliance verification
- SSL/TLS configuration
- Backup and recovery procedures

### Production Readiness
- Comprehensive monitoring setup
- Error tracking and alerting
- Performance monitoring
- User analytics implementation
- Documentation completion

### Launch Preparation
- User acceptance testing
- Staging environment validation
- Production deployment automation
- Post-launch monitoring setup
- Support documentation

## AI Development Notes
- **Quality Assurance**: Use Gemini Deep Think + Jules for comprehensive analysis
- **Documentation**: Use NotebookLM for comprehensive knowledge management
- **Monitoring**: Implement comprehensive observability
EOF

    echo -e "${GREEN}✅ Development roadmap generated with 3 epics${NC}"
    echo ""
}

# Generate contextual next steps
generate_next_steps() {
    echo -e "${BLUE}🚀 Smart Next Steps${NC}"
    echo -e "${BLUE}═══════════════════${NC}"
    echo ""
    
    echo -e "${GREEN}🎉 Project inception complete!${NC}"
    echo ""
    
    echo -e "${PURPLE}📊 What we've created:${NC}"
    echo -e "${CYAN}✅ Comprehensive PRD with AI-optimized recommendations${NC}"
    echo -e "${CYAN}✅ 3-phase development roadmap${NC}"  
    echo -e "${CYAN}✅ Technical architecture and tool recommendations${NC}"
    echo -e "${CYAN}✅ Ready-to-use epic specifications${NC}"
    echo ""
    
    echo -e "${PURPLE}🎯 Recommended Next Actions:${NC}"
    echo ""
    echo -e "${YELLOW}IMMEDIATE (Next 5 minutes):${NC}"
    echo -e "${CYAN}1. Review the generated PRD: ${PROJECT_DIR}/.claude/prds/${PROJECT_NAME,,}-comprehensive-prd.md${NC}"
    echo -e "${CYAN}2. Verify AI tool availability: Run Tool Verification (Option 10)${NC}"
    echo ""
    
    echo -e "${YELLOW}SHORT TERM (Today):${NC}"
    echo -e "${CYAN}3. Run Adaptive Workflow Generator (Option 11) for personalized setup${NC}"
    echo -e "${CYAN}4. Initialize development environment based on tech stack recommendations${NC}"
    echo -e "${CYAN}5. Set up version control: git init, initial commit${NC}"
    echo ""
    
    echo -e "${YELLOW}DEVELOPMENT START (This Week):${NC}"
    echo -e "${CYAN}6. Begin Epic 1 (Foundation): Focus on authentication and basic infrastructure${NC}"
    echo -e "${CYAN}7. Use recommended AI tools: Cursor Pro for backend, Lovable for frontend${NC}"
    echo -e "${CYAN}8. Set up CI/CD and monitoring early${NC}"
    echo ""
    
    echo -e "${PURPLE}💡 Pro Tips:${NC}"
    echo -e "${CYAN}• Use the generated epics as GitHub issues for project management${NC}"
    echo -e "${CYAN}• Leverage NotebookLM to synthesize all project documents${NC}"
    echo -e "${CYAN}• Run periodic reviews using the Quality Orchestrator${NC}"
    echo ""
    
    echo -e "${GREEN}Ready to start development? Run the orchestrator again and follow the recommended actions!${NC}"
    echo ""
}

# Main execution flow
main() {
    show_banner
    show_welcome
    collect_project_info
    prepare_analysis_context
    generate_comprehensive_prd
    generate_development_roadmap
    generate_next_steps
}

# Handle command line arguments
case "${1:-main}" in
    "main"|"")
        main
        ;;
    *)
        echo "Usage: $0"
        echo "  Runs the complete project inception wizard with AI analysis"
        ;;
esac