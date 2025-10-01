# 🤖 Claude Code Automation System

## Overview

This NixOS configuration features an **automated Claude Code behavior optimization system** that ensures AI agents leverage the full sophisticated CLI toolkit instead of defaulting to basic POSIX commands.

## 🔍 The Problem

Claude Code and other AI assistants typically default to legacy commands:
- ❌ `find` instead of `fd`
- ❌ `ls` instead of `eza`
- ❌ `cat` instead of `bat`
- ❌ `grep` instead of `rg`

Despite having **162+ premium modern CLI tools** installed and strategically distributed across the system, AI agents would consistently fall back to basic POSIX utilities.

## ⚡ The Solution

**Automated Tool Selection Policy Engine** that:
1. **Scans your NixOS configuration** for all installed tools
2. **Generates mandatory substitution rules** for Claude Code
3. **Updates system-level context** automatically on every rebuild
4. **Enforces expert-level tool usage** through behavioral policies

## 🎯 How It Works

### Automatic Execution Flow

```
./rebuild-nixos
    ↓
scripts/update-claude-configs-v2.sh
    ↓
    ├─→ scripts/update-system-claude-v2.py
    │       ↓
    │   ~/.claude/CLAUDE.md (system-level tool inventory + policies)
    │
    └─→ scripts/update-project-claude-v2.py
            ↓
        ./CLAUDE.md (project-level context + dynamic status)
```

### Script Architecture

**System-Level Generator** (`scripts/claude_automation/generators/system_generator.py`)
- Parses `modules/core/packages.nix` for all installed tools
- Categorizes tools by function (development, file ops, monitoring, etc.)
- Generates mandatory tool substitution policies
- Updates `~/.claude/CLAUDE.md` with 162+ tool descriptions

**Project-Level Generator** (`scripts/claude_automation/generators/project_generator.py`)
- Analyzes current git status
- Generates project-specific guidance
- Updates `./CLAUDE.md` with dynamic status

**Template Engine** (Jinja2-based)
- `scripts/claude_automation/templates/system-claude.j2`
- `scripts/claude_automation/templates/project-claude.j2`
- Shared templates for policies, command examples, fish abbreviations

**Validation Layer** (`scripts/claude_automation/validators/content_validator.py`)
- Ensures generated content meets quality standards
- Validates Pydantic schemas for type safety

### Generated Policies

The system injects these policies into `~/.claude/CLAUDE.md`:

```markdown
## IMPORTANT: CLAUDE CODE TOOL SELECTION POLICY
**SYSTEM OPTIMIZATION LEVEL: EXPERT**
**ALWAYS default to advanced tools, not basic POSIX commands.**

### MANDATORY Tool Substitutions (Use These ALWAYS)
- `find` → `fd` (ALWAYS use fd for file searching)
- `ls` → `eza` (ALWAYS use eza for directory listing)
- `cat` → `bat` (ALWAYS use bat for file viewing, except when piping)
- `grep` → `rg` (ALWAYS use ripgrep for text search)
- `du` → `dust` (ALWAYS use dust for disk usage analysis)
- `ps` → `procs` (ALWAYS use procs for process listing)
- `top` → `btm` or `bottom` (for system monitoring)

### File Analysis Priority (Check file type first)
1. **JSON files** → `jless` (interactive) or `bat` (syntax highlighting)
2. **YAML files** → `yq` (processing) or `bat` (viewing)
3. **CSV files** → `csvlook` (table view) or `miller` (processing)
4. **Markdown** → `glow` (formatted) or `bat` (syntax highlighting)
```

## 🚀 Results

**Before:**
```bash
# Claude Code would use:
find . -name "*.nix"
ls -la
cat config.json
grep "error" logs.txt
```

**After:**
```bash
# Claude Code now automatically uses:
fd "\.nix$"
eza -la --git --group-directories-first
bat config.json
jless config.json  # for large/complex JSON
rg "error" logs.txt
```

## 📊 Technical Implementation

### Module Structure

```
scripts/claude_automation/
├── __init__.py
├── schemas.py                    # Pydantic models
├── generators/
│   ├── base_generator.py        # Base class with template rendering
│   ├── system_generator.py      # System-level CLAUDE.md generation
│   └── project_generator.py     # Project-level CLAUDE.md generation
├── parsers/
│   └── nix_parser.py            # Parses packages.nix for tools
├── validators/
│   └── content_validator.py     # Quality validation
└── templates/
    ├── system-claude.j2          # System-level template
    ├── project-claude.j2         # Project-level template
    └── shared/
        ├── command_examples.j2
        ├── fish_abbreviations.j2
        └── policies.j2
```

### Key Technologies

- **Python 3.13** - Modern type hints and async support
- **Jinja2** - Powerful templating engine
- **Pydantic** - Data validation and settings management
- **DevEnv** - Isolated development environment for scripts
- **Nix Parsing** - Extracts package information from Nix expressions

### Configuration Sources

1. **`modules/core/packages.nix`** - System-wide tool definitions
2. **`modules/home-manager/base.nix`** - Fish shell abbreviations
3. **Git repository state** - Dynamic status information
4. **Flake metadata** - System version and configuration details

## 🏗️ Strategic System/Project-Level Architecture

### System-Level Tools (Universal Access)

Installed system-wide in `modules/core/packages.nix` for universal availability:

- **Database CLI**: `pgcli`, `mycli`, `usql` - Always available for any database work
- **AI Development**: `aider`, `atuin`, `broot`, `mise` - Universal AI agent support
- **API Testing**: `hurl`, `httpie`, `xh` - Generic HTTP testing utilities
- **File Management**: `fd`, `eza`, `bat`, `jq`, `yq` - Universal processing tools
- **System Monitoring**: `procs`, `bottom`, `dust`, `duf` - Performance analysis
- **Data Processing**: `miller`, `csvkit`, `choose` - Universal data manipulation

### Project-Level Tools (Context-Specific)

Managed via `devenv.nix` or `package.json` for reproducibility:

- **Code Quality**: `gitleaks`, `typos`, `pre-commit` - Project-specific security/quality gates
- **Formatters**: `ruff`, `black`, `eslint`, `prettier` - Team-specific style configurations
- **Testing**: Project-appropriate frameworks and versions
- **Language Tools**: Runtime-specific utilities with version control

### Why This Balance?

✅ **AI agents** get consistent, universal tool access across all projects
✅ **Teams** maintain reproducible, version-controlled project configurations
✅ **No conflicts** between system-wide and project-specific tool versions
✅ **Optimal productivity** with the right tool in the right context

## ✅ Key Benefits

- 🔄 **Self-Maintaining** - Updates automatically with every system rebuild
- 🎯 **Behavioral Enforcement** - Claude Code cannot ignore tool preferences
- ⚡ **Zero Manual Work** - No need to specify tool choices repeatedly
- 🏆 **Expert-Level** - Forces sophisticated tool usage patterns
- 📈 **Always Current** - Tool knowledge stays synchronized with system state
- 🛡️ **Type-Safe** - Pydantic validation ensures data integrity
- 📦 **Modular** - Clean separation of concerns (parsing, generation, validation)

## 🧪 Testing the System

Try asking Claude Code to:

1. **"Find all .nix files"** → Should use `fd "\.nix$"`
2. **"Show disk usage"** → Should use `dust` or `dua`
3. **"List processes"** → Should use `procs`
4. **"View JSON file"** → Should use `jless` or `bat`
5. **"Search for text"** → Should use `rg` (ripgrep)

If Claude Code still uses legacy commands after a rebuild, the automation may need attention:

```bash
# Manual trigger if needed
cd scripts && devenv shell python update-system-claude-v2.py
cd scripts && devenv shell python update-project-claude-v2.py
```

## 🔧 Maintenance & Troubleshooting

### When to Regenerate

The system automatically regenerates on every `./rebuild-nixos`, but you may need manual regeneration if:

- You modify `modules/core/packages.nix` without rebuilding
- You want to test template changes
- Claude Code behavior seems outdated

### Manual Regeneration

```bash
# Full regeneration (recommended)
./scripts/update-claude-configs-v2.sh

# System-level only
cd scripts && devenv shell python update-system-claude-v2.py

# Project-level only
cd scripts && devenv shell python update-project-claude-v2.py
```

### Debugging

```bash
# Check DevEnv environment
cd scripts && devenv shell

# Validate Nix parsing
python -c "from claude_automation.parsers.nix_parser import NixConfigParser; p = NixConfigParser(); print(len(p.parse_packages('../modules/core/packages.nix')))"

# Check generated content
bat ~/.claude/CLAUDE.md
bat ./CLAUDE.md
```

## 📝 Evolution History

This automation system has evolved through several phases:

1. **Phase 1**: Manual CLAUDE.md maintenance (error-prone, tedious)
2. **Phase 2**: Simple Python script with string templating
3. **Phase 3**: Jinja2 templates + Pydantic validation + DevEnv isolation
4. **Current**: Modular architecture with parsing, generation, and validation layers

The current v2 system represents production-grade automation with proper software engineering practices.

---

**This system ensures that every Claude Code session automatically leverages your full modern CLI ecosystem while respecting project-specific requirements and team collaboration needs.**
