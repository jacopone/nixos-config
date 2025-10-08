# Google Drive MCP Setup Guide

> For Downloads → Drive sync and document organization automation
> **Last updated:** 2025-10-07

---

## 🎯 Use Case

**Primary Goal:** Sync and organize files from `~/Downloads` to Google Drive with AI-powered categorization.

**Features:**
- Automatic file categorization (invoices, documents, photos, etc.)
- Smart file renaming based on content
- Organize into Drive folder structure
- Search and retrieve documents from Drive
- Sync local folders to cloud

---

## 🏗️ Architecture: Dedicated Project Approach

**Why NOT system-wide:**
- Google Drive contains sensitive personal data
- Unintended access risk in unrelated projects
- Better security with project-scoped access

**Recommended:** Create dedicated `~/automation/drive-organizer` project

---

## 📋 Setup Instructions

### Step 1: Create Google Cloud Project

1. **Go to Google Cloud Console:**
   https://console.cloud.google.com/

2. **Create new project:**
   - Name: "Drive Organizer" (or your choice)
   - Note the Project ID

3. **Enable Google Drive API:**
   - Navigate to "APIs & Services" → "Library"
   - Search for "Google Drive API"
   - Click "Enable"

4. **Create OAuth 2.0 Credentials:**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - Application type: "Desktop app"
   - Name: "Claude Drive Organizer"
   - Click "Create"

5. **Download credentials:**
   - Click download icon next to your OAuth client
   - Save as `credentials.json`

### Step 2: Set Up Project Directory

```bash
# Create automation directory
mkdir -p ~/automation/drive-organizer
cd ~/automation/drive-organizer

# Create .claude directory for MCP config
mkdir -p .claude

# Move credentials (replace with your actual path)
mv ~/Downloads/credentials.json ./credentials.json
chmod 600 credentials.json

# Add to gitignore if you version control this
echo "credentials.json" >> .gitignore
echo "token.json" >> .gitignore  # OAuth token created on first use
```

### Step 3: Configure Google Drive MCP

Create `.claude/mcp.json`:

```json
{
  "mcpServers": {
    "google-drive": {
      "type": "stdio",
      "command": "npx",
      "args": ["@modelcontextprotocol/server-google-drive"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/home/guyfawkes/automation/drive-organizer/credentials.json"
      }
    },
    "sequential-thinking": {
      "type": "stdio",
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

**Note:** Sequential Thinking is also included for better file categorization logic.

### Step 4: First-Time OAuth Authorization

On first use, the MCP server will:
1. Open browser for OAuth consent
2. Ask you to sign in to Google
3. Request Drive permissions
4. Save token to `token.json`

**Important:** Keep `token.json` secure - it provides access to your Drive!

### Step 5: Create Helper Scripts

**`organize-downloads.sh`:**
```bash
#!/usr/bin/env bash
# Quick launcher for Drive organizer
cd ~/automation/drive-organizer
echo "🚀 Opening Claude Code in Drive Organizer mode..."
echo "Google Drive MCP is active in this session."
claude
```

Make it executable:
```bash
chmod +x organize-downloads.sh
```

**`README.md`:**
```markdown
# Drive Organizer - AI-Powered File Management

Organizes ~/Downloads and syncs to Google Drive using AI categorization.

## Quick Start

```bash
# Open Claude Code with Drive access
./organize-downloads.sh
```

## Common Commands

Ask Claude:
- "Show me what's in my Downloads folder"
- "Organize all PDFs from Downloads to Drive"
- "Search Drive for [topic]"
- "Sync ~/Documents/ImportantStuff to Drive/Backup"
- "Find my tax documents from 2024"
- "Clean up old downloads"

## Safety

- Google Drive MCP ONLY active in this project
- Won't accidentally access Drive from other projects
- All operations require your explicit instruction
```

---

## 🎯 Usage Examples

### Example 1: Organize Downloads

```bash
cd ~/automation/drive-organizer
claude
```

Then in Claude Code:
```
You: "Scan my Downloads folder and show what needs organizing"

Claude: [Lists files with AI categorization]
Found 15 files:
- invoice-2025-10.pdf → Finance/Invoices
- meeting-notes.docx → Work/Meeting Notes
- vacation-photo.jpg → Personal/Photos
- course-material.zip → Education/Courses
...

You: "Organize all of them to Drive"

Claude: [Uses Sequential Thinking]
Step 1: Validate categories
Step 2: Create Drive folders if needed
Step 3: Upload with smart names
Step 4: Confirm uploads

[Uploads complete]
✓ 15 files organized in Google Drive
```

### Example 2: Smart Rename and Organize

```
You: "Take all invoices from Downloads, rename them properly, and organize"

Claude: [Analyzes PDF content]
- IMG_2023.pdf → "2025-10-07-Invoice-ElectricCompany-$245.pdf"
- scan.pdf → "2025-10-05-Receipt-Grocery-Walmart-$87.pdf"
- document.pdf → "2025-09-30-Invoice-Internet-Comcast-$79.pdf"

[Uploads to Drive/Finance/Invoices/2025/]
Done! 3 invoices organized.
```

### Example 3: Search and Download

```
You: "Find all my presentations about NixOS"

Claude: [Searches Drive]
Found 3 presentations:
1. Drive/Work/Presentations/NixOS-Intro-2024.pptx
2. Drive/Personal/Tech/NixOS-Setup-Guide.pdf
3. Drive/Work/Talks/NixOS-for-Developers.key

You: "Download the first one to ~/Documents"

Claude: [Downloads from Drive]
✓ Downloaded: ~/Documents/NixOS-Intro-2024.pptx
```

### Example 4: Sync Folder to Drive

```
You: "Backup my ~/Documents/Projects folder to Drive"

Claude: [Uses Sequential Thinking]
Step 1: Scan ~/Documents/Projects (238 files, 1.2GB)
Step 2: Check if Drive/Backup/Projects exists
Step 3: Compare with existing files
Step 4: Upload new/changed files only

Uploading:
- 12 new files
- 3 modified files
- Skipping 223 unchanged files

[Progress: 15/15 files uploaded]
✓ Backup complete: Drive/Backup/Projects
```

---

## 🔒 Security Considerations

### What Google Drive MCP Can Do

✅ **Allowed:**
- Read any file in your Drive
- Create/update/delete files
- Search across all Drive folders
- Share files (if you instruct it to)
- Organize folder structure

⚠️ **Remember:**
- MCP has full Drive access within this project
- Review AI's actions before confirming destructive operations
- Credentials grant access until you revoke them

### Limiting Risk

**1. Project-Level Isolation:**
- Drive MCP ONLY in `~/automation/drive-organizer`
- Other projects can't access Drive
- Mental model: "I'm in Drive organizer = Drive is accessible"

**2. Credential Security:**
```bash
# Secure credential files
chmod 600 credentials.json
chmod 600 token.json

# Never commit to git
echo "credentials.json" >> .gitignore
echo "token.json" >> .gitignore
```

**3. OAuth Token Revocation:**
If compromised or no longer needed:
- Visit: https://myaccount.google.com/permissions
- Find "Drive Organizer" app
- Click "Remove Access"
- Delete `token.json` locally

**4. Audit Trail:**
- All Drive operations logged in: https://drive.google.com/drive/activity
- Review what AI accessed/modified

---

## 🔧 Troubleshooting

### Error: "credentials.json not found"

```bash
# Check file exists
ls -la ~/automation/drive-organizer/credentials.json

# Verify path in .claude/mcp.json matches
cat .claude/mcp.json | grep GOOGLE_APPLICATION_CREDENTIALS
```

### Error: "OAuth consent required"

**First time:** Browser should open automatically for authorization.

**If browser doesn't open:**
1. Check terminal output for URL
2. Copy URL to browser
3. Complete OAuth flow
4. token.json will be created

### Error: "Permission denied"

Check OAuth scopes requested. You need:
- `https://www.googleapis.com/auth/drive` (full Drive access)

Or more restricted:
- `https://www.googleapis.com/auth/drive.file` (files created by app only)
- `https://www.googleapis.com/auth/drive.readonly` (read-only)

### MCP Server Won't Connect

```bash
# Test MCP server manually
cd ~/automation/drive-organizer
npx @modelcontextprotocol/server-google-drive

# Check if credentials are valid
cat credentials.json | jq .
```

### Rate Limiting

Google Drive API limits:
- 10,000 requests per 100 seconds per user
- 1 billion requests per day

**Unlikely to hit** with normal use. If you do:
- Add delays between operations
- Batch operations when possible

---

## 🎬 Getting Started Checklist

- [ ] Create Google Cloud project
- [ ] Enable Drive API
- [ ] Create OAuth credentials
- [ ] Download credentials.json
- [ ] Create ~/automation/drive-organizer directory
- [ ] Configure .claude/mcp.json
- [ ] Create helper scripts
- [ ] Complete first OAuth authorization
- [ ] Test basic operations
- [ ] Review security settings

---

## 📚 Related Documentation

**See also:**
- `MCP_AND_N8N_ARCHITECTURE_ANALYSIS.md` - Overall MCP strategy
- `MCP_SERVER_SETUP_GUIDE.md` - General MCP setup (if created)

**External Resources:**
- Google Drive API: https://developers.google.com/drive
- MCP Google Drive Server: https://github.com/modelcontextprotocol/servers/tree/main/src/google-drive
- OAuth 2.0: https://developers.google.com/identity/protocols/oauth2

---

## 🚀 Next Steps

### Phase 1: Manual Organization (NOW)

Use Claude Code interactively to organize downloads as needed.

### Phase 2: n8n Integration (LATER)

Once you install n8n, create automated workflow:

```yaml
Trigger: File added to ~/Downloads
↓
AI: Categorize file type
↓
Google Drive MCP: Upload to appropriate folder
↓
Optional: Delete from Downloads after 30 days
```

### Phase 3: Scheduled Backups

```yaml
Trigger: Daily at 2am
↓
Scan: ~/Documents, ~/Pictures, ~/Projects
↓
Google Drive MCP: Incremental backup to Drive/Backup
↓
Notification: Backup complete (or failed)
```

---

*Last updated: 2025-10-07*
*Ready to use when you decide to set up Drive integration*
