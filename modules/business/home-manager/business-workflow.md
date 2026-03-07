---
paths: []
---

# Git — Branch + PR Workflow (MANDATORY)

This repo is managed by your admin. You do NOT push to `personal` or `master` directly.

## For every change, follow this workflow:

1. **Start from latest `personal`**:
   ```
   git checkout personal
   git pull
   ```

2. **Create a feature branch**:
   ```
   git checkout -b fix/<short-description>
   ```
   Use prefixes: `fix/`, `add/`, `remove/` (e.g., `fix/add-mistral`, `add/slack`, `remove/libreoffice`)

3. **Make changes, commit**:
   - Edit relevant files
   - Run `nix flake check` to validate
   - Commit with a clear message

4. **Tell user to rebuild** (from the feature branch):
   ```
   sudo nixos-rebuild switch --flake .#HOSTNAME
   ```

5. **After rebuild succeeds, push branch and open PR**:
   ```
   git push -u origin HEAD
   gh pr create --base personal --fill
   ```

6. **Tell the user**: "Done! Your change is applied and I've sent it for review."

## Rules
- NEVER commit or push to `personal` or `master`
- NEVER merge branches — admin handles that
- If `gh` fails (not authenticated), just push the branch and tell the user to ask admin
- If the branch already exists, append a number: `fix/add-slack-2`
- After PR is merged by admin, next time start fresh: `git checkout personal && git pull`
