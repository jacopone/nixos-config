#!/usr/bin/env python3
"""
Smart Chrome Settings Manager for NixOS
Handles existing configurations intelligently to avoid duplicates.
"""

import json
import sys
import re
import math
from pathlib import Path
from datetime import datetime

CHROME_PREFS = Path.home() / ".config/google-chrome/Default/Preferences"
NIXOS_CONFIG = Path.home() / "nixos-config/modules/home-manager/base.nix"

# Chrome policies that might conflict
CHROME_POLICIES = {
    'DefaultZoomLevel', 'ZoomSettings', 'PerHostZoomLevels',
    'BookmarkBarEnabled', 'ShowHomeButton', 'HomepageLocation', 'HomepageIsNewTabPage',
    'DownloadDirectory', 'PromptForDownloadLocation',
    'SafeBrowsingProtectionLevel', 'PasswordManagerEnabled',
    'HardwareAccelerationModeEnabled', 'BackgroundModeEnabled', 'NetworkPredictionOptions',
    'DefaultJavaScriptSetting', 'DefaultImagesSetting', 'DefaultPopupsSetting', 'DefaultNotificationsSetting',
    'DeveloperToolsAvailability', 'DefaultFontSize', 'MinimumFontSize',
    'AutofillAddressEnabled', 'AutofillCreditCardEnabled', 'BlockThirdPartyCookies',
    'DefaultSearchProviderEnabled', 'DefaultSearchProviderName', 'DefaultSearchProviderSearchURL',
    'RestoreOnStartup', 'NewTabPageLocation', 'SyncDisabled', 'BrowserThemeColor',
    'NotificationsAllowedForUrls', 'NotificationsBlockedForUrls', 'JavaScriptAllowedForUrls',
    'DnsOverHttpsMode'
}

def zoom_level_to_percentage(zoom_level):
    """Convert Chrome's zoom level to percentage using correct base 1.2 formula."""
    if zoom_level == 0:
        return 100
    zoom_factor = 1.2 ** zoom_level
    return int(round(zoom_factor * 100))

def extract_current_chrome_settings(prefs):
    """Extract Chrome settings using the correct 2025 structure."""
    settings = {}
    
    # Zoom settings - check partition.default_zoom_level first
    partition_default = prefs.get('partition', {}).get('default_zoom_level', None)
    
    if partition_default is not None:
        if isinstance(partition_default, dict):
            if 'x' in partition_default:
                default_zoom = partition_default['x']
            else:
                default_zoom = next(iter(partition_default.values()), 0.0)
        else:
            default_zoom = partition_default
    else:
        default_zoom = prefs.get('default_zoom_level', 0.0)
        if default_zoom == 0.0:
            webkit_zoom = prefs.get('webkit', {}).get('webprefs', {}).get('default_zoom_level', None)
            if webkit_zoom is not None:
                default_zoom = webkit_zoom
    
    settings['DefaultZoomLevel'] = round(1.2 ** default_zoom, 3)
    settings['ZoomSettings'] = 1
    
    # Per-host zoom levels
    partition_zooms = prefs.get('partition', {}).get('per_host_zoom_levels', {})
    if partition_zooms:
        settings['PerHostZoomLevels'] = {}
        for host_key, zoom_data in partition_zooms.items():
            if isinstance(zoom_data, dict):
                for host, level in zoom_data.items():
                    settings['PerHostZoomLevels'][host] = round(1.2 ** level, 3)
            else:
                settings['PerHostZoomLevels'][host_key] = round(1.2 ** zoom_data, 3)
    
    # Other settings
    settings['BookmarkBarEnabled'] = prefs.get('bookmark_bar', {}).get('show_on_all_tabs', True)
    settings['ShowHomeButton'] = prefs.get('browser', {}).get('show_home_button', False)
    settings['HomepageLocation'] = prefs.get('homepage', 'https://www.google.com')
    settings['HomepageIsNewTabPage'] = prefs.get('homepage_is_newtabpage', True)
    
    download_prefs = prefs.get('download', {})
    settings['DownloadDirectory'] = download_prefs.get('default_directory', str(Path.home() / "Downloads"))
    settings['PromptForDownloadLocation'] = download_prefs.get('prompt_for_download', False)
    
    settings['PasswordManagerEnabled'] = prefs.get('credentials_enable_service', True)
    settings['SafeBrowsingProtectionLevel'] = 1
    settings['HardwareAccelerationModeEnabled'] = prefs.get('hardware_acceleration_mode_enabled', True)
    settings['BackgroundModeEnabled'] = prefs.get('background_mode', {}).get('enabled', False)
    settings['NetworkPredictionOptions'] = prefs.get('net', {}).get('network_prediction_options', 1)
    
    settings['DefaultJavaScriptSetting'] = 1
    settings['DefaultImagesSetting'] = 1
    settings['DefaultPopupsSetting'] = 2
    settings['DefaultNotificationsSetting'] = 3
    settings['DeveloperToolsAvailability'] = 1
    
    webkit_prefs = prefs.get('webkit', {}).get('webprefs', {})
    settings['DefaultFontSize'] = webkit_prefs.get('default_font_size', 16)
    settings['MinimumFontSize'] = webkit_prefs.get('minimum_font_size', 0)
    
    return settings

def analyze_existing_nixos_config():
    """Analyze existing NixOS config to find Chrome-related settings."""
    if not NIXOS_CONFIG.exists():
        return {"has_extraOpts": False, "chrome_policies": {}, "conflicts": []}
    
    with open(NIXOS_CONFIG, 'r') as f:
        content = f.read()
    
    result = {
        "has_extraOpts": False,
        "chrome_policies": {},
        "conflicts": [],
        "extracted_section": None,
        "manual_sections": []
    }
    
    # Check if extraOpts exists
    if 'extraOpts = {' in content:
        result["has_extraOpts"] = True
        
        # Find all Chrome policy settings in extraOpts
        extraopts_start = content.find('extraOpts = {')
        extraopts_end = content.find('};', extraopts_start)
        if extraopts_end != -1:
            extraopts_content = content[extraopts_start:extraopts_end]
            
            # Look for Chrome policies
            for policy in CHROME_POLICIES:
                pattern = f'"{policy}"\\s*='
                matches = re.findall(pattern, extraopts_content)
                if matches:
                    # Extract the value
                    value_pattern = f'"{policy}"\\s*=\\s*([^;]+);'
                    value_match = re.search(value_pattern, extraopts_content)
                    if value_match:
                        result["chrome_policies"][policy] = value_match.group(1).strip()
            
            # Check for extracted settings section
            if 'EXTRACTED CHROME SETTINGS' in extraopts_content:
                result["extracted_section"] = "found"
            
            # Check for manual Chrome settings sections
            chrome_section_patterns = [
                r'# .*CHROME.*SETTINGS',
                r'# .*ZOOM.*SETTINGS', 
                r'# .*PRIVACY.*SECURITY',
                r'# .*BROWSING.*BEHAVIOR',
                r'# .*DOWNLOAD.*HANDLING',
                r'# .*PERFORMANCE.*FEATURES'
            ]
            
            for pattern in chrome_section_patterns:
                if re.search(pattern, extraopts_content, re.IGNORECASE):
                    result["manual_sections"].append(pattern)
    
    return result

def detect_conflicts(existing_policies, new_settings):
    """Detect conflicts between existing and new Chrome settings."""
    conflicts = []
    
    for setting, new_value in new_settings.items():
        if setting in existing_policies:
            existing_value = existing_policies[setting]
            if str(new_value) != existing_value:
                conflicts.append({
                    'setting': setting,
                    'existing': existing_value,
                    'new': str(new_value),
                    'type': 'value_conflict'
                })
        
        # Check for multiple definitions (count occurrences)
        with open(NIXOS_CONFIG, 'r') as f:
            content = f.read()
        
        pattern = f'"{setting}"\\s*='
        matches = re.findall(pattern, content)
        if len(matches) > 1:
            conflicts.append({
                'setting': setting,
                'count': len(matches),
                'type': 'duplicate_definition'
            })
    
    return conflicts

def create_backup():
    """Create a backup of the current NixOS config."""
    backup_path = NIXOS_CONFIG.parent / f"base.nix.backup-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    
    with open(NIXOS_CONFIG, 'r') as src:
        with open(backup_path, 'w') as dst:
            dst.write(src.read())
    
    return backup_path

def smart_update_nixos_config(new_settings, analysis, user_choice='merge'):
    """Intelligently update NixOS config handling existing settings."""
    
    # Create backup first
    backup_path = create_backup()
    print(f"📁 Created backup: {backup_path}")
    
    with open(NIXOS_CONFIG, 'r') as f:
        content = f.read()
    
    if not analysis["has_extraOpts"]:
        print("❌ No extraOpts section found. Cannot update Chrome settings.")
        return False
    
    # Strategy 1: Remove all existing Chrome-related settings
    if user_choice == 'replace':
        print("🔄 Replacing all existing Chrome settings...")
        
        # Remove all Chrome policies
        for policy in CHROME_POLICIES:
            pattern = f'\\s*"{policy}"[^;]*;[\\n\\r]*'
            content = re.sub(pattern, '', content, flags=re.MULTILINE)
        
        # Remove comment sections
        chrome_section_patterns = [
            r'\\s*# ═+\\s*\\n\\s*# .*CHROME.*\\n\\s*# ═+\\s*\\n',
            r'\\s*# .*ZOOM.*SETTINGS.*\\n\\s*# =+\\s*\\n',
            r'\\s*# .*PRIVACY.*SECURITY.*\\n',
            r'\\s*# .*BROWSING.*BEHAVIOR.*\\n', 
            r'\\s*# .*DOWNLOAD.*HANDLING.*\\n',
            r'\\s*# .*PERFORMANCE.*FEATURES.*\\n'
        ]
        
        for pattern in chrome_section_patterns:
            content = re.sub(pattern, '', content, flags=re.MULTILINE | re.IGNORECASE)
    
    # Strategy 2: Only remove extracted settings section
    elif user_choice == 'merge':
        print("🔗 Merging with existing settings (removing only extracted section)...")
        
        # Remove only the extracted settings section
        extracted_pattern = r'\\s*# ═+\\s*\\n\\s*# EXTRACTED CHROME SETTINGS.*?\\n\\s*# Font Settings\\n[^}]*'
        content = re.sub(extracted_pattern, '', content, flags=re.DOTALL)
    
    # Add new settings at the beginning of extraOpts
    extraopts_start = content.find('extraOpts = {')
    insert_pos = content.find('\\n', extraopts_start) + 1
    
    # Generate new settings
    config_lines = []
    config_lines.append("      # ═══════════════════════════════════════════════════════════════════")
    config_lines.append("      # EXTRACTED CHROME SETTINGS (Smart Update)")
    config_lines.append(f"      # Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    config_lines.append("      # ═══════════════════════════════════════════════════════════════════")
    config_lines.append("")
    
    # Add settings
    config_lines.append("      # Zoom & Display")
    config_lines.append(f'      "DefaultZoomLevel" = {new_settings["DefaultZoomLevel"]};')
    config_lines.append(f'      "ZoomSettings" = {new_settings["ZoomSettings"]};')
    
    if 'PerHostZoomLevels' in new_settings:
        config_lines.append('      "PerHostZoomLevels" = {')
        for host, level in new_settings['PerHostZoomLevels'].items():
            config_lines.append(f'        "{host}" = {level};')
        config_lines.append('      };')
    
    config_lines.append("")
    config_lines.append("      # UI & Behavior")
    config_lines.append(f'      "BookmarkBarEnabled" = {str(new_settings["BookmarkBarEnabled"]).lower()};')
    config_lines.append(f'      "ShowHomeButton" = {str(new_settings["ShowHomeButton"]).lower()};')
    config_lines.append(f'      "HomepageLocation" = "{new_settings["HomepageLocation"]}";')
    config_lines.append(f'      "DownloadDirectory" = "{new_settings["DownloadDirectory"]}";')
    config_lines.append(f'      "PromptForDownloadLocation" = {str(new_settings["PromptForDownloadLocation"]).lower()};')
    
    config_lines.append("")
    config_lines.append("      # Security & Performance")
    config_lines.append(f'      "PasswordManagerEnabled" = {str(new_settings["PasswordManagerEnabled"]).lower()};')
    config_lines.append(f'      "SafeBrowsingProtectionLevel" = {new_settings["SafeBrowsingProtectionLevel"]};')
    config_lines.append(f'      "HardwareAccelerationModeEnabled" = {str(new_settings["HardwareAccelerationModeEnabled"]).lower()};')
    config_lines.append(f'      "NetworkPredictionOptions" = {new_settings["NetworkPredictionOptions"]};')
    
    new_config_text = '\\n'.join(config_lines)
    
    # Insert new settings
    new_content = content[:insert_pos] + new_config_text + '\\n\\n' + content[insert_pos:]
    
    # Clean up extra newlines
    new_content = re.sub(r'\\n{3,}', '\\n\\n', new_content)
    
    # Write updated config
    with open(NIXOS_CONFIG, 'w') as f:
        f.write(new_content)
    
    return True

def main():
    """Smart Chrome settings management."""
    print("🧠 Smart Chrome Settings Manager")
    print("=" * 50)
    
    if not CHROME_PREFS.exists():
        print("❌ Chrome preferences file not found!")
        sys.exit(1)
    
    try:
        with open(CHROME_PREFS, 'r') as f:
            prefs = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Error reading Chrome preferences: {e}")
        sys.exit(1)
    
    # Extract current Chrome settings
    print("📊 Extracting Chrome settings...")
    new_settings = extract_current_chrome_settings(prefs)
    
    # Analyze existing NixOS config
    print("🔍 Analyzing existing NixOS configuration...")
    analysis = analyze_existing_nixos_config()
    
    if not analysis["has_extraOpts"]:
        print("❌ No extraOpts section found in NixOS config.")
        print("Please add a basic extraOpts section first.")
        sys.exit(1)
    
    # Detect conflicts
    conflicts = detect_conflicts(analysis["chrome_policies"], new_settings)
    
    print(f"\\n📋 Analysis Results:")
    print(f"   • Existing Chrome policies: {len(analysis['chrome_policies'])}")
    print(f"   • Extracted section: {'Yes' if analysis['extracted_section'] else 'No'}")
    print(f"   • Manual sections: {len(analysis['manual_sections'])}")
    print(f"   • Conflicts detected: {len(conflicts)}")
    
    if conflicts:
        print("\\n⚠️  Conflicts found:")
        for conflict in conflicts:
            if conflict['type'] == 'value_conflict':
                print(f"   • {conflict['setting']}: existing='{conflict['existing']}' vs new='{conflict['new']}'")
            elif conflict['type'] == 'duplicate_definition':
                print(f"   • {conflict['setting']}: {conflict['count']} definitions found")
    
    # Get user choice
    if len(sys.argv) > 1:
        if sys.argv[1] == '--replace':
            choice = 'replace'
        elif sys.argv[1] == '--merge':
            choice = 'merge'
        else:
            choice = 'analyze'
    else:
        choice = 'analyze'
    
    if choice == 'analyze':
        print("\\n🔍 ANALYSIS COMPLETE")
        print("\\nNext steps:")
        print("  --replace : Remove all existing Chrome settings, use only extracted")
        print("  --merge   : Keep existing settings, add/update with extracted")
        return
    
    # Update configuration
    print(f"\\n🔄 Updating NixOS config with strategy: {choice}")
    
    if smart_update_nixos_config(new_settings, analysis, choice):
        print("✅ NixOS configuration updated successfully!")
        print("\\n🚀 Next steps:")
        print("1. Review the changes")
        print("2. Run: nixos-rebuild switch --flake .")
        print("3. Restart Chrome")
    else:
        print("❌ Failed to update configuration")

if __name__ == "__main__":
    main()