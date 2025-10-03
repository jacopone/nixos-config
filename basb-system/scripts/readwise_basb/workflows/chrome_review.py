"""Chrome bookmarks review workflow."""

from typing import Optional
from datetime import datetime

from ..ui import ui
from ..api import api
from ..chrome import ChromeBookmarks, suggest_tags_for_bookmark


def show_bookmark_stats():
    """Display bookmark statistics."""
    ui.header("Chrome Bookmarks Statistics", "📊")

    chrome = ChromeBookmarks()

    try:
        stats = chrome.get_stats()

        ui.style("\n" + "─" * 60, foreground="212")
        ui.style("OVERALL PROGRESS", foreground="212", bold=True)
        ui.style("─" * 60, foreground="212")

        total = stats["total"]
        reviewed = stats["reviewed"]
        unreviewed = stats["unreviewed"]
        progress = stats["review_progress"]

        # Progress bar
        bar_width = 40
        filled = int((reviewed / total) * bar_width) if total > 0 else 0
        bar = "█" * filled + "░" * (bar_width - filled)

        ui.style(f"\nTotal Bookmarks:     {total}", foreground="147")
        ui.style(f"Reviewed:            {reviewed}", foreground="green")
        ui.style(f"Unreviewed:          {unreviewed}", foreground="yellow")
        ui.style(f"\nProgress: {bar} {progress}%", foreground="212")

        # Top folders
        ui.style("\n" + "─" * 60, foreground="212")
        ui.style("TOP UNREVIEWED FOLDERS", foreground="212", bold=True)
        ui.style("─" * 60, foreground="212")

        for folder_info in stats["top_unreviewed_folders"]:
            name = folder_info["name"]
            unrev = folder_info["unreviewed"]
            tot = folder_info["total"]

            ui.style(f"{name:<40} {unrev:>3}/{tot:>3} unreviewed", foreground="147")

        ui.style("\n" + "─" * 60, foreground="212")
        ui.success(f"✓ Analyzed {total} bookmarks across {stats['folders']} folders")

    except Exception as e:
        ui.error(f"Error loading statistics: {e}")


def run_bookmark_review(
    folder: Optional[str] = None,
    limit: int = 20,
    stats_only: bool = False,
):
    """Run interactive bookmark review workflow."""

    if stats_only:
        show_bookmark_stats()
        return

    ui.header("Chrome Bookmarks Review", "🔖")

    chrome = ChromeBookmarks()

    # Load bookmarks
    ui.style("\n⠋ Loading Chrome bookmarks...", foreground="147")

    try:
        if folder:
            bookmarks = chrome.get_bookmarks_by_folder(folder, include_reviewed=False)
            ui.success(
                f"Loaded {len(bookmarks)} unreviewed bookmarks from '{folder}'\n"
            )
        else:
            bookmarks = chrome.get_all_bookmarks(include_reviewed=False)
            ui.success(f"Loaded {len(bookmarks)} unreviewed bookmarks\n")

    except Exception as e:
        ui.error(f"Failed to load bookmarks: {e}")
        return

    if not bookmarks:
        ui.info("No unreviewed bookmarks found!")
        ui.success("\n✓ You're all caught up!")
        return

    # Limit bookmarks for this session
    session_bookmarks = bookmarks[:limit]

    ui.info(f"Reviewing {len(session_bookmarks)} bookmarks (limit: {limit})")
    ui.info(f"{len(bookmarks) - len(session_bookmarks)} remaining for later\n")

    # Review statistics
    saved_to_readwise = 0
    deleted_count = 0
    kept_count = 0
    skipped_count = 0

    # Process each bookmark
    for i, bookmark in enumerate(session_bookmarks, 1):
        ui.style("\n" + "═" * 60, foreground="212")
        ui.style(f"Bookmark {i}/{len(session_bookmarks)}", foreground="212", bold=True)
        ui.style("═" * 60, foreground="212")

        # Display bookmark info
        title = bookmark["title"]
        url = bookmark["url"]
        folder = bookmark["folder"]
        date_added = bookmark["date_added"]

        ui.style(f"\n📄 {title}", foreground="147", bold=True)
        ui.style(f"🔗 {url}", foreground="blue")
        ui.style(f"📁 {folder}", foreground="yellow")

        if date_added:
            age_days = (datetime.now() - date_added).days
            age_str = (
                f"{age_days} days ago"
                if age_days < 365
                else f"{age_days // 365} years ago"
            )
            ui.style(f"📅 Added {age_str}", foreground="147")

        # Suggest tags
        suggested_tags = suggest_tags_for_bookmark(bookmark)
        ui.style(
            f"\n💡 Suggested tags: {suggested_tags['basb_tag']}", foreground="green"
        )
        if suggested_tags["tfp_tags"]:
            ui.style(
                f"   TFPs: {', '.join(suggested_tags['tfp_tags'])}", foreground="green"
            )
        ui.style(f"   Source: {suggested_tags['source']}", foreground="147")

        # Action menu
        actions = [
            "💾 Save to Readwise & tag with BASB",
            "🗑️  Delete (remove from Chrome)",
            "✅ Keep in Chrome (mark reviewed)",
            "⏭️  Skip for now",
            "🛑 Stop review session",
        ]

        action = ui.choose(actions, prompt="\n? What would you like to do?")

        if not action:
            ui.info("No action selected, skipping...")
            continue

        if "Save to Readwise" in action:
            # Save to Readwise
            try:
                ui.style("\n⠋ Saving to Readwise...", foreground="147")

                # Build tags
                tags = [suggested_tags["basb_tag"]]
                tags.extend(suggested_tags["tfp_tags"])
                tags.append(suggested_tags["layer_tag"])
                tags.append(suggested_tags["action_tag"])
                tags.append("source-chrome")

                # Save to Readwise
                api.save_document(
                    url=url,
                    title=title,
                    tags=tags,
                    location="later",  # Add to "Later" list
                )

                chrome.save_reviewed(bookmark["id"])
                saved_to_readwise += 1
                ui.success(f"✓ Saved to Readwise with tags: {', '.join(tags)}")

            except Exception as e:
                ui.error(f"✗ Failed to save: {e}")

        elif "Delete" in action:
            # Confirm deletion
            if ui.confirm(f"⚠️  Delete '{title}' from Chrome?", default=False):
                # Note: We don't actually delete from Chrome JSON
                # Just mark as reviewed so it won't show up again
                chrome.save_reviewed(bookmark["id"])
                deleted_count += 1
                ui.success("✓ Marked for deletion (review manually in Chrome)")
            else:
                ui.info("Delete cancelled")

        elif "Keep in Chrome" in action:
            # Just mark as reviewed
            chrome.save_reviewed(bookmark["id"])
            kept_count += 1
            ui.success("✓ Marked as reviewed, keeping in Chrome")

        elif "Skip" in action:
            skipped_count += 1
            ui.info("⏭️  Skipped for later")

        elif "Stop" in action:
            ui.warning("\n🛑 Stopping review session...")
            break

    # Session summary
    ui.style("\n" + "═" * 60, foreground="212")
    ui.header("Review Session Complete!", "✨")

    ui.style("\n📊 SESSION SUMMARY:", foreground="212", bold=True)
    ui.style(f"  • Saved to Readwise: {saved_to_readwise}", foreground="green")
    ui.style(f"  • Marked for deletion: {deleted_count}", foreground="red")
    ui.style(f"  • Kept in Chrome: {kept_count}", foreground="blue")
    ui.style(f"  • Skipped: {skipped_count}", foreground="yellow")

    total_processed = saved_to_readwise + deleted_count + kept_count
    ui.style(
        f"\n✓ Processed {total_processed}/{len(session_bookmarks)} bookmarks",
        foreground="green",
    )

    remaining = len(bookmarks) - total_processed
    if remaining > 0:
        ui.info(f"\n💡 {remaining} bookmarks remaining for next session")
        ui.info("   Run 'chrome-review' again to continue!")


if __name__ == "__main__":
    import sys

    folder = None
    limit = 20
    stats_only = False

    if "--stats" in sys.argv:
        stats_only = True

    if "--folder" in sys.argv:
        idx = sys.argv.index("--folder")
        if idx + 1 < len(sys.argv):
            folder = sys.argv[idx + 1]

    if "--limit" in sys.argv:
        idx = sys.argv.index("--limit")
        if idx + 1 < len(sys.argv):
            limit = int(sys.argv[idx + 1])

    run_bookmark_review(folder=folder, limit=limit, stats_only=stats_only)
