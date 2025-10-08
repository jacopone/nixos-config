---
status: active
created: 2025-10-08
updated: 2025-10-08
type: reference
lifecycle: persistent
---

# Discovery Item Template

Copy and paste this template when adding new items to backlog.md:

```markdown
#### $(date +%Y-%m-%d) - SERVICE/TOOL NAME
- **Source**: [HN/Reddit/Twitter/Blog] - [specific thread/post]
- **URL**: https://...
- **Quick Notes**: One-line description or key selling point
- **Priority**: [High/Medium/Low]
- **Why Interesting**: Why this caught your attention
- **Initial Cost**: €X/month or Free or Unknown
```

## Priority Guidelines

- **High**: Addresses current pain point, could be game-changer
- **Medium**: Interesting improvement, not urgent
- **Low**: Cool but not needed, educational interest

## Quick Bookmarklet

Add this to your browser bookmarks bar for one-click capture:

```javascript
javascript:(function(){
  const title = document.title;
  const url = window.location.href;
  const date = new Date().toISOString().split('T')[0];
  const template = `#### ${date} - ${title}
- **Source**: [EDIT_SOURCE]
- **URL**: ${url}
- **Quick Notes**: [EDIT_NOTES]
- **Priority**: [EDIT_PRIORITY]
- **Why Interesting**: [EDIT_REASON]
- **Initial Cost**: [EDIT_COST]`;
  
  navigator.clipboard.writeText(template).then(() => {
    alert('Discovery template copied to clipboard!');
  });
})();
```

Name the bookmark: "📋 Capture to Stack Backlog"