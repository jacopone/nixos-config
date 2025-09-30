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

# Install git hooks and setup Cursor AI
setup-git-hooks
setup-cursor
quality-report
```

## Available Scripts

- `hello` - Environment information
- `quality-report` - Show all active quality gates
- `quality-check` - Run comprehensive quality analysis
- `setup-git-hooks` - Install git hooks manually
- `setup-cursor` - Setup Cursor AI integration with project rules

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

## Cursor AI Integration

### Modern Rules System (2025)
This template uses the latest `.cursor/rules` system with MDC (Metadata + Content) format files for AI behavior configuration.

### Available Rule Files
- **`index.mdc`**: Core development rules with quality standards and technology stack integration
- **`security.mdc`**: Security-focused rules for secure coding practices
- **`testing.mdc`**: Testing and QA rules for comprehensive test coverage

### Cursor Configuration Features
- **YOLO Mode**: Enabled for advanced AI capabilities with build/test execution
- **Model Selection**: Claude 3.5 Sonnet (primary), GPT-4o (secondary) with auto-selection
- **Agent Mode**: Enhanced shortcuts (`Ctrl+I` for agent, `Ctrl+E` for background)
- **Privacy Mode**: Enterprise-grade privacy settings for sensitive code
- **Context Management**: Optimized for large codebases with proper exclusions

### Project Setup
1. Run `setup-cursor` to initialize project-specific rules
2. Edit `.cursor/rules/*.mdc` files to customize AI behavior
3. Use `.cursorignore` to exclude files from AI context
4. Leverage Agent mode for complex refactoring and implementation tasks

### Integration with Quality Gates
Cursor AI rules are synchronized with the project's quality gates:
- All AI-generated code respects complexity thresholds (CCN < 10)
- Security rules prevent credential exposure and enforce best practices
- Testing rules ensure comprehensive coverage for AI-suggested code
- Code formatting and linting rules match pre-commit hook configuration

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