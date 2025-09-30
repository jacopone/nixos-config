"""
Robust Nix configuration parser with multiple parsing strategies and error recovery.
"""

import logging
import re
from abc import ABC, abstractmethod
from pathlib import Path

from ..schemas import ParsingResult, ToolCategory, ToolInfo

logger = logging.getLogger(__name__)


class NixParsingError(Exception):
    """Base exception for Nix parsing errors."""

    pass


class BaseNixParser(ABC):
    """Base class for Nix parsers."""

    @abstractmethod
    def parse(self, file_path: Path) -> ParsingResult:
        """Parse a Nix configuration file."""
        pass

    def _categorize_tool(self, pkg_name: str, description: str) -> ToolCategory:
        """Categorize a tool based on its name and description."""
        desc_lower = (pkg_name + " " + description).lower()

        # Development tools
        if any(
            word in desc_lower
            for word in [
                "git",
                "code",
                "editor",
                "develop",
                "compile",
                "build",
                "debug",
                "lsp",
                "language",
                "programming",
                "ide",
                "vim",
                "emacs",
            ]
        ):
            return ToolCategory.DEVELOPMENT

        # File management tools
        elif any(
            word in desc_lower
            for word in [
                "file",
                "find",
                "search",
                "grep",
                "ls",
                "cat",
                "tree",
                "manager",
                "archive",
                "compress",
                "extract",
                "preview",
                "thumbnail",
            ]
        ):
            return ToolCategory.FILE_MANAGEMENT

        # System monitoring tools
        elif any(
            word in desc_lower
            for word in [
                "system",
                "process",
                "monitor",
                "htop",
                "disk",
                "memory",
                "performance",
                "benchmark",
                "stats",
                "usage",
            ]
        ):
            return ToolCategory.SYSTEM_MONITORING

        # Network and security tools
        elif any(
            word in desc_lower
            for word in [
                "network",
                "http",
                "wget",
                "curl",
                "nmap",
                "security",
                "firewall",
                "scan",
                "proxy",
                "ssl",
                "tls",
            ]
        ):
            return ToolCategory.NETWORK_SECURITY

        else:
            return ToolCategory.OTHER

    def _extract_url_from_comment(self, comment: str) -> str | None:
        """Extract URL from comment if present."""
        url_pattern = r"https?://[^\s\)]+[^\s\.\,\)\]\}]"
        match = re.search(url_pattern, comment)
        return match.group() if match else None

    def _is_valid_package_name(self, name: str) -> bool:
        """Check if package name is valid."""
        if not name or len(name) < 2:
            return False

        # Skip obvious non-package patterns
        invalid_patterns = [
            "with",
            "pkgs",
            "import",
            "let",
            "in",
            "if",
            "then",
            "else",
            "rec",
            "inherit",
            "callPackage",
            "override",
            "overrideAttrs",
        ]

        if name.lower() in invalid_patterns:
            return False

        # Must contain valid characters
        allowed_chars = set(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._"
        )
        return all(c in allowed_chars for c in name)


class RegexNixParser(BaseNixParser):
    """Improved regex-based Nix parser with better error recovery."""

    def __init__(self):
        self.patterns = [
            # Package with semicolon and comment
            r"^\s*([a-zA-Z0-9_.-]+)\s*;\s*#\s*(.+)$",
            # Package with comment (no semicolon)
            r"^\s*([a-zA-Z0-9_.-]+)\s*#\s*(.+)$",
            # Package with semicolon (no comment)
            r"^\s*([a-zA-Z0-9_.-]+)\s*;\s*$",
            # Package only (no semicolon, no comment)
            r"^\s*([a-zA-Z0-9_.-]+)\s*$",
        ]

    def parse(self, file_path: Path) -> ParsingResult:
        """Parse Nix file using regex patterns."""
        try:
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            packages = {}
            warnings = []
            errors = []

            lines = content.split("\n")
            in_packages_section = False
            bracket_depth = 0

            for line_num, line in enumerate(lines, 1):
                try:
                    self._process_line(
                        line,
                        line_num,
                        packages,
                        warnings,
                        in_packages_section,
                        bracket_depth,
                    )

                    # Track section state
                    if "systemPackages" in line or "home.packages" in line:
                        in_packages_section = True
                        bracket_depth = line.count("[") - line.count("]")
                    elif in_packages_section:
                        bracket_depth += line.count("[") - line.count("]")
                        if bracket_depth <= 0 and "]" in line:
                            in_packages_section = False

                except Exception as e:
                    errors.append(f"Line {line_num}: {e}")

            if len(packages) == 0:
                errors.append("No packages found in file")

            return ParsingResult(
                success=len(packages) > 0,
                packages=packages,
                errors=errors,
                warnings=warnings,
                parser_used="RegexNixParser",
            )

        except Exception as e:
            return ParsingResult(
                success=False,
                packages={},
                errors=[f"Failed to read file: {e}"],
                warnings=[],
                parser_used="RegexNixParser",
            )

    def _process_line(
        self,
        line: str,
        line_num: int,
        packages: dict[str, ToolInfo],
        warnings: list[str],
        in_packages_section: bool,
        bracket_depth: int,
    ):
        """Process a single line of Nix configuration."""
        stripped = line.strip()

        # Skip comments and empty lines
        if not stripped or stripped.startswith("#"):
            return

        if not in_packages_section:
            return

        # Try each pattern
        for pattern in self.patterns:
            match = re.match(pattern, line)
            if match:
                pkg_name = match.group(1).strip()

                # Clean up package name
                pkg_name = pkg_name.replace("pkgs.", "").strip()

                # Validate package name
                if not self._is_valid_package_name(pkg_name):
                    warnings.append(
                        f"Line {line_num}: Skipping invalid package name '{pkg_name}'"
                    )
                    return

                # Extract description and URL
                description = ""
                url = None

                if len(match.groups()) > 1 and match.group(2):
                    comment = match.group(2).strip()
                    description = comment
                    url = self._extract_url_from_comment(comment)

                # Create ToolInfo
                if pkg_name not in packages:  # Avoid duplicates
                    category = self._categorize_tool(pkg_name, description)
                    packages[pkg_name] = ToolInfo(
                        name=pkg_name,
                        description=description or f"Command-line tool: {pkg_name}",
                        category=category,
                        url=url,
                    )

                break


class FallbackNixParser(BaseNixParser):
    """Fallback parser for malformed Nix files."""

    def parse(self, file_path: Path) -> ParsingResult:
        """Parse using very basic pattern matching."""
        try:
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            # Very basic extraction - find anything that looks like a package
            packages = {}
            warnings = ["Using fallback parser - results may be incomplete"]

            # Look for common package names
            package_pattern = r"\b([a-z][a-z0-9-]*[a-z0-9])\b"
            potential_packages = re.findall(package_pattern, content)

            # Filter to likely package names
            likely_packages = [
                pkg
                for pkg in set(potential_packages)
                if self._is_likely_package(pkg) and self._is_valid_package_name(pkg)
            ]

            for pkg_name in likely_packages[:50]:  # Limit to prevent noise
                category = self._categorize_tool(pkg_name, "")
                packages[pkg_name] = ToolInfo(
                    name=pkg_name, description=f"Package: {pkg_name}", category=category
                )

            return ParsingResult(
                success=len(packages) > 0,
                packages=packages,
                errors=[],
                warnings=warnings,
                parser_used="FallbackNixParser",
            )

        except Exception as e:
            return ParsingResult(
                success=False,
                packages={},
                errors=[f"Fallback parser failed: {e}"],
                warnings=[],
                parser_used="FallbackNixParser",
            )

    def _is_likely_package(self, name: str) -> bool:
        """Check if name looks like a real package."""
        # Common CLI tools we expect to find
        known_tools = {
            "git",
            "wget",
            "curl",
            "vim",
            "emacs",
            "firefox",
            "chrome",
            "python",
            "nodejs",
            "gcc",
            "make",
            "cmake",
            "docker",
            "tmux",
            "htop",
            "btop",
            "eza",
            "bat",
            "fd",
            "ripgrep",
            "jq",
            "yq",
        }

        if name in known_tools:
            return True

        # Must be reasonable length
        if len(name) < 2 or len(name) > 30:
            return False

        # Common package patterns
        if any(pattern in name for pattern in ["-cli", "-bin", "lib", "dev"]):
            return True

        return len(name) >= 3


class NixConfigParser:
    """Main parser that tries multiple parsing strategies."""

    def __init__(self):
        self.parsers = [
            RegexNixParser(),  # Primary parser
            FallbackNixParser(),  # Last resort
        ]

    def parse_packages(self, file_path: Path) -> ParsingResult:
        """Parse packages using the first successful parser."""
        all_errors = []
        all_warnings = []

        for parser in self.parsers:
            try:
                logger.info(f"Trying {parser.__class__.__name__}")
                result = parser.parse(file_path)

                if result.success and self._validate_result(result):
                    # Merge any previous warnings
                    result.warnings.extend(all_warnings)
                    logger.info(f"Successfully parsed with {parser.__class__.__name__}")
                    return result

                all_errors.extend(result.errors)
                all_warnings.extend(result.warnings)

            except Exception as e:
                error_msg = f"{parser.__class__.__name__} failed: {e}"
                logger.warning(error_msg)
                all_errors.append(error_msg)

        # All parsers failed
        raise NixParsingError(f"All parsers failed. Errors: {'; '.join(all_errors)}")

    def _validate_result(self, result: ParsingResult) -> bool:
        """Validate that parsing result is reasonable."""
        if result.package_count == 0:
            return False

        if result.package_count > 500:  # Sanity check
            logger.warning(f"Package count {result.package_count} seems very high")
            return False

        # Check for reasonable distribution of categories
        categories = set(tool.category for tool in result.packages.values())
        if len(categories) < 2:
            logger.warning("All packages in same category - might be parsing error")

        return True

    def extract_fish_abbreviations(self, file_path: Path) -> list[dict[str, str]]:
        """Extract fish abbreviations from home-manager config."""
        try:
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            abbreviations = []
            abbr_pattern = r'abbr -a (\w+) [\'"]([^\'"]+)[\'"]'
            matches = re.findall(abbr_pattern, content)

            for abbr, command in matches:
                abbreviations.append({"abbr": abbr, "command": command})

            return abbreviations

        except Exception as e:
            logger.error(f"Failed to extract fish abbreviations: {e}")
            return []
