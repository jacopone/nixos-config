# Auto-Generated Permissions Update

**Generated**: 2025-12-27 09:23:44
**Rules Added**: 4

## What Happened

The Permission Auto-Learner analyzed your recent approval patterns and detected
high-confidence permission patterns that will reduce future prompts.

## Added Permissions

### Allow File write/edit operations

**Confidence**: 95.3%
**Occurrences**: 498
**Impact**: Low impact: ~5% fewer prompts

**Permissions added**:
- `file_write_operations`

### Allow File read operations

**Confidence**: 95.2%
**Occurrences**: 1717
**Impact**: Low impact: ~18% fewer prompts

**Permissions added**:
- `Read(/**)`
- `Write(/**)`
- `Edit(/**)`
- `Glob(**)`

---

These permissions have been automatically added to `.claude/settings.local.json`.
You can review and modify them at any time.

To disable auto-generation, set:
```json
{
  "_auto_generated_permissions": {
    "enabled": false
  }
}
```
