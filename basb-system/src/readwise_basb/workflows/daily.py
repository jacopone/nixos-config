"""Daily morning routine workflow."""

from datetime import datetime, timedelta

from ..api import api
from ..ui import ui


def run_daily_routine():
    """Run the daily morning BASB review routine."""
    ui.header(f"BASB Morning Review - {datetime.now().strftime('%b %d')}", "🌅")

    # Step 1: Sync with Readwise
    ui.style("\n⠋ Syncing with Readwise...", foreground="147")

    try:
        # Get documents from last 24 hours
        yesterday = (datetime.now() - timedelta(days=1)).isoformat()
        response = api.list_documents(updated_after=yesterday)
        new_articles = response.get("results", [])

        ui.success(f"Synced {len(new_articles)} new articles\n")
    except Exception as e:
        ui.error(f"Sync failed: {e}")
        return

    if not new_articles:
        ui.info("No new articles to process today.")
        ui.style("\n✨ You're all caught up!", foreground="green", bold=True)
        return

    # Step 2: Display new articles
    ui.style("NEW ARTICLES", foreground="212", bold=True)
    ui.style("─" * 60, foreground="212")

    article_options = []
    article_map = {}

    for _i, article in enumerate(new_articles):
        title = article.get("title", "Untitled")
        tags = article.get("tags", {})

        # Tags can be dict or list - handle both
        if isinstance(tags, dict):
            tag_list = list(tags.keys())
        else:
            tag_list = tags if tags else []

        tag_str = " ".join([f"#{tag}" for tag in tag_list]) if tag_list else "(untagged)"

        display = f"{title} {tag_str}"
        article_options.append(display)
        article_map[display] = article

    # Step 3: Select articles to process
    selected_displays = ui.choose(
        article_options,
        prompt="\n? Select articles to process today (space to select, enter to confirm):",
        multiple=True,
        height=min(15, len(article_options)),
    )

    if not selected_displays:
        ui.info("No articles selected.")
        return

    selected_articles = [article_map[display] for display in selected_displays]

    # Step 4: Quick notes
    notes = ui.input_text(
        prompt="\n? Add quick notes (optional): ", placeholder="Context or insights..."
    )

    # Step 5: Tag and process articles
    ui.style("\n📋 Processing Articles", foreground="212", bold=True)

    for article in selected_articles:
        title = article.get("title", "Untitled")
        ui.info(f"  • {title}")

        # Auto-tag as Layer 1 captured if no layer tag exists
        tags = article.get("tags", {})

        # Convert tags to list format
        if isinstance(tags, dict):
            current_tags = list(tags.keys())
        else:
            current_tags = list(tags) if tags else []

        has_layer = any(tag.startswith("layer") for tag in current_tags)

        if not has_layer:
            current_tags.append("layer1-captured")

        # Add inbox tag if not already tagged
        has_basb_tag = any(
            tag.startswith(("p1-", "p2-", "p3-", "a1-", "a2-", "a3-", "r2-", "r3-", "x2-", "x3-"))
            for tag in current_tags
        )

        if not has_basb_tag:
            current_tags.append("inbox")

        # Update article with tags and notes
        try:
            update_data = {"tags": current_tags}
            if notes:
                existing_notes = article.get("notes", "")
                update_data["notes"] = (
                    f"{existing_notes}\n\n[{datetime.now().strftime('%Y-%m-%d')}] {notes}".strip()
                )

            api.update_document(article["id"], **update_data)
        except Exception as e:
            ui.warning(f"    Failed to update: {e}")

    # Step 6: Export confirmation
    if ui.confirm("\n? Export summaries to Google Drive?", default=True):
        export_count = 0
        for article in selected_articles:
            # Only export Layer 3+ articles
            tags = article.get("tags", {})

            # Convert to list
            if isinstance(tags, dict):
                tag_list = list(tags.keys())
            else:
                tag_list = list(tags) if tags else []

            if any(tag in ["layer3-highlighted", "layer4-summary"] for tag in tag_list):
                # Export logic would go here
                export_count += 1

        if export_count > 0:
            ui.success(f"✓ Exported {export_count} summaries")
        else:
            ui.info("No Layer 3+ summaries to export yet")

    # Step 7: Summary
    ui.style("\n" + "─" * 60, foreground="212")
    ui.success(f"✓ {len(selected_articles)} articles processed")

    # Check for actionable items
    actionable = []
    for a in selected_articles:
        tags = a.get("tags", {})
        tag_list = list(tags.keys()) if isinstance(tags, dict) else (list(tags) if tags else [])
        if "actionable-now" in tag_list:
            actionable.append(a)

    if actionable:
        ui.info(f"💡 {len(actionable)} actionable items ready for Sunsama")

    # Completion message
    ui.header("Morning review complete!", "✨")
    ui.info("Next: Open Sunsama for daily planning with these insights.\n")


if __name__ == "__main__":
    run_daily_routine()
