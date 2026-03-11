---
paths: []
---

# Git — Branch + PR Workflow (MANDATORY)

You are a contributor, not an admin. You NEVER push to protected branches directly.

## nixos-config Repository

Base branch: `personal`. Prefix branches from it.

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

## account-harmony-ai Repository

Base branch: `gcp-minimal`. Full dev environment via devenv.

### First-time setup
```
git clone https://github.com/jacopone/account-harmony-ai-37599577.git
cd account-harmony-ai-37599577
# direnv activates devenv automatically — wait for it
npm install
cd backend && npm install && cd ..
```

### Development workflow
1. **Start from latest `gcp-minimal`**:
   ```
   git checkout gcp-minimal
   git pull
   ```

2. **Create a feature branch**:
   ```
   git checkout -b feat/<short-description>
   ```
   Prefixes: `fix/`, `feat/`, `refactor/`, `style/`, `test/`

3. **Run local dev server to preview changes**:
   ```
   npm run dev
   ```
   Opens frontend at http://localhost:5173. Backend connects to staging API.

4. **Make changes, verify**:
   - Run `npm run lint` and `npm run typecheck` before committing
   - Run `npm test` to verify tests pass
   - Git hooks run automatically on commit (lint, security, tests)

5. **Push branch and open PR**:
   ```
   git push -u origin HEAD
   gh pr create --base gcp-minimal --fill
   ```

6. **Wait for review**: Jacopo must approve before merge. CI must pass.

### Restrictions
- NEVER push to `gcp-minimal` — branch protection will reject it
- NEVER merge your own PRs
- NEVER modify: `.github/workflows/`, `Dockerfile*`, `devenv.nix`, deploy scripts
- NEVER change environment variables, secrets, or database migrations
- NEVER bypass git hooks with `--no-verify`
- If tests fail, fix them — don't skip

## General Rules
- NEVER commit or push to protected branches (`personal`, `gcp-minimal`, `master`)
- NEVER merge branches — admin handles that
- If `gh` fails (not authenticated), push the branch and tell the user to ask admin
- If the branch already exists, append a number: `fix/add-slack-2`
- After PR is merged by admin, start fresh: checkout base branch and pull
