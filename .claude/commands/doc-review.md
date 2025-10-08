---
status: active
created: 2025-10-08
updated: 2025-10-08
type: reference
lifecycle: persistent
description: Interactive cleanup of old markdown documentation
---

# Documentation Review & Cleanup

Perform an interactive review of markdown documentation in this repository.

## Your Task

1. **Find ephemeral documents that need action**:
   - Search for all `.md` files with `lifecycle: ephemeral`
   - Filter to those with `status: draft` older than 30 days
   - Filter to those with `status: archived` that are still in active directories

2. **Analyze each document**:
   - Read the frontmatter and first few paragraphs
   - Determine if it's:
     - **Unexecuted planning** → Should be archived to `docs/archive/planning-YYYY-MM/`
     - **Outdated session notes** → Should be archived to `docs/archive/session-notes-YYYY-MM/`
     - **Still relevant draft** → Propose promoting to `status: active`
     - **Should be deleted** → No longer useful

3. **Present findings as a table**:

| File | Type | Age (days) | Status | Recommendation | Reason |
|------|------|------------|--------|----------------|--------|
| docs/planning/foo.md | planning | 45 | draft | Archive | Unexecuted, superseded by current implementation |
| basb-system/old.md | session-note | 120 | archived | Delete | Historical, no reference value |

4. **Ask for approval before taking action**:
   - Show exactly what will be moved/deleted
   - Wait for explicit "yes" before executing
   - Use `git mv` for moves (preserves history)

## Important Policies

- **NEVER delete architecture docs** (lifecycle: persistent)
- **NEVER delete active guides** (status: active)
- **ASK before archiving anything less than 60 days old** (might still be relevant)
- **Preserve git history** - use `git mv`, not `rm` + create new file

## Output Format

Start with a summary:
```
📊 Documentation Review Results

Found 12 ephemeral documents:
- 5 unexecuted planning docs (draft, >30 days)
- 3 old session notes (archived, >90 days)
- 4 still relevant drafts

Recommended actions:
- Archive: 8 files
- Delete: 0 files (propose to user)
- Promote to active: 4 files
```

Then show the detailed table and wait for approval.
