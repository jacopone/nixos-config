---
status: draft
created: 2026-02-15
updated: 2026-02-15
type: planning
lifecycle: persistent
---

# Demo Reports for Autonomous Agents

## Problem

When autonomous agents complete work overnight (via `claude-autonomous.sh`), the morning review relies on git diffs and test results. For UI-heavy projects like Account Harmony AI, this misses visual regressions, layout issues, and UX problems. The reviewer must manually start the dev server and navigate to verify.

## Design

Agents produce a structured demo report (`DEMO.md` + screenshots) after completing their primary task. The pattern is generic across all projects but adapts based on per-project configuration.

## Components

### 1. Per-Project Opt-In: `.claude/demo-config.md`

Projects with visual UI place a `.claude/demo-config.md` file that tells agents what to demo:

```markdown
# Demo Configuration

## Dev Server
- command: `npm run dev`
- url: http://localhost:8080
- ready-signal: "ready in"

## Key Pages
- /dashboard (role: accountant)
- /clients (role: accountant)
- /compliance (role: accountant)
- /client-portal (role: client)

## Auth
- Test credentials from .env.example or seed data
```

If this file is absent, the agent produces a text-only demo report (command outputs, test results, change summary). No screenshots.

### 2. Prompt Appendix in `claude-autonomous.sh`

The autonomous launcher appends a demo-report instruction block to the agent prompt. The instruction tells the agent to:

1. Complete the primary task first
2. Check for `.claude/demo-config.md`
3. If present: start dev server, use Playwright MCP to navigate affected pages, capture screenshots into `.demo/`
4. Write `DEMO.md` at worktree root following the template
5. If absent: write text-only `DEMO.md` with command outputs and change summary

### 3. Morning Review Integration

`claude-morning-review.sh --report` checks each worktree for `DEMO.md` and includes it in the report output. The `--merge` flow shows the demo before prompting for merge decision.

## Output Structure

```
.worktrees/<task-name>/
  DEMO.md              # Structured demo report
  .demo/               # Screenshots directory
    01-<description>.png
    02-<description>.png
  src/...              # Actual code changes
```

## DEMO.md Template

```markdown
# Demo: [Task Name]
**Branch:** <branch-name>
**Date:** <date>

## Summary
[What was built and why, 1-2 sentences]

## Changes Made
- [File-level summary]

## Visual Demo
### [Page/Feature Name]
![Description](.demo/01-description.png)
[What this screenshot shows]

## Test Results
- Unit: [pass/fail count]
- E2E: [pass/fail count]
- Build: [status]

## Open Questions
- [Anything uncertain]
```

## Decisions

- **Screenshot tool**: Playwright MCP (already available to agents, richer than CLI alternatives)
- **Output location**: Worktree root `DEMO.md` + `.demo/` directory (easy discovery)
- **Scope**: Generic in nixos-config scripts, per-project opt-in via `.claude/demo-config.md`
- **Detection**: Convention file, not auto-detection (explicit > heuristic)
- **Text-only fallback**: Always produce DEMO.md, just without screenshots for non-UI projects

## Files to Modify

1. `scripts/claude-autonomous.sh` — append demo report instructions to agent prompt
2. `scripts/claude-morning-review.sh` — detect and display DEMO.md in report/merge flows
3. `~/account-harmony-ai-37599577/.claude/demo-config.md` — first project opt-in (new file)
