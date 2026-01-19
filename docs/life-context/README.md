---
status: active
created: 2026-01-16
updated: 2026-01-16
type: guide
lifecycle: persistent
---

# Life Context System

> **Philosophy**: Small daily effort, consistent. A system you use daily beats a perfect system you abandon.

## Quick Start

1. **Morning**: Run `/life sod` in Claude Code (nixos-config)
2. **During day**: Say "add to life context: [item] #domain" or use `/life add`
3. **Evening**: Run `/life eod` before closing

## Core Files

| File | Location | Purpose |
|------|----------|---------|
| Life Context | `~/obsidian_brain/Life Context.md` | Single source of truth |
| /life command | `~/.claude/commands/life.md` | Claude Code skill |
| Documentation | `~/nixos-config/docs/life-context/` | This folder |

## Commands

| Command | Purpose |
|---------|---------|
| `/life` | Quick summary |
| `/life sod` | Start of Day ritual (5 min) |
| `/life eod` | End of Day ritual (5 min) |
| `/life add [text]` | Quick capture |
| `/life goals` | Review quarterly goals |
| `/life week` | This week's view |
| `/life waiting` | All blockers |

## Design Principles

1. **< 5 minutes** per ritual
2. **One file** - no complex folder structures
3. **Grow organically** - add structure when pain demands it
4. **Bilingual** - Commands in English, conversations in Italian
5. **Goals + Commitments** - Track where you're going AND what you've agreed to

## Documentation

- [Taxonomy](./taxonomy.md) - Domain structure and MECE types
- [Commands](./commands.md) - Full command reference
- [Sunsama Integration](./sunsama-integration.md) - Calendar blocking

## Related

- Sunsama MCP: `~/sunsama-mcp/` - Calendar event creation
- Obsidian vault: `~/obsidian_brain/` - Life Context file location
