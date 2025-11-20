---
status: active
created: 2025-10-08
updated: 2025-10-08
type: reference
lifecycle: persistent
---

# Active NixOS Packages

*Tracking installed packages with rationale and usage*

**Last Updated**: $(date)
**Total Packages**: Auto-counted by script

---

## 🚀 Development Tools

### Core Editors
- **helix** - Primary modal editor, fast Rust-based
  - Added: 2024-01-01
  - Usage: Daily, 80% of text editing
  - Alternative to: Vim/Neovim

- **zed-editor** - Secondary AI-enhanced editor
  - Added: 2024-01-15
  - Usage: AI pair programming sessions
  - Alternative to: VSCode for AI features

- **vscode-fhs** - Full VSCode for complex projects
  - Added: 2023-12-01
  - Usage: Large codebases, debugging
  - Extension ecosystem needed

### Language Tools
- **nodejs_20** - Node.js runtime
  - Added: System default
  - Usage: Build tools, npm packages
  - Version: 20.19.4 LTS

- **python3** - Python runtime
  - Added: System default
  - Usage: Scripts, AI tools, build systems
  - Critical dependency

---

## 🛠️ System Utilities

### File Management
- **yazi** - Terminal file manager with rich preview
  - Added: 2024-01-01
  - Usage: Daily file operations
  - Alternative to: ranger, nnn
  - Plugins: rich-preview, file icons

- **eza** - Modern ls replacement
  - Added: 2024-01-01
  - Usage: Directory listing (aliased to ls)
  - Alternative to: ls, exa
  - Features: Git integration, icons

### Search & Text Processing
- **ripgrep** - Super fast grep alternative
  - Added: 2024-01-01
  - Usage: Code search, file content search
  - Alternative to: grep, ag
  - Performance: 10x faster than grep

- **fd** - Modern find alternative
  - Added: 2024-01-01
  - Usage: File name search
  - Alternative to: find
  - Features: Respect .gitignore, parallel

---

## 🎨 Media & Graphics

### Image Processing
- **imagemagick** - Image manipulation toolkit
  - Added: 2024-01-01
  - Usage: Yazi previews, batch processing
  - Critical for: File manager functionality

### Viewers
- **eog** - Eye of GNOME image viewer
  - Added: System default
  - Usage: Primary image viewing
  - Integration: GNOME desktop

---

## 📊 Package Health Metrics

### Usage Categories
- **Daily Use**: X packages
- **Weekly Use**: X packages
- **Monthly/Rare**: X packages ⚠️ Review candidates
- **Dependencies**: X packages (required by others)

### Installation Sources
- **System packages**: X packages (environment.systemPackages)
- **Home Manager**: X packages (home.packages)
- **Dev shells**: X packages (devenv/flake.nix)

### Size Impact
- **Large packages** (>100MB): List top 5
- **Total system size**: Auto-calculated
- **Last cleanup**: Date of last garbage collection

---

## 🔄 Package Lifecycle

### Adding Packages
1. Add to appropriate category in `modules/core/packages.nix` or `modules/home-manager/base.nix`
2. Document rationale in this file
3. Test with `nixos-rebuild test`
4. Commit with clear message

### Review Process
- **Monthly**: Check unused packages
- **Quarterly**: Evaluate alternatives
- **After major updates**: Verify all packages still needed

### Removal Process
1. Remove from NixOS configuration
2. Test rebuild
3. Document in `deprecated/` if significant
4. Run garbage collection
