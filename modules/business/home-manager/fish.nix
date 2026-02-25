# Simplified Fish shell for business profile
# Keeps: smart commands (context-aware cat/ls/grep/cd/find), git aliases, zoxide
# Drops: atuin keybindings, broot, bench/loc, API key loading, EOD cleanup, power-user functions
{ config, pkgs, lib, aiProfile ? "google", ... }:

let
  isGoogle = aiProfile == "google" || aiProfile == "both";
  isClaude = aiProfile == "claude" || aiProfile == "both";
  greetingText =
    if aiProfile == "both" then "  Type:  gemini  or  claude"
    else if aiProfile == "claude" then "  Type:  claude"
    else "  Type:  gemini";
in
{
  # Zoxide shell integration - creates `z` and `zi` commands
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;

    # Add ~/.local/bin to PATH
    shellInit = ''
      set -gx PATH $HOME/.local/bin $PATH
    '';

    interactiveShellInit = ''
      # Context detection function - determines if running in automated context
      # Essential for Claude Code to get clean (non-decorated) output
      function _is_automated_context
          # PRIORITY 1: Explicit automation flags (most reliable)
          if set -q CLAUDE_CODE_SESSION; or set -q CI; or set -q AUTOMATION; or set -q AGENT_MODE
              return 0  # true - automated
          end

          # PRIORITY 2: Check full process tree (not just immediate parent)
          set -l process_tree (ps -o comm= -p $fish_pid -p (ps -o ppid= -p $fish_pid 2>/dev/null) 2>/dev/null || echo "")
          if string match -qr '(claude|gemini|cursor|vscode|agent|copilot)' $process_tree
              return 0  # true - automated
          end

          # PRIORITY 3: Check for piped/redirected input
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

          # PRIORITY 6: SSH without X forwarding
          if set -q SSH_CONNECTION; and not set -q DISPLAY
              return 0
          end

          # Default: assume interactive
          return 1  # false - interactive
      end

      # Utility function to strip emoji and ANSI codes from output
      function _strip_formatting
          sed -E '
              s/\x1b\[[0-9;]*[mGKHFJ]//g
              s/🔒//g; s/🗑️//g; s/🔧//g
              s/📦//g; s/⚡//g; s/🚀//g
              s/✨//g; s/🐛//g; s/🎨//g
              s/♻️//g; s/⬆️//g; s/⬇️//g
              s/🔥//g; s/💄//g; s/📝//g
              s/🏗️//g; s/🎯//g; s/🤖//g
          ' | tr -cd '[:print:]\n\t'
      end

      # Smart cat function - context-aware file viewing
      function cat --description "Smart cat: glow for markdown, bat for code, cat for automation"
          if _is_automated_context
              command cat $argv
              return
          end

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

      # Smart grep function
      function grep --description "Smart grep: rg for interactive, grep for automation"
          if _is_automated_context
              command grep $argv
          else
              rg $argv
          end
      end

      # Smart cd function - zoxide for interactive, cd for automation
      function cd --description "Smart cd: zoxide for interactive, cd for automation"
          if set -q _CD_RECURSIVE_GUARD
              builtin cd $argv
              return
          end

          if _is_automated_context
              builtin cd $argv
          else
              if test (count $argv) -eq 0
                  set -g _CD_RECURSIVE_GUARD 1
                  z
                  set -e _CD_RECURSIVE_GUARD
              else if string match -q "..*" $argv[1]
                  builtin cd $argv
              else if string match -q "/*" $argv[1]
                  builtin cd $argv
              else if string match -q "~*" $argv[1]
                  builtin cd $argv
              else if string match -q "*/*" $argv[1]
                  builtin cd $argv
              else if test -d $argv[1]
                  builtin cd $argv
              else
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
              echo "Consider using: fd (faster, simpler syntax)"
              echo "  fd '$argv[2]'    # Simple name search"
              echo "  fd -e py         # Find by extension"
              echo "  fd -t f          # Files only"
              command find $argv
          end
      end

      # Escape hatches to original commands
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

      # AI assistant greeting — only show in interactive terminals
      if not _is_automated_context
          echo ""
          echo "  Need to install or change something?"
          echo "${greetingText}"
          echo ""
      end

      ${lib.optionalString isGoogle ''
      # Launch Gemini CLI in nixos-config directory
      function gemini --description "Open Gemini CLI in your system config"
          builtin cd ~/nixos-config
          command gemini
      end
      ''}
      ${lib.optionalString isClaude ''
      # Launch Claude Code in nixos-config directory
      function claude --description "Open Claude Code in your system config"
          builtin cd ~/nixos-config
          command claude
      end
      ''}
    '';

    # Simplified abbreviations (~15 vs 60+ in tech profile)
    shellAbbrs = {
      tree = "eza --tree";
      lt = "eza --tree --level=2";
      findname = "fd";
      json = "jq .";
      mdcat = "glow";
      mkd = "mkdir -p";
      gdiff = "git diff | bat --language=diff";
      glog = "git log --oneline | head -20";
      ndev = "nix develop";
      devshell = "devenv shell";
      dcp = "docker-compose";
      dcup = "docker-compose up -d";
      dcdown = "docker-compose down";
    };

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };
}
