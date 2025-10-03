"""Beautiful UI components using Gum."""

import subprocess
from typing import List, Optional


class GumUI:
    """Wrapper for gum CLI tool to create beautiful interactive UIs."""

    @staticmethod
    def style(
        text: str,
        foreground: Optional[str] = None,
        background: Optional[str] = None,
        border: Optional[str] = None,
        border_foreground: Optional[str] = None,
        padding: Optional[str] = None,
        margin: Optional[str] = None,
        bold: bool = False,
        italic: bool = False,
        align: Optional[str] = None,
        width: Optional[int] = None,
        height: Optional[int] = None,
    ) -> None:
        """Display styled text."""
        args = ["gum", "style"]

        if foreground:
            args.extend(["--foreground", foreground])
        if background:
            args.extend(["--background", background])
        if border:
            args.extend(["--border", border])
        if border_foreground:
            args.extend(["--border-foreground", border_foreground])
        if padding:
            args.extend(["--padding", padding])
        if margin:
            args.extend(["--margin", margin])
        if bold:
            args.append("--bold")
        if italic:
            args.append("--italic")
        if align:
            args.extend(["--align", align])
        if width:
            args.extend(["--width", str(width)])
        if height:
            args.extend(["--height", str(height)])

        args.append(text)
        subprocess.run(args)

    @staticmethod
    def input_text(
        prompt: str = "", placeholder: str = "", password: bool = False, value: str = ""
    ) -> str:
        """Get text input from user."""
        args = ["gum", "input"]

        if placeholder:
            args.extend(["--placeholder", placeholder])
        if password:
            args.append("--password")
        if value:
            args.extend(["--value", value])
        if prompt:
            args.extend(["--prompt", prompt])

        result = subprocess.run(args, capture_output=True, text=True)
        return result.stdout.strip()

    @staticmethod
    def choose(
        options: List[str],
        prompt: str = "",
        multiple: bool = False,
        limit: int = 10,
        height: int = 10,
    ) -> Optional[str | List[str]]:
        """Let user choose from options."""
        if not options:
            return [] if multiple else None

        args = ["gum", "choose"]

        if multiple:
            args.append("--no-limit")
        if limit:
            args.extend(["--limit", str(limit)])
        if height:
            args.extend(["--height", str(height)])

        args.extend(options)

        result = subprocess.run(args, capture_output=True, text=True)
        output = result.stdout.strip()

        if not output:
            return [] if multiple else None

        if multiple:
            return output.split("\n") if output else []
        return output

    @staticmethod
    def filter_list(
        options: List[str],
        placeholder: str = "Filter...",
        prompt: str = "> ",
        limit: int = 10,
    ) -> Optional[str]:
        """Interactive fuzzy filter."""
        if not options:
            return None

        args = ["gum", "filter"]

        if placeholder:
            args.extend(["--placeholder", placeholder])
        if prompt:
            args.extend(["--prompt", prompt])
        if limit:
            args.extend(["--limit", str(limit)])

        # Pass options via stdin
        input_text = "\n".join(options)
        result = subprocess.run(args, input=input_text, capture_output=True, text=True)

        return result.stdout.strip() or None

    @staticmethod
    def confirm(prompt: str, default: bool = True) -> bool:
        """Get yes/no confirmation."""
        args = ["gum", "confirm", prompt]

        if default:
            args.append("--default=true")

        result = subprocess.run(args, capture_output=True)
        return result.returncode == 0

    @staticmethod
    def spin(command: str, title: str = "Loading...") -> subprocess.CompletedProcess:
        """Show spinner while running command."""
        args = ["gum", "spin", "--title", title, "--", "sh", "-c", command]
        return subprocess.run(args)

    @staticmethod
    def table(
        headers: List[str], rows: List[List[str]], widths: Optional[List[int]] = None
    ) -> None:
        """Display a table."""
        # Gum doesn't have native table support, so we'll format it ourselves
        if not rows:
            return

        # Calculate column widths if not provided
        if not widths:
            widths = [
                max(len(str(row[i])) for row in [headers] + rows)
                for i in range(len(headers))
            ]

        # Format header
        header_line = (
            "│ "
            + " │ ".join(str(headers[i]).ljust(widths[i]) for i in range(len(headers)))
            + " │"
        )

        separator = "├" + "┼".join("─" * (w + 2) for w in widths) + "┤"
        top_border = "┌" + "┬".join("─" * (w + 2) for w in widths) + "┐"
        bottom_border = "└" + "┴".join("─" * (w + 2) for w in widths) + "┘"

        # Print table
        GumUI.style(top_border, foreground="212")
        GumUI.style(header_line, foreground="212", bold=True)
        GumUI.style(separator, foreground="212")

        for row in rows:
            row_line = (
                "│ "
                + " │ ".join(str(row[i]).ljust(widths[i]) for i in range(len(row)))
                + " │"
            )
            GumUI.style(row_line, foreground="147")

        GumUI.style(bottom_border, foreground="212")

    @staticmethod
    def progress_bar(current: int, total: int, width: int = 50) -> str:
        """Create a progress bar string."""
        filled = int((current / total) * width)
        bar = "█" * filled + "░" * (width - filled)
        percentage = int((current / total) * 100)
        return f"{bar} {percentage}%"

    @staticmethod
    def header(text: str, emoji: str = "🧠") -> None:
        """Display a section header."""
        GumUI.style(
            f"{emoji} {text}",
            border="double",
            padding="1 2",
            foreground="212",
            bold=True,
            align="center",
        )

    @staticmethod
    def success(text: str) -> None:
        """Display success message."""
        GumUI.style(f"✓ {text}", foreground="green", bold=True)

    @staticmethod
    def error(text: str) -> None:
        """Display error message."""
        GumUI.style(f"✗ {text}", foreground="red", bold=True)

    @staticmethod
    def warning(text: str) -> None:
        """Display warning message."""
        GumUI.style(f"⚠ {text}", foreground="yellow", bold=True)

    @staticmethod
    def info(text: str) -> None:
        """Display info message."""
        GumUI.style(f"ℹ {text}", foreground="blue")

    @staticmethod
    def box(text: str, title: str = "") -> None:
        """Display text in a box."""
        GumUI.style(text, border="rounded", padding="1 2", foreground="147")


# Global UI instance
ui = GumUI()
