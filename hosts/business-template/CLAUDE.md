---
status: active
created: 2026-02-21
updated: 2026-02-21
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
