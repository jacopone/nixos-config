# Claude Code Configuration

This directory contains Claude Code configuration for enterprise AI development with comprehensive quality gate awareness.

## Files

### `CLAUDE.md` (6KB)
**Primary instruction file** for Claude Code with complete quality gate awareness.

**Contents:**
- 🎯 Project Overview - Technology stack (Node 20, Python 3.13, DevEnv)
- 🤖 Operational Guidelines - Quality-first development directive
- 🔍 MCP Serena Integration - Token-efficient symbolic code operations
- 🔒 Quality Gate Compliance - Detailed strategies for each threshold:
  - Cyclomatic Complexity (CCN < 10) with examples
  - Code Duplication (< 5%) with prevention patterns
  - Security (Gitleaks + Semgrep) with violation/compliance examples
  - Formatting (Prettier, ESLint, Black, Ruff) standards
- 🛠️ Development Workflows - Code generation, refactoring, testing
- 📊 Performance Guidelines - Language-specific optimizations
- 🧪 Testing Requirements - Coverage standards, patterns, stack

**Purpose**: Ensures Claude Code generates enterprise-grade code that passes all quality gates.

### `settings.local.json`
**Claude Code settings** with quality hooks and MCP integration.

**Features:**
- ✅ Full permissions for project operations
- ✅ Auto-enable all project MCP servers (Serena)
- ✅ Quality reminder hooks on Write/Edit operations
- ✅ Environment variables for quality mode
- ✅ Co-authoring attribution

### `.claudeignore`
**Context exclusion file** to optimize token usage.

**Excludes:**
- Build artifacts (.devenv/, result, dist/, build/)
- Dependencies (node_modules/, __pycache__/)
- Environment files (.env, .env.*)
- Quality tool output (coverage/, .nyc_output/)
- IDE configs (.cursor/, .vscode/, .idea/)

## Setup

```bash
# In your project (after copying template)
devenv shell          # Enter development environment
setup-claude          # One-command setup

# Verify
quality-report        # See all quality gates
```

## Usage

### Starting Development
```bash
claude-code .         # Start Claude Code session

# Claude will automatically:
# - Read CLAUDE.md for quality gate awareness
# - Use MCP Serena for token-efficient code exploration
# - Receive quality reminders on Write/Edit operations
# - Generate code that passes all quality gates (CCN < 10, duplication < 5%, etc.)
```

### Quality Workflow
```bash
# During development
quality-check         # Run before committing

# Committing
git add .
git commit -m "feat(auth): add JWT refresh"  # Quality gates run automatically
```

## MCP Serena Integration

Claude Code is optimized to use **MCP Serena server** for symbolic code operations:

**Token-Efficient Operations:**
```bash
# Instead of reading entire files (high token usage)
# Claude uses symbolic tools:

mcp__serena__get_symbols_overview    # Get file structure (~200 tokens vs ~2000)
mcp__serena__find_symbol             # Find specific symbols
mcp__serena__replace_symbol_body     # Surgical code edits
mcp__serena__find_referencing_symbols # Impact analysis
```

**Result**: 60-80% token usage reduction for code exploration tasks.

## Quality Gates

Claude Code enforces these thresholds:

| Metric | Threshold | Tool | Enforcement |
|--------|-----------|------|-------------|
| Complexity | CCN < 10 | Lizard | Pre-commit |
| Duplication | < 5% | JSCPD | Pre-commit |
| Security | Zero violations | Semgrep | Pre-commit |
| Secrets | Zero secrets | Gitleaks | Pre-commit |
| Formatting | 100% | Prettier, ESLint, Black, Ruff | Pre-commit |
| Coverage | 75%+ | Vitest, pytest | CI/CD |

## Customization

### Editing CLAUDE.md
```bash
# Customize quality instructions
nano .claude/CLAUDE.md

# Add domain-specific sections
# Update thresholds (must match devenv.nix git hooks)
# Add project-specific patterns
```

### Editing settings.local.json
```bash
# Modify hooks, permissions, environment variables
nano .claude/settings.local.json

# Valid schema: https://json.schemastore.org/claude-code-settings.json
```

### Adding to .claudeignore
```bash
# Exclude additional files from context
echo "*.log" >> .claudeignore
echo "test-data/" >> .claudeignore
```

## Comparison with Cursor AI

This template supports **both Cursor AI and Claude Code** with identical quality gates:

**Cursor AI:**
- Uses `.cursor/rules/*.mdc` (multiple MDC files)
- YOLO mode for advanced capabilities
- Agent mode keyboard shortcuts (Ctrl+I, Ctrl+E)

**Claude Code:**
- Uses `.claude/CLAUDE.md` (single comprehensive file)
- MCP Serena for token-efficient symbolic operations
- Quality hooks on Write/Edit operations
- DevEnv script awareness

**Both enforce:**
- CCN < 10 (complexity)
- < 5% duplication
- Zero secrets
- Zero security violations
- 75%+ test coverage

## Best Practices

**1. Trust the Quality Hooks**
```bash
# When Claude shows: "🔍 Quality Gate: Ensure CCN < 10, duplication < 5%, no secrets"
# This reminder runs before every Write/Edit operation
```

**2. Leverage MCP Serena**
```bash
# Say: "Use symbolic tools to explore auth.ts, then read specific functions"
# Instead of: "Read auth.ts"
# Result: 70% token reduction
```

**3. Run quality-check Before Committing**
```bash
quality-check         # Comprehensive analysis before commit
git commit            # Quality gates enforce automatically
```

**4. Keep CLAUDE.md Updated**
```bash
# When you change quality thresholds in devenv.nix
# Update .claude/CLAUDE.md to match
```

## Troubleshooting

**Claude not respecting quality gates?**
- Check that `.claude/CLAUDE.md` exists and is not empty
- Verify `setup-claude` completed successfully
- Ensure Claude Code reads project-level CLAUDE.md files

**Hooks not executing?**
- Check `.claude/settings.local.json` is valid JSON
- Verify hooks are defined in `settings.local.json`
- Ensure `disableAllHooks` is not set to `true`

**MCP Serena not available?**
- Verify Serena MCP server is configured in global Claude Code settings
- Check `enableAllProjectMcpServers: true` in `settings.local.json`
- Restart Claude Code session

## Resources

- **Template Documentation**: `../README.md`
- **Integration Guide**: `../CLAUDE_CODE_INTEGRATION.md`
- **Main Template Docs**: `../../README.md`
- **Claude Code Docs**: https://docs.claude.com/claude-code
- **MCP Server Docs**: https://modelcontextprotocol.io

---

**Enterprise AI Development with Quality-First Approach**
