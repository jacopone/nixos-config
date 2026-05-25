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

**[COMPLETED]** (2026-05-20) Commits `af54bfc` (BATS tests) + `d69812c` (agent definitions). Executed via subagent-driven-development: implementer + spec review (caught a vacuous-pass bug) for the BATS work; direct edits for the agent prose; one final code review over the whole batch (ship-ready, no critical/important issues).

Done:
- BATS path portability — hardcoded `/home/guyfawkes/nixos-config/...` → `$(git rev-parse --show-toplevel)` in `test-frontmatter-valid.bats` + `test-statusline-format.bats`, matching `test-managed-settings.bats:14`.
- I1 — Bash tool scope documented per agent (package-finder has no Bash; the 3 Bash-enabled agents note why they have it).
- I2 — flake-debugger output format specifies unified diff (`diff -u` / `git diff`).
- I3 — generation-differ validates generation profile links exist and asks which two to compare if missing; never diffs a nonexistent link.
- I4 — supply-chain-auditor CVE cross-ref DROPPED (decided over add-WebFetch). The agent's `tools: Bash, Read, Grep` grant no network access, so the NVD/CVE claim was unbacked. Removed the step, the Vulnerabilities output section, and the description clause.
- I5 — reworded "run `./rebuild-nixos --audit` against the user" → "ask the user to run".
- I6 — "ask if missing input" added to all 4 agents (consistent phrasing/placement).
- M2 — required-fields test extended from flake-debugger alone to all 4 subagents. Spec review caught a vacuous-pass: `yq eval '.tools'` prints `null` for a missing key, which matched the original `grep -qE '\w'`; fixed to `[[ -n "$tools" && "$tools" != "null" ]]`.
- M3 — `test-agents-deployed.bats` converted from hard-fail to skip-with-message pre-rebuild (asserts when symlinks present).
- M6 — package-finder references the CLAUDE.md "Where to put what" table (`CLAUDE.md:114`) instead of duplicating it (removes drift risk).
- M7 — flake-debugger verb consistency: "invoke" → "run" for `nix flake check`.

Deferred / not actioned:
- M5 (commit-prose tweak) — too vague to action without the originating code-review note. Re-file with specifics if still wanted.
- M1, M4 — no actionable description was captured in this queue entry. Revisit the Tasks 14-15 code review if these still matter.

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

Per P1-1 code review of commits `1d3c796` + `f262715`. **All items [COMPLETED]:** I3+M5 in `4d47eb4`; I1, I2, I4, M1, M2 in the #24-polish session (2026-05-25, commits `e4f3d77`..`519b21a`, local on `personal`). Note: I3 relocated the event-log helpers to `lib/event-log.sh`, so the I2/M1/M2 anchors point at the lib, not `rebuild-nixos`.

- **I1** — **[COMPLETED]** `acaabe2` (+ `519b21a` scaffold cleanup). statusline annotates `last:succ(2d)` from the last-status mtime in `statusline.sh` (`format_age`: s/m/h/d floored, future mtime clamps to `0s`, missing file → no suffix). 3 bats tests added.
- **I2** — **[COMPLETED]** `996a15a`. Comment near the `LAST_STATUS_FILE=` declaration in `lib/event-log.sh` explaining the two-sink duality: append-only JSONL `EVENT_LOG` (telemetry history) vs one-word `LAST_STATUS_FILE` (O(1) statusline read).
- **I3 (most useful)** — **[COMPLETED]** `4d47eb4`. Extracted event-log helpers to `lib/event-log.sh`; `rebuild-nixos` and `test-event-log.bats` both source it. The fragile awk extraction (single-match anchors `^EVENT_LOG_DIR=`, `^step_skip\(\)`, etc.) is gone — a rename now fails loudly at source time instead of silently capturing the wrong range.
- **I4** — **[COMPLETED]** `8814a25`. Consolidated the four `log_event` field tests → 1 and the three `step` field tests → 1 via `jq -e` (29 → 24). Coverage tightened, not weakened: `jq -e` fails on wrong OR absent fields, and the step test now catches a number-vs-string type regression the old `jq -r` compare missed. Non-vacuity proven against bad input.
- **M1** — **[COMPLETED]** `e4f3d77`. Renamed `step_done` → `step_complete` across `lib/event-log.sh`, the two `rebuild-nixos` call sites, and the bats suite (incl. the `^step_complete()` definition grep). rg-clean; 24/24 tests green.
- **M2** — **[COMPLETED]** `996a15a`. Comment at `lib/event-log.sh:now_ms()` notes it is wall-clock, not monotonic — durations can skew across NTP steps or suspend.
- **M5** — **[COMPLETED]** `4d47eb4`. `CURRENT_STEP=0` is initialized in `lib/event-log.sh`; the test no longer injects it and the redundant init in `rebuild-nixos` was removed.

### #25 — Native sandbox write-deny binds break in-session libgit2 (e.g. nix flake check)

Identified during #18 work (2026-05-19); **re-framed 2026-05-20** after surveying the mechanism — the original "add a teardown hook to the launcher" framing was wrong on two counts (see below).

**Accurate mechanism.** The deny-mounts are created by Claude Code's *native* sandbox (`@anthropic-ai/sandbox-runtime`, wired in at `modules/home-manager/claude-code/default.nix:38`), NOT by our launcher. `scripts/claude-autonomous.sh:606-607` confirms it delegates to the native sandbox — it launches `claude` and the runtime self-sandboxes. Under that sandbox, `/dev/null` (char device 1/3) is bind-mounted over a set of paths (`.gitmodules`, `.mcp.json`, `.claude/settings.json`, `.claude/skills`, `.claude/agents`, `etc/`, `home/`, `.nix-store/`, `.nix-cache-eval/`, shell rc / IDE state files) — almost certainly a write-deny technique (replace the file with an unwritable node).

**Symptom.** Within a live session, libgit2 cannot *read* `.gitmodules` (it is now `/dev/null`), so `nix flake check`, `nix eval`, and `nix build` of any flake attr fail with `parsing .gitmodules file: failed open ... Permission denied (libgit2 error code = 2)`. The write-deny bind also breaks read.

**Two corrections to the original framing:**
- *Not a teardown problem.* Our launcher never creates these mounts (the native runtime does), so a teardown hook in `claude-autonomous.sh` cannot unmount them. Infeasible as written.
- *Not cross-session persistence.* The mounts are namespace-private: a host shell's `find` shows nothing while an in-session `find` shows the char-devices. When a `claude` session's mount namespace exits, the kernel destroys them automatically; a fresh `claude` starts clean. The earlier `sudo rm` "recovery" was a no-op on the host (nothing there to delete).

**Practical workaround (unchanged):** run `nix flake check` / `nix build` from a non-Claude (host) shell. The in-session path is blocked; the host path is clean. For repo work that is purely scripts/tests (not Nix inputs), in-session `bash -n` + `shellcheck` + `bats` validate fully without needing flake-check at all.

**A real fix would require one of (deferred):**
- *Sandbox-config exclusion:* determine whether the harness/`settings.json`/managed-settings filesystem rules can stop write-denying `.gitmodules` so the bind never happens. Uncertain, and `.gitmodules` write-deny may be a deliberate guard (prevent the agent injecting submodules) — needs care.
- *Upstream report:* file with Anthropic that a `/dev/null` write-deny bind breaks read-only consumers like libgit2.

**Severity:** low–medium. No data loss, no host pollution, no cross-session bleed. Cost is ~5 min of friction when Nix-input work needs flake-check from inside a session — mitigated by validating from the host shell.

Cross-reference: supersedes the "bwrap deny-mount leakage in repo root" note under "Two unresolved infrastructure items" below.

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

- **bwrap deny-mount char-devices in repo root** — within a sandboxed Claude session, `/dev/null` char-devices appear at `.mcp.json`, `.gitmodules`, `etc/`, `home/`, `.nix-store/`, `.nix-cache-eval/`, etc. **Superseded by #25 (re-framed 2026-05-20):** these are namespace-private write-deny binds from Claude Code's native sandbox-runtime — not a "leak" (a host shell sees nothing) and not cross-session (they die with the session's namespace). They are gitignored. See #25 for the accurate mechanism and why the in-session `nix flake check` failure is the real impact.

---

## Suggested resume order

1. **Run the Agent View pilot** (per `docs/plans/2026-05-19-agent-view-pilot-task.md`) targeting #22-I1. This validates Agent View as a tool AND lands the most consequential follow-up (settings.json parseability) in one shot.
2. Lower-priority polish: #15, #17, #20, the rest of #22. Plus #21's deferred M1/M4/M5 if revisited. (#24 fully resolved 2026-05-25 — see its section.)
3. **#25** (deferred / investigation) — re-framed 2026-05-20 to the accurate finding (native-sandbox write-deny binds break in-session libgit2). No quick fix: a real fix needs sandbox-config exclusion or an upstream report; the host-shell workaround stands. Pick up only if in-session `nix flake check` becomes a recurring pain.

## Where the canonical artifacts live

- Audit: `docs/plans/2026-05-18-claude-code-advancements-audit.md`
- Implementation plan: `docs/plans/2026-05-18-claudeos-p0-implementation.md`
- Sandbox investigation finding: `docs/plans/2026-05-18-sandbox-schema-finding.md`
- Agent View pilot (original P1-1 target, historical): `docs/plans/2026-05-18-agent-view-pilot-task.md`
- Agent View pilot (retargeted to #22-I1, current): `docs/plans/2026-05-19-agent-view-pilot-task.md`
- Agent View findings template (task-agnostic): `docs/plans/2026-05-18-agent-view-pilot-findings.md`
- This follow-ups queue: `docs/plans/2026-05-19-followups-queue.md`
