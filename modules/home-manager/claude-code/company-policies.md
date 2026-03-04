# Claude Code — Company Policies

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

## Git
- Amend previous commit for small follow-up fixes
- Commit and push before testing deployed applications
