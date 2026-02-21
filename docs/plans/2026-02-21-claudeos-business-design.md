---
status: draft
created: 2026-02-21
updated: 2026-02-21
type: planning
lifecycle: persistent
---

# ClaudeOS — Self-Service NixOS for Business Users

## Problem

Business users need to install programs and customize their machines but lack
NixOS knowledge. The admin (you) handles everything via RustDesk, which doesn't
scale and creates a bottleneck.

## Solution

Give business users Claude Code as their system administrator. Claude edits the
NixOS config, the user runs the rebuild command. Git branches per machine give
the admin full remote visibility and control.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Who runs rebuild? | User (sudo) | No sudo for Claude — user controls when system changes |
| What can Claude edit? | `modules/business/packages.nix` by default | Safe starting point; user can ask for more as they learn |
| When does Claude push? | After successful rebuild only | Remote branches only contain working configs |
| Where is CLAUDE.md? | Checked into each biz-NNN branch | Admin can update Claude's behavior remotely via git push |
| Branch base | `personal` branch | Source of truth; `master` is CI-sanitized, not suitable |

## Architecture

### Branch Model

```
personal     ← admin working branch (source of truth)
master       ← public, CI-sanitized (auto-synced by CI)
biz-001      ← business machine 1
biz-002      ← business machine 2
biz-003      ← business machine 3 (MacBook Air T2)
```

### User Flow

```
User opens terminal
  → Fish greeting: "Need to install something? Type: claude"
  → User types: claude
  → Fish alias: cd ~/nixos-config && claude
  → User: "Install Slack"
  → Claude: searches nixpkgs, edits packages.nix, git commit
  → Claude: "Done! Now run: sudo nixos-rebuild switch --flake .#biz-003"
  → User runs command
  → User: "It worked"
  → Claude: git push
```

### Admin Remote Management

Three levers, all via git push to the machine's branch:

1. **Fix config** — edit nix files on their branch, push, tell user to
   `git pull && sudo nixos-rebuild switch --flake .#<hostname>`
2. **Update Claude's behavior** — edit CLAUDE.md on their branch, push,
   tell user to `git pull`
3. **View machine state** — `git diff personal..biz-003 -- modules/business/packages.nix`

### Progressive Disclosure

The CLAUDE.md provides safe defaults but doesn't enforce a cage:

- **Day 1**: "Install Slack" → Claude edits packages.nix
- **Month 2**: "How do I add a keyboard shortcut?" → Claude teaches GNOME dconf
- **Month 6**: User reads Nix expressions, asks Claude to explain modules

The system grows with the user.

## Components

### 1. Business CLAUDE.md (checked into each biz-NNN branch)

```markdown
# NixOS Configuration — Your Computer

## What You Can Do
Ask me to install or remove programs. Examples:
- "Install Slack"
- "I need a video editor"
- "Remove LibreOffice"

## How It Works
1. I find the right package and update the config
2. I save the change (git commit)
3. You run the command I give you to apply it

## My Rules
- I edit `modules/business/packages.nix` to add/remove packages
- After editing, I commit with a descriptive message
- I tell you to run: `sudo nixos-rebuild switch --flake .#<HOSTNAME>`
- After you confirm it worked, I push the change

## If Something Goes Wrong
Tell me the error message and I'll help fix it.
If I can't fix it, your admin can see your system remotely.
```

### 2. Fish Shell Integration (in `modules/business/home-manager/fish.nix`)

- Fish greeting message pointing user to `claude` command
- Fish function `claude` that cd's to `~/nixos-config` and launches Claude Code

### 3. Machine Setup Procedure (run via RustDesk)

1. Clone repo: `git clone` into `~/nixos-config`
2. Create branch: `git checkout -b <hostname>` from `personal`
3. Create CLAUDE.md from template, commit, push
4. Verify rebuild: `sudo nixos-rebuild switch --flake .#<hostname>`
5. Test Claude: user types `claude`, asks to install something

## Maintenance

- **Upstream updates**: Rebase each biz-NNN branch onto `personal` (admin task)
- **Flake updates**: `nix flake update` on business machines (admin task via RustDesk)
- **CLAUDE.md changes**: Edit on branch, push (no RustDesk needed)

## Future Enhancements (not in scope now)

- Hooks to hard-block edits outside packages.nix (Approach B from brainstorming)
- Custom `claudeos` wrapper command (Approach C)
- Automated rebase CI for business branches
