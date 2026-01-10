# Auto-Generated Permissions Update

**Generated**: 2026-01-10 09:09:17
**Rules Added**: 5

## What Happened

The Permission Auto-Learner analyzed your recent approval patterns and detected
high-confidence permission patterns that will reduce future prompts.

## Added Permissions

### Allow Cloud provider CLIs (GCP, AWS, Azure)

**Confidence**: 95.0%
**Occurrences**: 25
**Impact**: Low impact: ~0% fewer prompts

**Permissions added**:
- `Bash(gcloud:*)`
- `Bash(aws:*)`
- `Bash(az:*)`

### Allow Network/HTTP client tools

**Confidence**: 83.0%
**Occurrences**: 10
**Impact**: Low impact: ~0% fewer prompts

**Permissions added**:
- `Bash(curl:*)`
- `Bash(xh:*)`

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
