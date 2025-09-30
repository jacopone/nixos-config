"""
System-level CLAUDE.md generator using templates and robust parsing.
"""

import logging
from datetime import datetime
from pathlib import Path

from ..parsers.nix_parser import NixConfigParser
from ..schemas import FishAbbreviation, GenerationResult, SystemConfig, ToolCategory
from .base_generator import BaseGenerator

logger = logging.getLogger(__name__)


class SystemGenerator(BaseGenerator):
    """Generates system-level CLAUDE.md files."""

    def __init__(self, template_dir: Path = None):
        super().__init__(template_dir)
        self.parser = NixConfigParser()

    def generate(self, output_path: Path, config_dir: Path = None) -> GenerationResult:
        """Generate system-level CLAUDE.md file."""
        if config_dir is None:
            config_dir = self._get_repo_root()

        try:
            # Parse configuration files
            system_config = self._build_system_config(config_dir)

            # Validate the configuration
            try:
                system_config.dict()  # Triggers Pydantic validation
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
            context = self._prepare_template_context(system_config)

            # Render template
            content = self.render_template("system-claude.j2", context)

            # Write file
            result = self.write_file(output_path, content)

            # Add generation stats
            if result.success:
                result.stats.update(
                    {
                        "total_tools": system_config.total_tools,
                        "package_count": system_config.package_count,
                        "abbreviation_count": system_config.abbreviation_count,
                        "categories": len(system_config.tool_categories),
                    }
                )

                logger.info(
                    f"Generated system CLAUDE.md with {system_config.total_tools} tools"
                )

            return result

        except Exception as e:
            error_msg = f"System generation failed: {e}"
            logger.error(error_msg)
            return GenerationResult(
                success=False,
                output_path=str(output_path),
                errors=[error_msg],
                warnings=[],
                stats={},
            )

    def _build_system_config(self, config_dir: Path) -> SystemConfig:
        """Build system configuration from Nix files."""
        # Parse system packages
        packages_file = config_dir / "modules" / "core" / "packages.nix"
        if not packages_file.exists():
            raise FileNotFoundError(f"Packages file not found: {packages_file}")

        parsing_result = self.parser.parse_packages(packages_file)
        if not parsing_result.success:
            raise RuntimeError(f"Failed to parse packages: {parsing_result.errors}")

        # Parse home-manager packages (if any)
        home_file = config_dir / "modules" / "home-manager" / "base.nix"
        home_packages = {}
        if home_file.exists():
            try:
                home_result = self.parser.parse_packages(home_file)
                if home_result.success:
                    home_packages = home_result.packages
            except Exception as e:
                logger.warning(f"Failed to parse home packages: {e}")

        # Merge packages and organize by category
        all_packages = {**parsing_result.packages, **home_packages}
        tool_categories = self._organize_by_category(all_packages)

        # Parse fish abbreviations
        fish_abbreviations = self._parse_fish_abbreviations(home_file)

        # Get git status
        git_status = self.get_current_git_status()

        return SystemConfig(
            timestamp=datetime.now(),
            package_count=len(all_packages),
            fish_abbreviations=fish_abbreviations,
            tool_categories=tool_categories,
            git_status=git_status,
        )

    def _organize_by_category(self, packages: dict) -> dict[ToolCategory, list]:
        """Organize packages by category."""
        categories = {}

        for tool_info in packages.values():
            category = tool_info.category
            if category not in categories:
                categories[category] = []
            categories[category].append(tool_info)

        # Sort tools within each category by name
        for category in categories:
            categories[category].sort(key=lambda t: t.name.lower())

        return categories

    def _parse_fish_abbreviations(self, home_file: Path) -> list[FishAbbreviation]:
        """Parse fish abbreviations from home-manager config."""
        if not home_file.exists():
            return []

        try:
            abbreviations_data = self.parser.extract_fish_abbreviations(home_file)
            return [
                FishAbbreviation(abbr=item["abbr"], command=item["command"])
                for item in abbreviations_data
            ]
        except Exception as e:
            logger.warning(f"Failed to parse fish abbreviations: {e}")
            return []

    def _prepare_template_context(self, config: SystemConfig) -> dict:
        """Prepare context for template rendering."""
        return {
            "timestamp": config.timestamp,
            "package_count": config.package_count,
            "fish_abbreviations": config.fish_abbreviations,
            "tool_categories": config.tool_categories,
            "git_status": config.git_status,
            "total_tools": config.total_tools,
            "generation_info": {
                "generator": "SystemGenerator",
                "version": "2.0.0",
                "template": "system-claude.j2",
            },
        }

    def get_summary_stats(self, config_dir: Path = None) -> dict:
        """Get summary statistics without generating the full file."""
        if config_dir is None:
            config_dir = self._get_repo_root()

        try:
            system_config = self._build_system_config(config_dir)
            return {
                "total_tools": system_config.total_tools,
                "package_count": system_config.package_count,
                "abbreviation_count": system_config.abbreviation_count,
                "categories": {
                    category.value: len(tools)
                    for category, tools in system_config.tool_categories.items()
                },
                "git_status": system_config.git_status.status_string,
                "timestamp": system_config.timestamp.isoformat(),
            }
        except Exception as e:
            logger.error(f"Failed to get summary stats: {e}")
            return {"error": str(e)}
