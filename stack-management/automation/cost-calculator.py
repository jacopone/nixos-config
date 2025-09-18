#!/usr/bin/env python3
"""
Stack Management Cost Calculator
Automatically calculates costs from subscription tracking files.
"""

import re
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple

# Configuration
STACK_DIR = Path(__file__).parent.parent
SUBSCRIPTIONS_FILE = STACK_DIR / "active" / "subscriptions.md"
COST_SUMMARY_FILE = STACK_DIR / "active" / "cost-summary.md"

def extract_costs_from_subscriptions() -> Dict[str, float]:
    """Extract all costs from subscriptions.md file."""
    if not SUBSCRIPTIONS_FILE.exists():
        print(f"❌ Subscriptions file not found: {SUBSCRIPTIONS_FILE}")
        return {}
    
    costs = {}
    current_category = "Uncategorized"
    
    with open(SUBSCRIPTIONS_FILE, 'r') as f:
        for line in f:
            # Track category headers
            if line.startswith('## ') and ('€' in line or '$' in line):
                # Extract category name and budget (support both € and $)
                match = re.search(r'## (.+?) \([€$](\d+(?:\.\d{2})?)/month\)', line)
                if match:
                    current_category = match.group(1)
                    continue
                # Category without budget in header
                match = re.search(r'## (.+?) \([€$]', line)
                if match:
                    current_category = match.group(1)
                    continue
            
            # Extract individual service costs (support both € and $)
            cost_match = re.search(r'### (.+?) - [€$](\d+(?:\.\d{2})?)/month', line)
            if cost_match:
                service_name = cost_match.group(1)
                cost = float(cost_match.group(2))
                costs[service_name] = {
                    'cost': cost,
                    'category': current_category
                }
    
    return costs

def calculate_category_totals(costs: Dict[str, dict]) -> Dict[str, float]:
    """Calculate total costs by category."""
    category_totals = {}
    for service, details in costs.items():
        category = details['category']
        cost = details['cost']
        category_totals[category] = category_totals.get(category, 0) + cost
    return category_totals

def update_cost_summary(costs: Dict[str, dict], category_totals: Dict[str, float]):
    """Update the cost-summary.md file with calculated costs."""
    if not COST_SUMMARY_FILE.exists():
        print(f"❌ Cost summary file not found: {COST_SUMMARY_FILE}")
        return
    
    total_monthly = sum(details['cost'] for details in costs.values())
    
    # Read current content
    with open(COST_SUMMARY_FILE, 'r') as f:
        content = f.read()
    
    # Update total monthly cost (support both € and $)
    content = re.sub(
        r'\*\*TOTAL MONTHLY\*\*: [€$]\d+\.\d{2}',
        f'**TOTAL MONTHLY**: €{total_monthly:.2f}',
        content
    )
    
    # Update subscription breakdown
    for category, total in category_totals.items():
        pattern = f'{category}: [€$]\\d+\\.\\d{{2}}'
        replacement = f'{category}: €{total:.2f}'
        content = re.sub(pattern, replacement, content)
    
    # Update last updated date
    content = re.sub(
        r'\*\*Report Date\*\*: .+',
        f'**Report Date**: {datetime.now().strftime("%Y-%m-%d")}',
        content
    )
    
    # Write updated content
    with open(COST_SUMMARY_FILE, 'w') as f:
        f.write(content)

def main():
    """Main cost calculation function."""
    print("🧮 Stack Management Cost Calculator")
    print("=" * 40)
    
    # Extract costs from subscriptions
    costs = extract_costs_from_subscriptions()
    if not costs:
        print("❌ No costs found in subscriptions file")
        sys.exit(1)
    
    # Calculate totals
    category_totals = calculate_category_totals(costs)
    total_monthly = sum(details['cost'] for details in costs.values())
    
    # Display summary
    print(f"\n💰 Monthly Subscription Costs")
    print("-" * 30)
    
    for category, total in sorted(category_totals.items()):
        print(f"{category:.<25} €{total:>6.2f}")
    
    print("-" * 30)
    print(f"{'TOTAL MONTHLY':.<25} €{total_monthly:>6.2f}")
    
    # Show individual services
    print(f"\n📋 Service Breakdown ({len(costs)} services)")
    print("-" * 40)
    
    for service, details in sorted(costs.items()):
        category = details['category'][:15] + "..." if len(details['category']) > 18 else details['category']
        print(f"{service:.<20} {category:>15} €{details['cost']:>6.2f}")
    
    # Update cost summary file
    print(f"\n📝 Updating {COST_SUMMARY_FILE.name}...")
    update_cost_summary(costs, category_totals)
    print("✅ Cost summary updated!")
    
    # Annual projection
    annual_cost = total_monthly * 12
    print(f"\n📊 Annual Projection: €{annual_cost:,.2f}")

if __name__ == "__main__":
    main()