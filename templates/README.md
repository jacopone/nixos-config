# 🏗️ NixOS Development Templates

**Enterprise-grade project templates - now available via ai-project-orchestration package**

## 📋 **Available Templates**

### **🤖 AI Project Orchestration Templates**

**System Package**: `ai-project-orchestration` (installed system-wide)

The complete AI project orchestration system provides two comprehensive workflow templates:

#### **1. Greenfield Template** (New Projects)

**Initialize with**:

```bash
ai-init-greenfield
# OR: ai-init-green
```

**Features**:

- **🔒 Enterprise Quality Gates**: Gitleaks, Semgrep, Lizard complexity, JSCPD clone detection
- **🤖 Dual AI Integration**: Claude Code + Cursor AI with `.cursor/rules/` MDC system
- **🚀 Modern Stack**: Node.js 20, Python 3.13 with uv, DevEnv for environment management
- **📋 Spec-Driven Development**: Constitution → Spec → Plan → Implementation workflow
- **⚡ System Integration**: Uses system-wide quality tools for consistency

**Workflow**:

```bash
mkdir my-new-project && cd my-new-project
ai-init-greenfield
direnv allow
/constitution          # Define project values
/specify my-feature    # Write specification
/plan my-feature       # Create technical plan
spec-to-prd my-feature # Convert to PRD
/pm:epic-oneshot       # GitHub sync + multi-agent dev
```

**Quality Standards**:

- ✅ 80%+ test coverage
- ✅ CCN < 10 complexity
- ✅ < 5% code duplication
- ✅ Zero security issues
- ✅ Complete spec traceability

#### **2. Brownfield Template** (Legacy Rescue)

**Initialize with**:

```bash
ai-init-brownfield
# OR: ai-init-brown or ai-rescue
```

**Features**:

- **🧠 AI Self-Assessment**: Analyzes its own limits and codebase reality
- **📊 Quality Baseline Gates**: Realistic targets based on current state
- **🔄 Autonomous Remediation**: Supervised AI-driven quality improvement
- **📈 Gradual Spec Adoption**: Achieve quality baseline before new features
- **🎯 Smart Prioritization**: Safety → Quick Wins → High Impact

**Workflow**:

```bash
cd /path/to/legacy-project
ai-init-brownfield
./scripts/assess-codebase.sh
./scripts/generate-quality-baseline.sh
./scripts/autonomous-remediation-session.sh
# Once baseline achieved, adopt spec-driven workflow
/constitution
/specify new-feature
```

**Results**:

- ✅ 20-50% complexity reduction
- ✅ 150-400% coverage increase
- ✅ 100% security issues resolved
- ✅ Quality baseline certified

### **🎯 When to Use Which Template**

| Scenario                                 | Template   | Command                                       |
| ---------------------------------------- | ---------- | --------------------------------------------- |
| **Brand new project, zero code**         | Greenfield | `ai-init-greenfield`                          |
| **Legacy codebase needs rescue**         | Brownfield | `ai-init-brownfield`                          |
| **Existing project, want quality gates** | Greenfield | Copy `.speckit/`, `.claude/`, quality scripts |
| **Technical debt is overwhelming**       | Brownfield | Full assessment → remediation workflow        |

## 🚀 **Quick Start**

### **Installation**

The templates are available system-wide via the ai-project-orchestration package:

```bash
# Already installed if you've rebuilt NixOS
which ai-project
which ai-init-greenfield
which ai-init-brownfield
```

### **Creating a New Project (Greenfield)**

```bash
# 1. Create and navigate to project directory
mkdir ~/projects/my-awesome-app
cd ~/projects/my-awesome-app

# 2. Initialize greenfield template
ai-init-greenfield

# 3. Activate environment
direnv allow
# OR: devenv shell

# 4. Follow spec-driven workflow
/constitution           # Define project values
/specify user-auth      # Write feature spec
/plan user-auth         # Create technical plan
spec-to-prd user-auth   # Convert to PRD
/pm:epic-oneshot        # Multi-agent implementation
```

### **Rescuing Legacy Code (Brownfield)**

```bash
# 1. Navigate to existing project
cd ~/projects/legacy-app

# 2. Initialize brownfield rescue
ai-init-brownfield

# 3. Run assessment
./scripts/assess-codebase.sh

# 4. Generate quality baseline
./scripts/generate-quality-baseline.sh

# 5. Start autonomous remediation
./scripts/autonomous-remediation-session.sh

# 6. Once quality baseline met, adopt spec workflow
/constitution
/specify new-feature
```

## 🔧 **Template Components**

### **Shared Components (Both Templates)**

- **DevEnv Configuration**: `devenv.nix` with Node 20, Python 3.13, quality tools
- **Git Hooks**: Pre-commit enforcement for complexity, duplication, security, formatting
- **Quality Scripts**: Comprehensive assessment, reporting, and remediation tools
- **AI Integration**: Claude Code + Cursor AI configurations with quality awareness

### **Greenfield-Specific**

- **Spec-Kit Structure**: `.speckit/` with constitution, specs, plans
- **CCPM Integration**: `.claude/` with PRD/Epic/Issue workflow
- **TDD Guard**: Test-first development enforcement
- **Quality Gates**: Enforced from commit #1

### **Brownfield-Specific**

- **Assessment Tools**: Codebase analysis, technical debt quantification
- **Remediation Scripts**: Autonomous quality improvement with supervision
- **Quality Baseline**: Realistic targets based on current state
- **Migration Path**: Gradual adoption of spec-driven development

## 🤖 **AI Development Integration**

### **Dual AI System Support**

Both templates provide comprehensive AI integration:

**Claude Code:**

- Project-level CLAUDE.md with quality gate strategies
- MCP Serena integration for token-efficient operations
- Pre/Post tool hooks for quality reminders
- DevEnv awareness (Node 20, Python 3.13, all quality tools)

**Cursor AI:**

- MDC rule system (`.cursor/rules/*.mdc`)
- YOLO mode with build/test execution
- Agent mode for complex refactoring
- Quality gate synchronization

**Interactive Setup:**

```bash
init-ai-tools    # Choose Claude Code, Cursor AI, or both
```

## 📊 **Quality Standards**

| **Metric**            | **Threshold**   | **Tool**               | **Enforcement** |
| --------------------- | --------------- | ---------------------- | --------------- |
| Cyclomatic Complexity | CCN < 10        | Lizard                 | Pre-commit      |
| Code Duplication      | < 5%            | JSCPD                  | Pre-commit      |
| Security Patterns     | Zero violations | Semgrep                | Pre-commit      |
| Secret Detection      | Zero secrets    | Gitleaks               | Pre-commit      |
| Code Formatting       | 100% compliance | Prettier, ESLint, Ruff | Pre-commit      |
| Commit Format         | Conventional    | Commitizen             | commit-msg      |

## 🔄 **Integration with NixOS System**

### **System-Wide Tools (Already Installed)**

Templates leverage tools from `modules/core/packages.nix`:

```nix
lizard             # Code complexity analysis
radon              # Python metrics
jscpd              # Clone detection
semgrep            # Security patterns
gitleaks           # Secret detection
```

**Benefits:**

- ✅ Consistent tool versions across projects
- ✅ No DevEnv compilation overhead
- ✅ AI agents have universal access
- ✅ Zero setup friction

## 📚 **Documentation**

### **Template Documentation**

- **Greenfield Workflow**: `/home/guyfawkes/ai-project-orchestration/docs/GREENFIELD_WORKFLOW.md`
- **Brownfield Workflow**: `/home/guyfawkes/ai-project-orchestration/docs/BROWNFIELD_WORKFLOW.md`
- **NixOS Integration**: `/home/guyfawkes/ai-project-orchestration/docs/NIXOS_INTEGRATION.md`

### **System Documentation**

- **Main README**: `~/ai-project-orchestration/README.md`
- **Installation Guide**: `~/ai-project-orchestration/INSTALLATION_COMPLETE.md`
- **Quality Integration**: `~/nixos-config/docs/CURSOR_AI_QUALITY_INTEGRATION.md`

## 🎯 **Use Cases**

### **For New Projects**

```bash
ai-init-greenfield
# → Spec-driven, quality-first development from day one
```

### **For Legacy Code**

```bash
ai-init-brownfield
# → Assessment → Remediation → Spec adoption
```

### **For This NixOS Config?**

**No** - it's configuration, not a software product. The orchestrator is for:

- SaaS applications
- Client projects
- Open source tools
- Any project with features and users

## 🤝 **Contributing**

To improve templates:

1. **For greenfield/brownfield templates**: Edit source in `~/ai-project-orchestration/templates/`
2. **Test changes**: Initialize new project and verify workflow
3. **Update docs**: Keep documentation synchronized
4. **Commit to ai-project-orchestration**: Changes apply to all future projects

---

**Built for modern development teams that demand excellence in code quality, security, and AI-assisted development.**

**Now available system-wide via the ai-project-orchestration package.**
