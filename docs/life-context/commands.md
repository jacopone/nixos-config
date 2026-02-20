---
status: active
created: 2026-01-16
updated: 2026-02-20
type: reference
lifecycle: persistent
---

# /life Command Reference

## Overview

The `/life` command is your interface to the Life Context System. It reads from multiple files in `~/obsidian_brain/` depending on the subcommand — see the file map below.

**Language**: Commands in English, conversations in Italian.

### File Map

| File | Read by |
|------|---------|
| `Life Context.md` | All subcommands |
| `plan.md` | sod, goals |
| `inbox.md` | inbox, eod |
| `journal/2026/2026-WXX.md` | sod (previous), eod (current), journal |
| `projects/*.md` | project [name] |

---

## Commands

### `/life` - Summary View

Shows a quick snapshot from Life Context.md only:
- Today's date and day of week
- Quick Capture items (if any)
- Active projects status
- Current energy levels
- Top waiting-for items
- Any conflicts

```
/life
```

---

### `/life sod` - Start of Day

Interactive 5-minute morning ritual. Reads hub + plan.md + previous journal.

**Flow**:
1. Create this week's journal file if it doesn't exist (ISO week calculation)
2. Present today's commitments across all domains (events first)
3. Alignment nudge: "Oggi contribuisce a: [annual goal] → [quarterly OKR]"
4. Capture check: "C'è qualcosa di nuovo da ieri sera?"
5. Energy check and update
6. Recurring reminders from System Preferences
7. Priority setting: "Qual è la tua priorità #1 oggi?"

```
/life sod
```

---

### `/life eod` - End of Day

Interactive 5-minute evening ritual. Reads hub + inbox.md + today's journal.

**Flow**:
1. Day review: "Com'è andata oggi? Qualcosa da catturare?"
2. Process Quick Capture:
   - Completed (✅) → today's journal `### Completati`
   - Untriaged → inbox.md
   - Project-specific → relevant project file
   - Enforce max 5 rule (target 0-2 after EOD)
3. Journal entry: write 1-2 line reflection in today's `### Log`
4. Waiting-for update
5. Energy assessment
6. Tomorrow preview with conflict check
7. Optional: Desktop/Screenshots/Downloads cleanup

```
/life eod
```

---

### `/life add [text]` - Quick Capture

Add an item to Quick Capture section. Warns if already at 5 items.

**Syntax**:
```
/life add [text] [#domain]
```

**Examples**:
```
/life add dinner Friday with Marco #family
/life add quarterly review deadline Jan 25 #work
/life add waiting: blood test results from Dr.Rossi #self
```

**Parsing**:
- Dates: "Friday", "Jan 25", "tomorrow", "next week"
- Entities: `@Name`
- Domains: `#family`, `#work`, `#self`
- Types: "waiting:" prefix → ⏳

---

### `/life goals` - Goals & Alignment Review

Reads `plan.md` and displays the full alignment chain:

- **Vision** (10-Year Vision)
- **Annual Goals** (by domain)
- **Quarterly OKRs** (with progress status)

Offers interactive mode to fill placeholder sections (Life Chapters, Vision, Critical Aspects, Fears). Shows which goals have active OKRs and which are neglected.

```
/life goals
```

---

### `/life week` - Week View

Show commitments chronologically for the week from This Week section.

```
/life week
```

**Output format**:
```
This Week (Feb 17 - Feb 23):

Mon Feb 17 (Today):
- 📅 14:00 | Doctor checkup | @Dr.Rossi | #self

Tue Feb 18:
- ☐ Send proposal | @Pietro | #work
```

---

### `/life waiting` - Waiting-For View

Show all blocked items with aging from the Waiting-For table.

```
/life waiting
```

**Output format**:
```
⚠️ IN RITARDO (>7 giorni):
- Item | @Who | X giorni | blocca: Y

ATTIVI:
- Item | @Who | X giorni | blocca: Y
```

---

### `/life inbox` - Triage Inbox

Interactive triage of items in `inbox.md`.

For each item, asks:
- "Questo va in This Week, un progetto, o lo eliminiamo?"
- Options: This Week / Project [which?] / Eliminare / Lasciare in inbox

Moves items to the chosen destination and updates inbox.md.

```
/life inbox
```

---

### `/life project [name]` - Project View

View and update a specific project file from `projects/`.

- With name: fuzzy-matches the project file and displays status, open tasks, deadlines
- Without name: lists all project files
- Asks: "Vuoi aggiornare qualcosa?"

```
/life project amatino
/life project
```

---

### `/life journal [text]` - Quick Journal Entry

Append a timestamped entry to today's `### Log` section in the current week's journal file.

```
/life journal Called Pietro about TeamSystem pricing
```

Entry format: `- HH:MM | [text]`

---

## Natural Language Capture

During any Claude session, you can say:

```
"aggiungi al life context: cena venerdì con Marco"
"add to life context: meeting with Sergio next Tuesday #work"
```

Claude will parse and add to Quick Capture.
