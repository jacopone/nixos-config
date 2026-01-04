# Auto-Generated Permissions Update

**Generated**: 2026-01-02 01:24:30
**Rules Added**: 3

## What Happened

The Permission Auto-Learner analyzed your recent approval patterns and detected
high-confidence permission patterns that will reduce future prompts.

## Added Permissions

### Allow Nix/NixOS ecosystem tools

**Confidence**: 93.1%
**Occurrences**: 31
**Impact**: Low impact: ~0% fewer prompts

**Permissions added**:
- `Bash(nix:*)`
- `Bash(devenv:*)`

### Allow Shell built-ins and utilities

**Confidence**: 89.8%
**Occurrences**: 20
**Impact**: Low impact: ~0% fewer prompts

**Permissions added**:
- `Bash(echo:*)`
- `Bash(which:*)`

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
