{ config, pkgs, ... }:

{
  # Note: cursor-enhanced.nix import removed until module is completed

  # Home Manager needs a state version.
  # Please read the relevant section in the Home Manager manual
  # before changing this value.
  home.stateVersion = "24.05";

  # The home.packages option allows you to install packages in your home profile.
  home.packages = [
    # pkgs.neovim
    # pkgs.tmux
  ];

  # Let home-manager manage my shell configuration.
  programs.bash.enable = true;

  # Configure Fish shell with smart command system (matching documentation)
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Context detection function - determines if running in automated context
      function _is_automated_context
          # Check for automation environment variables
          if set -q CI; or set -q AUTOMATION; or set -q AGENT_MODE
              return 0  # true - automated
          end

          # Check if input/output is redirected (non-interactive)
          if not isatty stdin; or not isatty stdout
              return 0  # true - automated
          end

          # Check for agent indicators in TERM
          if string match -q "*agent*" $TERM; or string match -q "*script*" $TERM
              return 0  # true - automated
          end

          # Check for dumb terminal (often used by AI tools)
          if test "$TERM" = "dumb"
              return 0  # true - automated
          end

          # Check parent process for AI tools (Claude, Cursor, etc.)
          set -l parent_cmd (ps -o comm= -p $fish_pid 2>/dev/null || echo "")
          if string match -q "*cursor*" $parent_cmd; or string match -q "*claude*" $parent_cmd; or string match -q "*vscode*" $parent_cmd
              return 0  # true - automated
          end

          return 1  # false - interactive
      end

      # Utility function to strip emoji and ANSI codes from output
      function _strip_formatting
          # Use a comprehensive approach to remove problematic characters
          # 1. Remove ANSI escape sequences
          # 2. Remove common emoji using explicit patterns
          # 3. Remove other Unicode control characters
          sed -E '
              s/\x1b\[[0-9;]*[mGKHFJ]//g     # ANSI escape sequences
              s/🔒//g; s/🗑️//g; s/🔧//g       # Common commit emoji
              s/📦//g; s/⚡//g; s/🚀//g        # More common emoji
              s/✨//g; s/🐛//g; s/🎨//g        # Git conventional emoji
              s/♻️//g; s/⬆️//g; s/⬇️//g        # Dependency emoji
              s/🔥//g; s/💄//g; s/📝//g        # Other common ones
              s/🏗️//g; s/🎯//g; s/🤖//g        # Build/AI emoji
          ' | tr -cd '[:print:]\n\t'           # Keep only printable ASCII + newlines/tabs
      end
      
      # Smart cat function - context-aware file viewing
      function cat --description "Smart cat: glow for markdown, bat for code, cat for automation"
          if _is_automated_context
              command cat $argv
              return
          end
          
          # Interactive mode - check file extension
          for file in $argv
              if test -f "$file"
                  switch (string lower (path extension "$file"))
                      case .md .markdown
                          glow "$file"
                      case .py .js .ts .rs .go .c .cpp .java .rb .php .css .html .json .yaml .yml .toml .nix .sh .bash .fish
                          bat "$file"
                      case '*'
                          bat "$file"
                  end
              else
                  command cat "$file"
              end
          end
      end
      
      # Smart ls function - context-aware directory listing  
      function ls --description "Smart ls: eza with icons for interactive, ls for automation"
          if _is_automated_context
              command ls $argv
          else
              eza --icons --git $argv
          end
      end
      
      function ll --description "Smart ll: enhanced long listing"
          if _is_automated_context
              command ls -la $argv
          else
              eza -la --icons --git --group-directories-first $argv
          end
      end
      
      function la --description "Smart la: show all files"
          if _is_automated_context  
              command ls -A $argv
          else
              eza -A --icons --git --group-directories-first $argv
          end
      end
      
      # Smart grep function - simple patterns only
      function grep --description "Smart grep: rg for simple interactive patterns, grep for complex/automation"
          if _is_automated_context
              command grep $argv
          else
              # For interactive use with simple patterns, use rg
              rg $argv
          end
      end
      
      # Smart cd function - zoxide for interactive, cd for automation
      function cd --description "Smart cd: zoxide for interactive directory jumping, cd for automation"
          # Prevent infinite recursion by checking if we're already in a cd call
          if set -q _CD_RECURSIVE_GUARD
              builtin cd $argv
              return
          end
          
          if _is_automated_context
              builtin cd $argv
          else
              # Handle special cases that should use builtin cd instead of zoxide
              if test (count $argv) -eq 0
                  # No arguments - go to home (let zoxide handle this)
                  set -g _CD_RECURSIVE_GUARD 1
                  z
                  set -e _CD_RECURSIVE_GUARD
              else if string match -q "..*" $argv[1]
                  # Parent directory navigation (.. ../ ../../etc) - use builtin cd
                  builtin cd $argv
              else if string match -q "/*" $argv[1]
                  # Absolute path - use builtin cd
                  builtin cd $argv
              else if string match -q "~*" $argv[1]
                  # Home path - use builtin cd
                  builtin cd $argv
              else if string match -q "*/*" $argv[1]
                  # Relative path with slashes - use builtin cd
                  builtin cd $argv
              else if test -d $argv[1]
                  # Directory exists locally - use builtin cd
                  builtin cd $argv
              else
                  # Directory name only - try zoxide for smart jumping
                  set -g _CD_RECURSIVE_GUARD 1
                  z $argv
                  set -e _CD_RECURSIVE_GUARD
              end
          end
      end
      
      # Smart find function suggestions
      function find --description "Smart find: suggest fd for interactive use"
          if _is_automated_context
              command find $argv
          else
              echo "💡 Consider using: fd (faster, simpler syntax)"
              echo "  fd '$argv[2]'    # Simple name search"
              echo "  fd -e py         # Find by extension"
              echo "  fd -t f          # Files only"
              command find $argv
          end
      end

      
      # Abbreviations - expand as you type
      abbr -a tree 'eza --tree'
      abbr -a lt 'eza --tree --level=2'  
      abbr -a lg 'eza -la --git --group-directories-first'
      abbr -a l1 'eza -1'
      abbr -a findname 'fd'
      abbr -a searchtext 'rg'
      abbr -a rgpy 'rg --type py'
      abbr -a rgjs 'rg --type js'  
      abbr -a rgmd 'rg --type md'
      abbr -a top 'htop'
      abbr -a gdiff 'git diff | bat --language=diff'
      abbr -a glog 'git log --oneline | head -20'
      abbr -a json 'jq .'
      abbr -a jsonc 'jq -C .'
      abbr -a mdcat 'glow'
      abbr -a mdp 'glow -p'
      abbr -a mdw 'glow -w 80'
      abbr -a pdf2md 'python3 -m pymupdf4llm'
      abbr -a pdftomarkdown 'python3 -m pymupdf4llm'
      abbr -a mkd 'mkdir -p'
      abbr -a batl 'bat --paging=never'
      abbr -a batp 'bat --style=plain'
      
      # New tool abbreviations
      abbr -a zz 'zoxide'
      abbr -a sk 'skim'
      abbr -a ai 'aider'
      abbr -a aicode 'aider --dark-mode --model anthropic/claude-3-5-sonnet-20241022'
      abbr -a br 'broot'
      abbr -a record 'vhs'
      abbr -a yamlcat 'yq .'
      abbr -a yamlp 'yq -P .'
      abbr -a csvcat 'csvlook'
      abbr -a csvstat 'csvstat'
      abbr -a mlr 'miller'
      abbr -a jlcat 'jless'
      abbr -a choose1 'choose 0'
      abbr -a choose2 'choose 0 1'
      abbr -a ruffcheck 'ruff check'
      abbr -a rufffix 'ruff check --fix'
      abbr -a ruffformat 'ruff format'
      abbr -a uvrun 'uv run'
      abbr -a uvinstall 'uv add'

      # Modern Nix/Flakes commands
      abbr -a ndev 'nix develop'
      abbr -a nshell 'nix shell nixpkgs#'
      abbr -a nsearch 'nix search nixpkgs'
      abbr -a nrun 'nix run nixpkgs#'
      abbr -a devshell 'devenv shell'

      # Database development (AI-friendly)
      abbr -a pgcli 'pgcli'
      abbr -a mycli 'mycli'
      abbr -a dbcli 'usql'

      # Note: Code quality tools are project-level
      # Use: `devenv shell` or project-specific commands
      # - gitleaks: configured per-project in devenv.nix
      # - typos: project-specific dictionaries
      # - pre-commit: .pre-commit-config.yaml per project
      abbr -a dcp 'docker-compose'
      abbr -a dcup 'docker-compose up'
      abbr -a dcdown 'docker-compose down'
      abbr -a pods 'k9s'
      abbr -a netscan 'nmap -sn'
      abbr -a portscan 'nmap -sS'
      abbr -a trace 'strace -f'
      abbr -a ltrace 'ltrace -f'

      # Note: Readwise BASB and Chrome abbreviations moved to shellAbbrs for persistence

      # Utility functions
      function preview --description "Enhanced file preview"
          if test (count $argv) -eq 0
              echo "Usage: preview <file>"
              return 1
          end
          
          set file $argv[1]
          switch (string lower (path extension "$file"))
              case .md .markdown
                  glow "$file"
              case '*'  
                  bat "$file"
          end
      end
      
      function ff --description "Find files by name (uses fd)"
          fd $argv
      end
      
      function search --description "Search text in files (uses rg)"  
          rg $argv
      end
      
      function md --description "Enhanced markdown viewer with options"
          if test (count $argv) -eq 0
              echo "Usage: md [-p] [-w WIDTH] [-s STYLE] <file>"
              return 1
          end
          
          glow $argv
      end
      
      function show_enhanced_tools --description "Show all available enhanced commands"
          echo "🚀 Enhanced CLI Tools Available:"
          echo ""
          echo "🤖 AI Development Tools:"
          echo "  ai        → aider (AI pair programming)"
          echo "  aicode    → aider with Claude Sonnet"
          echo "  br        → broot (interactive tree navigation)"
          echo "  cm        → chezmoi (dotfile management)"
          echo "  record    → vhs (terminal session recording)"
          echo ""
          echo "🗄️ Database & API Tools:"
          echo "  pgcli     → PostgreSQL client with autocompletion"
          echo "  mycli     → MySQL/MariaDB client with smart completion"
          echo "  dbcli     → Universal database CLI (usql)"
          echo "  hurl      → HTTP testing with file-based definitions"
          echo ""
          echo "🔧 Project-Level Tools (devenv/package.json):"
          echo "  gitleaks  → Security scanning (per-project configs)"
          echo "  typos     → Spell checking (project dictionaries)"
          echo "  pre-commit → Git hooks (project-specific rules)"
          echo "  ruff/black → Python formatting (project versions)"
          echo "  eslint/prettier → JS formatting (project configs)"
          echo ""
          echo "📝 Smart Commands (context-aware):"
          echo "  cat       → glow (markdown) / bat (code) / cat (automation)"
          echo "  ls        → eza --icons --git / ls (automation)"
          echo "  ll        → eza -la --icons --git --group-directories-first"
          echo "  la        → eza -A --icons --git --group-directories-first"
          echo "  grep      → rg (simple patterns) / grep (complex/automation)"
          echo "  cd        → zoxide (smart jumping) / cd (automation)"
          echo "  find      → suggests fd (with hints) / find (automation)"
          echo ""
          echo "⚡ Core Abbreviations (type + space to expand):"
          echo "  tree      → eza --tree"
          echo "  findname  → fd"
          echo "  rgpy      → rg --type py"  
          echo "  top       → htop"
          echo "  mdcat     → glow"
          echo "  json      → jq ."
          echo ""
          echo "🆕 New Tool Abbreviations:"
          echo "  yamlcat   → yq . (YAML processing)"
          echo "  csvcat    → csvlook (CSV viewing)"
          echo "  jlcat     → jless (large JSON files)"
          echo "  choose1   → choose 0 (extract first column)"
          echo "  ruffcheck → ruff check (Python linting)"
          echo "  uvrun     → uv run (fast Python execution)"
          echo "  dcp       → docker-compose"
          echo "  pods      → k9s (Kubernetes dashboard)"
          echo "  netscan   → nmap -sn (network discovery)"
          echo "  trace     → strace -f (system call tracing)"
          echo ""
          echo "🔧 Utility Functions:"
          echo "  preview   → Enhanced file preview"
          echo "  ff        → Find files by name"
          echo "  search    → Search text in files"
          echo "  md        → Enhanced markdown viewer"
          echo ""
          echo "📚 Documentation: bat fish-smart-commands.md"
      end
      
      # Override functions for original commands
      function orig_cat --description "Force original cat"
          command cat $argv
      end
      
      function orig_ls --description "Force original ls"
          command ls $argv  
      end
      
      function orig_grep --description "Force original grep"
          command grep $argv
      end

      # Git shortcuts
      alias gd='git diff'
      alias gst='git status'
      alias gl='git log --oneline --graph --decorate'
      
      # Development shortcuts
      alias bench='hyperfine'
      alias loc='tokei'

      # Broot integration function (enables cd functionality)
      function br --wraps=broot
          set -l cmd_file (mktemp)
          if broot --outcmd $cmd_file $argv
              source $cmd_file
              rm -f $cmd_file
          else
              set -l code $status
              rm -f $cmd_file
              return $code
          end
      end
      
      # New tool aliases
      alias lintpy='ruff check'
      alias formatpy='ruff format'  
      alias yamlfmt='yq -P .'
      alias jsonpp='jq .'
      alias yamlpp='yq -P .'
    '';

    # Fish abbreviations (persistent across sessions)
    shellAbbrs = {
      # Readwise BASB Integration
      rwsetup = "~/nixos-config/basb-system/scripts/readwise-basb setup";
      rwdaily = "~/nixos-config/basb-system/scripts/readwise-basb daily";
      rwtag = "~/nixos-config/basb-system/scripts/readwise-basb tag";
      rwstats = "~/nixos-config/basb-system/scripts/readwise-basb stats";
      rwtfp = "~/nixos-config/basb-system/scripts/readwise-basb stats --tfp";
      rwweekly = "~/nixos-config/basb-system/scripts/readwise-basb stats --weekly";

      # Chrome Bookmarks Review
      rwchrome = "~/nixos-config/basb-system/scripts/readwise-basb chrome";
      rwcstats = "~/nixos-config/basb-system/scripts/readwise-basb chrome --stats";
      rwcgtd = "~/nixos-config/basb-system/scripts/readwise-basb chrome --folder GTD";
    };

    # Fish completions and integrations
    plugins = [
      # Note: z plugin already configured in system packages
    ];
    shellAliases = {
      # Navigation shortcuts
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  # Enable additional completions and integrations
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Configure atuin for intelligent shell history
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # AI workflow optimizations
      auto_sync = true;
      sync_frequency = "1h";
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";
      show_preview = true;
      max_preview_height = 4;
      # Better context for AI agents
      history_filter = [
        "^\\s"        # Skip commands starting with space
        "^exit$"      # Skip exit commands
        "^clear$"     # Skip clear commands
      ];
    };
  };

  # Enable broot for interactive directory navigation
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };
  };

  # Enable and configure Yazi file manager (restored from working commit b25a70e)
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
      };
      preview = {
        image_filter = "lanczos3";
        image_quality = 90;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
      };
      plugin = {
        # Re-enabled rich-preview for enhanced file previews
        prepend_previewers = [
          { name = "*.csv"; run = "rich-preview"; }
          { name = "*.md"; run = "rich-preview"; }
          { name = "*.markdown"; run = "rich-preview"; }
          { name = "*.rst"; run = "rich-preview"; }
          { name = "*.ipynb"; run = "rich-preview"; }
          { name = "*.json"; run = "rich-preview"; }
        ];
      };
      opener = {
        # Markdown files - direct glow usage (no nested terminal)
        markdown = [
          { run = "glow -p \"$@\""; desc = "View with Glow (pager)"; block = true; }
          { run = "glow \"$@\""; desc = "View with Glow"; block = true; }
          { run = "hx \"$@\""; desc = "Edit with Helix"; block = true; }
        ];
        # Images - Eye of GNOME as primary
        image = [
          { run = "eog \"$@\""; desc = "View with Eye of GNOME"; orphan = true; }
          { run = "sxiv \"$@\""; desc = "View with sxiv"; orphan = true; }
          { run = "feh \"$@\""; desc = "View with feh"; orphan = true; }
        ];
        # PDFs - Okular as default  
        pdf = [
          { run = "/run/current-system/sw/bin/okular \"$@\""; desc = "View with Okular"; orphan = true; }
        ];
        # Office documents
        office = [
          { run = "/run/current-system/sw/bin/libreoffice \"$@\""; desc = "Open with LibreOffice"; orphan = true; }
        ];
        
        # CSV files - LibreOffice Calc as primary opener
        csv = [
          { run = "libreoffice --calc \"$@\""; desc = "Open with LibreOffice Calc"; orphan = true; }
          { run = "csvlook \"$@\""; desc = "View with csvlook"; block = true; }
          { run = "hx \"$@\""; desc = "Edit with Helix"; block = true; }
        ];
        
        # Text/code files - helix first, then other editors
        edit = [
          { run = "hx \"$@\""; desc = "Edit with Helix"; block = true; }
          { run = "zed \"$@\""; desc = "Edit with Zed"; }
          { run = "code \"$@\""; desc = "Edit with VS Code"; }
        ];
      };
      open = {
        rules = [
          # Markdown files
          { name = "*.md"; use = "markdown"; }
          { name = "*.markdown"; use = "markdown"; }
          # Images
          { name = "*.jpg"; use = "image"; }
          { name = "*.jpeg"; use = "image"; }
          { name = "*.png"; use = "image"; }
          { name = "*.gif"; use = "image"; }
          { name = "*.bmp"; use = "image"; }
          { name = "*.svg"; use = "image"; }
          { name = "*.webp"; use = "image"; }
          # PDFs
          { name = "*.pdf"; use = "pdf"; }
          # CSV files
          { name = "*.csv"; use = "csv"; }
          # Office documents  
          { name = "*.doc"; use = "office"; }
          { name = "*.docx"; use = "office"; }
          { name = "*.xls"; use = "office"; }
          { name = "*.xlsx"; use = "office"; }
          { name = "*.ppt"; use = "office"; }
          { name = "*.pptx"; use = "office"; }
          { name = "*.odt"; use = "office"; }
          { name = "*.ods"; use = "office"; }
          { name = "*.odp"; use = "office"; }
          
          # Text and code files - all open with Helix by default
          { name = "*.txt"; use = "edit"; }
          { name = "*.py"; use = "edit"; }
          { name = "*.js"; use = "edit"; }
          { name = "*.ts"; use = "edit"; }
          { name = "*.tsx"; use = "edit"; }
          { name = "*.jsx"; use = "edit"; }
          { name = "*.rs"; use = "edit"; }
          { name = "*.go"; use = "edit"; }
          { name = "*.c"; use = "edit"; }
          { name = "*.cpp"; use = "edit"; }
          { name = "*.cc"; use = "edit"; }
          { name = "*.cxx"; use = "edit"; }
          { name = "*.h"; use = "edit"; }
          { name = "*.hpp"; use = "edit"; }
          { name = "*.hxx"; use = "edit"; }
          { name = "*.css"; use = "edit"; }
          { name = "*.scss"; use = "edit"; }
          { name = "*.sass"; use = "edit"; }
          { name = "*.html"; use = "edit"; }
          { name = "*.htm"; use = "edit"; }
          { name = "*.xml"; use = "edit"; }
          { name = "*.yaml"; use = "edit"; }
          { name = "*.yml"; use = "edit"; }
          { name = "*.toml"; use = "edit"; }
          { name = "*.json"; use = "edit"; }
          { name = "*.jsonc"; use = "edit"; }
          { name = "*.json5"; use = "edit"; }
          { name = "*.ini"; use = "edit"; }
          { name = "*.conf"; use = "edit"; }
          { name = "*.cfg"; use = "edit"; }
          { name = "*.nix"; use = "edit"; }
          { name = "*.sh"; use = "edit"; }
          { name = "*.bash"; use = "edit"; }
          { name = "*.zsh"; use = "edit"; }
          { name = "*.fish"; use = "edit"; }
          { name = "*.vim"; use = "edit"; }
          { name = "*.lua"; use = "edit"; }
          { name = "*.rb"; use = "edit"; }
          { name = "*.php"; use = "edit"; }
          { name = "*.java"; use = "edit"; }
          { name = "*.kt"; use = "edit"; }
          { name = "*.swift"; use = "edit"; }
          { name = "*.dart"; use = "edit"; }
          { name = "*.sql"; use = "edit"; }
          { name = "*.dockerfile"; use = "edit"; }
          { name = "Dockerfile*"; use = "edit"; }
          { name = "*.env"; use = "edit"; }
          { name = "*.gitignore"; use = "edit"; }
          { name = "*.gitconfig"; use = "edit"; }
        ];
      };
    };
    plugins = {
      rich-preview = pkgs.yaziPlugins.rich-preview;
    };
  };

  # Enable and configure Kitty terminal with advanced optimizations
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
      sync_to_monitor = false;          # Disable vsync for better performance
      repaint_delay = 10;               # Faster repaints (default: 10ms)
      input_delay = 3;                  # More responsive typing during heavy output
      
      # MEMORY MANAGEMENT FOR AI SESSIONS
      # Large scrollback for AI conversations and debugging sessions
      scrollback_lines = 50000;         # 50k lines for extensive AI conversations
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
      background = "#1e1e2e";           # Catppuccin Base
      foreground = "#cdd6f4";           # Catppuccin Text
      cursor = "#f5e0dc";               # Catppuccin Rosewater
      
      # SELECTION COLORS (Enhanced for better contrast)
      selection_background = "#45475a"; # Surface1 for better readability
      selection_foreground = "#cdd6f4"; # Text
      
      # URL & LINK COLORS
      url_color = "#74c7ec";            # Sapphire for better visibility
      url_style = "curly";              # Underline style for URLs
      
      # STANDARD TERMINAL COLORS (Catppuccin Palette)
      color0 = "#45475a";   # Surface1
      color8 = "#585b70";   # Surface2
      color1 = "#f38ba8";   # Red
      color9 = "#f38ba8";   # Bright Red
      color2 = "#a6e3a1";   # Green
      color10 = "#a6e3a1";  # Bright Green
      color3 = "#f9e2af";   # Yellow
      color11 = "#f9e2af";  # Bright Yellow
      color4 = "#89b4fa";   # Blue
      color12 = "#89b4fa";  # Bright Blue
      color5 = "#f5c2e7";   # Pink
      color13 = "#f5c2e7";  # Bright Pink
      color6 = "#94e2d5";   # Teal
      color14 = "#94e2d5";  # Bright Teal
      color7 = "#bac2de";   # Subtext1
      color15 = "#a6adc8";  # Subtext0
      
      # ═══════════════════════════════════════════════════════════════════
      # ADVANCED TAB MANAGEMENT
      # ═══════════════════════════════════════════════════════════════════
      
      # TAB BAR CONFIGURATION
      tab_bar_edge = "bottom";                    # Tabs at bottom like VS Code
      tab_bar_style = "powerline";                # Powerline style for modern look
      tab_powerline_style = "slanted";            # Slanted powerline segments
      tab_title_template = "{index}: {title[title.rfind('/')+1:]}"; # Show only folder name
      
      # TAB COLORS (Catppuccin themed)
      active_tab_background = "#89b4fa";          # Blue for active tab
      active_tab_foreground = "#1e1e2e";          # Base for contrast
      inactive_tab_background = "#45475a";        # Surface1 for inactive
      inactive_tab_foreground = "#cdd6f4";        # Text
      
      # ═══════════════════════════════════════════════════════════════════
      # WINDOW & LAYOUT MANAGEMENT
      # ═══════════════════════════════════════════════════════════════════
      
      # WINDOW SIZE & BEHAVIOR
      remember_window_size = true;                # Remember size across sessions
      initial_window_width = 120;                # Wider for side-by-side code
      initial_window_height = 35;                # Taller for more content
      
      # WINDOW DECORATIONS
      window_border_width = "1px";               # Subtle border
      window_margin_width = 0;                   # No margin for max space
      window_padding_width = 4;                  # Small padding for comfort
      
      # ACTIVE/INACTIVE WINDOW DISTINCTION
      active_border_color = "#89b4fa";           # Blue border for active
      inactive_border_color = "#585b70";         # Gray for inactive
      
      # ═══════════════════════════════════════════════════════════════════
      # CURSOR & VISUAL ENHANCEMENTS
      # ═══════════════════════════════════════════════════════════════════
      
      # CURSOR BEHAVIOR
      cursor_blink_interval = 0.5;               # Moderate blink speed
      cursor_stop_blinking_after = 15.0;         # Stop after 15 seconds of inactivity
      cursor_shape = "block";                    # Block cursor (classic terminal)
      
      # VISUAL FEEDBACK
      visual_bell_duration = 0.1;                # Brief flash instead of beep
      visual_bell_color = "#f9e2af";             # Yellow flash for visibility
      
      # TRANSPARENCY & EFFECTS
      background_opacity = 0.95;                 # Subtle transparency for overlays
      
      # ═══════════════════════════════════════════════════════════════════
      # COPY/PASTE & MOUSE BEHAVIOR
      # ═══════════════════════════════════════════════════════════════════
      
      # CLIPBOARD INTEGRATION
      copy_on_select = "clipboard";              # Auto-copy selection to clipboard
      strip_trailing_spaces = "smart";           # Clean copying of AI outputs
      
      # MOUSE BEHAVIOR
      click_interval = -1.0;                     # Disable double-click timeout
      mouse_hide_wait = 3.0;                     # Hide mouse after 3 seconds
      open_url_with = "default";                 # Use system default browser
      open_url_modifiers = "kitty_mod";          # Require modifier to click URLs
      
      # RECTANGLE SELECTION (Great for code blocks)
      rectangle_select_modifiers = "ctrl+alt";   # Rectangular selection mode
      
      # ═══════════════════════════════════════════════════════════════════
      # GNOME WAYLAND INTEGRATION
      # ═══════════════════════════════════════════════════════════════════
      
      # WAYLAND OPTIMIZATIONS
      linux_display_server = "wayland";          # Native Wayland support
      wayland_titlebar_color = "background";     # Match titlebar to theme
      
      # SYSTEM INTEGRATION
      confirm_os_window_close = 2;               # Confirm before closing multiple tabs
      
      # ═══════════════════════════════════════════════════════════════════
      # SHELL INTEGRATION & FEATURES
      # ═══════════════════════════════════════════════════════════════════
      
      # SHELL INTEGRATION
      shell_integration = "enabled";             # Enhanced shell features
      
      # PATH & FILE DETECTION
      path_style = "single";                     # Underline file paths in output
      
      # FONT SIZE MANAGEMENT
      font_size = 12.1;                         # Start slightly larger than base
    };
    
    # ═══════════════════════════════════════════════════════════════════
    # KEYBOARD SHORTCUTS FOR AI DEVELOPMENT WORKFLOW
    # ═══════════════════════════════════════════════════════════════════
    keybindings = {
      # TAB MANAGEMENT
      "ctrl+shift+t" = "new_tab_with_cwd";        # New tab in current directory
      "ctrl+shift+w" = "close_tab";               # Close current tab
      "ctrl+shift+right" = "next_tab";            # Next tab
      "ctrl+shift+left" = "previous_tab";         # Previous tab
      
      # WINDOW SPLITTING (Great for comparing AI outputs)
      "ctrl+shift+d" = "launch --location=hsplit"; # Horizontal split
      "ctrl+shift+shift+d" = "launch --location=vsplit"; # Vertical split
      
      # QUICK TOOLS ACCESS
      "ctrl+shift+y" = "new_tab yazi";            # Quick file manager
      "ctrl+shift+m" = "new_tab tmux";            # New tmux session
      "ctrl+shift+h" = "new_tab htop";            # System monitor
      
      # FONT SIZE CONTROL
      "ctrl+plus" = "change_font_size all +1.0";  # Increase font
      "ctrl+minus" = "change_font_size all -1.0"; # Decrease font
      "ctrl+0" = "change_font_size all 0";        # Reset font size
      
      # SCROLLBACK NAVIGATION (Essential for long AI conversations)
      "ctrl+shift+page_up" = "scroll_page_up";    # Page up in scrollback
      "ctrl+shift+page_down" = "scroll_page_down"; # Page down in scrollback
      "ctrl+shift+home" = "scroll_home";          # Jump to top
      "ctrl+shift+end" = "scroll_end";            # Jump to bottom
      
      # CLIPBOARD OPERATIONS
      "ctrl+shift+c" = "copy_to_clipboard";       # Copy selection
      "ctrl+shift+v" = "paste_from_clipboard";    # Paste
    };
  };

  # Note: Chrome/Chromium policies moved to system-level configuration
  # in hosts/nixos/default.nix to avoid conflicts and ensure proper
  # policy application. Extensions are managed there as well.

  # Enhanced Starship prompt configuration with Nerd Font symbols
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$git_metrics$character";

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold bright-blue";
        truncation_length = 4;
        truncate_to_repo = true;
        fish_style_pwd_dir_length = 1;
        read_only = " 󰌾";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style = "bold purple";
        truncation_length = 25;
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bright-red";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        conflicted = "≠$count";
        deleted = "✘$count";
        renamed = "»$count";
        modified = "✱$count";
        staged = "✚$count";
        untracked = "?$count";
        stashed = "📦$count";
      };

      git_metrics = {
        format = "(\\(+$added/-$deleted\\) )";
        added_style = "bright-green";
        deleted_style = "bright-red";
        disabled = false;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
      
      # Performance optimization
      scan_timeout = 10;
      command_timeout = 500;
      
      # Additional Nerd Font symbols for other modules
      aws = {
        symbol = "  ";
      };
      
      buf = {
        symbol = " ";
      };
      
      bun = {
        symbol = " ";
      };
      
      cmake = {
        symbol = " ";
      };
      
      crystal = {
        symbol = " ";
      };
      
      dart = {
        symbol = " ";
      };
      
      deno = {
        symbol = " ";
      };
      
      elixir = {
        symbol = " ";
      };
      
      elm = {
        symbol = " ";
      };
      
      fennel = {
        symbol = " ";
      };
      
      fossil_branch = {
        symbol = " ";
      };
      
      gcloud = {
        symbol = "  ";
      };
      
      git_commit = {
        tag_symbol = "  ";
      };
      
      guix_shell = {
        symbol = " ";
      };
      
      haxe = {
        symbol = " ";
      };
      
      hg_branch = {
        symbol = " ";
      };
      
      hostname = {
        ssh_symbol = " ";
      };
      
      julia = {
        symbol = " ";
      };
      
      lua = {
        symbol = " ";
      };
      
      memory_usage = {
        symbol = "󰍛 ";
      };
      
      meson = {
        symbol = "󰔷 ";
      };
      
      nim = {
        symbol = "󰆥 ";
      };
      
      nix_shell = {
        symbol = " ";
      };
      
      ocaml = {
        symbol = " ";
      };
      
      package = {
        symbol = "󰏗 ";
      };
      
      perl = {
        symbol = " ";
      };
      
      pijul_channel = {
        symbol = " ";
      };
      
      pixi = {
        symbol = "󰏗 ";
      };
      
      rlang = {
        symbol = "󰟔 ";
      };
      
      ruby = {
        symbol = " ";
      };
      
      scala = {
        symbol = " ";
      };
      
      swift = {
        symbol = " ";
      };
      
      zig = {
        symbol = " ";
      };
      
      gradle = {
        symbol = " ";
      };
    };
  };

  # You can also manage settings for other programs, for example:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your@email.com";
  # };
}
