{ lib, pkgs, config, ... }:

{
  # Enhanced Cursor AI Configuration for NixOS + Home Manager
  # Optimized for 2025 best practices and AI orchestration workflows

  home.file = {
    # Enhanced Cursor settings with 2025 optimizations
    ".config/Cursor/User/settings.json".text = builtins.toJSON {
      # === CORE EDITOR CONFIGURATION ===
      "security.workspace.trust.untrustedFiles" = "open";
      "terminal.integrated.enableMultiLinePasteWarning" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "git.autofetch" = true;

      # === 2025 CURSOR AI OPTIMIZATIONS ===

      # YOLO Mode (Advanced AI Capabilities)
      "cursor.cpp.disabledLanguages" = [ ];
      "cursor.chat.enableContextAwareness" = true;
      "cursor.enableAutoSuggestions" = true;
      "cursor.yolo.enabled" = true;
      "cursor.yolo.allowTests" = true;
      "cursor.yolo.allowBuilds" = true;
      "cursor.yolo.allowLinting" = true;

      # Privacy & Security (Enterprise-grade)
      "cursor.privacy.anonymizedTelemetry" = false;
      "cursor.privacy.telemetryEnabled" = false;
      "cursor.security.disableModelLogging" = true;

      # Model Configuration (Cursor Pro Optimized)
      "cursor.preferredModel" = "claude-3-5-sonnet-20241022";
      "cursor.secondaryModel" = "gpt-4o-latest";
      "cursor.autoModelSelection" = true;
      "cursor.modelContext.maxTokens" = 128000;

      # Agent Mode Configuration
      "cursor.agent.enabled" = true;
      "cursor.agent.autoMode" = false;
      "cursor.agent.preserveModel" = true;
      "cursor.agent.maxIterations" = 10;

      # Context Management (2025 Enhancement)
      "cursor.context.enableCodebaseIndexing" = true;
      "cursor.context.maxFiles" = 1000;
      "cursor.context.includeHiddenFiles" = false;
      "cursor.context.respectGitignore" = true;

      # === DEVELOPMENT ENVIRONMENT INTEGRATION ===

      # DevEnv Integration
      "terminal.integrated.env.linux" = {
        "DEVENV_ACTIVE" = "true";
        "CURSOR_DEVENV_INTEGRATION" = "enabled";
      };

      # Git Integration (Enhanced)
      "git.enableCommitSigning" = true;
      "git.confirmSync" = false;
      "git.suggestSmartCommit" = true;
      "git.enableSmartCommit" = true;
      "git.autoRepositoryDetection" = true;

      # === UI/UX OPTIMIZATIONS ===

      # Theme and Appearance (matches Kitty terminal)
      "workbench.colorTheme" = "Catppuccin Mocha";
      "editor.fontFamily" = "'JetBrains Mono', 'JetBrainsMono Nerd Font', monospace";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "editor.lineHeight" = 1.5;
      "editor.cursorBlinking" = "smooth";
      "editor.cursorSmoothCaretAnimation" = "on";

      # Enhanced Code Editing
      "editor.inlineSuggest.enabled" = true;
      "editor.quickSuggestions" = {
        "other" = "on";
        "comments" = "on";
        "strings" = "on";
      };
      "editor.suggestOnTriggerCharacters" = true;
      "editor.wordBasedSuggestions" = "allDocuments";
      "editor.semanticHighlighting.enabled" = true;

      # File Handling
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.exclude" = {
        "**/.devenv" = true;
        "**/result" = true;
        "**/.direnv" = true;
        "**/node_modules" = true;
        "**/__pycache__" = true;
        "**/.pytest_cache" = true;
      };

      # === LANGUAGE-SPECIFIC OPTIMIZATIONS ===

      # TypeScript/JavaScript (enhanced for AI workflows)
      "typescript.suggest.autoImports" = true;
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "javascript.suggest.autoImports" = true;
      "javascript.updateImportsOnFileMove.enabled" = "always";

      # Python (integrated with uv and modern tooling)
      "python.defaultInterpreterPath" = "${pkgs.python313}/bin/python";
      "python.terminal.activateEnvironment" = true;
      "python.analysis.autoImportCompletions" = true;
      "python.analysis.typeCheckingMode" = "basic";

      # Nix Language Support
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";

      # === TERMINAL INTEGRATION ===
      "terminal.integrated.shell.linux" = "${pkgs.fish}/bin/fish";
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.lineHeight" = 1.2;

      # === EXTENSION SETTINGS ===

      # Vim Integration (matches your existing keybindings)
      "vim.enableNeovim" = false;
      "vim.useCtrlKeys" = false; # Disabled to allow Cursor AI shortcuts
      "vim.handleKeys" = {
        "<C-c>" = false;
        "<C-x>" = false;
        "<C-v>" = false;
        "<C-i>" = false; # Reserved for Agent mode
        "<C-e>" = false; # Reserved for background mode
      };

      # === PERFORMANCE OPTIMIZATIONS ===
      "workbench.settings.enableNaturalLanguageSearch" = false;
      "extensions.autoUpdate" = false; # Manage via Nix when possible
      "update.enableWindowsBackgroundUpdates" = false;
      "telemetry.telemetryLevel" = "off";
    };

    # Enhanced keybindings with 2025 features
    ".config/Cursor/User/keybindings.json".text = builtins.toJSON [
      # === AI AGENT SHORTCUTS ===
      {
        key = "ctrl+i";
        command = "composerMode.agent";
      }
      {
        key = "ctrl+e";
        command = "composerMode.background";
      }
      {
        key = "ctrl+shift+i";
        command = "cursor.agent.fork";
      }
      {
        key = "ctrl+alt+i";
        command = "cursor.agent.preserve-model";
      }

      # === ENHANCED WORKFLOW SHORTCUTS ===
      {
        key = "ctrl+shift+r";
        command = "cursor.rules.generate";
      }
      {
        key = "ctrl+alt+r";
        command = "cursor.context.rebuild";
      }
      {
        key = "ctrl+shift+p";
        command = "cursor.chat.openInEditor";
      }

      # === VIM COMPATIBILITY (disabled conflicting keys) ===
      {
        key = "ctrl+c";
        command = "-extension.vim_ctrl+c";
        when = "editorTextFocus && vim.active && vim.overrideCtrlC && vim.use<C-c> && !inDebugRepl";
      }
      {
        key = "ctrl+x";
        command = "-extension.vim_ctrl+x";
        when = "editorTextFocus && vim.active && vim.use<C-x> && !inDebugRepl";
      }
      {
        key = "ctrl+v";
        command = "-extension.vim_ctrl+v";
        when = "editorTextFocus && vim.active && vim.use<C-v> && !inDebugRepl";
      }

      # === FILE EXPLORER OPTIMIZATIONS ===
      {
        key = "ctrl+c";
        command = "-filesExplorer.copy";
        when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !inputFocus";
      }
      {
        key = "ctrl+x";
        command = "-filesExplorer.cut";
        when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus && !treeFindOpen";
      }
      {
        key = "ctrl+v";
        command = "-filesExplorer.paste";
        when = "filesExplorerFocus && foldersViewVisible && !explorerResourceReadonly && !inputFocus && !treeFindOpen";
      }
    ];

    # Global .cursorignore for system-wide exclusions
    ".cursorignore".text = ''
      # Build artifacts
      result
      result-*
      .devenv/
      .direnv/

      # Package managers
      node_modules/
      .npm/
      .yarn/
      .pnpm-store/
      __pycache__/
      .pytest_cache/
      .coverage
      .tox/

      # OS and IDE
      .DS_Store
      .vscode/
      .idea/
      *.swp
      *.swo

      # Logs
      *.log
      logs/

      # Temporary files
      .tmp/
      tmp/
      .cache/

      # Security
      .env
      .env.*
      *.key
      *.pem
      *.cert

      # Large files that shouldn't be in context
      *.db
      *.sqlite
      *.pdf
      *.mp4
      *.avi
      *.mov
      *.jpg
      *.jpeg
      *.png
      *.gif
      *.svg
    '';
  };

  # System-wide Cursor optimization scripts
  home.packages = with pkgs; [
    (writeShellScriptBin "cursor-setup" ''
      #!/usr/bin/env bash
      echo "🚀 Setting up enhanced Cursor AI configuration..."

      # Ensure Cursor directories exist
      mkdir -p ~/.config/Cursor/User

      # Restart Cursor if running
      if pgrep -f "cursor" > /dev/null; then
        echo "Restarting Cursor to apply changes..."
        pkill -f "cursor"
        sleep 2
      fi

      echo "✅ Cursor configuration updated!"
      echo "📋 New features available:"
      echo "   - Ctrl+I: Agent mode"
      echo "   - Ctrl+E: Background mode"
      echo "   - Ctrl+Shift+I: Fork agent"
      echo "   - Ctrl+Shift+R: Generate rules"
      echo ""
      echo "🔧 YOLO mode enabled for advanced AI capabilities"
      echo "🎯 Model: Claude 3.5 Sonnet (primary), GPT-4o (secondary)"
      echo "🔒 Privacy mode enabled for enterprise use"
    '')

    (writeShellScriptBin "cursor-project-init" ''
      #!/usr/bin/env bash
      echo "🔧 Initializing Cursor project configuration..."

      # Create modern .cursor/rules directory
      mkdir -p .cursor/rules

      # Initialize with project-specific rule template
      if [[ ! -f .cursor/rules/index.mdc ]]; then
        cp ~/nixos-config/templates/ai-quality-devenv/.cursor/rules/index.mdc .cursor/rules/ 2>/dev/null || \
        echo "Copy project rules template manually from nixos-config templates"
      fi

      echo "✅ Project initialized with Cursor AI rules"
      echo "📂 Edit .cursor/rules/index.mdc for project-specific AI behavior"
    '')
  ];
}
