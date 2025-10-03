"""Pytest configuration and fixtures."""

import json
from pathlib import Path
from typing import Any

import pytest


@pytest.fixture
def sample_bookmarks_data() -> dict[str, Any]:
    """Sample Chrome bookmarks JSON structure."""
    return {
        "roots": {
            "bookmark_bar": {
                "type": "folder",
                "name": "Bookmarks bar",
                "children": [
                    {
                        "type": "url",
                        "id": "1",
                        "name": "Google",
                        "url": "https://www.google.com",
                        "date_added": "13350000000000000",
                    }
                ],
            },
            "other": {
                "type": "folder",
                "name": "Other bookmarks",
                "children": [
                    {
                        "type": "folder",
                        "name": "GTD",
                        "children": [
                            {
                                "type": "url",
                                "id": "2",
                                "name": "GTD Article",
                                "url": "https://example.com/gtd",
                                "date_added": "13350000000000000",
                            }
                        ],
                    },
                    {
                        "type": "url",
                        "id": "3",
                        "name": "Broken Link",
                        "url": "http://this-does-not-exist-123456.com",
                        "date_added": "13350000000000000",
                    },
                ],
            },
        }
    }


@pytest.fixture
def temp_bookmarks_file(tmp_path: Path, sample_bookmarks_data: dict[str, Any]) -> Path:
    """Create a temporary Chrome bookmarks file."""
    bookmarks_file = tmp_path / "Bookmarks"
    with open(bookmarks_file, "w") as f:
        json.dump(sample_bookmarks_data, f, indent=3)
    return bookmarks_file


@pytest.fixture
def temp_config_dir(tmp_path: Path) -> Path:
    """Create a temporary config directory."""
    config_dir = tmp_path / ".config" / "readwise"
    config_dir.mkdir(parents=True)
    return config_dir


@pytest.fixture
def sample_config(temp_config_dir: Path) -> Path:
    """Create a sample config.json file."""
    config_file = temp_config_dir / "config.json"
    config_data = {
        "api": {
            "base_url": "https://readwise.io/api/v3",
            "token": "test_token_12345",
            "rate_limit_delay": 3,
        },
        "storage": {
            "db_path": str(temp_config_dir / "basb.db"),
            "export_path": str(temp_config_dir / "exports"),
        },
    }
    with open(config_file, "w") as f:
        json.dump(config_data, f, indent=2)
    return config_file
