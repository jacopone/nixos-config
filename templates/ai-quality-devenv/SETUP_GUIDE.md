# Interactive AI Tools Setup Guide

**Enterprise AI Development Template - October 2025**

## Overview

This template now features **interactive AI tool selection** via the `init-ai-tools` script, allowing you to choose Claude Code, Cursor AI, or both with a beautiful gum-powered interface.

## Quick Start

```bash
# 1. Copy template
cp -r ~/nixos-config/templates/ai-quality-devenv ./my-project
cd my-project

# 2. Enter environment
direnv allow

# 3. Interactive setup (NEW!)
init-ai-tools

# 4. Setup quality gates
setup-git-hooks

# 5. Verify
quality-report
```

## Interactive AI Tools Setup (`init-ai-tools`)

### What It Does

The `init-ai-tools` script provides an interactive interface to select and configure AI development tools for your project.

### Features

- ✅ **gum-powered UI**: Beautiful interactive prompts (fallback to bash select if gum unavailable)
- ✅ **Multi-select**: Choose Claude Code, Cursor AI, both, or skip
- ✅ **Smart copying**: Files copied from `.ai-templates/` directory
- ✅ **Verification**: Shows which tools were configured
- ✅ **Next steps**: Clear guidance on what to do after setup

### User Experience

```bash
$ init-ai-tools

🤖 AI Development Tools Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Select AI tool(s) to configure (Space to select, Enter to confirm):

  [ ] Claude Code - Token-efficient with MCP Serena
  [ ] Cursor AI - YOLO mode with Agent shortcuts
  [ ] Skip - Manual setup later
```

**After selection:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🤖 Setting up Claude Code...
  ✓ Copied CLAUDE.md (project instructions)
  ✓ Copied settings.local.json (personal settings)
  ✓ Copied README.md (documentation)
  ✓ Copied .claudeignore (context exclusions)
  ✓ Added settings.local.json to .gitignore

✅ Claude Code configured!
📄 Files created:
   • .claude/CLAUDE.md - Quality gate instructions (6KB)
   • .claude/settings.local.json - Personal settings
   • .claudeignore - Context exclusions

🔍 MCP Serena integration enabled for token-efficient operations
💡 Edit .claude/CLAUDE.md to customize behavior

🎯 Setting up Cursor AI...
  ✓ Copied MDC rule files
  ✓ Copied .cursorignore (context exclusions)

✅ Cursor AI configured!
📄 Files created:
   • .cursor/rules/index.mdc - Core development rules
   • .cursor/rules/security.mdc - Security patterns
   • .cursor/rules/testing.mdc - Testing standards
   • .cursorignore - Context exclusions

🎮 Agent mode shortcuts: Ctrl+I (agent) | Ctrl+E (background)
💡 Edit .cursor/rules/*.mdc to customize behavior

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Verification:
  ✅ Claude Code: Configured
  ✅ Cursor AI: Configured

📋 Next steps:
  1. Run 'setup-git-hooks' to install quality gates
  2. Run 'quality-report' to see active quality standards
  3. Initialize your project (npm init or uv init)
  4. Start coding with AI assistance!
```

## Template Structure

### New Architecture

```
ai-quality-devenv/
├── .ai-templates/              # NEW: Template source files
│   ├── README.md               # Template documentation
│   ├── claude/                 # Claude Code templates
│   │   ├── CLAUDE.md           # 6KB instruction file
│   │   ├── settings.local.json # Personal settings
│   │   ├── README.md           # Usage docs
│   │   └── .claudeignore       # Context exclusions
│   └── cursor/                 # Cursor AI templates
│       ├── rules/
│       │   ├── index.mdc       # Core rules
│       │   ├── security.mdc    # Security patterns
│       │   └── testing.mdc     # Testing standards
│       └── .cursorignore       # Context exclusions
├── devenv.nix                  # Contains init-ai-tools script
├── .gitignore                  # Ignores .cursor/, .claude/, etc.
└── README.md                   # Updated with init-ai-tools docs
```

### What Gets Created

When you run `init-ai-tools`, the following directories are created **in your project**:

**Claude Code:**
```
.claude/
├── CLAUDE.md                   # Copied from .ai-templates/
├── settings.local.json         # Copied from .ai-templates/
└── README.md                   # Copied from .ai-templates/

.claudeignore                   # Copied from .ai-templates/
```

**Cursor AI:**
```
.cursor/
└── rules/
    ├── index.mdc               # Copied from .ai-templates/
    ├── security.mdc            # Copied from .ai-templates/
    └── testing.mdc             # Copied from .ai-templates/

.cursorignore                   # Copied from .ai-templates/
```

## Available Scripts

### Primary Script

- **`init-ai-tools`** - Interactive AI tool selection and setup
  - Uses gum for beautiful UI (falls back to bash select)
  - Multi-select: Claude Code, Cursor AI, both, or skip
  - Copies files from `.ai-templates/` to project
  - Shows verification and next steps

### Individual Setup Scripts (Legacy - Use `init-ai-tools` instead)

- **`setup-claude`** - Setup Claude Code only
- **`setup-cursor`** - Setup Cursor AI only

### Other Scripts

- **`setup-git-hooks`** - Install pre-commit quality gates
- **`quality-report`** - Show all active quality standards
- **`quality-check`** - Run comprehensive quality analysis
- **`hello`** - Display environment information

## Workflow Examples

### Example 1: Claude Code Only

```bash
cp -r ~/nixos-config/templates/ai-quality-devenv ./my-saas-app
cd my-saas-app
direnv allow

init-ai-tools
# → Select "Claude Code - Token-efficient with MCP Serena"
# → Press Enter

setup-git-hooks
quality-report

npm init
claude-code .
```

### Example 2: Cursor AI Only

```bash
cp -r ~/nixos-config/templates/ai-quality-devenv ./my-mobile-app
cd my-mobile-app
direnv allow

init-ai-tools
# → Select "Cursor AI - YOLO mode with Agent shortcuts"
# → Press Enter

setup-git-hooks
quality-report

uv init
# Open in Cursor IDE
```

### Example 3: Both AI Tools

```bash
cp -r ~/nixos-config/templates/ai-quality-devenv ./my-enterprise-app
cd my-enterprise-app
direnv allow

init-ai-tools
# → Select both "Claude Code" and "Cursor AI" (Space to select both)
# → Press Enter

setup-git-hooks
quality-report

npm init
# Use either claude-code or open in Cursor IDE
```

### Example 4: Skip Initial Setup

```bash
cp -r ~/nixos-config/templates/ai-quality-devenv ./my-project
cd my-project
direnv allow

init-ai-tools
# → Select "Skip - Manual setup later"
# → Press Enter

# Later, when you're ready:
init-ai-tools
# → Select your preferred AI tool(s)
```

## Customization

### Editing AI Configurations

**Claude Code:**
```bash
# Edit comprehensive instructions
nano .claude/CLAUDE.md

# Edit settings
nano .claude/settings.local.json

# Update context exclusions
nano .claudeignore
```

**Cursor AI:**
```bash
# Edit core rules
nano .cursor/rules/index.mdc

# Edit security rules
nano .cursor/rules/security.mdc

# Add custom rules
touch .cursor/rules/database.mdc

# Update context exclusions
nano .cursorignore
```

### Updating Templates

To update the template source files:

```bash
# Edit template sources (these are what gets copied)
nano .ai-templates/claude/CLAUDE.md
nano .ai-templates/cursor/rules/index.mdc

# Re-run init-ai-tools in new projects to get updates
```

## Quality Gates

Both AI systems enforce identical quality standards:

| **Metric** | **Threshold** | **Tool** | **Enforcement** |
|------------|---------------|----------|-----------------|
| Complexity | CCN < 10 | Lizard | Pre-commit |
| Duplication | < 5% | JSCPD | Pre-commit |
| Security | Zero violations | Semgrep | Pre-commit |
| Secrets | Zero secrets | Gitleaks | Pre-commit |
| Formatting | 100% | Prettier, ESLint, Black, Ruff | Pre-commit |
| Coverage | 75%+ | Vitest, pytest | CI/CD |

## Troubleshooting

### gum not found

If you see "command not found: gum", the script will automatically fall back to bash select prompts. To get the enhanced UI:

```bash
# Rebuild NixOS with gum
sudo nixos-rebuild switch --flake .
```

### .ai-templates not found

If init-ai-tools reports ".ai-templates not found":

```bash
# Ensure you copied the entire template
ls -la .ai-templates

# If missing, re-copy the template
cp -r ~/nixos-config/templates/ai-quality-devenv/* .
```

### Files not copied

If files aren't being copied:

```bash
# Check permissions
ls -la .ai-templates/

# Manually copy if needed
cp -r .ai-templates/claude/ .claude/
cp .ai-templates/claude/.claudeignore ./
```

### Re-running init-ai-tools

`init-ai-tools` is safe to re-run. It only copies files that don't already exist, so your customizations won't be overwritten.

## System Requirements

- **NixOS**: Latest (2025+)
- **gum**: Installed via packages.nix (optional, but recommended)
- **fzf**: Already installed (fallback)
- **DevEnv**: Latest version
- **direnv**: For automatic environment activation

## Version Information

- **Template Version**: 2.0.0
- **Release Date**: October 2025
- **Key Feature**: Interactive AI tool selection with gum
- **Claude Code Compatibility**: October 2025+
- **Cursor AI Compatibility**: 2025+ (MDC format)
- **MCP Serena**: Enabled for Claude Code

## Migration from Old Template

If you're using the old template (with .cursor/ and .claude/ directly in the template):

```bash
# Old workflow:
setup-cursor
setup-claude

# New workflow:
init-ai-tools  # Select both tools
```

The new approach is cleaner because:
- ✅ Template doesn't include AI configs (only .ai-templates/)
- ✅ Users choose which tools they need
- ✅ No unnecessary files in template repository
- ✅ Beautiful interactive UX with gum
- ✅ Clear verification and next steps

---

**Built for modern development teams that demand excellence in code quality, security, and AI-assisted development.**
