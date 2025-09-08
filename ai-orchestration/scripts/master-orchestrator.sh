#!/usr/bin/env bash

# Master AI Orchestration Control System
# Unified interface for all CCPM-Enhanced AI Orchestration tools
# Phase 3: Advanced Integration Complete

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

# Script version and metadata
SCRIPT_VERSION="3.1.0"
SCRIPT_NAME="Master AI Orchestration Control"

# Configuration
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
AI_ORCHESTRATION_ROOT="$(dirname "$SCRIPT_DIR")"

# Display banner
show_banner() {
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 AI ORCHESTRATION MASTER 🚀               ║"
    echo "║                                                                ║"
    echo "║     CCPM-Enhanced Universal AI Orchestration System v3.1      ║"
    echo "║                                                                ║"
    echo "║  📊 90%+ Performance  🏗️  Structured Management  🤖 AI Agents  ║"
    echo "║  🐙 GitHub Issues    📋 Epic Tracking       🔄 Real-time Sync  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Function to show available tools
show_tools_menu() {
    echo -e "${BLUE}🛠️  Available Tools & Workflows:${NC}"
    echo ""
    
    echo -e "${PURPLE}【 Project Discovery 】${NC}"
    echo -e "${GREEN}  0. 🎯 Project Inception Wizard${NC} - AI-powered project discovery & specification"
    echo ""
    
    echo -e "${PURPLE}【 Core Orchestration 】${NC}"
    echo -e "${GREEN}  1. Hybrid Orchestration${NC}     - Full CCPM + GitHub + AI coordination"
    echo -e "${GREEN}  2. Bridge Setup${NC}             - Initialize CCPM structure and workflows"
    echo -e "${GREEN}  3. Original Orchestration${NC}   - Pure dynamic AI orchestration"
    echo ""
    
    echo -e "${PURPLE}【 Project Management 】${NC}"
    echo -e "${GREEN}  4. PRD to Epic Converter${NC}    - Transform requirements to technical specs"
    echo -e "${GREEN}  5. GitHub Issues Creator${NC}    - Generate Issues from epics with AI mapping"
    echo -e "${GREEN}  6. Progress Sync${NC}            - Real-time progress synchronization"
    echo ""
    
    echo -e "${PURPLE}【 Context & Templates 】${NC}"
    echo -e "${GREEN}  7. Context Manager${NC}          - Enhanced inter-agent communication"
    echo -e "${GREEN}  8. Workflow Templates${NC}       - Reusable patterns for common scenarios"
    echo -e "${GREEN}  9. System Status${NC}            - Complete system health and status"
    echo ""
    
    echo -e "${PURPLE}【 Adaptive Intelligence 】${NC}"
    echo -e "${GREEN} 10. Tool Verification${NC}        - Detect and verify available AI tools"
    echo -e "${GREEN} 11. Adaptive Workflow${NC}        - Generate optimized workflow for your setup"
    echo -e "${GREEN} 12. Platform Optimizer${NC}       - Premium platform optimization (Google One Ultra, Cursor Pro, Lovable)"
    echo ""
    
    echo -e "${PURPLE}【 Quick Actions 】${NC}"
    echo -e "${GREEN} 13. Quick Setup${NC}              - Initialize new project with full system"
    echo -e "${GREEN} 14. Project Dashboard${NC}        - Visual project progress and metrics"
    echo -e "${GREEN} 15. System Documentation${NC}     - Access all guides and documentation"
    echo ""
}

# Function to detect and display project context
show_project_context() {
    echo -e "${CYAN}📍 Project Context:${NC}"
    echo -e "${GREEN}   📁 Project: $PROJECT_NAME${NC}"
    echo -e "${GREEN}   📂 Path: $PROJECT_DIR${NC}"
    
    # Check CCPM structure
    if [[ -d "$PROJECT_DIR/.claude" ]]; then
        local epics=$(find "$PROJECT_DIR/.claude/epics" -name "*.md" 2>/dev/null | wc -l)
        local contexts=$(find "$PROJECT_DIR/.claude/context" -name "*.md" 2>/dev/null | wc -l)
        echo -e "${GREEN}   📋 CCPM: $epics epics, $contexts context files${NC}"
    else
        echo -e "${YELLOW}   ⚠️  CCPM: Not initialized${NC}"
    fi
    
    # Check GitHub repo
    if git status &> /dev/null; then
        local repo_url=$(git remote get-url origin 2>/dev/null || echo "Local repository")
        echo -e "${GREEN}   🐙 Git: Connected$(if [[ "$repo_url" != "Local repository" ]]; then echo " ($(basename "$repo_url" .git))"; fi)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Git: Not a repository${NC}"
    fi
    
    echo ""
}

# Function to run selected tool
run_tool() {
    local choice="$1"
    
    case "$choice" in
        0)
            echo -e "${BLUE}🎯 Starting Project Inception Wizard...${NC}"
            echo -e "${CYAN}This will help you discover and define your project with AI-powered analysis.${NC}"
            echo ""
            "$SCRIPT_DIR/project-inception-wizard.sh"
            ;;
        1)
            echo -e "${BLUE}🚀 Starting Hybrid Orchestration...${NC}"
            "$SCRIPT_DIR/ccpm-enhanced-universal.sh"
            ;;
        2)
            echo -e "${BLUE}🌉 Running CCPM Bridge Setup...${NC}"
            "$AI_ORCHESTRATION_ROOT/ccpm/ccpm-bridge.sh"
            ;;
        3)
            echo -e "${BLUE}🤖 Starting Original AI Orchestration...${NC}"
            "$SCRIPT_DIR/ai-orchestration-universal.sh"
            ;;
        4)
            echo -e "${BLUE}🔄 Starting PRD to Epic Conversion...${NC}"
            "$SCRIPT_DIR/prd-to-epic-converter.sh"
            ;;
        5)
            echo -e "${BLUE}🐙 Starting GitHub Issues Creator...${NC}"
            echo -e "${YELLOW}Enter epic name (or press Enter to list epics):${NC}"
            read -r epic_name
            
            if [[ -z "$epic_name" ]]; then
                # Show available epics
                if [[ -d "$PROJECT_DIR/.claude/epics" ]]; then
                    echo -e "${CYAN}Available epics:${NC}"
                    find "$PROJECT_DIR/.claude/epics" -name "*-epic.md" | while read -r epic_file; do
                        local name=$(basename "$epic_file" -epic.md)
                        echo -e "${GREEN}  • $name${NC}"
                    done
                    echo ""
                    echo -e "${YELLOW}Enter epic name:${NC}"
                    read -r epic_name
                fi
            fi
            
            if [[ -n "$epic_name" ]]; then
                "$SCRIPT_DIR/github-issues-creator.sh" "$epic_name"
            fi
            ;;
        6)
            echo -e "${BLUE}🔄 Starting Progress Synchronization...${NC}"
            echo -e "${YELLOW}Select mode: [1] Watch (continuous) [2] Sync once [3] Status only${NC}"
            read -p "Mode [1-3]: " sync_mode
            
            case "$sync_mode" in
                1) "$SCRIPT_DIR/progress-sync.sh" watch ;;
                2) "$SCRIPT_DIR/progress-sync.sh" sync-once ;;
                3) "$SCRIPT_DIR/progress-sync.sh" status ;;
                *) "$SCRIPT_DIR/progress-sync.sh" status ;;
            esac
            ;;
        7)
            echo -e "${BLUE}🧠 Starting Context Manager...${NC}"
            echo -e "${YELLOW}Select action: [1] Status [2] Initialize [3] Validate [4] Cleanup${NC}"
            read -p "Action [1-4]: " context_action
            
            case "$context_action" in
                1) "$SCRIPT_DIR/context-manager.sh" status ;;
                2) "$SCRIPT_DIR/context-manager.sh" init ;;
                3) "$SCRIPT_DIR/context-manager.sh" validate ;;
                4) "$SCRIPT_DIR/context-manager.sh" cleanup ;;
                *) "$SCRIPT_DIR/context-manager.sh" status ;;
            esac
            ;;
        8)
            echo -e "${BLUE}🎭 Starting Workflow Templates...${NC}"
            echo -e "${YELLOW}Select action: [1] List templates [2] Create from template [3] Initialize templates${NC}"
            read -p "Action [1-3]: " template_action
            
            case "$template_action" in
                1) "$SCRIPT_DIR/workflow-templates.sh" list ;;
                2) 
                    "$SCRIPT_DIR/workflow-templates.sh" list
                    echo ""
                    echo -e "${YELLOW}Enter template name:${NC}"
                    read -r template_name
                    echo -e "${YELLOW}Enter instance name:${NC}"
                    read -r instance_name
                    
                    if [[ -n "$template_name" ]] && [[ -n "$instance_name" ]]; then
                        "$SCRIPT_DIR/workflow-templates.sh" create "$template_name" "$instance_name"
                    fi
                    ;;
                3) "$SCRIPT_DIR/workflow-templates.sh" init ;;
                *) "$SCRIPT_DIR/workflow-templates.sh" list ;;
            esac
            ;;
        9)
            echo -e "${BLUE}📊 System Status Report${NC}"
            echo ""
            show_system_status
            ;;
        10)
            echo -e "${BLUE}🔍 Starting Tool Verification...${NC}"
            echo -e "${YELLOW}Select action: [1] Full Verification [2] Show Status [3] Update Configuration${NC}"
            read -p "Action [1-3]: " verify_action
            
            case "$verify_action" in
                1) "$SCRIPT_DIR/tool-detector.sh" verify ;;
                2) "$SCRIPT_DIR/tool-detector.sh" status ;;
                3) "$SCRIPT_DIR/tool-detector.sh" verify ;;
                *) "$SCRIPT_DIR/tool-detector.sh" status ;;
            esac
            ;;
        11)
            echo -e "${BLUE}🎯 Starting Adaptive Workflow Generation...${NC}"
            echo -e "${YELLOW}Select mode: [1] Generate with Current Config [2] Verify Tools & Generate [3] Show Current Config${NC}"
            read -p "Mode [1-3]: " adaptive_mode
            
            case "$adaptive_mode" in
                1) "$SCRIPT_DIR/adaptive-workflow-generator.sh" generate ;;
                2) "$SCRIPT_DIR/adaptive-workflow-generator.sh" verify-and-generate ;;
                3) "$SCRIPT_DIR/adaptive-workflow-generator.sh" status ;;
                *) "$SCRIPT_DIR/adaptive-workflow-generator.sh" generate ;;
            esac
            ;;
        12)
            echo -e "${BLUE}⚡ Starting Platform Optimizer...${NC}"
            echo -e "${YELLOW}Select optimization mode: [1] Generate Optimized Workflow [2] Platform Analysis [3] Full Optimization Report${NC}"
            read -p "Mode [1-3]: " opt_mode
            
            case "$opt_mode" in
                1) "$SCRIPT_DIR/platform-optimizer.sh" generate-workflow ;;
                2) "$SCRIPT_DIR/platform-optimizer.sh" analyze ;;
                3) "$SCRIPT_DIR/platform-optimizer.sh" full-report ;;
                *) "$SCRIPT_DIR/platform-optimizer.sh" analyze ;;
            esac
            ;;
        13)
            echo -e "${BLUE}🚀 Quick Project Setup${NC}"
            quick_project_setup
            ;;
        14)
            echo -e "${BLUE}📊 Project Dashboard${NC}"
            show_project_dashboard
            ;;
        15)
            echo -e "${BLUE}📚 System Documentation${NC}"
            show_documentation_menu
            ;;
        *)
            echo -e "${RED}❌ Invalid choice: $choice${NC}"
            return 1
            ;;
    esac
}

# Function to show system status
show_system_status() {
    echo -e "${PURPLE}🔧 System Component Status:${NC}"
    echo ""
    
    # Check script availability
    local scripts=(
        "ccpm-enhanced-universal.sh:Hybrid Orchestration"
        "ai-orchestration-universal.sh:Original Orchestration"
        "prd-to-epic-converter.sh:PRD Converter"
        "github-issues-creator.sh:GitHub Issues Creator"
        "progress-sync.sh:Progress Sync"
        "context-manager.sh:Context Manager"
        "workflow-templates.sh:Workflow Templates"
        "tool-detector.sh:Tool Verification"
        "adaptive-workflow-generator.sh:Adaptive Workflow Generator"
        "platform-optimizer.sh:Platform Optimizer"
    )
    
    echo -e "${CYAN}📁 Core Scripts:${NC}"
    for script_info in "${scripts[@]}"; do
        IFS=':' read -ra parts <<< "$script_info"
        local script_file="$SCRIPT_DIR/${parts[0]}"
        local script_name="${parts[1]}"
        
        if [[ -f "$script_file" ]] && [[ -x "$script_file" ]]; then
            echo -e "${GREEN}   ✅ $script_name${NC}"
        else
            echo -e "${RED}   ❌ $script_name (missing or not executable)${NC}"
        fi
    done
    
    echo ""
    
    # Check external dependencies
    echo -e "${CYAN}🔗 External Dependencies:${NC}"
    local deps=("git:Git" "gh:GitHub CLI" "jq:JSON Processor" "tree:Tree View")
    
    for dep_info in "${deps[@]}"; do
        IFS=':' read -ra parts <<< "$dep_info"
        local cmd="${parts[0]}"
        local name="${parts[1]}"
        
        if command -v "$cmd" &> /dev/null; then
            echo -e "${GREEN}   ✅ $name${NC}"
        else
            echo -e "${YELLOW}   ⚠️  $name (optional)${NC}"
        fi
    done
    
    echo ""
    
    # Project-specific status
    if [[ -d "$PROJECT_DIR/.claude" ]]; then
        echo -e "${CYAN}📋 CCPM Status:${NC}"
        "$SCRIPT_DIR/context-manager.sh" status | tail -n +4
    fi
    
    # GitHub status
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        echo -e "${CYAN}🐙 GitHub Integration:${NC}"
        echo -e "${GREEN}   ✅ GitHub CLI authenticated${NC}"
        
        if git status &> /dev/null && git remote get-url origin &> /dev/null; then
            echo -e "${GREEN}   ✅ Repository connected${NC}"
        else
            echo -e "${YELLOW}   ⚠️  No remote repository${NC}"
        fi
    else
        echo -e "${CYAN}🐙 GitHub Integration:${NC}"
        echo -e "${YELLOW}   ⚠️  GitHub CLI not authenticated${NC}"
    fi
    
    echo ""
}

# Function for quick project setup
quick_project_setup() {
    echo -e "${BLUE}🚀 Quick Project Setup${NC}"
    echo ""
    
    echo -e "${YELLOW}This will initialize the complete CCPM-Enhanced AI Orchestration system.${NC}"
    echo -e "${YELLOW}Continue? (y/N):${NC}"
    read -r confirm
    
    if [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]]; then
        echo -e "${YELLOW}Setup cancelled${NC}"
        return 0
    fi
    
    echo ""
    echo -e "${BLUE}Step 1: Initializing CCPM structure...${NC}"
    "$SCRIPT_DIR/context-manager.sh" init
    
    echo ""
    echo -e "${BLUE}Step 2: Setting up workflow templates...${NC}"
    "$SCRIPT_DIR/workflow-templates.sh" init
    
    echo ""
    echo -e "${BLUE}Step 3: Creating example PRD...${NC}"
    if [[ ! -f "$PROJECT_DIR/.claude/prds/example-feature.md" ]]; then
        "$SCRIPT_DIR/workflow-templates.sh" create basic-feature-prd example-feature
    fi
    
    echo ""
    echo -e "${PURPLE}✅ Quick setup complete!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "${GREEN}1. Edit .claude/prds/example-feature.md with your requirements${NC}"
    echo -e "${GREEN}2. Run: PRD to Epic Converter${NC}"
    echo -e "${GREEN}3. Run: GitHub Issues Creator${NC}"
    echo -e "${GREEN}4. Run: Hybrid Orchestration${NC}"
    echo ""
}

# Function to show project dashboard
show_project_dashboard() {
    echo -e "${PURPLE}📊 Project Dashboard: $PROJECT_NAME${NC}"
    echo ""
    
    if [[ -d "$PROJECT_DIR/.claude" ]]; then
        # Run progress sync to get latest status
        "$SCRIPT_DIR/progress-sync.sh" sync-once > /dev/null 2>&1 || true
        
        # Show dashboard if available
        local dashboard_file="$PROJECT_DIR/.claude/context/progress-dashboard.md"
        if [[ -f "$dashboard_file" ]]; then
            cat "$dashboard_file"
        else
            echo -e "${YELLOW}⚠️  Dashboard not available. Run Progress Sync first.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  CCPM not initialized. Run Quick Setup first.${NC}"
    fi
    
    echo ""
}

# Function to show documentation menu
show_documentation_menu() {
    echo -e "${BLUE}📚 System Documentation${NC}"
    echo ""
    
    local docs=(
        "$AI_ORCHESTRATION_ROOT/docs/CCPM_HYBRID_GUIDE.md:Complete Hybrid Guide (Phase 3)"
        "$AI_ORCHESTRATION_ROOT/ccpm/INTEGRATION.md:Integration Guide"
        "$AI_ORCHESTRATION_ROOT/README.md:System Overview"
        "$AI_ORCHESTRATION_ROOT/docs/AI_ORCHESTRATION.md:Core Framework"
        "$AI_ORCHESTRATION_ROOT/ccmp/README.md:CCPM Documentation"
    )
    
    echo -e "${CYAN}📖 Available Documentation:${NC}"
    for i in "${!docs[@]}"; do
        IFS=':' read -ra parts <<< "${docs[$i]}"
        local doc_file="${parts[0]}"
        local doc_name="${parts[1]}"
        
        if [[ -f "$doc_file" ]]; then
            echo -e "${GREEN}  $((i+1)). $doc_name${NC}"
        else
            echo -e "${RED}  $((i+1)). $doc_name (missing)${NC}"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Enter number to view document (or press Enter to return):${NC}"
    read -r doc_choice
    
    if [[ -n "$doc_choice" ]] && [[ "$doc_choice" -ge 1 ]] && [[ "$doc_choice" -le ${#docs[@]} ]]; then
        local selected_doc="${docs[$((doc_choice-1))]}"
        IFS=':' read -ra parts <<< "$selected_doc"
        local doc_file="${parts[0]}"
        
        if [[ -f "$doc_file" ]]; then
            echo -e "${BLUE}📄 Viewing: ${parts[1]}${NC}"
            echo ""
            
            # Use glow if available, otherwise cat
            if command -v glow &> /dev/null; then
                glow "$doc_file"
            else
                cat "$doc_file"
            fi
        fi
    fi
}

# Main execution
# Function to ask about interactive mode
ask_for_interactive_mode() {
    echo -e "${CYAN}🎯 Welcome! How would you like to proceed?${NC}"
    echo ""
    echo -e "${YELLOW}Choose your experience level:${NC}"
    echo ""
    echo -e "${GREEN}1. 🎓 Beginner/First Time${NC} - Interactive guided mode with explanations"
    echo -e "${GREEN}2. 🚀 Experienced User${NC}   - Direct access to all tools"
    echo ""
    echo -e "${YELLOW}Select mode [1-2]: ${NC}"
    read -r mode_choice
    
    case "$mode_choice" in
        1)
            echo -e "${BLUE}🎓 Starting Interactive Guide Mode...${NC}"
            echo -e "${CYAN}This will walk you through everything step-by-step with explanations!${NC}"
            echo ""
            exec "$SCRIPT_DIR/interactive-guide.sh"
            ;;
        2)
            echo -e "${BLUE}🚀 Entering Expert Mode...${NC}"
            echo -e "${CYAN}Direct access to all orchestration tools.${NC}"
            echo ""
            return 0
            ;;
        *)
            echo -e "${YELLOW}Invalid choice. Defaulting to Expert Mode...${NC}"
            echo ""
            return 0
            ;;
    esac
}

main() {
    show_banner
    ask_for_interactive_mode
    show_project_context
    show_tools_menu
    
    echo -e "${YELLOW}Select tool to run [0-15] (or 'q' to quit):${NC}"
    read -r choice
    
    if [[ "$choice" == "q" ]] || [[ "$choice" == "Q" ]]; then
        echo -e "${GREEN}👋 Goodbye!${NC}"
        exit 0
    fi
    
    echo ""
    run_tool "$choice"
    
    echo ""
    echo -e "${PURPLE}────────────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Run another tool? (y/N):${NC}"
    read -r continue_choice
    
    if [[ "$continue_choice" == "y" ]] || [[ "$continue_choice" == "Y" ]]; then
        echo ""
        main
    else
        echo -e "${GREEN}🎉 AI Orchestration session complete!${NC}"
    fi
}

# Handle script arguments
if [[ $# -gt 0 ]]; then
    case "$1" in
        "--help"|"-h")
            show_banner
            echo -e "${BLUE}Master AI Orchestration Control System${NC}"
            echo ""
            echo -e "${CYAN}Usage:${NC}"
            echo -e "${GREEN}  $0                 # Interactive mode${NC}"
            echo -e "${GREEN}  $0 --status        # Show system status${NC}"
            echo -e "${GREEN}  $0 --quick-setup   # Run quick project setup${NC}"
            echo -e "${GREEN}  $0 --dashboard     # Show project dashboard${NC}"
            echo ""
            ;;
        "--status")
            show_banner
            show_project_context
            show_system_status
            ;;
        "--quick-setup")
            show_banner
            quick_project_setup
            ;;
        "--dashboard")
            show_banner
            show_project_dashboard
            ;;
        *)
            echo -e "${RED}❌ Invalid argument: $1${NC}"
            echo -e "${YELLOW}Use --help for usage information${NC}"
            exit 1
            ;;
    esac
else
    main
fi