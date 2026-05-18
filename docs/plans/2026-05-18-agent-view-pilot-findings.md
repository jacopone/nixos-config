# Agent View Pilot — Findings

**Pilot task:** P1-1 add `log_event` JSON structured logging to `rebuild-nixos`
**Pilot definition:** `docs/plans/2026-05-18-agent-view-pilot-task.md`
**Agent View version:** v2.1.139+ (Agent View shipped 2026-05-11 with `/goal`, `--bg` supervisor, auto-isolating worktrees under `.claude/worktrees/`, `claude attach|logs|stop|respawn|rm` CLI)
**Outcome:** `[FILL IN AFTER PILOT: completed | partial | failed]`
**Duration:** `[FILL IN AFTER PILOT: actual wall-clock time from launch to /goal termination]`
**Session ID:** `[FILL IN AFTER PILOT: agent session id from claude agents list]`
**Worktree path:** `[FILL IN AFTER PILOT: .claude/worktrees/<session-id>/]`

## Baseline snapshot (pre-pilot)

`[FILL IN AFTER PILOT: paste output from Task 23 Step 1 inventory commands]`

- Lines in rebuild-nixos: `[FILL IN]`
- State dir contents: `[FILL IN]`
- Existing BATS suite contents: `[FILL IN]`

## What worked

`[FILL IN AFTER PILOT: list things Agent View handled well — auto-worktree, /goal termination, log streaming, etc.]`

- ...
- ...

## What didn't work

`[FILL IN AFTER PILOT: pain points, missing features, broken expectations, surprises]`

- ...
- ...

## Comparison to `claude-autonomous.sh`

| Capability | Agent View (v2.1.139+) | claude-autonomous.sh |
|------------|------------------------|----------------------|
| Worktree isolation | auto (`.claude/worktrees/<session-id>/`) | manual `git worktree add` |
| Background runs | `--bg` + supervisor process (independent of any session) | `tmux` session |
| Completion criteria | `/goal` command (declarative, checked each turn) | `COMPLETED.md` / `BLOCKERS.md` marker file |
| Multi-iteration | implicit (agent loops within `/goal` until criteria met) | Ralph loop (`--max-iter`, default 5) |
| Log access | `claude logs <session-id>` (live stream) | `tail -f <log-file>` |
| Per-agent MCP config | `[VERIFY DURING PILOT: agent frontmatter mcpServers field — confirm whether supported]` | global `.mcp.json` override at worktree root |
| Research-mode autoresearch | NOT SUPPORTED (per 2026-05-18 audit research) | `--research --metric` |
| Strict-mode prompts | not built-in | `--strict` flag injects prompt prefix |
| Permission model | inherits parent session policy + frontmatter overrides | `--dangerously-skip-permissions` + native sandbox (bubblewrap + seccomp BPF) |
| Process lifecycle | `claude stop <id>` / `claude respawn <id>` / `claude rm <id>` | `tmux kill-session` |

## Verifier output

`[FILL IN AFTER PILOT: paste exit status + relevant output for each]`

- `./scripts/check-claude-config.sh`: `[PASS | FAIL: <reason>]`
- `bats tests/bash/rebuild-nixos/test-event-log.bats`: `[PASS | FAIL: <reason>]`
- `./rebuild-nixos --dry-run`: `[PASS | FAIL: <reason>]`
- `cat ~/.local/state/rebuild-nixos/events.jsonl | jq .`: `[valid JSON | parse errors]`
- Event count: `[FILL IN: number of JSON objects produced]`

## Recommendation

`[PICK ONE — delete the others — and write 2-3 sentences of justification referencing the table above and the verifier output]`

**Candidate framings:**

- **Migrate fully** — Agent View covers all `claude-autonomous.sh` capabilities the team actually uses; the simpler primitive is worth the loss of `[X minor feature]`. Retire `scripts/claude-autonomous.sh` after porting the remaining items in the checklist below.

- **Migrate partial: `[items, e.g. simple task mode + Ralph loop]`** — Agent View handles the common cases well, but `[research-mode autoresearch | strict-mode prompts | other]` has no equivalent. Migrate the listed items; keep `claude-autonomous.sh` for the gap.

- **Keep both: `[reason]`** — Agent View and `claude-autonomous.sh` serve different workflows. Use Agent View for `[X]`, keep `claude-autonomous.sh` for `[Y]`. No retirement.

- **Stay on claude-autonomous.sh: `[reason]`** — Agent View has blockers we can't work around (`[specific failure mode]`). Re-evaluate when `[trigger: next release, missing feature ships, etc.]`.

## Migration items for follow-up (if migrating)

- [ ] Port simple task mode to Agent View
- [ ] Port Ralph-loop mode
- [ ] Preserve research mode as `autoresearch-runner` subagent (P2-11)
- [ ] Move strict-mode prompts to reusable skill (P2-16)
