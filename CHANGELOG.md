---
status: active
created: 2024-06-01
updated: 2025-12-18
type: reference
lifecycle: persistent
---

# Changelog

All notable changes to this NixOS configuration.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- `LICENSE` file (MIT) - previously only mentioned in README
- `INSTALL.md` - comprehensive installation guide extracted from README
- `CONTRIBUTING.md` - fork-friendly contribution guidelines
- `SECURITY.md` - security policy (standard for open source projects)
- `docs/README.md` - documentation navigation index
- GitHub repository topics (16 tags for discoverability)
- Demo GIF (`docs/assets/rebuild-demo.gif`) showing closed-loop workflow

### Changed
- README refactored from 445 → 189 lines for better scanability
- Repository description updated for SEO
- VHS demo script updated with real command examples
- README now emphasizes intelligent automation over tool count
- Key Features table highlights permission learning, analytics, suggestions
- Added "How It Works" section explaining claude-nixos-automation integration
- Ecosystem table expanded with better descriptions of each repo's role
- AI Tools list updated (removed aider, added jules/droid/opencode)
- Tool count standardized to 145 across all documentation

### Documentation
- Improved repository structure for GitHub discoverability
- Added ecosystem table linking related repositories
- Consolidated features into scannable tables
- Moved `THE_CLOSED_LOOP.md` to `docs/architecture/`
- Moved CI/CD docs to proper folders (`docs/guides/`, `docs/integrations/`)
- Archived 71-day-old HN planning docs to `docs/archive/2025-10-planning/`
- Archived draft automation docs (MCP, N8N, Google Drive)
- Fixed broken link to non-existent `CORE_THESIS.md`

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8
- add ThinkPad power and GPU optimizations

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)
- remove thermald (ThinkPad DYTC handles thermals)
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8
- add ThinkPad power and GPU optimizations

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)
- remove thermald (ThinkPad DYTC handles thermals)
  (Test: Verify the previous issue is resolved)
- tune i915 kernel params for video playback stability
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8
- add ThinkPad power and GPU optimizations

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)
- remove thermald (ThinkPad DYTC handles thermals)
  (Test: Verify the previous issue is resolved)
- tune i915 kernel params for video playback stability
  (Test: Verify the previous issue is resolved)
- stabilize bluetooth audio and battery charging
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8
- add ThinkPad power and GPU optimizations

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption
- remove 8 redundant CLI tools
- remove 3 more redundant tools
- remove redundant image viewers

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)
- remove thermald (ThinkPad DYTC handles thermals)
  (Test: Verify the previous issue is resolved)
- tune i915 kernel params for video playback stability
  (Test: Verify the previous issue is resolved)
- stabilize bluetooth audio and battery charging
  (Test: Verify the previous issue is resolved)
- disable WirePlumber auto headset profile switching
  (Test: Verify the previous issue is resolved)
- keep feh as yazi secondary opener, remove sxiv
  (Test: Verify the previous issue is resolved)

### Added
- add command tracking system to home-manager
- integrate automation updates and add transparency to rebuild-nixos
- re-enable pymupdf4llm and improve automation transparency
  (Test: `which pymupdf4llm` or `pymupdf4llm --version`)
- enhance rebuild-nixos with MCP session utilization display
- show global vs project-level MCP server breakdown in rebuild
- show project-level MCP server locations in rebuild
- optimize MCP scope, add AI tools, integrate adaptive learning
  (Test: `which AI` or `AI --version`)
- integrate intelligent data lifecycle management into rebuild-nixos
  (Test: `which integrate` or `integrate --version`)
- use local flake for all automation commands in rebuild-nixos
- add opencode AI agent and improve rebuild-nixos error handling
  (Test: `which opencode` or `opencode --version`)
- add tool usage analytics and fix rebuild-nixos stat extraction
- Update cursor-nix with Chrome browser automation support
- add NordVPN support via wgnord WireGuard client
  (Test: `which NordVPN` or `NordVPN --version`)
- add Google Antigravity IDE and enhance document processing
  (Test: `which Google` or `Google --version`)
- add Google Antigravity IDE with FHS environment
- enable ADB for Android development
  (Test: Connect Android device, run `adb devices`)
- add wl-clipboard and kooha, simplify fish config
  (Test: Launch from application menu, verify recording works)
- add changelog generation workflow to rebuild-nixos
- add automatic hook deployment to Phase 8
- add ThinkPad power and GPU optimizations
- add nom build visualization and polished UX
  (Test: `which nom` or `nom --version`)

### Changed
- consolidate Python invocations in session lifecycle (600ms speedup) (performance improvement)
- modularize home-manager config & security fixes (restructured)
- add Claude Code configuration analysis and update system state
- major code quality improvements - portability, security, and organization (restructured)
- install pre-commit hooks and apply code quality fixes
- add openspec tool and simplify rebuild script
- add OnlyOffice and improve rebuild GC output
- remove personal content for public adoption
- remove 8 redundant CLI tools
- remove 3 more redundant tools
- remove redundant image viewers
- remove redundant packages, exclude GNOME Showtime

### Fixed
- add complete YAML frontmatter to slash command files
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in warning count extraction
  (Test: Verify the previous issue is resolved)
- parse MCP stats from .claude/mcp-analytics.md instead of CLAUDE.md
  (Test: Verify the previous issue is resolved)
- extract system tools stats from CLAUDE.md instead of automation logs
  (Test: Verify the previous issue is resolved)
- handle grep -c exit code in server count extraction
  (Test: Verify the previous issue is resolved)
- remove timeout from adaptive learning cycle for interactive mode
  (Test: Verify the previous issue is resolved)
- use local flake for check-data-health instead of GitHub
  (Test: Verify the previous issue is resolved)
- improve MCP statistics display and lifecycle warning accuracy
  (Test: Verify the previous issue is resolved)
- resolve Fish variable expansion in GitHub workflow functions
  (Test: Verify the previous issue is resolved)
- add smart flake update logic to prevent stale cache issues
  (Test: Verify the previous issue is resolved)
- resolve pre-commit NixOS compatibility issue
  (Test: Verify the previous issue is resolved)
- resolve nix flake check failure in GitHub Actions
  (Test: Verify the previous issue is resolved)
- replace deprecated pkgs.system with pkgs.stdenv.hostPlatform.system
  (Test: Verify the previous issue is resolved)
- resolve antigravity-nix narHash mismatch in rebuild script
  (Test: Verify the previous issue is resolved)
- update script paths for claude-nixos-automation refactor
  (Test: Verify the previous issue is resolved)
- use nix run for health check in rebuild script
  (Test: Verify the previous issue is resolved)
- use nix run for tool analytics invocation
  (Test: Verify the previous issue is resolved)
- skip path inputs in update-dependencies workflow
  (Test: Verify the previous issue is resolved)
- convert path inputs to GitHub URLs for CI compatibility
  (Test: Verify the previous issue is resolved)
- correct broken THE_CLOSED_LOOP.md link in README
  (Test: Verify the previous issue is resolved)
- resolve critical issues from system review
  (Test: Verify the previous issue is resolved)
- remove thermald (ThinkPad DYTC handles thermals)
  (Test: Verify the previous issue is resolved)
- tune i915 kernel params for video playback stability
  (Test: Verify the previous issue is resolved)
- stabilize bluetooth audio and battery charging
  (Test: Verify the previous issue is resolved)
- disable WirePlumber auto headset profile switching
  (Test: Verify the previous issue is resolved)
- keep feh as yazi secondary opener, remove sxiv
  (Test: Verify the previous issue is resolved)
- resolve UI glitches in rebuild-nixos summary
  (Test: Verify the previous issue is resolved)
- use --out-link for nom build visualization
  (Test: Verify the previous issue is resolved)

### Added
- add context hook, session recording, and optimization notes
  (Test: `which context` or `context --version`)
- add personal→master auto-sync with sanitization
- handle file deletions in sync workflow

### Fixed
- always sanitize CLAUDE.md USER_MEMORY section
  (Test: Verify the previous issue is resolved)
- use commit-based filtering instead of date-based
  (Test: Verify the previous issue is resolved)

### Fixed
- use merge-base for diverged branch comparison
  (Test: Verify the previous issue is resolved)
- allow workflow files through personal paths filter
  (Test: Verify the previous issue is resolved)
- detect files only on master for deletion
  (Test: Verify the previous issue is resolved)

### Fixed
- actually delete npm cache instead of fake clean
  (Test: Verify the previous issue is resolved)
- commit devenv.lock for reproducible environments
  (Test: Verify the previous issue is resolved)
- escape dots in skip patterns to not match devenv.lock
  (Test: Verify the previous issue is resolved)
- resolve GCC 15 and nixos-unstable build failures
  (Test: Verify the previous issue is resolved)

### Added
- add uv package manager for MCP server support
  (Test: `which uv` or `uv --version`)

### Fixed
- add disk cleanup for performance benchmark
  (Test: Verify the previous issue is resolved)
- add --fallback and better error reporting for benchmark
  (Test: Verify the previous issue is resolved)

### Fixed
- make performance benchmark non-blocking on upstream issues
  (Test: Verify the previous issue is resolved)
- add devenv hook for use_devenv support
  (Test: Verify the previous issue is resolved)

### Planned
- User policies merge refactoring for claude-automation
- Justfile for common tasks

---

## [2025-10-06]

### Added
- `aitui` fish abbreviation for AI Project Orchestration TUI
- google-jules package via overlay system
- System now at 122 packages total

### Changed
- Fish abbreviations increased to 58

### Documentation
- **Phase 1: Fixed Stale References**
  - Updated CLAUDE_ORCHESTRATION.md to reflect claude-automation extraction (2025-10-03)
  - Updated README.md automation reference to external repository
  - Deprecated docs/automation/claude-automation-system.md with redirect to external repo
  - Deleted empty templates/ai-quality-devenv/ directory (superseded by ai-project-orchestration)
  - Added comprehensive documentation audit report

- **Phase 2: Documentation Reorganization**
  - Restructured docs/ with clear category separation:
    - `docs/architecture/` - System architecture (CLAUDE_ORCHESTRATION.md)
    - `docs/guides/` - User guides (COMMON_TASKS.md)
    - `docs/integrations/` - External integrations (CURSOR_AI_QUALITY_INTEGRATION.md)
    - `docs/automation/` - Automation systems
    - `docs/planning/active/` - Active plans (HN_LAUNCH_PLAN.md)
    - `docs/planning/archive/` - Completed plans
    - `docs/tools/` - Tool-specific guides
    - `docs/archive/` - Historical documentation
  - Updated all internal markdown links to reflect new structure
  - Updated README.md repository structure diagram
  - Added User Guides section to documentation index

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
