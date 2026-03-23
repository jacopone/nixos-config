---
status: active
created: 2024-06-01
updated: 2026-03-23
type: reference
lifecycle: persistent
---

# Changelog

All notable changes to this NixOS configuration.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Security
- Complete 8-layer supply chain hardening implementation:
  - `--audit` flag exports fixed-output derivation (FOD) manifest
  - `--verify-bootstrap` flag for deep reproducibility verification of critical packages
  - Quick reproducibility check for xz/gzip/bzip2/coreutils during audit
  - r13y.com community reproducibility monitoring integration
  - NPM version pinning for 6 tools (claude-flow, bmad-method, gemini-cli, jules, openspec, jscpd)
- New file: `modules/core/npm-versions.nix` - central npm version tracking
- New file: `scripts/update-npm-versions.sh` - version check helper
- New file: `docs/architecture/SUPPLY_CHAIN_HARDENING.md` - architecture documentation

### Added
- `LICENSE` file (MIT) - previously only mentioned in README
- `INSTALL.md` - comprehensive installation guide extracted from README
- `CONTRIBUTING.md` - fork-friendly contribution guidelines
- `SECURITY.md` - security policy (standard for open source projects)
- `docs/README.md` - documentation navigation index
- GitHub repository topics (16 tags for discoverability)
- Multi-profile architecture: `mkTechHost` and `mkBusinessHost` helpers
- Business AI profiles with `aiProfile` parameter (google, claude, both)
- Claude Code guardrail hooks for business profile
- LSP servers for Claude Code plugins (tech profile only)
- ADE upstream monitor systemd timer (twice daily)
- NVIDIA RTD3 disable and display recovery watchdog
- Amatino-repos module: auto-clone, env vars, Claude Code plugin
- Autonomous Claude Code script with git worktree isolation
- Batch scheduling script for overnight autonomous sessions

### Changed
- README refactored for scanability and HN audience
- Repository structure cleaned: removed archive, internal plans, life-context docs
- Fish shell greeting and helpers adapt at Nix build time via `lib.optionalString`
- Kernel pinned to 6.18 (avoids 6.19 amdgpu regressions on Strix Point)
- `amd_pstate=guided` for Framework 16 power management

### Documentation
- Improved repository structure for GitHub discoverability
- Added ecosystem table linking related repositories
- Consolidated features into scannable tables

---

## [2025-10-06]

### Added
- `aitui` fish abbreviation for AI Project Orchestration TUI
- google-jules package via overlay system

### Changed
- Fish abbreviations increased to 58

### Documentation
- Updated stale references and reorganized docs/ directory structure
- Restructured into architecture/, guides/, tools/, and archive/ categories
- Updated all internal markdown links

---

## [2025-10-05]

### Added
- **ai-project-orchestration** integrated as Nix flake package
  - System-wide commands: `ai-project`, `ai-init-greenfield`, `ai-init-brownfield`
  - Complete integration of Spec-Kit + TDD Guard + CCPM
- Comprehensive HN launch plan documentation

### Changed
- Git hooks temporarily disabled in nixos-config devenv
- Template system moved to ai-project-orchestration repository

---

## [2025-10-04]

### Added
- Rich library for Python-native UI in BASB system
- Comprehensive UI and workflow test coverage

### Changed
- BASB system refactored to use Rich instead of Gum for UI

### Fixed
- Chrome detection and deletion reliability in BASB
- Rich color style syntax compatibility
- TTY handling for interactive prompts

---

## [2025-10-03]

### Added
- Chrome bookmarks integration to BASB system
- Automated backup management with cleanup

### Changed
- Claude automation extracted to separate repository (`github:jacopone/claude-nixos-automation`)
- BASB system restructured with proper Python project structure

### Fixed
- Gum choose interactive selection with proper TTY handling

---

## [2025-10-02]

### Added
- Quality gates infrastructure
- Git hooks integration via devenv
- Post-commit auto-documentation system

### Changed
- Git hooks wrapped in devenv shell for tool availability

### Fixed
- ls-lint wrapped in devenv shell for git hooks
- Template devenv package compatibility issues

### Removed
- Python cache files from repository
- Redundant documentation files

---

## Categories Reference

- **Added**: New features, packages, modules, commands
- **Changed**: Modifications to existing functionality
- **Removed**: Deleted features, packages, or code
- **Fixed**: Bug fixes and corrections
- **Security**: Security-related fixes or improvements
- **Documentation**: Changes to documentation only
