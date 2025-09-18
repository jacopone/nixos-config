#!/usr/bin/env python3
"""
Chrome Extension Monitor for Stack Management
Detects manually installed extensions and prompts for stack workflow integration.
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set

# Configuration
STACK_DIR = Path(__file__).parent.parent
CHROME_PREFS = Path.home() / ".config/google-chrome/Default/Preferences"
NIXOS_CONFIG = Path.home() / "nixos-config/modules/home-manager/base.nix"
EXTENSIONS_TRACKING = STACK_DIR / "active" / "chrome-extensions.md"

# Known extension names for common IDs
EXTENSION_NAMES = {
    "aghfnjkcakhmadgdomlmlhhaocbkloab": "Just Black",
    "dbepggeogbaibhgnhhndojpepiihcmeb": "Vimium",
    "djflhoibgkdhkhhcedjiklpkjnoahfmg": "User-Agent Switcher for Chrome",
    "fjoaledfpmneenckfbpdfhkmimnjocfa": "VPN for Chrome: NordVPN proxy protection",
    "fmkadmapgofadopljbjfkapdkoienihi": "React Developer Tools",
    "ghbmnnjooekpmoecnnnilnnbdlolhkhi": "Google Docs Offline",
    "ipikiaejjblmdopojhpejjmbedhlibno": "SwiftRead - read faster, learn more",
    "jjhefcfhmnkfeepcpnilbbkaadhngkbi": "Readwise Highlighter",
    "kadmollpgjhjcclemeliidekkajnjaih": "Project Mariner Companion",
    "kbfnbcaeplbcioakkpcpgfkobkghlhen": "Grammarly: AI Writing Assistant and Grammar Checker App",
    "mhjhnkcfbdhnjickkkdbjoemdmbfginb": "SelectorGadget",
    "niloccemoadcdkdjlinkgdfekeahmflj": "Save to Pocket",
    "nkbihfbeogaeaoehlefnkodbefgpgknn": "MetaMask",
    "ohfgljdgelakfkefopgklcohadegdpjf": "Smallpdf—Edit, Convert, Compress, & AI Summarize PDF",
    "pbmlfaiicoikhdbjagjbglnbfcbcojpj": "Simplify Gmail"
}

# Built-in Chrome extensions and components to ignore
CHROME_BUILTIN_EXTENSIONS = {
    "aohghmigkfhddiffpmpbdggpcijllcdb",  # CryptoToken Component Extension
    "apdfllckaahabafndbhieahigkjlhalf",  # Google Drive
    "blpcfgokakmgnkcojhhkbfbldkacnbeo",  # YouTube
    "coobgpohoikkiipiblmjeljniedjpjpf",  # Google Search
    "ejidjjhkpiempkbhmpbfngldlkglhimk",  # Unknown Chrome component
    "felcaaldnbdncclmgdcncolpebgiejap",  # Google Docs
    "fignfifoniblkonapihmkfakmlgkbkcf",  # Google Network Speech
    "floipahigmmkfhkoapmnijnlnboniglg",  # Unknown Chrome component
    "gplegfbjlmmehdoakndmohflojccocli",  # Unknown Chrome component
    "jbohegmdfkmocmbpmjckoccgdladboco",  # Unknown Chrome component
    "jgbefhffiiongohodpopckdcalediegk",  # Unknown Chrome component
    "kmendfapggjehodndflmmgagdbamhnfd",  # CryptoToken Component Extension (alt)
    "mgndgikekgjfcpckkfioiadnlibdjbkf",  # Chrome component
    "mhjfbmdgcfjbbpaeojofohoefgiehjai",  # Chrome PDF Viewer
    "neajdppkdcdipfabeoofebfddakdcjhd",  # Google Network Speech (alt)
    "nkeimhogjdpnpccoofpliimaahmaaome",  # Google Hangouts (optional builtin)
    "nmmhkkegccagdldgiimedpiccmgmieda",  # Google Wallet
    "pjkljhegncpnkpknbcohdijeoejaedia",  # Gmail
}

def get_installed_extensions() -> Dict[str, dict]:
    """Get all currently installed Chrome extensions."""
    if not CHROME_PREFS.exists():
        print("❌ Chrome preferences file not found")
        return {}
    
    try:
        with open(CHROME_PREFS, 'r') as f:
            prefs = json.load(f)
        
        extensions = {}
        ext_settings = prefs.get('extensions', {}).get('settings', {})
        
        for ext_id, settings in ext_settings.items():
            if len(ext_id) == 32 and ext_id not in CHROME_BUILTIN_EXTENSIONS:  # Valid Chrome extension ID length, not builtin
                manifest = settings.get('manifest', {})
                name = manifest.get('name', EXTENSION_NAMES.get(ext_id, 'Unknown'))
                install_time = settings.get('install_time', '0')
                
                # Skip extensions that are clearly Chrome components (have no name or version)
                if name == 'Unknown' and manifest.get('version', 'unknown') == 'unknown':
                    continue
                
                extensions[ext_id] = {
                    'name': name,
                    'install_time': install_time,
                    'version': manifest.get('version', 'unknown')
                }
        
        return extensions
    except (json.JSONDecodeError, KeyError) as e:
        print(f"❌ Error reading Chrome preferences: {e}")
        return {}

def get_nixos_managed_extensions() -> Set[str]:
    """Get extension IDs that are managed by NixOS home-manager."""
    if not NIXOS_CONFIG.exists():
        return set()
    
    try:
        with open(NIXOS_CONFIG, 'r') as f:
            content = f.read()
        
        # Extract extension IDs from NixOS config
        import re
        pattern = r'id = "([a-z]{32})";'
        matches = re.findall(pattern, content)
        return set(matches)
    except Exception as e:
        print(f"⚠️ Could not read NixOS config: {e}")
        return set()

def get_tracked_extensions() -> Dict[str, dict]:
    """Get extensions that are being tracked in stack management."""
    if not EXTENSIONS_TRACKING.exists():
        return {}
    
    try:
        with open(EXTENSIONS_TRACKING, 'r') as f:
            content = f.read()
        
        # Parse tracked extensions (simple format)
        tracked = {}
        import re
        pattern = r'- \*\*([^*]+)\*\* \(`([a-z]{32})`\): (.+)'
        matches = re.findall(pattern, content)
        
        for name, ext_id, status in matches:
            tracked[ext_id] = {
                'name': name.strip(),
                'status': status.strip()
            }
        
        return tracked
    except Exception:
        return {}

def update_tracking_file(new_extensions: Dict[str, dict]):
    """Update the chrome-extensions.md tracking file."""
    if not new_extensions:
        return
    
    # Create file if it doesn't exist
    EXTENSIONS_TRACKING.parent.mkdir(parents=True, exist_ok=True)
    
    content = f"""# Chrome Extensions Tracking

*Monitoring manually installed extensions for stack management integration*

**Last Updated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 🔍 Newly Detected Extensions

"""
    
    for ext_id, details in new_extensions.items():
        content += f"""### {details['name']}
- **ID**: `{ext_id}`
- **Detected**: {datetime.now().strftime('%Y-%m-%d')}
- **Version**: {details['version']}
- **Status**: ⏳ Pending Review
- **Action Required**: 
  - [ ] Add to stack discovery backlog
  - [ ] Move to NixOS home-manager  
  - [ ] Mark as temporary/delete

---

"""
    
    with open(EXTENSIONS_TRACKING, 'w') as f:
        f.write(content)

def prompt_user_action(ext_id: str, ext_info: dict) -> str:
    """Interactive prompt for user decision on new extension."""
    print(f"\n🆕 New Extension Detected: {ext_info['name']}")
    print(f"   ID: {ext_id}")
    print(f"   Version: {ext_info['version']}")
    print()
    print("What would you like to do?")
    print("1. Add to Stack Management Discovery (evaluate for permanent use)")
    print("2. Move to NixOS Home-Manager (make it permanent)")
    print("3. Mark as Temporary (ignore for now)")
    print("4. Delete Extension (remove it)")
    print("5. Skip Decision (ask me later)")
    
    while True:
        choice = input("\nEnter choice (1-5): ").strip()
        if choice in ['1', '2', '3', '4', '5']:
            return choice
        print("Please enter a number between 1-5")

def add_to_discovery_backlog(ext_id: str, ext_info: dict):
    """Add extension to stack management discovery backlog."""
    backlog_file = STACK_DIR / "discovery" / "backlog.md"
    
    if not backlog_file.exists():
        print("❌ Discovery backlog file not found")
        return
    
    entry = f"""
#### {datetime.now().strftime('%Y-%m-%d')} - {ext_info['name']} (Chrome Extension)
- **Source**: Chrome Extension Store (manually installed)
- **URL**: https://chrome.google.com/webstore/detail/{ext_id}
- **Quick Notes**: Chrome extension - {ext_info['name']} v{ext_info['version']}
- **Priority**: Medium
- **Why Interesting**: Manually installed, may be worth permanent integration
- **Initial Cost**: Free (Chrome extension)
"""
    
    with open(backlog_file, 'a') as f:
        f.write(entry)
    
    print(f"✅ Added {ext_info['name']} to discovery backlog")

def add_to_nixos_config(ext_id: str, ext_info: dict):
    """Add extension to NixOS home-manager configuration."""
    if not NIXOS_CONFIG.exists():
        print("❌ NixOS config file not found")
        return
    
    with open(NIXOS_CONFIG, 'r') as f:
        content = f.read()
    
    # Find the extensions section
    if 'extensions = [' in content:
        # Add to existing extensions array
        extension_line = f'    {{ id = "{ext_id}"; }} # {ext_info["name"]}\n'
        content = content.replace(
            'extensions = [',
            f'extensions = [\n{extension_line}'
        )
    else:
        print("⚠️ Could not find extensions section in NixOS config")
        print("You'll need to manually add:")
        print(f'    {{ id = "{ext_id}"; }} # {ext_info["name"]}')
        return
    
    with open(NIXOS_CONFIG, 'w') as f:
        f.write(content)
    
    print(f"✅ Added {ext_info['name']} to NixOS home-manager config")
    print("🔄 Run 'nixos-rebuild switch --flake .' to apply changes")

def main():
    """Main monitoring function."""
    print("🔍 Chrome Extension Monitor")
    print("=" * 40)
    
    # Get current state
    installed = get_installed_extensions()
    nixos_managed = get_nixos_managed_extensions()
    tracked = get_tracked_extensions()
    
    if not installed:
        print("❌ No Chrome extensions found")
        sys.exit(1)
    
    print(f"📊 Extension Summary:")
    print(f"   • Total Installed: {len(installed)}")
    print(f"   • NixOS Managed: {len(nixos_managed)}")
    print(f"   • Previously Tracked: {len(tracked)}")
    
    # Find new extensions (not in NixOS config and not previously tracked)
    new_extensions = {}
    for ext_id, ext_info in installed.items():
        if ext_id not in nixos_managed and ext_id not in tracked:
            new_extensions[ext_id] = ext_info
    
    if not new_extensions:
        print("✅ No new extensions detected")
        return
    
    print(f"\n🆕 New Extensions Detected: {len(new_extensions)}")
    print("-" * 40)
    
    # Process each new extension
    for ext_id, ext_info in new_extensions.items():
        action = prompt_user_action(ext_id, ext_info)
        
        if action == '1':  # Add to discovery
            add_to_discovery_backlog(ext_id, ext_info)
        elif action == '2':  # Add to NixOS
            add_to_nixos_config(ext_id, ext_info)
        elif action == '3':  # Mark as temporary
            print(f"⏳ Marking {ext_info['name']} as temporary")
        elif action == '4':  # Delete extension
            print(f"🗑️ Please manually remove {ext_info['name']} from Chrome")
            print("   Extension ID for reference:", ext_id)
        elif action == '5':  # Skip decision
            print(f"⏭️ Skipping {ext_info['name']} for now")
    
    # Update tracking file with any skipped extensions
    update_tracking_file({
        ext_id: ext_info for ext_id, ext_info in new_extensions.items()
    })
    
    print("\n✅ Chrome extension monitoring complete!")
    print("📝 Review stack-management/active/chrome-extensions.md for tracking")

if __name__ == "__main__":
    main()