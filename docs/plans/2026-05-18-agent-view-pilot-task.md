# Agent View Pilot — P1-1: rebuild-nixos log_event

**Goal:** Add structured JSON event logging to rebuild-nixos at every phase boundary.

**Success criterion (testable):**
1. `./rebuild-nixos --dry-run` produces `~/.local/state/rebuild-nixos/events.jsonl` with N+ JSON objects (one per phase boundary)
2. Every line is valid JSON parseable by `jq`
3. Each event has fields: `ts` (ISO timestamp), `phase` (phase number/name), `event` (start|complete|skip|fail), `duration_ms` (where applicable)
4. `bats tests/bash/rebuild-nixos/test-event-log.bats` passes

**Constraints:**
- Don't change existing log behavior (the text log at $LOG_FILE stays)
- Don't break --dry-run, --quick, --boot modes
- Don't add external dependencies beyond `jq` and `date` (both already in PATH)
- Set /goal completion when all 4 success criteria pass

**Out of scope:**
- The MCP server that consumes events.jsonl (that's P1-2, separate)
- Statusline's last-status file (that's a 1-line addition in the exit handler — fine to include if convenient)

---

## How to execute the pilot (user action)

Run from `~/nixos-config` in a fresh terminal — NOT inside an existing `claude` session. The `--bg` supervisor process is independent of any Claude session, so launching it from a sub-agent dispatch is unreliable.

### Step 1: Inventory baseline

Capture before-state so the findings doc has comparable numbers:

```bash
echo "Lines in rebuild-nixos: $(wc -l < rebuild-nixos)"
ls -la ~/.local/state/rebuild-nixos/ 2>/dev/null || echo "no state dir"
ls tests/bash/rebuild-nixos/
```

Save output for the findings doc.

### Step 2: Verify CLI syntax

Agent View CLI flags may have evolved since v2.1.139. Confirm syntax first:

```bash
claude agents --help
```

### Step 3: Launch the pilot agent

```bash
claude agents --bg \
  --goal "$(cat docs/plans/2026-05-18-agent-view-pilot-task.md)" \
  --add-dir ~/nixos-config
```

Auto-isolation places the agent's worktree under `.claude/worktrees/<session-id>/`.

### Step 4: Monitor (don't poll obsessively)

```bash
claude agents list
claude logs <session-id>
```

The `/goal` overlay tracks elapsed time, turn count, and token usage. Let the agent run until it terminates on its own — either by meeting `/goal` criteria or by failing loudly. Hard ceiling: 4 hours.

### Step 5: Review the agent's output

When the agent terminates:

```bash
# Inspect commits on the agent's worktree branch
cd .claude/worktrees/<session-id>
git log --oneline

# Run validators against the agent's changes
./scripts/check-claude-config.sh
bats tests/bash/rebuild-nixos/test-event-log.bats
./rebuild-nixos --dry-run
cat ~/.local/state/rebuild-nixos/events.jsonl | jq .
```

### Step 6: Cherry-pick or merge

If the agent's commits pass review, cherry-pick or merge them into `personal`. If they don't pass, drop them — the worktree is disposable.

### Step 7: Write findings

Fill in `docs/plans/2026-05-18-agent-view-pilot-findings.md` based on what happened during the pilot. The template has `[FILL IN AFTER PILOT]` placeholders for outcome, duration, what-worked, what-didn't, and the migration recommendation.
