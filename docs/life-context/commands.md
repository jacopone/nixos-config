---
status: active
created: 2026-01-16
updated: 2026-01-16
type: reference
lifecycle: persistent
---

# /life Command Reference

## Overview

The `/life` command is your interface to the Life Context System. It reads and writes to `~/obsidian_brain/Life Context.md`.

**Language**: Commands in English, conversations in Italian.

---

## Commands

### `/life` - Summary View

Shows a quick snapshot:
- Today's commitments
- Current energy levels
- Top waiting-for items
- Any conflicts

```
/life
```

---

### `/life sod` - Start of Day

Interactive 5-minute morning ritual.

**Flow**:
1. Claude presents today's context
2. Asks: "Buongiorno! C'è qualcosa di nuovo da ieri sera?"
3. Asks: "Qual è la tua priorità #1 oggi?"
4. Suggests actions aligned with goals

```
/life sod
```

---

### `/life eod` - End of Day

Interactive 5-minute evening ritual.

**Flow**:
1. Claude asks: "Com'è andata oggi? Qualcosa da catturare?"
2. Asks about new commitments and waiting-for updates
3. Processes Quick Capture → proper sections
4. Suggests priorities for tomorrow

```
/life eod
```

---

### `/life add` - Quick Capture

Add an item to Quick Capture section.

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

### `/life goals` - Goals Review

Show and optionally update quarterly goals.

```
/life goals
```

Displays goals by domain with progress indicators.

---

### `/life week` - Week View

Show commitments chronologically for the week.

```
/life week
```

**Output format**:
```
This Week (Jan 16 - Jan 22):

Thu Jan 16 (Today):
- 📅 14:00 | Doctor checkup | @Dr.Rossi | #self

Fri Jan 17:
- 📅 19:00 | Dinner with parents | @Mom @Dad | #family
```

---

### `/life waiting` - Waiting-For View

Show all blocked items with aging.

```
/life waiting
```

**Output format**:
```
⚠️ OVERDUE (>7 days):
- Vacation dates | @Partner | 8 days | blocks: Work PTO

ACTIVE:
- Budget approval | @Finance | 4 days | blocks: Project kickoff
```

---

## Session Start Hook

If urgent items exist, Claude mentions them automatically:

```
[Life Context] Oggi: Dottore alle 14:00 (conflitto con standup)
```

Silent if nothing urgent.

---

## Natural Language Capture

During any Claude session, you can say:

```
"aggiungi al life context: cena venerdì con Marco"
"add to life context: meeting with Sergio next Tuesday #work"
```

Claude will parse and add to Quick Capture.
