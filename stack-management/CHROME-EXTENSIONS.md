# Chrome Extension & Settings Management with Stack Management

**Intelligent tracking and lifecycle management for Chrome extensions and settings**

---

## 🎯 **Overview**

This system provides **hybrid Chrome extension and settings management** combining:
- **NixOS Home-Manager** for core, permanent extensions and settings
- **Manual installation** for trial/temporary extensions
- **Automated monitoring** to catch manual installs and prompt for workflow integration
- **Smart settings extraction** from your current Chrome configuration
- **Stack management integration** for cost-benefit analysis

---

## 🔄 **Workflow**

### **1. Core Extensions (NixOS Managed)**
Your essential extensions are declared in `modules/home-manager/base.nix`:

```nix
programs.chromium = {
  enable = true;
  package = pkgs.google-chrome;
  extensions = [
    { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium - keyboard navigation
    { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # MetaMask - crypto wallet
    # ... other core extensions
  ];
  extraOpts = {
    "DefaultZoomLevel" = 1.1;  # 110% zoom
    "BookmarkBarEnabled" = true;
    "PasswordManagerEnabled" = true;
    # ... other Chrome settings
  };
};
```

**Benefits:**
- ✅ Automatically installed on new machines
- ✅ Version controlled with your system config
- ✅ Can't be accidentally removed
- ✅ Settings synchronized across machines
- ✅ Documented with rationale

### **2. Manual Extension Installation**
For quick trials or temporary needs:

1. **Install normally** through Chrome Web Store
2. **Use extension** as needed
3. **Monitor detects** the new extension automatically
4. **System prompts** for integration decision

### **3. Automated Detection & Prompting**

The `chrome-extension-monitor.py` script runs automatically during stack reviews and detects manually installed extensions:

```bash
# Manual run
./automation/chrome-extension-monitor.py

# Automatically runs during
./automation/review-reminder.sh
```

**When a new extension is detected, you'll be prompted:**
```
🆕 New Extension Detected: AI Writing Assistant Pro
   ID: abc123def456ghi789jkl012mno345pq
   Version: 2.1.0

What would you like to do?
1. Add to Stack Management Discovery (evaluate for permanent use)
2. Move to NixOS Home-Manager (make it permanent)
3. Mark as Temporary (ignore for now)
4. Delete Extension (remove it)
5. Skip Decision (ask me later)
```

### **4. Chrome Settings Management**

The `chrome-settings-smart.py` script extracts your current Chrome settings and integrates them with NixOS:

```bash
# Analyze current Chrome settings
./automation/chrome-settings-smart.py

# Extract and merge with existing NixOS config (recommended)
./automation/chrome-settings-smart.py --merge

# Replace all existing Chrome settings with current browser settings
./automation/chrome-settings-smart.py --replace
```

**Supported Settings:**
- **Zoom & Display**: Default zoom level, per-site zoom levels
- **UI & Behavior**: Bookmark bar, home button, homepage, downloads
- **Security & Performance**: Password manager, safe browsing, hardware acceleration
- **Content Settings**: JavaScript, images, popups, notifications
- **Font Settings**: Default and minimum font sizes

**Smart Features:**
- ✅ **Conflict Detection**: Identifies duplicate settings before applying
- ✅ **Automatic Backups**: Creates timestamped backups before changes
- ✅ **Correct Zoom Formula**: Uses Chrome's base-1.2 zoom calculation (110% = 1.1)
- ✅ **2025 Chrome Structure**: Compatible with current Chrome preferences format

### **5. Extension Integration Paths**

#### **Option 1: Stack Discovery**
- Adds extension to `discovery/backlog.md`
- Goes through full evaluation process
- May eventually become NixOS-managed

#### **Option 2: Direct NixOS Integration**  
- Immediately adds to `base.nix` configuration
- Becomes permanent, managed extension
- Requires `nixos-rebuild switch` to apply

#### **Option 3: Temporary Tracking**
- Extension remains manual
- Tracked in `active/chrome-extensions.md`  
- Won't be prompted again

#### **Option 4: Removal**
- Guides you to manually remove from Chrome
- Documents why it was rejected
- Adds to internal "don't ask again" list

---

## 📁 **File Structure**

```
stack-management/
├── automation/
│   ├── chrome-extension-monitor.py    # Extension detection & prompting
│   └── chrome-settings-smart.py       # Smart settings extraction & management
├── active/
│   └── chrome-extensions.md           # Tracking file for manual extensions
└── CHROME-EXTENSIONS.md               # This documentation
```

**NixOS Config:**
```
modules/home-manager/base.nix          # Core extension declarations
```

---

## 🛠️ **Setup Instructions**

### **1. Initial Migration**
Your current extensions are already declared in NixOS config. To apply:

```bash
# Apply the configuration  
nixos-rebuild switch --flake .

# Restart Chrome to see policy-managed extensions
```

### **2. Enable Monitoring**
The monitor runs automatically with stack reviews, or manually:

```bash
cd ~/nixos-config/stack-management
./automation/chrome-extension-monitor.py
```

### **3. Initialize Chrome Settings**
Extract your current Chrome settings and add them to NixOS:

```bash
# Analyze current settings (safe, read-only)
./automation/chrome-settings-smart.py

# Apply settings to NixOS config
./automation/chrome-settings-smart.py --merge

# Rebuild NixOS to apply changes
sudo nixos-rebuild switch --flake .
```

### **4. Test the Workflow**
1. Install a new extension manually from Chrome Web Store
2. Run the monitor script
3. Choose your integration path
4. Verify the extension is tracked appropriately

---

## 🎯 **Extension Categories**

### **Core Productivity** (Always NixOS-managed)
- **Vimium**: Keyboard navigation
- **Grammarly**: Writing assistance  
- **Readwise Highlighter**: Knowledge capture

### **Development Tools** (NixOS-managed for consistency)
- **React Developer Tools**: Component debugging
- **SelectorGadget**: CSS selector finding

### **Security & Privacy** (NixOS-managed for security)
- **MetaMask**: Crypto wallet
- **NordVPN**: VPN integration

### **Utilities** (Evaluated case-by-case)
- **Save to Pocket**: Reading list
- **Smallpdf**: PDF tools
- **Simplify Gmail**: Email cleanup

### **Experimental** (Manual installation, temporary)
- New AI tools for trial
- Specialized workflow extensions
- One-off project needs

---

## 🔧 **Management Operations**

### **Adding Core Extension**
```nix
# In modules/home-manager/base.nix
extensions = [
  # ... existing extensions
  { id = "NEW_EXTENSION_ID"; } # Brief description
];
```

Then rebuild: `nixos-rebuild switch --flake .`

### **Removing Core Extension**
```nix
# Comment out or delete line
# { id = "OLD_EXTENSION_ID"; } # No longer needed
```

Then rebuild and restart Chrome.

### **Checking Extension Status**
```bash
# See all installed vs managed
./automation/chrome-extension-monitor.py

# Manual check of Chrome policy
# Open: chrome://policy/
# Look for: ExtensionInstallForcelist
```

### **Managing Chrome Settings**
```bash
# Check current settings vs NixOS config
./automation/chrome-settings-smart.py

# Update NixOS config with current browser settings
./automation/chrome-settings-smart.py --merge

# View Chrome policies in browser
# Open: chrome://policy/
```

### **Bulk Extension Review**
```bash
# Monthly extension audit
./automation/review-reminder.sh force

# Check for unused extensions
cat active/chrome-extensions.md
```

---

## 🚨 **Troubleshooting**

### **Extensions Not Installing**
1. Check Chrome policy: `chrome://policy/`
2. Verify NixOS config syntax
3. Restart Chrome after rebuild
4. Check extension ID is correct (32 characters)

### **Manual Extensions Keep Disappearing**  
- This is normal for policy-managed extensions
- Either add to NixOS config or mark as temporary

### **Monitor Script Not Working**
```bash
# Check permissions
ls -la automation/chrome-extension-monitor.py
ls -la automation/chrome-settings-smart.py

# Test Python requirements
python3 -c "import json, pathlib; print('OK')"

# Check Chrome preferences file
ls -la ~/.config/google-chrome/Default/Preferences
```

### **Settings Script Issues**
```bash
# Check if Chrome is running (close Chrome before extracting settings)
ps aux | grep chrome

# Verify NixOS config has extraOpts section
grep -A 5 "extraOpts" ~/nixos-config/modules/home-manager/base.nix

# Test settings extraction without applying
./automation/chrome-settings-smart.py
```

### **Extension Conflicts**
- Some extensions conflict with policy management
- Try installing manually first, then migrating to NixOS
- Document conflicts in `active/chrome-extensions.md`

---

## 📊 **Benefits of This System**

### **Reproducibility**
- New machines get same extensions and settings automatically
- Configuration version controlled with system
- No manual setup of development environment
- Consistent browser experience across machines

### **Stack Awareness**  
- Extensions go through evaluation process
- Cost-benefit analysis for paid extensions
- Documentation of why each extension is used
- Settings changes tracked in version control

### **Hybrid Flexibility**
- Quick trials don't require config changes
- Permanent extensions and settings are properly managed  
- Clear path from trial to permanent
- Easy rollback via NixOS generations

### **Lifecycle Management**
- Detection of unused extensions
- Systematic deprecation process
- Learning from extension adoption patterns
- Settings drift detection and correction

### **Smart Configuration**
- Automatic backup before changes
- Conflict detection prevents broken builds
- Compatible with 2025 Chrome structure
- Intelligent merging of existing configurations

---

## 🔮 **Future Enhancements**

### **Planned Features**
- Usage analytics integration
- Extension update notifications  
- Bulk migration tools
- Chrome profile synchronization
- Settings change monitoring and alerts
- Automated settings drift correction

### **Possible Integrations**
- Browser history analysis for extension usage
- Integration with web app discovery
- Extension cost tracking (for paid extensions)
- Security audit of extension permissions
- Chrome settings compliance checking
- Cross-browser settings synchronization

---

**Last Updated**: 2025-09-18  
**Compatible With**: Google Chrome, Chromium  
**Dependencies**: NixOS Home-Manager, Python 3, jq

---

## 🎯 **Quick Reference**

### **Two Essential Scripts**

| Script | Purpose | Usage |
|--------|---------|-------|
| `chrome-extension-monitor.py` | Extension lifecycle management | `./automation/chrome-extension-monitor.py` |
| `chrome-settings-smart.py` | Smart settings extraction & management | `./automation/chrome-settings-smart.py --merge` |

### **Common Commands**

```bash
# Extension Management
./automation/chrome-extension-monitor.py

# Settings Management (analyze only)
./automation/chrome-settings-smart.py

# Settings Management (apply changes)
./automation/chrome-settings-smart.py --merge
sudo nixos-rebuild switch --flake .

# Check Chrome policies
# Open: chrome://policy/
```

**✅ Cleanup Complete**: Old, problematic scripts removed. Only verified, working scripts remain.