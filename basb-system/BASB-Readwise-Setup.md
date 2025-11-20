---
status: active
created: 2025-10-08
updated: 2025-10-08
type: guide
lifecycle: persistent
---

# Readwise Reader BASB Integration
**Phase 2: Setting up article processing with BASB taxonomy**

---

## 🎯 OBJECTIVE
Integrate Readwise Reader with your BASB system for seamless article processing and progressive summarization.

---

## 🏷️ READWISE TAGGING SYSTEM

### **PARA Alignment Tags**
Map your BASB categories to readable Readwise tags:

```
📋 PROJECT TAGS:
project-ai-agents         → P1-TEC_AI-Agents-System
project-ai-accounting     → P2-BIZ_AI-Accounting
project-research          → P1-RES_Research-Projects
project-creative          → P2-ART_Creative-Projects

🏠 AREA TAGS:
area-family               → A1-FAM_Family-Life
area-health               → A1-HLT_Health-Wellness
area-work                 → A1-WRK_Work-Career
area-finance              → A1-FIN_Personal-Finance
area-tech                 → A1-TEC_Tech-Development
area-art                  → A2-ART_Creative-Pursuits

📚 RESOURCE TAGS:
resource-learning         → R2-LRN_Learning-Pipeline
resource-tech             → R2-TEC_Code-Notebooks
resource-health           → R2-HLT_Health-Research
resource-business         → R2-BIZ_Business-Research
resource-art              → R3-ART_Creative-Inspiration

📦 ARCHIVE TAGS:
archive-completed         → X2/X3_Completed-Research
```

### **TFP Integration Tags**
Connect articles directly to your 8 Favorite Problems:

```
🎯 TFP TAGS:
tfp1-ai-creativity        → How can I build AI systems that amplify human creativity?
tfp2-holistic-health      → How can I optimize physical, mental & spiritual health?
tfp3-stress-free-finance  → How can I create stress-free financial systems?
tfp4-professional-growth  → How can I improve my professional growth?
tfp5-learning-to-action   → How can I turn learning into action faster?
tfp6-sustainable-living   → How can I live more sustainably?
tfp7-info-organization    → How can I organize information for easy retrieval?
tfp8-artistic-skills      → How can I improve my artistic skills?
```

### **Progressive Summarization Status Tags**
Track your processing progress:

```
📖 PROCESSING STATUS:
layer1-captured           → Initial save with key excerpts
layer2-bolded            → Main points identified and bolded
layer3-highlighted       → Key insights highlighted in yellow
layer4-summary           → Executive summary created
ready-for-action         → Actionable insights identified
needs-review             → Requires re-reading or deeper analysis
```

### **Actionability Level Tags**
Determine next steps for each article:

```
⚡ ACTION LEVEL:
actionable-now           → Can implement immediately
actionable-soon          → Within next 2 weeks
actionable-someday       → Future reference/inspiration
reference-only           → Pure knowledge, no direct action
inspiration-fuel         → Motivational/aspirational content
```

---

## 🔄 READWISE WORKFLOW

### **Article Capture Process:**

**Step 1: Initial Save (Layer 1)**
1. **Save article** to Readwise Reader
2. **Add initial tags:**
   - 1 PARA tag (project/area/resource)
   - 1 TFP tag (if relevant)
   - `layer1-captured`
3. **Quick highlight** of most interesting passages (max 10% of article)
4. **Add source context** in notes (where found, why saved)

**Step 2: First Review (Layer 2)**
1. **Read through highlights**
2. **Bold the key insights** that resonated most
3. **Add comments** explaining why they're important
4. **Update tags:**
   - Add `layer2-bolded`
   - Add actionability level tag
   - Refine PARA/TFP tags if needed

**Step 3: Deep Processing (Layer 3)**
1. **Re-read bolded sections**
2. **Highlight in yellow** the absolute best insights
3. **Note connections** to other articles/projects
4. **Update tags:**
   - Add `layer3-highlighted`
   - Add specific action tags if applicable

**Step 4: Executive Summary (Layer 4)**
1. **Write 3-5 bullet summary** in notes
2. **List specific action items** for Sunsama
3. **Note cross-references** to other knowledge
4. **Update tags:**
   - Add `layer4-summary`
   - Add `ready-for-action` if applicable

---

## 📋 TAGGING EXAMPLES

### **AI/Tech Article Example:**
```
Article: "Building Autonomous AI Agents with Memory"
Tags: #project-ai-agents #tfp1-ai-creativity #layer2-bolded #actionable-soon
Notes: "Directly applicable to current AI agents project. Memory architecture could solve context retention issues."
```

### **Health Article Example:**
```
Article: "Circadian Rhythm Optimization for Mental Performance"
Tags: #area-health #tfp2-holistic-health #layer3-highlighted #actionable-now
Notes: "Specific sleep schedule recommendations. Could implement this week."
```

### **Financial Article Example:**
```
Article: "Tax Optimization Strategies for Tech Professionals"
Tags: #area-finance #tfp3-stress-free-finance #layer1-captured #reference-only
Notes: "Good reference for next tax season. File under financial systems."
```

### **Creative Article Example:**
```
Article: "Practicing Music Theory Through Digital Composition"
Tags: #area-art #tfp8-artistic-skills #layer2-bolded #actionable-someday
Notes: "Interesting approach to music theory. Could combine with digital tools."
```

---

## 🔄 WEEKLY REVIEW INTEGRATION

### **Sunday Review Process (15 minutes):**

**Step 1: Process Backlog (10 min)**
1. **Review all `layer1-captured` articles**
2. **Promote 2-3 to Layer 2** (bold key points)
3. **Delete/archive low-value captures**

**Step 2: Advance Pipeline (5 min)**
1. **Check `layer2-bolded` articles** for Layer 3 candidates
2. **Identify `ready-for-action` items** for Sunsama
3. **Update dashboard** with progress metrics

### **Monthly Deep Review (30 minutes):**
1. **Audit tag consistency** across all articles
2. **Create Layer 4 summaries** for highest-value content
3. **Export summaries** to Google Drive BASB folders
4. **Review TFP coverage** - which problems getting attention?

---

## 🚀 SETUP CHECKLIST

### **Initial Configuration:**
- [ ] **Login to Readwise Reader** (readwise.io/read)
- [ ] **Import existing articles** if you have any
- [ ] **Create tag structure** using the taxonomy above
- [ ] **Test tagging workflow** with 2-3 articles

### **Integration Setup:**
- [ ] **Connect to Google Drive** if available
- [ ] **Set up export workflow** for Layer 4 summaries
- [ ] **Create dashboard tracking** for processing metrics
- [ ] **Schedule weekly review** reminder

### **Test Articles:**
Save and process 3 test articles:
1. **One TFP1 (AI creativity) article** - test tech tagging
2. **One TFP2 (health) article** - test health tagging
3. **One random interesting article** - test general workflow

---

## 📊 SUCCESS METRICS

### **Weekly Targets:**
- **5-10 new articles** captured (Layer 1)
- **2-3 articles** processed to Layer 2
- **1 article** advanced to Layer 3
- **1 Layer 4 summary** created monthly

### **Quality Indicators:**
- **Clear TFP connections** in 70% of saves
- **Actionable insights** generated regularly
- **Cross-references** noted between articles
- **Export to BASB folders** working smoothly

---

## 🔧 TROUBLESHOOTING

### **Common Issues:**
- **Too many saves, not enough processing** → Be more selective in captures
- **Tags getting inconsistent** → Use this reference guide religiously
- **No actionable insights** → Focus on TFP-relevant content
- **Overwhelming backlog** → Set weekly processing limits

### **Optimization Tips:**
- **Start with TFP-relevant articles** only
- **Focus on quality over quantity** of captures
- **Use progressive summarization gradually** - don't force Layer 4
- **Connect insights to current projects** for immediate value

---

**Ready to set up your Readwise Reader tags?** Start with creating the tag structure, then save your first test article!
