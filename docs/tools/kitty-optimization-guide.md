---
status: active
created: 2025-10-08
updated: 2025-10-08
type: guide
lifecycle: persistent
---

# 🚀 Ultimate Kitty Terminal Optimization Guide

This document explains every optimization applied to your Kitty terminal configuration, designed specifically for AI-powered development workflows with Claude Code, Plandex, and modern CLI tools.

## 📖 Table of Contents

- [Font & Typography](#font--typography)
- [Performance Optimizations](#performance-optimizations)
- [Theme & Visual Design](#theme--visual-design)
- [Tab Management](#tab-management)
- [Window Management](#window-management)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Mouse & Clipboard](#mouse--clipboard)
- [System Integration](#system-integration)
- [Learning Resources](#learning-resources)

## 🔤 Font & Typography

### **JetBrains Mono Nerd Font**
```nix
font = {
  name = "JetBrains Mono Nerd Font";
  size = 11;
};
```

**What it does:**
- **Programming ligatures**: Transforms `==` into `≡`, `!=` into `≠`, `->` into `→`
- **Nerd Font icons**: Shows file type icons in `eza`, git symbols, and more
- **Better readability**: Optimized character spacing and height for code

**Why it matters for your workflow:**
- Makes code more readable with mathematical symbols
- Integrates perfectly with your modern CLI tools (`eza`, `yazi`, etc.)
- Reduces eye strain during long coding sessions

### **Advanced Font Configuration**
```nix
font_family = "JetBrains Mono Nerd Font";
bold_font = "JetBrains Mono Nerd Font Bold";
italic_font = "JetBrains Mono Nerd Font Italic";
disable_ligatures = "cursor";
```

**Learning point:** `disable_ligatures = "cursor"` shows actual characters when editing (so you see `!=` not `≠` where your cursor is) but displays ligatures everywhere else.

## ⚡ Performance Optimizations

### **GPU & Rendering Performance**
```nix
sync_to_monitor = false;    # Disable vsync
repaint_delay = 10;         # 10ms repaint delay
input_delay = 3;            # 3ms input delay
```

**What this solves:**
- **Long Claude Code outputs**: When AI tools generate extensive text, the terminal stays responsive
- **Reduced input lag**: Your typing appears instantly even during heavy operations
- **Better performance**: Less GPU overhead for faster rendering

**Technical explanation:**
- `sync_to_monitor = false` decouples rendering from monitor refresh rate
- Lower delays mean faster response times but slightly higher CPU usage

### **Memory Management for AI Sessions**
```nix
scrollback_lines = 50000;              # 50,000 lines of history
scrollback_pager_history_size = 10;    # Remember 10 pager sessions
```

**Why this matters for AI development:**
- **Long conversations**: Keep entire Claude Code sessions in memory
- **Debugging**: Scroll back through extensive error logs and outputs
- **Reference**: Quickly find previous AI suggestions or commands

**Memory usage:** ~50MB for full scrollback buffer (negligible on modern systems)

## 🎨 Theme & Visual Design

### **Enhanced Catppuccin Mocha**
Your theme has been optimized for better contrast and readability:

```nix
background = "#1e1e2e";           # Catppuccin Base (dark)
foreground = "#cdd6f4";           # Catppuccin Text (light)
selection_background = "#45475a"; # Better contrast for selections
url_color = "#74c7ec";            # Sapphire blue for links
```

**Color psychology:**
- **Dark background**: Reduces eye strain during long sessions
- **High contrast text**: Improves readability
- **Blue URLs**: Industry standard for clickable links

### **Visual Feedback**
```nix
visual_bell_duration = 0.1;      # Brief flash instead of beep
visual_bell_color = "#f9e2af";   # Yellow flash
background_opacity = 0.95;       # 5% transparency
```

**Benefits:**
- **Silent notifications**: Visual flash instead of annoying beeps
- **Subtle transparency**: Better integration with GNOME desktop
- **Professional appearance**: Matches modern application design

## 📑 Tab Management

### **Powerline Tabs**
```nix
tab_bar_edge = "bottom";                    # Like VS Code
tab_bar_style = "powerline";                # Modern angled design
tab_powerline_style = "slanted";            # Slanted segments
tab_title_template = "{index}: {title[title.rfind('/')+1:]}";
```

**What you'll see:**
- Tabs at the bottom (familiar from VS Code/browsers)
- Angled powerline separators between tabs
- Smart titles showing only folder names (not full paths)
- Tab numbers for quick navigation

**Example:** Instead of `/home/guyfawkes/projects/my-project`, you'll see `1: my-project`

### **Tab Colors (Catppuccin themed)**
```nix
active_tab_background = "#89b4fa";    # Blue for active
active_tab_foreground = "#1e1e2e";    # Dark text on blue
inactive_tab_background = "#45475a";  # Gray for inactive
inactive_tab_foreground = "#cdd6f4";  # Light text on gray
```

**Visual hierarchy:** Active tabs stand out with blue background, inactive ones fade to gray.

## 🖼️ Window Management

### **Layout Optimization**
```nix
initial_window_width = 120;        # 120 columns (vs default 80)
initial_window_height = 35;        # 35 rows (vs default 24)
window_padding_width = 4;          # 4px padding for comfort
```

**Why these sizes:**
- **120 columns**: Perfect for side-by-side code comparison
- **35 rows**: More content visible without scrolling
- **Padding**: Prevents text from touching window edges

### **Window Borders**
```nix
window_border_width = "1px";           # Subtle border
active_border_color = "#89b4fa";       # Blue for active window
inactive_border_color = "#585b70";     # Gray for inactive
```

**Use case:** When you split windows (Ctrl+Shift+D), you can easily see which is active.

## ⌨️ Keyboard Shortcuts

### **Tab Management**
- **Ctrl+Shift+T**: New tab in current directory
- **Ctrl+Shift+W**: Close current tab
- **Ctrl+Shift+→/←**: Navigate between tabs

### **Window Splitting**
- **Ctrl+Shift+D**: Split horizontally (great for comparing AI outputs)
- **Ctrl+Shift+Shift+D**: Split vertically (side-by-side editing)

### **Quick Tool Access**
- **Ctrl+Shift+Y**: Open Yazi file manager in new tab
- **Ctrl+Shift+M**: Start new tmux session
- **Ctrl+Shift+H**: Open htop system monitor

### **Scrollback Navigation** (Essential for AI conversations)
- **Ctrl+Shift+Page Up/Down**: Scroll through history
- **Ctrl+Shift+Home**: Jump to beginning of scrollback
- **Ctrl+Shift+End**: Jump to current prompt

**Pro tip:** Use scrollback navigation to review long Claude Code conversations or find previous commands.

### **Font Size Control**
- **Ctrl++**: Increase font size
- **Ctrl+-**: Decrease font size
- **Ctrl+0**: Reset to default size

## 🖱️ Mouse & Clipboard

### **Smart Copy/Paste**
```nix
copy_on_select = "clipboard";         # Auto-copy selections
strip_trailing_spaces = "smart";      # Clean up whitespace
rectangle_select_modifiers = "ctrl+alt"; # Rectangular selection
```

**Workflow benefits:**
- **Auto-copy**: Select text and it's automatically copied to clipboard
- **Clean copying**: AI-generated code comes out cleanly formatted
- **Rectangle selection**: Perfect for selecting columns of data or code blocks

**How to use rectangle selection:**
1. Hold **Ctrl+Alt**
2. Click and drag to select rectangular area
3. Perfect for copying code indentation or data columns

### **URL Handling**
```nix
url_color = "#74c7ec";           # Blue color for URLs
url_style = "curly";             # Curly underline
open_url_with = "default";       # Use system browser
path_style = "single";           # Underline file paths
```

**Smart detection:** Kitty automatically detects and highlights:
- URLs (clickable with Ctrl+Click)
- File paths in error messages
- Git repository links

## 🔗 System Integration

### **GNOME Wayland Optimization**
```nix
linux_display_server = "wayland";          # Native Wayland support
wayland_titlebar_color = "background";     # Match theme
confirm_os_window_close = 2;               # Confirm before closing
```

**Benefits:**
- **Better performance**: Native Wayland means no X11 translation layer
- **Integrated appearance**: Titlebar matches your terminal theme
- **Safety**: Confirms before closing windows with multiple tabs

### **Shell Integration**
```nix
shell_integration = "enabled";    # Enhanced features
term = "xterm-kitty";             # Proper terminal identification
```

**What this enables:**
- Better integration with Fish shell features
- Proper terminal capabilities detection
- Enhanced prompt and completion support

## 📚 Learning Resources

### **Essential Kitty Commands**
```bash
# Check current configuration
kitty --debug-config

# List all keybindings
kitty --debug-keyboard

# Test font rendering
kitty +list-fonts

# Open configuration file
kitty --edit-config
```

### **Advanced Features to Explore**

#### **Sessions (Coming Soon)**
Kitty supports session management - you can save and restore entire tab/window layouts:
```bash
# Save current session
kitty @ get-layout > my-session.json

# Restore session
kitty --session my-session.json
```

#### **Remote Control**
Control Kitty from other applications:
```bash
# Create new tab from command line
kitty @ new-tab

# Send text to specific tab
kitty @ send-text --match title:my-tab "hello world"
```

#### **Image Display**
Kitty can display images directly in the terminal:
```bash
# Display image (works great with yazi previews)
kitty +kitten icat image.png
```

### **Troubleshooting Tips**

#### **Font Issues**
If ligatures don't work:
1. Verify font installation: `fc-list | grep -i jetbrains`
2. Clear font cache: `fc-cache -f -v`
3. Restart Kitty completely

#### **Performance Issues**
If terminal feels slow:
1. Reduce `scrollback_lines` if using too much memory
2. Increase `repaint_delay` if screen updates are choppy
3. Disable transparency if GPU struggles

#### **Key Bindings Not Working**
1. Check for conflicts with GNOME shortcuts
2. Use `kitty --debug-keyboard` to see what Kitty receives
3. Some shortcuts might need `kitty_mod` instead of `ctrl+shift`

## 🎯 Workflow Tips

### **For AI Development**
1. **Use tabs for different projects**: Each AI project gets its own tab
2. **Split windows for comparison**: Compare AI-generated code side-by-side
3. **Large scrollback is your friend**: Keep entire AI conversations accessible
4. **Rectangle selection for code**: Select specific code blocks from AI output

### **For System Administration**
1. **Quick htop access**: Ctrl+Shift+H for instant system monitoring
2. **Tmux integration**: Ctrl+Shift+M for persistent sessions
3. **File management**: Ctrl+Shift+Y for visual file operations

### **For Development**
1. **Font size adjustment**: Zoom in for detailed code review
2. **Path detection**: Click on file paths in error messages
3. **URL handling**: Click on documentation links from terminal output

This configuration transforms Kitty into a powerful AI development environment optimized for your modern toolchain! 🚀
