# Fish Shell Smart Command System Documentation

This document explains the intelligent command substitution system configured in your Fish shell that automatically provides enhanced tools for interactive use while preserving compatibility for agents and scripts.

## ✨ Visual Prompt Enhancement (NEW!)

Your terminal now includes **Starship prompt** with Nerd Font symbols:

```bash
~/nixos-config  main [✱2✚1⇡3] (+15/-3) ❯
```

**What you see:**
- `~/nixos-config` - Current directory path (blue)
- ` main` - Git branch with Nerd Font git icon (purple)
- `[✱2✚1⇡3]` - Git status: 2 modified, 1 staged, 3 ahead (red)
- `(+15/-3)` - Git metrics: 15 lines added, 3 deleted (green/red)
- `❯` - Prompt character (green for success, red for errors)

**Enhanced features:**
- **Nerd Font symbols** including  for git branches and 󰌾 for read-only directories
- **Clean, simple design** without heavy powerline segments
- **Real-time git status** with comprehensive indicators
- **Directory icons** for Documents 󰈙, Downloads , Music 󰝚, Pictures 
- **Performance optimized** for quick response

## 🧠 How It Works

Your Fish shell now has **context-aware command substitutions** that:
- ✅ **Give YOU enhanced tools** when typing commands interactively
- ✅ **Give AGENTS original tools** when they run commands automatically  
- ✅ **Preserve script compatibility** for all automation

## 🔍 Context Detection Logic

The system uses `_is_automated_context` function to detect when commands should use original vs enhanced tools:

### Triggers for Original Commands (cat, ls, grep, etc.)
- **Environment variables**: `CI`, `AUTOMATION`, `AGENT_MODE` are set
- **Non-TTY usage**: Input/output is piped or redirected (`cat file.txt | grep pattern`)
- **Agent indicators**: `$TERM` contains "agent" or "script"

### Triggers for Enhanced Commands (bat, eza, rg, etc.)
- **Interactive terminal**: You're typing commands directly
- **TTY detected**: Both stdin and stdout are connected to terminal
- **No automation markers**: No CI/agent environment variables detected

## 📋 Available Smart Commands

| Command You Type | Interactive Gets | Agents/Scripts Get | Description |
|------------------|------------------|-------------------|-------------|
| `cat file.md` | `glow file.md` | `cat file.md` | Beautiful markdown rendering for you |
| `cat file.py` | `bat file.py` | `cat file.py` | Syntax highlighting for code files |
| `ls` | `eza --icons --git` | `ls` | Icons and git status for you |
| `ll` | `eza -la --icons --git --group-directories-first` | `ls -la` | Enhanced long listing |
| `la` | `eza -A --icons --git --group-directories-first` | `ls -A` | Show all files enhanced |
| `grep pattern` | `rg pattern` (simple) | `grep pattern` | Faster search for simple patterns |
| `cd project` | Smart directory jumping | `cd project` | Uses zoxide for frequently visited dirs |

## 🧭 Smart Directory Navigation

### Enhanced `cd` Function
Your `cd` command is enhanced with **intelligent path handling**:

```bash
# These use builtin cd (fast, direct):
cd ..                    # Parent directory navigation
cd ../..                 # Multi-level parent navigation
cd /absolute/path        # Absolute paths
cd ~/home/path          # Home directory paths  
cd desktop-assistant/   # Relative paths with slashes
cd SomeDirectory        # Existing local directories

# This uses zoxide (smart jumping):
cd project              # Directory name only → zoxide finds best match
```

**How it works:**
1. **Parent directories** (`..`, `../..`) → Always use builtin `cd`
2. **Absolute paths** (`/path`) → Always use builtin `cd`  
3. **Home paths** (`~/path`) → Always use builtin `cd`
4. **Relative paths with slashes** (`dir/subdir`) → Use builtin `cd`
5. **Existing directories** → Use builtin `cd` if directory exists locally
6. **Directory names only** → Use `zoxide` for smart jumping to frequently visited directories

**Benefits:**
- ✅ **Reliable**: Local directories always work (no more "did not match any results")
- ⚡ **Fast**: Direct paths use builtin cd for instant navigation
- 🧠 **Smart**: Directory names use zoxide for intelligent jumping
- 🔄 **Compatible**: Works with all existing cd patterns

## 🚀 Abbreviations Available

These expand as you type and show you exactly what will run:

### File Operations
```bash
batl     # → bat --paging=never (no paging)
batp     # → bat --style=plain (plain style)
```

### Directory Navigation  
```bash
tree     # → eza --tree
lt       # → eza --tree --level=2 (limit depth)
lg       # → eza -la --git --group-directories-first
l1       # → eza -1 (single column)
```

### File Finding & Searching
```bash
findname # → fd (find files by name)
searchtext # → rg (search text in files)
rgpy     # → rg --type py (search Python files)
rgjs     # → rg --type js (search JavaScript files)
rgmd     # → rg --type md (search Markdown files)
```

### System Monitoring
```bash
top      # → htop (interactive process viewer)
du       # → ncdu (interactive disk usage)
df       # → pydf (colorized disk usage)
```

### AI Development Tools
```bash
ai       # → aider (AI pair programming assistant)
aicode   # → aider --dark-mode --model anthropic/claude-3-5-sonnet-20241022 (pre-configured)
br       # → broot (interactive tree navigation)
record   # → vhs (terminal session recording)
```

### Git & Development
```bash
gdiff    # → git diff | bat --language=diff (colorized diff)
glog     # → git log --oneline | head -20 (short log)
```

**Git Integration Note**: Your Starship prompt already shows comprehensive git status, so you have visual git information at all times without needing to run separate commands!

### JSON Processing
```bash
json     # → jq . (pretty print JSON)
jsonc    # → jq -C . (colorized JSON)
```

### Markdown Viewing
```bash
mdcat    # → glow (view markdown with glow)
mdp      # → glow -p (pager mode)
mdw      # → glow -w 80 (80 character width)
```

### Quick Operations
```bash
mkd      # → mkdir -p (create directory path)
rmd      # → rmdir (remove directory)
```

## 🛠 Utility Functions

### File Preview
```bash
preview file.txt    # Enhanced preview with bat/syntax highlighting
```

### Enhanced Search
```bash
ff pattern          # Find files by name (uses fd)
search pattern      # Search text in files (uses rg)
```

### Directory Tree
```bash
tree               # Enhanced tree view with eza
```

### Markdown Viewing
```bash
md file.md         # Enhanced markdown viewer with options
md -p file.md      # Pager mode
md -w 80 file.md   # Set width to 80 characters
md -s dark file.md # Use dark theme
```

## 🔧 Override Functions

When you need original commands (rare cases):

```bash
orig_cat file.txt   # Force original cat
orig_ls             # Force original ls  
orig_grep pattern   # Force original grep
```

## 📚 Help & Discovery

### Show Available Enhancements
```bash
show_enhanced_tools    # Lists all available enhanced commands
```

### Function Information
```bash
functions cat          # Show the cat function definition
help cat              # Fish help for cat function
type cat              # Show what cat resolves to
```

## 🧪 Testing the System

### Test Smart Context Detection
```bash
# These should use enhanced tools (you'll see colors, icons, etc.)
cat enhanced-tools-guide.md
ls
ll

# These should use original tools (no enhancements)
echo "test" | cat                    # Piped input → original cat
cat file.txt > output.txt            # Redirected output → original cat
AGENT_MODE=1 cat file.txt            # Agent mode → original cat
```

### Check What's Actually Running
```bash
# See expanded abbreviations as you type
tree<SPACE>          # Shows: eza --tree
rgpy<SPACE>          # Shows: rg --type py

# Check function definitions
functions ls         # Shows the smart ls function
```

## 🔄 How Commands Are Processed

1. **You type**: `cat important.py`
2. **Fish checks**: Is this an interactive session? Yes
3. **Function runs**: Smart `cat` function executes
4. **Context check**: `_is_automated_context` returns false (interactive)
5. **Tool selection**: Uses `bat` instead of `cat`
6. **Result**: You see syntax-highlighted Python code

Meanwhile:
1. **Agent types**: `cat important.py`
2. **Function runs**: Same smart `cat` function executes  
3. **Context check**: `_is_automated_context` returns true (non-TTY detected)
4. **Tool selection**: Uses original `cat`
5. **Result**: Agent gets plain text as expected

## 🐛 Troubleshooting

### Commands Not Working as Expected

**Check context detection:**
```bash
# Test the detection function
_is_automated_context; and echo "Automated context" or echo "Interactive context"
```

**Check if tools are installed:**
```bash
command -q bat; and echo "bat available" or echo "bat missing"
command -q eza; and echo "eza available" or echo "eza missing"  
command -q rg; and echo "ripgrep available" or echo "ripgrep missing"
```

**Force reload Fish config:**
```bash
source ~/.config/fish/config.fish
```

### Abbreviations Not Expanding

**List all abbreviations:**
```bash
abbr --list
```

**Add missing abbreviation:**
```bash
abbr --add myabbr "my command"
```

**Remove unwanted abbreviation:**
```bash
abbr --erase myabbr
```

### Reset to Original Commands

**Temporarily disable smart functions:**
```bash
set -g AGENT_MODE 1    # This session will use original commands
```

**Permanently remove (if needed):**
Edit `~/.config/fish/config.fish` and comment out the smart function definitions.

## 📁 File Locations

- **Main config**: `~/.config/fish/config.fish`
- **Individual functions**: `~/.config/fish/functions/` (if you want to split them)
- **This documentation**: `/home/guyfawkes/nixos-config/fish-smart-commands.md`
- **Tools guide**: `/home/guyfawkes/nixos-config/enhanced-tools-guide.md`

## 💡 Pro Tips

1. **Use tab completion** - All enhanced tools support Fish's excellent tab completion
2. **Check history** - Your command history shows the actual commands that ran
3. **Combine tools** - `fd -e py | fzf | xargs bat` works perfectly
4. **Trust the system** - It automatically adapts to the context
5. **Use `show_enhanced_tools`** when you forget what's available

## 🎯 Remember These Key Commands

```bash
show_enhanced_tools     # See what's enhanced
preview file.txt        # Quick file preview  
md file.md             # Enhanced markdown viewer
ff pattern             # Find files
search pattern         # Search in files
orig_command           # Force original version
```

The system is designed to be **invisible and helpful** - you get better tools automatically, but scripts and agents continue working exactly as expected!