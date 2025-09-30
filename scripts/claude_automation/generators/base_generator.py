"""
Base generator class with common functionality for CLAUDE.md generation.
"""

import logging
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, TemplateError

from ..schemas import GenerationResult, GitStatus

logger = logging.getLogger(__name__)


class BaseGenerator:
    """Base class for CLAUDE.md generators."""

    def __init__(self, template_dir: Path | None = None):
        """Initialize generator with template directory."""
        if template_dir is None:
            # Default to templates directory relative to this file
            template_dir = Path(__file__).parent.parent / "templates"

        self.template_dir = template_dir
        self.env = Environment(
            loader=FileSystemLoader(str(template_dir)),
            trim_blocks=True,
            lstrip_blocks=True,
            autoescape=False,  # We're generating markdown, not HTML
        )

        # Add custom filters
        self.env.filters["strftime"] = self._strftime_filter

    def _strftime_filter(self, date: datetime, fmt: str) -> str:
        """Jinja2 filter for datetime formatting."""
        return date.strftime(fmt)

    def get_current_git_status(self) -> GitStatus:
        """Get current git repository status."""
        try:
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                capture_output=True,
                text=True,
                timeout=10,
                cwd=self._get_repo_root(),
            )

            if result.returncode == 0:
                if not result.stdout.strip():
                    return GitStatus()  # Clean repository

                # Parse git status output
                lines = result.stdout.strip().split("\n")
                modified = sum(1 for line in lines if line.startswith(" M"))
                added = sum(1 for line in lines if line.startswith("A"))
                untracked = sum(1 for line in lines if line.startswith("??"))

                return GitStatus(modified=modified, added=added, untracked=untracked)

        except (
            subprocess.TimeoutExpired,
            subprocess.CalledProcessError,
            FileNotFoundError,
        ) as e:
            logger.warning(f"Failed to get git status: {e}")

        # Return unknown status on any error
        return GitStatus()

    def _get_repo_root(self) -> Path:
        """Get the root directory of the git repository."""
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                return Path(result.stdout.strip())
        except Exception:
            pass

        # Fallback: assume we're in nixos-config
        current = Path.cwd()
        while current != current.parent:
            if (current / ".git").exists() and (current / "flake.nix").exists():
                return current
            current = current.parent

        return Path.cwd()

    def create_backup(self, file_path: Path) -> Path | None:
        """Create backup of existing file."""
        if not file_path.exists():
            return None

        backup_path = file_path.with_suffix(
            f'.backup-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
        )

        try:
            import shutil

            shutil.copy2(file_path, backup_path)
            logger.info(f"Created backup: {backup_path}")
            return backup_path

        except Exception as e:
            logger.error(f"Failed to create backup: {e}")
            return None

    def render_template(self, template_name: str, context: dict[str, Any]) -> str:
        """Render a Jinja2 template with the given context."""
        try:
            template = self.env.get_template(template_name)
            return template.render(**context)

        except TemplateError as e:
            raise RuntimeError(f"Template rendering failed: {e}")

    def write_file(
        self, file_path: Path, content: str, create_backup: bool = True
    ) -> GenerationResult:
        """Write content to file with optional backup."""
        errors = []
        warnings = []
        backup_path = None

        try:
            # Create backup if requested and file exists
            if create_backup:
                backup_path = self.create_backup(file_path)

            # Ensure parent directory exists
            file_path.parent.mkdir(parents=True, exist_ok=True)

            # Write content
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)

            logger.info(f"Successfully wrote {file_path}")

            return GenerationResult(
                success=True,
                output_path=str(file_path),
                backup_path=str(backup_path) if backup_path else None,
                errors=errors,
                warnings=warnings,
                stats={
                    "file_size": len(content),
                    "line_count": content.count("\n") + 1,
                    "timestamp": datetime.now().isoformat(),
                },
            )

        except Exception as e:
            error_msg = f"Failed to write {file_path}: {e}"
            logger.error(error_msg)
            errors.append(error_msg)

            # Try to restore backup if write failed
            if backup_path and backup_path.exists():
                try:
                    import shutil

                    shutil.copy2(backup_path, file_path)
                    warnings.append("Restored from backup after write failure")
                except Exception as restore_e:
                    errors.append(f"Failed to restore backup: {restore_e}")

            return GenerationResult(
                success=False,
                output_path=str(file_path),
                backup_path=str(backup_path) if backup_path else None,
                errors=errors,
                warnings=warnings,
                stats={},
            )

    def validate_template_exists(self, template_name: str) -> bool:
        """Check if template file exists."""
        template_path = self.template_dir / template_name
        return template_path.exists()

    def get_template_info(self, template_name: str) -> dict[str, Any]:
        """Get information about a template."""
        template_path = self.template_dir / template_name

        if not template_path.exists():
            return {"exists": False}

        try:
            stat = template_path.stat()
            return {
                "exists": True,
                "size": stat.st_size,
                "modified": datetime.fromtimestamp(stat.st_mtime),
                "path": str(template_path),
            }
        except Exception as e:
            logger.warning(f"Failed to get template info: {e}")
            return {"exists": True, "error": str(e)}

    def cleanup_old_backups(self, file_path: Path, keep_count: int = 5):
        """Remove old backup files, keeping only the most recent."""
        try:
            backup_pattern = f"{file_path.name}.backup-*"
            backup_files = list(file_path.parent.glob(backup_pattern))

            if len(backup_files) <= keep_count:
                return

            # Sort by modification time (newest first)
            backup_files.sort(key=lambda p: p.stat().st_mtime, reverse=True)

            # Remove excess backups
            for old_backup in backup_files[keep_count:]:
                try:
                    old_backup.unlink()
                    logger.info(f"Removed old backup: {old_backup}")
                except Exception as e:
                    logger.warning(f"Failed to remove old backup {old_backup}: {e}")

        except Exception as e:
            logger.warning(f"Failed to cleanup old backups: {e}")
