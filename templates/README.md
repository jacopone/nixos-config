# 🏗️ NixOS Development Templates

**Enterprise-grade project templates with integrated quality gates and AI development support**

## 📋 **Available Templates**

### **🤖 AI Quality DevEnv Template**

**Location**: `templates/ai-quality-devenv/`

**Description**: Complete enterprise-grade development environment template with comprehensive quality gates designed for AI-assisted coding and modern development workflows.

#### **🎯 Features**

- **🔒 Enterprise Quality Gates**: Gitleaks, Semgrep, Lizard complexity analysis, JSCPD clone detection
- **🤖 Cursor AI Integration**: Complete `.cursor/rules/` system with MDC format for AI behavior configuration
- **🚀 Modern Stack**: Node.js 20, Python 3.13 with uv, DevEnv for environment management
- **🔧 Hybrid Architecture**: Both `devenv.nix` and `flake.nix` for maximum flexibility
- **⚡ System Integration**: Uses system-wide quality tools for consistency and performance

#### **🛠️ Technology Stack**

- **Frontend**: JavaScript/TypeScript with Node.js 20, ESLint, Prettier
- **Backend**: Python 3.13 with uv package manager, Black, Ruff
- **Quality**: System-wide lizard, jscpd, radon; project-level gitleaks, semgrep
- **Git Hooks**: Automated quality gate enforcement via pre-commit hooks
- **AI Development**: Cursor AI rules synchronized with quality standards

#### **📁 Template Structure**

```
ai-quality-devenv/
├── 📄 devenv.nix              # DevEnv configuration with quality gates
├── 📄 flake.nix               # Nix flake for CI/CD and packaging
├── 📄 .envrc                  # Direnv integration
├── 📄 README.md               # Complete usage documentation
├── 📂 .cursor/                # Cursor AI configuration
│   └── rules/                 # AI behavior rules (MDC format)
│       ├── index.mdc          # Core development rules
│       ├── security.mdc       # Security-focused patterns
│       └── testing.mdc        # Testing and QA rules
├── 📄 .cursorignore          # AI context optimization
└── 📂 scripts/               # Quality and setup scripts
    ├── quality-check          # Comprehensive quality analysis
    ├── setup-git-hooks       # Git hooks installation
    └── setup-cursor          # Cursor AI setup
```

#### **🚀 Quick Start**

```bash
# 1. Copy template to your new project
cp -r ~/nixos-config/templates/ai-quality-devenv/* /path/to/new-project/
cd /path/to/new-project

# 2. Initialize project environment
direnv allow          # Automatic activation
# OR
devenv shell          # Manual activation

# 3. Setup quality gates and AI integration
setup-git-hooks       # Install pre-commit hooks
setup-cursor          # Configure Cursor AI rules
quality-report         # Verify all systems

# 4. Start development
npm init              # Initialize package.json
uv init               # Initialize Python project
```

#### **🎯 Quality Standards**

| **Quality Metric** | **Threshold** | **Tool** | **Enforcement** |
|-------------------|---------------|----------|-----------------|
| **Cyclomatic Complexity** | CCN < 10 | Lizard (system-wide) | Pre-commit hook |
| **Code Duplication** | < 5% | JSCPD (system-wide) | Pre-commit hook |
| **Security Patterns** | Zero violations | Semgrep | Pre-commit hook |
| **Secret Detection** | Zero secrets | Gitleaks | Pre-commit hook |
| **Code Formatting** | 100% compliance | Prettier, ESLint, Black, Ruff | Pre-commit hook |
| **Commit Format** | Conventional Commits | Commitizen | commit-msg hook |

#### **🤖 AI Development Integration**

The template includes comprehensive **Cursor AI integration** with enterprise-grade quality gates:

- **MDC Rule System**: Modern `.cursor/rules/*.mdc` files for AI behavior configuration
- **Quality Synchronization**: AI rules automatically enforce quality thresholds
- **Project Context**: AI understands technology stack, patterns, and constraints
- **Security Integration**: AI prevents credential exposure and follows security best practices
- **Testing Patterns**: AI generates comprehensive tests with proper coverage

#### **🔧 Customization**

**Adding Packages**:
```nix
# In devenv.nix
packages = with pkgs; [
  # Existing packages...
  your-additional-package
];
```

**Adding Services**:
```nix
# In devenv.nix
services = {
  postgres.enable = true;
  redis.enable = true;
};
```

**Customizing AI Rules**:
```bash
# Edit project-specific AI behavior
nano .cursor/rules/index.mdc

# Add domain-specific rules
touch .cursor/rules/analytics.mdc
touch .cursor/rules/database.mdc
```

#### **📊 Quality Reporting**

```bash
# View active quality gates
quality-report

# Run comprehensive analysis
quality-check

# Test all git hooks
devenv test

# Verify system tools
lizard --version && jscpd --version && radon --version
```

## 🔄 **Template Usage Workflow**

### **1. Project Initialization**
```bash
# Navigate to your projects directory
cd ~/projects

# Copy template
cp -r ~/nixos-config/templates/ai-quality-devenv ./my-new-project
cd my-new-project

# Initialize environment
direnv allow
```

### **2. Setup Development Environment**
```bash
# Setup quality gates
setup-git-hooks

# Configure AI development
setup-cursor

# Initialize project files
npm init              # For JavaScript/TypeScript projects
uv init               # For Python projects
```

### **3. Verify Setup**
```bash
# Check all systems
quality-report

# Test quality gates
devenv test

# Start development
npm run dev           # Or your development command
```

## 🧠 **AI-Enhanced Development**

### **Cursor AI Integration**

The template provides **state-of-the-art AI development integration**:

- **🎯 Context-Aware**: AI understands project structure, tech stack, and quality requirements
- **🔒 Security-First**: AI rules prevent credential exposure and enforce security patterns
- **🧪 Testing-Focused**: AI generates comprehensive tests with proper coverage patterns
- **📏 Quality-Enforced**: AI respects complexity, duplication, and formatting standards

### **Usage Patterns**

```bash
# Agent Mode for complex tasks
# Ctrl+I in Cursor → "Implement user authentication with proper testing"

# Background mode for suggestions
# Ctrl+E in Cursor → Continuous AI assistance

# Quality-aware development
# AI automatically respects CCN < 10, duplication < 5%, security patterns
```

## 🔧 **Integration with NixOS System**

### **System-Level Tools**

The template leverages **system-wide quality tools** from your NixOS configuration:

```nix
# Available system-wide (modules/core/packages.nix)
lizard             # Code complexity analysis
python312Packages.radon # Python metrics
nodePackages.jscpd    # Clone detection
```

### **Benefits**

- **✅ Consistency**: Same tool versions across all projects
- **✅ Performance**: No package compilation overhead in DevEnv
- **✅ AI Integration**: Tools always available for AI agents
- **✅ Universal Access**: Works across all development environments

## 📚 **Documentation & Support**

- **Template README**: Complete setup and usage guide in each template
- **Quality Integration**: Comprehensive documentation in `docs/CURSOR_AI_QUALITY_INTEGRATION.md`
- **NixOS Config**: Main system documentation in root `README.md`
- **AI Development**: Cursor AI setup guide in project documentation

## 🤝 **Contributing to Templates**

### **Adding New Templates**

1. Create new directory under `templates/`
2. Include complete `README.md` with usage instructions
3. Add quality gates and AI integration where applicable
4. Update this documentation
5. Test template with real projects

### **Improving Existing Templates**

1. Follow existing patterns and conventions
2. Maintain backward compatibility
3. Update documentation
4. Test changes thoroughly

---

**Built for modern development teams that demand excellence in code quality, security, and AI-assisted development.**