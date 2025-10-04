"""Stats and metrics dashboard for knowledge pipeline."""

from collections import defaultdict
from datetime import datetime, timedelta

from ..api import api
from ..config import config
from ..ui_refactored import ui


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


def _load_stats_data(weekly: bool) -> tuple[list[dict], int, str] | None:
    """Load articles data. Returns (articles, total, period) or None on error."""
    ui.style("\n⠋ Loading data...", foreground="147")

    try:
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
        return articles, total_articles, period

    except Exception as e:
        ui.error(f"Failed to load data: {e}")
        return None


def _show_tfp_coverage_report(articles: list[dict], total_articles: int, period: str) -> None:
    """Display TFP coverage report with attention gaps."""
    ui.style("─" * 70, foreground="212")
    ui.style(f"TFP COVERAGE REPORT - {period.upper()}", foreground="212", bold=True)
    ui.style("─" * 70, foreground="212")

    tfps = config.get_tfps()
    tfp_coverage = calculate_tfp_coverage(articles)

    for tfp_code, question in tfps.items():
        count = tfp_coverage.get(tfp_code, 0)
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


def _show_layer_pipeline(articles: list[dict]) -> None:
    """Display progressive summarization pipeline stats."""
    ui.style("\n" + "─" * 70, foreground="212")
    ui.style("PROGRESSIVE SUMMARIZATION PIPELINE", foreground="212", bold=True)
    ui.style("─" * 70, foreground="212")

    layer_dist = calculate_layer_distribution(articles)

    layer1 = layer_dist.get("layer1-captured", 0)
    layer2 = layer_dist.get("layer2-bolded", 0)
    layer3 = layer_dist.get("layer3-highlighted", 0)
    layer4 = layer_dist.get("layer4-summary", 0)

    ui.style(f"\n📥 Layer 1 - Captured:     {layer1}", foreground="147")
    ui.style(f"✨ Layer 2 - Bolded:       {layer2}", foreground="yellow")
    ui.style(f"🎯 Layer 3 - Highlighted:  {layer3}", foreground="green")
    ui.style(f"📝 Layer 4 - Summarized:   {layer4}", foreground="blue")

    # Progression funnel
    if layer1 > 0:
        l2_pct = int((layer2 / layer1) * 100)
        l3_pct = int((layer3 / layer1) * 100)
        l4_pct = int((layer4 / layer1) * 100)

        ui.style("\n📊 Progression Funnel:", foreground="212", bold=True)
        ui.style(f"  Layer 1 → Layer 2: {l2_pct}%", foreground="yellow")
        ui.style(f"  Layer 1 → Layer 3: {l3_pct}%", foreground="green")
        ui.style(f"  Layer 1 → Layer 4: {l4_pct}%", foreground="blue")


def _show_actionability_stats(articles: list[dict]) -> None:
    """Display actionability distribution."""
    ui.style("\n" + "─" * 70, foreground="212")
    ui.style("ACTIONABILITY DISTRIBUTION", foreground="212", bold=True)
    ui.style("─" * 70, foreground="212")

    action_dist = calculate_actionability(articles)

    inspirational = action_dist.get("inspirational", 0)
    actionable = action_dist.get("actionable", 0)

    ui.style(f"\n💡 Inspirational:  {inspirational}", foreground="yellow")
    ui.style(f"🎯 Actionable:     {actionable}", foreground="green")

    total = inspirational + actionable
    if total > 0:
        actionable_pct = int((actionable / total) * 100)
        ui.style(f"\n✓ {actionable_pct}% of content is immediately actionable", foreground="green")


def run_stats_dashboard(tfp_only: bool = False, weekly: bool = False):
    """Display beautiful stats dashboard."""
    ui.header("Knowledge Pipeline Metrics", "📊")

    # Load data
    data = _load_stats_data(weekly)
    if data is None:
        return

    articles, total_articles, period = data

    # TFP Coverage Report
    if tfp_only or not weekly:
        _show_tfp_coverage_report(articles, total_articles, period)

    # Progressive Summarization Pipeline
    if not tfp_only:
        _show_layer_pipeline(articles)
        _show_actionability_stats(articles)


if __name__ == "__main__":
    import sys

    tfp_only = "--tfp" in sys.argv
    weekly = "--weekly" in sys.argv

    run_stats_dashboard(tfp_only=tfp_only, weekly=weekly)
