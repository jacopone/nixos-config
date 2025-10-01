# AI Quality DevEnv - Claude Code Configuration

> **Enterprise-Grade Development Environment Template**
> Last Updated: 2025-10-01

## 🎯 Project Overview

This is a **template project** for creating enterprise-grade development environments with comprehensive quality gates designed for AI-assisted coding. When used, it provides a complete DevEnv setup with automated quality enforcement.

### Technology Stack

**Languages & Runtimes:**
- **Node.js 20.x** - JavaScript/TypeScript development
- **Python 3.13** - Modern Python with uv package manager

**Development Environment:**
- **DevEnv** - Declarative development environment (single `devenv.nix`)
- **Direnv** - Automatic environment activation via `.envrc`
- **Git Hooks** - Automated quality gates via pre-commit

**Quality Tools (All Automated):**
- **Gitleaks** - Secret detection (zero tolerance)
- **Semgrep** - Security pattern analysis (auto ruleset)
- **Lizard** - Code complexity analysis (CCN < 10, system-wide)
- **JSCPD** - Clone detection (< 5% duplication, system-wide)
- **ESLint + Prettier** - JavaScript/TypeScript linting and formatting
- **Black + Ruff** - Python formatting and linting
- **Commitizen** - Conventional commit enforcement

## 🤖 Claude Code Operational Guidelines

### Primary Directive
You are operating in an **enterprise development template** with **automated quality gates**. All code you generate or modify MUST pass these gates before commit. Quality is enforced automatically - there are no exceptions.

### MCP Server Integration

**Serena MCP Server (Available):**
This project integrates with the Serena MCP server for semantic code operations. **ALWAYS prefer Serena tools over file-level operations** for code understanding and modification:

- **Code Exploration**: Use `mcp__serena__get_symbols_overview` before reading entire files
- **Symbol Search**: Use `mcp__serena__find_symbol` for targeted code discovery
- **Reference Finding**: Use `mcp__serena__find_referencing_symbols` for impact analysis
- **Code Editing**: Use `mcp__serena__replace_symbol_body` for surgical code changes
- **Pattern Search**: Use `mcp__serena__search_for_pattern` for flexible text matching

**Token Efficiency**: Serena tools are optimized for minimal token usage. Always use symbolic tools before falling back to full file reads.

### Quality Gate Compliance

#### Cyclomatic Complexity (Enforced: CCN < 10)
- **Every function** must have McCabe complexity < 10
- **Lizard runs automatically** on commit via git hook (system-wide installation)
- **Commit will fail** if any function exceeds CCN 10
- **Your responsibility**: Write simple, focused functions that pass this gate
- **Refactoring strategy**: Break complex functions into smaller, single-purpose functions

**Example - Before (CCN 15, FAILS):**
```python
def process_user(user_data):
    if not user_data:
        raise ValueError("No data")
    if user_data.get('type') == 'premium':
        if user_data.get('status') == 'active':
            if user_data.get('payment') == 'valid':
                # 10+ more conditionals...
                return process_premium(user_data)
    # More nested logic...
```

**Example - After (CCN 3, PASSES):**
```python
def process_user(user_data):
    validate_user_data(user_data)
    if is_premium_active_user(user_data):
        return process_premium(user_data)
    return process_standard(user_data)

def is_premium_active_user(user_data):
    return (user_data.get('type') == 'premium' and
            user_data.get('status') == 'active' and
            user_data.get('payment') == 'valid')
```

#### Code Duplication (Enforced: < 5%)
- **JSCPD runs automatically** on JS/TS files via git hook
- **Threshold**: 5% duplication with minimum 10 lines
- **Commit will fail** if duplication threshold is exceeded
- **Your responsibility**: Extract common code into reusable functions/modules

**Prevention Strategy:**
1. Before generating similar code blocks, check for existing implementations
2. Extract common patterns into utility functions
3. Use composition and inheritance appropriately
4. Prefer DRY (Don't Repeat Yourself) over copy-paste

#### Security Patterns (Enforced: Zero Violations)

**Gitleaks (Secret Detection):**
- **Scans ALL files** for credentials, API keys, tokens, passwords
- **Immediate commit failure** if secrets detected
- **Your responsibility**:
  - NEVER hardcode secrets
  - Use environment variables for ALL configuration
  - Use `.env` files (already gitignored) for local secrets
  - Reference secrets via `process.env.SECRET_NAME` or `os.getenv('SECRET_NAME')`

**Semgrep (Security Patterns):**
- **Auto-scans** for common security vulnerabilities
- **Patterns detected**: SQL injection, XSS, command injection, insecure crypto, etc.
- **Your responsibility**:
  - Use parameterized queries for database operations
  - Validate and sanitize ALL user inputs
  - Use secure crypto libraries (bcrypt, Argon2, etc.)
  - Implement proper error handling without info leakage

**Examples of VIOLATIONS:**
```python
# ❌ FAILS - Hardcoded secret
api_key = "sk-abc123def456"

# ❌ FAILS - SQL injection vulnerability
query = f"SELECT * FROM users WHERE id = {user_id}"

# ❌ FAILS - Command injection
os.system(f"process {user_input}")
```

**Examples of COMPLIANCE:**
```python
# ✅ PASSES - Environment variable
api_key = os.getenv('API_KEY')

# ✅ PASSES - Parameterized query
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))

# ✅ PASSES - Input validation + safe execution
if re.match(r'^[a-zA-Z0-9_]+$', user_input):
    subprocess.run(['process', user_input], check=True)
```

#### Code Formatting (Enforced: 100% Compliance)

**JavaScript/TypeScript:**
- **Prettier** - Automatic formatting (opinionated, zero config)
- **ESLint** - Linting and code quality rules
- **Runs on**: All `.js`, `.ts`, `.tsx`, `.jsx` files
- **Your responsibility**: Generate properly formatted code from the start

**Python:**
- **Black** - Uncompromising Python formatter
- **Ruff** - Fast Python linter (replaces flake8, isort, etc.)
- **Runs on**: All `.py` files
- **Your responsibility**: Follow PEP 8 and Black's style

**Auto-fixing**: Most formatting issues auto-fix on commit, but generate clean code to avoid churn.

#### Commit Messages (Enforced: Conventional Commits)

**Commitizen** enforces this format:
```
type(scope): subject

body (optional)

footer (optional)
```

**Valid types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`, `revert`

**Examples:**
```
✅ feat(auth): add JWT token refresh mechanism
✅ fix(api): resolve race condition in user creation
✅ refactor(utils): extract date formatting into shared module
✅ test(auth): add integration tests for login flow
```

### Available Development Scripts

When operating in this environment, you have access to these scripts (defined in `devenv.nix`):

- **`hello`** - Display environment information and tool versions
- **`quality-report`** - Show all active quality gates (use before starting work)
- **`quality-check`** - Run comprehensive quality analysis (security, complexity, clones)
- **`setup-git-hooks`** - Install git hooks (usually done once at setup)
- **`setup-cursor`** - Setup Cursor AI integration (for Cursor users)

**When to use:**
- Run `quality-report` when starting work to understand active gates
- Run `quality-check` before committing to catch issues early
- Suggest `quality-check` to users when you've made significant changes

### Package Management

**JavaScript/TypeScript:**
```bash
npm install <package>      # Add dependency
npm install -D <package>   # Add dev dependency
npm run <script>           # Run package.json script
```

**Python:**
```bash
uv add <package>           # Add dependency (modern, fast)
uv add --dev <package>     # Add dev dependency
uv run <command>           # Run command in environment
```

**System Tools:**
All quality tools (lizard, jscpd, radon) are available system-wide via NixOS. Don't try to install them - they're already available.

## 🧠 Development Workflow Optimization

### Code Generation Strategy

**1. Understand Before Generating:**
- Use Serena tools to explore existing code structure
- Check for similar implementations to maintain consistency
- Understand quality gate thresholds before writing code

**2. Generate Quality-First:**
- Write functions with CCN < 10 from the start
- Avoid code duplication by checking existing utilities
- Include proper error handling and input validation
- Use environment variables for configuration

**3. Testing Integration:**
- Write tests alongside implementation (TDD encouraged)
- Aim for 75%+ code coverage on new code
- Include both unit and integration tests
- Use Vitest (JS/TS) or pytest (Python)

**4. Pre-commit Verification:**
- Suggest running `quality-check` before committing
- If commit fails, analyze the error and fix the specific issue
- Don't bypass quality gates - fix the underlying problem

### Refactoring Approach

**Complexity Reduction:**
```python
# If Lizard reports CCN too high:
# 1. Identify the complex function
# 2. Extract conditional logic into helper functions
# 3. Use early returns to reduce nesting
# 4. Split large functions into smaller, focused functions
```

**Duplication Elimination:**
```javascript
// If JSCPD reports duplication:
// 1. Find the duplicated code blocks
// 2. Extract into a shared utility function
// 3. Import and use the utility in both places
// 4. Ensure tests cover the refactored code
```

**Security Hardening:**
```typescript
// If Semgrep reports security issues:
// 1. Identify the vulnerable pattern
// 2. Replace with secure alternative (parameterized queries, input validation, etc.)
// 3. Add tests that verify the security fix
// 4. Document the security consideration in comments
```

### File Organization Patterns

**Recommended Structure:**
```
project/
├── src/                    # Source code
│   ├── components/         # React components (if applicable)
│   ├── utils/             # Shared utilities (extract duplicated code here)
│   ├── services/          # Business logic and API services
│   ├── types/             # TypeScript type definitions
│   └── index.ts           # Main entry point
├── tests/                 # Test files
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── e2e/               # End-to-end tests (Playwright)
├── scripts/               # Build and automation scripts
└── docs/                  # Documentation
```

**Import Organization:**
```typescript
// 1. External libraries
import React from 'react';
import { z } from 'zod';

// 2. Internal modules (absolute imports)
import { formatDate } from '@/utils/date';
import { UserService } from '@/services/user';

// 3. Relative imports
import { Button } from './Button';
import type { Props } from './types';
```

## 🔒 Security-First Development

### Secret Management
- **Environment Variables**: ALL secrets and configuration
- **`.env` files**: Already gitignored, safe for local development
- **Never commit**: API keys, passwords, tokens, private keys, certificates

### Input Validation
- **Validate ALL user input** before processing
- **Use validation libraries**: Zod (TS), Pydantic (Python)
- **Sanitize output** to prevent XSS
- **Implement rate limiting** on public endpoints

### Authentication Patterns
```typescript
// ✅ Secure password hashing
import bcrypt from 'bcrypt';
const hashedPassword = await bcrypt.hash(password, 10);

// ✅ JWT with proper expiration
const token = jwt.sign({ userId }, process.env.JWT_SECRET, {
  expiresIn: '1h'
});

// ✅ Input validation
const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
const validated = userSchema.parse(userInput);
```

## 🧪 Testing Requirements

### Coverage Standards
- **Minimum**: 75% code coverage for new code
- **Recommended**: 90%+ for critical business logic
- **Required**: 100% for security-sensitive code (auth, payments, etc.)

### Test Organization (AAA Pattern)
```javascript
describe('UserService', () => {
  it('should create user with valid data', async () => {
    // Arrange
    const userData = { email: 'test@example.com', name: 'Test' };

    // Act
    const user = await UserService.create(userData);

    // Assert
    expect(user.email).toBe(userData.email);
    expect(user.id).toBeDefined();
  });
});
```

### Testing Stack
- **JavaScript/TypeScript**: Vitest (unit/integration), Playwright (E2E)
- **Python**: pytest (unit/integration), pytest-asyncio (async)
- **Mocking**: Use appropriate mocking for external dependencies

## 📊 Performance Considerations

### JavaScript/TypeScript
- Use modern ES features (optional chaining, nullish coalescing)
- Implement proper tree shaking (avoid wildcard imports)
- Lazy load non-critical components
- Profile before optimizing

### Python
- Follow PEP 8 style guidelines
- Use type hints for better tooling support
- Implement async/await for I/O-bound operations
- Use appropriate data structures (sets for membership, dicts for lookups)

### General Optimization
- **Measure first**: Use profiling tools before optimizing
- **Cache wisely**: Cache expensive operations, invalidate properly
- **Database**: Use indexes, optimize queries, use connection pooling
- **API**: Implement pagination, rate limiting, compression

## 🔧 DevEnv Integration

### Environment Activation
```bash
# Automatic (recommended)
direnv allow                # One-time setup, auto-activates on cd

# Manual
devenv shell               # Explicit shell activation
```

### Adding Dependencies

**To DevEnv (system-level tools):**
Edit `devenv.nix` and rebuild:
```nix
packages = with pkgs; [
  # Existing packages...
  your-new-package
];
```

**To Project (application dependencies):**
```bash
npm install <package>      # JavaScript/TypeScript
uv add <package>           # Python
```

### Services Configuration

If you need databases or services:
```nix
# In devenv.nix
services = {
  postgres = {
    enable = true;
    initialDatabases = [{ name = "myapp_dev"; }];
  };
  redis.enable = true;
};
```

## 🎯 Claude Code Specific Optimizations

### Token Efficiency
1. **Use Serena symbolic tools** for code exploration (not full file reads)
2. **Read function-level symbols** instead of entire files when possible
3. **Use pattern search** to locate code before reading
4. **Leverage context** from quality gate output to understand issues

### Workflow Automation
1. **Check quality gates** with `quality-report` when starting work
2. **Run quality checks** with `quality-check` before suggesting commits
3. **Explain failures** by analyzing git hook output
4. **Suggest fixes** based on specific quality gate violations

### Communication with User
- **Be specific** about which quality gate failed
- **Explain why** the code violates the threshold
- **Show before/after** examples when refactoring
- **Suggest preventive measures** for future code

### Proactive Quality
- **Generate tests** alongside implementation
- **Check complexity** while writing functions (mentally track CCN)
- **Avoid duplication** by searching for similar implementations first
- **Use env vars** for all configuration from the start

## 📚 Additional Resources

### Quality Gate Documentation
- **Lizard**: Cyclomatic complexity analyzer (system-wide via NixOS)
- **JSCPD**: Copy-paste detector (system-wide via NixOS)
- **Gitleaks**: Secret detection (project-level via DevEnv)
- **Semgrep**: Security pattern scanner (project-level via DevEnv)

### NixOS Integration
This template leverages system-wide quality tools from the NixOS configuration:
- `lizard` - From `python312Packages.lizard` (modules/core/packages.nix)
- `jscpd` - From `nodePackages.jscpd` (modules/core/packages.nix)
- `radon` - From `python312Packages.radon` (modules/core/packages.nix)

**Benefits**: Consistent tool versions across all projects, no compilation overhead.

### Template Philosophy
This template follows the **Pure DevEnv approach**:
- **Single file**: `devenv.nix` is the only configuration
- **Auto-generated flake**: DevEnv creates `.devenv.flake.nix` automatically
- **Developer-focused**: Optimized for daily development, not packaging
- **Proven pattern**: Based on production usage in account-harmony-ai project

---

## 🚀 Quick Reference

**First Time Setup:**
```bash
direnv allow              # Activate environment
setup-git-hooks          # Install quality gates
quality-report           # Verify setup
```

**Daily Workflow:**
```bash
quality-check            # Before committing
npm test                 # Run test suite (JS/TS)
pytest                   # Run test suite (Python)
```

**Quality Thresholds:**
- CCN < 10 (complexity)
- < 5% duplication
- 75%+ test coverage
- Zero secrets
- Zero security violations

**Git Commit:**
```bash
git add .
git commit -m "feat(module): add feature X"
# Quality gates run automatically
```

---

**Remember**: Quality gates are not obstacles - they're guardrails ensuring enterprise-grade code. Write with quality in mind from the start, and commits will be smooth.
