# AI Quality DevEnv Template

Enterprise-grade development environment with comprehensive quality gates designed for AI-assisted coding.

## Features

### 🔒 Security & Quality Gates
- **Gitleaks**: Secret detection and prevention
- **Semgrep**: Advanced security pattern analysis
- **Lizard**: Code complexity analysis (CCN < 10)
- **JSCPD**: Clone detection (threshold 5%)
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

# Choose your workflow:

# Option 1: DevEnv (Recommended - Enhanced Experience)
direnv allow         # Automatic activation
# OR
devenv shell         # Manual activation

# Option 2: Standard Nix Flake
nix develop --no-pure-eval

# Install git hooks and verify
setup-git-hooks
quality-report
```

## Available Scripts

- `hello` - Environment information
- `quality-report` - Show all active quality gates
- `quality-check` - Run comprehensive quality analysis
- `setup-git-hooks` - Install git hooks manually

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
3. **Quality**: Complexity analysis and clone detection
4. **Patterns**: Security vulnerability detection
5. **Messages**: Conventional commit format

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

## Architecture: Hybrid Approach

This template uses **both** `devenv.nix` and `flake.nix` based on the battle-tested `account-harmony-ai-37599577` pattern:

### 🔧 **devenv.nix** - Development Workflow
- **Enhanced developer experience** with git hooks, scripts, and automation
- **Superior performance** for daily development tasks
- **Purpose-built** for coding workflows with AI quality gates
- **Rich integration** with direnv and development processes

### 📦 **flake.nix** - Build & Deploy
- **Industry standard** for Nix community compatibility
- **CI/CD integration** for automated builds and testing
- **Package definitions** for production deployments
- **Template discoverability** via `nix flake init`

### 🎯 **Why Both?**
- **Flexibility**: Teams can choose their preferred workflow
- **Evolution**: Projects can grow from development to production
- **Standards**: Matches both devenv best practices AND Nix ecosystem expectations
- **Future-proof**: Adaptable to changing team needs and tooling

## Integration

This template integrates seamlessly with:
- **NixOS**: System-wide tool consistency
- **AI orchestration**: Claude Code, Cursor, other AI tools
- **CI/CD**: `devenv test` for automated quality verification
- **Development**: Automatic environment activation via direnv