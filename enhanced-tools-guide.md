# Enhanced Tools Guide - Modern CLI Alternatives

This guide shows you the modern, enhanced alternatives to traditional Unix tools that are installed in your NixOS system, along with their most useful workflows and options.

## 🚀 Visual Git Workflow (NEW!)

Your terminal now has **Starship prompt** providing real-time visual git information:

```bash
~/nixos-config 🚀 master [✱2✚1⇡3] (+15/-3) ❯ cat README.md
```

**Visual git indicators:**
- `🚀 master` - Current branch with rocket symbol  
- `[✱2✚1⇡3]` - Status: 2 modified, 1 staged, 3 ahead of remote
- `(+15/-3)` - Metrics: 15 lines added, 3 deleted
- Updates in real-time as you work

**Benefits over traditional git status:**
- Always visible - no need to run `git status`  
- Performance optimized - won't slow down your terminal
- Context-aware - only shows in git repositories
- Integrated with Fish shell smart commands

## File Viewing & Reading

### `glow` for Markdown Files + `bat` for Code
**Purpose**: Beautiful markdown rendering + syntax-highlighted code viewer

**Markdown Files (Auto-detected)**:
```bash
# Traditional way
cat README.md

# Enhanced way (automatic)
cat README.md                  # Uses glow for beautiful rendering
md README.md                   # Direct glow usage with options
md -p README.md               # Pager mode
md -w 80 README.md            # Set width
```

**Code Files**:
```bash
# Traditional way
cat file.py

# Enhanced way (automatic)
cat file.py                    # Uses bat for syntax highlighting
bat -n file.py                # No line numbers
bat --style=plain file.py      # No decorations, just highlighting
```

**Common Workflows**:
```bash
# Markdown files (uses glow automatically)
cat README.md                  # Beautiful rendering
cat *.md                      # Multiple markdown files

# Code files (uses bat automatically)  
cat *.py                      # Syntax highlighted code
cat file.py | grep "function" # Search within files

# Direct tool usage
md -p large-doc.md            # Page through large markdown
bat large-file.log            # Page through large logs

# Show Git diff with syntax highlighting
git diff | bat --language=diff

# View JSON with syntax highlighting
curl -s api.example.com/data | bat --language=json
```

## File Listing & Navigation

### `eza` instead of `ls`
**Purpose**: Modern file listing with colors, icons, and Git status

**Basic Usage**:
```bash
# Traditional way
ls -la

# Enhanced way
eza -la                       # Long format with hidden files
eza --tree                    # Tree view like 'tree' command
eza --git                     # Show Git status
eza --icons                   # Show file type icons
```

**Common Workflows**:
```bash
# Most useful daily command
eza -lag --icons --git        # Long, all files, grid, icons, git status

# Directory tree with Git status
eza --tree --git --ignore-glob=".git"

# Sort by modification time
eza -la --sort=modified

# Show file sizes in human readable format
eza -la --binary

# Group directories first
eza -la --group-directories-first
```

### `yazi` instead of file managers
**Purpose**: Modern terminal file manager with rich previews

**Basic Usage**:
```bash
# Launch yazi
yazi

# Navigation keys (in yazi):
# h/j/k/l - Navigate (vim-style)
# Space   - Select files
# Enter   - Enter directory or open file
# q       - Quit
```

**Common Workflows**:
- File previews automatically show for markdown, JSON, images
- Press `Tab` to preview pane
- Press `t` to create new tab
- Press `T` to switch between tabs
- Press `y` to copy files
- Press `x` to cut files
- Press `p` to paste files

## File Searching & Finding

### `ripgrep` (rg) instead of `grep`
**Purpose**: Ultra-fast text search with smart defaults

**Basic Usage**:
```bash
# Traditional way
grep -r "pattern" .

# Enhanced way
rg "pattern"                  # Recursive by default, respects .gitignore
rg "pattern" --type py        # Search only Python files
rg "pattern" -C 3             # Show 3 lines of context
```

**Common Workflows**:
```bash
# Most common searches
rg "function.*login"          # Regex search
rg "TODO|FIXME|HACK"          # Multiple patterns
rg -i "error"                 # Case insensitive
rg "import.*requests" --type py  # Language-specific search

# Advanced searches
rg "pattern" --files-with-matches  # Only show filenames
rg "pattern" --count          # Count matches per file
rg "pattern" -A 5 -B 5        # Context lines (after/before)
rg "pattern" --glob="*.config" # Custom file patterns
```

### `fd` instead of `find`
**Purpose**: Fast, user-friendly alternative to find

**Basic Usage**:
```bash
# Traditional way
find . -name "*.py" -type f

# Enhanced way
fd "\.py$"                    # Regex by default
fd -e py                      # Extension search
fd pattern                    # Simple pattern matching
```

**Common Workflows**:
```bash
# Most useful searches
fd "config"                   # Find files/dirs containing "config"
fd -e py -e js               # Multiple extensions
fd -t f "pattern"            # Files only (-t d for directories)
fd -H "pattern"              # Include hidden files
fd "pattern" /path/to/search # Search in specific directory

# Combined with other tools
fd -e py | xargs wc -l       # Count lines in all Python files
fd "test.*\.py$" -x pytest {} # Execute command on each match
```

## System Monitoring

### `htop` instead of `top`
**Purpose**: Interactive process viewer with better interface

**Key Features**:
- Color-coded CPU/memory bars
- Tree view of processes
- Mouse support
- Easy sorting and filtering

**Usage**:
```bash
htop

# In htop:
# F6 - Sort by different columns
# F5 - Tree view
# F4 - Filter processes
# F9 - Kill process
# F10 - Quit
```

### `gtop` - Modern system dashboard
**Purpose**: Graphical activity monitor for terminal

**Usage**:
```bash
gtop    # Shows CPU, memory, network, disk usage in real-time
```

### `pydf` instead of `df`
**Purpose**: Colorized disk usage with better formatting

**Usage**:
```bash
# Traditional way
df -h

# Enhanced way
pydf    # Colorized output with usage bars
```

### `ncdu` instead of `du`
**Purpose**: Interactive disk usage analyzer

**Usage**:
```bash
ncdu /path/to/analyze    # Interactive disk usage browser
```

## Text Processing & JSON

### `jq` for JSON processing
**Purpose**: Command-line JSON processor

**Common Workflows**:
```bash
# Pretty print JSON
cat data.json | jq .

# Extract specific fields
curl -s api.com/users | jq '.users[].name'

# Filter by conditions
jq '.users[] | select(.age > 25)' data.json

# Transform data
jq '.users | map({name: .name, email: .email})' data.json
```

### `glow` for Markdown
**Purpose**: Render markdown in terminal with style

**Usage**:
```bash
glow README.md              # Render with styling
glow -p README.md           # Pager mode
glow -w 80 README.md        # Set width
```

## Interactive Selection

### `fzf` - Fuzzy finder
**Purpose**: General-purpose command-line fuzzy finder

**Common Workflows**:
```bash
# Find and edit files
vim $(fzf)

# Search command history
history | fzf

# Find and cd to directory
cd $(fd -t d | fzf)

# Kill process interactively
kill $(ps aux | fzf | awk '{print $2}')

# Git branch switching
git checkout $(git branch | fzf)
```

### `peco` - Simplistic interactive filtering
**Purpose**: Simple alternative to fzf for filtering

**Usage**:
```bash
# Filter any list
ps aux | peco

# Select from history
history | peco
```

## Development Tools

### Visual Git Status Integration
**With Starship prompt, you get instant git feedback:**
```bash
# Your prompt shows everything you need:
~/myproject 🚀 feature/auth [✚1?2] ❯ 

# No need for these commands anymore:
# git status    # Info already in prompt
# git branch    # Current branch always visible
# git diff --stat  # Change metrics in prompt
```

### Advanced Git Workflows
**Combine Starship with enhanced tools:**
```bash
# Visual git log with bat
git log --oneline | bat --language=gitlog

# Enhanced git diff (already configured with delta)
git diff  # Uses delta with side-by-side display

# Interactive git operations
lazygit   # Full-featured git TUI
gitui     # Alternative git terminal UI
```

### `tree` for directory structure
**Usage**:
```bash
tree                        # Show directory tree
tree -a                     # Include hidden files
tree -I "node_modules"      # Ignore patterns
tree -L 2                   # Limit depth
```

### Fish Shell Features
**Your shell has enhanced features + visual git:**
```bash
# Directory jumping with z plugin
z project                   # Jump to frequently used directories

# Visual git branch in prompt (always visible)
# Real-time git status indicators
# Enhanced auto-completion (just start typing and press Tab)
# Syntax highlighting as you type
# Better history search with up/down arrows
```

## File Management Workflows

### Most Useful Daily Commands
```bash
# Quick file overview
eza -lag --icons --git

# Search for files containing text
rg "pattern" --type py

# Find files by name
fd "config"

# View file with syntax highlighting
bat filename

# Interactive file browsing
yazi

# System monitoring
htop

# JSON processing
curl api.com/data | jq '.results[] | {name, status}'

# Fuzzy find and edit
vim $(fd -e py | fzf)
```

## Pro Tips

1. **Combine tools**: `fd -e py | fzf | xargs bat`
2. **Use aliases**: Add to your shell config for frequently used combinations
3. **Shell integration**: Many tools provide shell integration (fzf, z plugin)
4. **Git integration**: Tools like bat, eza, and yazi show Git status automatically
5. **Respect gitignore**: Modern tools automatically ignore files in .gitignore
6. **Performance**: These tools are generally much faster than their traditional counterparts

## 🐟 Fish Shell Integration

**Good News!** Your Fish shell is configured with **smart command substitutions** that automatically handle this for you:

### Smart Commands (Context-Aware)
When **you** type these commands interactively, you get the enhanced versions.  
When **agents/scripts** use them, they get the original versions automatically.

| You Type | You Get | Agents Get | Auto-Switches |
|----------|---------|------------|---------------|
| `cat file.md` | `glow file.md` | `cat file.md` | ✅ |
| `cat file.py` | `bat file.py` | `cat file.py` | ✅ |
| `ls` | `eza --icons --git` | `ls` | ✅ |
| `ll` | `eza -la --icons --git --group-directories-first` | `ls -la` | ✅ |
| `grep pattern` | `rg pattern` | `grep pattern` | ✅ |

### Quick Help Commands
```bash
show_enhanced_tools    # See all available enhancements
fish_help             # Quick Fish shell help
check_context         # Check if in automated context
what_runs cat         # See what 'cat' will actually run
```

### Fish Abbreviations Available
These expand as you type (press Space to expand):
```bash
tree     # → eza --tree
findname # → fd
rgpy     # → rg --type py
top      # → htop
gdiff    # → git diff | bat --language=diff
json     # → jq .
mdcat    # → glow
mdp      # → glow -p
```

📚 **Full Fish documentation**: `bat fish-smart-commands.md`

## Tool Comparison Summary

| Traditional | Enhanced | Key Benefits | Fish Smart Command | Visual Git Integration |
|------------|----------|--------------|-------------------|----------------------|
| `git status` | Starship prompt | Always visible, real-time updates | ✅ Auto-enabled | ✅ Built-in |
| `git branch` | Starship prompt | Current branch always visible | ✅ Auto-enabled | ✅ Built-in |
| `cat` (markdown) | `glow` | Beautiful markdown rendering, themes, paging | ✅ Auto-switches | — |
| `cat` (code) | `bat` | Syntax highlighting, line numbers, Git integration | ✅ Auto-switches | — |
| `ls` | `eza` | Colors, icons, Git status, better formatting | ✅ Auto-switches | ✅ Shows git status |
| `grep` | `ripgrep` | Faster, respects .gitignore, better defaults | ✅ Auto-switches | — |
| `find` | `fd` | Simpler syntax, faster, colored output | Manual use | — |
| `git diff` | `delta` | Side-by-side, syntax highlighting | ✅ Auto-enabled | ✅ Enhanced display |
| `top` | `htop` | Interactive, mouse support, better interface | Abbreviation | — |
| `du` | `ncdu` | Interactive browsing, visual bars | Abbreviation | — |
| File manager | `yazi` | Rich previews, vim-style navigation | Manual use | — |

**Start by just typing your normal commands** - the Fish shell will automatically give you the enhanced versions, and your Starship prompt provides continuous visual git feedback!