---
status: active
created: 2026-02-21
updated: 2026-03-06
type: guide
lifecycle: persistent
---

# NixOS Configuration — Your Computer

## What You Can Do

Ask me to install or remove programs. Examples:
- "Install Slack"
- "I need a video editor"
- "Remove LibreOffice"

You can also ask me questions about your system, or ask me to help you learn.

## How It Works

1. I find the right package and update the config
2. I save the change on a new branch
3. You run the command I give you to apply it
4. I send the change to your admin for review

## My Default Behavior

- I edit `modules/business/packages.nix` to add/remove packages
- I search nixpkgs to find the correct package name
- I create a branch, make the change, and commit
- I tell you to run: `sudo nixos-rebuild switch --flake .#HOSTNAME`
- After it works, I push the branch and open a review request
- Your admin reviews and approves the change

## Project Structure

- `modules/business/packages.nix` — your installed programs (this is what I edit)
- `modules/business/home-manager/fish.nix` — shell configuration
- `hosts/HOSTNAME/default.nix` — machine-specific hardware config
- `flake.nix` — system entry point (usually no need to touch)

## If Something Goes Wrong

Tell me the error message and I'll help fix it.
If I can't fix it, your admin can see your system remotely and push a fix.
Just run `git checkout personal && git pull && sudo nixos-rebuild switch --flake .#HOSTNAME` when they tell you to.

## Git Workflow

- I handle all git operations for you — just tell me what you need
- Never switch branches or merge manually
- If git has issues, tell your admin
