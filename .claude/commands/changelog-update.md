---
status: active
created: 2025-12-11
updated: 2025-12-11
type: reference
lifecycle: persistent
description: Generate changelog draft from recent commits
---

# Changelog Update

Generate a changelog draft from git commits since the last CHANGELOG.md entry.

## Your Task

1. **Run the generator script**:
   ```bash
   ./scripts/generate-changelog-draft.sh
   ```

2. **Review the output**:
   - Verify the categorization makes sense (Added/Changed/Fixed)
   - Check that test hints are accurate and runnable
   - Look for any commits that were incorrectly filtered out

3. **Enhance entries if needed**:
   - Improve descriptions to be user-friendly (not just commit messages)
   - Add better test commands where the heuristics failed
   - Group related entries (e.g., multiple tools added together)

4. **Present the draft to the user**:
   Show the enhanced draft in a code block:
   ```markdown
   ## [YYYY-MM-DD]

   ### Added
   - Description with test hint

   ### Changed
   - Description

   ### Fixed
   - Description with test hint
   ```

5. **Ask for approval**:
   - Options: Append to CHANGELOG.md, Edit first, Skip
   - If approved, update the `[Unreleased]` section in CHANGELOG.md

## Filtering Rules

The script follows these rules (you should verify they make sense):

| Type | Include? | Category |
|------|----------|----------|
| `feat:` | Always | Added |
| `fix:` | Always | Fixed |
| `perf:` | Always | Changed |
| `chore:` | Only if packages.nix changed | Changed |
| `refactor:` | Only if user-facing | Changed |
| `docs:`, `ci:`, `test:` | Never | - |

## Enhancement Guidelines

When improving the raw output:

**Good test hints** (specific, runnable):
```
(Test: `echo "hello" | wl-copy && wl-paste`)
(Test: Connect Android device, run `adb devices`)
(Test: Launch Kooha from application menu)
```

**Bad test hints** (vague, not actionable):
```
(Test: Verify it works)
(Test: Check the feature)
```

**Good descriptions** (user-focused):
```
- `wl-clipboard` - Copy/paste in terminal for Wayland sessions
- ADB support for Android development and debugging
```

**Bad descriptions** (developer-focused):
```
- add wl-clipboard and kooha, simplify fish config
- enable ADB for Android development
```

## CHANGELOG.md Format

Follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/):

```markdown
## [Unreleased]

### Planned
- (Future work items)

---

## [2025-12-11]

### Added
- New feature descriptions...
```

## Important

- **NEVER auto-commit** - Always show draft and wait for approval
- **Preserve existing content** - Only add to `[Unreleased]` section
- **Date new entries** - When moving from Unreleased to dated section
