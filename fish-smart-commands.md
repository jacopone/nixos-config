# Fish Shell Smart Command System Documentation

This document explains the intelligent command substitution system configured in your Fish shell that automatically provides enhanced tools for interactive use while preserving compatibility for agents and scripts.

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
| `cat file.txt` | `bat file.txt` | `cat file.txt` | Syntax highlighting for you |
| `ls` | `eza --icons --git` | `ls` | Icons and git status for you |
| `ll` | `eza -la --icons --git --group-directories-first` | `ls -la` | Enhanced long listing |
| `la` | `eza -A --icons --git --group-directories-first` | `ls -A` | Show all files enhanced |
| `grep pattern` | `rg pattern` (simple) | `grep pattern` | Faster search for simple patterns |

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

### Git & Development
```bash
gdiff    # → git diff | bat --language=diff (colorized diff)
glog     # → git log --oneline | head -20 (short log)
```

### JSON Processing
```bash
json     # → jq . (pretty print JSON)
jsonc    # → jq -C . (colorized JSON)
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
ff pattern             # Find files
search pattern         # Search in files
orig_command           # Force original version
```

The system is designed to be **invisible and helpful** - you get better tools automatically, but scripts and agents continue working exactly as expected!