# AI Tool Configuration Templates

This directory contains template configurations for AI development tools. These files are copied by the `init-ai-tools` script based on your selection.

## Available Templates

### 📂 claude/
**Claude Code Integration** - Enterprise AI development with quality gate awareness

**Files:**
- `CLAUDE.md` - Project instructions with comprehensive quality gate awareness (6KB)
- `settings.json` - Shared team settings (git-tracked)
- `settings.local.json` - Personal settings (git-ignored)
- `README.md` - Usage documentation
- `.claudeignore` - Context exclusions

**Features:**
- MCP Serena integration for token-efficient symbolic code operations
- Quality hooks (Pre/Post tool use reminders)
- DevEnv script awareness (quality-check, quality-report, etc.)
- Comprehensive quality gate compliance strategies with examples

### 📂 cursor/
**Cursor AI Integration** - Modern MDC rules system with YOLO mode

**Files:**
- `rules/index.mdc` - Core development rules with quality standards
- `rules/security.mdc` - Security-focused rules and patterns
- `rules/testing.mdc` - Testing and QA rules
- `.cursorignore` - Context exclusions

**Features:**
- MDC format (YAML frontmatter + Markdown content)
- Glob patterns for file-specific rules
- YOLO mode for advanced AI capabilities
- Agent mode shortcuts (Ctrl+I, Ctrl+E)

## Usage

### Interactive Setup
```bash
# Enter development environment
devenv shell

# Run interactive AI tools setup
init-ai-tools

# Follow prompts to select:
# • Claude Code
# • Cursor AI
# • Both
# • Skip
```

### Manual Setup
```bash
# For Claude Code only
cp -r .ai-templates/claude/ .claude/
cp .ai-templates/claude/.claudeignore ./

# For Cursor AI only
cp -r .ai-templates/cursor/ .cursor/
cp .ai-templates/cursor/.cursorignore ./
```

## Shared Quality Standards

Both AI systems enforce identical quality gates:

| **Metric** | **Threshold** | **Tool** | **Enforcement** |
|------------|---------------|----------|-----------------|
| Complexity | CCN < 10 | Lizard | Pre-commit |
| Duplication | < 5% | JSCPD | Pre-commit |
| Security | Zero violations | Semgrep | Pre-commit |
| Secrets | Zero secrets | Gitleaks | Pre-commit |
| Formatting | 100% | Prettier, ESLint, Black, Ruff | Pre-commit |
| Coverage | 75%+ | Vitest, pytest | CI/CD |

## Customization

After running `init-ai-tools`, you can customize the generated configuration files:

**Claude Code:**
```bash
# Edit project instructions
nano .claude/CLAUDE.md

# Edit settings
nano .claude/settings.json
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

## Updating Templates

When the template system is updated:

1. **Pull latest changes**: `git pull` in nixos-config
2. **Re-run setup**: `init-ai-tools` (will detect existing configs)
3. **Merge changes**: Review diffs and merge updates as needed

## Version Information

- **Template Version**: 1.0.0
- **Claude Code Compatibility**: October 2025+
- **Cursor AI Compatibility**: 2025+ (MDC format)
- **DevEnv Version**: Latest
- **MCP Serena**: Enabled for Claude Code

---

**These templates ensure consistent, high-quality AI-assisted development across your entire team.**
