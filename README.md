# nixos-config

NixOS as a Claude Code-native operating system -- built with Claude, optimized for Claude, evolving with Claude.

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos)](https://nixos.org)
[![CI](https://img.shields.io/github/actions/workflow/status/jacopone/nixos-config/test.yml?style=flat-square&label=CI)](https://github.com/jacopone/nixos-config/actions)
[![License](https://img.shields.io/github/license/jacopone/nixos-config?style=flat-square)](LICENSE)

This configuration turns NixOS into the ideal platform for AI-assisted development.
Every module, every tool choice, every workflow has been shaped through
hundreds of Claude Code sessions. The result is a system where the OS and
the AI agent reinforce each other -- reproducible environments that Claude
can reason about, sandboxed execution that makes autonomous coding safe,
and declarative configuration that eliminates the drift AI tools struggle with.

## Why NixOS is the ideal OS for AI agents

Traditional operating systems fight AI-assisted development:

| Problem | Traditional OS | NixOS |
|---------|---------------|-------|
| "Works on my machine" | Claude generates code that depends on implicit system state | Declarative config = Claude knows exactly what's installed |
| Dangerous autonomy | `--dangerously-skip-permissions` or click "approve" 50 times | Kernel-level sandboxing with network access preserved |
| Configuration drift | AI edits dotfiles, things break silently | Single source of truth, atomic rollbacks |
| Environment setup | "Install X, then Y, hope versions align" | `nix develop` -- reproducible, every time |
| Testing changes | Every install is permanent | Ephemeral shells -- test anything, discard instantly |

NixOS gives AI agents what they need: a system they can fully understand,
safely modify, and reliably reproduce. This configuration is the implementation
of that idea.

## What's inside

### Multi-profile architecture

One repository, multiple machine roles. Two helper functions -- `mkTechHost` and
`mkBusinessHost` -- compose the right modules for each profile:

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
    abbreviations, custom         simplified shell,
    overlays                      remote setup via ISO
```

Adding a host is three lines in `flake.nix`:

```nix
my-host = mkTechHost { hostname = "my-host"; username = "me"; };
```

### Sandboxed Claude Code

Autonomous AI coding requires isolation. This config provides two modes,
both kernel-enforced:

- **`claude-sandboxed`** -- Namespace isolation + seccomp BPF, network preserved.
  For long-running autonomous tasks with `--dangerously-skip-permissions`.
- **`claude-airgapped`** -- Full isolation, zero network. For offline code review.

Spawned processes inherit the sandbox. No escape via `bash -c` or subprocess chains.

### AI toolchain

The tech profile includes a complete AI development stack as flake inputs --
each pinned, reproducible, and auto-updated:

- **Claude Code** -- Primary development tool (via `claude-code-nix`)
- **Cursor** -- AI editor (via [`code-cursor-nix`](https://github.com/jacopone/code-cursor-nix), maintained by this repo's author)
- **Antigravity** -- Google's agentic IDE (via [`antigravity-nix`](https://github.com/jacopone/antigravity-nix), maintained by this repo's author)
- **Whisper Dictation** -- Local speech-to-text (via [`whisper-dictation`](https://github.com/jacopone/whisper-dictation), maintained by this repo's author)
- **NixClaw** -- Personal AI agent platform (in development)

### Tested and CI'd

Unusual for a dotfiles repo: this configuration has automated testing.

- **ShellCheck** -- Static analysis for all shell scripts
- **BATS** -- Unit tests for `rebuild-nixos` and helper scripts
- **GitHub Actions** -- CI runs on every push and PR
- **Security scanning** -- Automated dependency audits

## Quick start

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config
./rebuild-nixos
```

Requires NixOS with Flakes enabled. The `rebuild-nixos` script handles
validation, building, and optional permission learning in a single interactive flow.

## Repository structure

```
nixos-config/
├── flake.nix                     # Entry point + mkTechHost/mkBusinessHost
├── rebuild-nixos                 # Multi-phase rebuild with safety checks
├── hosts/
│   ├── common/base.nix           # Shared foundation (boot, nix, GNOME, Docker)
│   ├── tech-001/                 # Framework 16 (AMD + NVIDIA RTX 5070)
│   ├── thinkpad-x1-jacopo/       # ThinkPad X1 Carbon
│   ├── biz-001/                  # Business workstation
│   ├── biz-002/                  # Business workstation (remote deploy)
│   └── business-template/        # Template for new business deployments
├── modules/
│   ├── core/packages.nix         # Tech profile packages (350+)
│   ├── business/                 # Business profile (packages, shell, HM)
│   ├── hardware/                 # Vendor-specific hardware modules
│   └── home-manager/             # Tech Home Manager config
├── overlays/                     # Custom Nix package overlays
├── scripts/                      # Automation helpers
├── tests/bash/                   # BATS unit tests
└── .github/workflows/            # CI: tests, security, dependency updates
```

## Related repositories

| Repository | What it does |
|------------|-------------|
| [antigravity-nix](https://github.com/jacopone/antigravity-nix) | Nix packaging for Google Antigravity IDE |
| [code-cursor-nix](https://github.com/jacopone/code-cursor-nix) | Nix packaging for Cursor editor |
| [whisper-dictation](https://github.com/jacopone/whisper-dictation) | Local speech-to-text for NixOS |

## License

[MIT](LICENSE)
