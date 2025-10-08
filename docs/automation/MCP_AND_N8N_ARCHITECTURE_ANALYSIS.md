# MCP Servers & n8n Architecture Analysis

> **Session Date:** 2025-10-07
> **Status:** Analysis complete - Recommended implementation path defined
> **Next Action:** Install Sequential Thinking MCP system-wide

---

## 📋 Executive Summary

Analysis of Model Context Protocol (MCP) servers and n8n workflow automation for personal productivity and development workflow enhancement.

**Key Findings:**
1. **MCP servers should be minimal** - Claude Code has built-in Read/Write/Edit, many CLI tools cover needs
2. **n8n is EXCELLENT for Google Workspace personal assistant** - Email triage, meeting notes, daily briefings
3. **Sequential Thinking MCP is highest-value addition** - Improves AI reasoning quality

**Recommended Setup:**
- ✅ System-level: Sequential Thinking MCP (reasoning enhancement)
- ✅ Project-level: Playwright MCP (web projects only)
- ✅ Project-level: Google Drive MCP (when needed for automations)
- ❌ Skip: Filesystem MCP (redundant with Claude Code), GitHub MCP (have gh CLI)

---

## 🔍 MCP Ecosystem Research

### Most Popular MCP Servers (2025 Data from Smithery.ai)

1. **Sequential Thinking** (5,550+ uses) - `@modelcontextprotocol/server-sequential-thinking`
   - Complex problem decomposition
   - Step-by-step reasoning for AI
   - Reduces hallucinations
   - **RECOMMENDATION: INSTALL SYSTEM-WIDE**

2. **wcgw** (4,920+ uses) - Shell automation with guardrails

3. **GitHub MCP** - `@modelcontextprotocol/server-github`
   - Natural language GitHub operations
   - **RECOMMENDATION: SKIP - redundant with `gh` CLI**

4. **Filesystem MCP** - `@modelcontextprotocol/server-filesystem`
   - File operations with access controls
   - **RECOMMENDATION: SKIP - redundant with Claude Code Read/Write/Edit**

5. **Playwright MCP** - `@playwright/mcp`
   - Browser automation, E2E testing
   - **RECOMMENDATION: INSTALL PER-PROJECT (web projects only)**

6. **Postgres/DB MCP** - Database query and analysis
   - **RECOMMENDATION: OPTIONAL per-project (data-heavy projects)**

---

## 🛠️ Current System Analysis

### Existing CLI Tools (From nixos-config/modules/core/packages.nix)

**GitHub Operations:**
- `gh` (GitHub CLI) - Full GitHub operations
- `git` + `delta` - Version control with better diffs
- **Verdict:** GitHub MCP is redundant

**File Operations:**
- Claude Code built-in: `Read`, `Write`, `Edit`, `Glob`, `Grep`
- Modern CLI: `fd`, `rg`, `bat`, `eza`
- **Verdict:** Filesystem MCP is redundant

**Database Tools:**
- `pgcli`, `mycli`, `usql` - Database CLIs with smart completion
- **Verdict:** Database MCP optional, only for complex AI-driven queries

**Development:**
- `aider` - AI pair programming
- `serena` - Semantic code analysis MCP (ALREADY INSTALLED)
- `mcp-nixos` - NixOS package/option info (ALREADY INSTALLED)
- `devenv` + `direnv` - Auto project environments

**AI/Automation:**
- `atuin` - Neural shell history
- `fish` with smart commands (cat→glow, ls→eza)
- `zoxide` - Smart directory jumping

---

## 🎯 Redundancy Analysis: What NOT to Install

### ❌ Filesystem MCP Server - REDUNDANT

**Why skip:**
- Claude Code has built-in Read/Write/Edit/Glob/Grep tools
- These work WITHOUT filesystem MCP server
- Permissions managed via `.claude/settings.local.json`
- Adding filesystem MCP creates confusion about which system handles files

**What you already have:**
```python
# claude-nixos-automation already handles this
Read("path/to/file")           # Built-in tool
Write("path", content)         # Built-in tool
Edit("path", old, new)         # Built-in tool
Glob("**/*.py")                # Built-in tool
```

### ❌ GitHub MCP Server - REDUNDANT (for now)

**Why skip:**
- You have `gh` CLI installed
- Claude Code can run: `Bash(gh pr create)`, `Bash(gh issue list)`
- GitHub MCP adds natural language abstraction, but gh CLI is more direct

**When to reconsider:**
- If you want AI to autonomously browse GitHub without explicit commands
- For multi-step GitHub workflows: "Find all issues assigned to me, summarize, create report"

**What you already have:**
```bash
gh pr create --title "..." --body "..."
gh issue list --assignee @me
gh pr review 123 --approve
```

---

## ✅ Recommended MCP Configuration

### System-Level MCP Servers (Global)

**Location:** `~/.claude.json` or system config

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "type": "stdio",
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sequential-thinking"]
    },
    "mcp-nixos": {
      "type": "stdio",
      "command": "mcp-nixos"
    },
    "serena": {
      "type": "stdio",
      "command": "serena"
    }
  }
}
```

**Rationale:**
- **Sequential Thinking**: Improves all AI reasoning, no overlap with existing tools
- **mcp-nixos**: Already installed, NixOS-specific (no CLI equivalent)
- **serena**: Already installed, semantic code analysis (no CLI equivalent)

### Project-Level MCP Servers (Per-Project)

**Location:** `<project>/.claude/mcp.json`

**For web projects with E2E tests:**
```json
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

**For projects needing Google Drive automation:**
```json
{
  "mcpServers": {
    "google-drive": {
      "type": "stdio",
      "command": "npx",
      "args": ["@modelcontextprotocol/server-google-drive"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/path/to/credentials.json"
      }
    }
  }
}
```

**For data-heavy backend projects (optional):**
```json
{
  "mcpServers": {
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_URL": "postgresql://localhost:5432/mydb"
      }
    }
  }
}
```

---

## 🚀 n8n Personal Assistant Architecture

### Use Case: Google Workspace Automation

**Primary Goal:** Personal productivity automation with Google Workspace integration

**Key Capabilities:**
- Email triage and AI categorization
- Meeting documentation and follow-ups
- Daily briefing generation
- Contact management and enrichment
- Document organization in Google Drive

### n8n Native MCP Integration (v1.88+)

n8n has **TWO MCP modes**:

1. **MCP Server Trigger Node** - n8n acts as MCP server
   ```
   Claude Code → MCP → n8n workflow → execute automation
   ```

2. **MCP Client Tool Node** - n8n consumes other MCP servers
   ```
   n8n workflow → MCP Client → Sequential Thinking → analyze
   ```

### High-Value Personal Assistant Workflows

#### 1. Email Triage Assistant (HIGH VALUE)

**Time saved:** 30 min/day = 15 hours/month

```yaml
Trigger: New Gmail (every 5 minutes)
↓
AI (GPT-4): Categorize email
  - Partnership inquiry
  - Customer support
  - Newsletter (low priority)
  - Urgent action required
↓
Apply Gmail labels automatically
↓
For urgent emails:
  - Add to Google Calendar as task
  - Send Slack/Telegram notification
  - Draft reply with AI
```

#### 2. Meeting Follow-Up Assistant (HIGH VALUE)

**Time saved:** 20 min per meeting × 10 meetings/month = 3.3 hours/month

```yaml
Trigger: Google Calendar event ends
↓
Check: Was meeting recorded? (Zoom/Meet)
↓
If yes:
  - Fetch transcript
  - AI: Extract action items
  - Create tasks in Google Sheets
  - Email summary to attendees
  - Add follow-up reminders to Calendar
```

#### 3. Daily Briefing Generator (MEDIUM VALUE)

**Time saved:** 10 min/day = 5 hours/month

```yaml
Trigger: Every morning 7am
↓
Fetch from Gmail: Yesterday's important emails
Fetch from Calendar: Today's meetings
Fetch from Drive: Recently edited docs
↓
AI (GPT-4): Generate briefing:
  - Top 3 priorities today
  - Meeting prep notes
  - Pending follow-ups
↓
Send via: Slack DM / Email / Telegram
```

#### 4. Contact Enrichment (MEDIUM VALUE)

**Time saved:** 30 min/month + better networking

```yaml
Trigger: New contact in Google Contacts
↓
AI: Enrich contact data
  - Lookup company (Clearbit/LinkedIn)
  - Add industry, role, company size
  - Update custom fields
↓
Add to CRM (if business contact)
Add to Google Sheets (personal network tracker)
```

#### 5. Document Organization (MEDIUM VALUE)

**Time saved:** 1 hour/month

```yaml
Trigger: New file in Google Drive
↓
AI: Analyze document
  - Extract metadata (date, type, topic)
  - Suggest folder location
  - Generate filename (standardized)
↓
Move to appropriate folder
Update index in Google Sheets
```

### n8n vs Alternatives

| Feature | n8n (Self-Hosted) | Zapier | Make.com |
|---------|-------------------|--------|----------|
| **Monthly Cost** | $0 (+ $5-20 AI API) | $30-100 | $20-60 |
| **Setup Time** | 2-4 hours | 30 min | 1 hour |
| **AI Capabilities** | ✅✅✅ Excellent | ⚠️ Limited | ⚠️ Good |
| **Privacy** | ✅ Local | ❌ Cloud | ❌ Cloud |
| **Google Workspace** | ✅ Full | ✅ Full | ✅ Full |
| **Self-hosting** | ✅ Yes | ❌ No | ❌ No |
| **Open Source** | ✅ Yes | ❌ No | ❌ No |
| **Customization** | ✅✅✅ Full | ⚠️ Limited | ⚠️ Good |

**Verdict:** n8n is ideal for technical users who value privacy and want AI-native automation

---

## 💰 Cost Analysis

### n8n Self-Hosted (Recommended)

**Infrastructure:**
- Existing NixOS machine: $0
- n8n RAM usage: ~200MB
- OR Hetzner VPS CX11: €4.15/month

**Operating Costs:**
```
n8n software: $0 (open source, self-hosted)
OpenAI API (for AI features): $5-20/month
  - Email categorization: ~$0.01 per 100 emails
  - Daily briefings: ~$0.05/day = $1.50/month
  - Meeting summaries: ~$0.10 per meeting

Total: $5-20/month
```

**ROI:**
- Time saved: 20-30 hours/month
- Value at $50/hour: $1,000-1,500/month
- Cost: $5-20/month
- **ROI: 50-300x**

### Alternative: Zapier

**Cost:** $30-100/month
**Same time saved:** 20-30 hours/month
**ROI:** 10-50x (still good, but worse than n8n)

---

## 🚨 Important Considerations

### 1. Setup Time Investment

**Initial setup:** 2-4 hours
- Install n8n on NixOS
- Configure Google OAuth
- Import/build 3-5 core workflows
- Test and iterate

**Maintenance:** ~1 hour/month
- Update workflows
- Fix broken integrations
- Monitor execution logs

**Break-even point:** 6 months of usage

### 2. The "Automation Trap"

**Common mistake:** Spend 10 hours automating a 5-minute weekly task

**How to avoid:**
- ✅ Start with highest-value tasks (email triage, meeting notes)
- ✅ Use existing templates (don't build from scratch)
- ❌ Don't automate one-off tasks
- ❌ Don't over-engineer workflows

**Rule of thumb:** Only automate if task happens 10+ times/month

### 3. AI API Costs Management

**Set limits:**
- OpenAI API spending limit: $20/month
- Use GPT-3.5-turbo for simple tasks
- Use GPT-4 only for complex reasoning
- Cache AI responses when possible

**Cost per operation:**
- Email categorization: $0.0001 per email
- Daily briefing: $0.05 per day
- Meeting summary: $0.10 per summary

### 4. Google API Rate Limits

**Gmail API limits:**
- 250 quota units/user/second
- 1 billion quota units/day
- Translation: ~25,000 emails/day (won't hit this)

**Solution:** n8n has built-in rate limiting

---

## 🎯 Decision Matrix: When to Install What

### Install Sequential Thinking MCP (System-Wide) IF:

✅ You want better AI reasoning quality
✅ You work on complex problems requiring step-by-step analysis
✅ You want AI to show its thought process
✅ Zero cost, pure reasoning enhancement

**Status:** ✅ **RECOMMENDED - INSTALL NOW**

### Install n8n (System Service) IF:

✅ You receive 50+ emails/day
✅ You have 5+ meetings/week
✅ You want daily AI-generated briefings
✅ You value privacy (don't want Zapier seeing your emails)
✅ You're OK spending 2-4 hours initial setup
✅ You'll commit to using it for 6+ months

**Status:** ⏸️ **DEFER - Evaluate need after 1 month**

### Install Playwright MCP (Per-Project) IF:

✅ Project has web UI with E2E tests
✅ Need browser automation for testing/scraping
✅ Want AI to generate/run E2E tests
✅ Project uses devenv with Playwright

**Status:** 📋 **DOCUMENT SETUP - Install when needed**

### Install Google Drive MCP (Per-Project) IF:

✅ Need Google Drive integration in specific project
✅ Building automation that reads/writes Drive files
✅ Part of n8n workflow requiring Drive access

**Status:** 📋 **DOCUMENT SETUP - Install when needed**

### SKIP Filesystem MCP:

❌ Redundant with Claude Code Read/Write/Edit
❌ Would create permission system confusion

### SKIP GitHub MCP (for now):

❌ Redundant with `gh` CLI
⏸️ Reconsider if you want autonomous AI GitHub browsing

---

## 📋 Implementation Checklist

### Phase 1: Install Sequential Thinking MCP (NOW)

- [ ] Add to system-level MCP configuration
- [ ] Test with Claude Code: "Break down this complex task step-by-step"
- [ ] Verify reasoning quality improvement

### Phase 2: Document Project-Level MCP Setup (NOW)

- [ ] Create Playwright MCP setup guide
- [ ] Create Google Drive MCP setup guide
- [ ] Document when to use each

### Phase 3: Evaluate n8n (AFTER 1 MONTH)

- [ ] Track time spent on email triage manually
- [ ] Count meetings needing notes
- [ ] Evaluate if n8n ROI makes sense
- [ ] If yes → proceed with n8n installation

---

## 🔗 Reference Links

**MCP Documentation:**
- Official MCP Specification: https://modelcontextprotocol.io
- Anthropic MCP Docs: https://docs.anthropic.com/mcp
- MCP Servers Repository: https://github.com/modelcontextprotocol/servers
- Awesome MCP Servers: https://github.com/wong2/awesome-mcp-servers

**n8n Documentation:**
- Official n8n Docs: https://docs.n8n.io
- n8n MCP Integration: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcptrigger/
- n8n Workflow Templates: https://n8n.io/workflows/
- n8n Personal Productivity Templates: https://n8n.io/workflows/categories/personal-productivity/

**Community Resources:**
- Sequential Thinking MCP: https://github.com/smithery-ai/server-sequential-thinking
- Playwright MCP: https://github.com/microsoft/playwright-mcp
- MCP Best Practices: https://steipete.me/posts/2025/mcp-best-practices

---

## 🎬 Next Actions

### Immediate (This Session)

1. ✅ Install Sequential Thinking MCP system-wide
2. ✅ Create Playwright MCP setup documentation
3. ✅ Create Google Drive MCP setup documentation

### Future Sessions

1. **After 1 month:** Evaluate if n8n is worth the setup investment
2. **When working on web projects:** Add Playwright MCP per-project
3. **If building Drive automations:** Add Google Drive MCP per-project

---

*Last updated: 2025-10-07*
*Next review: 2025-11-07 (1 month)*
