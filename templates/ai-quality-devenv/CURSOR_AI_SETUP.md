# Cursor AI Setup Guide

**Enterprise AI Development with Quality Gate Awareness**

## Overview

This guide explains how to set up and use Cursor AI with the AI Quality DevEnv template. The integration provides comprehensive quality gate awareness through MDC rule files, YOLO mode for advanced capabilities, and agent mode shortcuts for efficient development.

## Quick Setup

```bash
# Enter development environment
devenv shell

# Run setup script
setup-cursor

# Verify configuration
ls -la .cursor/
```

## What Gets Configured

### 1. `.cursor/rules/` Directory (MDC Rule Files)

Three specialized rule files using Cursor's MDC format:

**`index.mdc` (Core Development Rules)**
- Code quality standards (CCN < 10, < 5% duplication)
- Technology stack integration (Node 20, Python 3.13, DevEnv)
- AI workflow optimization
- Security-first development patterns
- Testing requirements (75%+ coverage)

**`security.mdc` (Security-Focused Rules)**
- Secret detection patterns
- Input validation requirements
- Authentication/authorization best practices
- Secure coding standards

**`testing.mdc` (Testing & QA Rules)**
- AAA pattern (Arrange, Act, Assert)
- Test coverage requirements
- Mocking and stubbing guidelines
- Integration test patterns

### 2. `.cursorignore`

Excludes from context:
- Build artifacts (`dist/`, `build/`, `*.pyc`)
- Dependencies (`node_modules/`, `.venv/`, `__pycache__/`)
- IDE configs (`.vscode/`, `.idea/`)
- DevEnv internals (`.devenv/`, `result`)

## Key Features

### MDC Rule System (2025 Format)

Cursor AI uses MDC (Markdown with YAML frontmatter) for rules:

```markdown
---
description: Rule description
globs:
  - "**/*.ts"
  - "**/*.js"
alwaysApply: true
---

# Rule content in markdown
```

**Benefits:**
- File-type targeting with glob patterns
- Selective rule activation with `alwaysApply`
- Organized by concern (core, security, testing)
- Easy to customize per project

### Quality Gate Awareness

Cursor understands all quality thresholds:

| Quality Gate | Threshold | Cursor Knows |
|--------------|-----------|--------------|
| Cyclomatic Complexity | CCN < 10 | ✅ Via index.mdc |
| Code Duplication | < 5% | ✅ Via index.mdc |
| Security Patterns | Zero violations | ✅ Via security.mdc |
| Secret Detection | Zero secrets | ✅ Via security.mdc |
| Code Formatting | 100% | ✅ Via index.mdc |
| Test Coverage | 75%+ | ✅ Via testing.mdc |

### YOLO Mode

Advanced AI capabilities with build/test execution:

**Configuration** (set in Cursor settings):
```json
{
  "cursor.aiMode": "yolo",
  "cursor.autoTest": true,
  "cursor.autoBuild": true
}
```

**Capabilities:**
- Automatically run tests after code changes
- Execute build scripts and catch errors
- More aggressive autonomous operations
- Faster iteration cycles

### Agent Mode Shortcuts

Integrated keyboard shortcuts for efficient workflow:

- **`Ctrl+I`**: Agent mode (interactive chat with context)
- **`Ctrl+E`**: Background agent (autonomous execution)

## Usage Examples

### Example 1: Feature Development

```bash
# Start Cursor IDE
cursor .

# User types in agent mode (Ctrl+I):
# "Add user registration endpoint with JWT authentication"

# Cursor AI:
# 1. Checks index.mdc for quality requirements
# 2. References security.mdc for auth patterns
# 3. Uses testing.mdc for test structure
# 4. Generates code with CCN < 10, 75%+ test coverage
# 5. Follows security best practices from security.mdc

# Verify quality
quality-check

# Commit (quality gates enforce automatically)
git add .
git commit -m "feat(auth): add user registration endpoint"
```

### Example 2: Legacy Code Refactoring

```bash
# Open Cursor IDE
cursor .

# User: "Refactor this complex function to pass quality gates"
# (Select complex function in editor, press Ctrl+I)

# Cursor AI:
# 1. Analyzes current complexity (CCN 15)
# 2. References index.mdc refactoring guidelines
# 3. Extracts helper functions to reduce complexity
# 4. Results in CCN 7 (passes threshold)
# 5. Updates tests per testing.mdc guidelines

# Validate
quality-check
```

### Example 3: YOLO Mode Autonomous Development

```bash
# Enable YOLO mode in Cursor settings

# User: "Add payment processing endpoint with Stripe integration"
# (Press Ctrl+E for background agent)

# Cursor AI (YOLO mode):
# 1. Generates endpoint code
# 2. Writes tests automatically
# 3. Runs tests in background
# 4. If tests fail, auto-corrects
# 5. Runs quality-check
# 6. Reports completion when all gates pass
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

**After (CCN 3, PASSES)** - Cursor AI refactors:
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

### Security Patterns

**Violation** (security.mdc catches):
```javascript
const API_KEY = "sk-1234567890abcdef";  // ❌ Hardcoded secret
```

**Compliance** (Cursor suggests):
```javascript
const API_KEY = process.env.API_KEY;  // ✅ Environment variable
if (!API_KEY) throw new Error("API_KEY not configured");
```

### Testing Requirements (testing.mdc)

**Cursor generates tests following AAA pattern:**
```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { name: 'John', email: 'john@example.com' };
      const mockRepository = { save: jest.fn() };
      const service = new UserService(mockRepository);

      // Act
      const result = await service.createUser(userData);

      // Assert
      expect(mockRepository.save).toHaveBeenCalledWith(userData);
      expect(result).toHaveProperty('id');
    });
  });
});
```

## Configuration Details

### MDC Rule Structure

**index.mdc (Core Rules)**:
```markdown
---
description: AI Quality DevEnv - Enterprise Development Rules
globs:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
alwaysApply: true
---

# AI Quality DevEnv Rules

You are an expert AI assistant working in an enterprise-grade development environment...

## Code Quality Standards
- Keep cyclomatic complexity below 10 per function
- Maximum function length: 50 lines
- Avoid code duplication above 5% threshold
```

**security.mdc (Security Rules)**:
```markdown
---
description: Security-first development patterns
globs:
  - "**/*.ts"
  - "**/*.js"
  - "**/*.py"
alwaysApply: true
---

# Security-First Development

## Authentication & Authorization
- Never hardcode credentials
- Use environment variables for secrets
- Implement proper session management
```

### Cursor Settings Integration

**Recommended Cursor settings.json:**
```json
{
  "cursor.aiMode": "yolo",
  "cursor.autoTest": true,
  "cursor.autoBuild": true,
  "cursor.agentShortcuts": {
    "interactive": "Ctrl+I",
    "background": "Ctrl+E"
  },
  "cursor.rules": {
    "enabled": true,
    "directory": ".cursor/rules"
  },
  "cursor.models": {
    "primary": "claude-3.5-sonnet",
    "secondary": "gpt-4o"
  }
}
```

## Comparison with Claude Code

| Feature | Cursor AI | Claude Code |
|---------|-----------|-------------|
| **Configuration** | Multiple `.mdc` files | Single `CLAUDE.md` |
| **Quality Awareness** | Via MDC rules | Comprehensive examples |
| **Agent Mode** | UI-based (Ctrl+I) | CLI-based |
| **YOLO Mode** | ✅ Advanced capabilities | N/A |
| **Token Efficiency** | Standard file reads | MCP Serena symbolic ops |
| **UI Integration** | Full IDE integration | Terminal-based |
| **Keyboard Shortcuts** | ✅ Ctrl+I, Ctrl+E | N/A |

**Both systems enforce identical quality gates** - choice is based on preference and workflow.

## Best Practices

### 1. Run Setup Immediately

```bash
setup-cursor
quality-report  # Understand active quality gates
```

### 2. Leverage Agent Mode

Use keyboard shortcuts for efficiency:
```
Ctrl+I: Interactive agent (for planning, questions)
Ctrl+E: Background agent (for autonomous execution)
```

### 3. Enable YOLO Mode for Iteration

For rapid prototyping:
```json
{
  "cursor.aiMode": "yolo",
  "cursor.autoTest": true
}
```

Cursor will automatically test and fix issues.

### 4. Run Quality Check Before Committing

```bash
quality-check         # Comprehensive analysis
git commit            # Quality gates enforce automatically
```

### 5. Customize Rules for Your Project

```bash
# Edit core rules
nano .cursor/rules/index.mdc

# Add project-specific rules
touch .cursor/rules/database.mdc
```

## Troubleshooting

### Issue: Rules not applying

**Solution**: Verify MDC frontmatter:
```bash
head -15 .cursor/rules/index.mdc
# Should show YAML frontmatter with alwaysApply: true
```

### Issue: YOLO mode too aggressive

**Solution**: Reduce aggressiveness in settings:
```json
{
  "cursor.aiMode": "standard",
  "cursor.autoTest": false
}
```

### Issue: Cursor not following quality thresholds

**Solution**: Check rule files exist:
```bash
ls -la .cursor/rules/
# Should show index.mdc, security.mdc, testing.mdc
```

### Issue: Commit rejected by quality gates

**Solution**: Run quality check first:
```bash
quality-check
# Fix reported issues
git add .
git commit -m "fix: address quality gate failures"
```

## Advanced Configuration

### Custom Complexity Target

Edit `.cursor/rules/index.mdc`:
```markdown
### Complexity Management
- Keep cyclomatic complexity below 8 per function  # Stricter than default 10
- Maximum function length: 40 lines  # Stricter than default 50
```

### Language-Specific Rules

Create language-specific MDC files:

**`.cursor/rules/python.mdc`:**
```markdown
---
description: Python-specific guidelines
globs:
  - "**/*.py"
alwaysApply: true
---

# Python Best Practices

- Always use type hints for function signatures
- Prefer dataclasses over dictionaries
- Follow PEP 8 naming conventions
- Use context managers for resource management
```

**`.cursor/rules/typescript.mdc`:**
```markdown
---
description: TypeScript-specific guidelines
globs:
  - "**/*.ts"
  - "**/*.tsx"
alwaysApply: true
---

# TypeScript Best Practices

- Always use strict mode
- Prefer interfaces over types for object shapes
- Use discriminated unions for state management
- Avoid `any` type - use `unknown` instead
```

### Glob Pattern Targeting

Target specific directories:

```markdown
---
description: Backend API rules
globs:
  - "src/api/**/*.ts"
  - "src/services/**/*.ts"
alwaysApply: true
---
```

## Integration with Autonomous Remediation

Cursor AI works seamlessly with autonomous remediation:

```bash
# Initialize remediation
assess-codebase
initialize-remediation-state

# Start autonomous session
autonomous-remediation-session

# Use Cursor Agent Mode (Ctrl+E) to:
# 1. Load targets from remediation state
# 2. Refactor to meet quality thresholds
# 3. Validate improvements automatically
# 4. Checkpoint progress
```

See **AUTONOMOUS_REMEDIATION.md** for details.

## Related Documentation

- **README.md** - Template overview and quick start
- **INIT_AI_TOOLS_GUIDE.md** - Interactive setup with both AI tools
- **CLAUDE_CODE_SETUP.md** - Alternative AI system setup
- **AUTONOMOUS_REMEDIATION.md** - Autonomous refactoring system
- **QUALITY_BASELINE_GATES.md** - Quality thresholds and gated workflow
- **LEGACY_CODEBASE_RESCUE.md** - 8-step assessment and rescue system

## Support

For issues or questions:
1. Review `.cursor/rules/*.mdc` for rule configuration
2. Check `quality-report` for active quality gates
3. Run `quality-check` to identify specific issues
4. Consult related documentation above

---

**Setup Version**: 1.0
**Last Updated**: October 2025
**Cursor AI Compatibility**: 2025+ (MDC format)
**Quality Gates**: Identical to Claude Code setup
