# Changelog

All notable changes to this NixOS configuration.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- User policies merge refactoring for claude-automation
- Justfile for common tasks
- Improved documentation structure

---

## [2025-10-06]

### Added
- `aitui` fish abbreviation for AI Project Orchestration TUI
- google-jules package via overlay system
- System now at 122 packages total

### Changed
- Fish abbreviations increased to 58

---

## [2025-10-05]

### Added
- **ai-project-orchestration** integrated as Nix flake package
  - System-wide commands: `ai-project`, `ai-init-greenfield`, `ai-init-brownfield`
  - Complete integration of Spec-Kit + TDD Guard + CCPM
- TDD Guard integration in ai-quality-devenv template
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
- Improved Python-native interaction patterns

### Fixed
- Chrome detection and deletion reliability in BASB
- Rich color style syntax compatibility across all formats
- TTY handling for interactive prompts

---

## [2025-10-03]

### Added
- Chrome bookmarks integration to BASB system
- Automated backup management with cleanup in BASB
- Directory detection in claude-automation

### Changed
- Claude automation extracted to separate repository (`github:jacopone/claude-nixos-automation`)
- BASB system restructured with proper Python project structure
- Switched claude-automation to GitHub URL flake input

### Fixed
- Gum choose interactive selection with proper TTY handling

---

## [2025-10-02]

### Added
- Quality gates infrastructure for nixos-config
- Git hooks integration via devenv
- Post-commit auto-documentation system
- Quality dashboard with new metrics
- Documentation/structure/naming target support

### Changed
- Git hooks wrapped in devenv shell for tool availability
- Auto-update CLAUDE.md system integrated

### Fixed
- ls-lint wrapped in devenv shell for git hooks
- Complete devenv git-hooks solution
- Template devenv package compatibility issues

### Removed
- Python cache files from repository
- Redundant documentation files

### Documentation
- Comprehensive git hooks and devenv integration guide
- Updated README with new features
- AUTONOMOUS_REMEDIATION.md updated with new phases

---

## Categories Reference

Changes are categorized as follows:

- **Added**: New features, packages, modules, commands
- **Changed**: Modifications to existing functionality
- **Deprecated**: Soon-to-be removed features (warnings)
- **Removed**: Deleted features, packages, or code
- **Fixed**: Bug fixes and corrections
- **Security**: Security-related fixes or improvements
- **Documentation**: Changes to documentation only
- **Performance**: Performance improvements

---

## Maintenance Notes

### How to Update This File

When making changes:

1. Add entry under `[Unreleased]` during development
2. When running `./rebuild-nixos`, move unreleased items to dated section
3. Use conventional commit format for consistency
4. Group related changes together

### Example Entry

```markdown
## [YYYY-MM-DD]

### Added
- New package X for Y functionality
- Fish abbreviation `foo` → `bar`

### Changed
- Updated flake input X to version Y

### Fixed
- Issue with Z configuration
```

### Git Commit to Changelog Mapping

- `feat:` → **Added** or **Changed**
- `fix:` → **Fixed**
- `docs:` → **Documentation**
- `refactor:` → **Changed**
- `perf:` → **Performance**
- `chore:` → **Changed** or appropriate category
- `security:` → **Security**

---

**Last Updated**: 2025-10-06
**System Version**: NixOS 25.11 (unstable)
**Total Packages**: 122
