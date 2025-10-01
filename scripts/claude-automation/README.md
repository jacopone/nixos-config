# claude-automation Package

## ⚠️ CRITICAL INFRASTRUCTURE - DO NOT DELETE ⚠️

**This is NOT legacy code. This is NOT a duplicate folder.**

This package is **ACTIVE, CRITICAL infrastructure** that auto-generates Claude Code configuration files during every `nixos-rebuild`.

### Why This Exists

Claude Code requires configuration files to understand your system. This package automatically generates them by:
1. Parsing your NixOS configuration files
2. Extracting tool lists, fish abbreviations, and system info
3. Generating up-to-date CLAUDE.md files

**Without this package, Claude Code loses context about your system every time you add packages.**

---

## Package Architecture

### Directory vs Import Name

- **Directory name**: `claude-automation/` (with hyphen)
- **Python package name**: `claude_automation` (with underscore)

This is **standard Python practice**. When you see:
```python
from claude_automation.generators.system_generator import SystemGenerator
```

It's importing from THIS directory. They are **NOT duplicates**.

---

## What This Package Does

### Auto-Generation on System Rebuild

Every time you run `./rebuild-nixos`, this package:

1. **Parses NixOS Configuration**
   - `modules/core/packages.nix` → Extracts 162 system tools
   - `modules/home-manager/base.nix` → Extracts 57 fish abbreviations
   - `flake.nix` → Extracts tech stack info

2. **Generates System-Level Config** (`~/.claude/CLAUDE.md`)
   - Complete tool inventory with descriptions
   - Fish shell abbreviations and smart commands
   - Tool substitution policies (fd > find, eza > ls, etc.)
   - System information (NixOS version, desktop, shell)

3. **Generates Project-Level Config** (`./CLAUDE.md`)
   - NixOS-specific workflows (rebuild process, flake structure)
   - Module organization and architecture
   - Git status and branch information
   - Current system state

### Integration Points

**Called by**: `rebuild-nixos` script (lines 120-140)
```bash
# In rebuild-nixos
cd scripts && devenv shell python update-system-claude-v2.py
cd scripts && devenv shell python update-project-claude-v2.py
```

**Uses**:
- `update-system-claude-v2.py` → Generates `~/.claude/CLAUDE.md`
- `update-project-claude-v2.py` → Generates `./CLAUDE.md`

---

## Package Structure

```
claude-automation/
├── README.md                    # THIS FILE - explains everything
├── __init__.py                  # Package initialization
├── schemas.py                   # Data schemas for validation
│
├── generators/                  # CLAUDE.md file generators
│   ├── __init__.py
│   ├── base_generator.py        # Base class for generators
│   ├── system_generator.py      # Generates ~/.claude/CLAUDE.md
│   └── project_generator.py     # Generates ./CLAUDE.md
│
├── parsers/                     # NixOS configuration parsers
│   ├── __init__.py
│   └── nix_parser.py           # Parses .nix files for tools/config
│
├── templates/                   # Jinja2 templates for generation
│   ├── system-claude.j2         # Template for system-level CLAUDE.md
│   ├── project-claude.j2        # Template for project-level CLAUDE.md
│   └── shared/                  # Shared template fragments
│       ├── command_examples.j2
│       ├── fish_abbreviations.j2
│       └── policies.j2
│
└── validators/                  # Content validation
    ├── __init__.py
    └── content_validator.py     # Validates generated files
```

---

## Why It Keeps Getting Deleted

### The Problem

This package **looks** like legacy code because:
1. ❌ No README.md explaining its purpose (FIXED NOW)
2. ❌ Hidden in `scripts/` directory
3. ❌ Name confusion: `claude-automation` (dir) vs `claude_automation` (import)
4. ❌ No visible integration with main system
5. ❌ Appears orphaned during cleanup operations

### The Reality

This package is:
- ✅ **ACTIVE** - Called on every nixos-rebuild
- ✅ **CRITICAL** - Claude Code loses system context without it
- ✅ **NOT DUPLICATE** - `claude-automation/` is THE package, `claude_automation` is the import name
- ✅ **WELL-ARCHITECTED** - Generators, parsers, templates, validators
- ✅ **ESSENTIAL INFRASTRUCTURE** - Auto-generates 400+ lines of Claude configuration

---

## How to Verify It Works

### Check Generated Files

```bash
# System-level config (auto-generated)
cat ~/.claude/CLAUDE.md
# Should show:
# - 162 system tools
# - 57 fish abbreviations
# - Tool substitution policies
# - Last updated timestamp

# Project-level config (auto-generated)
cat ~/nixos-config/CLAUDE.md
# Should show:
# - Tech stack (NixOS, Flakes, etc.)
# - Module structure
# - Git status
# - Workflows
```

### Trigger Manual Regeneration

```bash
cd ~/nixos-config/scripts
devenv shell python update-system-claude-v2.py
devenv shell python update-project-claude-v2.py
```

### Test During Rebuild

```bash
./rebuild-nixos
# Watch for:
# "✅ System-level Claude configuration updated"
# "✅ Project-level CLAUDE.md updated"
```

---

## Three Levels of Claude Configuration

### Level 1: System-Wide (`~/.claude/CLAUDE.md`)
- **Source**: Auto-generated by THIS package
- **Frequency**: On every nixos-rebuild
- **Content**: Tool inventory, fish abbreviations, system info
- **Scope**: ALL Claude Code projects on this system

### Level 2: NixOS Config Project (`./CLAUDE.md`)
- **Source**: Auto-generated by THIS package
- **Frequency**: On every nixos-rebuild
- **Content**: Workflows, module structure, git status
- **Scope**: Working on nixos-config repository

### Level 3: Template Projects (`.ai-templates/claude/CLAUDE.md`)
- **Source**: Manually maintained, high-quality curated
- **Frequency**: Manual updates only
- **Content**: Quality gates, DevEnv scripts, testing standards
- **Scope**: New projects created from ai-quality-devenv template

**Key Insight**: Levels 1 & 2 are DYNAMIC (auto-generated). Level 3 is STATIC (curated).

---

## Relationship to Template System

This package is **separate from** the template system:

| Component | Purpose | Maintenance |
|-----------|---------|-------------|
| **claude-automation package** (THIS) | Auto-generate system/project configs | Auto-updated on rebuild |
| **templates/ai-quality-devenv/.ai-templates/claude/** | Template for new projects | Manually curated |

They work together but serve different purposes:
- **claude-automation**: Keeps Claude informed about YOUR system
- **Template claude config**: Gives Claude quality standards for NEW projects

---

## Maintenance

### Adding New Tool Categories

Edit `templates/system-claude.j2`:
```jinja2
### New Category
{% for tool in tools.new_category %}
- `{{ tool.name }}` - {{ tool.description }}
{% endfor %}
```

### Updating Template Structure

Edit templates in `templates/` directory. Changes apply on next nixos-rebuild.

### Adding New Parsers

Create new parser in `parsers/` directory following `nix_parser.py` pattern.

---

## Dependencies

- **Python 3.13** (from DevEnv)
- **Jinja2** (template engine)
- **Python standard library** (pathlib, json, logging)

All dependencies available in DevEnv - no additional installation needed.

---

## Troubleshooting

### Issue: "Failed to update system-level Claude config"

**Solution**: Check DevEnv is active
```bash
cd ~/nixos-config/scripts
devenv shell
python update-system-claude-v2.py
```

### Issue: Import errors for claude_automation

**Solution**: Verify package structure intact
```bash
ls -la ~/nixos-config/scripts/claude-automation/
# Should show: generators/, parsers/, templates/, validators/
```

### Issue: Generated files empty or missing

**Solution**: Check Nix file paths in parsers
```bash
cd scripts
devenv shell python -c "from claude_automation.parsers.nix_parser import NixParser; print(NixParser().parse_packages('../modules/core/packages.nix'))"
```

---

## DO NOT DELETE CHECKLIST

Before deleting this directory, ask yourself:

- [ ] Do I want Claude Code to lose knowledge of my 162 system tools?
- [ ] Do I want to manually update Claude about every package I add?
- [ ] Do I want to break the `rebuild-nixos` script?
- [ ] Am I okay with Claude not knowing about fish abbreviations?
- [ ] Do I understand this is NOT a duplicate of anything else?

If you answered "No" to any of these, **DO NOT DELETE THIS DIRECTORY**.

---

## Related Documentation

- **System CLAUDE.md**: `~/.claude/CLAUDE.md` (auto-generated by this package)
- **Project CLAUDE.md**: `./CLAUDE.md` (auto-generated by this package)
- **Template CLAUDE.md**: `templates/ai-quality-devenv/.ai-templates/claude/CLAUDE.md` (manual)
- **Rebuild script**: `./rebuild-nixos` (calls this package)
- **Update scripts**: `scripts/update-system-claude-v2.py`, `scripts/update-project-claude-v2.py`

---

**Package Version**: 2.0
**Last Updated**: October 2025
**Status**: ACTIVE, CRITICAL INFRASTRUCTURE
**Deletability**: ❌ NEVER DELETE
