# 🧠 BASB + Sunsama Implementation Guide
*Complete documentation for Jacopo's Building a Second Brain system*

**Created:** 2025-09-27
**Status:** Phase 1 In Progress
**Integration:** NixOS + Google Workspace + Sunsama + Readwise Reader

---

## 📋 EXECUTIVE SUMMARY

This document outlines the complete implementation of Tiago Forte's Building a Second Brain (BASB) methodology integrated with:
- **Google Workspace** (Drive, Gmail, Keep) for cloud-native workflow
- **Sunsama** for knowledge → action pipeline
- **Readwise Reader** for article processing
- **NixOS** existing stack-management system
- **GNOME Online Accounts** for seamless desktop integration

**Goal:** Transform scattered information across platforms into a unified, actionable knowledge system that enhances decision-making and project execution.

---

## 🎯 UNIFIED TAXONOMY SYSTEM

### **Core Format: `[PARA][Priority]-[Domain]`**

#### **PARA Categories:**
- **P** = Projects (active, deadline-driven initiatives)
- **A** = Areas (ongoing life responsibilities)
- **R** = Resources (future reference materials)
- **X** = Archive (inactive/completed items)

#### **Priority Levels:**
- **1** = Critical/Daily (requires immediate attention)
- **2** = Important/Weekly (regular maintenance)
- **3** = Useful/Monthly (periodic review)

#### **Domain Codes (3-Letter Intuitive System):**
- **FAM** = Family & Personal Life (Famiglia)
- **HLT** = Health & Wellness
- **WRK** = Work & Career (Lavoro)
- **FIN** = Finance & Money (Finanza)
- **TEC** = Technology & Coding
- **RES** = Research & Development
- **BIZ** = Business & Accounting
- **LRN** = Learning & Content Consumption
- **ART** = Art & Music (Creative pursuits, instruments, concerts, art projects)
- **GEN** = General/Administrative

#### **Examples:**
- `P1-TEC` = Critical Technology Project (daily attention)
- `A2-FIN` = Important Financial Area (weekly review)
- `R3-LRN` = Low-priority Learning Resource (monthly scan)
- `X2-WRK` = Archived Work Materials (important but inactive)

---

## 📁 GOOGLE DRIVE STRUCTURE

### **Current → New Folder Mapping:**

```
📋 PROJECTS (Active with deadlines):
040_Progetti_R&D → P1-RES_Research-Projects/
050_CodingAgentsSystem → P1-TEC_AI-Agents-System/
AI x Accounting → P2-BIZ_AI-Accounting/
Contestazione Avis → P3-GEN_Avis-Issue/

🏠 AREAS (Ongoing responsibilities):
01_Famiglia → A1-FAM_Family-Life/
02_Health → A1-HLT_Health-Wellness/
010_Finanza_Personale → A1-FIN_Personal-Finance/
020_Lavoro → A1-WRK_Work-Career/
Avis → A3-GEN_Avis-Volunteer/

📚 RESOURCES (Future reference):
03_Content_to_be_consumed → R2-LRN_Learning-Pipeline/
Colab Notebooks → R2-TEC_Code-Notebooks/
Google AI Studio → R2-TEC_AI-Tools/
Health Simulation → R2-HLT_Health-Research/
Meet Recordings → R3-WRK_Meeting-Archive/

📦 ARCHIVE (Inactive/completed):
backup-11092024 → X3-GEN_System-Backups/
Chromebook Wallpaper → X3-GEN_Old-Wallpapers/
Estratti Conto BP → X2-FIN_Bank-Statements/

📥 INBOX (Processing):
100_Inbox-last-updated-01112023 → 05_INBOX/
```

### **Target Google Drive Structure:**

```
My Drive/
├── 00_BASB-SYSTEM/
│   ├── Master-Dashboard.gdoc          # Weekly system overview
│   ├── Twelve-Favorite-Problems.gdoc  # Personal filtering criteria
│   ├── Weekly-Review-Template.gdoc    # Recurring workflow
│   └── Quick-Reference-Guide.gdoc     # Taxonomy cheat sheet
│
├── 01_PROJECTS/
│   ├── P1-RES_Research-Projects/     # Critical R&D initiatives
│   ├── P1-TEC_AI-Agents-System/      # AI coding project
│   ├── P2-BIZ_AI-Accounting/         # AI business integration
│   └── P3-GEN_Avis-Issue/            # Administrative projects
│
├── 02_AREAS/
│   ├── A1-FAM_Family-Life/           # Family systems & relationships
│   ├── A1-HLT_Health-Wellness/       # Health optimization
│   ├── A1-FIN_Personal-Finance/      # Money management
│   ├── A1-WRK_Work-Career/           # Professional development
│   └── A3-GEN_Avis-Volunteer/        # Community involvement
│
├── 03_RESOURCES/
│   ├── R2-LRN_Learning-Pipeline/     # Content to be consumed
│   ├── R2-TEC_Code-Notebooks/        # Technical references
│   ├── R2-TEC_AI-Tools/              # AI platform resources
│   ├── R2-HLT_Health-Research/       # Health knowledge base
│   └── R3-WRK_Meeting-Archive/       # Historical records
│
├── 04_ARCHIVE/
│   ├── X2-FIN_Bank-Statements/       # Important financial records
│   ├── X3-GEN_System-Backups/        # Technical archives
│   └── X3-GEN_Old-Assets/            # Low-value historical items
│
└── 05_INBOX/                         # Daily processing folder
```

---

## 📧 GMAIL LABEL SYSTEM

### **Current Labels → New BASB Labels:**

```
🔴 CRITICAL (Priority 1 - Daily attention):
A-Core Job → P1-WRK_Core-Work-Projects
BP, Salary & Co. → A1-FIN_Banking-Finance
E-Health (Physi... → A1-HLT_Health-Medical
Coding,Data,PM → A1-TEC_Tech-Development

🟡 IMPORTANT (Priority 2 - Weekly attention):
B-All Job-Produ... → A2-WRK_Career-Development
Investments → A2-FIN_Investment-Portfolio
C-Slanciamoci → P2-WRK_Business-Project

🟢 USEFUL (Priority 3 - Monthly attention):
D-Arte,Musica → A3-ART_Arts-Culture

📥 PROCESSING LABELS (New):
00_INBOX (auto-applied to new emails)
01_ACTION-REQUIRED (needs response today)
02_WAITING-FOR (pending others)
03_REFERENCE (filed for future lookup)
```

---

## 📱 GOOGLE KEEP TAG SYSTEM

### **Mobile-Optimized Tag Hierarchy:**

```
🏷️ PARA + DOMAIN (Primary classification):
#p1-res #p1-tec #p1-biz #p1-wrk     (Critical projects)
#a1-fam #a1-hlt #a1-fin #a1-wrk     (Critical areas)
#a2-wrk #a2-fin #r2-lrn #r2-tec     (Important items)
#a3-art #r3-gen #x3-gen             (Low priority/archive)

⚡ ACTION LEVEL (Sunsama integration):
#now     (today's tasks - immediate Sunsama input)
#soon    (this week's planning)
#maybe   (someday/maybe list)
#ref     (reference only - no action needed)

🎯 TWELVE FAVORITE PROBLEMS:
#tfp1 #tfp2 #tfp3 #tfp4 #tfp5 #tfp6 #tfp7 #tfp8 (8 defined, 4 to be added)

📋 PROCESSING STATUS:
#inbox   (needs processing during daily routine)
#draft   (work in progress)
#done    (completed/filed appropriately)

EXAMPLE USAGE:
"Voice memo about AI automation for accounting project"
Tags: #p2-biz #tfp7 #soon #draft
```

---

## 📖 READWISE READER TAG SYSTEM

### **Article Processing Tags:**

```
🏷️ PARA ALIGNMENT:
project-ai-agents (maps to P1-TEC)
project-accounting (maps to P2-BIZ)
area-health (maps to A1-HLT)
area-finance (maps to A1-FIN)
area-art (maps to A3-ART)
resource-tech (maps to R2-TEC)
resource-learning (maps to R2-LRN)

🧠 PROGRESSIVE SUMMARIZATION STATUS:
layer1-captured      # Initial save with key excerpts
layer2-bolded       # Main points identified and bolded
layer3-highlighted  # Key insights highlighted in yellow
layer4-summary      # Executive summary created
ready-for-action    # Actionable insights identified

🎯 TWELVE FAVORITE PROBLEMS:
tfp1-ai-amplification
tfp2-health-optimization
tfp3-financial-systems
tfp4-family-work-balance
tfp5-learning-to-action
tfp6-system-maintainability
tfp7-ai-business-integration
tfp8-smart-automation
tfp9-community-contribution
tfp10-information-organization
tfp11-tech-without-addiction
tfp12-knowledge-sharing

⚡ ACTIONABILITY LEVEL:
actionable-now      # Immediate application possible
actionable-soon     # Within next 2 weeks
inspiration-only    # Motivational/aspirational
reference-material  # Future lookup value

EXAMPLE TAGGING:
Article: "Building a Second Brain methodology"
Tags: #resource-learning #tfp10-information-organization #layer3-highlighted #actionable-soon
```

---

## 🎯 TWELVE FAVORITE PROBLEMS

*Personal filtering criteria based on current interests and challenges*

1. **How can I build AI systems that amplify human creativity?**
   - Primary domains: TEC, RES, BIZ
   - Tag: #tfp1

2. **How can I optimize my physical, mental and spiritual health systematically?**
   - Primary domains: HLT, TEC
   - Tag: #tfp2

3. **How can I create stress-free and improve financial systems: taxes, savings & investments?**
   - Primary domains: FIN, TEC
   - Tag: #tfp3

4. **How can I improve my professional growth?**
   - Primary domains: WRK, FAM
   - Tag: #tfp4

5. **How can I turn learning into action faster?**
   - Primary domains: LRN, all domains
   - Tag: #tfp5

6. **How can I live more sustainably?**
   - Primary domains: HLT, FAM, FIN
   - Tag: #tfp6

7. **How can I organize information for easy retrieval?**
   - Primary domains: All domains (BASB system itself)
   - Tag: #tfp7

8. **How can I improve my artistic - music, sculpture, dance skills?**
   - Primary domains: ART, LRN
   - Tag: #tfp8

*Note: TFP 9-12 to be defined as interests and challenges evolve*

---

## 🔄 PROGRESSIVE SUMMARIZATION METHODOLOGY

### **Four-Layer System (Tiago Forte's approach):**

**Layer 1: Capture**
- Save interesting excerpts (max 10% of original source)
- Include source info (URL, title, author, date)
- Tag with PARA category and TFP relevance
- Apply initial action level (#now, #soon, #maybe, #ref)

**Layer 2: Bold Main Points**
- During weekly review, bold key insights
- Focus on passages that made you think/feel something
- Don't overthink - use intuition for what stands out
- Add comments explaining why it resonated

**Layer 3: Highlight Key Insights**
- For valuable sources that you revisit
- Highlight (yellow) the best of the bolded passages
- Usually 1-2 sentences that capture core message
- These should jump out when scanning the note

**Layer 4: Executive Summary**
- For truly exceptional sources you reference repeatedly
- Write 3-5 bullet points in your own words
- Include immediate applications and connections
- Generate specific action items for Sunsama

### **Progressive Summarization Workflow:**

```
📖 Article/Book → Layer 1 (Capture) → Google Drive/Readwise
      ↓ (Weekly review)
Layer 2 (Bold) → Identify main points → Update with comments
      ↓ (When revisiting)
Layer 3 (Highlight) → Extract key insights → Note connections
      ↓ (For exceptional sources)
Layer 4 (Summary) → Create action items → Feed to Sunsama
```

---

## 🎯 SUNSAMA INTEGRATION STRATEGY

### **Knowledge → Action Pipeline:**

**Project Alignment:**
```
BASB Projects ↔ Sunsama Projects:
P1-RES_Research-Projects ↔ "Research & Development"
P1-TEC_AI-Agents-System ↔ "AI Agents System"
P2-BIZ_AI-Accounting ↔ "AI Accounting Integration"
A1-HLT_Health-Wellness ↔ "Health Optimization"
A1-WRK_Work-Career ↔ "Professional Development"
```

**Task Generation from Knowledge:**
```
Layer 4 BASB Summary → Specific Sunsama Tasks:

Example:
Article: "Cognitive Load Theory in System Design"
Layer 4 Summary: "Working memory limited to 7±2 items"
Sunsama Tasks:
□ Audit current AI project for cognitive overload (15 min)
□ Redesign interface to reduce mental burden (1 hour)
□ Test simplified workflow with team (30 min)
```

**Daily Integration Workflow:**
- Morning: Review BASB insights → Generate Sunsama tasks
- Planning: Reference Google Drive project folders during Sunsama daily planning
- Evening: Capture execution insights → Feed back to BASB system

---

## 📋 IMPLEMENTATION PHASES

### **PHASE 1: Foundation Setup (Week 1) ✅ IN PROGRESS**

**Objectives:**
- Establish core BASB folder structure
- Create unified tagging system across platforms
- Define personal Twelve Favorite Problems
- Set up basic capture workflows

**Completed:**
- [x] Designed unified taxonomy system (PARA + Priority + Domain)
- [x] Mapped current folders to new BASB structure
- [x] Created Gmail label migration plan
- [x] Defined Google Keep mobile tag system
- [x] Defined Readwise Reader tag strategy
- [x] Created personal TFP list

**Current Tasks:**
- [ ] Create BASB folder structure in Google Drive
- [ ] Update Gmail labels with new system
- [ ] Set up Google Keep tags for mobile capture
- [ ] Create system dashboard and reference documents

**Success Criteria:**
- All main BASB folders created and accessible
- Can tag new emails and Keep notes with BASB system
- TFP list created and understood
- System dashboard functional for weekly reviews

### **PHASE 2: Integration & Migration (Week 2)**

**Objectives:**
- Process existing messy files using decision matrix
- Set up Readwise tagging system
- Connect Sunsama projects to BASB folders
- Establish daily capture routines

**Planned Tasks:**
- [ ] Process loose files using 3-question decision matrix
- [ ] Set up Readwise Reader with BASB tags
- [ ] Align Sunsama projects with BASB project folders
- [ ] Create morning/evening routine templates
- [ ] Migrate high-value content from old folders

**Success Criteria:**
- 80% of loose files properly categorized
- Readwise articles tagged with BASB system
- Sunsama projects mirror BASB project structure
- Daily routines established and tested

### **PHASE 3: Optimization & Automation (Week 3)**

**Objectives:**
- Refine taxonomy based on usage patterns
- Automate what's possible (filters, rules, shortcuts)
- Optimize cross-platform workflows
- Build maintenance habits

**Planned Tasks:**
- [ ] Analyze taxonomy effectiveness and adjust
- [ ] Set up Gmail filters for auto-labeling
- [ ] Create desktop shortcuts for quick access
- [ ] Optimize mobile → desktop workflow
- [ ] Establish weekly review routine

**Success Criteria:**
- System feels natural and efficient to use
- Automation reduces manual categorization work
- Weekly review routine established
- Mobile capture → desktop processing seamless

### **PHASE 4: Advanced Features (Week 4)**

**Objectives:**
- Implement advanced progressive summarization
- Optimize knowledge → action conversion
- Integrate with existing stack-management system
- Build long-term maintenance systems

**Planned Tasks:**
- [ ] Master progressive summarization workflow
- [ ] Optimize BASB → Sunsama task generation
- [ ] Integrate with nixos-config stack-management
- [ ] Create monthly and quarterly review processes
- [ ] Set up system health monitoring

**Success Criteria:**
- Regularly creating Layer 3/4 summaries
- High conversion rate from knowledge to action
- Integration with existing NixOS workflow
- System maintains itself with minimal overhead

---

## 🗂️ CLEANUP STRATEGY FOR EXISTING FILES

### **3-Question Decision Matrix:**

**For each loose file, ask:**

1. **When did I last use this?**
   - Last 3 months → Keep in active PARA category
   - 3-12 months ago → Archive with appropriate priority
   - 1+ years ago → Consider deleting

2. **Will I need this for current projects?**
   - Yes, actively → Projects (P1/P2)
   - Maybe someday → Resources (R2/R3)
   - No → Archive (X3) or delete

3. **What's the cost of losing it?**
   - High (legal, financial, irreplaceable) → Keep in A1/A2
   - Medium (useful reference) → Resources R2/R3
   - Low (easily replaceable) → Delete or X3

### **File Processing Examples:**

```
✅ Colab Notebooks → R2T_Code-Notebooks/
   (Medium cost, useful reference, tech domain)

✅ Health Simulation → R2H_Health-Research/
   (Medium cost, health domain, research value)

✅ Meet Recordings → R3W_Meeting-Archive/
   (Low frequency, work domain, archive value)

🗑️ Chromebook Wallpaper → DELETE
   (Low cost, easily replaceable, no business value)

📦 backup-11092024 → X3G_System-Backups/
   (Keep for safety, but archive low priority)

⚠️ Estratti Conto BP → A2M_Bank-Records/
   (High cost financial docs, important area)
```

---

## 🔄 DAILY WORKFLOWS

### **Morning Routine (15 minutes, 8:30 AM):**

**Phase 1: Mobile Capture Processing (5 min)**
1. Open Google Keep → Filter by #inbox
2. Re-tag with BASB codes (#p1w, #a2h, etc.)
3. Add action level (#now, #soon, #maybe)
4. Connect to TFP when relevant (#tfp3, #tfp7, etc.)

**Phase 2: Email Triage (5 min)**
1. Gmail inbox → Apply BASB labels
2. Tag urgency: 01_ACTION-REQUIRED, 03_REFERENCE
3. Clear processed emails from inbox

**Phase 3: Knowledge → Action (5 min)**
1. Check Google Drive project folders for updates
2. Review any Layer 3/4 summaries for action items
3. Generate specific Sunsama tasks from insights
4. Open Sunsama for daily planning with knowledge context

### **Evening Routine (10 minutes, 6:00 PM):**

**Phase 1: Execution Reflection (4 min)**
1. Sunsama daily reflection
2. Note which knowledge-informed tasks were effective
3. Update project progress in Google Drive

**Phase 2: Learning Capture (4 min)**
1. Quick insight capture in Google Keep
2. Tag with BASB codes + #draft
3. Note connections to TFPs and current projects

**Phase 3: Pipeline Maintenance (2 min)**
1. Queue tomorrow's progressive summarization work
2. Flag urgent processing for morning routine
3. Clear completed items from active lists

### **Weekly Review (45 minutes, Sunday 10:00 AM):**

**System Health (15 min)**
1. Review BASB Dashboard metrics
2. Process progressive summarization pipeline
3. Clean up folder organization
4. Archive completed items

**Cross-Platform Alignment (15 min)**
1. Verify BASB taxonomy consistency
2. Update project status across all systems
3. Generate next week's knowledge priorities

**Strategic Planning (15 min)**
1. Review TFP alignment with weekly captures
2. Plan knowledge → action priorities
3. Update Sunsama with knowledge-informed goals
4. Schedule any needed deep work sessions

---

## 💻 TECHNICAL IMPLEMENTATION

### **NixOS Integration:**

**Required Packages:**
```nix
environment.systemPackages = with pkgs; [
  # BASB core tools
  firefox              # Primary browser for Google Workspace
  gnome.gedit          # Quick text editing
  libreoffice         # Alternative to Google Docs

  # Enhanced productivity
  obsidian            # Local backup for critical notes
  rclone              # Alternative sync option if needed
];

# GNOME Online Accounts integration
services.gnome.gnome-online-accounts.enable = true;
services.gvfs.enable = true;
```

**Desktop Shortcuts Setup:**
```bash
# Create BASB quick access
mkdir -p ~/Desktop/BASB-Shortcuts

# Create .desktop files for instant access to key folders
# (Implementation in Phase 2)
```

### **Automation Opportunities:**

**Gmail Filters (Phase 3):**
- Auto-label known senders with appropriate BASB categories
- Auto-apply 00_INBOX to all new mail
- Priority classification based on keywords

**Google Keep → Drive Automation:**
- Weekly script to export #done Keep notes to appropriate Drive folders
- Cleanup completed mobile captures

**Cross-Platform Sync:**
- Monitor Google Drive folder health
- Alert when inbox gets too full
- Generate weekly metrics for dashboard

---

## 📊 SUCCESS METRICS

### **System Health Indicators:**

**Weekly Metrics:**
- Items captured across all platforms
- Layer 2-4 progressive summarization completed
- Knowledge → action conversion rate
- TFP coverage (how many problems addressed)
- Inbox processing time
- System maintenance overhead

**Monthly Metrics:**
- Folder organization health score
- Cross-platform consistency score
- Project velocity improvement
- Learning → application success rate
- Time saved through better organization

**Quarterly Metrics:**
- TFP evolution and refinement
- System adaptation to changing needs
- Knowledge sharing and output creation
- Integration with other life systems

### **Quality Indicators:**

- **Findability:** Can locate any captured insight within 2 minutes
- **Actionability:** 70%+ of captured knowledge leads to concrete actions
- **Sustainability:** System maintenance takes <30 min/week
- **Growth:** Regularly creating new connections between ideas
- **Output:** Increased creation of valuable content/decisions

---

## 🔧 TROUBLESHOOTING & MAINTENANCE

### **Common Issues & Solutions:**

**Problem:** GNOME Online Accounts not showing folder names in CLI
**Solution:** Use GUI-based workflows; consider rclone for automation needs

**Problem:** Overwhelming capture volume
**Solution:** Be more selective; strengthen TFP filtering; increase processing frequency

**Problem:** Cross-platform tag inconsistency
**Solution:** Weekly audit using Quick Reference Guide; maintain tag hygiene

**Problem:** Sunsama task overload from BASB insights
**Solution:** Strengthen Layer 3/4 criteria; focus on immediate actionability

### **Regular Maintenance Tasks:**

**Daily (5 min):** Process mobile captures, update active projects
**Weekly (30 min):** Progressive summarization, system health check
**Monthly (60 min):** Folder cleanup, automation review, metrics update
**Quarterly (120 min):** TFP evolution, system optimization, strategic planning

---

## 📚 REFERENCES & RESOURCES

### **Core Methodology:**
- **Building a Second Brain** by Tiago Forte
- **Getting Things Done** by David Allen
- **CODE Method:** Capture, Organize, Distill, Express
- **PARA Method:** Projects, Areas, Resources, Archive

### **Technical Integration:**
- **GNOME Online Accounts** documentation
- **Sunsama** planning methodology
- **Readwise Reader** highlighting system
- **Google Workspace** productivity features

### **System Evolution:**
- Review and update this documentation monthly
- Track system effectiveness and adapt as needed
- Share learnings with community for feedback
- Maintain compatibility with NixOS stack-management system

---

**Document Version:** 1.0
**Last Updated:** 2025-09-27
**Next Review:** 2025-10-27
**Implementation Status:** Phase 1 In Progress

---

*This documentation serves as the complete reference for implementing and maintaining Jacopo's BASB system. All phases, taxonomies, and workflows are documented to enable seamless continuation regardless of session interruptions.*