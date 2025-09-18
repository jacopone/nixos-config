#!/usr/bin/env python3
"""
Chrome Settings Extractor
Extracts current Chrome settings to help configure home-manager policies.
"""

import json
import sys
from pathlib import Path

CHROME_PREFS = Path.home() / ".config/google-chrome/Default/Preferences"

def extract_zoom_settings(prefs):
    """Extract zoom-related settings."""
    print("\n🔍 ZOOM SETTINGS")
    print("=" * 40)
    
    # Default zoom level
    default_zoom = prefs.get('partition', {}).get('default', {}).get('zoom_level', 0)
    zoom_percentage = int((2 ** default_zoom) * 100)
    print(f"Current default zoom: {zoom_percentage}% (level: {default_zoom})")
    print(f'NixOS config: "DefaultZoomLevel" = {2 ** default_zoom:.2f};')
    
    # Per-host zoom levels
    per_host_zooms = prefs.get('partition', {}).get('per_host_zoom_levels', {})
    if per_host_zooms:
        print("\nPer-site zoom levels:")
        nix_config = '"PerHostZoomLevels" = {\n'
        for host, level in per_host_zooms.items():
            percentage = int((2 ** level) * 100)
            print(f"  {host}: {percentage}% (level: {level})")
            nix_config += f'  "{host}" = {2 ** level:.2f};\n'
        nix_config += '};'
        print(f"\nNixOS config:\n{nix_config}")

def extract_appearance_settings(prefs):
    """Extract appearance and UI settings."""
    print("\n🎨 APPEARANCE SETTINGS")
    print("=" * 40)
    
    bookmark_bar = prefs.get('bookmark_bar', {}).get('show_on_all_tabs', True)
    print(f"Bookmarks bar shown: {bookmark_bar}")
    print(f'"BookmarkBarEnabled" = {str(bookmark_bar).lower()};')
    
    show_home = prefs.get('browser', {}).get('show_home_button', False)  
    print(f"Home button shown: {show_home}")
    print(f'"ShowHomeButton" = {str(show_home).lower()};')
    
    homepage = prefs.get('homepage', 'https://www.google.com')
    print(f"Homepage: {homepage}")
    print(f'"HomepageLocation" = "{homepage}";')

def extract_download_settings(prefs):
    """Extract download preferences."""
    print("\n📥 DOWNLOAD SETTINGS") 
    print("=" * 40)
    
    download_dir = prefs.get('download', {}).get('default_directory', str(Path.home() / "Downloads"))
    print(f"Download directory: {download_dir}")
    print(f'"DownloadDirectory" = "{download_dir}";')
    
    prompt_location = prefs.get('download', {}).get('prompt_for_download', True)
    print(f"Prompt for download location: {prompt_location}")  
    print(f'"PromptForDownloadLocation" = {str(prompt_location).lower()};')

def extract_privacy_settings(prefs):
    """Extract privacy and security settings."""
    print("\n🔒 PRIVACY & SECURITY")
    print("=" * 40)
    
    # Safe browsing
    safe_browsing = prefs.get('safebrowsing', {}).get('enabled', True)
    enhanced_protection = prefs.get('safebrowsing', {}).get('enhanced', False)
    if enhanced_protection:
        level = 2
        level_name = "Enhanced"
    elif safe_browsing:
        level = 1  
        level_name = "Standard"
    else:
        level = 0
        level_name = "Disabled"
    
    print(f"Safe Browsing: {level_name}")
    print(f'"SafeBrowsingProtectionLevel" = {level};')
    
    # Password manager
    password_manager = prefs.get('credentials_enable_service', True)
    print(f"Password manager: {password_manager}")
    print(f'"PasswordManagerEnabled" = {str(password_manager).lower()};')

def extract_search_settings(prefs):
    """Extract search engine settings."""
    print("\n🔍 SEARCH SETTINGS")
    print("=" * 40)
    
    default_search = prefs.get('default_search_provider_data', {})
    if default_search:
        search_name = default_search.get('template_url_data', {}).get('short_name', 'Unknown')
        search_url = default_search.get('template_url_data', {}).get('url', '')
        print(f"Default search engine: {search_name}")
        print(f"Search URL: {search_url}")
        if '{searchTerms}' in search_url:
            print(f'"DefaultSearchProviderName" = "{search_name}";')
            print(f'"DefaultSearchProviderSearchURL" = "{search_url}";')

def main():
    """Main extraction function."""
    print("🔧 Chrome Settings Extractor")
    print("Analyzing your current Chrome configuration...")
    
    if not CHROME_PREFS.exists():
        print("❌ Chrome preferences file not found!")
        print(f"Expected location: {CHROME_PREFS}")
        sys.exit(1)
    
    try:
        with open(CHROME_PREFS, 'r') as f:
            prefs = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Error reading Chrome preferences: {e}")
        sys.exit(1)
    
    # Extract different categories
    extract_zoom_settings(prefs)
    extract_appearance_settings(prefs)  
    extract_download_settings(prefs)
    extract_privacy_settings(prefs)
    extract_search_settings(prefs)
    
    print("\n" + "=" * 60)
    print("✅ Extraction complete!")
    print("💡 Copy the relevant NixOS config lines above into your")
    print("   modules/home-manager/base.nix extraOpts section")
    print("🔄 Then run: nixos-rebuild switch --flake .")

if __name__ == "__main__":
    main()