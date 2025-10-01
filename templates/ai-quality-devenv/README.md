# AI Quality DevEnv Template

**Pure DevEnv approach** - Enterprise-grade development environment with comprehensive quality gates designed for AI-assisted coding.

## Features

### 🔒 Security & Quality Gates
- **Gitleaks**: Secret detection and prevention
- **Semgrep**: Advanced security pattern analysis
- **Lizard**: Code complexity analysis (CCN < 10) - *Available system-wide*
- **JSCPD**: Clone detection via npx wrapper (threshold 5%) - *Available system-wide*
- **Commitizen**: Conventional commit format enforcement

### 🛠️ Development Tools
- **Node.js 20**: Modern JavaScript/TypeScript development
- **Python 3.13**: Latest Python with uv package manager
- **ESLint + Prettier**: JavaScript/TypeScript formatting
- **Black + Ruff**: Python formatting and linting

### 🤖 AI Code Protection
All quality gates run automatically via pre-commit hooks to ensure AI-generated code meets enterprise standards.

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

# Interactive AI tools setup (RECOMMENDED - NEW!)
init-ai-tools        # Choose Claude Code, Cursor AI, or both

# Install git hooks
setup-git-hooks

# Verify setup
quality-report
```

## Available Scripts

### AI Tools Setup
- `init-ai-tools` - **Interactive AI tools setup** (choose Claude Code, Cursor AI, or both)
- `setup-cursor` - Setup Cursor AI only (use init-ai-tools instead)
- `setup-claude` - Setup Claude Code only (use init-ai-tools instead)

### Quality Gates
- `hello` - Environment information
- `quality-report` - Show all active quality gates
- `quality-check` - Run comprehensive quality analysis
- `setup-git-hooks` - Install git hooks manually

### Legacy Codebase Rescue (NEW!)
- `assess-codebase` - **Comprehensive 8-step codebase analysis**
- `generate-remediation-plan` - **AI-powered remediation plan with self-awareness**
- `quality-dashboard` - Real-time quality metrics dashboard

See `LEGACY_CODEBASE_RESCUE.md` for complete rescue system documentation.

### Quality Baseline Gates (NEW!)
- `check-feature-readiness` - **Validate all quality baseline thresholds before features**
- `certify-feature-ready` - **Lock in baseline and enable strict mode enforcement**
- `quality-regression-check` - **Pre-commit validation against baseline (strict mode)**

See `QUALITY_BASELINE_GATES.md` for complete baseline gates system documentation.

### Autonomous Execution (NEW - Complete!)

#### Tier 1: Core Autonomy
- `initialize-remediation-state` - **Initialize autonomous remediation with state management**
- `update-remediation-state` - **Internal: Update persistent state**
- `identify-next-targets` - **Smart target prioritization algorithm**
- `checkpoint-progress` - **Git commit automation with tagging every 5 commits**
- `needs-human-checkpoint` - **Safety gate checking for human approval**
- `validate-target-improved` - **Automatic validation of refactoring improvements**
- `mark-checkpoint-approved` - **Mark human approval for phase transitions**
- `rollback-to-checkpoint` - **Rollback to last stable checkpoint**

#### Tier 2: Orchestration
- `autonomous-remediation-session` - **Main orchestrator for supervised autonomous refactoring**

#### Tier 3: Optimization & Analytics
- `estimate-token-usage` - **Predict token cost for files and optimize batch sizing**
- `analyze-failure-patterns` - **Identify common failure reasons and suggest strategies**
- `generate-progress-report` - **Stakeholder-friendly markdown report with metrics and ROI**
- `parallel-remediation-coordinator` - **Multi-agent coordination with work queue distribution**

See `AUTONOMOUS_AGENT_COMPATIBILITY.md` for autonomous execution documentation.

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

This template provides **first-class support for both Cursor AI and Claude Code** with comprehensive quality gate awareness.

### Cursor AI Integration

**Modern Rules System (2025)**: Uses `.cursor/rules` with MDC format files.

**Available Rule Files:**
- **`index.mdc`**: Core development rules with quality standards and technology stack integration
- **`security.mdc`**: Security-focused rules for secure coding practices
- **`testing.mdc`**: Testing and QA rules for comprehensive test coverage

**Configuration Features:**
- YOLO Mode for advanced AI capabilities with build/test execution
- Claude 3.5 Sonnet (primary), GPT-4o (secondary) model selection
- Agent Mode shortcuts (`Ctrl+I` for agent, `Ctrl+E` for background)
- Enterprise-grade privacy settings for sensitive code
- Optimized context management with `.cursorignore`

**Setup:**
```bash
# Option 1: Interactive (RECOMMENDED)
init-ai-tools                   # Select Cursor AI in the prompt

# Option 2: Direct
setup-cursor                    # Initialize Cursor AI integration

# Customize
# Edit .cursor/rules/*.mdc      # Adjust AI behavior and rules
```

### Claude Code Integration (NEW - October 2025)

**Project-Level Configuration**: Uses `.claude/CLAUDE.md` for comprehensive Claude Code instructions.

**Key Features:**
- **Quality Gate Awareness**: Claude knows all thresholds (CCN < 10, duplication < 5%, etc.)
- **MCP Serena Integration**: Optimized symbolic code operations for token efficiency
- **DevEnv Context**: Full understanding of Node.js 20, Python 3.13, uv, quality tools
- **Pre/Post Hooks**: Quality reminders on Write/Edit operations
- **Enterprise Settings**: Permissions, environment variables, MCP server enablement

**Configuration Files:**
- **`.claude/CLAUDE.md`**: Comprehensive enterprise development guidelines (6KB)
  - Quality gate compliance strategies
  - MCP Serena tool usage optimization
  - Technology stack integration
  - Security-first development patterns
  - Code generation best practices
- **`.claude/settings.local.json`**: Hooks, permissions, environment variables
- **`.claudeignore`**: Exclude build artifacts and dependencies from context

**Setup:**
```bash
# Option 1: Interactive (RECOMMENDED)
init-ai-tools                   # Select Claude Code in the prompt

# Option 2: Direct
setup-claude                    # Initialize Claude Code integration

# Customize
# Edit .claude/CLAUDE.md        # Adjust behavior and guidelines
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

This template uses **only** `devenv.nix` based on the proven `account-harmony-ai-37599577` pattern:

### 🔧 **devenv.nix** - Complete Development Solution
- **Unified experience** - Single configuration file for all development needs
- **Auto-generated flake** - DevEnv automatically generates `.devenv.flake.nix` for Nix compatibility
- **Enhanced developer experience** with git hooks, scripts, and automation
- **Superior performance** for daily development tasks
- **Purpose-built** for coding workflows with AI quality gates
- **Rich integration** with direnv and development processes

### 🎯 **Why Pure DevEnv?**
- **Simplicity**: Single `devenv.nix` file to maintain
- **Automatic Nix integration**: DevEnv handles flake generation automatically
- **Developer-focused**: Built specifically for development workflows, not packaging
- **Real-world proven**: Based on successful production usage in account-harmony-ai
- **Reduced complexity**: No need to maintain separate flake.nix and devenv.nix files
- **Better performance**: DevEnv optimized for development speed over generic Nix usage

### 🔄 **How it works**
1. **You maintain**: Only `devenv.nix` with your development environment
2. **DevEnv generates**: `.devenv.flake.nix` automatically for Nix compatibility
3. **You get**: Full Nix ecosystem benefits without the complexity

## Integration

This template integrates seamlessly with:
- **NixOS**: System-wide tool consistency
- **AI orchestration**: Claude Code, Cursor, other AI tools
- **CI/CD**: `devenv test` for automated quality verification
- **Development**: Automatic environment activation via direnv