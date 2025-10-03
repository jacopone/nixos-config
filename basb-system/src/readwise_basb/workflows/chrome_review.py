"""Chrome bookmarks review workflow."""

from datetime import datetime

from ..api import api
from ..chrome import ChromeBookmarks, suggest_tags_for_bookmark
from ..ui import ui


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
    folder: str | None = None,
    limit: int = 20,
    stats_only: bool = False,
    filter_broken: bool = True,
):
    """Run interactive bookmark review workflow."""

    if stats_only:
        show_bookmark_stats()
        return

    ui.header("Chrome Bookmarks Review", "🔖")

    try:
        chrome = ChromeBookmarks()
    except Exception as e:
        ui.error(f"Failed to initialize Chrome bookmarks: {e}")
        return

    # Load bookmarks
    ui.style("\n⠋ Loading Chrome bookmarks...", foreground="147")

    try:
        if folder:
            bookmarks = chrome.get_bookmarks_by_folder(folder, include_reviewed=False)
            ui.success(f"Loaded {len(bookmarks)} unreviewed bookmarks from '{folder}'\n")
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

    # Filter broken URLs from session only (faster than filtering all bookmarks)
    if filter_broken:
        ui.style(
            f"\n⠋ Checking {len(session_bookmarks)} URLs for accessibility...",
            foreground="147",
        )
        accessible_bookmarks = []
        broken_bookmarks = []

        try:
            for _i, bookmark in enumerate(session_bookmarks):
                url = bookmark.get("url", "")
                if not url:
                    broken_bookmarks.append(bookmark)
                    continue

                if chrome._is_url_accessible(url):
                    accessible_bookmarks.append(bookmark)
                else:
                    broken_bookmarks.append(bookmark)
        except Exception as e:
            ui.error(f"Error checking URLs: {e}")
            # Continue with all bookmarks if URL checking fails
            session_bookmarks = session_bookmarks
            accessible_bookmarks = session_bookmarks
            broken_bookmarks = []

        if broken_bookmarks:
            ui.warning(f"\n⚠ Found {len(broken_bookmarks)} broken/inaccessible URLs")
            ui.info("These bookmarks appear to be dead links (404, timeout, etc.)\n")

            # Show broken URLs
            for bookmark in broken_bookmarks[:5]:  # Show first 5
                title = bookmark.get("name", bookmark.get("title", "Untitled"))
                url = bookmark.get("url", "No URL")
                ui.style(f"  • {title}", foreground="red")
                ui.style(f"    {url}", foreground="147")

            if len(broken_bookmarks) > 5:
                ui.style(f"  ... and {len(broken_bookmarks) - 5} more", foreground="147")

            # Ask user what to do
            ui.style(
                "\n❓ What would you like to do with broken URLs?", foreground="212", bold=True
            )
            action = ui.choose(
                [
                    "🗑️  Delete from Chrome permanently",
                    "✅ Mark as reviewed (skip in future sessions)",
                    "⏭️  Keep in queue (check again next time)",
                    "👁️  Show me each one to decide",
                ]
            )

            # Debug: show what action was selected
            import logging

            logger = logging.getLogger(__name__)
            logger.debug(f"Broken URLs action selected: {repr(action)}")

            if not action:
                # User cancelled or gum failed
                ui.warning("\n⚠️  No action selected - keeping broken URLs in queue")
                ui.info("They will be checked again next session\n")
                session_bookmarks = accessible_bookmarks

            elif "Delete from Chrome" in action:
                # Mark all broken bookmarks for deletion
                ui.warning("\n🗑️  Marked for deletion")
                ui.info(f"   {len(broken_bookmarks)} broken URLs will be deleted at session end")
                ui.info("   (You'll be prompted to close Chrome before deletion)\n")

                for bookmark in broken_bookmarks:
                    chrome.mark_for_deletion(bookmark["id"])
                    chrome.save_reviewed(bookmark["id"])

                ui.success(f"✓ {len(broken_bookmarks)} bookmarks queued for deletion\n")
                session_bookmarks = accessible_bookmarks

            elif "Mark as reviewed" in action:
                for bookmark in broken_bookmarks:
                    chrome.save_reviewed(bookmark["id"])
                ui.success(f"✓ Marked {len(broken_bookmarks)} broken URLs as reviewed")
                ui.info("   They won't appear in future sessions\n")
                session_bookmarks = accessible_bookmarks

            elif "Keep in queue" in action:
                # Explicitly keep in queue
                ui.info(f"⏭️  Kept {len(broken_bookmarks)} broken URLs in queue")
                ui.info("   They will be checked again next session\n")
                session_bookmarks = accessible_bookmarks

            elif "Show me each one" in action:
                # Add broken bookmarks to session for manual review
                ui.info(f"👁️  Added {len(broken_bookmarks)} broken URLs to review queue")
                ui.info("   You'll review each one individually\n")
                session_bookmarks = accessible_bookmarks + broken_bookmarks

            else:
                # Unknown action - shouldn't happen but be safe
                ui.warning(f"\n⚠️  Unknown action: {action}")
                ui.info("   Keeping broken URLs in queue for next session\n")
                session_bookmarks = accessible_bookmarks
        else:
            ui.success("✓ All URLs are accessible\n")

    ui.info(f"Reviewing {len(session_bookmarks)} bookmarks (limit: {limit})")
    ui.info(f"{len(bookmarks) - len(session_bookmarks)} remaining for later\n")

    # Review statistics
    saved_to_readwise = 0
    deleted_count = 0
    kept_count = 0
    skipped_count = 0
    stopped_early = False

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
            age_str = f"{age_days} days ago" if age_days < 365 else f"{age_days // 365} years ago"
            ui.style(f"📅 Added {age_str}", foreground="147")

        # Suggest tags
        suggested_tags = suggest_tags_for_bookmark(bookmark)
        ui.style(f"\n💡 Suggested tags: {suggested_tags['basb_tag']}", foreground="green")
        if suggested_tags["tfp_tags"]:
            ui.style(f"   TFPs: {', '.join(suggested_tags['tfp_tags'])}", foreground="green")
        ui.style(f"   Source: {suggested_tags['source']}", foreground="147")

        # Action menu (gum choose will display the options interactively)
        actions = [
            "💾 Save to Readwise & tag with BASB",
            "🗑️  Delete (remove from Chrome)",
            "✅ Keep in Chrome (mark reviewed)",
            "⏭️  Skip for now",
            "🛑 Stop review session",
        ]

        action = ui.choose(actions)

        # Handle no action (user cancelled or gum failed)
        if not action:
            ui.warning("\n⚠️  No action selected")

            # Ask if user wants to stop or continue
            should_continue = ui.confirm("Continue to next bookmark?", default=True)
            if not should_continue:
                ui.warning("\n🛑 Stopping review session...")
                stopped_early = True
                break
            else:
                ui.info("⏭️  Skipping this bookmark...\n")
                skipped_count += 1
                continue

        # Debug: show selected action (only in debug mode)
        import logging

        logger = logging.getLogger(__name__)
        logger.debug(f"Bookmark action selected: {repr(action)}")

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
            if ui.confirm(f"⚠️  Mark '{title}' for deletion?", default=False):
                # Mark for deletion (will delete at end of session)
                chrome.mark_for_deletion(bookmark["id"])
                chrome.save_reviewed(bookmark["id"])
                deleted_count += 1
                ui.success("✓ Marked for deletion (will delete at end of session)")
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
            # User explicitly chose to stop
            ui.info("\n🛑 Session stopped by user\n")
            stopped_early = True
            break

    # Session summary
    ui.style("\n" + "═" * 60, foreground="212")

    if stopped_early:
        ui.header("Review Session Stopped", "🛑")
        ui.style("\n📊 PARTIAL SESSION SUMMARY:", foreground="212", bold=True)
    else:
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

    # Handle batch deletion of marked bookmarks
    deletion_queue = chrome.get_deletion_queue()
    if deletion_queue:
        ui.style("\n" + "─" * 60, foreground="147")
        ui.style(
            f"\n🗑️  {len(deletion_queue)} bookmarks marked for deletion",
            foreground="red",
            bold=True,
        )

        if ui.confirm("\nProceed with deletion? (Chrome must be closed)", default=True):
            # Check if Chrome is running
            if chrome.is_chrome_running():
                ui.warning("\n⚠️  Chrome is currently running")
                ui.info("Please close Chrome to proceed with deletion...\n")

                # Wait for Chrome to close (with timeout)
                ui.style("⏳ Waiting for Chrome to close (60 second timeout)...", foreground="147")
                if chrome.wait_for_chrome_close(timeout=60):
                    ui.success("\n✓ Chrome closed!")
                else:
                    ui.error("\n✗ Timeout waiting for Chrome to close")
                    ui.info("Bookmarks will remain marked for deletion")
                    ui.info("Run 'rwchrome' again later to complete deletion\n")
                    return

            # Delete the bookmarks
            ui.style("\n⠋ Deleting bookmarks from Chrome...", foreground="147")
            success, message = chrome.delete_bookmarks(deletion_queue)

            if success:
                ui.success(f"\n✓ {message}")
                chrome.clear_deletion_queue()
                ui.info("\n💡 You can now reopen Chrome")
            else:
                ui.error(f"\n✗ {message}")
        else:
            ui.info("\nDeletion postponed. Bookmarks remain marked for deletion")
            ui.info("Run 'rwchrome' again later to complete deletion")

    remaining = len(bookmarks) - total_processed
    if remaining > 0:
        ui.info(f"\n💡 {remaining} bookmarks remaining for next session")
        ui.info("   Run 'rwchrome' again to continue!")


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
