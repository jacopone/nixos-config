# 🤖 Claude Code Automation System

## Revolutionary Tool Selection Engine

This NixOS configuration features an **automated Claude Code behavior optimization system** that forces AI agents to leverage your sophisticated CLI toolkit instead of defaulting to basic POSIX commands.

## 🔍 **The Problem**

Claude Code was defaulting to legacy commands:
- ❌ `find` instead of `fd`
- ❌ `ls` instead of `eza`
- ❌ `cat` instead of `bat`
- ❌ `grep` instead of `rg`

Despite having **121+ premium modern CLI tools** installed and strategically distributed!

## ⚡ **The Solution**

**Automated Tool Selection Policy Engine** that:
1. **Scans your NixOS configuration** for all installed tools
2. **Generates mandatory substitution rules** for Claude Code
3. **Updates system-level context** automatically
4. **Enforces expert-level tool usage**

## 🎯 **How It Works**

### **Automatic Execution**
```bash
./rebuild-nixos  # Triggers the automation automatically
```

**Script Flow:**
```
rebuild-nixos → scripts/update-claude-tools.py → ~/.claude/CLAUDE.md
```

### **Generated Policies**
The system generates this context for Claude Code:

```markdown
## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY
**SYSTEM OPTIMIZATION LEVEL: EXPERT**

### MANDATORY Tool Substitutions (Use These ALWAYS)
- `find` → `fd` (ALWAYS use fd for file searching)
- `ls` → `eza` (ALWAYS use eza for directory listing)
- `cat` → `bat` (ALWAYS use bat for file viewing)
- `du` → `dust` (ALWAYS use dust for disk usage)
- `ps` → `procs` (ALWAYS use procs for process listing)
```

## 🚀 **Results**

**Before:**
```bash
# Claude Code would use:
find . -name "*.nix"
ls -la
cat config.json
```

**After:**
```bash
# Claude Code now automatically uses:
fd "\.nix$"
eza -la --git --group-directories-first
bat config.json
jless config.json  # for large JSON files
```

## 📊 **Technical Details**

- **Script**: `scripts/update-claude-tools.py`
- **Target**: `~/.claude/CLAUDE.md` (system-level context)
- **Tools Documented**: 121+ modern CLI tools (optimized system/project distribution)
- **Categories**: Development, file ops, data processing, system monitoring, database access
- **Automation**: Zero manual intervention required

## ✅ **Key Benefits**

- 🔄 **Self-Maintaining** - Updates with system changes
- 🎯 **Behavioral Enforcement** - Claude Code can't ignore preferences
- ⚡ **Zero Manual Work** - No need to specify tool choices
- 🏆 **Expert-Level** - Forces sophisticated tool usage
- 📈 **Always Current** - Tool knowledge stays synchronized

## 🧪 **Testing the System**

Try asking Claude Code to:
1. **"Find all .nix files"** → Should use `fd "\\.nix$"`
2. **"Show disk usage"** → Should use `dust`
3. **"List processes"** → Should use `procs`
4. **"View JSON file"** → Should use `jless` or `bat`

If Claude Code still uses legacy commands, run `./rebuild-nixos` to refresh the automation.

## 🏗️ **Strategic System/Project-Level Architecture**

### **System-Level Tools (Universal Access)**
- **Database CLI**: `pgcli`, `mycli`, `usql` - Always available for any database work
- **AI Development**: `aider`, `atuin`, `broot`, `mise` - Universal AI agent support
- **API Testing**: `hurl`, `httpie`, `xh` - Generic HTTP testing utilities
- **File Management**: `fd`, `eza`, `bat`, `jq`, `yq` - Universal processing tools

### **Project-Level Tools (Context-Specific)**
- **Code Quality**: `gitleaks`, `typos`, `pre-commit` - Managed via `devenv.nix` or `package.json`
- **Formatters**: `ruff`, `black`, `eslint`, `prettier` - Project-specific configurations
- **Testing**: Project-appropriate frameworks and versions
- **Language Tools**: Runtime-specific utilities in project environments

### **Why This Balance?**
✅ **AI agents** get consistent, universal tool access across all projects
✅ **Teams** maintain reproducible, version-controlled project configurations
✅ **No conflicts** between system-wide and project-specific tool versions
✅ **Optimal productivity** with the right tool in the right context

---

**This system ensures that every Claude Code session automatically leverages your full modern CLI ecosystem while respecting project-specific requirements and team collaboration needs.**