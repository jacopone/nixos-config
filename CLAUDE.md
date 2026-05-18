# CLAUDE.md

> **ClaudeOS** — a reproducible, kernel-sandboxed NixOS fleet maintained by Claude Code.
> One flake provisions every machine in the company: technical workstations and
> business workstations for non-technical users, with declarative state, atomic
> rollback, and supply-chain audit as first-class properties.

## Mission

Build and operate an entire company's computing fleet from one declarative source.
Claude Code is the primary maintainer: it proposes changes, runs them in
kernel-isolated sandboxes, validates reproducibility, and stages them for human
approval. The human approves; NixOS activates atomically; rollback is one command.

This is not a personal dotfiles repo. It is the operating system of a company,
expressed as code, evolved by an AI agent.

## Fleet (Scope)

| Class | Builder | Machines | User profile |
|-------|---------|----------|--------------|
| Personal / technical | `mkTechHost` | `thinkpad-x1-jacopo`, Framework 16, T2 + pre-T2 MacBooks | Maintainer / power users — full AI toolchain, 350+ packages, fish with 60+ abbreviations |
| Business / non-technical | `mkBusinessHost` | `tl-biz-001`, `tl-biz-003`, `tl-biz-004`, `ama-biz-001`, … | Office staff — ~40 curated packages, learning-to-code shell, optional AI profile (`google` / `claude` / `both`) |

Adding a machine is one line in `flake.nix`. Business hosts deploy remotely via
custom live ISO + RustDesk — the end user never touches a terminal. See `INSTALL.md`.

## Invariants Claude must preserve

When making changes, do not break these. They are the contract that makes the
fleet maintainable by an AI agent.

1. **Declarativity** — every package, service, and dotfile in git. No `nix-env -i`,
   no imperative dotfile edits, no out-of-band drift.
2. **Reproducibility** — flake inputs pinned (`flake.lock`); NPM tools pinned
   (`modules/core/npm-versions.nix`). Validate with `nix flake check`; for closure
   changes, suggest `./rebuild-nixos --verify-bootstrap`.
3. **Atomic rollback** — every change produces a coherent generation. If a change
   can't roll back cleanly, redesign it.
4. **Sandbox isolation** — autonomous work runs via `scripts/claude-autonomous.sh`
   in bubblewrap + seccomp BPF worktrees. Spawned processes inherit the sandbox
   (kernel-enforced). Don't bypass.
5. **Supply-chain auditability** — significant input changes warrant
   `./rebuild-nixos --audit`. New flake inputs need a `MAINTAINER:` comment in
   `flake.nix`.
6. **One-line host onboarding** — extending the fleet stays a single
   `mkTechHost` / `mkBusinessHost` call. Don't pierce the abstraction.
7. **Tech ↔ business separation** — business hosts must remain usable by
   non-technical staff. Don't leak tech-host packages into the business profile.
8. **Secrets isolation** — secrets never enter the flake or git. The repo holds
   no credentials, keys, or tokens; sensitive values come from environment
   variables or external secret managers. `sops-nix` / `agenix` for declarative
   secrets are not yet adopted — treat secret introduction as an architectural
   decision, not a quick fix.
9. **Validate beyond syntax** — `nix flake check` validates the flake; it does
   not exercise tools. After non-trivial input changes, build with
   `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` and,
   post-rebuild, exercise the touched surface (open the app, run the CLI).
   Silent regressions in infrequently-used tools are the dominant failure mode
   of an AI-maintained OS.

## Tech Stack

- **OS** — NixOS 25.11 (unstable channel), Nix Flakes
- **Desktop** — GNOME (Wayland). Plasma/Hyprland evaluated and shelved; see auto-memory.
- **Shell** — Fish + Starship
- **Terminal** — Kitty (JetBrains Mono Nerd Font)
- **AI agents** — Claude Code (primary), Cursor, Antigravity, Gemini CLI (business default)
- **Reproducibility** — pinned flake inputs, NPM version pinning, `r13y.com` tracking

## Project Structure

```
flake.nix                         mkTechHost / mkBusinessHost host helpers
rebuild-nixos                     Multi-phase rebuild + safety + supply-chain audit
hosts/
  common/base.nix                 Shared boot, nix, locale, GNOME, Docker
  thinkpad-x1-jacopo/             Personal (mkTechHost)
  tl-biz-*/, ama-biz-*/           Business workstations (mkBusinessHost)
  business-template/              Template for new business deploys
modules/
  core/packages.nix               Tech-host system packages (350+)
  core/npm-versions.nix           Pinned NPM tool versions
  common/packages.nix             Cross-profile shared packages
  business/                       Business profile (packages, HM, chrome-extensions)
  hardware/                       Framework 16, T2 / pre-T2 MacBook, ThinkPad modules
  home-manager/                   Fish, Kitty, Yazi, editors, dev tools, claude-code
profiles/desktop/                 DE composition (base + gnome)
overlays/, pkgs/                  Custom packages and patches
scripts/                          claude-autonomous.sh, restore-machine, EOD/SOD helpers
docs/architecture/                SUPPLY_CHAIN_HARDENING.md, fleet design docs
tests/bash/                       BATS unit tests for rebuild-nixos
```

## Essential Commands

### System Management

- `./rebuild-nixos` — Interactive rebuild with safety checks (preferred)
- `./rebuild-nixos --audit` — Export fixed-output derivation manifest
- `./rebuild-nixos --verify-bootstrap` — Deep reproducibility check (xz, gzip, coreutils)
- `./rebuild-nixos --fresh` — Skip eval cache (after `flake.lock` changes)
- `./rebuild-nixos --boot` — Stage for next reboot (no immediate activation)
- `nix flake check` — Validate configuration
- `nix flake update` — Refresh inputs (weekly cadence)

### Autonomous Work

- `claude` — Interactive (full host access)
- `scripts/claude-autonomous.sh <repo> <task> "<prompt>"` — Sandboxed worktree
  + tmux + Ralph loop (≤5 iterations). Bubblewrap namespace isolation +
  seccomp BPF; spawned processes inherit the sandbox.

## Where to put what

| Change | File |
|--------|------|
| New system tool for tech hosts | `modules/core/packages.nix` |
| New tool for ALL hosts | `modules/common/packages.nix` |
| New tool for business hosts only | `modules/business/packages.nix` |
| User-level program / dotfile | `modules/home-manager/<category>/` |
| Pinned NPM tool | `modules/core/npm-versions.nix` |
| Per-vendor hardware quirk | `modules/hardware/<vendor>.nix` |
| New machine | One line in `flake.nix` (`mkTechHost` or `mkBusinessHost`) |
| Project-scoped tooling | `devenv.nix` or `shell.nix` |

## Code Style

- Follow existing Nix formatting
- Comment WHY (constraint, workaround, regression), not WHAT
- Include source URLs for unfamiliar packages
- Group related packages logically
- New flake inputs need a `MAINTAINER:` comment in `flake.nix`

## Git Workflow

Two-branch model with CI auto-sync:

- **`personal`** — Primary working branch. All development here.
- **`master`** — Public-facing. Auto-synced by CI (squashed + sanitized of personal paths).

### Rules — READ BEFORE ANY GIT OPERATION

- **ALWAYS** work on `personal`. Check with `git branch` before committing.
- **ALWAYS** commit and push to `personal`. **NEVER** push to `master`.
- **NEVER** manually merge, push, or commit to `master` — CI handles this
  (workflow: `.github/workflows/sync-to-master.yml`).
- If on `master`, switch first: `git checkout personal`.
- Applies to all machines (Framework, MacBook, ThinkPad, business hosts).

CI creates new commits on `master` (squashed, sanitized) with different hashes.
Direct pushes to `master` cause conflicts.

## Safety

- `./rebuild-nixos` and `nixos-rebuild` require sudo — Claude must NOT run them.
  Ask the user.
- `nix flake check`, `nix build .#…`, `git add`, edits — Claude can run these
  freely.
- Never `git commit --no-verify` without explicit permission. Fix the underlying
  issue.
- Never create placeholder/fake data — only real data.
- Significant input changes → suggest `./rebuild-nixos --audit`.

## Do Not Touch

- `/etc/nixos/` (this repo replaces it)
- `result*` symlinks (Nix build artifacts)
- `hosts/*/hardware-configuration.nix` (auto-generated per machine)

## 📝 User Memory & Notes
<!-- USER_MEMORY_START -->
<!-- This section preserves your personal notes and #memory entries across rebuilds -->
<!-- Add your content below this line -->
<!-- USER_MEMORY_END -->

---

## Dynamic Context

- **MCP-NixOS** is configured in `.mcp.json` for real-time package/option queries.
- **Auto-memory** — `~/.claude/projects/-home-guyfawkes-nixos-config/memory/MEMORY.md`
  holds fleet-wide patterns, hardware gotchas (Apple T2, Framework 16 power),
  and business AI profile decisions.
- **Analytics** — `.claude/tool-analytics.md`, `.claude/mcp-analytics.md`.
