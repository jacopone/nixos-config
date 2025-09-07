# Universal AI Orchestration Script Installation

This guide explains how to install the universal AI orchestration script globally in your nixos-config so it works across all projects.

## 🎯 Overview

The universal script (`ai-orchestration-universal.sh`) is designed to:
- **Live globally** in your nixos-config directory
- **Detect any project** you're working in automatically
- **Generate project-specific prompts** tailored to the detected technology stack
- **Include evolution protocol** for maintaining cutting-edge orchestration
- **Work consistently** across all your development projects

## 🚀 Installation Steps

### Step 1: Copy Script to Global Location

```bash
# Copy the universal script to your nixos-config
cp scripts/ai-orchestration-universal.sh ~/nixos-config/scripts/ai-orchestration

# Make it executable  
chmod +x ~/nixos-config/scripts/ai-orchestration
```

### Step 2: Add to PATH (NixOS Configuration)

Add to your `configuration.nix` or home-manager configuration:

```nix
# In your nixos configuration
environment.systemPackages = with pkgs; [
  # ... other packages
  (writeShellScriptBin "ai-orchestration" (builtins.readFile ./scripts/ai-orchestration))
];
```

Or for home-manager:

```nix
# In your home.nix
home.packages = with pkgs; [
  # ... other packages  
  (writeShellScriptBin "ai-orchestration" (builtins.readFile ./scripts/ai-orchestration))
];
```

### Step 3: Alternative - Simple PATH Addition

If you prefer not to use Nix packages:

```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
export PATH="$HOME/nixos-config/scripts:$PATH"

# Create alias for convenience
alias orchestrate="ai-orchestration"
```

### Step 4: Rebuild NixOS

```bash
# Rebuild your NixOS configuration
sudo nixos-rebuild switch

# Or if using home-manager
home-manager switch
```

## 🧠 How It Works

### Project Detection Algorithm

The script automatically detects your project by analyzing:

1. **Technology Stack Indicators**:
   - `package.json` → Node.js project (React, Vue, Angular detection)
   - `pyproject.toml` → Python project
   - `Cargo.toml` → Rust project
   - `go.mod` → Go project

2. **Framework Detection**:
   - React + TypeScript combinations
   - Next.js, Vite, Vue.js frameworks
   - Backend frameworks and databases

3. **Testing Framework Detection**:
   - Vitest, Jest, Cypress, Playwright
   - Matches testing approach to project patterns

4. **AI Orchestration Maturity**:
   - Checks for `docs/AI_ORCHESTRATION.md` 
   - Looks for `CLAUDE.md` files
   - Determines orchestration readiness level

### Generated Output Structure

For any project, running `ai-orchestration` creates:

```
[YOUR_PROJECT]/
└── ai-orchestration-sessions/
    └── [TIMESTAMP]/
        ├── 01-claude-coordinator.md       # Master coordination
        ├── 02-cursor-backend.md           # Backend implementation  
        ├── 03-lovable-frontend.md         # Frontend implementation
        ├── 04-gemini-quality.md           # Quality assurance
        ├── 05-claude-synthesis.md         # Final integration
        ├── 06-evolution-quarterly-review.md  # System evolution
        ├── 07-evolution-monthly-health.md    # Health monitoring
        ├── 08-evolution-breakthrough-detection.md # Innovation tracking
        ├── session-tracker.md             # Progress management
        └── quick-reference.md             # Workflow guide
```

## 📋 Usage Examples

### Any Node.js + React Project

```bash
cd ~/projects/my-react-app
ai-orchestration

# Script detects: React + TypeScript + Vite + Vitest
# Generates: Project-specific prompts with React patterns
```

### Python FastAPI Project

```bash
cd ~/projects/my-fastapi-service  
ai-orchestration

# Script detects: Python + FastAPI + PostgreSQL
# Generates: Python-specific implementation prompts
```

### Full-Stack Project  

```bash
cd ~/projects/account-harmony-ai
ai-orchestration

# Script detects: React + Node.js + PostgreSQL + Domain-Driven Design
# Generates: Full-stack orchestration with DDD patterns
```

## 🔧 Project-Specific Adaptations

### Automatic Context Generation

The script generates project-appropriate prompts by including:

- **Detected technology stack** in all prompt contexts
- **Framework-specific patterns** and best practices
- **Testing approach** aligned with detected tools
- **Architecture patterns** based on project structure
- **Database integration** matching detected database type

### Example Adaptations

**For React + TypeScript projects**:
```markdown
**Technical Context**:
- Framework: React + TypeScript + Vite
- Components: Modern React patterns with hooks
- State Management: Context API or state management library
- Styling: Tailwind CSS or styled-components
- Testing: Vitest for unit and integration tests
```

**For Python projects**:
```markdown  
**Technical Context**:
- Backend: Python + FastAPI
- API: RESTful endpoints with Pydantic validation
- Database: PostgreSQL with SQLAlchemy ORM
- Testing: pytest for comprehensive testing
```

## 🌟 Evolution Protocol Integration

### Quarterly Reviews

```bash
# In any project directory
ai-orchestration

# Generated evolution prompts include:
# - 06-evolution-quarterly-review.md (comprehensive assessment)
# - 07-evolution-monthly-health.md (regular monitoring)  
# - 08-evolution-breakthrough-detection.md (innovation tracking)
```

### Automated Maintenance Schedule

The script generates prompts for systematic maintenance:

- **Monthly**: Health checks and performance monitoring
- **Quarterly**: Comprehensive framework evolution assessment
- **As-needed**: Breakthrough technology evaluation
- **Annually**: Strategic technology roadmap planning

## 🚀 Benefits of Global Installation

### ✅ Consistency Across Projects
- Same cutting-edge orchestration approach everywhere
- Consistent prompt quality and structure
- Unified evolution and maintenance strategy

### ✅ Automatic Technology Adaptation  
- No manual configuration needed per project
- Intelligent detection of technology stacks
- Framework-specific best practices included automatically

### ✅ Single Source of Truth
- One script to maintain and evolve
- Automatic updates across all projects when script improves
- No version drift between different project copies

### ✅ Evolution Protocol Included
- Built-in system for staying current with AI developments
- Automated prompts for regular system assessment
- Breakthrough detection and integration planning

## 🔄 Keeping the Script Updated

### Manual Updates

```bash
# When you improve the script in a project
cp ~/projects/account-harmony-ai/scripts/ai-orchestration-universal.sh ~/nixos-config/scripts/ai-orchestration

# Rebuild to pick up changes
sudo nixos-rebuild switch
```

### Automated Updates (Future Enhancement)

Consider setting up a git subtree or submodule system to automatically sync script updates across your nixos-config and projects.

## 🎯 Next Steps

1. **Install globally** using the steps above
2. **Test in different projects** to verify detection works correctly  
3. **Use evolution protocol** to keep the orchestration system current
4. **Iterate and improve** the script based on experience across projects

**Result**: One universal script that provides cutting-edge AI orchestration across your entire development ecosystem! 🚀