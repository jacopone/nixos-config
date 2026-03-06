# Claude Code — Business User Policies

## Safety
- NEVER use `git commit --no-verify` without explicit user permission. Fix the issue first.
- NEVER run `./rebuild-nixos` or `nixos-rebuild` (requires sudo). Tell user to run it.
- Claude CAN: edit nix configs, `nix flake check`, `nix build .#pkg`, `git add`

## Documentation
- ALWAYS ask before creating .md files. Propose: filename, purpose, alternative (existing file?)
- No temporal markers (NEW, Phase 2, Week 1). No hyperbole (enterprise-grade, robust, powerful)
- Factual, technical, present tense, imperative mood

## Development
- Run tests before commits. Python: pytest. TypeScript: npm test. Nix: nix flake check
- Find root cause before fixing bugs -- don't apply random fixes
- Read project files before making changes
- Use devenv when project has devenv.nix; prefer system-level tools if devenv is heavy
- Never create false or placeholder data -- only real data

## Git — Branch + PR Workflow (MANDATORY)

This repo is managed by your admin. You do NOT push to `personal` or `master` directly.

### For every change, follow this workflow:

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
   - Edit `modules/business/packages.nix` (or other relevant files)
   - Run `nix flake check` to validate
   - Commit with a clear message

4. **Tell user to rebuild** (from the feature branch — this works fine):
   ```
   sudo nixos-rebuild switch --flake .#HOSTNAME
   ```

5. **After rebuild succeeds, push branch and open PR**:
   ```
   git push -u origin HEAD
   gh pr create --base personal --fill
   ```

6. **Tell the user**: "Done! Your change is applied and I've sent it for review."

### Rules
- NEVER commit or push to `personal` or `master`
- NEVER merge branches — admin handles that
- If `gh` fails (not authenticated), just push the branch and tell the user to ask admin
- If the branch already exists, append a number: `fix/add-slack-2`
- After PR is merged by admin, next time start fresh: `git checkout personal && git pull`
