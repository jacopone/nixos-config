# Agent View Pilot — Retargeted to Follow-up #22-I1

**Why this doc exists:** The original pilot target was P1-1 (log_event in `rebuild-nixos`), defined in `docs/plans/2026-05-18-agent-view-pilot-task.md`. P1-1 landed via subagent-driven development in commits `1d3c796` + `f262715` before the Agent View pilot ran. This doc retargets the pilot to a different small, self-contained task so the *evaluation* of Agent View can still happen.

**Retargeted goal:** Implement follow-up task #22 I1 — add `jq empty` probe in `scripts/check-claude-config.sh` to detect malformed `~/.claude/settings.json` and emit a clear error event instead of silently mishandling it.

## Goal (testable)

Add a parseability probe at the start of `check_plugin_versions` and `check_sandbox_attestation` in `scripts/check-claude-config.sh`. When `~/.claude/settings.json` is unparseable JSON:

1. Emit a single `error`-level event: `{"level":"error","check":"settings_parse","message":"~/.claude/settings.json is not valid JSON"}`
2. Skip the downstream checks (`check_plugin_versions`, `check_sandbox_attestation`) gracefully — DO NOT crash or emit misleading info events
3. Set `EXIT_CODE=2` (the validator's existing error-level exit code)
4. The validator's exit/output behavior is preserved otherwise (other checks still run if they don't depend on settings.json)

## Success criteria

1. `bats tests/bash/check-claude-config/test-skeleton.bats` passes (existing 7 tests stay green)
2. New BATS test in same file exercises the malformed-settings.json path: creates a temp `~/.claude/settings.json` containing `not valid json`, runs the validator, asserts:
   - exit code 2
   - output contains exactly one event with `check=="settings_parse"` and `level=="error"`
   - no event with `check=="plugin_version"` and `level=="info"` saying "no plugins enabled" (the current misleading message)
3. Live run on the user's actual `~/.claude/settings.json` (which IS valid JSON) is unchanged — 33 info, 4-5 warn, 0 error
4. `nix flake check` still passes

## Constraints

- Single commit, conventional format: `fix(check-claude-config): probe settings.json parseability before per-check use`
- Don't change behavior on valid settings.json
- Don't add external dependencies (jq is already used)
- Per CLAUDE.md doc policy: factual, present tense
- Don't run `./rebuild-nixos` (sudo) — but `./scripts/check-claude-config.sh` is user-runnable
- Set `/goal` completion when all 4 success criteria pass
- Estimated runtime: ~1 hour for the agent

## Out of scope for this pilot

- The remaining #22 items (I2 unused NIXOS_CONFIG, I3 tilde quoting, I4 test grep tightening, M3 plugin cache concurrency message) — separate commits
- Re-running the whole P0 plan
- Anything touching `~/.claude/settings.json` itself (read-only on the user's actual file)

## How to execute the pilot (you, the user)

Run from `~/nixos-config` in a fresh terminal (NOT inside an existing claude session):

```bash
# 1. Verify claude agents CLI is available
claude agents --help | head -20

# 2. Launch the pilot in background (--bg = supervisor process survives terminal exit)
claude agents --bg \
  --goal "$(cat docs/plans/2026-05-19-agent-view-pilot-task.md)" \
  --add-dir ~/nixos-config

# Note: exact flag syntax may have evolved; check `claude agents --help` first.
# Alternative if --bg flag isn't accepted: start interactive then use /bg

# 3. Monitor (don't poll obsessively; the supervisor outlives your terminal)
claude agents list
# Or watch logs:
claude logs <session-id>

# 4. When the agent reports /goal completion or you want to check progress:
claude attach <session-id>

# 5. When done, the agent's work lives in an auto-isolated worktree at
#    .claude/worktrees/<session-id>/. Review:
ls .claude/worktrees/
cd .claude/worktrees/<session-id>
git log --oneline main..HEAD
git diff main..HEAD

# 6. If approved, merge back to personal:
cd ~/nixos-config
git merge --ff-only <session-id-branch-name>
# OR cherry-pick specific commits

# 7. Clean up the worktree:
git worktree remove .claude/worktrees/<session-id>
```

## When done — fill out the findings template

The findings template at `docs/plans/2026-05-18-agent-view-pilot-findings.md` is task-agnostic and remains valid for this retargeted pilot. Update the outcome / duration / what-worked / what-didn't / migration recommendation sections after the pilot completes.

The capability comparison table in that doc is the most valuable artifact — fill in any rows marked `[VERIFY DURING PILOT]` based on what you observe during the run.

## Why this target is good for evaluating Agent View

- **Touches bash + jq + BATS** — the patterns this codebase uses heavily
- **Has a TDD shape** — write failing test, implement, pass — natural fit for `/goal` completion
- **Self-contained** — no upstream dependencies, no waiting on external systems
- **Small enough** (~1h) — pilot can complete in reasonable wall-time
- **Real cleanup value** — the #22 I1 issue is a known bug; even if Agent View struggles, the bug gets fixed
- **Stresses the supervisor model** — short enough to compare against `claude-autonomous.sh` Ralph loops, which were the original P0-4 motivation

## Related docs

- Original pilot doc (historical): `docs/plans/2026-05-18-agent-view-pilot-task.md`
- Findings template (still valid): `docs/plans/2026-05-18-agent-view-pilot-findings.md`
- Source of follow-up #22: P0-8 Phase 4 validator implementation, code review of commits `c3ffca3..20869af`
