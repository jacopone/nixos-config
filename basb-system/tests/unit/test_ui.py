"""Unit tests for UI components."""

from unittest.mock import MagicMock, patch

from readwise_basb.ui import ui


class TestGumUI:
    """Tests for GumUI class."""

    @patch("readwise_basb.ui.subprocess.run")
    @patch("readwise_basb.ui.sys.stdin")
    @patch("readwise_basb.ui.sys.stderr")
    def test_choose_returns_selection(self, mock_stderr, mock_stdin, mock_run):
        """Test that choose returns the selected option."""
        # Mock successful selection
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = "💾 Save to Readwise & tag with BASB\n"
        mock_run.return_value = mock_result

        options = [
            "💾 Save to Readwise & tag with BASB",
            "🗑️  Delete (remove from Chrome)",
            "✅ Keep in Chrome (mark reviewed)",
        ]

        result = ui.choose(options)

        assert result == "💾 Save to Readwise & tag with BASB"
        assert mock_run.called

        # Verify gum was called with correct arguments
        args = mock_run.call_args[0][0]
        assert args[0] == "gum"
        assert args[1] == "choose"
        assert options[0] in args

    @patch("readwise_basb.ui.subprocess.run")
    def test_choose_returns_none_on_cancel(self, mock_run):
        """Test that choose returns None when user cancels."""
        # Mock cancelled selection (Ctrl+C)
        mock_run.return_value = MagicMock(returncode=1, stdout="")  # Non-zero exit code

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    @patch("readwise_basb.ui.subprocess.run")
    def test_choose_handles_empty_output(self, mock_run):
        """Test that choose handles empty output gracefully."""
        # Mock empty output
        mock_run.return_value = MagicMock(returncode=0, stdout="")

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    @patch("readwise_basb.ui.subprocess.run")
    def test_choose_handles_exception(self, mock_run):
        """Test that choose handles exceptions gracefully."""
        # Mock exception
        mock_run.side_effect = Exception("Test exception")

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    @patch("readwise_basb.ui.subprocess.run")
    @patch("readwise_basb.ui.sys.stdin")
    @patch("readwise_basb.ui.sys.stderr")
    def test_choose_multiple_selections(self, mock_stderr, mock_stdin, mock_run):
        """Test that choose can handle multiple selections."""
        # Mock multiple selections
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = "Option 1\nOption 2\n"
        mock_run.return_value = mock_result

        options = ["Option 1", "Option 2", "Option 3"]
        result = ui.choose(options, multiple=True)

        assert result == ["Option 1", "Option 2"]

    def test_choose_empty_options(self):
        """Test that choose handles empty options list."""
        result = ui.choose([])
        assert result is None

        result = ui.choose([], multiple=True)
        assert result == []

    @patch("readwise_basb.ui.subprocess.run")
    def test_confirm_yes(self, mock_run):
        """Test that confirm returns True on yes."""
        mock_run.return_value = MagicMock(returncode=0)

        result = ui.confirm("Delete this?")
        assert result is True

    @patch("readwise_basb.ui.subprocess.run")
    def test_confirm_no(self, mock_run):
        """Test that confirm returns False on no."""
        mock_run.return_value = MagicMock(returncode=1)

        result = ui.confirm("Delete this?")
        assert result is False
