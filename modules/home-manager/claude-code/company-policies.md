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
- Context-aware checkpointing — this is a 1M-token environment (Claude Opus 4.7). Don't suggest checkpoint based on task count: that heuristic predates the 1M window. Check `/context`: ride to ~70% before handing over; below that, only start fresh at a natural boundary when the next task is unrelated. The `deep-session-state.sh` Stop hook prompts a handover at ~70% (override via `CLAUDE_CONTEXT_LIMIT`). Other valid triggers: context compression has already fired, or you're about to dispatch many parallel subagents and need synthesis headroom. Task count alone is not a trigger.

## Safety
- NEVER use `git commit --no-verify` without explicit user permission. Fix the issue first.
- NEVER run `./rebuild-nixos` or `nixos-rebuild` (requires sudo). Tell user to run it.
- NEVER create false or placeholder data — only real data.
- Claude CAN: edit nix configs, `nix flake check`, `nix build .#pkg`, `git add`.
- For significant input changes in `~/nixos-config`, suggest `./rebuild-nixos --audit` (closure manifest) or `--verify-bootstrap` (deep reproducibility check).
- `sandbox.enabled = true` and `sandbox.failIfUnavailable = true` are set unconditionally in `/etc/claude-code/managed-settings.json` (deployed by `modules/common/claude-code-managed.nix`). These cannot be opted out via `~/.claude/settings.json` — managed-settings precedence wins over user settings by design. Invariant #4 (sandbox isolation) is enforced fleet-wide.

## Paid External APIs (LLM, search, data providers)

Origin: 2026-07-10 Gemini grounding incident — two runs billed EUR 1,173 against
a EUR ~30 estimate because the billing unit (per search query, with model-decided
fan-out) differed from the assumed one (per request). These rules bind every repo:

1. **Verify the price from the provider's live pricing page before writing any
   budget or estimate.** Never budget from memory or model priors. State the
   billing UNIT explicitly (per request? per query? per token?) — unit confusion,
   not rate confusion, caused the incident. Free-tier claims count as pricing:
   verify who qualifies and in which unit the allowance is denominated.
2. **Every spend-capable code path defaults to no-spend.** A bare invocation
   (no flags, UI button, scheduler default, deploy default) must cost zero.
   Spending requires an explicit per-run cap flag, denominated in calls AND
   estimated money, printed before the run starts (`--confirm-spend` pattern).
3. **No unbounded modes and no silent retry amplification.** Batch tools take a
   required hard cap; task-level retries, in-call retries, and requeue-of-errors
   are off by default (each layer re-bills — a timed-out call may still bill
   server-side). A run must abort on consecutive errors (circuit breaker), not
   grind a quota wall at full billing.
4. **Platform backstops before the first paid run:** a billing budget alert
   scoped to the API's service, and a hard server-side quota cap (requests/day)
   sized to the worst acceptable daily burn. Code guards fail; quotas don't.
5. **A zero-cost smoke test validates wiring, not economics.** Before scaling any
   paid batch, run a SMALL paid batch, reconcile actual billed cost against the
   estimate in the billing console, and only then scale. First paid runs are
   supervised, never launched unattended or overnight.

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
