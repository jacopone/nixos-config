---
status: draft
created: 2026-02-16
updated: 2026-02-16
type: planning
lifecycle: ephemeral
---

# README Overhaul Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite all public repository READMEs to present a strong full-stack entrepreneur profile for YC partner visibility.

**Architecture:** Each repo gets a per-repo optimized README. nixos-config is the flagship with a "NixOS as Claude Code-native OS" narrative. Other repos are polished individually based on their audience and purpose. Clean & professional tone throughout (no emojis, minimal badges, confident prose).

**Tech Stack:** Markdown, GitHub CLI (`gh`), git

**Design doc:** `docs/plans/2026-02-16-readme-overhaul-design.md`

---

### Task 1: Rewrite nixos-config README

**Files:**
- Modify: `README.md` (complete rewrite)

**Step 1: Write the new README**

Replace the entire contents of `README.md` with this:

````markdown
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
````

**Step 2: Verify the README renders correctly**

Run: `glow README.md | head -60`
Expected: Clean rendering with table, code blocks, and tree structure intact.

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README with Claude Code-native NixOS narrative"
```

---

### Task 2: Update nixos-config GitHub repo metadata

**Files:** None (GitHub API only)

**Step 1: Update repo description and topics**

```bash
gh repo edit jacopone/nixos-config \
  --description "Declarative NixOS configuration -- Claude Code-native developer workstations with kernel-level sandboxing, multi-host architecture, and reproducible AI toolchain" \
  --add-topic nixos-config \
  --remove-topic automation
```

**Step 2: Verify**

```bash
gh api repos/jacopone/nixos-config --jq '{description: .description, topics: .topics}'
```

Expected: New description visible, topics updated.

---

### Task 3: Polish antigravity-nix README

**Context:** 95 stars -- your most popular repo. Currently solid but verbose. This is a Nix packaging repo, so the audience is NixOS users looking for a quick install.

**Files:**
- Modify: README.md in the `antigravity-nix` repo (clone or use `gh`)

**Step 1: Clone the repo locally**

```bash
cd /tmp && gh repo clone jacopone/antigravity-nix && cd antigravity-nix
```

**Step 2: Rewrite the README**

Key changes:
- Keep the overview structure (it works)
- Remove Chrome integration details (too niche for the opening)
- Tighten the "Overview" bullets to 4 max
- Add a one-line pitch under the title: "Auto-updating Nix Flake for Google Antigravity -- zero configuration, multi-platform, version-pinned."
- Keep NixOS + Home Manager install examples (they are the main value)
- Remove any verbose Chrome wrapper documentation, move to a USAGE.md if needed
- Trim the README to ~120 lines max
- Keep existing badges (they work)
- Ensure the closing section mentions this is actively maintained with 3x/week auto-updates

**Step 3: Commit and push**

```bash
git add README.md
git commit -m "docs: tighten README for clarity"
git push
```

---

### Task 4: Polish whisper-dictation README

**Context:** 6 stars. Currently very detailed but too long (~300 lines) with extensive troubleshooting. The audience is NixOS users who want local speech-to-text.

**Files:**
- Modify: README.md in the `whisper-dictation` repo

**Step 1: Clone the repo locally**

```bash
cd /tmp && gh repo clone jacopone/whisper-dictation && cd whisper-dictation
```

**Step 2: Rewrite the README**

Key changes:
- Remove all emojis (clean & professional tone)
- Pitch line: "Privacy-first local speech-to-text for NixOS -- whisper.cpp powered, push-to-talk, paste anywhere."
- Keep the feature bullets but remove emojis, tighten to one line each
- Keep NixOS install + Manual install sections
- Collapse the 4-option "Daily Usage" section into just one primary method
- Move model selection guide into a `<details>` block (useful but not front-page)
- Move the full Troubleshooting section to a TROUBLESHOOTING.md and link to it
- Move the full Configuration section to the existing DEVELOPMENT.md or a CONFIG.md
- Keep the comparison table (strong signal vs competitors)
- Remove the Roadmap section (promises without delivery look bad to YC)
- Remove "Made with heart for NixOS community" footer
- Remove the Acknowledgments section (keep it in LICENSE or DEVELOPMENT.md)
- Target: ~150 lines max

**Step 3: Commit and push**

```bash
git add README.md
git commit -m "docs: tighten README, move details to supporting docs"
git push
```

---

### Task 5: Polish code-cursor-nix README

**Context:** 4 stars. Functional Nix packaging README. Similar structure to antigravity-nix.

**Files:**
- Modify: README.md in the `code-cursor-nix` repo

**Step 1: Clone the repo locally**

```bash
cd /tmp && gh repo clone jacopone/code-cursor-nix && cd code-cursor-nix
```

**Step 2: Rewrite the README**

Key changes:
- Same treatment as antigravity-nix: tighten overview, keep install examples
- Pitch line: "Auto-updating Nix Flake for Cursor AI editor -- AppImage extraction, FHS environment, browser automation included."
- Keep existing badges
- Trim Chrome integration details (move to usage section if needed)
- Target: ~100 lines max

**Step 3: Commit and push**

```bash
git add README.md
git commit -m "docs: tighten README for clarity"
git push
```

---

### Task 6: Polish bpkit README

**Context:** 0 stars. "Business plan to constitution" tool. Interesting concept but README is dense.

**Files:**
- Modify: README.md in the `bpkit` repo

**Step 1: Clone the repo locally**

```bash
cd /tmp && gh repo clone jacopone/bpkit && cd bpkit
```

**Step 2: Rewrite the README**

Key changes:
- Rename display title to "BPKit" (cleaner than "BP-to-Constitution")
- Pitch line: "Transform business plans into executable MVP specifications for AI agents."
- Keep the closed-loop diagram (it communicates the concept well)
- Add a quick start section if missing
- Remove any references to Sequoia Capital template in the opening (looks presumptuous)
- Keep it tight: ~80-100 lines

**Step 3: Commit and push**

```bash
git add README.md
git commit -m "docs: rewrite README with clearer positioning"
git push
```

---

### Task 7: Polish brownkit README

**Context:** 0 stars. Brownfield companion to Spec-Kit. Has badges, decent structure.

**Files:**
- Modify: README.md in the `brownkit` repo

**Step 1: Clone the repo locally**

```bash
cd /tmp && gh repo clone jacopone/brownkit && cd brownkit
```

**Step 2: Rewrite the README**

Key changes:
- Remove all emojis from badges and headers
- Keep the pipeline diagram (Messy Code -> BrownKit -> Clean Code -> Spec-Kit)
- Tighten prose, remove marketing fluff
- Ensure quick start is prominent
- Target: ~100 lines

**Step 3: Commit and push**

```bash
git add README.md
git commit -m "docs: clean up README, remove emojis"
git push
```

---

### Task 8: Polish italian-real-estate-prices README

**Context:** 0 stars. Data science / ML project. Different audience (quantitative). The results table is the star.

**Files:**
- Modify: README.md in the `italian-real-estate-prices` repo

**Step 1: Clone the repo locally**

```bash
cd /tmp && gh repo clone jacopone/italian-real-estate-prices && cd italian-real-estate-prices
```

**Step 2: Rewrite the README**

Key changes:
- Keep the results tables (they are the selling point -- real numbers)
- Add a pitch line: "ML system for Italian real estate price analysis using demographic, economic, and tourism data."
- Ensure there is a quick start / reproduction section
- Add a brief methodology section if missing
- This is one of the most interesting repos for YC partners (shows data/ML chops) -- make it shine
- Target: ~120 lines

**Step 3: Commit and push**

```bash
git add README.md
git commit -m "docs: improve README with methodology and clearer structure"
git push
```

---

### Task 9: Polish remaining repos (low priority batch)

**Context:** mcp-sunsama, whatsapp-mcp, digital-invoice-to-pdf. These are forks or minor utilities.

**Files:**
- Modify: README.md in each repo

**Step 1: Quick pass on each**

For each repo:
- Ensure there is a clear one-line description
- Remove any broken links or stale references
- Add a "Quick start" if missing
- Keep it minimal (these are not portfolio centerpieces)
- If a repo is a fork (mcp-sunsama, whatsapp-mcp), ensure attribution is clear and your modifications are highlighted

**Step 2: Commit and push each**

```bash
git add README.md
git commit -m "docs: clean up README"
git push
```

---

### Task 10: Update GitHub profile metadata for all repos

**Files:** None (GitHub API only)

**Step 1: Update descriptions for repos with missing or outdated descriptions**

```bash
# bpkit (currently empty description)
gh repo edit jacopone/bpkit --description "Transform business plans into executable MVP specifications for AI coding agents"

# mcp-sunsama (currently empty)
gh repo edit jacopone/mcp-sunsama --description "MCP server for Sunsama task management -- create, read, update tasks via AI assistants"

# digital-invoice-to-pdf (currently empty)
gh repo edit jacopone/digital-invoice-to-pdf --description "Convert Italian digital invoice XML to PDF"
```

**Step 2: Verify all repos have descriptions**

```bash
gh repo list --visibility=public --json name,description --limit 20
```

Expected: Every repo has a non-empty description.

---

### Task 11: Final review pass

**Step 1: Open each repo's GitHub page and verify README renders**

Visit each URL and confirm:
- No broken badges
- Tables render correctly
- Code blocks have proper syntax highlighting
- No broken links
- Description matches README narrative

**Step 2: Push nixos-config changes**

```bash
cd ~/nixos-config
git push
```
