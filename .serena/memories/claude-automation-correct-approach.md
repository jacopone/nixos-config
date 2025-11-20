# Claude Automation: Correct Architecture (Merge Approach)

## Decision: Merge User Policies Into Single CLAUDE.md

After ultrathinking, the **merge approach is superior to @import** for this use case.

## Why Merge Is Better

1. **100% Reliability**: Single file guaranteed read at initialization
2. **No Import Dependency**: No uncertainty about @import edge cases
3. **Critical Policies**: User behavioral rules MUST be enforced, can't risk silent import failure
4. **Clear Architecture**: Source (user-editable) → Generator → Artifact (Claude-readable)

## Architecture

```
SOURCE FILES (User-Editable):
  ~/.claude/CLAUDE-USER-POLICIES.md  ← User maintains this
  modules/core/packages.nix          ← System packages
  modules/home-manager/base.nix      ← Fish config

GENERATION PROCESS:
  claude-automation reads all sources
  ↓
  Merges into single document
  ↓
  Generates artifact

OUTPUT ARTIFACT (Claude-Readable):
  ~/.claude/CLAUDE.md  ← AUTO-GENERATED, Claude reads this
```

## Implementation Changes Required

### File: `claude_automation/generators/system_generator.py`

```python
def generate(self) -> GenerationResult:
    """Generate system CLAUDE.md with merged user policies."""

    # 1. Load user policies (if exists)
    user_policies_file = Path.home() / ".claude" / "CLAUDE-USER-POLICIES.md"
    user_policies_content = ""
    if user_policies_file.exists():
        user_policies_content = user_policies_file.read_text()

    # 2. Parse system configuration
    packages = self.parse_packages()
    fish_abbrevs = self.parse_fish_config()

    # 3. Build context with user policies
    context = {
        "timestamp": datetime.now(),
        "user_policies": user_policies_content,
        "has_user_policies": bool(user_policies_content),
        "tool_categories": categorize_tools(packages),
        "fish_abbreviations": fish_abbrevs,
    }

    # 4. Render merged template
    content = self.render_template("system-claude.j2", context)

    # 5. Write to ~/.claude/CLAUDE.md
    return self.write_file(self.output_file, content)
```

### File: `claude_automation/templates/system-claude.j2`

```jinja2
# System-Level CLAUDE.md

*Last updated: {{ timestamp.strftime('%Y-%m-%d %H:%M:%S') }}*

{% if has_user_policies %}
## 🎯 USER-DEFINED POLICIES

**These policies have TOP PRIORITY and override all system defaults.**

{{ user_policies }}

---

{% endif %}

## 🛠️ SYSTEM TOOLS & CONFIGURATION

**SYSTEM OPTIMIZATION LEVEL: EXPERT**
{% include 'shared/policies.j2' %}

{% include 'shared/command_examples.j2' %}

## System Information
...
```

### File: `claude_automation/templates/shared/policies.j2`

**REMOVE the @import or "check" instruction** - not needed anymore since merged.

## User Workflow

1. **Edit policies**: `nano ~/.claude/CLAUDE-USER-POLICIES.md`
2. **Rebuild system**: `cd ~/nixos-config && ./rebuild-nixos`
3. **Auto-merged**: User policies merged into `~/.claude/CLAUDE.md`
4. **Claude reads**: Single merged file at initialization

## Benefits Over @import

| Aspect | Merge Approach | @import Approach |
|--------|---------------|-----------------|
| Reliability | ✅ 100% guaranteed | ❓ Depends on import mechanism |
| Precedence | ✅ User policies at top | ❓ Uncertain if equal weight |
| Debugging | ✅ One file to check | ❌ Two files + import resolution |
| Edge Cases | ✅ None (simple file read) | ❓ Unknown edge cases |
| User Model | ✅ Source → Generate → Read | ❓ Main file + imported file |

## Migration Path

1. Update `system_generator.py` to read and merge user policies
2. Update `system-claude.j2` template to include user policies section
3. Remove @import or "check" instruction from `policies.j2`
4. Test: Edit user policies, rebuild, verify merged in CLAUDE.md
5. Document: User policies source vs Claude-readable artifact

## Conclusion

User was correct to question @import approach. Merge is more reliable for critical behavioral policies.
