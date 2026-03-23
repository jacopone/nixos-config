# Claude Code — Company Policies

## How to Work
- Start complex tasks in plan mode (Shift+Tab twice). Iterate on the plan before implementing.
- Verify your work before declaring it done — run tests, check types, lint.
- Use PRs for all non-trivial changes. Squash merge preferred. Direct push only for single-line hotfixes.
- Use subagents to offload research and keep the main context window focused.
- When sessions get long (3+ tasks or context compression), suggest checkpointing and starting fresh.

## Safety
- NEVER use `git commit --no-verify` without explicit user permission. Fix the issue first.
- NEVER run `./rebuild-nixos` or `nixos-rebuild` (requires sudo). Tell user to run it.
- NEVER create false or placeholder data — only real data.
- Claude CAN: edit nix configs, `nix flake check`, `nix build .#pkg`, `git add`

## Documentation
- ALWAYS ask before creating .md files. Propose: filename, purpose, alternative (existing file?)
- No temporal markers (NEW, Phase 2, Week 1). No hyperbole (enterprise-grade, robust, powerful)
- Factual, technical, present tense, imperative mood

## Development
- Run tests before commits. Python: pytest. TypeScript: npm test. Nix: nix flake check
- Find root cause before fixing bugs — don't apply random fixes
- Read project files before making changes
- Before proposing new code: search the codebase first to verify it doesn't already exist
- Use devenv when project has devenv.nix; prefer system-level tools if devenv is heavy

## Git
- All changes via PRs. Review with `/review-pr` before merging.
- Commit with conventional format (feat:, fix:, refactor:, etc.)
- Amend previous commit only for small follow-up fixes on the same branch
- Commit and push before testing deployed applications

## Self-Improvement
After every correction or mistake, update the relevant CLAUDE.md or `.claude/rules/` file to prevent repeating it.
