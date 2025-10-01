"""
Content validation for generated CLAUDE.md files.
"""

import logging
import re
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)


class ValidationError(Exception):
    """Validation error."""

    pass


class ContentValidator:
    """Validates generated CLAUDE.md content."""

    def __init__(self):
        self.required_sections = [
            "CLAUDE CODE TOOL SELECTION POLICY",
            "System Information",
            "Available Command Line Tools",
        ]

        self.required_patterns = [
            r"Last updated:",
            r"SYSTEM OPTIMIZATION LEVEL: EXPERT",
            r"MANDATORY Tool Substitutions",
            r"find.*→.*fd",
            r"ls.*→.*eza",
            r"cat.*→.*bat",
        ]

    def validate_system_content(self, content: str) -> dict[str, Any]:
        """Validate system-level CLAUDE.md content."""
        errors = []
        warnings = []
        stats = {}

        # Check basic structure
        errors.extend(self._check_required_sections(content, self.required_sections))
        errors.extend(self._check_required_patterns(content, self.required_patterns))

        # Check specific content
        errors.extend(self._validate_tool_substitutions(content))
        warnings.extend(self._check_content_quality(content))

        # Calculate statistics
        stats.update(self._calculate_content_stats(content))

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "warnings": warnings,
            "stats": stats,
        }

    def validate_project_content(self, content: str) -> dict[str, Any]:
        """Validate project-level CLAUDE.md content."""
        errors = []
        warnings = []
        stats = {}

        project_sections = [
            "Tech Stack",
            "Essential Commands",
            "Project Structure",
            "Working Features",
        ]

        # Check basic structure
        errors.extend(self._check_required_sections(content, project_sections))

        # Check project-specific content
        # Look for package/tool count information (flexible patterns)
        if not re.search(r"\d+\s+(tools|packages)", content, re.IGNORECASE):
            warnings.append("Missing package count information")

        if "git status" not in content.lower():
            warnings.append("Missing git status information")

        # Check for working features
        if "Working Features" in content:
            features_section = self._extract_section(content, "Working Features")
            if not features_section or len(features_section.strip()) < 50:
                warnings.append("Working Features section seems too short")

        # Calculate statistics
        stats.update(self._calculate_content_stats(content))

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "warnings": warnings,
            "stats": stats,
        }

    def _check_required_sections(
        self, content: str, required_sections: list[str]
    ) -> list[str]:
        """Check that all required sections are present."""
        errors = []
        content_lower = content.lower()

        for section in required_sections:
            if section.lower() not in content_lower:
                errors.append(f"Missing required section: {section}")

        return errors

    def _check_required_patterns(self, content: str, patterns: list[str]) -> list[str]:
        """Check that required patterns are present."""
        errors = []

        for pattern in patterns:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Missing required pattern: {pattern}")

        return errors

    def _validate_tool_substitutions(self, content: str) -> list[str]:
        """Validate that tool substitutions are properly formatted."""
        errors = []

        # Check for mandatory substitutions
        mandatory_tools = ["find", "ls", "cat", "grep", "du", "ps"]
        substitution_section = self._extract_section(
            content, "MANDATORY Tool Substitutions"
        )

        if substitution_section:
            for tool in mandatory_tools:
                if tool not in substitution_section.lower():
                    errors.append(f"Missing tool substitution for: {tool}")
        else:
            errors.append("Tool substitutions section not found")

        return errors

    def _check_content_quality(self, content: str) -> list[str]:
        """Check content quality and provide warnings."""
        warnings = []

        # Check length
        if len(content) < 5000:
            warnings.append("Content seems short for a comprehensive guide")
        elif len(content) > 50000:
            warnings.append("Content is very long - consider breaking into sections")

        # Check for broken links (basic)
        broken_link_pattern = r"\[([^\]]+)\]\(\s*\)"
        if re.search(broken_link_pattern, content):
            warnings.append("Found empty markdown links")

        # Check for inconsistent formatting
        if content.count("```") % 2 != 0:
            warnings.append("Unmatched code block markers")

        # Check for placeholder text
        placeholders = ["TODO", "FIXME", "XXX", "PLACEHOLDER"]
        for placeholder in placeholders:
            if placeholder in content.upper():
                warnings.append(f"Found placeholder text: {placeholder}")

        return warnings

    def _extract_section(self, content: str, section_name: str) -> str | None:
        """Extract a specific section from markdown content."""
        # Simple section extraction - look for section header and content until next header
        pattern = rf"^#+ {re.escape(section_name)}.*?\n(.*?)(?=^#+ |\Z)"
        match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
        return match.group(1) if match else None

    def _calculate_content_stats(self, content: str) -> dict[str, Any]:
        """Calculate statistics about the content."""
        lines = content.split("\n")
        non_empty_lines = [line for line in lines if line.strip()]

        return {
            "total_chars": len(content),
            "total_lines": len(lines),
            "non_empty_lines": len(non_empty_lines),
            "sections": len(re.findall(r"^#+ ", content, re.MULTILINE)),
            "code_blocks": content.count("```") // 2,
            "bullet_points": len(re.findall(r"^\s*[-*] ", content, re.MULTILINE)),
            "links": len(re.findall(r"\[([^\]]+)\]\(([^)]+)\)", content)),
            "tool_references": len(re.findall(r"`[a-z][a-z0-9-]*`", content)),
        }

    def validate_file(
        self, file_path: Path, content_type: str = "auto"
    ) -> dict[str, Any]:
        """Validate a CLAUDE.md file."""
        if not file_path.exists():
            return {
                "valid": False,
                "errors": [f"File does not exist: {file_path}"],
                "warnings": [],
                "stats": {},
            }

        try:
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            # Auto-detect content type if not specified
            if content_type == "auto":
                if "System-Level CLAUDE.md" in content:
                    content_type = "system"
                elif "NixOS Configuration - Modern CLI Toolkit" in content:
                    content_type = "project"
                else:
                    content_type = "unknown"

            # Validate based on type
            if content_type == "system":
                return self.validate_system_content(content)
            elif content_type == "project":
                return self.validate_project_content(content)
            else:
                return {
                    "valid": False,
                    "errors": ["Unknown content type"],
                    "warnings": ["Could not determine file type"],
                    "stats": self._calculate_content_stats(content),
                }

        except Exception as e:
            logger.error(f"Failed to validate file {file_path}: {e}")
            return {
                "valid": False,
                "errors": [f"Validation failed: {e}"],
                "warnings": [],
                "stats": {},
            }

    def generate_validation_report(self, validation_result: dict[str, Any]) -> str:
        """Generate a human-readable validation report."""
        report = []

        if validation_result["valid"]:
            report.append("✅ Content validation PASSED")
        else:
            report.append("❌ Content validation FAILED")

        if validation_result["errors"]:
            report.append("\n🚨 Errors:")
            for error in validation_result["errors"]:
                report.append(f"  - {error}")

        if validation_result["warnings"]:
            report.append("\n⚠️  Warnings:")
            for warning in validation_result["warnings"]:
                report.append(f"  - {warning}")

        if validation_result["stats"]:
            stats = validation_result["stats"]
            report.append("\n📊 Statistics:")
            report.append(
                f"  - Content length: {stats.get('total_chars', 0):,} characters"
            )
            report.append(
                f"  - Lines: {stats.get('total_lines', 0)} total, {stats.get('non_empty_lines', 0)} non-empty"
            )
            report.append(f"  - Sections: {stats.get('sections', 0)}")
            report.append(f"  - Code blocks: {stats.get('code_blocks', 0)}")
            report.append(f"  - Tool references: {stats.get('tool_references', 0)}")

        return "\n".join(report)
