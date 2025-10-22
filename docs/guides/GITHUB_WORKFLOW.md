---
status: active
created: 2025-10-22
updated: 2025-10-22
type: guide
lifecycle: persistent
---

# GitHub Issue Workflow - Feature & Bug Tracking

Quick-capture system for tracking ideas and bugs across all your projects using GitHub Issues and `gh` CLI.

---

## 🎯 Overview

This workflow enables:
- **Instant capture** of ideas/bugs while using products (no context switching)
- **Multi-repo visibility** with grouped review commands
- **Decision framework** for prioritizing what to build
- **Integration with Spec Kit** and Claude Code for implementation

---

## 📝 Capture Commands

### Capture Feature Ideas

```bash
# In any git repository
cd ~/my-project
idea add dark mode toggle to settings
# ✅ Idea captured in my-project

idea export data as CSV
# ✅ Idea captured in my-project
```

**Creates GitHub issue with**:
- Label: `status:idea`, `type:feature`
- Title: "💡 add dark mode toggle to settings"
- Auto-linked to repository

---

### Log Bugs

```bash
# In any git repository
bug save button doesn't work on Firefox
# ✅ Bug logged in my-project

bug dashboard loads slowly with large datasets
# ✅ Bug logged in my-project
```

**Creates GitHub issue with**:
- Label: `type:bug`, `priority:medium`
- Title: "🐛 save button doesn't work on Firefox"
- Template with reproduction steps

---

## 🔍 Review Commands

### Review All Ideas (Multi-repo)

```bash
# From anywhere
ideas
# OR
review-ideas
```

**Output**:
```
💡 Ideas Across All Repositories

📦 jacopone/nixos-config (2 ideas)
  #128: 💡 add automated backup system (2025-10-22)
  #129: 💡 integrate with Notion API (2025-10-22)

📦 jacopone/basb-system (1 idea)
  #42: 💡 add bulk export feature (2025-10-22)

Next steps:
  • View details: gh issue view <number> --repo <owner/repo>
  • Spec it: spec-it <number> [owner/repo]
  • Build it: build-it <number> [owner/repo]
  • Defer it: defer-it <number> [owner/repo]
```

---

### Review All Bugs (Multi-repo)

```bash
# From anywhere
bugs
# OR
review-bugs
```

**Output**:
```
🐛 Bugs Across All Repositories

📦 jacopone/nixos-config (1 bug)
  #130: 🐛 rebuild fails on fresh install 🟡 (2025-10-22)

📦 jacopone/my-app (2 bugs)
  #45: 🐛 crash on mobile Safari 🔴 (2025-10-21)
  #46: 🐛 slow search performance 🟠 (2025-10-22)

Next steps:
  • View: gh issue view <number> --repo <owner/repo>
  • Fix: fix-it <number> [owner/repo]
```

Priority indicators:
- 🔴 Critical
- 🟠 High
- 🟡 Medium

---

## ⚡ Decision Commands

### Mark for Specification (Complex Features)

```bash
spec-it 128
# ✅ Issue #128 marked for specification
# Next: View with 'gh issue view 128'
#       Then run /spec-feature in Claude Code

# Or specify repo explicitly
spec-it 42 jacopone/basb-system
```

**What happens**:
- Removes label: `status:idea`
- Adds label: `status:needs-spec`

**Next steps**:
1. `gh issue view 128` - Review the issue
2. In Claude Code: `/spec-feature`
3. Tell Claude: "Please spec GitHub issue #128"
4. Claude uses Spec Kit to create detailed specification

---

### Mark Ready to Build (Simple Features)

```bash
build-it 129
# ✅ Issue #129 ready to build
# Next: View with 'gh issue view 129'
#       Then run /feature-dev:feature-dev in Claude Code
```

**What happens**:
- Removes label: `status:idea`
- Adds label: `status:ready`

**Next steps**:
1. `gh issue view 129` - Review the issue
2. In Claude Code: `/feature-dev:feature-dev`
3. Tell Claude: "Implement GitHub issue #129"

---

### Start Fixing a Bug

```bash
fix-it 45
# Creates branch and checks it out
# 🔧 Ready to fix bug #45
# Claude Code can help with the implementation

# Or for bugs in other repos
fix-it 45 jacopone/my-app
# ⚠️  Multi-repo bug fixing requires manual clone/checkout
# Run: gh issue view 45 --repo jacopone/my-app
```

**What happens** (current repo):
- Runs `gh issue develop 45`
- Creates branch like `45-crash-on-mobile-safari`
- Checks out the branch
- Ready to implement fix

---

### Defer for Later

```bash
defer-it 130
# 💤 Issue #130 deferred
# Reopen anytime: gh issue reopen 130
```

**What happens**:
- Adds label: `status:deferred`
- Closes issue with reason "not planned"
- Can reopen later when priorities change

---

## 🔄 Complete Workflow Example

### Day-to-Day Usage

```bash
# Morning: Working on project A
cd ~/nixos-config
idea add automated backup system
bug rebuild script fails on fresh install

# Afternoon: Working on project B
cd ~/basb-system
idea integrate with Notion API
idea add bulk export feature

# Evening: Working on project C
cd ~/my-app
bug crash on mobile Safari
bug slow search performance
```

---

### Weekly Planning Session

```bash
# Review everything from anywhere
cd ~
ideas
# See 4 ideas across 3 repos

bugs
# See 3 bugs across 3 repos

# Make decisions for each
gh issue view 128                     # Review details
spec-it 128                           # Complex → needs spec

gh issue view 42
build-it 42                           # Simple → ready to build

gh issue view 45
# Critical bug → prioritize
fix-it 45

gh issue view 130
defer-it 130                          # Not now
```

---

### Implementation with Claude Code

**For spec'd features**:
```bash
cd ~/nixos-config
gh issue view 128                     # Review issue

# In Claude Code
/spec-feature
# Claude: "What feature do you want to spec?"
# You: "Please spec GitHub issue #128 - automated backup system"
# Claude creates detailed spec using Spec Kit
```

**For ready features**:
```bash
cd ~/basb-system
gh issue view 42                      # Review issue

# In Claude Code
/feature-dev:feature-dev
# Claude: "What feature should we develop?"
# You: "Implement GitHub issue #42 - bulk export"
# Claude implements based on issue description
```

**For bugs**:
```bash
cd ~/my-app
fix-it 45                             # Creates branch

# In Claude Code
# You: "Fix the bug in issue #45 - crash on mobile Safari"
# Claude implements the fix

# When done
gh pr create --fill                   # Auto-links to issue #45
```

---

## 🏷️ Label System

### Status Labels
- `status:idea` - Just captured, not analyzed
- `status:needs-spec` - Requires specification with Spec Kit
- `status:ready` - Approved, ready to build
- `status:deferred` - Not now, revisit later

### Type Labels
- `type:feature` - New functionality
- `type:bug` - Something broken

### Priority Labels (Bugs)
- `priority:critical` - 🔴 Blocking, fix immediately
- `priority:high` - 🟠 Important, fix soon
- `priority:medium` - 🟡 Normal priority

---

## 💡 Tips & Best Practices

### Quick Capture Habit

**Do this**: Capture immediately while context is fresh
```bash
# Right after noticing something
idea add keyboard shortcuts for common actions
```

**Not this**: Write ideas in notes, then forget to log them

---

### Batch Review Sessions

Schedule regular review sessions (weekly/bi-weekly):
```bash
# Every Monday morning
ideas    # Review all feature ideas
bugs     # Review all bugs

# Prioritize and decide for each
```

---

### Use Descriptive Titles

**Good**:
```bash
idea add export to CSV with custom column selection
bug user profile page crashes when bio exceeds 500 chars
```

**Bad**:
```bash
idea export feature
bug profile broken
```

---

### Spec vs Build Decision

**Use `spec-it` when**:
- Feature requires 3+ files or 500+ lines of code
- Integration with external services
- Unclear requirements (needs clarification)
- Breaking architectural changes

**Use `build-it` when**:
- Small, well-defined feature
- Single file change
- Clear requirements
- Bug fix (use `fix-it` instead)

---

## 🔧 Troubleshooting

### Commands Not Found After Rebuild

**Problem**: `idea`, `bugs`, etc. not available

**Solution**:
```bash
# Reload fish shell
exec fish

# Or source config manually
source ~/.config/fish/config.fish
```

---

### "Not in a git repository" Error

**Problem**: Running `idea` or `bug` outside a repo

**Solution**: Navigate to a git repository first
```bash
cd ~/my-project
idea add feature
```

Note: Review commands (`ideas`, `bugs`) work from anywhere

---

### GitHub API Rate Limiting

**Problem**: Too many `gh` commands in short time

**Solution**: Wait a few minutes, or authenticate with token:
```bash
gh auth login
# Follow prompts to increase rate limit
```

---

## 📚 Related Documentation

- [COMMON_TASKS.md](./COMMON_TASKS.md) - NixOS system operations
- [Spec Kit Documentation](https://github.com/github/github/tree/master/script/specify) - Spec-driven development
- [gh CLI Manual](https://cli.github.com/manual/) - GitHub CLI reference

---

## 🚀 Quick Reference Card

```bash
# CAPTURE (in repo)
idea <description>          # Log feature idea
bug <description>           # Log bug

# REVIEW (anywhere)
ideas / review-ideas        # All ideas across repos
bugs / review-bugs          # All bugs across repos

# DECIDE
spec-it <num> [repo]        # Mark for spec → /spec-feature
build-it <num> [repo]       # Mark ready → /feature-dev
fix-it <num> [repo]         # Start fixing bug
defer-it <num> [repo]       # Close, revisit later

# VIEW DETAILS
gh issue view <num>         # In current repo
gh issue view <num> --repo owner/repo  # Other repo
```

---

*Last updated: 2025-10-22*
