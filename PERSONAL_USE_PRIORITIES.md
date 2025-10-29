---
status: active
created: 2025-10-29
updated: 2025-10-29
type: guide
lifecycle: persistent
---

# Personal Use - Adjusted Priorities

**Context**: This is a personal NixOS configuration for single-user, home use. No business deployment, no team collaboration, no compliance requirements.

**Reality Check**: Most of the "enterprise-grade" recommendations are overkill. Here's what actually matters for your personal setup.

---

## 🎯 What Actually Matters for Personal Use

### Your Current System is FINE for personal use. It works. Don't fix what isn't broken.

**Current State Reality**:
- ✅ You have a working system that boots and runs
- ✅ rebuild-nixos provides safety (test builds, rollback)
- ✅ You have 122 tools installed and working
- ✅ Automated updates are happening
- ✅ The system is maintainable by you

**The "Issues" in Context**:
- Most "vulnerabilities" are theoretical for personal use
- 11.9s rebuild time is annoying but not critical
- 9% test coverage is totally fine for personal config
- Monolithic files are only a problem if YOU find them hard to navigate
- Documentation is for you - temporal markers don't matter

---

## 🔴 Actually Fix These (4-6 hours total)

### 1. GitHub Token Exposure (1 hour) - GENUINE RISK

**Why it matters**: Your actual GitHub account with your actual repos is at risk.

**Location**: `modules/home-manager/base.nix:44-47`

```fish
# REMOVE THESE LINES:
if command -v gh &> /dev/null
  set -gx GITHUB_TOKEN (gh auth token 2>/dev/null)
end
```

**Simple fix** (no agenix needed for personal use):
```fish
# Just delete it. GitHub CLI tools can use gh auth directly:
# When you need auth, run: gh auth login
# Tools that need it will prompt or use credential helpers
```

**Alternative if automation needs it**:
Store in a file with restricted permissions instead:
```bash
# One-time setup
echo "$(gh auth token)" > ~/.github-token
chmod 600 ~/.github-token

# In scripts that need it:
GITHUB_TOKEN=$(cat ~/.github-token)
```

---

### 2. Enable Evaluation Cache (15 minutes) - FREE 60-80% SPEEDUP

**Why it matters**: 11.9s → 2-4s for repeated operations. This is literally free performance.

**Add to `flake.nix`**:
```nix
{
  # ... existing config ...

  nixConfig = {
    eval-cache = true;  # Cache evaluation results
    tarball-ttl = 3600; # Cache flake inputs for 1 hour
  };
}
```

**Test it**:
```bash
time nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
# First run: ~12s
# Second run: ~2-4s
```

---

### 3. Insecure Packages - ONLY if You're Paranoid (1-2 hours)

**Reality Check**: Obsidian with old Electron on your personal machine is low risk UNLESS:
- You're opening untrusted files in Obsidian
- You're clicking sketchy links in Obsidian
- You're using Obsidian for sensitive data

**Personal Risk Assessment**:
- **Low risk**: Using Obsidian for personal notes, trusted files only → Keep using it
- **Medium risk**: Opening untrusted markdown files → Consider updating
- **High risk**: Sensitive data + untrusted sources → Definitely fix

**If you decide to fix**:

**Option A: Live with the risk** (0 effort)
```nix
# Keep the current config, just be aware:
# - Don't open untrusted files in Obsidian
# - Don't click random links
# - You're probably fine
```

**Option B: Network isolation** (30 min)
```nix
# Install firejail
environment.systemPackages = with pkgs; [ firejail ];

# Run Obsidian without network
# Add to fish config or alias:
abbr obsidian 'firejail --net=none obsidian'
```

**Option C: Remove Obsidian** (5 min)
```nix
# Comment out obsidian in packages.nix
# Use web version or different note app
```

---

## ⚡ Nice Quality-of-Life Improvements (10-15 hours)

### These Actually Improve Your Daily Experience

#### 4. Split base.nix - ONLY if You Find it Annoying (4-8 hours)

**Question to ask yourself**:
- Do you struggle to find things in base.nix?
- Do you get lost scrolling through 1,165 lines?
- Would separate files help YOU?

**If YES**: Split it into logical modules (fish, kitty, yazi, git, etc.)
**If NO**: Leave it alone. It works. Monolithic is fine for personal use.

**Simple split approach** (if you decide to):
```bash
# Create module directories
mkdir -p modules/home-manager/{shell,terminal,file-management,development}

# Move logical chunks
# Fish config (300 lines) → shell/fish.nix
# Kitty (220 lines) → terminal/kitty.nix
# Starship (198 lines) → terminal/starship.nix
# Yazi (146 lines) → file-management/yazi.nix
# Git/direnv/etc → development/*.nix

# Update base.nix to import them
imports = [
  ./shell/fish.nix
  ./terminal/kitty.nix
  ./terminal/starship.nix
  ./file-management/yazi.nix
  ./development/git.nix
];
```

**Benefit**: Easier to navigate, faster to find things
**Effort**: 4-8 hours one-time
**Urgency**: Low - only if it bothers you

---

#### 5. Remove Dormant Tools (2-3 hours)

**Current**: 122 packages installed, 113 unused (88% dormant)

**Personal question**: Do you actually use these tools?
- wireshark, k9s, semgrep, etc.

**If NO**: Remove them, keep your system clean

**Simple audit**:
```bash
# Check what you've actually used (from analytics)
cat .claude/tool-analytics.md

# For each unused tool, ask:
# 1. Will I use this in the next month?
# 2. Is it easy to install on-demand with nix shell?
# 3. Does it slow my rebuilds?

# If all answers are NO → comment it out
```

**Benefit**:
- Faster rebuilds (fewer packages to check)
- Cleaner closure (3-5GB smaller)
- Less mental clutter

**Alternative lazy approach**:
```nix
# Keep everything, just add comments marking rarely-used stuff
environment.systemPackages = with pkgs; [
  # Daily use
  helix zed-editor eza bat fd ripgrep

  # Weekly use
  docker k9s

  # Rarely used (candidate for removal)
  # wireshark semgrep  # Could use: nix shell nixpkgs#wireshark
];
```

---

#### 6. Pin NPX Versions (2-4 hours)

**Why it matters for YOU**:
- claude-flow might break on updates
- Reproducibility is nice for personal debugging
- "It worked yesterday" syndrome

**Current risk**:
```nix
# This downloads whatever is "latest" today:
(pkgs.writeShellScriptBin "claude-flow" ''
  exec ${pkgs.nodejs_20}/bin/npx claude-flow@alpha "$@"
'')
```

**Personal fix** (pin to known-working versions):
```nix
# Find current version
npx claude-flow@alpha --version  # → 0.5.2 (example)

# Pin it
(pkgs.writeShellScriptBin "claude-flow" ''
  exec ${pkgs.nodejs_20}/bin/npx claude-flow@0.5.2 "$@"
'')
```

**Benefit**: Your tools don't randomly break
**Effort**: 5-10 minutes per tool
**Do this**: When a tool breaks and you find a working version

---

## 🤷 Probably Skip These (Unless You Enjoy It)

### These are "Nice to Have" but Not Worth the Effort for Personal Use

#### Skip: Extensive Testing (30 hours)
**Reality**: Your manual rebuild-nixos testing is fine. You're not deploying to production. You catch issues before they break your system.

**Keep**: The test build phase in rebuild-nixos (you already have this)
**Skip**: NixOS test framework, 40% coverage, CI/CD test automation

---

#### Skip: CI/CD Automation (20-40 hours)
**Reality**: You're the only developer. GitHub Actions is overkill.

**Keep**: Your local rebuild-nixos workflow (it's excellent)
**Skip**:
- GitHub Actions workflows (unless you enjoy DevOps as a hobby)
- Branch protection (you're the only one committing)
- Automated security scanning (it's your personal machine)

**Exception**: If you want GitHub Actions as a learning exercise, go for it! But don't feel obligated.

---

#### Skip: Security Hardening (15-20 hours)
**Reality**: Most security recommendations assume enterprise/multi-tenant/internet-facing systems.

**Keep**:
- Fix GitHub token (actually important)
- Don't run random Docker containers as root
- Basic firewall (probably already have via router)

**Skip**:
- Removing yourself from trusted-users (it's YOUR system)
- auditd logging (who's auditing? You?)
- File integrity monitoring (you have rollback)
- Docker rootless mode (unless you're running untrusted containers)
- Extensive firewall rules (you're behind home NAT)

---

#### Skip: Documentation Cleanup (10-15 hours)
**Reality**: The docs are for YOU. If temporal markers don't bother you, ignore them.

**Keep**:
- CLAUDE.md auto-updates (nice feature)
- Your operational knowledge

**Skip**:
- Removing 996 temporal markers (who cares?)
- Creating SECURITY.md (for who? yourself?)
- CONTRIBUTING.md (you're not accepting contributors)
- Fixing policy violations (your rules, your choice)

---

#### Skip: Multi-Host Architecture (20-30 hours)
**Reality**: You have one machine. You're not managing a fleet.

**Keep**: Current single-host setup
**Skip**: Multi-host refactoring entirely

**Reconsider**: Only if you actually get a second NixOS machine

---

## 🎨 The "Fun Project" Category

### Do These if You Enjoy the Process

These aren't necessary, but they're interesting learning experiences:

**If you enjoy DevOps**:
- Set up GitHub Actions (learn workflow automation)
- Implement proper secrets management with agenix
- Create monitoring dashboards

**If you enjoy architecture**:
- Refactor base.nix into clean modules
- Implement proper NixOS options system
- Create reusable module patterns

**If you enjoy optimization**:
- Get flake eval down to <2s
- Optimize closure size to <12GB
- Benchmark everything

**If you enjoy security**:
- Implement full security hardening
- Run vulnerability scanners
- Set up audit logging

**The point**: These are hobbies, not obligations. Do them if they spark joy.

---

## 📊 Adjusted Priority Matrix for Personal Use

| Priority | Task | Effort | Why |
|----------|------|--------|-----|
| **Do Now** | Fix GitHub token | 1h | Real security risk |
| **Do Now** | Enable eval-cache | 15m | Free 60-80% speedup |
| **Consider** | Insecure packages | 1-2h | Low risk, but your call |
| **Quality of Life** | Split base.nix | 4-8h | Only if it annoys you |
| **Quality of Life** | Remove dormant tools | 2-3h | Nice to have cleaner system |
| **Quality of Life** | Pin NPX versions | 2-4h | Do it when things break |
| **Skip / Hobby** | CI/CD automation | 20-40h | Overkill for personal use |
| **Skip / Hobby** | Extensive testing | 30h | Manual testing works fine |
| **Skip** | Security hardening | 15-20h | Most is unnecessary |
| **Skip** | Documentation cleanup | 10-15h | Docs are for you |
| **Skip** | Multi-host architecture | 20-30h | You have one machine |

---

## ✅ Realistic Implementation Plan for Personal Use

### This Week (2-3 hours) - Actually Do This
1. ✅ Fix GitHub token exposure (1h)
2. ✅ Enable eval-cache (15m)
3. ✅ Decide on Obsidian risk tolerance (15m thought, 0-2h action)

**Result**: Main security issue fixed, free performance boost

---

### Next Month (Optional, 10-15 hours)
1. ✅ Split base.nix IF it's bothering you (4-8h)
2. ✅ Clean up unused packages (2-3h)
3. ✅ Pin NPX versions as they break (2-4h)

**Result**: Nicer personal workflow, less clutter

---

### Someday/Maybe (If You're Bored)
1. Play with CI/CD as learning project
2. Refactor architecture for fun
3. Implement security hardening as hobby
4. Build monitoring dashboards

**Result**: New skills, interesting projects, but not necessary

---

## 🤔 The Real Questions to Ask

Instead of the comprehensive review's questions, ask yourself:

1. **Does it annoy me daily?**
   - 11.9s rebuild time? → Fix with eval-cache (15 min)
   - Can't find things in base.nix? → Split it (4-8h)
   - System feels bloated? → Remove unused tools (2-3h)

2. **Does it actually risk my data or accounts?**
   - GitHub token exposed? → YES, fix it (1h)
   - Old Electron in Obsidian? → Probably not, unless you're paranoid
   - No firewall? → You have a home router, probably fine

3. **Will I regret not doing this?**
   - CI/CD? → Probably not, manual is fine for personal
   - Testing? → Probably not, you catch issues before deployment
   - Documentation? → Probably not, you're the only user

4. **Is this actually fun for me?**
   - If YES → Do it as a hobby project
   - If NO → Skip it, spend time on things you enjoy

---

## 💡 The Minimalist Approach

**If you want to do the ABSOLUTE MINIMUM**:

```bash
# 1. Fix GitHub token (1 hour)
# Edit modules/home-manager/base.nix, remove lines 44-47

# 2. Enable eval-cache (5 minutes)
# Add to flake.nix:
nixConfig = {
  eval-cache = true;
  tarball-ttl = 3600;
};

# 3. Done. Your system is now good enough.
```

**Everything else** in the comprehensive review is optional quality-of-life or hobby territory.

---

## 🎯 Adjusted Success Metrics

Forget the enterprise metrics. Here are **personal use metrics**:

| Metric | Current | "Good Enough" | "Nice to Have" |
|--------|---------|---------------|----------------|
| **System boots?** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Daily tools work?** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Can rollback if broken?** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Rebuild time** | 11.9s | <5s (with cache) | <3s |
| **GitHub account safe?** | ❌ Token exposed | ✅ Fixed | ✅ Fixed |
| **Personal data safe?** | ✅ Mostly | ✅ Yes | ✅ Yes + backups |
| **Easy to maintain?** | ✅ Yes | ✅ Yes | ✅ Very easy |
| **Fun to use?** | ✅ Yes | ✅ Yes | ✅ Yes |

**Current Overall**: 7/8 good → **Fix GitHub token → 8/8 good**

---

## 🏁 Bottom Line for Personal Use

**Your system is fundamentally fine.** The comprehensive review found issues because it was looking from an enterprise/production lens.

**Do these 2 things** (2 hours total):
1. Fix GitHub token exposure
2. Enable eval-cache

**Consider these** (10-15 hours if they bother you):
3. Split base.nix if navigation is annoying
4. Remove unused tools for cleaner system
5. Pin NPX versions as tools break

**Skip everything else** unless it sounds fun to you as a learning project.

---

## 📚 What to Read from the Review

**Useful sections**:
- Phase 2A Security (GitHub token issue)
- Phase 2B Performance (eval-cache tip)
- Phase 1A Code Quality (split base.nix IF you want)

**Skip these sections**:
- Testing strategy (overkill)
- CI/CD implementation (overkill)
- Security hardening (mostly overkill)
- Documentation cleanup (unnecessary)
- Multi-host architecture (not relevant)
- Compliance anything (not applicable)

---

**Reality check complete.** Your NixOS config is good. Fix the token, enable cache, enjoy your system. 🎉

---

*Adjusted for: Personal use, single user, home environment, no business requirements*
*Priority: Things that actually matter vs. enterprise theatre*
