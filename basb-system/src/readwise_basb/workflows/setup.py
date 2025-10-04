"""Interactive setup wizard for Readwise BASB integration."""

import json
import sys
from pathlib import Path

from ..api import api
from ..ui_refactored import ui


def run_setup():
    """Run interactive setup wizard."""
    ui.header("Readwise BASB Integration Setup", "🚀")

    # Welcome message
    ui.info("This wizard will help you configure the Readwise BASB integration.\n")

    # Check if config already exists
    config_path = Path.home() / ".config" / "readwise" / "config.json"

    if config_path.exists():
        ui.warning("Configuration file already exists!")
        if not ui.confirm("Do you want to reconfigure?", default=False):
            ui.info("Setup cancelled.")
            return

    # Get API token
    ui.style("\n📝 Step 1: API Token", foreground="212", bold=True)
    ui.info("Get your token from: https://readwise.io/access_token\n")

    token = ui.input_text(prompt="Enter your Readwise API token: ", password=True)

    if not token:
        ui.error("Token is required. Setup cancelled.")
        sys.exit(1)

    # Test authentication
    ui.style("\n🔐 Step 2: Testing Authentication", foreground="212", bold=True)

    # Create temporary config for testing
    config_path.parent.mkdir(parents=True, exist_ok=True)
    temp_config = {
        "api": {
            "token": token,
            "base_url": "https://readwise.io/api/v3",
            "rate_limit": 20,
        },
        "storage": {"db_path": "~/.local/share/basb/readwise.db", "cache_ttl": 3600},
        "export": {
            "drive_path": "~/Google Drive/03_RESOURCES/R2-LRN_Learning-Pipeline/Readwise-Summaries",
            "format": "markdown",
            "include_highlights": True,
            "include_tags": True,
        },
        "sync": {"auto_sync": True, "sync_interval": "daily", "sync_time": "08:30"},
        "ui": {"theme": "catppuccin", "show_progress": True, "use_colors": True},
    }

    with open(config_path, "w") as f:
        json.dump(temp_config, f, indent=2)

    # Set secure permissions
    config_path.chmod(0o600)

    # Test connection
    try:
        # Reload API client with new config
        api.config.load()
        api.token = token
        api.headers["Authorization"] = f"Token {token}"

        if api.test_auth():
            ui.success("Authentication successful!\n")
        else:
            ui.error("Authentication failed. Please check your token.")
            sys.exit(1)
    except Exception as e:
        ui.error(f"Error testing authentication: {e}")
        sys.exit(1)

    # Configure preferences
    ui.style("\n⚙️  Step 3: Preferences", foreground="212", bold=True)

    # Export path
    ui.info("Configure where to export Layer 4 summaries:")
    export_path = ui.input_text(prompt="Export path: ", value=temp_config["export"]["drive_path"])

    if export_path:
        temp_config["export"]["drive_path"] = export_path

    # Sync settings
    ui.info("\nConfigure automatic sync:")
    sync_interval = ui.choose(["daily", "hourly", "manual"], prompt="Sync interval: ")

    if sync_interval:
        temp_config["sync"]["sync_interval"] = sync_interval

    if sync_interval == "daily":
        sync_time = ui.input_text(prompt="Daily sync time (HH:MM): ", value="08:30")
        if sync_time:
            temp_config["sync"]["sync_time"] = sync_time

    # Save final configuration
    with open(config_path, "w") as f:
        json.dump(temp_config, f, indent=2)

    config_path.chmod(0o600)

    # Display summary
    ui.style("\n✨ Setup Complete!", foreground="green", bold=True)
    ui.box(
        f"""Configuration saved to: {config_path}

Next steps:
  1. Run 'rwsync' to sync your Readwise library
  2. Run 'rwlist' to browse your articles
  3. Run 'rwdaily' for your morning routine
  4. Run 'rwstats' to see your knowledge metrics

Type 'rwhelp' for more commands.
        """,
        title="Getting Started",
    )

    ui.success("\n✓ Ready to integrate Readwise with your BASB system!")


if __name__ == "__main__":
    run_setup()
