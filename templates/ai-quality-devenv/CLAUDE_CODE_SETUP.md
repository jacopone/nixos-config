# Claude Code Setup Guide

**Enterprise AI Development with Quality Gate Awareness**

## Overview

This guide explains how to set up and use Claude Code with the AI Quality DevEnv template. The integration provides comprehensive quality gate awareness, MCP Serena optimization for token efficiency, and automatic quality reminders during development.

## Quick Setup

```bash
# Enter development environment
devenv shell

# Run setup script
setup-claude

# Verify configuration
ls -la .claude/
```

## What Gets Configured

### 1. `.claude/CLAUDE.md` (6KB Instructions)

Comprehensive project-level instructions including:
- **Quality Gate Compliance** - Detailed guidance for CCN < 10, duplication < 5%, zero secrets
- **MCP Serena Integration** - Symbolic code operation optimization
- **DevEnv Context** - All available scripts (quality-check, assess-codebase, etc.)
- **Code Examples** - Before/after examples for each quality threshold
- **Testing Standards** - 75%+ coverage requirements, AAA pattern

### 2. `.claude/settings.local.json`

Claude Code settings with:
- **Quality Hooks** - Automatic reminders before Write/Edit operations
- **Environment Variables** - Quality mode indicators (CLAUDE_QUALITY_MODE=enterprise)
- **MCP Auto-Enable** - Automatically approve project MCP servers
- **Co-Authoring** - Include Claude attribution in commits

### 3. `.claudeignore`

Excludes from context:
- Build artifacts (`dist/`, `build/`, `*.pyc`)
- Dependencies (`node_modules/`, `.venv/`, `__pycache__/`)
- IDE configs (`.vscode/`, `.idea/`)
- DevEnv internals (`.devenv/`, `result`)

## Key Features

### Quality Gate Awareness

Claude understands all quality thresholds:

| Quality Gate | Threshold | Claude Knows |
|--------------|-----------|--------------|
| Cyclomatic Complexity | CCN < 10 | ✅ With refactoring examples |
| Code Duplication | < 5% | ✅ With prevention strategies |
| Security Patterns | Zero violations | ✅ With Semgrep/Gitleaks awareness |
| Secret Detection | Zero secrets | ✅ With env var patterns |
| Code Formatting | 100% | ✅ Prettier, ESLint, Black, Ruff |
| Test Coverage | 75%+ | ✅ AAA pattern, mocking examples |

### MCP Serena Optimization

Claude uses symbolic tools instead of reading entire files:

**Traditional Approach** (High Token Usage):
```
User: "Find the authentication logic"
Claude: [Reads entire auth.ts - 500 lines, ~2000 tokens]
```

**MCP Serena Approach** (70% Token Reduction):
```
User: "Find the authentication logic"
Claude:
  1. mcp__serena__get_symbols_overview(auth.ts) [~200 tokens]
  2. mcp__serena__find_symbol("AuthService") [~100 tokens]
  3. mcp__serena__find_symbol("AuthService/login", include_body=true) [~300 tokens]
     Total: ~600 tokens (70% reduction)
```

### Quality Hooks

Automatic reminders during development:

**Before Write/Edit**:
```
🔍 Quality Gate: Ensure CCN < 10, duplication < 5%, no secrets
```

**After Write/Edit**:
```
✅ File modified - run quality-check before committing
```

### DevEnv Script Awareness

Claude knows about all available scripts:

```markdown
### Available Development Scripts
- `quality-report` - Show all active quality gates
- `quality-check` - Run comprehensive quality analysis
- `assess-codebase` - 8-step quality assessment
- `autonomous-remediation-session` - Supervised autonomous refactoring
- `generate-progress-report` - Stakeholder reporting
```

## Usage Examples

### Example 1: Feature Development

```bash
# Start Claude Code
claude-code .

# User: "Add user registration endpoint"
# Claude:
# 1. Checks CLAUDE.md for quality requirements
# 2. Receives quality hook reminder
# 3. Generates code with CCN < 10, 75%+ test coverage
# 4. Suggests: "Run quality-check before committing"

# Verify quality
quality-check

# Commit (quality gates enforce automatically)
git add .
git commit -m "feat(auth): add user registration endpoint"
```

### Example 2: Legacy Code Refactoring

```bash
# User: "Refactor this complex function to pass quality gates"
# Claude:
# 1. Analyzes current complexity (CCN 15)
# 2. Uses MCP Serena to understand dependencies
# 3. Refactors with extracted helper functions
# 4. Results in CCN 7 (passes threshold)
# 5. Ensures tests still pass

# Validate
quality-check
```

### Example 3: Code Exploration

```bash
# User: "Understand the payment processing flow"
# Claude:
# 1. Uses mcp__serena__get_symbols_overview(payment.ts)
# 2. Identifies PaymentService class
# 3. Uses mcp__serena__find_symbol("PaymentService", depth=1)
# 4. Reads only relevant methods with include_body=true
# 5. Provides summary without reading entire file
```

## Quality Gate Compliance Examples

### Cyclomatic Complexity (CCN < 10)

**Before (CCN 15, FAILS)**:
```javascript
function processOrder(order) {
  if (order.type === 'express') {
    if (order.value > 100) {
      if (order.customer.isPremium) {
        if (order.items.length > 5) {
          // ... nested logic
        }
      }
    }
  }
  // More nested conditionals...
}
```

**After (CCN 3, PASSES)**:
```javascript
function processOrder(order) {
  const handler = getOrderHandler(order);
  return handler.process(order);
}

function getOrderHandler(order) {
  if (order.type === 'express') return new ExpressOrderHandler();
  return new StandardOrderHandler();
}

class ExpressOrderHandler {
  process(order) {
    if (this.shouldApplyPremiumDiscount(order)) {
      return this.processPremiumOrder(order);
    }
    return this.processStandardOrder(order);
  }
}
```

### Code Duplication (< 5%)

**Prevention Strategies Claude Uses**:
1. Extract common logic into utility functions
2. Use composition over inheritance
3. Create reusable components/modules
4. Apply DRY principle systematically

### Security Patterns

**Violation**:
```javascript
const API_KEY = "sk-1234567890abcdef";  // ❌ Hardcoded secret
```

**Compliance**:
```javascript
const API_KEY = process.env.API_KEY;  // ✅ Environment variable
if (!API_KEY) throw new Error("API_KEY not configured");
```

## Configuration Details

### Environment Variables

Set in `.claude/settings.local.json`:

```json
"env": {
  "CLAUDE_QUALITY_MODE": "enterprise",
  "CLAUDE_COMPLEXITY_TARGET": "8",
  "CLAUDE_MIN_COVERAGE": "75"
}
```

Claude references these when generating code.

### Hook Configuration

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "echo '🔍 Quality Gate: Ensure CCN < 10, duplication < 5%, no secrets'"
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "echo '✅ File modified - run quality-check before committing'"
        }
      ]
    }
  ]
}
```

### MCP Server Integration

```json
"enableAllProjectMcpServers": true
```

This automatically enables MCP Serena (and other project-level MCP servers) without manual approval.

## Comparison with Cursor AI

| Feature | Cursor AI | Claude Code |
|---------|-----------|-------------|
| **Configuration** | Multiple `.mdc` files | Single `CLAUDE.md` |
| **Token Efficiency** | Standard file reads | MCP Serena symbolic ops |
| **Quality Hooks** | Rule-based | Pre/Post tool hooks |
| **Agent Mode** | UI-based (Ctrl+I) | CLI-based |
| **MCP Support** | Limited | Full integration |
| **Quality Awareness** | Via rules | Comprehensive examples |

**Both systems enforce identical quality gates** - choice is based on preference and workflow.

## Best Practices

### 1. Run Setup Immediately

```bash
setup-claude
quality-report  # Understand active quality gates
```

### 2. Leverage MCP Serena

Instead of:
```
"Read auth.ts"
```

Say:
```
"Use symbolic tools to explore auth.ts structure, then read specific functions"
```

### 3. Trust Quality Hooks

When you see quality reminders, Claude is being reminded to check thresholds before writing code.

### 4. Run Quality Check Before Committing

```bash
quality-check         # Comprehensive analysis
git commit            # Quality gates enforce automatically
```

### 5. Review Generated Code

Even with quality awareness, review:
- Test coverage completeness
- Edge case handling
- Security considerations
- Performance implications

## Troubleshooting

### Issue: Quality hooks not appearing

**Solution**: Verify `.claude/settings.local.json` exists and hooks are configured:
```bash
cat .claude/settings.local.json | jq '.hooks'
```

### Issue: MCP Serena not available

**Solution**: Check MCP server configuration in Claude Code settings. Serena should be enabled for project.

### Issue: Claude not following quality thresholds

**Solution**: Verify `.claude/CLAUDE.md` exists:
```bash
cat .claude/CLAUDE.md | grep "Cyclomatic Complexity"
```

### Issue: Commit rejected by quality gates

**Solution**: Run quality check first to identify issues:
```bash
quality-check
# Fix reported issues
git add .
git commit -m "fix: address quality gate failures"
```

## Advanced Configuration

### Custom Complexity Target

Edit `.claude/settings.local.json`:
```json
"env": {
  "CLAUDE_COMPLEXITY_TARGET": "6"  // Stricter than default 8
}
```

### Additional Quality Hooks

Add custom reminders:
```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Write.*\\.test\\.",
      "hooks": [
        {
          "type": "command",
          "command": "echo '🧪 Reminder: Use AAA pattern (Arrange, Act, Assert)'"
        }
      ]
    }
  ]
}
```

### Language-Specific Guidelines

Edit `.claude/CLAUDE.md` to add project-specific patterns:
```markdown
## Project-Specific Patterns

### TypeScript
- Always use strict mode
- Prefer interfaces over types for object shapes
- Use discriminated unions for state management

### Python
- Use type hints for all function signatures
- Prefer dataclasses over dictionaries
- Follow PEP 8 naming conventions
```

## Integration with Autonomous Remediation

Claude Code works seamlessly with autonomous remediation:

```bash
# Initialize remediation
assess-codebase
initialize-remediation-state

# Start autonomous session with Claude
autonomous-remediation-session

# Claude Code will:
# 1. Load targets from remediation state
# 2. Use MCP Serena to understand context
# 3. Refactor to meet quality thresholds
# 4. Validate improvements automatically
# 5. Checkpoint progress
```

See **AUTONOMOUS_REMEDIATION.md** for details.

## Related Documentation

- **README.md** - Template overview and quick start
- **AUTONOMOUS_REMEDIATION.md** - Autonomous refactoring system
- **QUALITY_BASELINE_GATES.md** - Quality thresholds and gated workflow
- **LEGACY_CODEBASE_RESCUE.md** - 8-step assessment and rescue system

## Support

For issues or questions:
1. Review `.claude/CLAUDE.md` for comprehensive guidance
2. Check `quality-report` for active quality gates
3. Run `quality-check` to identify specific issues
4. Consult related documentation above

---

**Setup Version**: 1.0
**Last Updated**: October 2025
**Claude Code Compatibility**: October 2025+
**MCP Server**: Serena (symbolic code operations)
