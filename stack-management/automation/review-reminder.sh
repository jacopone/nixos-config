#!/usr/bin/env bash
#
# Stack Management Review Reminder
# Automated reminders for stack maintenance tasks.
#

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATE=$(date +%Y-%m-%d)
MONTH=$(date +%B)
YEAR=$(date +%Y)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Stack Management Review - $DATE${NC}"
echo "=" $(printf '=%.0s' {1..50})

# Check if it's time for monthly review (first Sunday of month)
FIRST_SUNDAY=$(cal $(date +%m) $(date +%Y) | awk 'NF {DAYS = $0} END {print DAYS}' | grep -o '^.\?[0-9]' | head -1)
TODAY_DAY=$(date +%d)

if [ "$TODAY_DAY" -eq "$FIRST_SUNDAY" ] || [ "$1" = "force" ]; then
    echo -e "${YELLOW}📅 Monthly Review Time!${NC}"
    MONTHLY_REVIEW=true
else
    echo -e "${GREEN}ℹ️  Regular check (Monthly review on first Sunday)${NC}"
    MONTHLY_REVIEW=false
fi

echo ""

# 1. Discovery Backlog Check
echo -e "${BLUE}📋 Discovery Backlog Status${NC}"
BACKLOG_FILE="$STACK_DIR/discovery/backlog.md"
if [ -f "$BACKLOG_FILE" ]; then
    BACKLOG_ITEMS=$(grep -c "^#### " "$BACKLOG_FILE" 2>/dev/null || echo "0")
    echo "   • Backlog items: $BACKLOG_ITEMS"

    if [ "$BACKLOG_ITEMS" -gt 10 ]; then
        echo -e "   ${YELLOW}⚠️  High backlog count - consider reviewing${NC}"
    elif [ "$BACKLOG_ITEMS" -gt 0 ]; then
        echo -e "   ${GREEN}✅ Healthy backlog size${NC}"
    else
        echo -e "   ${BLUE}ℹ️  Empty backlog - add discoveries as you find them${NC}"
    fi
else
    echo -e "   ${RED}❌ Backlog file not found${NC}"
fi

# 2. Active Evaluations Check
echo -e "\n${BLUE}🧪 Active Evaluations${NC}"
EVAL_FILE="$STACK_DIR/discovery/evaluating.md"
if [ -f "$EVAL_FILE" ]; then
    EVAL_ITEMS=$(grep -c "^### " "$EVAL_FILE" 2>/dev/null || echo "0")
    echo "   • Services in trial: $EVAL_ITEMS"

    # Check for overdue evaluations (basic check for dates)
    if grep -q "Trial:" "$EVAL_FILE"; then
        echo -e "   ${YELLOW}⏰ Check trial end dates manually${NC}"
    fi
else
    echo -e "   ${RED}❌ Evaluation file not found${NC}"
fi

# 3. Cost Calculation
echo -e "\n${BLUE}💰 Cost Analysis${NC}"
if [ -f "$STACK_DIR/automation/cost-calculator.py" ]; then
    echo "   Running cost calculation..."
    if command -v python3 &> /dev/null; then
        python3 "$STACK_DIR/automation/cost-calculator.py" | tail -5
    else
        echo -e "   ${RED}❌ Python3 not available for cost calculation${NC}"
    fi
else
    echo -e "   ${RED}❌ Cost calculator not found${NC}"
fi

# 4. Monthly Review Tasks
if [ "$MONTHLY_REVIEW" = true ]; then
    echo -e "\n${YELLOW}📝 Monthly Review Checklist${NC}"
    echo "   □ Review discovery/backlog.md for stale items"
    echo "   □ Update active/subscriptions.md with usage notes"
    echo "   □ Check active/packages.md for unused packages"
    echo "   □ Review active/cost-summary.md budget status"
    echo "   □ Consider deprecating underused services"
    echo "   □ Update ROI assessments in subscriptions"
    echo ""
    echo -e "   ${GREEN}📁 Quick navigation:${NC}"
    echo "   • Backlog: $STACK_DIR/discovery/backlog.md"
    echo "   • Subscriptions: $STACK_DIR/active/subscriptions.md"
    echo "   • Packages: $STACK_DIR/active/packages.md"
    echo "   • Cost Summary: $STACK_DIR/active/cost-summary.md"
fi

# 5. Chrome Extension Check
echo -e "\n${BLUE}🌐 Chrome Extension Monitor${NC}"
if [ -f "$STACK_DIR/automation/chrome-extension-monitor.py" ]; then
    if command -v python3 &> /dev/null; then
        echo "   Running Chrome extension check..."
        python3 "$STACK_DIR/automation/chrome-extension-monitor.py" || echo -e "   ${YELLOW}ℹ️  Chrome not running or no new extensions${NC}"
    else
        echo -e "   ${RED}❌ Python3 not available for extension monitoring${NC}"
    fi
else
    echo -e "   ${RED}❌ Chrome extension monitor not found${NC}"
fi

# 6. Automation Health
echo -e "\n${BLUE}🔧 Automation Health${NC}"
if [ -x "$STACK_DIR/automation/cost-calculator.py" ]; then
    echo -e "   ${GREEN}✅ Cost calculator executable${NC}"
else
    echo -e "   ${YELLOW}⚠️  Cost calculator not executable${NC}"
    echo "      Run: chmod +x $STACK_DIR/automation/cost-calculator.py"
fi

if [ -x "$STACK_DIR/automation/chrome-extension-monitor.py" ]; then
    echo -e "   ${GREEN}✅ Chrome extension monitor executable${NC}"
else
    echo -e "   ${YELLOW}⚠️  Chrome extension monitor not executable${NC}"
    echo "      Run: chmod +x $STACK_DIR/automation/chrome-extension-monitor.py"
fi

# Check for recent postmortems
POSTMORTEM_COUNT=$(find "$STACK_DIR/deprecated" -name "*.md" -not -name "cost-savings.md" | wc -l)
echo "   • Recent postmortems: $POSTMORTEM_COUNT files"

# 6. Quick Actions
echo -e "\n${BLUE}⚡ Quick Actions${NC}"
echo "   • Add discovery item: edit $STACK_DIR/discovery/backlog.md"
echo "   • Update costs: run python3 $STACK_DIR/automation/cost-calculator.py"
echo "   • Monthly review: $0 force"
echo "   • View all files: ls -la $STACK_DIR/"

# 7. System Integration Check
echo -e "\n${BLUE}🔗 System Integration${NC}"
if grep -q "stack-management" "$STACK_DIR/../modules"/**/*.nix 2>/dev/null; then
    echo -e "   ${GREEN}✅ NixOS comments found${NC}"
else
    echo -e "   ${YELLOW}ℹ️  Add stack-management comments to NixOS configs${NC}"
fi

echo ""
echo -e "${GREEN}Review complete! $(date)${NC}"

# Optional: Set up cron job reminder
if [ "$1" = "setup-cron" ]; then
    echo ""
    echo -e "${BLUE}📅 Setting up weekly cron reminder...${NC}"
    CRON_ENTRY="0 9 * * 0 $STACK_DIR/automation/review-reminder.sh"
    echo "Add this to your crontab (crontab -e):"
    echo "$CRON_ENTRY"
    echo "This will run every Sunday at 9 AM"
fi
