# DevEnv Architecture

**AI Quality DevEnv Template - Modular Structure (2025)**

## Overview

This template uses **devenv 1.9+ modular architecture** to maintain a clean, scalable configuration.

### Before (Legacy)
```
devenv.nix → 2,553 lines
- 92% comments
- 26 inline scripts
- Hard to maintain
```

### After (Modular)
```
devenv.nix → 58 lines (imports only)
modules/ → 4 focused files
scripts/ → 29 executable scripts
Total: Organized, maintainable, scalable
```

---

## Directory Structure

```
ai-quality-devenv/
├── devenv.nix              # Main entry (58 lines) - imports modules
├── devenv.yaml             # DevEnv metadata
├── devenv.lock             # Lock file (auto-generated)
│
├── modules/                # Core functionality
│   ├── languages.nix       # JavaScript & Python config
│   ├── packages.nix        # Tool declarations (30 packages)
│   ├── scripts.nix         # Script definitions (29 scripts)
│   └── git-hooks.nix       # Pre-commit hooks (12 hooks)
│
├── scripts/                # Executable shell scripts
│   ├── hello.sh
│   ├── quality-check.sh
│   ├── assess-codebase.sh
│   ├── autonomous-remediation-session.sh
│   └── ... (29 total)
│
├── profiles/               # Optional feature sets (future)
│   ├── minimal.nix         # Lightweight mode
│   └── legacy-rescue.nix   # Full autonomous remediation
│
└── docs/                   # Documentation
    └── devenv-architecture.md  # This file
```

---

## Module Descriptions

### `modules/languages.nix`
**Purpose**: Language runtime configuration

**Contents**:
- JavaScript/TypeScript (Node.js 20 + npm)
- Python 3.13 with uv package manager
- Auto-installation of dependencies

**Lines**: ~17

---

### `modules/packages.nix`
**Purpose**: Development tool declarations

**Contents**:
- Core tools: git, gh, nodejs, python, uv
- Security: gitleaks, semgrep
- Quality: ruff, black, commitizen
- Documentation: markdownlint-cli2, typedoc, interrogate
- Naming: ls-lint

**Total Packages**: 20
**Lines**: ~40

---

### `modules/scripts.nix`
**Purpose**: Script definitions (all point to `scripts/` directory)

**Script Categories**:
1. **Core Quality** (4 scripts)
   - hello, quality-check, quality-report, quality-dashboard

2. **AI Tools Setup** (3 scripts)
   - init-ai-tools, setup-claude, setup-cursor

3. **Assessment** (4 scripts)
   - assess-codebase, assess-documentation
   - analyze-folder-structure, check-naming-conventions

4. **Remediation** (11 scripts)
   - Autonomous remediation session
   - State management, target identification
   - Validation, checkpointing, rollback

5. **Quality Gates** (3 scripts)
   - check-feature-readiness, certify-feature-ready
   - quality-regression-check

6. **Advanced** (4 scripts)
   - estimate-token-usage, analyze-failure-patterns
   - generate-progress-report, parallel-remediation-coordinator

**Total Scripts**: 29
**Lines**: ~55

---

### `modules/git-hooks.nix`
**Purpose**: Pre-commit hook configuration

**Hook Categories**:
1. **Formatting**: prettier, black
2. **Linting**: eslint, ruff
3. **Security**: gitleaks, semgrep
4. **Quality**: complexity-check (lizard), clone-detection (jscpd)
5. **Documentation**: markdownlint
6. **Naming**: ls-lint
7. **Commits**: commitizen

**Total Hooks**: 12
**Lines**: ~85

---

## Scripts Directory

All 29 scripts are executable shell files in `scripts/`:

```bash
scripts/
├── Core
│   ├── hello.sh
│   ├── quality-check.sh
│   ├── quality-report.sh
│   └── quality-dashboard.sh
│
├── Setup
│   ├── setup-git-hooks.sh
│   ├── init-ai-tools.sh
│   ├── setup-claude.sh
│   └── setup-cursor.sh
│
├── Assessment
│   ├── assess-codebase.sh
│   ├── assess-documentation.sh
│   ├── analyze-folder-structure.sh
│   └── check-naming-conventions.sh
│
├── Remediation
│   ├── autonomous-remediation-session.sh
│   ├── initialize-remediation-state.sh
│   ├── update-remediation-state.sh
│   ├── identify-next-targets.sh
│   ├── validate-target-improved.sh
│   ├── checkpoint-progress.sh
│   ├── needs-human-checkpoint.sh
│   ├── mark-checkpoint-approved.sh
│   ├── rollback-to-checkpoint.sh
│   ├── estimate-token-usage.sh
│   ├── analyze-failure-patterns.sh
│   └── generate-progress-report.sh
│
└── Advanced
    ├── parallel-remediation-coordinator.sh
    ├── generate-remediation-plan.sh
    ├── check-feature-readiness.sh
    ├── certify-feature-ready.sh
    └── quality-regression-check.sh
```

---

## How It Works

### 1. Entry Point
`devenv.nix` imports all modules:

```nix
{
  imports = [
    ./modules/languages.nix
    ./modules/packages.nix
    ./modules/scripts.nix
    ./modules/git-hooks.nix
  ];
}
```

### 2. Module Loading
DevEnv loads each module and merges their configurations.

### 3. Script Resolution
When you run a command like `quality-check`, devenv:
1. Looks up the script definition in `modules/scripts.nix`
2. Finds: `quality-check.exec = "bash scripts/quality-check.sh"`
3. Executes the shell script

### 4. Git Hooks
Pre-commit hooks are automatically installed when entering the shell.

---

## Benefits of This Architecture

### 1. Maintainability
- Each file has a single, clear purpose
- Easy to find and modify specific functionality
- No 2,500-line files to navigate

### 2. Scalability
- Add new scripts: Just create `scripts/new-tool.sh` and add one line to `modules/scripts.nix`
- Add new packages: Edit `modules/packages.nix` (one focused file)
- Add new hooks: Edit `modules/git-hooks.nix` (one focused file)

### 3. Reusability
- Modules can be shared across projects
- Scripts are standalone and testable
- Clear separation of concerns

### 4. Documentation
- Comments in modules, not inline in scripts
- Scripts are self-documenting (bash with comments)
- Architecture is explicit, not implicit

---

## Future: Profiles (Optional)

Profiles allow enabling/disabling feature sets:

```nix
# devenv.yaml
profiles:
  minimal:
    module: ./profiles/minimal.nix
  legacy-rescue:
    module: ./profiles/legacy-rescue.nix
```

Activate with:
```bash
devenv shell --profile minimal        # Lightweight dev environment
devenv shell --profile legacy-rescue  # Full autonomous remediation
```

---

## Comparison

| Metric | Before | After |
|--------|--------|-------|
| **Main file size** | 2,553 lines | 58 lines |
| **Inline scripts** | 26 embedded | 0 (all in scripts/) |
| **Comments** | 2,355 lines (92%) | Moved to docs/ |
| **Maintainability** | Hard | Easy |
| **Modularity** | None | 4 focused modules |
| **Testability** | Low | High (scripts are files) |

---

## Editing Guide

### Adding a New Script

1. Create `scripts/my-new-tool.sh`
2. Add to `modules/scripts.nix`:
   ```nix
   my-new-tool.exec = "bash scripts/my-new-tool.sh";
   ```

### Adding a New Package

Edit `modules/packages.nix`:
```nix
packages = with pkgs; [
  # ... existing packages ...
  my-new-package
];
```

### Adding a New Git Hook

Edit `modules/git-hooks.nix`:
```nix
git-hooks.hooks = {
  # ... existing hooks ...
  my-hook = {
    enable = true;
    entry = "${pkgs.my-tool}/bin/my-tool";
  };
};
```

---

## Migration from Legacy

### Why We Refactored

The original `devenv.nix` was unwieldy:
- **2,579 lines** (92% comments, 7% code)
- **26 embedded scripts** (hard to test individually)
- **Mixed concerns** (languages, packages, hooks, scripts all together)
- **Hard to navigate** (finding specific config required scrolling thousands of lines)

### What Changed

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Main file size** | 2,579 lines | 57 lines | **96% smaller** |
| **Inline scripts** | 26 embedded | 0 | **100% extracted** |
| **Comments in code** | 2,355 lines | 0 | **Moved to docs/** |
| **Files to edit** | 1 giant file | 4 focused modules | **4x more focused** |
| **Testability** | Low (inline) | High (files) | **Major improvement** |

### What Was Preserved

**100% functionality preserved** - no features removed:
- ✅ All 29 scripts work identically
- ✅ All git hooks function the same
- ✅ All packages are available
- ✅ All language configs unchanged

The only difference is **organization**, not functionality.

### Where to Find Things

- **Old file**: Backed up to `devenv.nix.backup`
- **Scripts**: Now in `scripts/` directory (29 files)
- **Language config**: `modules/languages.nix`
- **Package list**: `modules/packages.nix`
- **Script definitions**: `modules/scripts.nix`
- **Git hooks**: `modules/git-hooks.nix`

### Before & After Example

**Adding a new quality script before**:
1. Open 2,579-line `devenv.nix`
2. Scroll to find scripts section (~line 1800)
3. Add inline script definition with heredoc
4. Risk breaking existing scripts
5. Hard to test in isolation

**Adding a new quality script after**:
1. Create `scripts/my-script.sh` (standalone file)
2. Add one line to `modules/scripts.nix`
3. Test script independently
4. Done!

---

**Architecture Version**: 2.0
**Last Updated**: October 2025
**DevEnv Version**: 1.9+
**Status**: Production Ready
