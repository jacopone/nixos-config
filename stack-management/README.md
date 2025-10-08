---
status: active
created: 2025-10-08
updated: 2025-10-08
type: reference
lifecycle: persistent
---

# Stack Management System

**Personal Tech Stack Lifecycle Management for NixOS**

A comprehensive system for tracking, evaluating, and optimizing your technology stack - from discovery through deprecation.

---

## 🎯 Overview

This system helps you:
- **Discover** new tools and services systematically  
- **Evaluate** them with structured trials
- **Track** active subscriptions and costs
- **Optimize** through informed deprecation decisions
- **Learn** from postmortem analysis

## 📁 Directory Structure

```
stack-management/
├── discovery/
│   ├── backlog.md              # Quick capture of interesting finds
│   ├── evaluating.md           # Active trials and evaluations
│   └── templates/
│       └── discovery-item.md   # Template for new discoveries
├── active/
│   ├── subscriptions.md        # Paid services with costs & ROI
│   ├── packages.md             # NixOS packages with rationale  
│   └── cost-summary.md         # Budget tracking & analysis
├── deprecated/
│   ├── YYYY-MM-service.md      # Individual postmortem files
│   └── cost-savings.md         # Cumulative savings tracking
├── automation/
│   ├── cost-calculator.py      # Automated cost calculations
│   └── review-reminder.sh      # Review task automation
└── README.md                   # This documentation
```

---

## 🔄 Lifecycle Workflow

### 1. **Discovery Phase** 📡
*"Found something on Hacker News..."*

**Quick Capture:**
- Add to `discovery/backlog.md` using template
- Include source, cost, priority, and why interesting
- Use bookmarklet for one-click capture

**Example Entry:**
```markdown
#### 2024-01-15 - AI Coding Assistant X
- **Source**: Hacker News thread
- **URL**: https://example.com
- **Quick Notes**: Claims 30% faster coding with Rust
- **Priority**: High  
- **Why Interesting**: Current copilot struggles with Rust
- **Initial Cost**: $20/month
```

### 2. **Evaluation Phase** 🧪
*"Let me try this for 2 weeks..."*

**Move to Active Trial:**
- Transfer from backlog to `discovery/evaluating.md`
- Set trial period and success criteria
- Document daily experiences
- Make go/no-go decision

**Success Framework:**
- [ ] Solves real problem
- [ ] Better than current solution  
- [ ] Worth the cost
- [ ] Good integration
- [ ] Sustainable vendor

### 3. **Implementation Phase** ⚙️
*"Adding to my active stack..."*

**NixOS Integration:**
```nix
# stack-management: Added 2024-01-20, Cost: $20/month, Source: HN
# stack-management: Replaces: GitHub Copilot (-$10/month)
programs.ai-assistant = {
  enable = true;
  # configuration...
};
```

**Documentation Updates:**
- Add to `active/subscriptions.md` with cost and usage
- Update `active/cost-summary.md` budget tracking
- Run cost calculator for updated totals

### 4. **Active Management** 📊
*"Regular stack health monitoring..."*

**Monthly Reviews:**
- Update usage and ROI assessments
- Check for underutilized services
- Identify optimization opportunities
- Update cost projections

**Automation Support:**
```bash
# Weekly review reminder
./automation/review-reminder.sh

# Cost calculation update
./automation/cost-calculator.py

# Monthly deep review
./automation/review-reminder.sh force
```

### 5. **Deprecation Phase** 🗑️
*"This isn't working anymore..."*

**Systematic Removal:**
1. Create postmortem using template
2. Remove from NixOS configuration
3. Update cost tracking
4. Document lessons learned
5. Track savings achieved

**Postmortem Template:** `templates/postmortem.md`

---

## 🚀 Getting Started

### 1. **Initial Setup**
```bash
# Navigate to your nixos-config
cd ~/nixos-config/stack-management

# Test automation scripts
./automation/review-reminder.sh
./automation/cost-calculator.py
```

### 2. **Populate Current State**
- Add existing subscriptions to `active/subscriptions.md`
- Document current packages in `active/packages.md`  
- Set budget limits in `active/cost-summary.md`
- Run cost calculator to get baseline

### 3. **Start Discovery Process**
- Add browser bookmarklet from `templates/discovery-item.md`
- Begin capturing interesting finds in `discovery/backlog.md`
- Set up weekly review reminders

---

## 🔧 Automation Features

### Cost Calculator (`automation/cost-calculator.py`)
- Parses subscription costs from markdown
- Updates cost summary automatically
- Provides category breakdowns
- Shows annual projections

**Usage:**
```bash
python3 automation/cost-calculator.py
```

### Review Reminder (`automation/review-reminder.sh`) 
- Checks backlog health
- Monitors active evaluations
- Runs cost calculations
- Provides monthly review checklist

**Setup weekly reminders:**
```bash
./automation/review-reminder.sh setup-cron
```

---

## 📊 Key Metrics Tracked

### Financial Metrics
- Monthly subscription costs by category
- Annual spending projections  
- Savings from deprecations
- Budget utilization percentage
- ROI assessments per service

### Operational Metrics  
- Services in discovery backlog
- Active evaluations and trial status
- Package count and usage
- Deprecation success rate
- Time spent on stack management

---

## 🎯 Best Practices

### Discovery
- **Capture immediately** - don't overthink initial adds
- **Include context** - why it caught your attention
- **Set priorities** - helps focus evaluation efforts
- **Regular review** - weekly backlog grooming

### Evaluation  
- **Define success criteria** upfront
- **Set time limits** - avoid endless trials
- **Document daily** - capture real usage patterns
- **Test integrations** - ensure it fits your workflow

### Active Management
- **Monthly cost reviews** - track spending trends
- **ROI assessments** - validate ongoing value
- **Usage monitoring** - identify underused services
- **Integration checks** - ensure services work together

### Deprecation
- **Document thoroughly** - capture lessons learned  
- **Clean up completely** - remove configs and data
- **Track savings** - quantify optimization impact
- **Share insights** - help future decisions

---

## 🔗 Integration Points

### NixOS Configuration
```nix
# Add comments linking to stack management
# stack-management: Service added YYYY-MM-DD, Cost: $X/month
# stack-management: Replaces: Previous service (saves $Y/month)
```

### Git Workflow
```bash
# Commit messages link to stack management
git commit -m "Add service X (stack-management: +$20/month, see active/subscriptions.md)"
```

### Calendar Integration
- Monthly review on first Sunday
- Quarterly budget reviews
- Annual stack audit

---

## 📈 Success Indicators

### Stack Health
- ✅ All services have documented purpose
- ✅ Monthly costs within budget
- ✅ High ROI across all paid services  
- ✅ Regular evaluation of new tools
- ✅ Systematic deprecation of unused services

### Process Health
- ✅ Backlog regularly groomed
- ✅ Evaluations completed on schedule
- ✅ Costs tracked automatically
- ✅ Postmortems completed for all deprecations
- ✅ Learnings applied to future decisions

---

## 🚨 Warning Signs

### Stack Bloat
- ⚠️ Monthly costs growing without clear ROI
- ⚠️ Multiple services solving same problem
- ⚠️ Services unused for 30+ days
- ⚠️ Backlog growing without evaluation

### Process Breakdown  
- ⚠️ No reviews completed in 2+ months
- ⚠️ Cost calculations out of date
- ⚠️ Services added without documentation
- ⚠️ No recent deprecations despite growth

---

## 🔮 Future Enhancements

### Potential Automations
- GitHub/GitLab API integration for package tracking
- Browser extension for automatic discovery capture
- Slack/Discord notifications for review reminders
- Integration with personal finance tools

### Advanced Analytics
- Service usage correlation analysis
- Predictive cost modeling
- ROI optimization suggestions
- Stack comparison with peers

---

**Last Updated**: 2025-09-30
**System Version**: 1.0
**Maintainer**: Personal stack management system