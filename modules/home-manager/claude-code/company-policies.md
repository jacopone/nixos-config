# Claude Code — Company Policies

## Primary Project Context

- Primary repo: `~/nixos-config` (**ClaudeOS**) — a reproducible, kernel-sandboxed NixOS fleet maintained by Claude Code.
- Fleet spans personal hardware (Framework 16, MacBooks, ThinkPad) and business workstations for non-technical staff, all built from one flake via `mkTechHost` / `mkBusinessHost`.
- Recovery model: atomic rollback (`nixos-rebuild switch --rollback`), not in-place hot-fix.
- Autonomous work runs in bubblewrap + seccomp BPF worktrees via `scripts/claude-autonomous.sh`. Don't bypass the sandbox.
- These policies are themselves declarative: this file lives at `modules/home-manager/claude-code/company-policies.md` and is deployed to `~/.claude/CLAUDE.md` by Home Manager. Edit the source, not the symlink.

## How to Work
- Start complex tasks in plan mode (Shift+Tab twice). Iterate on the plan before implementing.
- Verify your work before declaring it done — run tests, check types, lint.
- Use PRs for all non-trivial changes. Squash merge preferred. Direct push only for single-line hotfixes.
- Use subagents to offload research and keep the main context window focused.
- Context-aware checkpointing — this is a 1M-token environment (Claude Opus 4.7). Don't suggest checkpoint based on task count: that heuristic predates the 1M window. Check `/context`: below 50% messages bar default to continuing; ≥60% weigh whether the next task benefits from a clean slate; ≥75% actively suggest checkpoint. Other valid triggers: context compression has already fired, or you're about to dispatch many parallel subagents and need synthesis headroom. Task count alone is not a trigger.

## Safety
- NEVER use `git commit --no-verify` without explicit user permission. Fix the issue first.
- NEVER run `./rebuild-nixos` or `nixos-rebuild` (requires sudo). Tell user to run it.
- NEVER create false or placeholder data — only real data.
- Claude CAN: edit nix configs, `nix flake check`, `nix build .#pkg`, `git add`.
- For significant input changes in `~/nixos-config`, suggest `./rebuild-nixos --audit` (closure manifest) or `--verify-bootstrap` (deep reproducibility check).
- `sandbox.enabled = true` and `sandbox.failIfUnavailable = true` are set unconditionally in `/etc/claude-code/managed-settings.json` (deployed by `modules/common/claude-code-managed.nix`). These cannot be opted out via `~/.claude/settings.json` — managed-settings precedence wins over user settings by design. Invariant #4 (sandbox isolation) is enforced fleet-wide.

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
