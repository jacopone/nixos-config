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

## File Architecture

| File | Location | Purpose |
|------|----------|---------|
| **Life Context** | `~/obsidian_brain/Life Context.md` | Operational hub (~150 lines) |
| **Plan** | `~/obsidian_brain/plan.md` | Vision, annual goals, quarterly OKRs |
| **Inbox** | `~/obsidian_brain/inbox.md` | Untriaged items buffer |
| **Journal** | `~/obsidian_brain/journal/2026/2026-WXX.md` | Weekly journal entries |
| **Projects** | `~/obsidian_brain/projects/*.md` | One file per active project |
| **Reference** | `~/obsidian_brain/reference/*.md` | Contacts, watchlist, ideas, notes |
| **Health** | `~/obsidian_brain/Health/Health Protocol.md` | Health log, visits, meds |
| **/life command** | `~/.claude/commands/life.md` | Claude Code skill |
| **Documentation** | `~/nixos-config/docs/life-context/` | This folder |

Life Context.md is the hub — it links to everything else via Obsidian wiki-links.

## Commands

| Command | Purpose |
|---------|---------|
| `/life` | Quick summary (reads hub only) |
| `/life sod` | Start of Day ritual (5 min) |
| `/life eod` | End of Day ritual (5 min) |
| `/life add [text]` | Quick capture (max 5 items) |
| `/life goals` | Vision + goals + OKRs alignment review |
| `/life week` | This week's view |
| `/life waiting` | All blockers with aging |
| `/life inbox` | Interactive inbox triage |
| `/life project [name]` | Project detail view |
| `/life journal [text]` | Quick timestamped journal entry |

## Design Principles

1. **< 5 minutes** per ritual
2. **Hub + satellites** — Life Context.md links to purpose-specific files
3. **Alignment chain** — Vision → Annual Goals → Quarterly OKRs → This Week → Today
4. **Bilingual** — Commands in English, conversations in Italian
5. **Quick Capture max 5** — overflow goes to inbox, processed in EOD

## Documentation

- [Taxonomy](./taxonomy.md) - Domain structure and MECE types
- [Commands](./commands.md) - Full command reference
- [Sunsama Integration](./sunsama-integration.md) - Calendar blocking

## Related

- Obsidian vault: `~/obsidian_brain/` — all life system files
- Sunsama MCP: `~/sunsama-mcp/` — calendar event creation
