"""Beautiful UI components using Rich (Python-native, no external binaries)."""

from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Confirm, IntPrompt, Prompt
from rich.table import Table as RichTable

console = Console()


class ModernUI:
    """Python-native UI using Rich (no external binaries needed)."""

    @staticmethod
    def style(
        text: str,
        foreground: str | None = None,
        background: str | None = None,
        border: str | None = None,
        bold: bool = False,
        italic: bool = False,
        **kwargs,
    ) -> None:
        """Display styled text using Rich."""
        style_str = ""

        if foreground:
            # Support hex (#ff0000), 256-color codes (147), and named colors (red, yellow)
            if len(foreground) == 6 and all(c in "0123456789abcdefABCDEF" for c in foreground):
                style_str += f"#{foreground} "  # Hex color
            elif foreground.isdigit():
                style_str += f"color({foreground}) "  # 256-color code
            else:
                style_str += f"{foreground} "  # Named color
        if background:
            # Same logic for background colors
            if len(background) == 6 and all(c in "0123456789abcdefABCDEF" for c in background):
                style_str += f"on #{background} "
            elif background.isdigit():
                style_str += f"on color({background}) "
            else:
                style_str += f"on {background} "
        if bold:
            style_str += "bold "
        if italic:
            style_str += "italic "

        if border:
            # Use Panel for bordered text
            console.print(Panel(text, style=style_str.strip(), **kwargs))
        else:
            console.print(text, style=style_str.strip())

    @staticmethod
    def input_text(
        prompt: str = "", placeholder: str = "", password: bool = False, value: str = ""
    ) -> str:
        """Get text input from user using Rich."""
        if password:
            return Prompt.ask(prompt or "Enter password", password=True, default=value)
        return Prompt.ask(prompt or "Enter text", default=value)

    @staticmethod
    def _display_options(options: list[str], prompt: str) -> None:
        """Display numbered menu options."""
        console.print(f"\n[bold cyan]{prompt or 'Select an option:'}[/bold cyan]")
        for i, option in enumerate(options, 1):
            console.print(f"  [yellow]{i}.[/yellow] {option}")

    @staticmethod
    def _choose_multiple(options: list[str]) -> list[str]:
        """Handle multiple choice selection."""
        console.print(
            "\n[dim]Enter numbers separated by spaces (e.g., 1 3 5), or press Enter to skip[/dim]"
        )
        response = Prompt.ask("", default="")
        if not response.strip():
            return []

        try:
            indices = [int(x.strip()) - 1 for x in response.split()]
            return [options[i] for i in indices if 0 <= i < len(options)]
        except (ValueError, IndexError):
            console.print("[red]Invalid selection[/red]")
            return []

    @staticmethod
    def _choose_single(options: list[str]) -> str | None:
        """Handle single choice selection."""
        choice = IntPrompt.ask("Choice", default=1, show_default=False)
        if 1 <= choice <= len(options):
            return options[choice - 1]
        console.print("[red]Invalid selection[/red]")
        return None

    @staticmethod
    def choose(
        options: list[str],
        prompt: str = "",
        multiple: bool = False,
        limit: int = 10,
        height: int = 10,
    ) -> str | list[str] | None:
        """Let user choose from options using Rich prompts."""
        if not options:
            return [] if multiple else None

        try:
            ModernUI._display_options(options, prompt)
            if multiple:
                return ModernUI._choose_multiple(options)
            return ModernUI._choose_single(options)
        except KeyboardInterrupt:
            return [] if multiple else None
        except Exception as e:
            console.print(f"[red]Error: {e}[/red]")
            return [] if multiple else None

    @staticmethod
    def filter_list(
        options: list[str],
        placeholder: str = "Filter...",
        prompt: str = "> ",
        limit: int = 10,
    ) -> str | None:
        """Interactive filter using Rich prompts (simplified)."""
        if not options:
            return None

        try:
            console.print(f"\n[bold cyan]{prompt or 'Search:'}[/bold cyan]")
            search_term = Prompt.ask(placeholder, default="")

            if not search_term:
                # No filter, show all options as numbered list
                return ModernUI.choose(options[:limit], "Select from all options")

            # Filter options by search term (case-insensitive substring match)
            filtered = [opt for opt in options if search_term.lower() in opt.lower()]

            if not filtered:
                console.print("[yellow]No matches found[/yellow]")
                return None

            # If only one match, return it directly
            if len(filtered) == 1:
                console.print(f"[green]✓ Found: {filtered[0]}[/green]")
                return filtered[0]

            # Multiple matches, let user choose
            return ModernUI.choose(filtered[:limit], f"Found {len(filtered)} matches")
        except KeyboardInterrupt:
            return None
        except Exception:
            return None

    @staticmethod
    def confirm(prompt: str, default: bool = True) -> bool:
        """Get yes/no confirmation using Rich."""
        return Confirm.ask(prompt, default=default)

    @staticmethod
    def spin(command: str, title: str = "Loading..."):
        """Show spinner while running command using Rich Progress."""
        # Note: This is a placeholder - Rich doesn't execute shell commands
        # You should refactor code to not need this pattern
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            _task = progress.add_task(title, total=None)  # noqa: F841
            # Execute the actual work here instead of shelling out
            pass

    @staticmethod
    def table(headers: list[str], rows: list[list[str]], widths: list[int] | None = None) -> None:
        """Display a table using Rich."""
        if not rows:
            return

        table = RichTable(show_header=True, header_style="bold magenta")

        # Add columns
        for header in headers:
            table.add_column(header)

        # Add rows
        for row in rows:
            table.add_row(*[str(cell) for cell in row])

        console.print(table)

    @staticmethod
    def progress_bar(current: int, total: int, width: int = 50) -> str:
        """Create a progress bar string."""
        filled = int((current / total) * width)
        bar = "█" * filled + "░" * (width - filled)
        percentage = int((current / total) * 100)
        return f"{bar} {percentage}%"

    @staticmethod
    def header(text: str, emoji: str = "🧠") -> None:
        """Display a section header using Rich Panel."""
        console.print(
            Panel(
                f"{emoji}  {text}",
                style="bold magenta",
                border_style="magenta",
            )
        )

    @staticmethod
    def success(text: str) -> None:
        """Display success message."""
        console.print(f"✓ {text}", style="bold green")

    @staticmethod
    def error(text: str) -> None:
        """Display error message."""
        console.print(f"✗ {text}", style="bold red")

    @staticmethod
    def warning(text: str) -> None:
        """Display warning message."""
        console.print(f"⚠ {text}", style="bold yellow")

    @staticmethod
    def info(text: str) -> None:
        """Display info message."""
        console.print(f"ℹ {text}", style="blue")

    @staticmethod
    def box(text: str, title: str = "") -> None:
        """Display text in a box using Rich Panel."""
        console.print(Panel(text, title=title if title else None, style="cyan"))


# Global UI instance
ui = ModernUI()
