# Claude Code — Company Policies

## Fleet Context (ClaudeOS)

- These policies bind every Claude session on every ClaudeOS machine (tech and business hosts alike).
- They are declarative: the source is `modules/home-manager/claude-code/company-policies.md` in `~/nixos-config`, deployed fleet-wide as the `claudeMd` key of `/etc/claude-code/managed-settings.json` (`modules/common/claude-code-managed.nix`). Edit the source, then rebuild. There is deliberately NO `~/.claude/CLAUDE.md` copy — a user-deletable file would defeat the managed authority model.
- The fleet repo `~/nixos-config` has its own `CLAUDE.md` (fleet table, invariants, project structure, rebuild commands, branch model) — that file governs when working in the repo; this one stays repo-agnostic.
- Recovery model everywhere: atomic rollback (`nixos-rebuild switch --rollback`), not in-place hot-fix. Autonomous work runs in bubblewrap + seccomp BPF worktrees via `scripts/claude-autonomous.sh` — don't bypass the sandbox.

## How to Work
- Start complex tasks in plan mode (Shift+Tab twice). Iterate on the plan before implementing.
- Verify your work before declaring it done — run tests, check types, lint.
- Use PRs for all non-trivial changes. Squash merge preferred. Direct push only for single-line hotfixes.
- Use subagents to offload research and keep the main context window focused.
- Context-aware checkpointing — current Claude models run 1M-token context windows. Don't suggest checkpoint based on task count: that heuristic predates the 1M window. Check `/context`: ride to ~70% before handing over; below that, only start fresh at a natural boundary when the next task is unrelated. The `deep-session-state.sh` Stop hook prompts a handover at ~70% (override via `CLAUDE_CONTEXT_LIMIT`). Other valid triggers: context compression has already fired, or you're about to dispatch many parallel subagents and need synthesis headroom. Task count alone is not a trigger.

## Safety
- NEVER use `git commit --no-verify` without explicit user permission. Fix the issue first.
- NEVER run `./rebuild-nixos` or `nixos-rebuild` (requires sudo). Tell user to run it.
- NEVER create false or placeholder data — only real data.
- Claude CAN: edit nix configs, `nix flake check`, `nix build .#pkg`, `git add`.
- For significant input changes in `~/nixos-config`, suggest `./rebuild-nixos --audit` (closure manifest) or `--verify-bootstrap` (deep reproducibility check).
- `sandbox.enabled = true` and `sandbox.failIfUnavailable = true` are re-asserted into `~/.claude/settings.json` on EVERY rebuild by the `claude-settings-merge` activation — a manual opt-out self-heals at the next rebuild, not instantly. Treat Invariant #4 (sandbox isolation) as binding: never weaken these keys. Hard managed-settings enforcement is a tracked follow-up in `modules/common/claude-code-managed.nix`.

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

## Anthropic Spend & Degraded Mode

The Paid-External-API rules above apply to our own Anthropic usage — it is the
company's largest paid API (learned 2026-07-14: the org's monthly cap was hit
mid-task with no early warning). Two pools: the claude.ai org (Claude Code
sessions — subscription + extra usage) and the Console org (API keys, e.g. CI
`claude-review`).

- **Early warning:** the `anthropic-usage-alert` user timer (fleet module)
  checks month-to-date spend vs budget every 6h and alerts at 50/80/95%
  crossings. It needs `~/.config/anthropic/{admin-api-key,monthly-budget-usd}`
  on at least one tech host. Manual check: claude.ai/admin-settings/usage and
  the Console cost page.
- **Failure signature at the cap:** subagents/Task tools die with a spend-limit
  message; the auto-mode permission classifier can go "temporarily unavailable"
  which blocks ALL write tools (reads keep working); CI `claude-review` can
  fail org-wide, freezing every PR merge.
- **Playbook:** (1) recognize the signature — do NOT grind retries; (2) finish
  read-only work, park writes; (3) the owner raises the limit
  (claude.ai/admin-settings/usage or `/usage-credits`) or accepts waiting for
  the reset; (4) truly urgent merges only: OrganizationAdmin bypass, sparingly;
  (5) after restore, re-run killed subagent work — their results were lost,
  sessions survive.

## Documentation
- ALWAYS ask before creating .md files. Propose: filename, purpose, alternative (existing file?)
- No temporal markers (NEW, Phase 2, Week 1). No hyperbole (enterprise-grade, robust, powerful)
- Factual, technical, present tense, imperative mood

## Development
- Every host is NixOS. A missing CLI tool is NEVER a blocker and never an
  apt/brew/pip global install: run it ephemerally — `nix-shell -p <pkg> --run '<cmd>'`
  or `nix run nixpkgs#<pkg> -- <args>` (both already permission-allowlisted; inside a
  devenv project prefer `devenv shell` first). Recurring need → propose adding it to
  the proper `packages.nix` (nixos-config CLAUDE.md "Where to put what"), don't
  keep reaching for ephemeral shells.
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
