"""Configuration management for Readwise BASB integration."""

import json
from pathlib import Path
from typing import Any


class Config:
    """Manage configuration for Readwise BASB integration."""

    def __init__(self):
        self.config_path = Path.home() / ".config" / "readwise" / "config.json"
        self.tag_mapping_path = Path(__file__).parent.parent.parent / "config" / "tag-mapping.json"
        self._config = None
        self._tag_mapping = None

    def load(self) -> dict[str, Any]:
        """Load configuration from file."""
        if not self.config_path.exists():
            raise FileNotFoundError(
                f"Configuration file not found: {self.config_path}\n" "Run 'rwsetup' to create it."
            )

        with open(self.config_path) as f:
            self._config = json.load(f)

        return self._config

    def load_tag_mapping(self) -> dict[str, Any]:
        """Load tag mapping configuration."""
        if not self.tag_mapping_path.exists():
            raise FileNotFoundError(f"Tag mapping not found: {self.tag_mapping_path}")

        with open(self.tag_mapping_path) as f:
            self._tag_mapping = json.load(f)

        return self._tag_mapping

    @property
    def api_token(self) -> str:
        """Get API token."""
        if not self._config:
            self.load()
        return self._config["api"]["token"]

    @property
    def api_base_url(self) -> str:
        """Get API base URL."""
        if not self._config:
            self.load()
        return self._config["api"]["base_url"]

    @property
    def db_path(self) -> Path:
        """Get database path."""
        if not self._config:
            self.load()
        path = Path(self._config["storage"]["db_path"]).expanduser()
        path.parent.mkdir(parents=True, exist_ok=True)
        return path

    @property
    def export_path(self) -> Path:
        """Get export path."""
        if not self._config:
            self.load()
        return Path(self._config["export"]["drive_path"]).expanduser()

    def get_tfps(self) -> dict[str, str]:
        """Get Twelve Favorite Problems."""
        if not self._tag_mapping:
            self.load_tag_mapping()
        return self._tag_mapping["tfps"]

    def get_domains(self) -> dict[str, str]:
        """Get domain codes."""
        if not self._tag_mapping:
            self.load_tag_mapping()
        return self._tag_mapping["domains"]

    def get_para_categories(self) -> dict[str, list]:
        """Get PARA categories."""
        if not self._tag_mapping:
            self.load_tag_mapping()
        return self._tag_mapping["para_categories"]

    def get_layers(self) -> dict[str, str]:
        """Get progressive summarization layers."""
        if not self._tag_mapping:
            self.load_tag_mapping()
        return self._tag_mapping["layers"]

    def get_action_levels(self) -> dict[str, str]:
        """Get action levels."""
        if not self._tag_mapping:
            self.load_tag_mapping()
        return self._tag_mapping["action_levels"]


# Global config instance
config = Config()
