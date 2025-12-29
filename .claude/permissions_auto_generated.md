# Auto-Generated Permissions Update

**Generated**: 2025-12-29 10:04:31
**Rules Added**: 2

## What Happened

The Permission Auto-Learner analyzed your recent approval patterns and detected
high-confidence permission patterns that will reduce future prompts.

## Added Permissions

### Allow Pytest test execution

**Confidence**: 65.5%
**Occurrences**: 2
**Impact**: Low impact: ~0% fewer prompts

**Permissions added**:
- `Bash(pytest:*)`
- `Bash(python -m pytest:*)`

### Allow Ruff linter/formatter

**Confidence**: 65.5%
**Occurrences**: 2
**Impact**: Low impact: ~0% fewer prompts

**Permissions added**:
- `Bash(ruff:*)`

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
