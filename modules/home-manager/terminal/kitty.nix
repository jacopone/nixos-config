# Kitty terminal emulator configuration
{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    # PROGRAMMING FONT WITH LIGATURES
    # JetBrains Mono Nerd Font provides:
    # - Programming ligatures (== -> ≡, != -> ≠, -> -> →)
    # - Nerd Font icons for file types, git status, etc.
    # - Better readability for code with optimized character spacing
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    settings = {
      # ═══════════════════════════════════════════════════════════════════
      # SHELL CONFIGURATION
      # ═══════════════════════════════════════════════════════════════════
      shell = "${pkgs.fish}/bin/fish";

      # TERMINAL IDENTIFICATION
      # Proper terminal identification for better compatibility
      term = "xterm-kitty";

      # ═══════════════════════════════════════════════════════════════════
      # PERFORMANCE OPTIMIZATIONS FOR AI DEVELOPMENT
      # ═══════════════════════════════════════════════════════════════════

      # GPU & RENDERING PERFORMANCE
      # Critical for handling long Claude Code/Plandex outputs
      sync_to_monitor = false; # Disable vsync for better performance
      repaint_delay = 10; # Faster repaints (default: 10ms)
      input_delay = 3; # More responsive typing during heavy output

      # MEMORY MANAGEMENT FOR AI SESSIONS
      # Large scrollback for AI conversations and debugging sessions
      scrollback_lines = 50000; # 50k lines for extensive AI conversations
      scrollback_pager_history_size = 10; # Remember pager positions

      # ═══════════════════════════════════════════════════════════════════
      # ADVANCED TYPOGRAPHY & LIGATURES
      # ═══════════════════════════════════════════════════════════════════

      # FONT CONFIGURATION
      # Comprehensive font family setup with fallbacks
      font_family = "JetBrainsMono Nerd Font";
      bold_font = "JetBrainsMono Nerd Font Bold";
      italic_font = "JetBrainsMono Nerd Font Italic";
      bold_italic_font = "JetBrainsMono Nerd Font Bold Italic";

      # LIGATURE CONTROL
      # Show ligatures everywhere except at cursor position for better editing
      disable_ligatures = "cursor";

      # ADVANCED TEXT RENDERING
      # Better Unicode handling for international characters and symbols
      text_composition_strategy = "1.0 0";

      # ═══════════════════════════════════════════════════════════════════
      # ENHANCED CATPPUCCIN MOCHA THEME
      # ═══════════════════════════════════════════════════════════════════

      # CORE THEME COLORS
      background = "#1e1e2e"; # Catppuccin Base
      foreground = "#cdd6f4"; # Catppuccin Text
      cursor = "#f5e0dc"; # Catppuccin Rosewater

      # SELECTION COLORS (Enhanced for better contrast)
      selection_background = "#45475a"; # Surface1 for better readability
      selection_foreground = "#cdd6f4"; # Text

      # URL & LINK COLORS
      url_color = "#74c7ec"; # Sapphire for better visibility
      url_style = "curly"; # Underline style for URLs

      # STANDARD TERMINAL COLORS (Catppuccin Palette)
      color0 = "#45475a"; # Surface1
      color8 = "#585b70"; # Surface2
      color1 = "#f38ba8"; # Red
      color9 = "#f38ba8"; # Bright Red
      color2 = "#a6e3a1"; # Green
      color10 = "#a6e3a1"; # Bright Green
      color3 = "#f9e2af"; # Yellow
      color11 = "#f9e2af"; # Bright Yellow
      color4 = "#89b4fa"; # Blue
      color12 = "#89b4fa"; # Bright Blue
      color5 = "#f5c2e7"; # Pink
      color13 = "#f5c2e7"; # Bright Pink
      color6 = "#94e2d5"; # Teal
      color14 = "#94e2d5"; # Bright Teal
      color7 = "#bac2de"; # Subtext1
      color15 = "#a6adc8"; # Subtext0

      # ═══════════════════════════════════════════════════════════════════
      # ADVANCED TAB MANAGEMENT
      # ═══════════════════════════════════════════════════════════════════

      # TAB BAR CONFIGURATION
      tab_bar_edge = "bottom"; # Tabs at bottom like VS Code
      tab_bar_style = "powerline"; # Powerline style for modern look
      tab_powerline_style = "slanted"; # Slanted powerline segments
      tab_title_template = "{index}: {title[title.rfind('/')+1:]}"; # Show only folder name

      # TAB COLORS (Catppuccin themed)
      active_tab_background = "#89b4fa"; # Blue for active tab
      active_tab_foreground = "#1e1e2e"; # Base for contrast
      inactive_tab_background = "#45475a"; # Surface1 for inactive
      inactive_tab_foreground = "#cdd6f4"; # Text

      # ═══════════════════════════════════════════════════════════════════
      # WINDOW & LAYOUT MANAGEMENT
      # ═══════════════════════════════════════════════════════════════════

      # WINDOW SIZE & BEHAVIOR
      remember_window_size = true; # Remember size across sessions
      initial_window_width = 120; # Wider for side-by-side code
      initial_window_height = 35; # Taller for more content

      # DEFAULT DIRECTORY
      chdir = "~/nixos-config"; # New windows start here instead of last CWD

      # WINDOW DECORATIONS
      window_border_width = "1px"; # Subtle border
      window_margin_width = 0; # No margin for max space
      window_padding_width = 4; # Small padding for comfort

      # ACTIVE/INACTIVE WINDOW DISTINCTION
      active_border_color = "#89b4fa"; # Blue border for active
      inactive_border_color = "#585b70"; # Gray for inactive

      # ═══════════════════════════════════════════════════════════════════
      # CURSOR & VISUAL ENHANCEMENTS
      # ═══════════════════════════════════════════════════════════════════

      # CURSOR BEHAVIOR
      cursor_blink_interval = 0.5; # Moderate blink speed
      cursor_stop_blinking_after = 15.0; # Stop after 15 seconds of inactivity
      cursor_shape = "block"; # Block cursor (classic terminal)

      # VISUAL FEEDBACK
      visual_bell_duration = 0.1; # Brief flash instead of beep
      visual_bell_color = "#f9e2af"; # Yellow flash for visibility

      # TRANSPARENCY & EFFECTS
      background_opacity = 0.95; # Subtle transparency for overlays

      # ═══════════════════════════════════════════════════════════════════
      # COPY/PASTE & MOUSE BEHAVIOR
      # ═══════════════════════════════════════════════════════════════════

      # CLIPBOARD INTEGRATION
      copy_on_select = "clipboard"; # Auto-copy selection to clipboard
      strip_trailing_spaces = "smart"; # Clean copying of AI outputs

      # MOUSE BEHAVIOR
      click_interval = -1.0; # Disable double-click timeout
      mouse_hide_wait = 3.0; # Hide mouse after 3 seconds
      open_url_with = "default"; # Use system default browser
      open_url_modifiers = "kitty_mod"; # Require modifier to click URLs

      # RECTANGLE SELECTION (Great for code blocks)
      rectangle_select_modifiers = "ctrl+alt"; # Rectangular selection mode

      # ═══════════════════════════════════════════════════════════════════
      # GNOME WAYLAND INTEGRATION
      # ═══════════════════════════════════════════════════════════════════

      # WAYLAND OPTIMIZATIONS
      linux_display_server = "wayland"; # Native Wayland support
      wayland_titlebar_color = "background"; # Match titlebar to theme

      # SYSTEM INTEGRATION
      confirm_os_window_close = 2; # Confirm before closing multiple tabs

      # ═══════════════════════════════════════════════════════════════════
      # SHELL INTEGRATION & FEATURES
      # ═══════════════════════════════════════════════════════════════════

      # SHELL INTEGRATION
      shell_integration = "enabled"; # Enhanced shell features

      # PATH & FILE DETECTION
      path_style = "single"; # Underline file paths in output

      # FONT SIZE MANAGEMENT
      font_size = 12.1; # Start slightly larger than base
    };

    # ═══════════════════════════════════════════════════════════════════
    # KEYBOARD SHORTCUTS FOR AI DEVELOPMENT WORKFLOW
    # ═══════════════════════════════════════════════════════════════════
    keybindings = {
      # TAB MANAGEMENT
      "ctrl+shift+t" = "new_tab_with_cwd"; # New tab in current directory
      "ctrl+shift+w" = "close_tab"; # Close current tab
      "ctrl+shift+right" = "next_tab"; # Next tab
      "ctrl+shift+left" = "previous_tab"; # Previous tab

      # WINDOW SPLITTING (Great for comparing AI outputs)
      "ctrl+shift+d" = "launch --location=hsplit"; # Horizontal split
      "ctrl+shift+shift+d" = "launch --location=vsplit"; # Vertical split

      # QUICK TOOLS ACCESS
      "ctrl+shift+y" = "new_tab yazi"; # Quick file manager
      "ctrl+shift+m" = "new_tab tmux"; # New tmux session
      "ctrl+shift+h" = "new_tab htop"; # System monitor

      # FONT SIZE CONTROL
      "ctrl+plus" = "change_font_size all +1.0"; # Increase font
      "ctrl+minus" = "change_font_size all -1.0"; # Decrease font
      "ctrl+0" = "change_font_size all 0"; # Reset font size

      # SCROLLBACK NAVIGATION (Essential for long AI conversations)
      "ctrl+shift+page_up" = "scroll_page_up"; # Page up in scrollback
      "ctrl+shift+page_down" = "scroll_page_down"; # Page down in scrollback
      "ctrl+shift+home" = "scroll_home"; # Jump to top
      "ctrl+shift+end" = "scroll_end"; # Jump to bottom

      # CLIPBOARD OPERATIONS
      "ctrl+shift+c" = "copy_to_clipboard"; # Copy selection
      "ctrl+shift+v" = "paste_from_clipboard"; # Paste
    };
  };

  # Note: Chrome/Chromium policies moved to system-level configuration
  # in hosts/nixos/default.nix to avoid conflicts and ensure proper
  # policy application. Extensions are managed there as well.

  # Enhanced Starship prompt configuration with Nerd Font symbols
}
