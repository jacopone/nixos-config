---
status: archived
created: 2025-10-01
updated: 2025-10-08
type: session-note
lifecycle: ephemeral
---

# Chrome Bookmarks → BASB Integration

**Transform your 1,885 Chrome bookmarks into organized knowledge with BASB.**

## 🎯 Overview

The Chrome Bookmarks integration provides a systematic, interactive workflow to review, organize, and migrate your browser bookmarks into the BASB system via Readwise Reader.

**Key Features:**
- 🔖 Parse and track all Chrome bookmarks across profiles
- 📊 Progress tracking across review sessions
- 🏷️ Auto-tagging based on folder structure
- 💾 Save valuable bookmarks to Readwise with BASB tags
- 🗑️ Delete or keep bookmarks in Chrome
- ⏭️ Strategic prioritization (GTD → recent → by folder)

## 🚀 Quick Start

### 1. Check Your Bookmarks

```bash
rwcstats    # Show statistics and folder breakdown
```

**Example Output:**
```
OVERALL PROGRESS
────────────────────────────────────────────────────────────
Total Bookmarks:     1885
Reviewed:            0
Unreviewed:          1885

Progress: ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0%

TOP UNREVIEWED FOLDERS
────────────────────────────────────────────────────────────
other/Other bookmarks/Other/Bookmarks sparsi 1635/1635 unreviewed
other/Other bookmarks/Other/Data Science  87/ 87 unreviewed
other/Other bookmarks/Other/Programming & Hacking  52/ 52 unreviewed
```

### 2. Start Reviewing

```bash
rwchrome    # Start review (20 bookmarks/session default)
```

**Interactive Workflow:**
1. View bookmark details (title, URL, folder, age)
2. See suggested BASB tags based on folder
3. Choose action:
   - 💾 Save to Readwise with BASB tags
   - 🗑️ Delete from Chrome
   - ✅ Keep in Chrome (mark reviewed)
   - ⏭️ Skip for now
   - 🛑 Stop review session

### 3. Strategic Review

```bash
rwcgtd                    # Review GTD folder first (highest priority)
rwchrome --folder "Data Science"   # Review specific folder
rwchrome --limit 10       # Shorter session (10 bookmarks)
```

## 📊 Workflow Details

### Auto-Tagging by Folder

The system automatically suggests BASB tags based on bookmark folder:

| Folder | BASB Tag | Domain | TFPs | Action |
|--------|----------|--------|------|--------|
| GTD | a1-wrk | WRK | tfp5 | now |
| Programming & Hacking | r2-tec | TEC | tfp5 | ref |
| Data Science | r2-tec | TEC | tfp1 | ref |
| Startups | r2-biz | BIZ | tfp4 | ref |
| Security | r2-tec | TEC | - | ref |
| Philosophy | r3-lrn | LRN | tfp2 | ref |
| Fintech | r2-fin | FIN | tfp3 | ref |

**Unknown folders** get default tags: `r3-lrn`, `layer1-captured`, `actionable-ref`

### Progress Tracking

Reviews are tracked in `~/.local/share/basb/chrome-reviewed.json`:

```json
{
  "reviewed": [
    "bookmark-id-1",
    "bookmark-id-2",
    ...
  ]
}
```

**Progress persists across sessions** - bookmarks you've reviewed won't appear again.

### Review Session Example

```
════════════════════════════════════════════════════════════
Bookmark 1/20
════════════════════════════════════════════════════════════

📄 Implementing Getting Things Done (GTD) in Gmail
🔗 https://www.example.com/gtd-gmail
📁 other/Other bookmarks/Other/GTD
📅 Added 2 years ago

💡 Suggested tags: a1-wrk
   TFPs: tfp5
   Source: auto (from folder: GTD)

? What would you like to do?
  ❯ 💾 Save to Readwise & tag with BASB
    🗑️  Delete (remove from Chrome)
    ✅ Keep in Chrome (mark reviewed)
    ⏭️  Skip for now
    🛑 Stop review session

✓ Saved to Readwise with tags: a1-wrk, tfp5, layer1-captured, actionable-now, source-chrome
```

### Session Summary

At the end of each session:

```
═══════════════════════════════════════════════════════════
✨ Review Session Complete!

📊 SESSION SUMMARY:
  • Saved to Readwise: 12
  • Marked for deletion: 3
  • Kept in Chrome: 4
  • Skipped: 1

✓ Processed 19/20 bookmarks

💡 1866 bookmarks remaining for next session
   Run 'rwchrome' again to continue!
```

## 🎯 Strategic Review Approach

### Recommended Order

1. **GTD Folder First** (highest priority)
   ```bash
   rwcgtd    # Review GTD bookmarks
   ```

2. **TFP-Connected Folders**
   ```bash
   rwchrome --folder "Programming & Hacking"   # TFP5
   rwchrome --folder "Data Science"            # TFP1
   rwchrome --folder "Fintech"                 # TFP3
   ```

3. **Domain-Specific Folders**
   ```bash
   rwchrome --folder "Startups"    # Business domain
   rwchrome --folder "Security"    # Technology domain
   ```

4. **Bulk Cleanup**
   ```bash
   rwchrome --folder "Bookmarks sparsi"   # Review 1635 miscellaneous
   ```

### Time Investment

- **20 bookmarks/session** × 5 min = ~25 min/session
- **1,885 total** ÷ 20 = ~95 sessions
- **1 session/day** = 3 months to complete
- **OR: 2 sessions/day** = 6 weeks to complete

## 🔧 Advanced Usage

### Custom Limits

```bash
rwchrome --limit 50    # Power session (50 bookmarks)
rwchrome --limit 5     # Quick session (5 bookmarks)
```

### Folder-Specific Reviews

```bash
# List all folders first
rwcstats

# Review specific folder
rwchrome --folder "Programming & Hacking"
```

### Stats-Only Mode

```bash
rwcstats    # Just show statistics, no review
```

## 📁 File Structure

```
~/.config/google-chrome/Default/
  └── Bookmarks                              # Chrome's bookmark database (read-only)

~/.local/share/basb/
  └── chrome-reviewed.json                   # Progress tracking

~/nixos-config/basb-system/scripts/readwise_basb/
  ├── chrome.py                              # Chrome bookmarks parser
  └── workflows/chrome_review.py             # Interactive review workflow
```

## 🏷️ Tag Mapping Reference

### PARA Categories Used
- **A1** - Active areas (GTD, work-related)
- **R2** - Active resources (learning, references)
- **R3** - Low-priority resources (philosophy, general learning)

### Domains Used
- **WRK** - Work & Productivity
- **TEC** - Technology & Development
- **BIZ** - Business & Entrepreneurship
- **FIN** - Finance & Economics
- **LRN** - Learning & Education

### TFP Connections
- **tfp1** - Data Science & AI workflows
- **tfp2** - Philosophy & worldview
- **tfp3** - Financial systems & automation
- **tfp4** - Business scaling & automation
- **tfp5** - Development tools & productivity

### Processing Layers
All saved bookmarks start at **layer1-captured**.

### Action Levels
- **actionable-now** - GTD folder (immediate action)
- **actionable-ref** - Most other folders (reference material)

## 🔗 Integration Flow

```
Chrome Bookmarks
    ↓
Review with rwchrome
    ↓
Save to Readwise (with BASB tags)
    ↓
Review in rwdaily
    ↓
Process through Progressive Summarization
    ↓
Export to Google Drive / Add to Sunsama
```

## ❓ FAQ

**Q: Will this delete my Chrome bookmarks?**
A: No. The "Delete" action only marks bookmarks as reviewed - you need to manually delete in Chrome.

**Q: What if I skip a bookmark?**
A: Skipped bookmarks remain unreviewed and will appear in future sessions.

**Q: Can I review the same folder multiple times?**
A: Yes! Use `rwchrome --folder "Folder Name"` as many times as needed.

**Q: What happens if I stop mid-session?**
A: Only bookmarks you completed actions on are marked as reviewed. The rest will appear next time.

**Q: Can I change suggested tags?**
A: Yes! After saving to Readwise, use `rwtag` to re-tag the article with different BASB tags.

**Q: Which Chrome profile is used?**
A: Default profile (jacopo.anselmi@gmail.com). To use a different profile, edit `chrome.py` line 12.

## 🎨 Gum-Powered UX

The workflow uses [Gum](https://github.com/charmbracelet/gum) for:
- ✨ Beautiful progress bars
- 🎨 Color-coded output
- 📋 Interactive menus
- ✅ Confirmation prompts
- 📊 Styled statistics

## 🚀 Next Steps

After completing your Chrome bookmark review:

1. **Daily Review**: Use `rwdaily` to process saved articles
2. **Tag Refinement**: Use `rwtag` to refine BASB tags
3. **Metrics**: Track progress with `rwstats --weekly`
4. **Progressive Summarization**: Move articles through layers 1-4
5. **Export**: Export Layer 3+ summaries to Google Drive

---

**Happy bookmark organizing! 🎉**

*Part of the BASB System - Building a Second Brain with NixOS*
