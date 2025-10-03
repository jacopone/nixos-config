# BASB System Implementation

This directory contains the complete **Building a Second Brain (BASB)** system implementation for managing knowledge across digital platforms.

## 📚 System Documentation

### **Core Implementation**
- **[BASB-IMPLEMENTATION-GUIDE.md](./BASB-IMPLEMENTATION-GUIDE.md)** - Master implementation document with complete system overview
- **[BASB-Quick-Reference-Guide.md](./BASB-Quick-Reference-Guide.md)** - Taxonomy cheat sheet and usage examples
- **[BASB-Master-Dashboard.md](./BASB-Master-Dashboard.md)** - Weekly system overview template

### **Phase 2 Workflows**
- **[BASB-File-Processing-Workflow.md](./BASB-File-Processing-Workflow.md)** - 3-question decision matrix for organizing existing files
- **[BASB-Content-Migration.md](./BASB-Content-Migration.md)** - TFP-prioritized migration of high-value content
- **[BASB-Daily-Routines.md](./BASB-Daily-Routines.md)** - Morning & evening knowledge processing workflows

### **Platform Integration**
- **[BASB-Readwise-Setup.md](./BASB-Readwise-Setup.md)** - Article processing with progressive summarization
- **[BASB-Sunsama-Integration.md](./BASB-Sunsama-Integration.md)** - Knowledge → Action pipeline

## 🎯 Quick Start

1. **Read the [Implementation Guide](./BASB-IMPLEMENTATION-GUIDE.md)** for complete system overview
2. **Use the [Quick Reference](./BASB-Quick-Reference-Guide.md)** for daily taxonomy guidance
3. **Import the [Dashboard template](./BASB-Master-Dashboard.md)** into Google Docs
4. **Start with [Daily Routines](./BASB-Daily-Routines.md)** for immediate workflow benefits

## 🏷️ System Features

- **10-Domain Taxonomy:** FAM, HLT, WRK, FIN, TEC, RES, BIZ, LRN, ART, GEN
- **8 Personal TFPs:** Twelve Favorite Problems filtering system
- **PARA Method:** Projects, Areas, Resources, Archive organization
- **Progressive Summarization:** 4-layer knowledge distillation
- **Cross-Platform Integration:** Gmail, Google Keep, Drive, Readwise, Sunsama

## 📋 Implementation Status

- ✅ **Phase 1:** Foundation setup and taxonomy design
- ✅ **Phase 2:** Workflows and platform integration
- ✅ **Phase 2.5:** Readwise Reader API Integration (Gum-powered CLI) 🎉
- ✅ **Phase 2.6:** Chrome Bookmarks Integration (Deferred deletion, URL filtering) 🎉
- ✅ **Phase 2.7:** Proper project structure with testing (devenv + pytest) 🎉
- ⏳ **Phase 3:** Optimization and automation (planned)

## 🧪 Development

The project now has a proper Python structure with testing:

```
basb-system/
├── src/readwise_basb/       # Main package
│   ├── cli.py               # CLI entry point with logging
│   ├── chrome.py            # Chrome bookmarks parser
│   ├── api.py               # Readwise API client
│   ├── workflows/           # Interactive workflows
│   └── ui.py                # Gum-powered UI components
├── tests/
│   ├── unit/                # Unit tests
│   ├── integration/         # Integration tests (planned)
│   └── conftest.py          # Pytest fixtures
├── scripts/readwise-basb    # Entry point script
├── pyproject.toml           # Project config
└── devenv.nix               # Dev environment (pytest, ruff)
```

**Running Tests:**
```bash
# Enter dev environment and run tests
devenv shell
pytest tests/           # All tests
pytest tests/unit/      # Unit tests only

# Or run directly
bash -c 'source <(devenv print-dev-env) && pytest tests/ -v'
```

**Linting:**
```bash
devenv shell
ruff check src/         # Check code
```

**Current test coverage:** 8 unit tests for Chrome bookmarks functionality

## 🆕 NEW: Readwise API Integration

**Your Readwise library is now connected to BASB!**

- 📚 **2,929 articles** ready to organize
- 🎨 **Beautiful Gum-powered CLI** for interactive workflows
- 🏷️ **Automated tagging** with BASB taxonomy
- 📊 **Knowledge metrics dashboard** with TFP coverage

**Quick Start:**
```bash
rwdaily    # Morning BASB review routine
rwtag      # Interactive article tagging
rwstats    # Knowledge pipeline metrics
```

**Documentation:**
- 🚀 [Quick Start Guide](./README-QUICKSTART.md) - Start here!
- 📖 [Full API Integration](./BASB-Readwise-API-Integration.md) - Complete reference

## 🆕 NEW: Chrome Bookmarks Integration

**Your Chrome bookmarks are now integrated with BASB!**

- 🔖 **1,885 bookmarks** ready to review
- 🎯 **Strategic review workflow** with folder prioritization
- 📊 **Progress tracking** across review sessions
- 🏷️ **Auto-tagging** based on folder structure
- 💾 **Save to Readwise** or keep in Chrome

**Quick Start:**
```bash
rwcstats    # Show bookmark statistics
rwchrome    # Start reviewing bookmarks (20/session)
```

**Features:**
- **Progressive Review:** 20 bookmarks per session (default)
- **Auto-Tagging:** Folder → BASB taxonomy mapping
- **Actions:** Save to Readwise, Delete, Keep, Skip
- **Session Tracking:** Pick up where you left off

---

*This system integrates with the broader nixos-config for a complete personal knowledge and productivity management solution.*