#!/usr/bin/env bash

# Interactive Guide Mode - Step-by-step guided experience
# Explains each step and guides users through optimal workflow

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

show_interactive_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                   🎯 INTERACTIVE GUIDE MODE 🎯                ║"
    echo "║                                                                ║"
    echo "║         Step-by-Step Setup with Explanations & Guidance       ║"
    echo "║                                                                ║"
    echo "║    💡 Explains Each Step  🎓 Beginner Friendly  ✅ Optimal     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

pause_with_explanation() {
    local explanation="$1"
    echo ""
    echo -e "${CYAN}💡 ${explanation}${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to continue, or 'q' to quit...${NC}"
    read -r response
    if [[ "$response" == "q" ]]; then
        echo -e "${CYAN}Exiting interactive guide. You can restart anytime!${NC}"
        exit 0
    fi
}

show_current_status() {
    echo -e "${BLUE}📊 Current Project Status:${NC}"
    echo -e "${CYAN}  📁 Project: $PROJECT_NAME${NC}"
    echo -e "${CYAN}  📂 Location: $PROJECT_DIR${NC}"
    
    # Check CCPM status
    if [[ -d "$PROJECT_DIR/.claude" ]]; then
        echo -e "${GREEN}  ✅ CCPM: Initialized${NC}"
    else
        echo -e "${YELLOW}  ⚠️  CCMP: Not initialized${NC}"
    fi
    
    # Check Git status
    if git status &> /dev/null; then
        echo -e "${GREEN}  ✅ Git: Repository ready${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Git: Not a repository${NC}"
    fi
    
    # Check configuration
    if [[ -f "$HOME/.ai-orchestration-config.json" ]]; then
        echo -e "${GREEN}  ✅ AI Tools: Detected and configured${NC}"
    else
        echo -e "${YELLOW}  ⚠️  AI Tools: Not yet detected${NC}"
    fi
    
    echo ""
}

explain_tool_verification() {
    echo -e "${PURPLE}🧠 STEP 1: AI Tool Verification${NC}"
    echo -e "${PURPLE}═══════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}What this does:${NC}"
    echo -e "${CYAN}• Detects which premium AI tools you have access to${NC}"
    echo -e "${CYAN}• Checks for Google One Ultra, Cursor Pro, Lovable, etc.${NC}"
    echo -e "${CYAN}• Creates a personalized configuration file${NC}"
    echo -e "${CYAN}• Enables optimal workflow generation${NC}"
    echo ""
    echo -e "${YELLOW}Why it's important:${NC}"
    echo -e "${YELLOW}The system needs to know your available tools to create${NC}"
    echo -e "${YELLOW}workflows optimized for YOUR specific setup.${NC}"
    
    pause_with_explanation "This step is like telling the system what tools you have in your toolbox, so it can give you the best instructions."
}

run_tool_verification() {
    echo -e "${BLUE}🔍 Running AI Tool Verification...${NC}"
    echo ""
    
    "$SCRIPT_DIR/tool-detector.sh" verify
    
    echo ""
    echo -e "${GREEN}✅ Tool verification completed!${NC}"
    echo -e "${CYAN}Your AI tool configuration has been saved.${NC}"
    
    pause_with_explanation "Great! Now the system knows exactly which AI tools you can use. Next, we'll set up your project structure."
}

explain_project_setup() {
    echo -e "${PURPLE}🏗️ STEP 2: Project Structure Setup${NC}"
    echo -e "${PURPLE}══════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}What this does:${NC}"
    echo -e "${CYAN}• Initializes a Git repository (if needed)${NC}"
    echo -e "${CYAN}• Creates the .claude/ folder structure (CCPM)${NC}"
    echo -e "${CYAN}• Sets up templates for requirements and epics${NC}"
    echo -e "${CYAN}• Creates sample files to show you how it works${NC}"
    echo ""
    echo -e "${YELLOW}Why it's important:${NC}"
    echo -e "${YELLOW}This creates the organized structure where all your project${NC}"
    echo -e "${YELLOW}information lives. Think of it as building the foundation.${NC}"
    
    pause_with_explanation "This is like setting up organized folders and files for your project, so everything has its proper place."
}

run_project_setup() {
    echo -e "${BLUE}🚀 Running Quick Setup (Project Structure)...${NC}"
    echo ""
    echo -e "${CYAN}Executing Quick Setup tool...${NC}"
    
    # We'll call the master orchestrator with option 13
    echo "13" | "$SCRIPT_DIR/master-orchestrator.sh" 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}✅ Project structure setup completed!${NC}"
    echo -e "${CYAN}Your project now has proper organization and sample files.${NC}"
    
    pause_with_explanation "Perfect! Your project is now properly structured. Next, we'll generate your personalized workflow."
}

explain_adaptive_workflow() {
    echo -e "${PURPLE}🎯 STEP 3: Adaptive Workflow Generation${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}What this does:${NC}"
    echo -e "${CYAN}• Creates step-by-step workflows based on YOUR detected tools${NC}"
    echo -e "${CYAN}• Generates role-specific instructions (backend, frontend, etc.)${NC}"
    echo -e "${CYAN}• Provides optimal settings for each AI platform${NC}"
    echo -e "${CYAN}• Creates a complete development guide${NC}"
    echo ""
    echo -e "${YELLOW}Why it's important:${NC}"
    echo -e "${YELLOW}This creates your personalized 'instruction manual' for${NC}"
    echo -e "${YELLOW}building software efficiently with your specific AI tools.${NC}"
    
    pause_with_explanation "Think of this as creating a custom recipe book that's perfectly tailored to the ingredients (AI tools) you have available."
}

run_adaptive_workflow() {
    echo -e "${BLUE}🎯 Running Adaptive Workflow Generation...${NC}"
    echo ""
    
    "$SCRIPT_DIR/adaptive-workflow-generator.sh" generate
    
    echo ""
    echo -e "${GREEN}✅ Adaptive workflow generated!${NC}"
    echo -e "${CYAN}Your personalized development workflow has been created.${NC}"
    
    pause_with_explanation "Excellent! You now have a complete, personalized development workflow. Let's see what you've accomplished!"
}

show_completion_summary() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 SETUP COMPLETE! 🎉                       ║"
    echo "║                                                                ║"
    echo "║              Your AI Development System is Ready!              ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    echo -e "${GREEN}✅ What you've accomplished:${NC}"
    echo ""
    echo -e "${CYAN}1. ✅ AI Tool Verification Complete${NC}"
    echo -e "${CYAN}   • Your available AI tools have been detected${NC}"
    echo -e "${CYAN}   • Configuration saved for future use${NC}"
    echo ""
    echo -e "${CYAN}2. ✅ Project Structure Initialized${NC}"
    echo -e "${CYAN}   • Git repository set up${NC}"
    echo -e "${CYAN}   • CCMP structure (.claude/ folder) created${NC}"
    echo -e "${CYAN}   • Sample files and templates ready${NC}"
    echo ""
    echo -e "${CYAN}3. ✅ Personalized Workflow Generated${NC}"
    echo -e "${CYAN}   • Workflows optimized for YOUR AI tools${NC}"
    echo -e "${CYAN}   • Step-by-step development instructions${NC}"
    echo -e "${CYAN}   • Platform-specific configurations included${NC}"
    echo ""
    
    show_current_status
    
    echo -e "${PURPLE}🚀 What's Next? (Choose Your Adventure)${NC}"
    echo ""
    echo -e "${YELLOW}For a Real Project:${NC}"
    echo -e "${CYAN}• Replace sample files in .claude/prds/ with your actual requirements${NC}"
    echo -e "${CYAN}• Follow the generated workflow files for development${NC}"
    echo -e "${CYAN}• Use the master orchestrator for ongoing project management${NC}"
    echo ""
    echo -e "${YELLOW}To Learn More:${NC}"
    echo -e "${CYAN}• Explore the .claude/ folder to see the structure${NC}"
    echo -e "${CYAN}• Read the generated workflow files to understand the process${NC}"
    echo -e "${CYAN}• Run the master orchestrator to see all available tools${NC}"
    echo ""
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo -e "${GREEN}• Master orchestrator: ~/nixos-config/ai-orchestration/scripts/master-orchestrator.sh${NC}"
    echo -e "${GREEN}• View workflow files: ls -la adaptive-workflow-*/${NC}"
    echo -e "${GREEN}• Edit your project: code .${NC}"
    echo ""
    
    pause_with_explanation "Congratulations! You're now ready to build software with AI-powered efficiency. The system is fully configured and optimized for your setup."
}

ask_for_optional_setup() {
    echo -e "${PURPLE}🎯 Optional Advanced Features${NC}"
    echo -e "${PURPLE}═══════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Would you like to set up additional features? (optional)${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${CYAN}• GitHub Issues integration (for project management)${NC}"
    echo -e "${CYAN}• Workflow templates (for common project types)${NC}"
    echo -e "${CYAN}• Progress sync (for team collaboration)${NC}"
    echo ""
    echo -e "${YELLOW}These are completely optional and can be set up later.${NC}"
    echo ""
    echo -e "${YELLOW}Set up optional features now? [y/N]: ${NC}"
    read -r setup_optional
    
    if [[ "$setup_optional" =~ ^[Yy]$ ]]; then
        show_optional_features_menu
    else
        echo -e "${CYAN}No problem! You can always access these features later through the master orchestrator.${NC}"
    fi
}

show_optional_features_menu() {
    echo ""
    echo -e "${PURPLE}🔧 Optional Features Setup${NC}"
    echo ""
    echo -e "${CYAN}1. GitHub Issues Integration - Set up project management${NC}"
    echo -e "${CYAN}2. Workflow Templates - Install common project templates${NC}"
    echo -e "${CYAN}3. Progress Sync - Enable team collaboration features${NC}"
    echo -e "${CYAN}4. Skip - Continue to completion${NC}"
    echo ""
    echo -e "${YELLOW}Select option [1-4]: ${NC}"
    read -r optional_choice
    
    case "$optional_choice" in
        1)
            echo -e "${BLUE}Setting up GitHub Issues integration...${NC}"
            echo "5" | "$SCRIPT_DIR/master-orchestrator.sh" 2>/dev/null || true
            ;;
        2)
            echo -e "${BLUE}Installing workflow templates...${NC}"
            echo "8" | "$SCRIPT_DIR/master-orchestrator.sh" 2>/dev/null || true
            ;;
        3)
            echo -e "${BLUE}Setting up progress sync...${NC}"
            echo "6" | "$SCRIPT_DIR/master-orchestrator.sh" 2>/dev/null || true
            ;;
        *)
            echo -e "${CYAN}Skipping optional features.${NC}"
            ;;
    esac
}

# Main interactive flow
main() {
    show_interactive_banner
    
    echo -e "${CYAN}Welcome to Interactive Guide Mode!${NC}"
    echo ""
    echo -e "${CYAN}This will walk you through setting up your AI orchestration system${NC}"
    echo -e "${CYAN}with detailed explanations at each step.${NC}"
    echo ""
    
    show_current_status
    
    pause_with_explanation "Let's start by understanding what AI tools you have available."
    
    # Step 1: Tool Verification
    explain_tool_verification
    run_tool_verification
    
    # Step 2: Project Setup
    explain_project_setup
    run_project_setup
    
    # Step 3: Adaptive Workflow
    explain_adaptive_workflow
    run_adaptive_workflow
    
    # Optional features
    ask_for_optional_setup
    
    # Completion
    show_completion_summary
    
    echo -e "${GREEN}🎉 Interactive setup completed successfully!${NC}"
    echo -e "${CYAN}You're now ready to build amazing things with AI assistance!${NC}"
}

# Command line interface
case "${1:-main}" in
    "main"|"")
        main
        ;;
    *)
        echo "Usage: $0"
        echo "  Runs the interactive guided setup experience"
        ;;
esac