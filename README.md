# nixos-config

NixOS configuration designed for autonomous AI coding -- declarative system state
that AI agents can reason about, kernel-level sandboxing for safe unattended
execution, and atomic rollbacks when things go wrong.

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![CI](https://img.shields.io/github/actions/workflow/status/jacopone/nixos-config/test.yml?style=flat-square&label=CI)](https://github.com/jacopone/nixos-config/actions)
[![License](https://img.shields.io/github/license/jacopone/nixos-config?style=flat-square)](LICENSE)

## Why NixOS for AI agents

| Problem | Traditional OS | NixOS |
|---------|---------------|-------|
| "Works on my machine" | AI generates code depending on implicit system state | Declarative config = AI knows exactly what's installed |
| Dangerous autonomy | `--dangerously-skip-permissions` or click "approve" 50 times | Kernel-level sandbox (bubblewrap + seccomp BPF) |
| Configuration drift | AI edits dotfiles, things break silently | Single source of truth, atomic rollbacks |
| Environment setup | "Install X, then Y, hope versions align" | `nix develop` -- reproducible, every time |
| Packaging AI tools | Pip/npm version hell, broken dependencies | Flake inputs, pinned and auto-updated |

## What this gives you

### Autonomous AI coding with isolation

```bash
# Launch Claude Code in a sandboxed git worktree with auto-retry loop
./scripts/claude-autonomous.sh my-repo feature/add-auth "implement OAuth2 login"
```

This creates an isolated worktree, launches Claude with `--dangerously-skip-permissions`
in tmux, and runs up to 5 iterations with fresh context each pass. Native sandbox
(bubblewrap + seccomp BPF) activates automatically -- spawned processes inherit
the sandbox, no escape via `bash -c` or subprocess chains.

If something goes wrong: `nixos-rebuild switch --rollback`. Done.

### Multi-machine, one repo

Two helper functions -- `mkTechHost` and `mkBusinessHost` -- compose the right
modules for each role:

```
                     hosts/common/base.nix
                     (bootloader, nix, locale, GNOME, Docker)
                            |
               +------------+------------+
               v                         v
      mkTechHost(...)           mkBusinessHost(...)
               |                         |
    350+ packages, full           ~40 packages, office
    AI toolchain, Fish 60+        + learning-to-code
    abbreviations                 simplified shell
```

Adding a machine is one line:

```nix
my-host = mkTechHost { hostname = "my-host"; username = "me"; };
```

Business machines deploy remotely via custom live ISO + RustDesk -- the end
user never touches a terminal. See [INSTALL.md](INSTALL.md) for the full
walkthrough.

### AI toolchain (all as flake inputs)

Every tool pinned, reproducible, and auto-updated via CI:

- **Claude Code** -- Primary agent (via `claude-code-nix`)
- **Cursor** -- AI editor (via [`code-cursor-nix`](https://github.com/jacopone/code-cursor-nix))
- **Antigravity** -- Google's agentic IDE (via [`antigravity-nix`](https://github.com/jacopone/antigravity-nix))
- **Whisper Dictation** -- Local speech-to-text (via [`whisper-dictation`](https://github.com/jacopone/whisper-dictation))
- **ClawNix** -- Self-evolving AI agent platform (via [`clawnix`](https://github.com/jacopone/clawnix))

### Supply chain hardening

8-layer verification built into `rebuild-nixos`:

```bash
./rebuild-nixos --audit          # Export fixed-output derivation manifest
./rebuild-nixos --verify-bootstrap  # Deep reproducibility check (xz, gzip, coreutils)
```

NPM tools version-pinned in `modules/core/npm-versions.nix`. Reproducibility
tracked against [r13y.com](https://r13y.com).

### Tested and CI'd

Unusual for a dotfiles repo:

- **ShellCheck** on all shell scripts
- **BATS** unit tests for `rebuild-nixos`
- **GitHub Actions** on every push
- **Automated security scanning** and dependency updates

## Quick start

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config

# For an existing NixOS machine with flakes:
./rebuild-nixos

# For a new machine, see the full guide:
# INSTALL.md covers fresh install, Framework 16, remote business deploy
```

## Repository structure

```
nixos-config/
├── flake.nix                     # Entry point + mkTechHost/mkBusinessHost
├── rebuild-nixos                 # Multi-phase rebuild with safety checks
├── hosts/
│   ├── common/base.nix           # Shared foundation (boot, nix, GNOME, Docker)
│   ├── tech-001/                 # Framework 16 (AMD Ryzen AI + NVIDIA RTX 5070)
│   ├── biz-001/, biz-002/        # Business workstations
│   └── business-template/        # Template for new deployments
├── modules/
│   ├── core/packages.nix         # System packages (350+)
│   ├── business/                 # Business profile (packages, shell, HM)
│   ├── hardware/                 # Framework 16, ThinkPad, MacBook modules
│   └── home-manager/             # Fish, Kitty, Yazi, dev tools
├── overlays/                     # Custom package overlays
├── scripts/                      # claude-autonomous.sh, rebuild helpers
├── tests/bash/                   # BATS unit tests
├── docs/                         # Guides, architecture, tool configs
└── .github/workflows/            # CI: tests, security, dependency updates
```

## Related repositories

| Repository | Description |
|------------|-------------|
| [clawnix](https://github.com/jacopone/clawnix) | Self-evolving AI agent platform for NixOS |
| [antigravity-nix](https://github.com/jacopone/antigravity-nix) | Nix packaging for Google Antigravity IDE |
| [code-cursor-nix](https://github.com/jacopone/code-cursor-nix) | Nix packaging for Cursor editor |
| [whisper-dictation](https://github.com/jacopone/whisper-dictation) | Local speech-to-text for NixOS |

## License

[MIT](LICENSE)
