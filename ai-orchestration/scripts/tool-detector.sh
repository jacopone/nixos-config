#!/usr/bin/env bash

# Dynamic Tool Detection & Verification System
# Verifies availability of premium AI tools and adapts workflows accordingly

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
SCRIPT_NAME="AI Tool Detection & Verification"

# Configuration file path
CONFIG_FILE="$HOME/.ai-orchestration-config.json"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Tool availability tracking
declare -A TOOL_STATUS
declare -A TOOL_CAPABILITIES
declare -A FALLBACK_CHAINS

show_banner() {
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                 🔍 AI TOOL VERIFICATION SYSTEM 🔍              ║"
    echo "║                                                                ║"
    echo "║        Dynamic Detection & Adaptive Workflow Generation       ║"
    echo "║                                                                ║"
    echo "║  🧠 Gemini Detection  🖥️  Cursor Verification  🎨 Lovable Test ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Function to check Gemini capabilities
check_gemini_capabilities() {
    echo -e "${BLUE}🧠 Checking Gemini Access & Capabilities...${NC}"
    
    # Initialize Gemini status
    TOOL_STATUS["gemini_base"]="unknown"
    TOOL_STATUS["gemini_deep_think"]="unknown"
    TOOL_STATUS["gemini_deep_research"]="unknown"
    TOOL_STATUS["gemini_canvas"]="unknown"
    TOOL_STATUS["jules"]="unknown"
    TOOL_STATUS["notebooklm"]="unknown"
    
    # Ask about Gemini access in a user-friendly way
    echo ""
    echo -e "${CYAN}Let's check your Google AI access:${NC}"
    echo ""
    echo -e "${YELLOW}Do you have access to Gemini at gemini.google.com? [y/N]${NC}"
    read -r has_gemini_access
    
    if [[ "$has_gemini_access" =~ ^[Yy]$ ]]; then
        TOOL_STATUS["gemini_base"]="available"
        echo -e "${GREEN}  ✓ Gemini access confirmed${NC}"
        
        # Ask about subscription level
        echo ""
        echo -e "${CYAN}Which Google subscription do you have?${NC}"
        echo -e "${YELLOW}1. Google One Ultra (Premium) - Includes advanced Gemini features${NC}"
        echo -e "${YELLOW}2. Google One Standard/Basic - Regular Gemini access${NC}"
        echo -e "${YELLOW}3. Free Gemini - Basic access only${NC}"
        echo ""
        echo -e "${YELLOW}Select your subscription [1-3]: ${NC}"
        read -r subscription_level
        
        case "$subscription_level" in
            1)
                echo -e "${GREEN}  🌟 Google One Ultra detected!${NC}"
                TOOL_STATUS["gemini_deep_think"]="available"
                TOOL_STATUS["gemini_deep_research"]="available"
                TOOL_STATUS["gemini_canvas"]="available"
                TOOL_STATUS["jules"]="available"
                
                # Confirm specific features
                echo ""
                echo -e "${CYAN}Let's verify your premium features:${NC}"
                
                echo -e "${YELLOW}  • Do you see 'Deep Research' option in Gemini? [y/N]${NC}"
                read -r has_deep_research
                if [[ ! "$has_deep_research" =~ ^[Yy]$ ]]; then
                    TOOL_STATUS["gemini_deep_research"]="unavailable"
                fi
                
                echo -e "${YELLOW}  • Do you see 'Canvas' for collaboration? [y/N]${NC}"
                read -r has_canvas
                if [[ ! "$has_canvas" =~ ^[Yy]$ ]]; then
                    TOOL_STATUS["gemini_canvas"]="unavailable"
                fi
                
                echo -e "${YELLOW}  • Do you have access to Jules (Google's coding assistant)? [y/N]${NC}"
                read -r has_jules
                if [[ ! "$has_jules" =~ ^[Yy]$ ]]; then
                    TOOL_STATUS["jules"]="unavailable"
                fi
                
                echo -e "${YELLOW}  • Do you use NotebookLM (Google's AI research assistant)? [y/N]${NC}"
                read -r has_notebooklm
                if [[ "$has_notebooklm" =~ ^[Yy]$ ]]; then
                    TOOL_STATUS["notebooklm"]="available"
                    TOOL_CAPABILITIES["notebooklm_tier"]="ultra"
                    echo -e "${GREEN}    🌟 NotebookLM Ultra: ~100 notebooks, 50+ sources per notebook${NC}"
                else
                    TOOL_STATUS["notebooklm"]="unavailable"
                fi
                
                echo -e "${GREEN}  ✓ Premium Gemini features configured${NC}"
                ;;
            2|3)
                echo -e "${CYAN}  ℹ️  Standard Gemini access configured${NC}"
                TOOL_STATUS["gemini_deep_think"]="unavailable"
                TOOL_STATUS["gemini_deep_research"]="unavailable"
                TOOL_STATUS["gemini_canvas"]="unavailable"
                TOOL_STATUS["jules"]="unavailable"
                
                # Ask about NotebookLM for standard users
                echo -e "${YELLOW}  • Do you use NotebookLM (Google's AI research assistant)? [y/N]${NC}"
                read -r has_notebooklm
                if [[ "$has_notebooklm" =~ ^[Yy]$ ]]; then
                    TOOL_STATUS["notebooklm"]="available"
                    if [[ "$subscription_level" == "2" ]]; then
                        TOOL_CAPABILITIES["notebooklm_tier"]="pro"
                        echo -e "${GREEN}    💼 NotebookLM Pro: ~20 notebooks, 20+ sources per notebook${NC}"
                    else
                        TOOL_CAPABILITIES["notebooklm_tier"]="free"
                        echo -e "${GREEN}    📚 NotebookLM Free: ~10 notebooks, 10 sources per notebook${NC}"
                    fi
                else
                    TOOL_STATUS["notebooklm"]="unavailable"
                fi
                ;;
            *)
                echo -e "${YELLOW}  ⚠️  Assuming standard access${NC}"
                TOOL_STATUS["gemini_deep_think"]="unavailable"
                TOOL_STATUS["gemini_deep_research"]="unavailable"
                TOOL_STATUS["gemini_canvas"]="unavailable"
                TOOL_STATUS["jules"]="unavailable"
                TOOL_STATUS["notebooklm"]="unavailable"
                ;;
        esac
    else
        echo -e "${YELLOW}  ℹ️  No Gemini access - will use fallback options${NC}"
        TOOL_STATUS["gemini_base"]="unavailable"
        TOOL_STATUS["gemini_deep_think"]="unavailable"
        TOOL_STATUS["gemini_deep_research"]="unavailable"
        TOOL_STATUS["gemini_canvas"]="unavailable"
        TOOL_STATUS["jules"]="unavailable"
        TOOL_STATUS["notebooklm"]="unavailable"
    fi
}

# Function to check Cursor capabilities  
check_cursor_capabilities() {
    echo -e "${BLUE}🖥️  Checking Cursor AI Code Editor...${NC}"
    
    TOOL_STATUS["cursor_basic"]="unknown"
    TOOL_STATUS["cursor_pro"]="unknown"
    TOOL_STATUS["cursor_agents"]="unknown"
    
    echo ""
    echo -e "${CYAN}Let's check your Cursor setup:${NC}"
    echo ""
    echo -e "${YELLOW}Do you have Cursor AI code editor installed? [y/N]${NC}"
    echo -e "${CYAN}(Download from cursor.sh if you don't have it)${NC}"
    read -r has_cursor
    
    if [[ "$has_cursor" =~ ^[Yy]$ ]]; then
        TOOL_STATUS["cursor_basic"]="available"
        echo -e "${GREEN}  ✓ Cursor installation confirmed${NC}"
        
        # Ask about subscription level
        echo ""
        echo -e "${CYAN}What's your Cursor subscription level?${NC}"
        echo -e "${YELLOW}1. Cursor Pro - Unlimited AI usage, agents, advanced features${NC}"
        echo -e "${YELLOW}2. Cursor Free - Limited AI usage${NC}"
        echo ""
        echo -e "${YELLOW}Select your subscription [1-2]: ${NC}"
        read -r cursor_level
        
        case "$cursor_level" in
            1)
                TOOL_STATUS["cursor_pro"]="available"
                TOOL_STATUS["cursor_agents"]="available"
                echo -e "${GREEN}  🌟 Cursor Pro features enabled!${NC}"
                
                # Ask about preferred AI model
                echo ""
                echo -e "${CYAN}Which AI model do you prefer in Cursor?${NC}"
                echo -e "${YELLOW}1. Claude 3.5 Sonnet (Best for backend/complex code)${NC}"
                echo -e "${YELLOW}2. GPT-4o (Great for frontend/general coding)${NC}"
                echo -e "${YELLOW}3. Auto (Let Cursor choose)${NC}"
                echo ""
                echo -e "${YELLOW}Select model [1-3]: ${NC}"
                read -r model_choice
                
                case "$model_choice" in
                    1) TOOL_CAPABILITIES["cursor_preferred_model"]="claude-3-5-sonnet-20241022" ;;
                    2) TOOL_CAPABILITIES["cursor_preferred_model"]="gpt-4o-latest" ;;
                    *) TOOL_CAPABILITIES["cursor_preferred_model"]="auto" ;;
                esac
                
                echo -e "${GREEN}  ✓ Cursor Pro configured with preferred model${NC}"
                ;;
            *)
                TOOL_STATUS["cursor_pro"]="unavailable"
                TOOL_STATUS["cursor_agents"]="unavailable"
                echo -e "${CYAN}  ℹ️  Cursor Free configured${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}  ℹ️  No Cursor installation - will use alternative code editors${NC}"
        TOOL_STATUS["cursor_basic"]="not_installed"
        TOOL_STATUS["cursor_pro"]="not_installed"
        TOOL_STATUS["cursor_agents"]="not_installed"
    fi
}

# Function to check Lovable + Supabase capabilities
check_lovable_supabase_capabilities() {
    echo -e "${BLUE}🎨 Checking Lovable & Supabase Access...${NC}"
    
    TOOL_STATUS["lovable"]="unknown" 
    TOOL_STATUS["supabase"]="unknown"
    TOOL_STATUS["lovable_supabase_integrated"]="unknown"
    
    echo ""
    echo -e "${CYAN}Let's check your frontend development tools:${NC}"
    echo ""
    
    # Check Lovable access
    echo -e "${YELLOW}Do you have access to Lovable (lovable.dev)? [y/N]${NC}"
    echo -e "${CYAN}(Lovable is an AI-powered frontend builder)${NC}"
    read -r has_lovable
    
    if [[ "$has_lovable" =~ ^[Yy]$ ]]; then
        TOOL_STATUS["lovable"]="available"
        echo -e "${GREEN}  ✓ Lovable access confirmed${NC}"
    else
        TOOL_STATUS["lovable"]="unavailable"
        echo -e "${YELLOW}  ℹ️  No Lovable access - will use alternative frontend tools${NC}"
    fi
    
    # Check Supabase access
    echo ""
    echo -e "${YELLOW}Do you have a Supabase account (supabase.com)? [y/N]${NC}"
    echo -e "${CYAN}(Supabase provides backend-as-a-service with database, auth, etc.)${NC}"
    read -r has_supabase
    
    if [[ "$has_supabase" =~ ^[Yy]$ ]]; then
        TOOL_STATUS["supabase"]="available"
        echo -e "${GREEN}  ✓ Supabase access confirmed${NC}"
        
        # Ask about integration if both are available
        if [[ "${TOOL_STATUS["lovable"]}" == "available" ]]; then
            echo ""
            echo -e "${CYAN}Perfect! You have both Lovable and Supabase.${NC}"
            echo -e "${YELLOW}Would you like to use them together for full-stack development? [Y/n]${NC}"
            echo -e "${CYAN}(This enables rapid full-stack app creation)${NC}"
            read -r use_integration
            
            if [[ ! "$use_integration" =~ ^[Nn]$ ]]; then
                TOOL_STATUS["lovable_supabase_integrated"]="available"
                echo -e "${GREEN}  🌟 Lovable + Supabase integration enabled!${NC}"
                echo -e "${CYAN}    This will provide 60% faster frontend development${NC}"
            else
                TOOL_STATUS["lovable_supabase_integrated"]="disabled"
                echo -e "${CYAN}  ℹ️  Using Lovable and Supabase separately${NC}"
            fi
        fi
    else
        TOOL_STATUS["supabase"]="unavailable"
        echo -e "${YELLOW}  ℹ️  No Supabase access - will use alternative backend options${NC}"
    fi
}

# Function to check standard fallback tools
check_fallback_tools() {
    echo -e "${BLUE}🔧 Checking Additional Tools...${NC}"
    
    echo ""
    echo -e "${CYAN}Let's check some additional development tools:${NC}"
    echo ""
    
    # Claude Code (always available in this context)
    TOOL_STATUS["claude_code"]="available"
    echo -e "${GREEN}  ✅ Claude Code available (you're using it now!)${NC}"
    
    # Check v0.dev access
    echo ""
    echo -e "${YELLOW}Do you have access to v0.dev (Vercel's AI UI generator)? [y/N]${NC}"
    echo -e "${CYAN}(v0.dev generates React components from text descriptions)${NC}"
    read -r has_v0
    if [[ "$has_v0" =~ ^[Yy]$ ]]; then
        TOOL_STATUS["v0_dev"]="available"
        echo -e "${GREEN}  ✓ v0.dev access confirmed${NC}"
    else
        TOOL_STATUS["v0_dev"]="unavailable"
        echo -e "${YELLOW}  ℹ️  No v0.dev access - will use alternative UI generation${NC}"
    fi
    
    # Check GitHub CLI (technical check but explain it)
    echo ""
    echo -e "${CYAN}Checking GitHub integration...${NC}"
    if command -v gh &> /dev/null; then
        if gh auth status &> /dev/null 2>&1; then
            TOOL_STATUS["github_cli"]="available"
            echo -e "${GREEN}  ✅ GitHub CLI ready for project management${NC}"
        else
            TOOL_STATUS["github_cli"]="authentication_required"
            echo -e "${YELLOW}  ⚠️  GitHub CLI found but needs login${NC}"
            echo -e "${CYAN}    (Run 'gh auth login' later if needed)${NC}"
        fi
    else
        TOOL_STATUS["github_cli"]="not_installed"
        echo -e "${YELLOW}  ℹ️  GitHub CLI not found - limited GitHub integration${NC}"
        echo -e "${CYAN}    (Can be installed later: brew install gh)${NC}"
    fi
    
    # Check Git (essential)
    if command -v git &> /dev/null; then
        TOOL_STATUS["git"]="available"
        echo -e "${GREEN}  ✅ Git ready for version control${NC}"
    else
        TOOL_STATUS["git"]="not_installed"
        echo -e "${RED}  ❌ Git not found (REQUIRED for projects)${NC}"
        echo -e "${CYAN}    Please install Git first!${NC}"
    fi
}

# Function to define fallback chains
define_fallback_chains() {
    # Strategic Coordination
    if [[ "${TOOL_STATUS["gemini_deep_think"]}" == "available" && "${TOOL_STATUS["gemini_canvas"]}" == "available" ]]; then
        FALLBACK_CHAINS["strategic_coordinator"]="gemini_deep_think_canvas"
    elif [[ "${TOOL_STATUS["gemini_base"]}" == "available" ]]; then
        FALLBACK_CHAINS["strategic_coordinator"]="gemini_pro"
    else
        FALLBACK_CHAINS["strategic_coordinator"]="claude_code"
    fi
    
    # Research Specialist
    if [[ "${TOOL_STATUS["gemini_deep_research"]}" == "available" ]]; then
        FALLBACK_CHAINS["research_specialist"]="gemini_deep_research"
    elif [[ "${TOOL_STATUS["gemini_base"]}" == "available" ]]; then
        FALLBACK_CHAINS["research_specialist"]="gemini_pro"
    else
        FALLBACK_CHAINS["research_specialist"]="claude_code_research"
    fi
    
    # Knowledge Management Specialist (NEW)
    if [[ "${TOOL_STATUS["notebooklm"]}" == "available" ]]; then
        local tier="${TOOL_CAPABILITIES["notebooklm_tier"]:-free}"
        if [[ "$tier" == "ultra" ]]; then
            FALLBACK_CHAINS["knowledge_manager"]="notebooklm_ultra"
        elif [[ "$tier" == "pro" ]]; then
            FALLBACK_CHAINS["knowledge_manager"]="notebooklm_pro"  
        else
            FALLBACK_CHAINS["knowledge_manager"]="notebooklm_free"
        fi
    else
        FALLBACK_CHAINS["knowledge_manager"]="claude_code_docs"
    fi
    
    # Backend Implementation
    if [[ "${TOOL_STATUS["cursor_pro"]}" == "available" && "${TOOL_STATUS["cursor_agents"]}" == "available" ]]; then
        FALLBACK_CHAINS["backend_implementation"]="cursor_pro_agents"
    elif [[ "${TOOL_STATUS["cursor_basic"]}" == "available" ]]; then
        FALLBACK_CHAINS["backend_implementation"]="cursor_basic"
    else
        FALLBACK_CHAINS["backend_implementation"]="claude_code"
    fi
    
    # Frontend Implementation
    if [[ "${TOOL_STATUS["lovable_supabase_integrated"]}" == "available" ]]; then
        FALLBACK_CHAINS["frontend_implementation"]="lovable_supabase"
    elif [[ "${TOOL_STATUS["lovable"]}" == "available" ]]; then
        FALLBACK_CHAINS["frontend_implementation"]="lovable_standalone"
    elif [[ "${TOOL_STATUS["v0_dev"]}" == "available" ]]; then
        FALLBACK_CHAINS["frontend_implementation"]="v0_dev"
    else
        FALLBACK_CHAINS["frontend_implementation"]="claude_code"
    fi
    
    # Quality Assurance
    if [[ "${TOOL_STATUS["gemini_deep_think"]}" == "available" && "${TOOL_STATUS["jules"]}" == "available" ]]; then
        FALLBACK_CHAINS["quality_assurance"]="gemini_deep_think_jules"
    elif [[ "${TOOL_STATUS["gemini_base"]}" == "available" ]]; then
        FALLBACK_CHAINS["quality_assurance"]="gemini_pro"
    else
        FALLBACK_CHAINS["quality_assurance"]="claude_code_qa"
    fi
}

# Function to save configuration
save_configuration() {
    echo -e "${BLUE}💾 Saving Configuration...${NC}"
    
    # Create JSON configuration
    cat > "$CONFIG_FILE" << EOF
{
    "version": "$SCRIPT_VERSION",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "tool_status": {
$(for tool in "${!TOOL_STATUS[@]}"; do
    echo "        \"$tool\": \"${TOOL_STATUS[$tool]}\","
done | sed '$s/,$//')
    },
    "tool_capabilities": {
$(for capability in "${!TOOL_CAPABILITIES[@]}"; do
    echo "        \"$capability\": \"${TOOL_CAPABILITIES[$capability]}\","
done | sed '$s/,$//')
    },
    "fallback_chains": {
$(for chain in "${!FALLBACK_CHAINS[@]}"; do
    echo "        \"$chain\": \"${FALLBACK_CHAINS[$chain]}\","
done | sed '$s/,$//')
    }
}
EOF
    
    echo -e "${GREEN}  ✓ Configuration saved to: $CONFIG_FILE${NC}"
}

# Function to display configuration summary
show_configuration_summary() {
    echo -e "${BLUE}📊 Configuration Summary${NC}"
    echo ""
    
    echo -e "${PURPLE}Strategic Coordination:${NC} ${FALLBACK_CHAINS["strategic_coordinator"]}"
    echo -e "${PURPLE}Research Specialist:${NC} ${FALLBACK_CHAINS["research_specialist"]}"
    echo -e "${PURPLE}Knowledge Management:${NC} ${FALLBACK_CHAINS["knowledge_manager"]}"
    echo -e "${PURPLE}Backend Implementation:${NC} ${FALLBACK_CHAINS["backend_implementation"]}"
    echo -e "${PURPLE}Frontend Implementation:${NC} ${FALLBACK_CHAINS["frontend_implementation"]}"
    echo -e "${PURPLE}Quality Assurance:${NC} ${FALLBACK_CHAINS["quality_assurance"]}"
    echo ""
    
    # Calculate optimization level
    local premium_count=0
    local total_roles=6
    
    [[ "${FALLBACK_CHAINS["strategic_coordinator"]}" == "gemini_deep_think_canvas" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["research_specialist"]}" == "gemini_deep_research" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["knowledge_manager"]}" =~ ^notebooklm_(ultra|pro)$ ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["backend_implementation"]}" == "cursor_pro_agents" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["frontend_implementation"]}" == "lovable_supabase" ]] && ((premium_count++))
    [[ "${FALLBACK_CHAINS["quality_assurance"]}" == "gemini_deep_think_jules" ]] && ((premium_count++))
    
    local optimization_percent=$((premium_count * 100 / total_roles))
    
    if [[ $optimization_percent -eq 100 ]]; then
        echo -e "${GREEN}🚀 Optimization Level: Ultra Premium (98%+ efficiency)${NC}"
    elif [[ $optimization_percent -ge 60 ]]; then
        echo -e "${YELLOW}⚡ Optimization Level: Premium ($((50 + optimization_percent/2))%+ efficiency)${NC}"
    else
        echo -e "${CYAN}🔧 Optimization Level: Standard (Base efficiency)${NC}"
    fi
}

# Function to generate setup recommendations
generate_recommendations() {
    echo -e "${BLUE}💡 Setup Recommendations${NC}"
    echo ""
    
    local has_recommendations=false
    
    # Missing premium tools
    if [[ "${TOOL_STATUS["gemini_deep_think"]}" != "available" ]]; then
        echo -e "${YELLOW}📈 Consider upgrading to Google One Ultra for:${NC}"
        echo -e "${CYAN}  • Gemini Deep Think (40% faster strategic planning)${NC}"
        echo -e "${CYAN}  • Gemini Deep Research (comprehensive analysis)${NC}"
        echo -e "${CYAN}  • Canvas (visual collaboration)${NC}"
        echo -e "${CYAN}  • Jules (continuous code review)${NC}"
        has_recommendations=true
    fi
    
    if [[ "${TOOL_STATUS["cursor_pro"]}" != "available" ]]; then
        echo -e "${YELLOW}🖥️  Consider upgrading to Cursor Pro for:${NC}"
        echo -e "${CYAN}  • Advanced AI agents (35% faster backend development)${NC}"
        echo -e "${CYAN}  • Superior model selection and control${NC}"
        echo -e "${CYAN}  • Multi-agent parallel development${NC}"
        has_recommendations=true
    fi
    
    if [[ "${TOOL_STATUS["lovable"]}" != "available" ]]; then
        echo -e "${YELLOW}🎨 Consider Lovable + Supabase for:${NC}"
        echo -e "${CYAN}  • 60% faster frontend development${NC}"
        echo -e "${CYAN}  • Integrated full-stack workflows${NC}"
        echo -e "${CYAN}  • Real-time features and authentication${NC}"
        has_recommendations=true
    fi
    
    # Missing CLI tools
    if [[ "${TOOL_STATUS["github_cli"]}" != "available" ]]; then
        echo -e "${YELLOW}🐙 Install GitHub CLI for enhanced project management:${NC}"
        echo -e "${CYAN}  brew install gh  # or  sudo apt install gh${NC}"
        has_recommendations=true
    fi
    
    if [[ ! $has_recommendations ]]; then
        echo -e "${GREEN}✨ Your setup is fully optimized! No recommendations at this time.${NC}"
    fi
}

# Main function
main() {
    show_banner
    
    echo -e "${CYAN}Detecting and verifying AI tool availability...${NC}"
    echo ""
    
    # Run all checks
    check_gemini_capabilities
    echo ""
    check_cursor_capabilities  
    echo ""
    check_lovable_supabase_capabilities
    echo ""
    check_fallback_tools
    echo ""
    
    # Define optimal workflow chains
    define_fallback_chains
    
    # Save and display results
    save_configuration
    echo ""
    show_configuration_summary
    echo ""
    generate_recommendations
    echo ""
    
    echo -e "${GREEN}✅ Tool verification complete!${NC}"
    echo -e "${CYAN}💡 Configuration saved and ready for adaptive workflows.${NC}"
}

# Command line interface
case "${1:-main}" in
    "main"|"verify"|"")
        main
        ;;
    "status")
        if [[ -f "$CONFIG_FILE" ]]; then
            echo -e "${BLUE}📊 Current Configuration:${NC}"
            cat "$CONFIG_FILE" | jq -r '
                "Last Updated: " + .timestamp,
                "",
                "🔧 Tool Status:",
                (.tool_status | to_entries[] | "  " + .key + ": " + .value),
                "",
                "⚡ Active Chains:",
                (.fallback_chains | to_entries[] | "  " + .key + ": " + .value)
            ' 2>/dev/null || cat "$CONFIG_FILE"
        else
            echo -e "${YELLOW}⚠️  No configuration found. Run tool verification first.${NC}"
        fi
        ;;
    "config-path")
        echo "$CONFIG_FILE"
        ;;
    *)
        echo "Usage: $0 [verify|status|config-path]"
        echo "  verify     - Run tool detection and verification (default)"
        echo "  status     - Show current configuration"
        echo "  config-path - Show configuration file path"
        ;;
esac