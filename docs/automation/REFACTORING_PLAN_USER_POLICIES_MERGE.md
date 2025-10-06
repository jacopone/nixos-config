# Claude Automation Refactoring: User Policies Merge Implementation

**Created**: 2025-10-05
**Status**: Ready to Execute
**Estimated Time**: 60 minutes
**Complexity**: Medium

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Implementation Steps](#implementation-steps)
5. [Testing & Validation](#testing--validation)
6. [Rollback Procedure](#rollback-procedure)
7. [Success Criteria](#success-criteria)

---

## Overview

### Problem
Currently, `claude-nixos-automation` includes an **instruction** in `~/.claude/CLAUDE.md` telling Claude to "check" the user policies file:

```markdown
**ALWAYS check `~/.claude/CLAUDE-USER-POLICIES.md` for user-specific policies**
```

This is unreliable - it's just a suggestion, not an actual import. Claude may or may not follow it.

### Solution
**Merge** user policies directly into `~/.claude/CLAUDE.md` during generation, ensuring they're loaded at initialization with guaranteed precedence.

### Benefits
- ✅ 100% reliable loading (single file)
- ✅ User policies at document top (maximum priority)
- ✅ No dependency on @import mechanism
- ✅ Clear architecture: source file → generator → artifact

---

## Prerequisites

Before starting, ensure:

1. **Repository access**:
   - `~/claude-nixos-automation` exists and is on `master` branch
   - `~/nixos-config` exists

2. **User policies file exists**:
   ```bash
   ls -l ~/.claude/CLAUDE-USER-POLICIES.md
   ```
   Should show the file (266 lines as of 2025-10-05)

3. **Clean working directory**:
   ```bash
   cd ~/claude-nixos-automation
   git status
   # Should show clean or only uv.lock changed
   ```

4. **Backup current CLAUDE.md**:
   ```bash
   cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup-before-merge
   ```

---

## Architecture

### File Roles

```
SOURCE FILES (User Maintains):
  ~/.claude/CLAUDE-USER-POLICIES.md  ← User edits this, never auto-overwritten

SOURCE FILES (System Maintains):
  ~/nixos-config/modules/core/packages.nix      ← 121 tools
  ~/nixos-config/modules/home-manager/base.nix  ← 57 fish abbreviations

              ↓
      [rebuild-nixos runs]
              ↓
  claude-automation generator:
    1. Read CLAUDE-USER-POLICIES.md
    2. Parse packages.nix
    3. Parse fish config
    4. MERGE into single document
              ↓
GENERATED ARTIFACT (Claude Reads):
  ~/.claude/CLAUDE.md  ← AUTO-GENERATED on every rebuild
```

### Key Principle
- **Source**: `CLAUDE-USER-POLICIES.md` (user edits, persisted)
- **Artifact**: `CLAUDE.md` (auto-generated, ephemeral)
- **Generator**: Merges source files into artifact

---

## Implementation Steps

### Step 1: Update SystemConfig Schema (5 min)

**File**: `~/claude-nixos-automation/claude_automation/schemas.py`

**Location**: Find the `SystemConfig` class (around line 98)

**Add two new fields** after `git_status`:

```python
class SystemConfig(BaseModel):
    """System-level CLAUDE.md configuration."""

    timestamp: datetime = Field(default_factory=datetime.now)
    package_count: int = Field(..., ge=1, le=1000, description="Total number of packages")
    fish_abbreviations: list[FishAbbreviation] = Field(default_factory=list)
    tool_categories: dict[ToolCategory, list[ToolInfo]] = Field(default_factory=dict)
    git_status: GitStatus = Field(default_factory=GitStatus)

    # NEW FIELDS - Add these two lines
    user_policies: str = Field(default="", description="User-defined policies content")
    has_user_policies: bool = Field(default=False, description="Whether user policies exist")

    # ... rest of class unchanged (validate methods, properties, etc.) ...
```

**Save the file.**

---

### Step 2: Update SystemGenerator - Part A (10 min)

**File**: `~/claude-nixos-automation/claude_automation/generators/system_generator.py`

**Location**: Find the `_build_system_config` method (around line 76)

**Add user policies reading** after fish abbreviations parsing and before the `return SystemConfig(...)` statement:

```python
def _build_system_config(self, config_dir: Path) -> SystemConfig:
    """Build system configuration from Nix files."""
    # ... existing code for parsing packages ...
    # ... existing code for organizing categories ...
    # ... existing code for parsing fish abbreviations ...

    # Get git status
    git_status = self.get_current_git_status()

    # NEW CODE - Add this entire section
    # Read user policies if they exist
    user_policies_file = Path.home() / ".claude" / "CLAUDE-USER-POLICIES.md"
    user_policies_content = ""
    has_user_policies = False

    if user_policies_file.exists():
        try:
            user_policies_content = user_policies_file.read_text(encoding='utf-8')
            has_user_policies = True
            logger.info(f"Read user policies from {user_policies_file}")
        except Exception as e:
            logger.warning(f"Failed to read user policies: {e}")
    # END NEW CODE

    return SystemConfig(
        timestamp=datetime.now(),
        package_count=len(all_packages),
        fish_abbreviations=fish_abbreviations,
        tool_categories=tool_categories,
        git_status=git_status,
        user_policies=user_policies_content,      # NEW - add this line
        has_user_policies=has_user_policies,      # NEW - add this line
    )
```

**Save the file.**

---

### Step 3: Update SystemGenerator - Part B (5 min)

**File**: `~/claude-nixos-automation/claude_automation/generators/system_generator.py`

**Location**: Find the `_prepare_template_context` method (around line 140)

**Add user policies to template context**:

```python
def _prepare_template_context(self, config: SystemConfig) -> dict:
    """Prepare context for template rendering."""
    return {
        "timestamp": config.timestamp,
        "package_count": config.package_count,
        "fish_abbreviations": config.fish_abbreviations,
        "tool_categories": config.tool_categories,
        "git_status": config.git_status,
        "total_tools": config.total_tools,
        "user_policies": config.user_policies,            # NEW - add this line
        "has_user_policies": config.has_user_policies,    # NEW - add this line
        "generation_info": {
            "generator": "SystemGenerator",
            "version": "2.1.0",  # CHANGE - bump from 2.0.0 to 2.1.0
            "template": "system-claude.j2",
        },
    }
```

**Save the file.**

---

### Step 4: Update System Template (10 min)

**File**: `~/claude-nixos-automation/claude_automation/templates/system-claude.j2`

**Location**: After the header (line ~5), before "## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY"

**Add the user policies section**:

```jinja2
# System-Level CLAUDE.md

This file provides Claude Code with comprehensive information about all available tools and utilities on this NixOS system.

*Last updated: {{ timestamp.strftime('%Y-%m-%d %H:%M:%S') }}*

{% if has_user_policies %}
---

## 🎯 USER-DEFINED POLICIES

**THESE POLICIES HAVE TOP PRIORITY AND OVERRIDE ALL SYSTEM DEFAULTS.**

{{ user_policies }}

---

{% endif %}

## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY

**SYSTEM OPTIMIZATION LEVEL: EXPERT**
{% include 'shared/policies.j2' %}

... (rest of template continues unchanged)
```

**Save the file.**

---

### Step 5: Remove Obsolete Instruction (5 min)

**File**: `~/claude-nixos-automation/claude_automation/templates/shared/policies.j2`

**Location**: Near the end of the file (after "Process search" section)

**REMOVE these lines entirely**:

```jinja2
### 📋 User-Defined Policies

**ALWAYS check `~/.claude/CLAUDE-USER-POLICIES.md` for user-specific policies that override defaults.**
```

**Reason**: User policies are now merged directly, this instruction is obsolete and misleading.

**The file should end with**:

```jinja2
5. **Process search** → `procs <pattern>` instead of `ps aux | grep`
```

(No user policies instruction after this)

**Save the file.**

---

### Step 6: Test Locally (10 min)

```bash
# 1. Go to automation repo
cd ~/claude-nixos-automation

# 2. Run the generator locally
nix run .#update-system

# 3. Verify the output
bat ~/.claude/CLAUDE.md | head -200

# EXPECTED OUTPUT:
# - Header with timestamp
# - "## 🎯 USER-DEFINED POLICIES" section
# - "THESE POLICIES HAVE TOP PRIORITY" message
# - Full content of your CLAUDE-USER-POLICIES.md
# - "---" separator
# - "## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY"
# - Rest of system tools
```

**Verification checks**:

```bash
# Check user policies are included
bat ~/.claude/CLAUDE.md | rg -A 20 "USER-DEFINED POLICIES"
# Should show your actual policies (git commit policy, rebuild restrictions, etc.)

# Check old instruction is gone
bat ~/.claude/CLAUDE.md | rg "ALWAYS check.*CLAUDE-USER-POLICIES"
# Should return nothing (not found)

# Check line count increased
wc -l ~/.claude/CLAUDE.md
# Should be ~450-500 lines (was ~200 before, now includes merged policies)
```

---

### Step 7: Commit Changes (5 min)

```bash
cd ~/claude-nixos-automation

# Check what changed
git status
git diff

# Add all changes
git add claude_automation/schemas.py
git add claude_automation/generators/system_generator.py
git add claude_automation/templates/system-claude.j2
git add claude_automation/templates/shared/policies.j2

# Commit with descriptive message
git commit -m "feat: merge user policies into system CLAUDE.md for guaranteed loading

Changes:
- SystemGenerator reads ~/.claude/CLAUDE-USER-POLICIES.md
- Merges content into ~/.claude/CLAUDE.md at top with TOP PRIORITY marker
- Add user_policies and has_user_policies to SystemConfig schema
- Update system-claude.j2 template to include merged policies section
- Remove obsolete 'check CLAUDE-USER-POLICIES.md' instruction from policies.j2
- Bump version to 2.1.0

Architecture:
- Source: CLAUDE-USER-POLICIES.md (user-editable, never overwritten)
- Artifact: CLAUDE.md (auto-generated, Claude reads this)
- Generator merges on every rebuild

Rationale:
- Single file = 100% guaranteed loading at initialization
- No dependency on @import mechanism reliability
- User policies clearly prioritized at document top
- Clear separation: source vs artifact

Fixes: User policies were being suggested but not actually imported"
```

---

### Step 8: Push to GitHub (2 min)

```bash
# Push changes
git push origin master

# Verify pushed successfully
git log -1 --oneline
# Should show your commit message
```

---

### Step 9: Test Integration with nixos-config (10 min)

```bash
# 1. Go to nixos-config
cd ~/nixos-config

# 2. Update flake inputs (pulls latest claude-nixos-automation)
nix flake update claude-automation

# 3. Rebuild system (will regenerate CLAUDE.md with new merge logic)
./rebuild-nixos

# When prompted "Are you satisfied with changes?", press 'y'
# When prompted for commit message, enter something like:
# "chore: update claude-automation to v2.1.0 with user policies merge"

# 4. Verify merged output
bat ~/.claude/CLAUDE.md | head -250

# EXPECTED:
# - User policies at top
# - System tools below
# - Clean merge, no duplication
```

**Verification**:

```bash
# Count sections
bat ~/.claude/CLAUDE.md | rg "^## " | head -10
# Should show:
# ## 🎯 USER-DEFINED POLICIES
# ## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY
# ## System Information
# ## Available Tools
# ... etc

# Check no old instruction remains
bat ~/.claude/CLAUDE.md | rg "ALWAYS check.*CLAUDE-USER-POLICIES"
# Should return nothing

# Check git status
cd ~/nixos-config
git log -1 --oneline
# Should show your commit about updating claude-automation
```

---

## Testing & Validation

### Test 1: Edit User Policies and Verify Merge

```bash
# 1. Edit user policies to add a test
echo -e "\n## 🧪 TEST POLICY\n\nNever use semicolons in JavaScript code." >> ~/.claude/CLAUDE-USER-POLICIES.md

# 2. Rebuild
cd ~/nixos-config
./rebuild-nixos
# Answer 'y' to satisfaction, skip commit message (press Enter)

# 3. Verify test policy is merged
bat ~/.claude/CLAUDE.md | rg -B 2 -A 2 "TEST POLICY"

# EXPECTED OUTPUT:
# ## 🧪 TEST POLICY
#
# Never use semicolons in JavaScript code.

# 4. Clean up test
# Edit ~/.claude/CLAUDE-USER-POLICIES.md and remove the test section
nano ~/.claude/CLAUDE-USER-POLICIES.md
# Delete the "## 🧪 TEST POLICY" section

# 5. Rebuild again to clean up
cd ~/nixos-config && ./rebuild-nixos
```

---

### Test 2: Validate with Claude Code

```bash
# 1. Start new Claude Code session
cd ~/nixos-config
claude-code .

# 2. In the chat, ask:
# "What are my user-defined policies regarding git commits?"

# EXPECTED: Claude should reference your git commit policy directly
# (e.g., "NEVER use git commit --no-verify without permission")

# NOT: Claude saying "I should check CLAUDE-USER-POLICIES.md"

# 3. Ask another test question:
# "What are my policies about rebuilding NixOS?"

# EXPECTED: Claude references the rebuild restrictions policy
```

---

### Test 3: Verify Source vs Artifact Separation

```bash
# 1. Check source file (user edits this)
ls -lh ~/.claude/CLAUDE-USER-POLICIES.md
# Should show ~266 lines, ~13KB

# 2. Check artifact file (Claude reads this)
ls -lh ~/.claude/CLAUDE.md
# Should show ~450-500 lines, ~25-30KB

# 3. Verify artifact is larger (contains merged content)
wc -l ~/.claude/CLAUDE-USER-POLICIES.md ~/.claude/CLAUDE.md
# CLAUDE-USER-POLICIES.md: ~266 lines
# CLAUDE.md: ~450-500 lines (includes policies + system tools)

# 4. Verify backup exists
ls -lt ~/.claude/.backups/ | head -5
# Should show recent backup files
```

---

## Rollback Procedure

### If Local Testing Fails (Before Commit)

```bash
cd ~/claude-nixos-automation

# Discard changes
git restore .

# Restore previous CLAUDE.md
cp ~/.claude/CLAUDE.md.backup-before-merge ~/.claude/CLAUDE.md

# You're back to the original state
```

---

### If Integration Testing Fails (After Push)

```bash
# 1. Revert commit in claude-nixos-automation
cd ~/claude-nixos-automation
git revert HEAD
git push origin master

# 2. Update nixos-config to use reverted version
cd ~/nixos-config
nix flake update claude-automation
./rebuild-nixos

# 3. Or restore from backup manually
cp ~/.claude/.backups/CLAUDE.md.backup-before-merge ~/.claude/CLAUDE.md
```

---

### If CLAUDE.md Gets Corrupted

```bash
# List available backups
ls -lt ~/.claude/.backups/

# Restore most recent backup
cp ~/.claude/.backups/CLAUDE.md.backup-$(ls -t ~/.claude/.backups/ | grep "CLAUDE.md.backup-" | head -1) ~/.claude/CLAUDE.md

# Or regenerate from scratch
cd ~/nixos-config
nix run github:jacopone/claude-nixos-automation#update-system
```

---

## Success Criteria

Mark each as ✅ when completed and verified:

- [ ] `schemas.py` updated with `user_policies` and `has_user_policies` fields
- [ ] `system_generator.py` reads CLAUDE-USER-POLICIES.md
- [ ] `system_generator.py` passes policies to template context
- [ ] `system-claude.j2` includes user policies section at top
- [ ] `shared/policies.j2` has obsolete instruction removed
- [ ] Local test: `nix run .#update-system` generates merged file
- [ ] Verification: User policies appear at top of CLAUDE.md
- [ ] Verification: "TOP PRIORITY" marker present
- [ ] Verification: Old "check" instruction gone
- [ ] Changes committed with descriptive message
- [ ] Changes pushed to GitHub successfully
- [ ] Integration test: `./rebuild-nixos` regenerates correctly
- [ ] Claude Code test: Policies referenced in responses
- [ ] Source file preserved: CLAUDE-USER-POLICIES.md unchanged
- [ ] Artifact generated: CLAUDE.md contains merged content

---

## Troubleshooting

### Issue: "user_policies" attribute error

**Symptom**:
```
AttributeError: 'SystemConfig' object has no attribute 'user_policies'
```

**Fix**: You forgot Step 1 (updating schemas.py). Go back and add the fields.

---

### Issue: User policies not appearing in CLAUDE.md

**Symptom**: CLAUDE.md generated but no user policies section

**Diagnosis**:
```bash
# Check if file exists
ls -l ~/.claude/CLAUDE-USER-POLICIES.md

# Check if generator reads it
cd ~/claude-nixos-automation
nix run .#update-system 2>&1 | rg "user policies"
# Should see: "Read user policies from ..."
```

**Fix**: Verify Step 2 (reading logic) was added correctly

---

### Issue: Template rendering error

**Symptom**:
```
TemplateError: ... user_policies undefined
```

**Fix**: You forgot Step 3 (adding to template context). Add those two lines.

---

### Issue: Old instruction still present

**Symptom**: Both new merge AND old "check" instruction appear

**Diagnosis**:
```bash
bat ~/.claude/CLAUDE.md | rg "check.*CLAUDE-USER-POLICIES"
```

**Fix**: Go back to Step 5 and remove the obsolete lines from `shared/policies.j2`

---

## Files Modified Summary

```
~/claude-nixos-automation/
├── claude_automation/
│   ├── schemas.py                      [MODIFIED - add 2 fields]
│   ├── generators/
│   │   └── system_generator.py         [MODIFIED - add read logic + context]
│   └── templates/
│       ├── system-claude.j2            [MODIFIED - add merge section]
│       └── shared/
│           └── policies.j2             [MODIFIED - remove instruction]

~/.claude/
├── CLAUDE-USER-POLICIES.md             [UNCHANGED - source file]
└── CLAUDE.md                           [REGENERATED - artifact]
```

---

## Time Estimates

| Phase | Task | Estimated Time |
|-------|------|----------------|
| 1 | Update schemas.py | 5 min |
| 2 | Update system_generator.py (Part A) | 10 min |
| 3 | Update system_generator.py (Part B) | 5 min |
| 4 | Update system-claude.j2 | 10 min |
| 5 | Update shared/policies.j2 | 5 min |
| 6 | Local testing | 10 min |
| 7 | Commit changes | 5 min |
| 8 | Push to GitHub | 2 min |
| 9 | Integration testing | 10 min |
| **Total** | | **~60 minutes** |

---

## Reference: What Changes Where

### Before (Current State)

```
~/.claude/CLAUDE.md
├── Header
├── Tool Selection Policy
│   └── "ALWAYS check CLAUDE-USER-POLICIES.md" ← Unreliable
├── System Tools (121 tools)
└── Fish Abbreviations (57)

~/.claude/CLAUDE-USER-POLICIES.md
└── User policies (266 lines) ← Separate file
```

### After (New State)

```
~/.claude/CLAUDE.md (GENERATED ARTIFACT)
├── Header
├── 🎯 USER-DEFINED POLICIES ← Merged at top
│   └── [Full content of CLAUDE-USER-POLICIES.md]
├── Tool Selection Policy
│   └── [No "check" instruction] ← Removed
├── System Tools (121 tools)
└── Fish Abbreviations (57)

~/.claude/CLAUDE-USER-POLICIES.md (SOURCE)
└── User policies (266 lines) ← User edits here
```

---

## Post-Implementation Notes

After completing this refactoring:

1. **User workflow**:
   - Edit: `nano ~/.claude/CLAUDE-USER-POLICIES.md`
   - Rebuild: `cd ~/nixos-config && ./rebuild-nixos`
   - Result: Policies auto-merged into CLAUDE.md

2. **Never edit CLAUDE.md directly** - it's regenerated on every rebuild

3. **User policies have guaranteed precedence** - they're literally at the top

4. **No @import dependency** - single file, 100% reliable

---

**Document Version**: 1.0
**Last Updated**: 2025-10-05
**Tested**: ❌ Pending execution
**Author**: Claude Code Planning Session
