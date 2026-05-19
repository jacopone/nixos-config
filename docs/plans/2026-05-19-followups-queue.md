# Pending Follow-ups Queue

**As of:** 2026-05-19 end-of-session (after P1-1 ship)
**Source:** TaskList entries #15-#24 from the audit/implementation session. Captured here because TaskList doesn't persist across sessions.

When resuming work, pick any of these and start a fresh session pointed at the relevant section.

---

## From P0 implementation (Phase 1-5 / audit work)

### #15 — Clean stale claude-automation doc references

Pre-existing doc rot surfaced during Task 2 code review of commit `cea28f6` (claude-automation flake input removal).

- `docs/guides/COMMON_TASKS.md` lines 23, 124, 136-137, 148, 401-413 — TOC entry, update-input examples, and the entire "Claude Automation" section (lines 401-413) describing how to invoke the now-removed `nix run github:jacopone/claude-nixos-automation#update-all`. Same file also lists `ai-project-orchestration` (line 125) which auto-memory says has been gone since 2026-02.
- `docs/architecture/SUPPLY_CHAIN_HARDENING.md` lines 240, 354, 360 — never-built `claude_automation/cli/check_reproducibility.py` design-doc speculation.

Defer until after Phase 1 P0 work; not build-blocking.

### #16 — Tighten BATS Test 3 to exercise single-arg apply-seccomp path

`tests/bash/sandbox/test-seccomp-active.bats` Test 3 currently invokes `apply-seccomp python3 -c "..."` which is argc==4, hitting the legacy argc>=3 path treating "python3" as BPF path (fails ENOENT, test passes by exclusion). Never exercises argc==2 single-arg BPF_PATH path. Should write a wrapper script (e.g., `/tmp/test-af-unix.sh`) and call `apply-seccomp /tmp/test-af-unix.sh` (argc==2).

Spec reviewer demonstrated pre- vs post-migration BATS output is identical. Functional migration is verified independently (commit `fcb2177`), this is test hygiene.

### #17 — Merge jq edge case: applyPath when sandbox section absent

Per spec reviewer Check 7 caveat of Task 4. If a `settings.json` lacks any `sandbox` section, the merge jq pipeline in `modules/home-manager/claude-code/default.nix` produces `sandbox.seccomp: {}` (empty, no `applyPath`).

First-setup branch correctly sets `applyPath`. Current user is unaffected (their settings has `sandbox`). Future-proof would be: in merge branch, also set `sandbox.seccomp.applyPath` if absent. Minor edge case; defer.

### #18 — $DRY_RUN_CMD corrupts settings.json on dry-run

**[COMPLETED]** Fixed in commit `f2fc81a` (2026-05-19). Both jq pipelines in `home.activation.claude-settings-merge` now wrapped in explicit `if [ -n "$DRY_RUN_CMD" ]; then ... else ... fi` guards. Regression coverage: `tests/bash/claude-settings/test-dry-run-safety.bats` (5 tests: structural check on source, control reproduction of the bug pattern, and behavioral assertions for both dry-run and real-mode shapes).

### #19 — sandbox.enabled = true overrides user opt-out

**[COMPLETED]** Doc note added in commit `ef3ccfe`.

### #20 — Properly configure managed-settings marketplace restrictions

Per fix commit `921de12` (post-Task 6). `strictKnownMarketplaces` and `blockedMarketplaces` expect arrays of source-pattern objects, NOT booleans. Per Claude Code binary docstrings: `[{hostPattern = "^github\\.com$";} {source = "skills-dir";}]` etc.

Sentinels: `{source="skills-dir"}` enables/disables `~/.claude/skills/` auto-scan. github sources match hostPattern against "github.com". file/directory sources match pathPattern against `.path`.

Reasonable starter: `strictKnownMarketplaces = [{hostPattern = "^github\\.com$";} {source = "skills-dir";}];` plus `blockedMarketplaces = [];` (allow all not explicitly blocked). Use `lib.mkDefault` on both for per-host override-ability.

### #21 — Tighten subagent runtime quality (I1-I6 + M1-M7)

Per Tasks 9-13 code review of subagent commits + Tasks 14-15 code review (M1).

All new BATS tests under `tests/bash/{subagents,statusline}/` hardcode `/home/guyfawkes/nixos-config/...` instead of using `$(git rev-parse --show-toplevel)`. Pattern from `tests/bash/managed-settings/test-managed-settings.bats:14` is the canonical convention.

Also:
- I1 over-broad Bash tools in subagent definitions
- I2 flake-debugger output format should use unified-diff
- I3 generation-differ needs fallback for missing generations
- I4 supply-chain-auditor CVE cross-ref has no mechanism (drop or add WebFetch)
- I5 reword "against the user" ambiguity
- I6 add "ask if missing input" pattern to all 4 agents
- M2 required-fields test for all 4 subagents (currently only flake-debugger)
- M3 skip-with-message pre-rebuild
- M5 commit-prose tweak
- M6 package-finder dedupe CLAUDE.md table
- M7 verb consistency in flake-debugger

### #22 — check-claude-config.sh polish (5 items from Phase 4 code review)

Per Phase 4 code review of commits `c3ffca3..20869af`.

- **I1 IMPORTANT** — malformed `settings.json` silently swallowed in `check_plugin_versions` + `check_sandbox_attestation`. Probe with `jq empty` first and emit error event if unparseable. **This is the chosen Agent View pilot target (see `docs/plans/2026-05-19-agent-view-pilot-task.md`).**
- I2 — drop unused `NIXOS_CONFIG` variable (SC2034)
- I3 — replace literal `~` in user-facing message with `${CLAUDE_DIR}/agents/` (SC2088)
- I4 — `test-phase4-validator.bats` Test 2 grep alternation only requires ONE exit-code branch found, not all 3 — tighten to assert all three present. Also: hardcoded `/home/guyfawkes/nixos-config/rebuild-nixos` path in same test should use `$BATS_TEST_DIRNAME` relative reference for portability.
- M3 — plugin-cache "no plugin.json" warn cannot distinguish broken install vs in-progress extraction. Add brief retry or note in message.

### #23 — P1-1: Add log_event JSON structured logging to rebuild-nixos

**[COMPLETED]** Commits `1d3c796` + `f262715`.

### #24 — P1-1 polish (I1-I4 + M1-M5 from code review)

Per P1-1 code review of commits `1d3c796` + `f262715`.

- **I1** — statusline shows stale `last-status` forever (no age check). Add age annotation: `last:succ(2d)` or mtime/TTL check in `statusline.sh:32-35`.
- **I2** — 3-line comment explaining text-file ↔ JSONL duality (`LAST_STATUS_FILE` vs `EVENT_LOG`) near the `LAST_STATUS_FILE=` declaration. Two-sinks-of-truth is justified but undocumented.
- **I3 (most useful)** — extract event-log helpers to `lib/event-log.sh` so BATS sources directly. Eliminates awk extraction brittleness — the P1-1 implementer hit pain on this twice. Anchors: `^EVENT_LOG_DIR=`, `^CURRENT_PHASE_START_MS=""`, `^# Current epoch milliseconds`, `^step_skip\(\)` are all single-match anchors today, which means any rename/re-indent silently breaks the test harness.
- **I4** — BATS 28 tests borderline over-engineered. Could consolidate per-field-assertion tests 4-to-1 with `jq -e`. Tests 14, 18, 19, 24, 25, 26 are grep checks (catch removal but not bugs).
- **M1** — rename `step_done` → `step_complete` for consistency with emitted "complete" event name vocabulary.
- **M2** — document `now_ms()` clock-skew/suspend caveat (wall-clock vs monotonic) in a comment.
- **M5** — `declare -g CURRENT_STEP=0` at top scope so BATS doesn't need to inject it.

### #25 — Bubblewrap deny-mount artifacts block intra-session Nix validation

Identified during #18 work (2026-05-19). When Claude Code launches under `sandbox.enabled = true`, bwrap bind-mounts `/dev/null` (char device 1/3) over paths it wants to hide from the inner process: `.mcp.json`, `.gitmodules`, `.claude/settings.json`, `.claude/skills`, `.claude/agents`, `etc/`, `home/`, `.nix-store/`, `.nix-cache-eval/`, and the shell rc / IDE state files (`.profile`, `.bashrc`, `.zshrc`, `.gitconfig`, `.ripgreprc`, `.idea`, `.vscode`, `.bash_profile`, `.zprofile`). Mounts are namespace-scoped — invisible from a host shell.

**Symptom:** any libgit2 operation in the sandboxed Claude session fails with `parsing .gitmodules file: failed open ... Permission denied (libgit2 error code = 2)`. This blocks `nix flake check`, `nix eval`, and `nix build` of any flake attr from inside the session — i.e., the validation discipline mandated by Invariant #9.

**Recovery in use:** the user runs `sudo rm -f .gitmodules .mcp.json && sudo rm -rf .claude/{settings.json,skills,agents} etc/ home/ .nix-store/ .nix-cache-eval/ <dotfiles>` from a non-Claude shell. These deletes are no-ops on the host filesystem (the bind mounts are namespace-private to the sandbox) but re-confirm the host is clean. The sandbox view is unchanged for the rest of the current Claude session; a fresh `claude` invocation starts with clean mounts.

**Proposed fix:** add a graceful-exit hook to the sandbox launcher (both `scripts/claude-autonomous.sh` for autonomous sessions and the interactive `claude` wrapper / systemd-equivalent) that unmounts these char devices before namespace exit. Safe because the mounts are private to the namespace; teardown won't touch host state. Should also be idempotent so an unclean exit + manual cleanup don't conflict.

**Severity:** medium. Adds ~5 minutes of recovery overhead any time Nix work happens inside a Claude session that previously held the sandbox, and pushes validation to a separate shell (defeats some of the in-session feedback loop).

Cross-reference: this is the actionable promotion of the "bwrap deny-mount leakage in repo root" note under "Two unresolved infrastructure items" below.

---

## Plan-defect pattern observations

Three of the last four P0-issue catches in this session came from spec/code reviewers, not from tests:
1. **Tasks 9-13 frontmatter theater** — invented Claude Code subagent fields (`isolation`, `preload_skills`, `mcpServers`) that don't exist in the schema; caught by code-quality reviewer
2. **P0-3 schema-key types** — `strictKnownMarketplaces: true` rejected by Claude Code Zod validator with "Expected array, but received boolean"; caught when Claude couldn't start after rebuild
3. **P1-1 Phase 4 gate inversion** — `step_skip` insertion lacked closing `fi`, putting validator body inside business branch; caught by spec reviewer's awk depth-trace

**Generalizable lesson:** unit tests have a structural blind spot for integration boundaries (our code ↔ Claude Code's schema, bash control flow ↔ inserted code blocks). The two-stage spec+code-quality review keeps catching these.

---

## Two unresolved infrastructure items

These aren't tracked as numbered follow-ups but came up during the session:

- **gh auth token expired mid-session** — `gh auth status` shows "The token in default is invalid" → git push via `.git/git-credential-gh` credential helper fails. Fix: `gh auth login -h github.com` to refresh. Could also add `gh auth status --quiet || warning` to `rebuild-nixos` Phase 0 as a future Phase 4 validator extension.

- **bwrap deny-mount leakage in repo root** — sandboxed nix invocations leave character-device files at `.mcp.json`, `.gitmodules`, `etc/`, `home/`, `.nix-store/`, `.nix-cache-eval/` inside the cwd when they bind-mount `/dev/null` over hidden paths. Now gitignored (per `.gitignore` updates in the session), but worth understanding why specific subagent setups trigger it and not others. **Promoted to actionable follow-up #25 on 2026-05-19** after observing that the artifacts also block `nix flake check` from inside the sandboxed session.

---

## Suggested resume order

1. **Run the Agent View pilot** (per `docs/plans/2026-05-19-agent-view-pilot-task.md`) targeting #22-I1. This validates Agent View as a tool AND lands the most consequential follow-up (settings.json parseability) in one shot.
2. **#24 I3** (extract event-log helpers to `lib/event-log.sh`) — biggest maintainability win, unblocks easier P1-2/P1-3 work later.
3. **#21** (subagent runtime quality batch) — the 4 subagents you shipped need this to behave as advertised.
4. **#25** (sandbox-artifact teardown) — recover Nix validation inside sandboxed sessions; meaningful ergonomic win for every subsequent session.
5. Lower-priority polish: #15, #17, #20, the rest of #22 and #24.

## Where the canonical artifacts live

- Audit: `docs/plans/2026-05-18-claude-code-advancements-audit.md`
- Implementation plan: `docs/plans/2026-05-18-claudeos-p0-implementation.md`
- Sandbox investigation finding: `docs/plans/2026-05-18-sandbox-schema-finding.md`
- Agent View pilot (original P1-1 target, historical): `docs/plans/2026-05-18-agent-view-pilot-task.md`
- Agent View pilot (retargeted to #22-I1, current): `docs/plans/2026-05-19-agent-view-pilot-task.md`
- Agent View findings template (task-agnostic): `docs/plans/2026-05-18-agent-view-pilot-findings.md`
- This follow-ups queue: `docs/plans/2026-05-19-followups-queue.md`
