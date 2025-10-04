#!/usr/bin/env python3
"""Test Chrome detection methods."""

import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from readwise_basb.chrome import ChromeBookmarks


def main():
    """Test Chrome detection."""
    chrome = ChromeBookmarks()

    print("🔍 Testing Chrome Detection Methods\n")
    print("=" * 60)

    # Test with verbose logging
    print("\n📊 Verbose Detection Check:")
    print("-" * 60)
    is_running = chrome.is_chrome_running(verbose=True)

    print("\n" + "=" * 60)
    print(f"\n🎯 RESULT: Chrome is {'RUNNING' if is_running else 'NOT RUNNING'}")
    print("\n💡 If this seems wrong, check the debug output above")
    print("   Look for:")
    print("   - File lock status")
    print("   - Process IDs found")
    print("   - Any error messages")

    # Additional diagnostics
    print("\n" + "=" * 60)
    print("📁 Additional Diagnostics:")
    print("-" * 60)
    print(f"Bookmarks file: {chrome.bookmarks_path}")
    print(f"File exists: {chrome.bookmarks_path.exists()}")

    if chrome.bookmarks_path.exists():
        import os

        stats = os.stat(chrome.bookmarks_path)
        print(f"File size: {stats.st_size} bytes")
        print(f"Last modified: {stats.st_mtime}")

    # Test process commands manually
    print("\n📋 Manual Process Checks:")
    print("-" * 60)

    import subprocess

    try:
        result = subprocess.run(["pgrep", "-x", "chrome"], capture_output=True, text=True)
        if result.returncode == 0:
            pids = result.stdout.strip().split("\n")
            print(f"'pgrep -x chrome' found: {pids}")
        else:
            print("'pgrep -x chrome' found: No processes")
    except Exception as e:
        print(f"'pgrep -x chrome' error: {e}")

    try:
        result = subprocess.run(["pgrep", "-x", "google-chrome"], capture_output=True, text=True)
        if result.returncode == 0:
            pids = result.stdout.strip().split("\n")
            print(f"'pgrep -x google-chrome' found: {pids}")
        else:
            print("'pgrep -x google-chrome' found: No processes")
    except Exception as e:
        print(f"'pgrep -x google-chrome' error: {e}")

    # Show all chrome-related processes
    try:
        result = subprocess.run(["pgrep", "-a", "-i", "chrome"], capture_output=True, text=True)
        if result.returncode == 0:
            print("\n🔎 All chrome-related processes:")
            for line in result.stdout.strip().split("\n"):
                print(f"   {line}")
        else:
            print("\n🔎 All chrome-related processes: None found")
    except Exception as e:
        print(f"\n🔎 All chrome-related processes error: {e}")


if __name__ == "__main__":
    main()
