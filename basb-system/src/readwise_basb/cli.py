"""Command-line interface for Readwise BASB integration."""

import argparse
import logging
import sys
from pathlib import Path

from readwise_basb.ui import ui
from readwise_basb.workflows import chrome_review, daily, setup, stats, tagging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(Path.home() / ".local" / "share" / "basb" / "readwise-basb.log"),
        logging.StreamHandler(sys.stderr),
    ],
)
logger = logging.getLogger(__name__)


def main() -> None:
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description="Readwise BASB Integration - Beautiful knowledge management",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  rwsetup                     Run initial setup wizard
  rwdaily                     Morning BASB review routine
  rwtag                       Interactive article tagging
  rwtag <article-id>          Tag specific article
  rwstats                     Show knowledge metrics
  rwstats --tfp               TFP coverage report only
  rwstats --weekly            This week's metrics
  rwchrome                    Review Chrome bookmarks
  rwchrome --stats            Show bookmark statistics
  rwchrome --folder GTD       Review specific folder
  rwchrome --limit 10         Limit review session

For more information, visit: https://github.com/yourusername/nixos-config
        """,
    )

    parser.add_argument(
        "command",
        nargs="?",
        choices=["setup", "daily", "tag", "stats", "chrome", "help"],
        help="Command to run",
    )

    parser.add_argument("args", nargs="*", help="Additional arguments for the command")

    parser.add_argument(
        "--tfp", action="store_true", help="Show TFP coverage only (for stats command)"
    )

    parser.add_argument(
        "--weekly",
        action="store_true",
        help="Show this week's metrics (for stats command)",
    )

    parser.add_argument(
        "--stats", action="store_true", help="Show statistics only (for chrome command)"
    )

    parser.add_argument("--folder", type=str, help="Review specific folder (for chrome command)")

    parser.add_argument(
        "--limit",
        type=int,
        default=20,
        help="Limit bookmarks per session (for chrome command)",
    )

    parser.add_argument(
        "--no-filter",
        action="store_true",
        help="Disable broken URL filtering (for chrome command)",
    )

    parser.add_argument("--debug", action="store_true", help="Enable debug logging")

    args = parser.parse_args()

    # Set debug level if requested
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
        logger.debug("Debug logging enabled")

    # Show help if no command
    if not args.command:
        parser.print_help()
        return

    # Route to appropriate workflow
    try:
        logger.info(f"Running command: {args.command}")

        if args.command == "setup":
            setup.run_setup()

        elif args.command == "daily":
            daily.run_daily_routine()

        elif args.command == "tag":
            article_id = args.args[0] if args.args else None
            tagging.run_tagging_wizard(article_id)

        elif args.command == "stats":
            stats.run_stats_dashboard(tfp_only=args.tfp, weekly=args.weekly)

        elif args.command == "chrome":
            chrome_review.run_bookmark_review(
                folder=args.folder,
                limit=args.limit,
                stats_only=args.stats,
                filter_broken=not args.no_filter,
            )

        elif args.command == "help":
            parser.print_help()

        logger.info(f"Command {args.command} completed successfully")

    except KeyboardInterrupt:
        ui.warning("\n\nOperation cancelled by user.")
        logger.info("Operation cancelled by user")
        sys.exit(0)
    except Exception as e:
        ui.error(f"\nError: {e}")
        logger.exception(f"Error running command {args.command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
