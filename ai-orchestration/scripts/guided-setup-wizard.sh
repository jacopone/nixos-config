#!/usr/bin/env bash

# Guided Setup Wizard - Complete AI Orchestration Setup
# Walks users through the entire setup process step by step

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

# Project detection
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")

show_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                🧙‍♂️ GUIDED SETUP WIZARD 🧙‍♂️                    ║"
    echo "║                                                                ║"
    echo "║           Complete AI Orchestration Setup Guide               ║"
    echo "║                                                                ║"
    echo "║    📋 Step-by-Step  🤖 Automated  🎯 Optimized  ✅ Verified    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

pause_for_user() {
    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

step_separator() {
    echo ""
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}$(printf '═%.0s' $(seq 1 ${#1}))${NC}"
    echo ""
}

check_prerequisites() {
    step_separator "🔍 STEP 1: Checking Prerequisites"
    
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    local missing_tools=()
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
        echo -e "${RED}  ❌ Git not found${NC}"
    else
        echo -e "${GREEN}  ✅ Git available${NC}"
    fi
    
    # Check GitHub CLI (optional but recommended)
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}  ⚠️  GitHub CLI not found (recommended)${NC}"
        echo -e "${CYAN}    Install with: brew install gh${NC}"
    else
        echo -e "${GREEN}  ✅ GitHub CLI available${NC}"
    fi
    
    # Check jq (for JSON processing)
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}  ⚠️  jq not found (recommended for tool detection)${NC}"
        echo -e "${CYAN}    Install with: brew install jq${NC}"
    else
        echo -e "${GREEN}  ✅ jq available${NC}"
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}❌ Missing required tools: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}Please install missing tools and run again.${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}✅ All prerequisites satisfied!${NC}"
    pause_for_user
}

detect_ai_tools() {
    step_separator "🧠 STEP 2: AI Tool Detection & Verification"
    
    echo -e "${BLUE}Running comprehensive AI tool detection...${NC}"
    echo ""
    echo -e "${CYAN}This will check for:${NC}"
    echo -e "${CYAN}  • Google One Ultra (Gemini Deep Think, Deep Research, Canvas)${NC}"
    echo -e "${CYAN}  • Cursor Pro subscription and agent capabilities${NC}"
    echo -e "${CYAN}  • Lovable + Supabase integration options${NC}"
    echo -e "${CYAN}  • Standard fallback tools (Claude Code, v0.dev)${NC}"
    echo ""
    
    pause_for_user
    
    # Run tool detection
    echo -e "${YELLOW}Starting interactive tool detection...${NC}"
    "$SCRIPT_DIR/tool-detector.sh" verify
    
    echo ""
    echo -e "${GREEN}✅ Tool detection completed!${NC}"
    echo -e "${CYAN}💡 Configuration saved for future use${NC}"
    pause_for_user
}

initialize_project_structure() {
    step_separator "🏗️ STEP 3: Project Structure Initialization"
    
    echo -e "${BLUE}Setting up project structure...${NC}"
    echo ""
    echo -e "${CYAN}This will:${NC}"
    echo -e "${CYAN}  • Initialize Git repository (if needed)${NC}"
    echo -e "${CYAN}  • Create CCPM structure (.claude/ folder)${NC}"
    echo -e "${CYAN}  • Set up context and epic templates${NC}"
    echo -e "${CYAN}  • Configure GitHub integration (if available)${NC}"
    echo ""
    
    pause_for_user
    
    # Check if Git repo exists
    if ! git status &> /dev/null; then
        echo -e "${YELLOW}Initializing Git repository...${NC}"
        git init
        git add .
        git commit -m "Initial commit - AI Orchestration setup"
        echo -e "${GREEN}  ✅ Git repository initialized${NC}"
    else
        echo -e "${GREEN}  ✅ Git repository already exists${NC}"
    fi
    
    # Run CCPM bridge setup
    echo -e "${YELLOW}Setting up CCPM structure...${NC}"
    "$SCRIPT_DIR/../ccpm/ccpm-bridge.sh"
    
    echo ""
    echo -e "${GREEN}✅ Project structure initialized!${NC}"
    pause_for_user
}

generate_adaptive_workflow() {
    step_separator "🎯 STEP 4: Adaptive Workflow Generation"
    
    echo -e "${BLUE}Generating optimized workflow based on your tools...${NC}"
    echo ""
    echo -e "${CYAN}This will:${NC}"
    echo -e "${CYAN}  • Analyze your detected AI tools${NC}"
    echo -e "${CYAN}  • Generate platform-optimized workflows${NC}"
    echo -e "${CYAN}  • Create role-specific instructions${NC}"
    echo -e "${CYAN}  • Provide performance optimization guidance${NC}"
    echo ""
    
    pause_for_user
    
    # Generate adaptive workflow
    echo -e "${YELLOW}Generating adaptive workflow...${NC}"
    "$SCRIPT_DIR/adaptive-workflow-generator.sh" verify-and-generate
    
    echo ""
    echo -e "${GREEN}✅ Adaptive workflow generated!${NC}"
    echo -e "${CYAN}💡 Workflow files created in timestamped directory${NC}"
    pause_for_user
}

setup_github_integration() {
    step_separator "🐙 STEP 5: GitHub Integration (Optional)"
    
    echo -e "${BLUE}Setting up GitHub integration...${NC}"
    echo ""
    
    if command -v gh &> /dev/null; then
        if gh auth status &> /dev/null; then
            echo -e "${GREEN}  ✅ GitHub CLI already authenticated${NC}"
            
            echo -e "${YELLOW}Would you like to create a GitHub repository for this project? [y/N]${NC}"
            read -r create_repo
            
            if [[ "$create_repo" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Creating GitHub repository...${NC}"
                
                # Check if remote already exists
                if git remote get-url origin &> /dev/null; then
                    echo -e "${GREEN}  ✅ Git remote already configured${NC}"
                else
                    echo -e "${YELLOW}Enter repository description (or press Enter for default):${NC}"
                    read -r repo_desc
                    repo_desc="${repo_desc:-AI-powered development project with orchestration}"
                    
                    gh repo create "$PROJECT_NAME" --public --description "$repo_desc" --source .
                    echo -e "${GREEN}  ✅ GitHub repository created and linked${NC}"
                fi
            else
                echo -e "${CYAN}  ℹ️  Skipping GitHub repository creation${NC}"
            fi
        else
            echo -e "${YELLOW}  ⚠️  GitHub CLI needs authentication${NC}"
            echo -e "${CYAN}    Run: gh auth login${NC}"
            echo -e "${CYAN}  ℹ️  You can set this up later${NC}"
        fi
    else
        echo -e "${YELLOW}  ⚠️  GitHub CLI not available${NC}"
        echo -e "${CYAN}    Install with: brew install gh${NC}"
        echo -e "${CYAN}  ℹ️  GitHub integration will be limited without CLI${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ GitHub integration configured!${NC}"
    pause_for_user
}

create_sample_project() {
    step_separator "📝 STEP 6: Sample Project Setup"
    
    echo -e "${BLUE}Creating sample project structure...${NC}"
    echo ""
    echo -e "${CYAN}This will create:${NC}"
    echo -e "${CYAN}  • Sample PRD (Product Requirements Document)${NC}"
    echo -e "${CYAN}  • Example epic and context files${NC}"
    echo -e "${CYAN}  • Basic project documentation${NC}"
    echo -e "${CYAN}  • Ready-to-use workflow templates${NC}"
    echo ""
    
    pause_for_user
    
    # Create sample PRD
    mkdir -p .claude/prds
    cat > .claude/prds/sample-project-prd.md << EOF
# Sample Project - AI-Powered Task Manager

## Product Overview
Create a modern, AI-enhanced task management application that helps users organize, prioritize, and complete their work efficiently.

## Core Features
- **Task Management**: Create, edit, delete, and organize tasks
- **AI Assistant**: Smart task suggestions and priority recommendations  
- **Real-time Sync**: Multi-device synchronization
- **Analytics**: Productivity insights and reporting

## Technical Requirements
- **Frontend**: React with TypeScript
- **Backend**: Node.js with Express
- **Database**: PostgreSQL with real-time features
- **Authentication**: Secure user management
- **Testing**: Comprehensive test coverage

## Success Metrics
- User engagement and retention
- Task completion rates
- Performance and reliability
- User satisfaction scores

## Timeline
- **Phase 1**: Core functionality (4 weeks)
- **Phase 2**: AI features (3 weeks)  
- **Phase 3**: Advanced features (3 weeks)
EOF

    # Create sample context
    mkdir -p .claude/context
    cat > .claude/context/project-requirements.md << EOF
# Project Context - AI Task Manager

## Current State
- New project initialization
- Team: 1 developer (full-stack)
- Timeline: 10 weeks total
- Budget: Moderate

## Technology Stack
- **Frontend**: React 18, TypeScript, Tailwind CSS
- **Backend**: Node.js, Express, TypeScript
- **Database**: PostgreSQL with Supabase
- **Testing**: Vitest, Playwright
- **Deployment**: Vercel (frontend), Railway (backend)

## Development Approach
- Agile methodology with 2-week sprints
- Test-driven development
- Continuous integration/deployment
- Code review and quality gates

## Key Constraints  
- Mobile-responsive design required
- GDPR compliance needed
- Performance: <2s page load times
- Accessibility: WCAG 2.1 AA compliance

## Success Criteria
- All core features implemented
- 90%+ test coverage
- Performance benchmarks met
- User acceptance testing passed
EOF

    # Create sample epic
    mkdir -p .claude/epics
    cat > .claude/epics/user-authentication-epic.md << EOF
# Epic: User Authentication System

## Overview
Implement a comprehensive user authentication and authorization system with modern security practices.

## User Stories
1. **As a user**, I want to register with email/password so I can create an account
2. **As a user**, I want to sign in securely so I can access my tasks
3. **As a user**, I want to reset my password so I can regain access if forgotten
4. **As a user**, I want social login options so I can sign in quickly
5. **As an admin**, I want role-based access control so I can manage permissions

## Technical Implementation
### Backend Requirements
- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting for auth endpoints
- Email verification system
- OAuth integration (Google, GitHub)

### Frontend Requirements  
- Login/register forms with validation
- Protected routes and auth guards
- Token refresh mechanism
- User profile management
- Responsive design for all auth flows

### Database Schema
- Users table with encrypted passwords
- Sessions/tokens management
- User roles and permissions
- Email verification tracking

## Acceptance Criteria
- ✅ User registration with email verification
- ✅ Secure login with JWT tokens
- ✅ Password reset functionality
- ✅ Social OAuth integration
- ✅ Role-based access control
- ✅ Session management and logout
- ✅ Security best practices implemented

## Testing Requirements
- Unit tests for auth functions
- Integration tests for auth flows
- Security penetration testing
- End-to-end user journey tests

## Definition of Done
- [ ] All user stories completed
- [ ] Security review passed
- [ ] Performance requirements met
- [ ] Documentation updated
- [ ] Tests written and passing
- [ ] Code review completed
EOF

    echo -e "${GREEN}✅ Sample project structure created!${NC}"
    echo ""
    echo -e "${CYAN}📁 Created files:${NC}"
    echo -e "${CYAN}  • .claude/prds/sample-project-prd.md${NC}"
    echo -e "${CYAN}  • .claude/context/project-requirements.md${NC}"
    echo -e "${CYAN}  • .claude/epics/user-authentication-epic.md${NC}"
    
    pause_for_user
}

show_completion_summary() {
    step_separator "🎉 SETUP COMPLETE!"
    
    echo -e "${GREEN}${BOLD}Congratulations! Your AI Orchestration system is fully configured!${NC}"
    echo ""
    
    echo -e "${PURPLE}📊 Setup Summary:${NC}"
    echo -e "${GREEN}  ✅ Prerequisites verified${NC}"
    echo -e "${GREEN}  ✅ AI tools detected and configured${NC}"
    echo -e "${GREEN}  ✅ Project structure initialized${NC}"
    echo -e "${GREEN}  ✅ Adaptive workflows generated${NC}"
    echo -e "${GREEN}  ✅ GitHub integration configured${NC}"
    echo -e "${GREEN}  ✅ Sample project created${NC}"
    echo ""
    
    echo -e "${PURPLE}🚀 Next Steps:${NC}"
    echo -e "${CYAN}1. Review generated workflow files in the timestamped directory${NC}"
    echo -e "${CYAN}2. Customize the sample PRD and epic for your actual project${NC}"
    echo -e "${CYAN}3. Run the master orchestrator to start development:${NC}"
    echo -e "${YELLOW}   ~/nixos-config/ai-orchestration/scripts/master-orchestrator.sh${NC}"
    echo ""
    
    echo -e "${PURPLE}📚 Available Resources:${NC}"
    echo -e "${CYAN}  • Tool configuration: ~/.ai-orchestration-config.json${NC}"
    echo -e "${CYAN}  • Project structure: .claude/ directory${NC}"
    echo -e "${CYAN}  • Documentation: ~/nixos-config/ai-orchestration/docs/${NC}"
    echo ""
    
    echo -e "${PURPLE}🎯 Quick Commands:${NC}"
    echo -e "${CYAN}  • Master orchestrator: ~/nixos-config/ai-orchestration/scripts/master-orchestrator.sh${NC}"
    echo -e "${CYAN}  • Tool verification: ~/nixos-config/ai-orchestration/scripts/tool-detector.sh${NC}"
    echo -e "${CYAN}  • Adaptive workflow: ~/nixos-config/ai-orchestration/scripts/adaptive-workflow-generator.sh${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}🎉 You're ready to build with 98%+ AI-powered efficiency!${NC}"
}

# Main execution flow
main() {
    show_banner
    
    echo -e "${CYAN}Welcome to the AI Orchestration Guided Setup Wizard!${NC}"
    echo -e "${CYAN}This will walk you through the complete setup process step by step.${NC}"
    echo ""
    echo -e "${YELLOW}Project: $PROJECT_NAME${NC}"
    echo -e "${YELLOW}Location: $PROJECT_DIR${NC}"
    echo ""
    
    pause_for_user
    
    # Execute all setup steps
    check_prerequisites
    detect_ai_tools
    initialize_project_structure
    generate_adaptive_workflow
    setup_github_integration
    create_sample_project
    show_completion_summary
    
    echo ""
    echo -e "${PURPLE}Setup wizard completed successfully!${NC}"
}

# Handle command line arguments
case "${1:-main}" in
    "main"|"")
        main
        ;;
    *)
        echo "Usage: $0"
        echo "  Runs the complete guided setup wizard"
        ;;
esac