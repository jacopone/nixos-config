"""Unit tests for UI components."""

import subprocess


class TestGumUI:
    """Tests for GumUI class."""

    def test_choose_returns_selection(self, mocker):
        """Test that choose returns the selected option."""
        from readwise_basb.ui import ui

        # Mock successful selection using pytest-mock
        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(
            returncode=0, stdout="💾 Save to Readwise & tag with BASB\n"
        )

        options = [
            "💾 Save to Readwise & tag with BASB",
            "🗑️  Delete (remove from Chrome)",
            "✅ Keep in Chrome (mark reviewed)",
        ]

        result = ui.choose(options)

        assert result == "💾 Save to Readwise & tag with BASB"
        assert mock_run.called

        # Verify gum was called with correct arguments and TTY inheritance
        call_args, call_kwargs = mock_run.call_args
        assert call_kwargs["stdin"] is None  # Inherits from parent
        assert call_kwargs["stderr"] is None  # Inherits from parent
        assert call_kwargs["stdout"] == subprocess.PIPE  # Captured

        assert call_args[0][0] == "gum"
        assert call_args[0][1] == "choose"
        assert options[0] in call_args[0]

    def test_choose_returns_none_on_cancel(self, mocker):
        """Test that choose returns None when user cancels."""
        from readwise_basb.ui import ui

        # Mock cancelled selection (Ctrl+C)
        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=1, stdout="")  # Non-zero exit code

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    def test_choose_handles_empty_output(self, mocker):
        """Test that choose handles empty output gracefully."""
        from readwise_basb.ui import ui

        # Mock empty output
        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=0, stdout="")

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    def test_choose_handles_exception(self, mocker):
        """Test that choose handles exceptions gracefully."""
        from readwise_basb.ui import ui

        # Mock exception
        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.side_effect = Exception("Test exception")

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    def test_choose_multiple_selections(self, mocker):
        """Test that choose can handle multiple selections."""
        from readwise_basb.ui import ui

        # Mock multiple selections
        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=0, stdout="Option 1\nOption 2\n")

        options = ["Option 1", "Option 2", "Option 3"]
        result = ui.choose(options, multiple=True)

        assert result == ["Option 1", "Option 2"]

        # Verify --no-limit flag was passed
        args = mock_run.call_args[0][0]
        assert "--no-limit" in args

    def test_choose_empty_options(self):
        """Test that choose handles empty options list."""
        from readwise_basb.ui import ui

        result = ui.choose([])
        assert result is None

        result = ui.choose([], multiple=True)
        assert result == []

    def test_confirm_yes(self, mocker):
        """Test that confirm returns True on yes."""
        from readwise_basb.ui import ui

        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=0)

        result = ui.confirm("Delete this?")
        assert result is True

    def test_confirm_no(self, mocker):
        """Test that confirm returns False on no."""
        from readwise_basb.ui import ui

        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=1)

        result = ui.confirm("Delete this?")
        assert result is False

    def test_choose_with_keyboard_interrupt(self, mocker):
        """Test that choose handles KeyboardInterrupt (Ctrl+C)."""
        from readwise_basb.ui import ui

        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.side_effect = KeyboardInterrupt()

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    def test_choose_esc_returns_none(self, mocker):
        """Test that ESC (exit code 130) returns None."""
        from readwise_basb.ui import ui

        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_result = mocker.MagicMock()
        mock_result.returncode = 130  # Gum returns 130 for Ctrl+C
        mock_result.stdout = ""
        mock_run.return_value = mock_result

        options = ["Option 1", "Option 2"]
        result = ui.choose(options)

        assert result is None

    def test_choose_with_limit_and_height(self, mocker):
        """Test that choose passes limit and height parameters."""
        from readwise_basb.ui import ui

        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=0, stdout="Option 1\n")

        options = ["Option 1", "Option 2", "Option 3"]
        result = ui.choose(options, limit=5, height=15)

        assert result == "Option 1"

        # Verify parameters were passed
        args = mock_run.call_args[0][0]
        assert "--limit" in args
        assert "5" in args
        assert "--height" in args
        assert "15" in args

    def test_choose_stdin_stderr_inheritance(self, mocker):
        """Test that choose properly inherits stdin/stderr for TTY access."""
        from readwise_basb.ui import ui

        mock_run = mocker.patch("readwise_basb.ui.subprocess.run")
        mock_run.return_value = mocker.MagicMock(returncode=0, stdout="Test\n")

        ui.choose(["Test"])

        # Verify stdin and stderr are inherited (None), not captured
        call_kwargs = mock_run.call_args[1]
        assert call_kwargs["stdin"] is None, "stdin should be None to inherit from parent"
        assert call_kwargs["stderr"] is None, "stderr should be None to inherit from parent"
        assert "stdout" in call_kwargs, "stdout should be captured"
