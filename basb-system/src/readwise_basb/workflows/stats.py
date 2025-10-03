"""Stats and metrics dashboard for knowledge pipeline."""

from collections import defaultdict
from datetime import datetime, timedelta

from ..api import api
from ..config import config
from ..ui import ui


def calculate_tfp_coverage(articles: list[dict]) -> dict[str, int]:
    """Calculate article coverage for each TFP."""
    tfp_counts = defaultdict(int)

    for article in articles:
        tags = article.get("tags", {})
        # Tags can be dict or list - handle both
        if isinstance(tags, dict):
            tag_list = list(tags.keys())
        else:
            tag_list = tags if tags else []

        for tag in tag_list:
            if tag.startswith("tfp"):
                tfp_counts[tag] += 1

    return dict(tfp_counts)


def calculate_layer_distribution(articles: list[dict]) -> dict[str, int]:
    """Calculate distribution across progressive summarization layers."""
    layer_counts = {
        "layer1-captured": 0,
        "layer2-bolded": 0,
        "layer3-highlighted": 0,
        "layer4-summary": 0,
    }

    for article in articles:
        tags = article.get("tags", {})
        # Tags can be dict or list - handle both
        if isinstance(tags, dict):
            tag_list = list(tags.keys())
        else:
            tag_list = tags if tags else []

        for tag in tag_list:
            if tag.startswith("layer"):
                layer_counts[tag] = layer_counts.get(tag, 0) + 1

    return layer_counts


def calculate_actionability(articles: list[dict]) -> dict[str, int]:
    """Calculate actionability distribution."""
    action_counts = defaultdict(int)

    for article in articles:
        tags = article.get("tags", {})
        # Tags can be dict or list - handle both
        if isinstance(tags, dict):
            tag_list = list(tags.keys())
        else:
            tag_list = tags if tags else []

        for tag in tag_list:
            if tag.startswith("actionable-"):
                action_level = tag.replace("actionable-", "")
                action_counts[action_level] += 1

    return dict(action_counts)


def show_progress_bar(label: str, count: int, total: int, width: int = 20):
    """Display a progress bar for metrics."""
    if total == 0:
        percentage = 0
        filled = 0
    else:
        percentage = int((count / total) * 100)
        filled = int((count / total) * width)

    bar = "█" * filled + "░" * (width - filled)
    ui.style(f"{label:<30} {bar} {count:>3} articles ({percentage:>3}%)", foreground="147")


def run_stats_dashboard(tfp_only: bool = False, weekly: bool = False):
    """Display beautiful stats dashboard."""

    ui.header("Knowledge Pipeline Metrics", "📊")

    # Load data
    ui.style("\n⠋ Loading data...", foreground="147")

    try:
        # Get all documents or filter by date
        if weekly:
            week_ago = (datetime.now() - timedelta(days=7)).isoformat()
            response = api.list_documents(updated_after=week_ago)
            period = "This Week"
        else:
            response = api.list_all_documents()
            period = "All Time"

        articles = response if isinstance(response, list) else response.get("results", [])
        total_articles = len(articles)

        ui.success(f"Loaded {total_articles} articles\n")

    except Exception as e:
        ui.error(f"Failed to load data: {e}")
        return

    # TFP Coverage Report
    if tfp_only or not weekly:
        ui.style("─" * 70, foreground="212")
        ui.style(f"TFP COVERAGE REPORT - {period.upper()}", foreground="212", bold=True)
        ui.style("─" * 70, foreground="212")

        tfps = config.get_tfps()
        tfp_coverage = calculate_tfp_coverage(articles)

        for tfp_code, question in tfps.items():
            count = tfp_coverage.get(tfp_code, 0)
            # Truncate question if too long
            short_question = question[:45] + "..." if len(question) > 45 else question
            show_progress_bar(f"{tfp_code.upper()} - {short_question}", count, total_articles)

        # Identify attention gaps
        ui.style("\n⚠️  ATTENTION NEEDED:", foreground="yellow", bold=True)

        low_coverage_tfps = [
            (code, count)
            for code, count in tfp_coverage.items()
            if total_articles > 0 and (count / total_articles) < 0.05
        ]

        if low_coverage_tfps:
            for tfp_code, count in sorted(low_coverage_tfps, key=lambda x: x[1]):
                percentage = int((count / total_articles) * 100) if total_articles > 0 else 0
                ui.style(
                    f"  • {tfp_code.upper()} - only {percentage}% coverage",
                    foreground="yellow",
                )
        else:
            ui.style("  ✓ All TFPs have good coverage!", foreground="green")

        # Suggestions
        ui.style("\n💡 SUGGESTIONS:", foreground="blue", bold=True)
        if low_coverage_tfps:
            ui.info("  • Search for content in neglected TFP areas")
            ui.info("  • Review your Twelve Favorite Problems - are they still relevant?")

    # Progressive Summarization Pipeline
    if not tfp_only:
        ui.style("\n" + "─" * 70, foreground="212")
        ui.style("PROGRESSIVE SUMMARIZATION PIPELINE", foreground="212", bold=True)
        ui.style("─" * 70, foreground="212")

        layer_dist = calculate_layer_distribution(articles)

        layer1 = layer_dist.get("layer1-captured", 0)
        layer2 = layer_dist.get("layer2-bolded", 0)
        layer3 = layer_dist.get("layer3-highlighted", 0)
        layer4 = layer_dist.get("layer4-summary", 0)

        ui.style(f"Layer 1 (Captured)     →  {layer1:>3} articles", foreground="147")

        if layer1 > 0:
            l2_pct = int((layer2 / layer1) * 100)
            ui.style(
                f"Layer 2 (Bolded)       →  {layer2:>3} articles  ({l2_pct}%)",
                foreground="147",
            )

            if layer2 > 0:
                l3_pct = int((layer3 / layer2) * 100)
                ui.style(
                    f"Layer 3 (Highlighted)  →  {layer3:>3} articles  ({l3_pct}%)",
                    foreground="147",
                )

                if layer3 > 0:
                    l4_pct = int((layer4 / layer3) * 100)
                    ui.style(
                        f"Layer 4 (Summary)      →  {layer4:>3} articles  ({l4_pct}%)",
                        foreground="147",
                    )

        # Pipeline health
        ui.style("\n📈 PIPELINE HEALTH:", foreground="blue", bold=True)
        if layer1 > 0:
            conversion_rate = int((layer4 / layer1) * 100) if layer1 > 0 else 0
            if conversion_rate >= 10:
                ui.success(f"  ✓ {conversion_rate}% Layer 1→4 conversion rate (excellent!)")
            elif conversion_rate >= 5:
                ui.info(f"  → {conversion_rate}% Layer 1→4 conversion rate (good)")
            else:
                ui.warning(f"  ⚠ {conversion_rate}% Layer 1→4 conversion rate (needs improvement)")

            # Recommendations
            if layer1 - layer2 > 10:
                ui.info(f"  • {layer1 - layer2} articles waiting for Layer 2 processing")
            if layer2 - layer3 > 5:
                ui.info(f"  • {layer2 - layer3} articles ready for Layer 3 highlighting")

    # Actionability Breakdown
    if not tfp_only:
        ui.style("\n" + "─" * 70, foreground="212")
        ui.style("ACTIONABILITY BREAKDOWN", foreground="212", bold=True)
        ui.style("─" * 70, foreground="212")

        action_dist = calculate_actionability(articles)

        now_count = action_dist.get("now", 0)
        soon_count = action_dist.get("soon", 0)
        maybe_count = action_dist.get("maybe", 0)
        ref_count = action_dist.get("ref", 0)

        show_progress_bar("Actionable Now (today)", now_count, total_articles)
        show_progress_bar("Actionable Soon (this week)", soon_count, total_articles)
        show_progress_bar("Maybe Someday", maybe_count, total_articles)
        show_progress_bar("Reference Only", ref_count, total_articles)

        if now_count > 0:
            ui.style(
                f"\n💡 You have {now_count} items ready for immediate action!",
                foreground="green",
                bold=True,
            )
            ui.info("   Run 'rwactions' to convert them to Sunsama tasks.")

    # Footer
    ui.style("\n" + "─" * 70, foreground="212")
    ui.success(f"✓ Analyzed {total_articles} articles from {period}")

    # Next steps
    if not tfp_only and not weekly:
        ui.style("\n📋 NEXT STEPS:", foreground="blue", bold=True)
        ui.info("  • Run 'rwstats --weekly' for this week's metrics")
        ui.info("  • Run 'rwdaily' for morning review workflow")
        ui.info("  • Run 'rwactions' to generate Sunsama tasks")


if __name__ == "__main__":
    import sys

    tfp_only = "--tfp" in sys.argv
    weekly = "--weekly" in sys.argv

    run_stats_dashboard(tfp_only=tfp_only, weekly=weekly)
