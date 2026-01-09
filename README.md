---
status: active
created: 2024-06-01
updated: 2025-12-31
type: reference
lifecycle: persistent
---

# Intelligent Permission Learning for Claude Code

> Your NixOS system learns which commands to auto-approve, reducing friction without compromising security

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![Claude Code](https://img.shields.io/badge/Claude-Code-5A67D8.svg?style=flat-square&logo=anthropic)](https://claude.ai)
[![License](https://img.shields.io/github/license/jacopone/nixos-config?style=flat-square)](LICENSE)

## The Problem

Every Claude Code session:

```
Allow "git status"? [y/n]
Allow "fd -e py"? [y/n]
Allow "rg TODO"? [y/n]
... 47 more prompts ...
```

**Your options:**
1. Click approve 50+ times per session (tedious)
2. Use `--dangerously-skip-permissions` (security nightmare)
3. Manually maintain permission configs (never stays current)

**This project adds Option 4:** Let your system learn what's safe.

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│  YOUR WORKFLOW                                                  │
│                                                                 │
│  You approve "git status" → System logs it                      │
│  You approve "fd -e nix" → System logs it                       │
│  You approve "rg pattern" → System logs it                      │
│         ...50+ approvals across sessions...                     │
│                                                                 │
│  ./rebuild-nixos runs → Adaptive learning triggers              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Pattern detected: "git *" approved 89 times (98% rate)  │   │
│  │ Confidence: 0.94                                        │   │
│  │ → Auto-generate: allow Bash(git:*)                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Next session: "git status" auto-approved. No prompt.           │
└─────────────────────────────────────────────────────────────────┘
```

**Result:** Permission prompts decrease over time as the system learns your workflow.

## Key Features

### 1. Adaptive Permission Learning

The system analyzes your approval history and auto-generates permission rules:

- **Pattern detection** from actual behavior (not guesswork)
- **Confidence scoring** (only high-confidence patterns become rules)
- **Audit trail** in `.claude/permissions_auto_generated.md`
- **Interactive review** before applying suggestions

```bash
./rebuild-nixos
# Step 6/6: Adaptive learning
# Found 3 permission patterns:
#   [1] Bash(git:*) - 94% confidence
#   [2] Bash(fd:*) - 87% confidence
#   [3] Read(/home/user/projects/**) - 91% confidence
# Apply these? [y/n/review each]
```

### 2. Zero-Drift Documentation

System state automatically syncs to Claude's knowledge:

```
packages.nix changes → ./rebuild-nixos → CLAUDE.md updated
```

- **No manual docs** to maintain
- **Every tool** extracted with descriptions
- **Always current** - impossible to drift

### 3. Ephemeral Testing (NixOS-Specific)

Test anything without polluting your system:

```bash
# Test with pytest without installing it globally
nix shell nixpkgs#pytest --command pytest tests/

# Enter a reproducible dev environment
nix develop

# Exit → system unchanged. No cleanup needed.
```

**Why this matters:**
- macOS: `pip install pytest` → permanent system change
- Ubuntu: `apt install python3-pytest` → permanent system change
- NixOS: `nix shell` → temporary, atomic, reversible

### 4. Usage Analytics

Data-driven decisions about your tools:

```
Tool Usage Report (30 days)
──────────────────────────────────────
Installed: 131 tools
Used: 34 (26%)
Dormant: 97 tools (candidates for removal)

Top tools (Human vs Claude):
  git     H:28  C:989
  fd      H:0   C:152
  rg      H:0   C:100
```

## Why NixOS?

This system requires NixOS because:

| Capability | NixOS | macOS/Ubuntu |
|------------|-------|--------------|
| Atomic rebuilds | Switch or rollback completely | Partial state changes |
| Reproducible environments | `flake.lock` pins exact versions | "Works on my machine" |
| Ephemeral shells | `nix shell` - test without installing | Every install is permanent |
| Declarative config | Single source of truth | Scattered across dotfiles |
| Pure derivations | Same inputs = same outputs | Build depends on system state |

## Quick Start

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config
./rebuild-nixos
```

**Requirements:** NixOS with Flakes enabled, 8GB+ RAM
**Time:** ~20 minutes first build

**[Full Installation Guide →](INSTALL.md)**

## The Ecosystem

| Repository | Purpose |
|------------|---------|
| [nixos-config](https://github.com/jacopone/nixos-config) | System config + `rebuild-nixos` orchestration |
| [claude-nixos-automation](https://github.com/jacopone/claude-nixos-automation) | **The brain:** Permission learning, analytics, CLAUDE.md generation |

## How It Differs from Alternatives

| Feature | This Project | mcp-nixos | nixai | Manual Config |
|---------|-------------|-----------|-------|---------------|
| Permission auto-learning | From behavior | - | - | - |
| Zero-drift docs | Automatic | - | - | Manual |
| Ephemeral testing | Nix shells | N/A | - | - |
| Tool analytics | H vs C usage | - | - | - |
| NixOS package info | Via automation | MCP | Yes | - |

## What's Included

<details>
<summary><strong>Modern CLI Stack (130+ tools)</strong></summary>

**Replacements for POSIX defaults:**
| Old | New | Why |
|-----|-----|-----|
| `find` | `fd` | 5x faster, better syntax |
| `ls` | `eza` | Icons, git status |
| `cat` | `bat` | Syntax highlighting |
| `grep` | `rg` | 10x faster |
| `du` | `dust` | Visual, interactive |

**AI Development:**
- Claude Code, Cursor, Antigravity, Gemini CLI, Jules, Droid
- `claude-sandboxed` / `claude-airgapped` - Bubblewrap sandboxing for autonomous tasks

**Development:**
- DevEnv, Direnv, Fish shell, Kitty terminal, GNOME (Wayland)

See [`modules/core/packages.nix`](modules/core/packages.nix) for the complete list.

</details>

## Repository Structure

```
nixos-config/
├── flake.nix                      # Main entry point
├── rebuild-nixos                  # 14-phase rebuild with learning
├── modules/
│   ├── core/packages.nix          # System tools (130+)
│   └── home-manager/              # User configurations
├── CLAUDE.md                      # Auto-generated AI context
└── .claude/
    ├── settings.local.json        # Auto-generated permissions
    └── permissions_auto_generated.md  # Audit trail
```

## Essential Commands

```bash
# System rebuild with permission learning
./rebuild-nixos

# Quick rebuild (skip cleanup phases)
./rebuild-nixos --quick

# Validate configuration
nix flake check

# Ephemeral testing
nix shell nixpkgs#python312 --command python
```

## Sandboxed Claude Code

For long-running autonomous tasks, use kernel-level isolation via [bubblewrap](https://github.com/containers/bubblewrap):

| Command | Network | Use Case |
|---------|---------|----------|
| `claude` | Full | Normal interactive use |
| `claude-sandboxed` | API only | Autonomous tasks with `--dangerously-skip-permissions` |
| `claude-airgapped` | None | Code review, offline analysis |

```bash
# Run Claude in sandbox for autonomous work
claude-sandboxed ~/my-project --dangerously-skip-permissions

# Fully airgapped for security-sensitive code review
claude-airgapped ~/my-project
```

**Security features:**
- Process/IPC/UTS namespace isolation (`--unshare-pid`, `--unshare-ipc`, `--unshare-uts`)
- Filesystem restricted to project directory + `~/.claude` only
- All Linux capabilities dropped (`--cap-drop ALL`)
- Spawned processes inherit sandbox (kernel-enforced, not bypassable)

## Documentation

| Guide | Description |
|-------|-------------|
| [INSTALL.md](INSTALL.md) | Full installation and setup |
| [THE_CLOSED_LOOP.md](docs/architecture/THE_CLOSED_LOOP.md) | How auto-documentation works |
| [COMMON_TASKS.md](docs/guides/COMMON_TASKS.md) | Quick reference for daily use |

## Contributing

This is a personal configuration shared for learning and inspiration.

- **Fork** and adapt for your setup
- **Star** if you find it useful
- **Issues** for bugs or suggestions

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

[MIT License](LICENSE)

---

<div align="center">

**Permission learning that gets smarter with every session**

[Quick Start](#quick-start) · [Documentation](#documentation) · [Report Issue](https://github.com/jacopone/nixos-config/issues)

</div>
