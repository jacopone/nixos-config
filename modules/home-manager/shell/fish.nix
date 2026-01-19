# Fish shell configuration with smart commands and AI-optimized workflows
{ config, pkgs, ... }:

{
  # Zoxide shell integration - creates `z` and `zi` commands
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;

    # Add ~/.local/bin to PATH for TDD Guard control scripts
    shellInit = ''
      set -gx PATH $HOME/.local/bin $PATH
    '';

    interactiveShellInit = ''
      # Context detection function - determines if running in automated context
      # Uses multiple heuristics for reliability across different environments
      function _is_automated_context
          # PRIORITY 1: Explicit automation flags (most reliable)
          if set -q CLAUDE_CODE_SESSION; or set -q CI; or set -q AUTOMATION; or set -q AGENT_MODE
              return 0  # true - automated
          end

          # PRIORITY 2: Check full process tree (not just immediate parent)
          # This catches cases where AI tools spawn bash → fish
          set -l process_tree (ps -o comm= -p $fish_pid -p (ps -o ppid= -p $fish_pid 2>/dev/null) 2>/dev/null || echo "")
          if string match -qr '(claude|cursor|vscode|agent|copilot)' $process_tree
              return 0  # true - automated
          end

          # PRIORITY 3: Check for piped/redirected input (allows tmux/screen)
          # Only check stdin for pipes, allow pty pseudo-terminals
          if not test -t 0; and test -p /dev/stdin
              return 0  # true - piped input
          end

          # PRIORITY 4: Check for non-interactive output
          if not test -t 1
              return 0  # true - output redirected
          end

          # PRIORITY 5: Terminal environment indicators
          if test "$TERM" = "dumb"; or string match -q "*agent*" $TERM; or string match -q "*script*" $TERM
              return 0  # true - automated terminal
          end

          # PRIORITY 6: Check for SSH sessions without X forwarding (edge case)
          if set -q SSH_CONNECTION; and not set -q DISPLAY
              # SSH but no X11 = likely automated/headless
              return 0
          end

          # Default: assume interactive (safer for user experience)
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


      # Note: Abbreviations are now managed declaratively in shellAbbrs below
      # This provides better integration with Home Manager and Fish 4.x

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
          echo "  aitui     → AI Project Orchestration TUI (Rich interface)"
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

      # EOD cleanup workflow
      alias eod-cleanup='~/nixos-config/scripts/eod-cleanup.sh'
      alias eod-report='~/nixos-config/scripts/eod-cleanup.sh --report'
      alias review-files='~/nixos-config/scripts/review-files.sh'
      alias review-ss='~/nixos-config/scripts/review-files.sh screenshots'
      alias review-dl='~/nixos-config/scripts/review-files.sh downloads'

      # Manual atuin integration with fixed bind syntax (replaces enableFishIntegration)
      # Atuin 18.8.0 has a bug using deprecated "bind -k" syntax
      set -gx ATUIN_SESSION (atuin uuid)
      set --erase ATUIN_HISTORY_ID

      function _atuin_preexec --on-event fish_preexec
          if not test -n "$fish_private_mode"
              set -g ATUIN_HISTORY_ID (atuin history start -- "$argv[1]")
          end
      end

      function _atuin_postexec --on-event fish_postexec
          set -l s $status
          if test -n "$ATUIN_HISTORY_ID"
              ATUIN_LOG=error atuin history end --exit $s -- $ATUIN_HISTORY_ID &>/dev/null &
              disown
          end
          set --erase ATUIN_HISTORY_ID
      end

      function _atuin_search
          set -l keymap_mode
          switch $fish_key_bindings
              case fish_vi_key_bindings
                  switch $fish_bind_mode
                      case default
                          set keymap_mode vim-normal
                      case insert
                          set keymap_mode vim-insert
                  end
              case '*'
                  set keymap_mode emacs
          end

          set -l ATUIN_H (ATUIN_SHELL_FISH=t ATUIN_LOG=error ATUIN_QUERY=(commandline -b) atuin search --keymap-mode=$keymap_mode $argv -i 3>&1 1>&2 2>&3 | string collect)

          if test -n "$ATUIN_H"
              if string match --quiet '__atuin_accept__:*' "$ATUIN_H"
                  set -l ATUIN_HIST (string replace "__atuin_accept__:" "" -- "$ATUIN_H" | string collect)
                  commandline -r "$ATUIN_HIST"
                  commandline -f repaint
                  commandline -f execute
                  return
              else if string match --quiet '__atuin_chain_command__:*' "$ATUIN_H"
                  set -l new_command (string replace "__atuin_chain_command__:" "" -- "$ATUIN_H" | string collect)
                  set -l current_command (commandline -b)
                  commandline -r "$current_command $new_command"
              else
                  commandline -r "$ATUIN_H"
              end
          end

          commandline -f repaint
      end

      function _atuin_bind_up
          if commandline --search-mode; or commandline --paging-mode
              up-or-search
              return
          end

          set -l lineno (commandline --line)
          switch $lineno
              case 1
                  _atuin_search --shell-up-key-binding
              case '*'
                  up-or-search
          end
      end

      # Bind atuin commands (FIXED: using new syntax instead of deprecated -k)
      bind \cr _atuin_search
      bind \eOA _atuin_bind_up
      bind \e\[A _atuin_bind_up

      # Vi mode bindings (if applicable) - FIXED syntax
      if bind -M insert > /dev/null 2>&1
          bind -M insert \cr _atuin_search
          bind -M insert \eOA _atuin_bind_up
          bind -M insert \e\[A _atuin_bind_up
      end

      # Load API keys from local secrets (not in git)
      # Used by: CLAUDE.md suggestion engine, other AI tools
      if test -f ~/.config/secrets/anthropic.fish
          source ~/.config/secrets/anthropic.fish
      end
    '';

    # Fish abbreviations (persistent across sessions, managed by Home Manager)
    shellAbbrs = {
      # Tree and listing
      tree = "eza --tree";
      lt = "eza --tree --level=2";
      lg = "eza -la --git --group-directories-first";
      l1 = "eza -1";

      # Search tools
      findname = "fd";
      searchtext = "rg";
      rgpy = "rg --type py";
      rgjs = "rg --type js";
      rgmd = "rg --type md";

      # System monitoring
      top = "htop";

      # Git shortcuts
      gdiff = "git diff | bat --language=diff";
      glog = "git log --oneline | head -20";

      # JSON/YAML/CSV processing
      json = "jq .";
      jsonc = "jq -C .";
      yamlcat = "yq .";
      yamlp = "yq -P .";
      csvcat = "csvlook";
      csvstat = "csvstat";
      mlr = "miller";
      jlcat = "jless";

      # Markdown
      mdcat = "glow";
      mdp = "glow -p";
      mdw = "glow -w 80";

      # PDF conversion
      pdf2md = "python3 -m pymupdf4llm";
      pdftomarkdown = "python3 -m pymupdf4llm";

      # File operations
      mkd = "mkdir -p";
      batl = "bat --paging=never";
      batp = "bat --style=plain";

      # Tool shortcuts
      zz = "zoxide";
      sk = "skim";
      aitui = "python3 -m ai_orchestrator_tui";
      br = "broot";
      record = "vhs";

      # Column extraction
      choose1 = "choose 0";
      choose2 = "choose 0 1";

      # Python tools
      ruffcheck = "ruff check";
      rufffix = "ruff check --fix";
      ruffformat = "ruff format";
      uvrun = "uv run";
      uvinstall = "uv add";

      # Nix/Flakes
      ndev = "nix develop";
      nshell = "nix shell nixpkgs#";
      nsearch = "nix search nixpkgs";
      nrun = "nix run nixpkgs#";
      devshell = "devenv shell";

      # Database CLI
      pgcli = "pgcli";
      mycli = "mycli";
      dbcli = "usql";

      # Docker/Kubernetes
      dcp = "docker-compose";
      dcup = "docker-compose up";
      dcdown = "docker-compose down";
      pods = "k9s";

      # Network/Security
      netscan = "nmap -sn";
      portscan = "nmap -sS";
      trace = "strace -f";
      ltrace = "ltrace -f";

      # Workflow
      ideas = "review-ideas";
      bugs = "review-bugs";
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
}
