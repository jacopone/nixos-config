"""Chrome bookmarks parser and integration."""

import json
import logging
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)


class ChromeBookmarks:
    """Parser for Chrome bookmarks."""

    def __init__(self, profile_name: str = "Default"):
        self.profile_name = profile_name
        self.bookmarks_path = Path.home() / ".config" / "google-chrome" / profile_name / "Bookmarks"
        self.reviewed_path = Path.home() / ".local" / "share" / "basb" / "chrome-reviewed.json"
        self.to_delete_path = Path.home() / ".local" / "share" / "basb" / "chrome-to-delete.json"
        self._bookmarks = None
        self._reviewed = set()
        self._to_delete = set()
        self._load_reviewed()
        self._load_to_delete()

    def _load_reviewed(self):
        """Load set of reviewed bookmark IDs."""
        if self.reviewed_path.exists():
            with open(self.reviewed_path) as f:
                data = json.load(f)
                self._reviewed = set(data.get("reviewed", []))

    def _load_to_delete(self):
        """Load set of bookmarks marked for deletion."""
        if self.to_delete_path.exists():
            with open(self.to_delete_path) as f:
                data = json.load(f)
                self._to_delete = set(data.get("to_delete", []))

    def save_reviewed(self, bookmark_id: str):
        """Mark a bookmark as reviewed."""
        self._reviewed.add(bookmark_id)
        self.reviewed_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.reviewed_path, "w") as f:
            json.dump({"reviewed": list(self._reviewed)}, f, indent=2)

    def mark_for_deletion(self, bookmark_id: str):
        """Mark a bookmark for deletion."""
        self._to_delete.add(bookmark_id)
        self.to_delete_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.to_delete_path, "w") as f:
            json.dump({"to_delete": list(self._to_delete)}, f, indent=2)

    def clear_deletion_queue(self):
        """Clear the deletion queue."""
        self._to_delete.clear()
        if self.to_delete_path.exists():
            self.to_delete_path.unlink()

    def get_deletion_queue(self) -> list[str]:
        """Get list of bookmark IDs marked for deletion."""
        return list(self._to_delete)

    def is_chrome_running(self, verbose: bool = False) -> bool:
        """
        Check if Chrome main browser process is currently running.

        Args:
            verbose: If True, log detailed process information

        Returns:
            True if main Chrome browser is running, False otherwise
        """
        try:
            # Method 1: Check if Bookmarks file is locked (most reliable!)
            # Chrome locks the Bookmarks file when running
            if self.bookmarks_path.exists():
                try:
                    # Try to open in exclusive mode - will fail if Chrome has it open
                    import fcntl

                    with open(self.bookmarks_path) as f:
                        try:
                            fcntl.flock(f.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                            fcntl.flock(f.fileno(), fcntl.LOCK_UN)
                            logger.debug("Bookmarks file is not locked - Chrome is NOT running")
                            if verbose:
                                logger.info("✓ Bookmarks file check: Chrome is NOT running")
                            return False
                        except BlockingIOError:
                            logger.debug("Bookmarks file is locked - Chrome IS running")
                            if verbose:
                                logger.info("⚠️  Bookmarks file is locked - Chrome IS running")
                            return True
                except Exception as e:
                    logger.debug(f"File lock check failed: {e}, falling back to process check")

            # Method 2: Fallback - check for main Chrome process (not helpers)
            # Look for the main browser process specifically
            result = subprocess.run(
                ["pgrep", "-x", "chrome"],  # -x = exact match, not substring
                capture_output=True,
                text=True,
            )

            if result.returncode == 0:
                pids = result.stdout.strip().split("\n")
                logger.debug(f"Found Chrome processes (exact match): {pids}")
                if verbose:
                    logger.info(f"⚠️  Found {len(pids)} Chrome process(es): {pids}")
                return True

            # Also try google-chrome exact match
            result2 = subprocess.run(
                ["pgrep", "-x", "google-chrome"], capture_output=True, text=True
            )

            if result2.returncode == 0:
                pids2 = result2.stdout.strip().split("\n")
                logger.debug(f"Found google-chrome processes (exact match): {pids2}")
                if verbose:
                    logger.info(f"⚠️  Found {len(pids2)} google-chrome process(es): {pids2}")
                return True

            logger.debug("No Chrome processes found")
            if verbose:
                logger.info("✓ Process check: Chrome is NOT running")
            return False

        except FileNotFoundError:
            logger.warning("pgrep not available, cannot check if Chrome is running")
            if verbose:
                logger.info("⚠️  Cannot check Chrome status (pgrep not found)")
            return False
        except Exception as e:
            logger.error(f"Error checking if Chrome is running: {e}")
            if verbose:
                logger.info(f"⚠️  Error checking Chrome status: {e}")
            return False

    def wait_for_chrome_close(self, timeout: int = 60) -> bool:
        """
        Wait for Chrome to close.
        Returns True if Chrome closed, False if timeout.
        """
        import time

        elapsed = 0
        while elapsed < timeout:
            if not self.is_chrome_running():
                return True
            time.sleep(1)
            elapsed += 1
        return False

    def delete_bookmarks(self, bookmark_ids: list[str]) -> tuple[bool, str]:
        """
        Delete bookmarks from Chrome by ID.

        WARNING: Chrome must be closed for this to work!
        Returns: (success: bool, message: str)
        """
        # Check if Chrome is running using our improved detection
        logger.debug("Checking if Chrome is running before deleting bookmarks...")
        if self.is_chrome_running(verbose=True):
            logger.warning("Chrome detected as running during delete_bookmarks")
            return (
                False,
                "Chrome is running! Please close Chrome first, then run this command again.",
            )

        # Create backup
        backup_path = self.bookmarks_path.with_suffix(".json.backup")
        logger.info(f"Creating backup at {backup_path}")
        try:
            import shutil

            shutil.copy2(self.bookmarks_path, backup_path)
            logger.info("✓ Backup created successfully")
        except Exception as e:
            logger.error(f"Failed to create backup: {e}")
            return False, f"Failed to create backup: {e}"

        # Load current bookmarks
        logger.info(f"Loading bookmarks from {self.bookmarks_path}")
        try:
            with open(self.bookmarks_path) as f:
                data = json.load(f)
            logger.info("✓ Loaded bookmarks file successfully")
        except Exception as e:
            logger.error(f"Failed to read bookmarks: {e}")
            return False, f"Failed to read bookmarks: {e}"

        # Remove bookmarks recursively
        logger.info(f"Starting deletion of {len(bookmark_ids)} bookmarks")
        deleted_count = 0

        def remove_bookmark_recursive(node, bookmark_ids_set):
            nonlocal deleted_count

            if isinstance(node, dict):
                if node.get("type") == "folder" and "children" in node:
                    # Filter out bookmarks to delete
                    original_count = len(node["children"])
                    node["children"] = [
                        child
                        for child in node["children"]
                        if child.get("id") not in bookmark_ids_set
                    ]
                    deleted_count += original_count - len(node["children"])

                    # Recurse into remaining children
                    for child in node["children"]:
                        remove_bookmark_recursive(child, bookmark_ids_set)

            elif isinstance(node, list):
                for item in node:
                    remove_bookmark_recursive(item, bookmark_ids_set)

        bookmark_ids_set = set(bookmark_ids)

        # Process all roots
        for root_name in ["bookmark_bar", "other", "synced"]:
            root = data.get("roots", {}).get(root_name)
            if root:
                remove_bookmark_recursive(root, bookmark_ids_set)

        # Write back
        logger.info(f"Writing updated bookmarks (deleted {deleted_count} bookmarks)")
        try:
            with open(self.bookmarks_path, "w") as f:
                json.dump(data, f, indent=3)
            logger.info("✓ Successfully wrote updated bookmarks file")
        except Exception as e:
            # Restore backup
            logger.error(f"Failed to write bookmarks: {e}, restoring backup...")
            import shutil

            shutil.copy2(backup_path, self.bookmarks_path)
            logger.info("✓ Backup restored")
            return False, f"Failed to write bookmarks (restored backup): {e}"

        logger.info(f"✅ Deletion complete! Deleted {deleted_count} bookmarks")
        return (
            True,
            f"Successfully deleted {deleted_count} bookmarks. Backup saved to {backup_path}",
        )

    def is_reviewed(self, bookmark_id: str) -> bool:
        """Check if bookmark has been reviewed."""
        return bookmark_id in self._reviewed

    def load_bookmarks(self) -> dict[str, Any]:
        """Load bookmarks from Chrome."""
        if not self.bookmarks_path.exists():
            raise FileNotFoundError(f"Chrome bookmarks not found: {self.bookmarks_path}")

        with open(self.bookmarks_path) as f:
            self._bookmarks = json.load(f)

        return self._bookmarks

    def _extract_bookmarks_recursive(
        self, node: dict[str, Any], folder_path: str = ""
    ) -> list[dict[str, Any]]:
        """Recursively extract bookmarks from Chrome structure."""
        bookmarks = []

        if isinstance(node, dict):
            if node.get("type") == "url":
                # Convert Chrome timestamp (microseconds since 1601) to datetime
                timestamp = int(node.get("date_added", 0))
                if timestamp:
                    # Chrome epoch: Jan 1, 1601
                    # Unix epoch: Jan 1, 1970
                    # Difference: 11644473600 seconds
                    unix_timestamp = (timestamp / 1000000) - 11644473600
                    date_added = datetime.fromtimestamp(unix_timestamp)
                else:
                    date_added = None

                bookmarks.append(
                    {
                        "id": node.get("id"),
                        "title": node.get("name", "Untitled"),
                        "url": node.get("url", ""),
                        "date_added": date_added,
                        "folder": folder_path,
                        "reviewed": self.is_reviewed(node.get("id", "")),
                    }
                )

            elif node.get("type") == "folder":
                folder_name = node.get("name", "Unknown")
                new_path = f"{folder_path}/{folder_name}" if folder_path else folder_name

                # Recurse into folder
                if "children" in node:
                    for child in node["children"]:
                        bookmarks.extend(self._extract_bookmarks_recursive(child, new_path))

        elif isinstance(node, list):
            for item in node:
                bookmarks.extend(self._extract_bookmarks_recursive(item, folder_path))

        return bookmarks

    def _is_url_accessible(self, url: str, timeout: int = 3) -> bool:
        """Check if URL is accessible using curl HEAD request (fast)."""
        try:
            # Use curl with HEAD request (faster than httpie)
            # -I = HEAD request only
            # -s = silent
            # -f = fail on HTTP errors
            # --max-time = timeout in seconds
            # -L = follow redirects
            result = subprocess.run(
                ["curl", "-I", "-s", "-f", "-L", "--max-time", str(timeout), url],
                capture_output=True,
                timeout=timeout + 1,
            )
            # curl returns 0 if successful
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            # Timeout or curl not found - assume URL is broken
            return False

    def get_all_bookmarks(
        self, include_reviewed: bool = False, filter_broken: bool = False
    ) -> list[dict[str, Any]]:
        """Get all bookmarks as flat list."""
        if not self._bookmarks:
            self.load_bookmarks()

        all_bookmarks = []

        # Extract from all roots
        for root_name in ["bookmark_bar", "other", "synced"]:
            root = self._bookmarks.get("roots", {}).get(root_name)
            if root:
                all_bookmarks.extend(self._extract_bookmarks_recursive(root, root_name))

        # Filter out reviewed if requested
        if not include_reviewed:
            all_bookmarks = [b for b in all_bookmarks if not b["reviewed"]]

        # Filter out broken URLs if requested
        if filter_broken:
            accessible_bookmarks = []
            for bookmark in all_bookmarks:
                if self._is_url_accessible(bookmark["url"]):
                    accessible_bookmarks.append(bookmark)
            return accessible_bookmarks

        return all_bookmarks

    def get_bookmarks_by_folder(
        self, folder_name: str, include_reviewed: bool = False, filter_broken: bool = False
    ) -> list[dict[str, Any]]:
        """Get bookmarks from a specific folder."""
        all_bookmarks = self.get_all_bookmarks(
            include_reviewed=include_reviewed, filter_broken=filter_broken
        )
        return [b for b in all_bookmarks if folder_name in b["folder"]]

    def get_folder_list(self) -> list[dict[str, Any]]:
        """Get list of all folders with bookmark counts."""
        all_bookmarks = self.get_all_bookmarks(include_reviewed=True)

        folders = {}
        for bookmark in all_bookmarks:
            folder = bookmark["folder"]
            if folder not in folders:
                folders[folder] = {"total": 0, "reviewed": 0, "unreviewed": 0}

            folders[folder]["total"] += 1
            if bookmark["reviewed"]:
                folders[folder]["reviewed"] += 1
            else:
                folders[folder]["unreviewed"] += 1

        return [
            {
                "name": folder,
                "total": counts["total"],
                "reviewed": counts["reviewed"],
                "unreviewed": counts["unreviewed"],
            }
            for folder, counts in sorted(
                folders.items(), key=lambda x: x[1]["unreviewed"], reverse=True
            )
        ]

    def get_stats(self) -> dict[str, Any]:
        """Get bookmark statistics."""
        all_bookmarks = self.get_all_bookmarks(include_reviewed=True)

        total = len(all_bookmarks)
        reviewed = sum(1 for b in all_bookmarks if b["reviewed"])
        unreviewed = total - reviewed

        folders = self.get_folder_list()

        return {
            "total": total,
            "reviewed": reviewed,
            "unreviewed": unreviewed,
            "review_progress": int(reviewed / total * 100) if total > 0 else 0,
            "folders": len(folders),
            "top_unreviewed_folders": folders[:5],
        }


# Folder → BASB taxonomy mapping
FOLDER_TAXONOMY = {
    "GTD": {"para": "A1", "domain": "WRK", "tfps": ["tfp5"], "action": "now"},
    "Programming & Hacking": {
        "para": "R2",
        "domain": "TEC",
        "tfps": ["tfp5"],
        "action": "ref",
    },
    "Data Science": {"para": "R2", "domain": "TEC", "tfps": ["tfp1"], "action": "ref"},
    "Startups": {"para": "R2", "domain": "BIZ", "tfps": ["tfp4"], "action": "ref"},
    "Security": {"para": "R2", "domain": "TEC", "tfps": [], "action": "ref"},
    "Inspiring - Philosophy": {
        "para": "R3",
        "domain": "LRN",
        "tfps": ["tfp2"],
        "action": "ref",
    },
    "Fintech": {"para": "R2", "domain": "FIN", "tfps": ["tfp3"], "action": "ref"},
}


def suggest_tags_for_bookmark(bookmark: dict[str, Any]) -> dict[str, Any]:
    """Suggest BASB tags based on bookmark folder."""
    folder = bookmark.get("folder", "")

    # Try to match folder to taxonomy
    for folder_name, taxonomy in FOLDER_TAXONOMY.items():
        if folder_name in folder:
            return {
                "basb_tag": f"{taxonomy['para'].lower()}-{taxonomy['domain'].lower()}",
                "tfp_tags": taxonomy["tfps"],
                "layer_tag": "layer1-captured",
                "action_tag": f"actionable-{taxonomy['action']}",
                "source": f"auto (from folder: {folder_name})",
            }

    # Default tags for unknown folders
    return {
        "basb_tag": "r3-lrn",  # Low priority learning resource
        "tfp_tags": [],
        "layer_tag": "layer1-captured",
        "action_tag": "actionable-ref",
        "source": "default (unknown folder)",
    }
