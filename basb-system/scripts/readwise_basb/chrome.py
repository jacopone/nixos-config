"""Chrome bookmarks parser and integration."""

import json
from pathlib import Path
from typing import List, Dict, Any
from datetime import datetime


class ChromeBookmarks:
    """Parser for Chrome bookmarks."""

    def __init__(self, profile_name: str = "Default"):
        self.profile_name = profile_name
        self.bookmarks_path = (
            Path.home() / ".config" / "google-chrome" / profile_name / "Bookmarks"
        )
        self.reviewed_path = (
            Path.home() / ".local" / "share" / "basb" / "chrome-reviewed.json"
        )
        self._bookmarks = None
        self._reviewed = set()
        self._load_reviewed()

    def _load_reviewed(self):
        """Load set of reviewed bookmark IDs."""
        if self.reviewed_path.exists():
            with open(self.reviewed_path) as f:
                data = json.load(f)
                self._reviewed = set(data.get("reviewed", []))

    def save_reviewed(self, bookmark_id: str):
        """Mark a bookmark as reviewed."""
        self._reviewed.add(bookmark_id)
        self.reviewed_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.reviewed_path, "w") as f:
            json.dump({"reviewed": list(self._reviewed)}, f, indent=2)

    def is_reviewed(self, bookmark_id: str) -> bool:
        """Check if bookmark has been reviewed."""
        return bookmark_id in self._reviewed

    def load_bookmarks(self) -> Dict[str, Any]:
        """Load bookmarks from Chrome."""
        if not self.bookmarks_path.exists():
            raise FileNotFoundError(
                f"Chrome bookmarks not found: {self.bookmarks_path}"
            )

        with open(self.bookmarks_path) as f:
            self._bookmarks = json.load(f)

        return self._bookmarks

    def _extract_bookmarks_recursive(
        self, node: Dict[str, Any], folder_path: str = ""
    ) -> List[Dict[str, Any]]:
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
                new_path = (
                    f"{folder_path}/{folder_name}" if folder_path else folder_name
                )

                # Recurse into folder
                if "children" in node:
                    for child in node["children"]:
                        bookmarks.extend(
                            self._extract_bookmarks_recursive(child, new_path)
                        )

        elif isinstance(node, list):
            for item in node:
                bookmarks.extend(self._extract_bookmarks_recursive(item, folder_path))

        return bookmarks

    def get_all_bookmarks(self, include_reviewed: bool = False) -> List[Dict[str, Any]]:
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

        return all_bookmarks

    def get_bookmarks_by_folder(
        self, folder_name: str, include_reviewed: bool = False
    ) -> List[Dict[str, Any]]:
        """Get bookmarks from a specific folder."""
        all_bookmarks = self.get_all_bookmarks(include_reviewed=include_reviewed)
        return [b for b in all_bookmarks if folder_name in b["folder"]]

    def get_folder_list(self) -> List[Dict[str, Any]]:
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

    def get_stats(self) -> Dict[str, Any]:
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
            "review_progress": int((reviewed / total * 100)) if total > 0 else 0,
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


def suggest_tags_for_bookmark(bookmark: Dict[str, Any]) -> Dict[str, Any]:
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
