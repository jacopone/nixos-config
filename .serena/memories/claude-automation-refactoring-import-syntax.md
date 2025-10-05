# Claude Automation Refactoring: Import Syntax Fix

## Problem Identified (2025-10-05)

**User's suspicion was 100% CORRECT!**

The current `claude-nixos-automation` implementation does NOT properly import user policies. It uses an instructional approach that Claude may ignore:

```markdown
### 📋 User-Defined Policies
**ALWAYS check `~/.claude/CLAUDE-USER-POLICIES.md` for user-specific policies that override defaults.**
```

This is just a text instruction to Claude - NOT an actual import. Claude may or may not follow this instruction depending on context.

## Official Documentation Findings

From Claude Code docs (https://docs.claude.com/en/docs/claude-code/memory.md):

1. **Proper Import Syntax**: `@path/to/file`
2. **Example**: `@~/.claude/my-project-instructions.md`
3. **Behavior**: Files are actually loaded and processed at startup
4. **Precedence**: Files higher in hierarchy load first and take precedence
5. **Max Depth**: 5 file hops for recursive imports
6. **Deprecated**: CLAUDE.local.md is replaced by imports

## Required Refactoring

### Change in `claude-nixos-automation`

**Current (WRONG)**:
```markdown
### 📋 User-Defined Policies
**ALWAYS check `~/.claude/CLAUDE-USER-POLICIES.md` for user-specific policies that override defaults.**
```

**Should be (CORRECT)**:
```markdown
### 📋 User-Defined Policies

@~/.claude/CLAUDE-USER-POLICIES.md
```

This ensures:
- ✅ User policies are actually loaded at startup
- ✅ They have the same weight as main CLAUDE.md content
- ✅ They can override system defaults properly
- ✅ No reliance on Claude "remembering" to check another file

## Impact

This affects:
- `claude-nixos-automation` repository (needs template update)
- `scripts/claude_automation/templates/system-claude.j2` 
- All generated `~/.claude/CLAUDE.md` files

## Next Steps

1. Update claude-nixos-automation repository templates
2. Regenerate system CLAUDE.md
3. Verify user policies are properly loaded
4. Document the import syntax in architecture docs
