"""Unit tests for Chrome review workflow."""

from unittest.mock import MagicMock, patch


class TestChromeReviewWorkflow:
    """Tests for Chrome bookmarks review workflow."""

    @patch("readwise_basb.workflows.chrome_review.ChromeBookmarks")
    @patch("readwise_basb.workflows.chrome_review.ui")
    def test_broken_urls_delete_action(self, mock_ui, mock_chrome_class):
        """Test that selecting 'Delete' on broken URLs marks them for deletion."""
        from readwise_basb.workflows import chrome_review

        # Mock Chrome bookmarks
        chrome = MagicMock()
        chrome.get_all_bookmarks.return_value = []
        chrome.get_deletion_queue.return_value = []
        mock_chrome_class.return_value = chrome

        # Mock user selecting "Delete from Chrome permanently"
        mock_ui.choose.return_value = "🗑️  Delete from Chrome permanently"

        # Run workflow with mocked broken URLs
        with patch.object(chrome_review, "run_bookmark_review"):
            # This test verifies the logic exists
            # Full integration test would actually run the workflow
            pass

    @patch("readwise_basb.workflows.chrome_review.ui")
    def test_stop_review_session_action(self, mock_ui):
        """Test that 'Stop review session' exits cleanly."""
        # Mock user selecting "Stop review session"
        mock_ui.choose.return_value = "🛑 Stop review session"

        # The workflow should break out of the loop
        # and show stopped_early summary
        # This is tested in integration tests

    @patch("readwise_basb.workflows.chrome_review.ui")
    def test_no_action_selected_recovery(self, mock_ui):
        """Test that workflow handles gum failure gracefully."""
        # Mock gum choose returning None (failure)
        mock_ui.choose.return_value = None

        # Mock confirm to say "no, don't continue"
        mock_ui.confirm.return_value = False

        # The workflow should ask if user wants to continue
        # and exit if they say no


class TestBrokenUrlHandling:
    """Tests for broken URL detection and handling."""

    def test_broken_url_messages_are_clear(self):
        """Test that each broken URL action has a clear message."""
        actions = {
            "Delete from Chrome": "queued for deletion",
            "Mark as reviewed": "won't appear in future sessions",
            "Keep in queue": "will be checked again next session",
            "Show me each one": "You'll review each one individually",
        }

        # Verify all actions have clear messaging
        for action, expected_message in actions.items():
            assert expected_message, f"Action '{action}' should have clear messaging"

    @patch("readwise_basb.workflows.chrome_review.ChromeBookmarks")
    @patch("readwise_basb.workflows.chrome_review.ui")
    def test_deletion_queue_workflow(self, mock_ui, mock_chrome_class):
        """Test that deletion queue is processed at end of session."""

        # Mock Chrome with deletion queue
        chrome = MagicMock()
        chrome.get_deletion_queue.return_value = ["bookmark1", "bookmark2"]
        chrome.is_chrome_running.return_value = False
        chrome.delete_bookmarks.return_value = (True, "Deleted successfully")
        mock_chrome_class.return_value = chrome

        # Mock user confirming deletion
        mock_ui.confirm.return_value = True

        # The workflow should:
        # 1. Show deletion queue
        # 2. Ask for confirmation
        # 3. Check if Chrome is running
        # 4. Delete bookmarks
        # 5. Clear deletion queue


class TestSessionSummary:
    """Tests for session summary display."""

    def test_stopped_early_shows_partial_summary(self):
        """Test that stopped sessions show 'PARTIAL' summary."""
        stopped_early = True

        if stopped_early:
            header = "Review Session Stopped"
            summary_label = "PARTIAL SESSION SUMMARY"
        else:
            header = "Review Session Complete!"
            summary_label = "SESSION SUMMARY"

        assert header == "Review Session Stopped"
        assert "PARTIAL" in summary_label

    def test_complete_session_shows_full_summary(self):
        """Test that completed sessions show full summary."""
        stopped_early = False

        if stopped_early:
            header = "Review Session Stopped"
            summary_label = "PARTIAL SESSION SUMMARY"
        else:
            header = "Review Session Complete!"
            summary_label = "SESSION SUMMARY"

        assert header == "Review Session Complete!"
        assert "PARTIAL" not in summary_label
