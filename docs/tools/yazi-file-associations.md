---
status: active
created: 2025-10-08
updated: 2025-10-08
type: guide
lifecycle: persistent
---

# Yazi File Associations & Opening Behavior

This document explains how yazi is configured to open different file types with the optimal programs.

## 🎯 Key Improvements

- **Markdown files** now open with `glow` in pager mode for beautiful rendering (uses `hx` command for editing)
- **Images** open with Eye of GNOME (`eog`) - clean, fast GNOME integration
- **CSV files** show rich formatted previews and open with LibreOffice Calc
- **PDFs** open with Okular - full-featured with annotation support
- **Code files** automatically open with Helix editor (`hx` command)
- **Rich previews** work seamlessly with rich-preview plugin for markdown, JSON, CSV
- **Context-aware opening** - different behavior for interactive vs automated use

## 📋 File Type Associations

### 📝 Text & Documentation
| File Type | Primary Action | Secondary Actions |
|-----------|----------------|-------------------|
| `*.md`, `*.markdown` | `glow -p` (pager) | `glow`, `hx` (helix) |
| `*.txt`, `*.py`, `*.js`, etc. | `hx` (helix) | `zed`, `code` |
| `*.csv` | LibreOffice Calc | `csvlook`, `hx` |
| `*.json` | `hx` (helix) | `zed`, `code` |
| `*.log` | `hx` (helix) | `bat`, `less` |

### 🖼️ Media Files
| File Type | Primary Action | Secondary Actions |
|-----------|----------------|-------------------|
| `*.jpg`, `*.png`, `*.gif`, etc. | `eog` (Eye of GNOME) | `feh` |
| `*.pdf` | `okular` | - |
| `*.csv` | LibreOffice Calc | `csvlook`, `hx` |
| Office docs (`*.doc`, `*.xlsx`, etc.) | `libreoffice` | - |

### 📦 Archives & Documents
| File Type | Primary Action | Secondary Actions |
|-----------|----------------|-------------------|
| `*.zip`, `*.tar.gz`, `*.7z`, etc. | `file-roller` | `7z l` (list) |
| `*.doc`, `*.xlsx`, `*.odt`, etc. | `libreoffice` | - |
| `*.html` | `google-chrome` | `glow` (as text) |

## 🎮 How to Use

### Basic Usage
1. **Navigate** to any file in yazi (`hjkl` or arrow keys)
2. **Press Enter** to open with the primary program
3. **Press `o`** to see all available opening options and choose

### Keyboard Shortcuts in Yazi
- **Enter**: Open with primary program
- **`o`**: Show opener menu with all options
- **Space**: Select/preview file
- **Tab**: Toggle preview pane
- **`q`**: Quit yazi

## ✨ Smart Opening Examples

### Markdown Files
```bash
# When you press Enter on README.md:
→ glow -p README.md    # Beautiful rendering in pager mode

# Options available (press 'o'):
1. View with Glow (pager)     [PRIMARY]
2. View with Glow
3. Edit with Helix
4. Edit with Zed
```

### Image Files
```bash
# When you press Enter on image.jpg:
→ eog image.jpg        # Eye of GNOME image viewer

# Options available (press 'o'):
1. View with Eye of GNOME     [PRIMARY]
```

### JSON Files
```bash
# When you press Enter on data.json:
→ jq . data.json | bat --language=json    # Pretty-printed with syntax highlighting

# Options available (press 'o'):
1. Pretty print with jq and bat    [PRIMARY]
2. Edit with Helix
```

## 🔧 Configuration Location

The yazi opener configuration is defined in:
- **File**: `/home/guyfawkes/nixos-config/modules/home-manager/base.nix`
- **Section**: `programs.yazi.settings.opener` and `programs.yazi.settings.open.rules`

## 📦 Required Packages

These packages are automatically installed for the file associations:
- **`glow`** - Markdown renderer with beautiful styling
- **`eog`** - Eye of GNOME image viewer (newly added)
- **`okular`** - Full-featured PDF viewer with annotations
- **`libreoffice`** - Office document suite and CSV viewer
- **`helix` (`hx`)** - Post-modern text editor for code (fixed command name)
- **`csvkit`** - CSV processing tools (includes `csvlook`)
- **`rich-preview`** - Enhanced previews for CSV, JSON, markdown
- **`bat`** - Syntax highlighter with git integration

## 🎨 Customization

### Adding New File Types
Edit `modules/home-manager/base.nix` and add to the `open.rules` section:
```nix
{ name = "*.ext"; use = "your-opener"; }
```

### Adding New Openers
Add to the `opener` section:
```nix
your-opener = [
  { run = "your-program \"$@\""; desc = "Description"; }
];
```

### Changing Priority
The first entry in each opener list is the primary action (Enter key).
Reorder the list to change priorities.

## 🧪 Testing

After applying changes with `./rebuild-nixos`, test the associations:

1. **Launch yazi**: `yazi`
2. **Navigate to different file types**
3. **Press Enter** to test primary actions
4. **Press `o`** to test opener menu
5. **Verify each file type opens correctly**

## 🎯 Benefits

- **Markdown files**: Beautiful rendering instead of raw text editing
- **Media files**: Proper viewers instead of text editors
- **JSON files**: Pretty-printed and syntax highlighted
- **Archives**: Easy extraction with graphical interface
- **Consistent experience**: Right tool for each file type
- **Multiple options**: Always have alternatives available

The system now provides an optimal viewing/opening experience for each file type while keeping editing options readily available! 🚀
