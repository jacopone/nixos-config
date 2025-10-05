# AI Quality DevEnv Template

Development environment with automated quality gates for AI-assisted coding.

## Features

### 🔒 Security & Quality Gates
- **Gitleaks**: Secret detection and prevention
- **Semgrep**: Pattern-based security and code quality scanning
- **Lizard**: Code complexity analysis (CCN < 10) - *Available system-wide*
- **JSCPD**: Clone detection via npx wrapper (threshold 5%) - *Available system-wide*
- **Markdownlint**: Documentation linting
- **ls-lint**: File and folder naming convention validation
- **Commitizen-go**: Conventional commit format enforcement

### 🛠️ Development Tools
- **Node.js 20**: JavaScript/TypeScript runtime
- **Python 3.13**: Python runtime with uv package manager
- **ESLint + Prettier**: JavaScript/TypeScript formatting
- **Black + Ruff**: Python formatting and linting

### 📚 Documentation Tools
- **JSDoc**: JavaScript API documentation generation
- **Sphinx**: Python documentation generator
- **Markdownlint-cli2**: Markdown linting
- TypeDoc and Interrogate available via npm/uv for project-specific needs

### 🤖 Automated Quality Checks
Quality gates run automatically via pre-commit hooks on each commit.

**Important**: Git hooks run inside `devenv shell` automatically. This ensures all quality tools (ls-lint, markdownlint, gitleaks, etc.) are available when you commit, even from outside the devenv shell.

### 🧪 TDD Enforcement (Test-Driven Development)
- **TDD Guard**: Automated TDD workflow enforcement integrated with Claude Code
- **RED/GREEN/REFACTOR**: Enforces proper TDD cycle automatically
- **Test-First**: Blocks implementation code without failing tests
- **Test Validation**: Ensures tests pass after implementation
- **Pre-configured**: Integrated with Claude Code hooks (system-wide)
- **Project-Ready**: Template includes tdd-guard-pytest for Python projects

## Quick Start

```bash
# Initialize new project with this template
cd /home/guyfawkes/nixos-config
cp -r templates/ai-quality-devenv/* /path/to/new-project/
cd /path/to/new-project

# Enter development environment
direnv allow         # Automatic activation (recommended)
# OR
devenv shell         # Manual activation

# Interactive AI tools setup
init-ai-tools        # Choose Claude Code, Cursor AI, or both

# For Python projects: Setup TDD Guard
cp pyproject.toml.template pyproject.toml
# Edit pyproject.toml with your project name and details
# TDD Guard is pre-configured - just update project_root if needed

# Git hooks are installed automatically on first devenv shell
# Verify installation:
ls -la .git/hooks/pre-commit

# Verify setup
quality-report
```

### TDD Guard Setup (Python Projects)

TDD Guard is **pre-configured** system-wide via Claude Code hooks. For Python projects:

1. **Copy the template**:
   ```bash
   cp pyproject.toml.template pyproject.toml
   ```

2. **Customize** your project details (name, version, dependencies)

3. **TDD Guard is ready!** It's already included in dev dependencies:
   ```toml
   [project.optional-dependencies]
   dev = [
       "pytest>=8.0.0",
       "tdd-guard-pytest>=0.1.0",  # Already configured!
       # ... other dev tools
   ]
   ```

4. **Enter devenv** and dependencies auto-install:
   ```bash
   devenv shell  # or direnv allow
   ```

5. **TDD workflow is enforced** automatically:
   - Write test first → Allowed ✅
   - Test must fail (RED) → Validated
   - Write implementation → Allowed when tests exist
   - Tests must pass (GREEN) → Validated
   - Refactor with green tests → Allowed ✅

See `~/.claude/TDD-GUARD-SETUP.md` for full documentation.

### JavaScript/TypeScript Projects

For JS/TS projects, install the appropriate reporter:

```bash
# Vitest
npm install --save-dev tdd-guard-vitest

# Jest
npm install --save-dev tdd-guard-jest
```

Then configure in `vitest.config.ts` or `jest.config.js` (see TDD-GUARD-SETUP.md).
```

## Available Scripts

### AI Tools Setup
- `init-ai-tools` - Interactive AI tools setup (choose Claude Code, Cursor AI, or both)
- `setup-cursor` - Setup Cursor AI only (use init-ai-tools instead)
- `setup-claude` - Setup Claude Code only (use init-ai-tools instead)

### Quality Gates
- `hello` - Environment information
- `quality-report` - Show all active quality gates
- `quality-check` - Run quality analysis
- `setup-git-hooks` - Install git hooks manually

### Legacy Codebase Rescue
- `assess-codebase` - 8-step codebase analysis
- `assess-documentation` - Markdown linting, required docs, JSDoc coverage
- `analyze-folder-structure` - Depth analysis, god directories, structure score
- `check-naming-conventions` - File/folder naming validation
- `generate-remediation-plan` - AI-powered remediation plan with self-awareness
- `quality-dashboard` - Real-time quality metrics for 7 quality categories
- `post-commit-docs` - Auto-documentation reminders after commits

See `LEGACY_CODEBASE_RESCUE.md` for complete rescue system documentation.

### Quality Baseline Gates
- `check-feature-readiness` - Validate all quality baseline thresholds before features
- `certify-feature-ready` - Lock in baseline and enable strict mode enforcement
- `quality-regression-check` - Pre-commit validation against baseline (strict mode)

See `QUALITY_BASELINE_GATES.md` for complete baseline gates system documentation.

### Autonomous Execution

#### Tier 1: Core Autonomy
- `initialize-remediation-state` - Initialize autonomous remediation with state management
- `update-remediation-state` - Internal: Update persistent state
- `identify-next-targets` - Smart target prioritization algorithm
- `checkpoint-progress` - Git commit automation with tagging every 5 commits
- `needs-human-checkpoint` - Safety gate checking for human approval
- `validate-target-improved` - Automatic validation of refactoring improvements
- `mark-checkpoint-approved` - Mark human approval for phase transitions
- `rollback-to-checkpoint` - Rollback to last stable checkpoint

#### Tier 2: Orchestration
- `autonomous-remediation-session` - Main orchestrator for supervised autonomous refactoring

#### Tier 3: Optimization & Analytics
- `estimate-token-usage` - Predict token cost for files and optimize batch sizing
- `analyze-failure-patterns` - Identify common failure reasons and suggest strategies
- `generate-progress-report` - Stakeholder-friendly markdown report with metrics and ROI
- `parallel-remediation-coordinator` - Multi-agent coordination with work queue distribution

See `AUTONOMOUS_REMEDIATION.md` for complete autonomous execution documentation.

## Quality Standards

### Complexity Thresholds
- **Cyclomatic Complexity**: < 10 (McCabe standard)
- **Function Length**: < 50 lines
- **Code Duplication**: < 5% threshold
- **Security Patterns**: Auto-detection via Semgrep

### Pre-commit Hooks
All hooks run automatically on commit:
1. **Security**: Gitleaks secret scanning
2. **Format**: Prettier/ESLint for JS/TS, Black/Ruff for Python
3. **Quality**: Complexity analysis and clone detection (*via system tools*)
4. **Patterns**: Security vulnerability detection
5. **Messages**: Conventional commit format

> **Note**: Lizard (complexity) and JSCPD (clone detection) are available system-wide through your NixOS configuration rather than in the DevEnv package set for optimal performance and consistency.

## Customization

### Adding Packages
Edit `devenv.nix`:
```nix
packages = with pkgs; [
  # Existing packages...
  your-additional-package
];
```

### Adding Services
Edit `devenv.nix`:
```nix
services = {
  postgres.enable = true;
  redis.enable = true;
};
```

### Adjusting Quality Thresholds
Modify hook configurations in `git-hooks.hooks` section.

## AI Development Integration

This template supports both Cursor AI and Claude Code with quality gate awareness.

### Cursor AI Integration

Uses `.cursor/rules` with MDC format files.

**Available Rule Files:**
- **`index.mdc`**: Core development rules with quality standards and technology stack
- **`security.mdc`**: Security-focused rules for secure coding practices
- **`testing.mdc`**: Testing and QA rules for test coverage

**Configuration Features:**
- YOLO Mode for AI capabilities with build/test execution
- Claude 3.5 Sonnet (primary), GPT-4o (secondary) model selection
- Agent Mode shortcuts (`Ctrl+I` for agent, `Ctrl+E` for background)
- Privacy settings for sensitive code
- Context management with `.cursorignore`

**Setup:**
```bash
# Option 1: Interactive
init-ai-tools                   # Select Cursor AI in the prompt

# Option 2: Direct
setup-cursor                    # Initialize Cursor AI integration

# Customize
# Edit .cursor/rules/*.mdc      # Adjust AI behavior and rules
```

### Claude Code Integration

Uses `.claude/CLAUDE.md` for Claude Code instructions.

**Key Features:**
- Quality Gate Awareness: Claude knows all thresholds (CCN < 10, duplication < 5%, etc.)
- MCP Serena Integration: Symbolic code operations for token efficiency
- DevEnv Context: Understanding of Node.js 20, Python 3.13, uv, quality tools
- Pre/Post Hooks: Quality reminders on Write/Edit operations
- Settings: Permissions, environment variables, MCP server enablement

**Configuration Files:**
- **`.claude/CLAUDE.md`**: Development guidelines
  - Quality gate compliance strategies
  - MCP Serena tool usage
  - Technology stack integration
  - Security-first development patterns
  - Code generation best practices
- **`.claude/settings.local.json`**: Hooks, permissions, environment variables
- **`.claudeignore`**: Exclude build artifacts and dependencies from context

**Setup:**
```bash
# Option 1: Interactive
init-ai-tools                   # Select Claude Code in the prompt

# Option 2: Direct
setup-claude                    # Initialize Claude Code integration

# Customize
# Edit .claude/CLAUDE.md        # Adjust behavior and guidelines

# Documentation
# See CLAUDE_CODE_SETUP.md for complete setup guide
```

### Shared Quality Standards

Both AI systems enforce identical quality gates:
- **Complexity**: CCN < 10 per function (Lizard)
- **Duplication**: < 5% threshold (JSCPD)
- **Security**: Zero secrets (Gitleaks), zero vulnerabilities (Semgrep)
- **Formatting**: Prettier/ESLint (JS/TS), Black/Ruff (Python)
- **Testing**: 75%+ coverage for new code
- **Commits**: Conventional Commits format (Commitizen)

## Architecture: Pure DevEnv Approach

This template uses only `devenv.nix` based on the `account-harmony-ai-37599577` pattern:

### 🔧 devenv.nix - Development Configuration
- Single configuration file for all development needs
- DevEnv automatically generates `.devenv.flake.nix` for Nix compatibility
- Includes git hooks, scripts, and automation
- Designed for coding workflows with quality gates
- Integrates with direnv and development processes

### 🎯 Why Pure DevEnv?
- **Simplicity**: Single `devenv.nix` file to maintain
- **Automatic Nix integration**: DevEnv handles flake generation automatically
- **Developer-focused**: Built for development workflows, not packaging
- **Proven pattern**: Based on production usage in account-harmony-ai
- **Reduced complexity**: No need to maintain separate flake.nix and devenv.nix files
- **Optimized for development**: DevEnv optimized for development speed

### 🔄 How it works
1. **You maintain**: Only `devenv.nix` with your development environment
2. **DevEnv generates**: `.devenv.flake.nix` automatically for Nix compatibility
3. **You get**: Nix ecosystem benefits without the complexity

## Troubleshooting

### Git Hooks Not Running

If git hooks fail with "Executable not found" errors:

1. **Verify devenv shell activation**:
   ```bash
   devenv shell bash -c "which ls-lint"
   # Should show: /nix/store/.../ls-lint-2.3.1/bin/ls-lint
   ```

2. **Regenerate hooks**:
   ```bash
   rm -f .pre-commit-config.yaml .git/hooks/*
   devenv shell  # Hooks auto-install on shell entry
   ```

3. **Check .pre-commit-config.yaml**:
   ```bash
   # ls-lint entry should be wrapped in devenv shell:
   grep "ls-lint" .pre-commit-config.yaml
   # Should show: "entry": "devenv shell bash -c 'ls-lint'"
   ```

### Git Hooks Architecture

**How it works**:
- Git hooks run **outside** the devenv shell by default
- Template wraps quality tools in `devenv shell bash -c 'command'`
- This ensures tools are available when git triggers hooks
- The `nix` package in devenv.nix provides `nix-store` for GC root creation

**Why this approach**:
- No need to install tools system-wide
- Works in any environment (CI, different machines, containers)
- Developers don't need to remember to run hooks from within devenv shell
- Quality gates enforced automatically on every commit

### Common Issues

**"nix-store: command not found"** during devenv shell:
- Solution: `nix` package is included in template's devenv.nix
- If using older version, add `pkgs.nix` to packages list

**Hooks slow on first run**:
- First commit after `devenv shell` spawns new devenv instance
- Subsequent commits are faster (devenv shell cached)
- This is expected behavior

**"Your pre-commit configuration is unstaged"**:
```bash
git add .pre-commit-config.yaml
git commit -m "your message"
```

## Integration

This template integrates with:
- **NixOS**: System-wide tool consistency
- **AI orchestration**: Claude Code, Cursor, other AI tools
- **CI/CD**: `devenv test` for automated quality verification
- **Development**: Automatic environment activation via direnv