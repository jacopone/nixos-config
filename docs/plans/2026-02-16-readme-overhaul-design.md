---
status: draft
created: 2026-02-16
updated: 2026-02-16
type: planning
lifecycle: ephemeral
---

# README Overhaul Design

## Goal

Rewrite public repository READMEs to present a strong "full-stack entrepreneur" profile for YC partner visibility. Start with nixos-config, then tackle remaining public repos.

## Audience

YC partners scanning a GitHub profile. They look for: clarity of thought, engineering discipline, ability to ship across domains.

## Design Decisions

### Narrative: NixOS as Claude Code-native OS

The nixos-config README is reframed from "permission learning for Claude Code" to "NixOS purpose-built for AI-assisted development." The entire repo is both the product and the demonstration of building with Claude.

Key pitch: "Built with Claude, optimized for Claude, evolving with Claude."

### Tone: Clean & Professional

Minimal badges, clear sections, confident prose, no emojis. Like Vercel/Stripe repos. Let the architecture speak.

### Per-repo optimization (not forced consistency)

Each README is optimized for its own audience. No shared template across repos.

## nixos-config README Structure

### 1. Header + Pitch

- Title: `nixos-config` (just the repo name)
- One-line: "NixOS as a Claude Code-native operating system -- built with Claude, optimized for Claude, evolving with Claude."
- Badges: NixOS version, CI status (live), License. No Claude Code badge.
- Short paragraph explaining why NixOS + Claude Code reinforce each other (reproducibility, sandboxing, declarative config)

### 2. Thesis: Why NixOS is ideal for AI agents

Comparison table: Traditional OS vs NixOS across 5 dimensions:
- Implicit system state vs declarative config
- Dangerous autonomy vs kernel-level sandboxing
- Configuration drift vs atomic rollbacks
- Environment setup vs `nix develop`
- Permanent installs vs ephemeral shells

Closing line anchors it back to the repo.

### 3. What's Inside

Four subsections:

**Multi-profile architecture** -- mkTechHost/mkBusinessHost diagram, "adding a host is 3 lines" code example.

**Sandboxed Claude Code** -- Two modes (sandboxed with network, airgapped without). Kernel-enforced, no subprocess escape.

**AI toolchain** -- List of flake inputs: Claude Code, Cursor, Antigravity, Whisper Dictation, NixClaw. Highlight that 3 of these are maintained by the author.

**Tested and CI'd** -- ShellCheck, BATS, GitHub Actions, security scanning. Frame as "unusual for a dotfiles repo."

### 4. Quick Start

Three lines: clone, cd, rebuild. No prerequisites wall. Confident.

### 5. Repository Structure

Tree view reflecting actual current host names (tech-001, biz-001, biz-002, etc).

### 6. Related Repositories

Table of 3 actively maintained repos: antigravity-nix, code-cursor-nix, whisper-dictation. Dropped claude-nixos-automation.

### 7. License

One line: MIT.

## What's Removed from Current README

- YAML frontmatter (internal tooling metadata)
- "The Problem" / permission learning framing
- Collapsible package lists (350+ tool dump)
- "The Ecosystem" section with claude-nixos-automation
- "How It Differs from Alternatives" comparison table
- "Contributing" section (adds nothing for a personal config)
- Closing marketing banner
- Documentation links table
- rebuild-nixos flags table (too detailed for README)
- "Why NixOS?" evangelism section (replaced by AI-focused thesis)

## Remaining Public Repos (Phase 2+)

After nixos-config, apply same process to each repo:

| Repo | Current State | Priority |
|------|--------------|----------|
| antigravity-nix (95 stars) | Good README, could tighten | High |
| whisper-dictation (6 stars) | Solid, needs polish | High |
| code-cursor-nix (4 stars) | Functional, needs narrative | Medium |
| bpkit | Decent structure | Medium |
| brownkit | Has badges, reasonable | Medium |
| mcp-sunsama | Fork-style README | Low |
| whatsapp-mcp | Fork-style README | Low |
| italian-real-estate-prices | Data science, different audience | Medium |
| digital-invoice-to-pdf | Legacy JS project | Low |
