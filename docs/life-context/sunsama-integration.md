---
status: active
created: 2026-01-16
updated: 2026-01-16
type: guide
lifecycle: persistent
---

# Sunsama Calendar Integration

## Overview

The Life Context System can integrate with Sunsama to:
- Block calendar time for commitments
- Show today's tasks alongside Life Context
- Detect calendar conflicts

## MCP Server

**Location**: `~/sunsama-mcp/` (clone of [robertn702/mcp-sunsama](https://github.com/robertn702/mcp-sunsama))

**Package**: `mcp-sunsama` (npm)

---

## Calendar Tools

### `get-calendars`

List all available calendars (Google, Outlook, Apple).

**Response includes**:
- `calendarId` - Unique identifier (email for Google, GUID for Microsoft)
- `displayName` - Human-readable name
- `service` - Provider (google, microsoft, apple)

### `create-calendar-event`

Block time on a specific calendar.

**Required parameters**:
```json
{
  "title": "Meeting title",
  "startDate": "2026-01-20T14:00:00.000Z",
  "endDate": "2026-01-20T15:00:00.000Z",
  "calendarId": "user@gmail.com"
}
```

**Optional parameters**:
- `description` - Event notes
- `location` - Event location
- `timeZone` - Override default timezone
- `isAllDay` - All-day event flag

---

## Setup

### 1. Build the MCP Server

```bash
cd ~/sunsama-mcp
bun run build
```

### 2. Configure in .mcp.json

Add to your project's `.mcp.json` (e.g., `~/nixos-config/.mcp.json`):
```json
{
  "mcpServers": {
    "sunsama": {
      "command": "node",
      "args": ["/home/guyfawkes/sunsama-mcp/dist/src/main.js"],
      "cwd": "/home/guyfawkes/sunsama-mcp"
    }
  }
}
```

### 3. Test

```bash
cd ~/sunsama-mcp
bun run inspect
```

---

## Life Context Integration

### Current Flow (Manual)

1. Add commitment to Life Context via `/life add`
2. If you want to block calendar time, manually call Sunsama tools

### Future Flow (Planned)

| Life Context Action | Sunsama Integration |
|---------------------|---------------------|
| `/life add` with date | → Ask "Bloccare sul calendario?" → `create-calendar-event` |
| `/life sod` | → Show today's Sunsama tasks |
| `/life week` | → Include calendar events for conflict detection |

---

## Workflow Example

```
1. Get your calendars:
   User: "quali calendari ho?"
   Claude: [calls get-calendars]
   → Personal (user@gmail.com)
   → Work (outlook-guid)
   → Family (shared@gmail.com)

2. Block time:
   User: "blocca 2 ore domani per la quarterly review sul calendario Work"
   Claude: [calls create-calendar-event with calendarId=outlook-guid]
   → Event created in Sunsama and synced to Outlook

3. Verify:
   Check Sunsama UI - event should appear on your calendar
```

---

## Limitations

| Feature | Status |
|---------|--------|
| Create events | ✅ Working |
| List calendars | ✅ Working |
| Send invitations | ❌ Not yet |
| Recurring events | ❌ Not yet |
| Modify events | ❌ Not yet |
| Delete events | ❌ Not yet |
| Conflict detection | ❌ Manual |

---

## Troubleshooting

### Auth Issues

Session tokens are stored in `~/.sunsama-mcp/session-token.json`. If expired:
1. Delete the token file
2. Re-authenticate via `bun run inspect`

### Build Errors

```bash
cd ~/sunsama-mcp
bun install
bun run build
```

### Calendar Not Found

Make sure the calendar is:
1. Connected in Sunsama settings
2. Visible in Sunsama UI
3. Using correct `calendarId` from `get-calendars`
