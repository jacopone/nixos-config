# 🤖 Claude Code Automation System

> **⚠️ DEPRECATED - 2025-10-06**
>
> This documentation has been deprecated because the claude-automation system was extracted to a separate repository on 2025-10-03.
>
> **Implementation details now maintained in the source repository.**

---

## 📍 Current Documentation Locations

### For High-Level Architecture

See **[CLAUDE_ORCHESTRATION.md](../../CLAUDE_ORCHESTRATION.md)** for:
- Three-level Claude Code orchestration system (System/Project/Template)
- How auto-generation integrates with `./rebuild-nixos`
- Manual trigger commands
- Troubleshooting and maintenance

### For Implementation Details

See **[Claude NixOS Automation Repository](https://github.com/jacopone/claude-nixos-automation)** for:
- Source code and implementation
- Generator architecture (system/project)
- Jinja2 templates
- Nix parser implementation
- Validation layer
- Development environment setup

**Local clone**: `~/claude-nixos-automation/README.md`

---

## Quick Reference

### Trigger Manual Update

```bash
cd ~/nixos-config
nix run github:jacopone/claude-nixos-automation#update-all
```

### Update Only System CLAUDE.md

```bash
nix run github:jacopone/claude-nixos-automation#update-system
```

### Update Only Project CLAUDE.md

```bash
nix run github:jacopone/claude-nixos-automation#update-project
```

---

## Historical Reference

The original implementation details documentation has been preserved at:

**[docs/archive/claude-automation-system-OLD.md](../archive/claude-automation-system-OLD.md)**

---

**Reason for Deprecation**: Implementation details belong in the source repository, not in the nixos-config documentation. This keeps documentation focused on usage and integration rather than internal implementation.

**Last Updated**: 2025-10-06
