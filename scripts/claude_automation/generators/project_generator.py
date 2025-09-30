"""
Project-level CLAUDE.md generator using templates and configuration data.
"""

import logging
from datetime import datetime
from pathlib import Path

from ..parsers.nix_parser import NixConfigParser
from ..schemas import GenerationResult, ProjectConfig
from .base_generator import BaseGenerator

logger = logging.getLogger(__name__)


class ProjectGenerator(BaseGenerator):
    """Generates project-level CLAUDE.md files."""

    def __init__(self, template_dir: Path = None):
        super().__init__(template_dir)
        self.parser = NixConfigParser()

    def generate(self, output_path: Path, config_dir: Path = None) -> GenerationResult:
        """Generate project-level CLAUDE.md file."""
        if config_dir is None:
            config_dir = self._get_repo_root()

        try:
            # Build project configuration
            project_config = self._build_project_config(config_dir)

            # Validate the configuration
            try:
                project_config.dict()  # Triggers Pydantic validation
            except Exception as e:
                logger.error(f"Configuration validation failed: {e}")
                return GenerationResult(
                    success=False,
                    output_path=str(output_path),
                    errors=[f"Configuration validation failed: {e}"],
                    warnings=[],
                    stats={},
                )

            # Prepare template context
            context = self._prepare_template_context(project_config)

            # Render template
            content = self.render_template("project-claude.j2", context)

            # Write file
            result = self.write_file(output_path, content)

            # Add generation stats
            if result.success:
                result.stats.update(
                    {
                        "package_count": project_config.package_count,
                        "fish_abbreviation_count": project_config.fish_abbreviation_count,
                        "working_features": len(project_config.working_features),
                    }
                )

                logger.info(
                    f"Generated project CLAUDE.md with {project_config.package_count} packages"
                )

            return result

        except Exception as e:
            error_msg = f"Project generation failed: {e}"
            logger.error(error_msg)
            return GenerationResult(
                success=False,
                output_path=str(output_path),
                errors=[error_msg],
                warnings=[],
                stats={},
            )

    def _build_project_config(self, config_dir: Path) -> ProjectConfig:
        """Build project configuration from Nix files."""
        # Count packages from both system and home-manager
        package_count = self._count_total_packages(config_dir)

        # Count fish abbreviations
        fish_abbreviation_count = self._count_fish_abbreviations(config_dir)

        # Get git status
        git_status = self.get_current_git_status()

        # Get working features
        working_features = self._get_working_features()

        return ProjectConfig(
            timestamp=datetime.now(),
            package_count=package_count,
            fish_abbreviation_count=fish_abbreviation_count,
            git_status=git_status,
            working_features=working_features,
        )

    def _count_total_packages(self, config_dir: Path) -> int:
        """Count total packages from all Nix files."""
        total_count = 0

        # Count system packages
        packages_file = config_dir / "modules" / "core" / "packages.nix"
        if packages_file.exists():
            try:
                result = self.parser.parse_packages(packages_file)
                if result.success:
                    total_count += result.package_count
            except Exception as e:
                logger.warning(f"Failed to count system packages: {e}")

        # Count home-manager packages
        home_file = config_dir / "modules" / "home-manager" / "base.nix"
        if home_file.exists():
            try:
                result = self.parser.parse_packages(home_file)
                if result.success:
                    total_count += result.package_count
            except Exception as e:
                logger.warning(f"Failed to count home packages: {e}")

        return total_count

    def _count_fish_abbreviations(self, config_dir: Path) -> int:
        """Count fish shell abbreviations."""
        home_file = config_dir / "modules" / "home-manager" / "base.nix"
        if not home_file.exists():
            return 0

        try:
            abbreviations = self.parser.extract_fish_abbreviations(home_file)
            return len(abbreviations)
        except Exception as e:
            logger.warning(f"Failed to count fish abbreviations: {e}")
            return 0

    def _get_working_features(self) -> list[str]:
        """Get list of working features for the system."""
        # These could be dynamically determined by checking system state,
        # but for now we'll use a curated list that reflects the current setup
        features = [
            "Fish shell with smart abbreviations",
            "Yazi file manager with rich previews",
            "Starship prompt with visual git status",
            "Auto-updating Claude Code tool intelligence",
            "BASB knowledge management system",
            "AI orchestration with CCPM integration",
            "Chrome declarative extension management",
        ]

        # We could add dynamic checks here, e.g.:
        # - Check if fish is actually installed and configured
        # - Verify yazi preview functionality
        # - Test starship prompt configuration
        # - Validate Chrome extension setup

        return features

    def _prepare_template_context(self, config: ProjectConfig) -> dict:
        """Prepare context for template rendering."""
        return {
            "timestamp": config.timestamp,
            "package_count": config.package_count,
            "fish_abbreviation_count": config.fish_abbreviation_count,
            "git_status": config.git_status,
            "working_features": config.working_features,
            "generation_info": {
                "generator": "ProjectGenerator",
                "version": "2.0.0",
                "template": "project-claude.j2",
            },
        }

    def get_summary_stats(self, config_dir: Path = None) -> dict:
        """Get summary statistics without generating the full file."""
        if config_dir is None:
            config_dir = self._get_repo_root()

        try:
            project_config = self._build_project_config(config_dir)
            return {
                "package_count": project_config.package_count,
                "fish_abbreviation_count": project_config.fish_abbreviation_count,
                "working_features_count": len(project_config.working_features),
                "git_status": project_config.git_status.status_string,
                "timestamp": project_config.timestamp.isoformat(),
            }
        except Exception as e:
            logger.error(f"Failed to get summary stats: {e}")
            return {"error": str(e)}
