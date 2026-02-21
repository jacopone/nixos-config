---
status: draft
created: 2026-02-21
updated: 2026-02-21
type: planning
lifecycle: persistent
---

# ClaudeOS Business Self-Service Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable business users to self-service install programs via Claude Code, with git-branch-per-machine visibility for the admin.

**Architecture:** A CLAUDE.md template checked into each business branch instructs Claude to edit only `modules/business/packages.nix`, commit after edits, and push after successful rebuild. A fish greeting + alias gives users a zero-friction entry point.

**Tech Stack:** Nix, Fish shell, Git, Claude Code

---

### Task 1: Add fish greeting and claude alias to business profile

**Files:**
- Modify: `modules/business/home-manager/fish.nix:21` (inside `interactiveShellInit`)

**Step 1: Add the greeting and claude function**

At the end of `interactiveShellInit` (before the closing `'';` on line 192), add:

```fish
      # ClaudeOS greeting — only show in interactive terminals, not inside Claude
      if not _is_automated_context
          echo ""
          echo "  Need to install or change something?"
          echo "  Type:  claude"
          echo ""
      end

      # Launch Claude Code in nixos-config directory
      function claude --description "Open Claude Code in your system config"
          builtin cd ~/nixos-config
          command claude
      end
```

Note: The `claude` function uses `builtin cd` to avoid triggering the smart cd/zoxide wrapper. It uses `command claude` to call the actual Claude binary, not recurse.

**Step 2: Verify syntax**

Run: `nix flake check`
Expected: No errors (nix evaluates the fish config as a string, so syntax issues show as eval errors)

**Step 3: Commit**

```bash
git add modules/business/home-manager/fish.nix
git commit -m "feat: add fish greeting and claude alias for business users"
```

---

### Task 2: Create the business CLAUDE.md template

This file lives in the repo but is only used on business branches. On the `personal` branch it serves as the template source.

**Files:**
- Create: `hosts/business-template/CLAUDE.md`

**Step 1: Create the template file**

```markdown
# NixOS Configuration — Your Computer

## What You Can Do

Ask me to install or remove programs. Examples:
- "Install Slack"
- "I need a video editor"
- "Remove LibreOffice"

You can also ask me questions about your system, or ask me to help you learn.

## How It Works

1. I find the right package and update the config
2. I save the change (git commit)
3. You run the command I give you to apply it
4. After it works, I sync the change (git push)

## My Default Behavior

- I edit `modules/business/packages.nix` to add/remove packages
- I search nixpkgs to find the correct package name
- After editing, I commit with a descriptive message
- I tell you to run: `sudo nixos-rebuild switch --flake .#HOSTNAME`
- After you confirm it worked, I run `git push`
- If the rebuild fails, I help you fix it before pushing

## Project Structure

- `modules/business/packages.nix` — your installed programs (this is what I edit)
- `modules/business/home-manager/fish.nix` — shell configuration
- `hosts/HOSTNAME/default.nix` — machine-specific hardware config
- `flake.nix` — system entry point (usually no need to touch)

## If Something Goes Wrong

Tell me the error message and I'll help fix it.
If I can't fix it, your admin can see your system remotely and push a fix.
Just run `git pull && sudo nixos-rebuild switch --flake .#HOSTNAME` when they tell you to.

## Git Workflow

- Always work on the current branch (your machine's branch)
- Never switch branches or merge
- If git has issues, tell your admin
```

Note: `HOSTNAME` in the template must be replaced with the actual hostname (e.g. `biz-003`) during machine setup. This is a manual step documented in the setup procedure.

**Step 2: Verify no syntax issues**

Run: `nix flake check`
Expected: Pass (CLAUDE.md is not evaluated by Nix, but good practice)

**Step 3: Commit**

```bash
git add hosts/business-template/CLAUDE.md
git commit -m "feat: add CLAUDE.md template for business self-service"
```

---

### Task 3: Test the fish integration locally

**Step 1: Verify the fish function works in isolation**

Run in a fish shell:
```fish
function claude --description "Open Claude Code in your system config"
    builtin cd ~/nixos-config
    command claude
end
type claude
```
Expected: Shows the function definition, confirming it doesn't conflict with the claude binary.

**Step 2: Test the greeting gate**

Run:
```fish
# Simulate interactive context (should show greeting)
_is_automated_context; and echo "automated" || echo "interactive"
```
Expected: `interactive` (when run in a real terminal)

```fish
# Simulate automated context (should NOT show greeting)
CLAUDE_CODE_SESSION=1 fish -c 'source ~/.config/fish/config.fish; _is_automated_context; and echo "automated" || echo "interactive"'
```
Expected: `automated`

**Step 3: Commit test results as verified**

No code change — just confirm the integration works. Update the design doc status if desired.

---

### Task 4: Document the machine setup procedure

**Files:**
- Modify: `docs/plans/2026-02-21-claudeos-business-design.md` (update status to `active`)

**Step 1: Update design doc status**

Change frontmatter `status: draft` to `status: active`.

**Step 2: Commit**

```bash
git add docs/plans/2026-02-21-claudeos-business-design.md
git commit -m "docs: mark ClaudeOS design as active"
```

---

## Setup Procedure (for reference — run on each new business machine)

This is not a task to implement now, but the procedure to follow when deploying to a new machine:

```bash
# 1. Clone repo
cd ~
git clone https://github.com/jacopone/nixos-config.git
cd nixos-config

# 2. Create machine branch from personal
git checkout personal
git checkout -b <hostname>

# 3. Copy and customize CLAUDE.md
cp hosts/business-template/CLAUDE.md ./CLAUDE.md
sed -i 's/HOSTNAME/<hostname>/g' CLAUDE.md

# 4. Commit and push
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md for <hostname>"
git push -u origin <hostname>

# 5. Verify rebuild
sudo nixos-rebuild switch --flake .#<hostname>

# 6. Test Claude
claude
# Ask: "Install htop" — verify it edits packages.nix, commits, prints rebuild command
```
