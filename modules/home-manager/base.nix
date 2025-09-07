{ config, pkgs, ... }:

{
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
          
          return 1  # false - interactive
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
          if _is_automated_context
              command cd $argv
          else
              # Use zoxide for interactive directory jumping
              if test (count $argv) -eq 0
                  z
              else
                  z $argv
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
      abbr -a mkd 'mkdir -p'
      abbr -a batl 'bat --paging=never'
      abbr -a batp 'bat --style=plain'
      
      # New tool abbreviations
      abbr -a zz 'zoxide'
      abbr -a sk 'skim'
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
      abbr -a dcp 'docker-compose'
      abbr -a dcup 'docker-compose up'
      abbr -a dcdown 'docker-compose down'
      abbr -a pods 'k9s'
      abbr -a netscan 'nmap -sn'
      abbr -a portscan 'nmap -sS'
      abbr -a trace 'strace -f'
      abbr -a ltrace 'ltrace -f'
      
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
      
      # New tool aliases
      alias lintpy='ruff check'
      alias formatpy='ruff format'  
      alias yamlfmt='yq -P .'
      alias jsonpp='jq .'
      alias yamlpp='yq -P .'
    '';
    
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
      plugin = {
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
        # Markdown files - stable glow configuration for yazi
        markdown = [
          { run = ''${pkgs.kitty}/bin/kitty -e ${pkgs.glow}/bin/glow -p "$@"''; desc = "View with Glow (pager)"; block = true; }
          { run = ''${pkgs.kitty}/bin/kitty -e ${pkgs.glow}/bin/glow "$@"''; desc = "View with Glow"; block = true; }
          { run = "helix \"$@\""; desc = "Edit with Helix"; block = true; }
        ];
        # Images - Eye of GNOME as default
        image = [
          { run = "/run/current-system/sw/bin/eog \"$@\""; desc = "View with Eye of GNOME"; orphan = true; }
        ];
        # PDFs - Okular as default  
        pdf = [
          { run = "/run/current-system/sw/bin/okular \"$@\""; desc = "View with Okular"; orphan = true; }
        ];
        # Office documents
        office = [
          { run = "/run/current-system/sw/bin/libreoffice \"$@\""; desc = "Open with LibreOffice"; orphan = true; }
        ];
        
        # Text/code files - helix first, then other editors
        edit = [
          { run = "helix \"$@\""; desc = "Edit with Helix"; block = true; }
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

  # Enable and configure Kitty terminal
  programs.kitty = {
    enable = true;
    font = {
      name = "Adwaita Mono";
      size = 11;
    };
    settings = {
      # Shell
      shell = "${pkgs.fish}/bin/fish";
      
      # Catppuccin Mocha theme
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";
      selection_background = "#585b70";
      selection_foreground = "#cdd6f4";
      url_color = "#89b4fa";
      
      # Colors
      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      color7 = "#bac2de";
      color15 = "#a6adc8";
      
      # Zoom settings - start with one increment above base size
      font_size = 12.1; # Equivalent to base size (11) + one Ctrl+Plus increment
      remember_window_size = true;
      initial_window_width = 120; # columns
      initial_window_height = 30; # rows
    };
  };

  # You can also manage settings for other programs, for example:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your@email.com";
  # };
}
