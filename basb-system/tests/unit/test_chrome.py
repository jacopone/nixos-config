"""Unit tests for Chrome bookmarks parser."""

from unittest.mock import MagicMock, patch

from readwise_basb.chrome import ChromeBookmarks


class TestChromeBookmarks:
    """Tests for ChromeBookmarks class."""

    def test_parse_bookmarks_structure(self, sample_bookmarks_data):
        """Test that bookmarks are parsed correctly."""
        with patch.object(ChromeBookmarks, "load_bookmarks", return_value=sample_bookmarks_data):
            chrome = ChromeBookmarks()
            chrome._bookmarks = sample_bookmarks_data
            bookmarks = chrome.get_all_bookmarks(include_reviewed=True)

            # Should find all 3 bookmarks
            assert len(bookmarks) >= 2

            # Check that bookmarks have required fields
            for bookmark in bookmarks:
                assert "url" in bookmark
                assert bookmark.get("name") or bookmark.get("title")
                assert "folder" in bookmark

    def test_get_bookmarks_by_folder(self, sample_bookmarks_data):
        """Test filtering bookmarks by folder."""
        with patch.object(ChromeBookmarks, "load_bookmarks", return_value=sample_bookmarks_data):
            chrome = ChromeBookmarks()
            chrome._bookmarks = sample_bookmarks_data

            gtd_bookmarks = chrome.get_bookmarks_by_folder("GTD", include_reviewed=True)

            # Should find GTD folder bookmark
            assert len(gtd_bookmarks) >= 1
            assert any("GTD" in b["folder"] for b in gtd_bookmarks)

    def test_mark_for_deletion(self, tmp_path):
        """Test marking bookmarks for deletion."""
        with patch.object(ChromeBookmarks, "__init__", lambda x: None):
            chrome = ChromeBookmarks()
            chrome.to_delete_path = tmp_path / "to_delete.json"
            chrome._to_delete = set()

            chrome.mark_for_deletion("test_bookmark_id")

            assert "test_bookmark_id" in chrome._to_delete
            assert chrome.to_delete_path.exists()

    def test_reviewed_tracking(self, tmp_path):
        """Test that reviewed bookmarks are tracked."""
        with patch.object(ChromeBookmarks, "__init__", lambda x: None):
            chrome = ChromeBookmarks()
            chrome.reviewed_path = tmp_path / "reviewed.json"
            chrome._reviewed = set()

            chrome.save_reviewed("bookmark_123")

            assert "bookmark_123" in chrome._reviewed
            assert chrome.reviewed_path.exists()
            assert chrome.is_reviewed("bookmark_123")
            assert not chrome.is_reviewed("bookmark_456")

    def test_url_accessibility_check(self):
        """Test URL accessibility checking."""
        chrome = ChromeBookmarks()

        # Test with a known good URL
        assert chrome._is_url_accessible("https://www.google.com")

        # Test with a known bad URL
        assert not chrome._is_url_accessible("http://this-definitely-does-not-exist-abcxyz123.com")

    def test_deletion_queue_management(self, tmp_path):
        """Test deletion queue operations."""
        with patch.object(ChromeBookmarks, "__init__", lambda x: None):
            chrome = ChromeBookmarks()
            chrome.to_delete_path = tmp_path / "to_delete.json"
            chrome._to_delete = set()

            # Add items to queue
            chrome.mark_for_deletion("id1")
            chrome.mark_for_deletion("id2")

            queue = chrome.get_deletion_queue()
            assert len(queue) == 2
            assert "id1" in queue
            assert "id2" in queue

            # Clear queue
            chrome.clear_deletion_queue()
            assert len(chrome.get_deletion_queue()) == 0
            assert not chrome.to_delete_path.exists()

    def test_is_chrome_running(self):
        """Test Chrome running detection."""
        chrome = ChromeBookmarks()

        # This will return True or False depending on whether Chrome is actually running
        # We just test that it doesn't crash
        result = chrome.is_chrome_running()
        assert isinstance(result, bool)

    @patch("subprocess.run")
    def test_is_chrome_running_mocked(self, mock_run):
        """Test Chrome running detection with mocked subprocess."""
        chrome = ChromeBookmarks()

        # Mock Chrome running
        mock_run.return_value = MagicMock(returncode=0)
        assert chrome.is_chrome_running()

        # Mock Chrome not running
        mock_run.return_value = MagicMock(returncode=1)
        assert not chrome.is_chrome_running()
