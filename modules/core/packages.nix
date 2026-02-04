{ pkgs, inputs, ... }:

let
  # Pinned npm versions for reproducibility
  npmVersions = import ./npm-versions.nix;
in
{
  environment.systemPackages = with pkgs; [
    # dev tools
    helix # A post-modern modal text editor - https://helix-editor.com/
    # zed-editor # TEMP: Disabled - requires source compilation, causes system slowdown on rebuild
    vscode-fhs # Visual Studio Code in an FHS-like environment - https://code.visualstudio.com/
    inputs.code-cursor-nix.packages.${pkgs.stdenv.hostPlatform.system}.cursor # Cursor - Auto-updating AI Code Editor - https://cursor.com/
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # A code-generation tool using Anthropic's Claude model (better packaged)
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # Google Antigravity - Next-generation agentic IDE - https://antigravity.google
    pencil-dev # Design on canvas, land in code - IDE-integrated design tool - https://pencil.dev

    # Speech-to-text
    vibetyper # AI voice typing with speech-to-text - https://vibetyper.com
    wtype # Wayland text input
    xdotool # X11 text input
    dotool # Universal text input

    # Anthropic's sandbox-runtime (srt) - Claude Code sandboxing
    # Usage: srt claude [args]  OR  srt --settings ~/.srt-settings.json claude [args]
    # See: https://github.com/anthropic-experimental/sandbox-runtime
    bubblewrap # Required by srt on Linux - https://github.com/containers/bubblewrap
    socat # Required by srt for proxy bridging
    (pkgs.writeShellScriptBin "srt" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes @anthropic-ai/sandbox-runtime@${npmVersions.srt} "$@"
    '')
    # Claude Autonomous Workflow Trilogy
    # 1. claude-autonomous - Single task launcher (foundation)
    # 2. claude-night-batch - Multi-task batch launcher from manifest
    # 3. claude-morning-review - Review and merge overnight work
    # See: scripts/claude-*.sh for documentation
    (pkgs.writeShellScriptBin "claude-autonomous" (builtins.readFile ../../scripts/claude-autonomous.sh))
    (pkgs.writeShellScriptBin "claude-night-batch" (builtins.readFile ../../scripts/claude-night-batch.sh))
    (pkgs.writeShellScriptBin "claude-morning-review" (builtins.readFile ../../scripts/claude-morning-review.sh))

    # AI Tools - Pinned versions for reproducibility (see npm-versions.nix)
    # Claude Flow - AI orchestration platform
    (pkgs.writeShellScriptBin "claude-flow" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes claude-flow@${npmVersions.claude-flow} "$@"
    '')
    # BMAD-METHOD - Universal AI agent framework for Agentic Agile Driven Development
    (pkgs.writeShellScriptBin "bmad-method" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes bmad-method@${npmVersions.bmad-method} "$@"
    '')
    # Gemini CLI - Google's Gemini CLI
    (pkgs.writeShellScriptBin "gemini-cli" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes @google/gemini-cli@${npmVersions.gemini-cli} "$@"
    '')
    # Jules - Google's asynchronous coding agent CLI
    (pkgs.writeShellScriptBin "jules" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes @google/jules@${npmVersions.jules} "$@"
    '')
    # OpenSpec - Spec-driven development for AI coding assistants
    (pkgs.writeShellScriptBin "openspec" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes @fission-ai/openspec@${npmVersions.openspec} "$@"
    '')
    # Agent Browser - Vercel Labs headless browser CLI for AI agents
    # Uses system Chrome to avoid NixOS binary compatibility issues
    playwright-driver.browsers # Provides Playwright-managed browsers for NixOS
    (pkgs.writeShellScriptBin "agent-browser" ''
      export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
      export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
      exec ${pkgs.nodejs_20}/bin/npx --yes agent-browser@${npmVersions.agent-browser} "$@"
    '')

    # NOTE: Linggen (linggen.dev) - macOS only, Linux "coming soon"
    # Install manually when available: curl -sSL https://linggen.dev/install-cli.sh | bash

    # NOTE: Superset (superset.sh) - Electron desktop app, macOS only
    # Requires: git clone, bun install, bun run build
    # Alternative: Use git worktrees manually for parallel Claude Code sessions

    # Serena MCP Server - Semantic code analysis toolkit (tracks GitHub main)
    (pkgs.writeShellScriptBin "serena" ''
      exec ${pkgs.nix}/bin/nix run github:oraios/serena -- "$@"
    '')
    # Spec-Kit - GitHub's Spec-Driven Development workflow (tracks git main)
    (pkgs.writeShellScriptBin "specify" ''
      exec ${pkgs.uv}/bin/uvx --python ${pkgs.python312}/bin/python --from git+https://github.com/github/spec-kit.git specify "$@"
    '')
    # Droid - Factory.ai's #1 Terminal-Bench AI development agent (always latest)
    (pkgs.writeShellScriptBin "droid" ''
      #!${pkgs.stdenv.shell}
      set -e

      # Factory.ai Droid CLI wrapper for NixOS
      # This wrapper ensures Droid is installed and properly configured

      DROID_VERSION="latest"
      DROID_HOME="''${DROID_HOME:-$HOME/.droid}"
      DROID_CONFIG="''${DROID_CONFIG:-$HOME/.config/factory}"

      # Ensure required directories exist
      mkdir -p "$DROID_HOME"
      mkdir -p "$DROID_CONFIG"

      # Function to check if Droid is installed
      check_installation() {
        if [ -f "$DROID_HOME/bin/droid" ]; then
          return 0
        elif [ -f "$HOME/.local/bin/droid" ]; then
          # Move to standard location
          mkdir -p "$DROID_HOME/bin"
          mv "$HOME/.local/bin/droid" "$DROID_HOME/bin/droid" 2>/dev/null || true
          return 0
        fi
        return 1
      }

      # Function to install Droid
      install_droid() {
        echo "🤖 Installing Factory.ai Droid CLI..."
        echo "This is a one-time setup process."
        echo ""

        # Ensure we have the required tools
        export PATH="${pkgs.lib.makeBinPath [ pkgs.nodejs_20 pkgs.xdg-utils pkgs.curl ]}:$PATH"
        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        # Create temp directory for installation
        INSTALL_TMP=$(mktemp -d)
        cd "$INSTALL_TMP"

        # Download and run the installer
        echo "Downloading Droid installer..."
        if curl -fsSL https://app.factory.ai/cli -o installer.sh; then
          # Modify installer to use our preferred directory
          sed -i "s|~/.local/bin|$DROID_HOME/bin|g" installer.sh 2>/dev/null || true

          # Run the installer
          chmod +x installer.sh
          DROID_INSTALL_DIR="$DROID_HOME" bash installer.sh || {
            echo "❌ Installation failed. Please try again or install manually."
            rm -rf "$INSTALL_TMP"
            exit 1
          }
        else
          echo "❌ Failed to download Droid installer."
          rm -rf "$INSTALL_TMP"
          exit 1
        fi

        # Clean up
        rm -rf "$INSTALL_TMP"

        echo "✅ Droid installation complete!"
        echo ""
      }

      # Main execution
      if ! check_installation; then
        echo "🔍 Droid is not installed. Installing automatically..."
        install_droid
      fi

      # Ensure environment is properly set
      export PATH="${pkgs.lib.makeBinPath [ pkgs.nodejs_20 pkgs.xdg-utils ]}:$PATH"
      export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

      # Execute Droid with all arguments
      if [ -f "$DROID_HOME/bin/droid" ]; then
        exec "$DROID_HOME/bin/droid" "$@"
      else
        echo "❌ Droid executable not found at $DROID_HOME/bin/droid"
        echo "Please run 'droid' again to reinstall."
        exit 1
      fi
    '')
    atuin # Neural network-powered shell history
    broot # Interactive tree navigation with fuzzy search

    # Speech-to-Text (Acqua Voice-like dictation system)
    # DISABLED: GCC 15 incompatibility in ctranslate2 (missing #include <cstdint> in cxxopts)
    # inputs.whisper-dictation.packages.${pkgs.stdenv.hostPlatform.system}.default # Whisper Dictation - local STT with push-to-talk
    whisper-cpp # High-performance C++ port of OpenAI Whisper for local STT

    # MCP NixOS Server - Model Context Protocol for NixOS package/option info (uvx auto-updates)
    (pkgs.writeShellScriptBin "mcp-nixos" ''
      export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
      exec ${pkgs.uv}/bin/uvx --python ${pkgs.python312}/bin/python mcp-nixos "$@"
    '')
    git # A free and open source distributed version control system - https://git-scm.com/
    gh # GitHub's official command-line tool - https://cli.github.com/
    google-cloud-sdk # Google Cloud SDK for gcloud CLI and cloud operations
    wget # A free software package for retrieving files using HTTP, HTTPS, FTP and FTPS - https://www.gnu.org/software/wget/
    fish # A smart and user-friendly command line shell - https://fishshell.com/
    eza # A modern replacement for ls - https://eza.rocks/
    gedit # The official text editor of the GNOME desktop environment - https://wiki.gnome.org/Apps/Gedit
    jq # JSON processor - essential for development
    ripgrep # Super fast grep (rg command)
    fd # Modern find alternative
    bat # Better cat with syntax highlighting

    # Create fdfind symlink for yazi compatibility
    (pkgs.runCommand "fdfind" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.fd}/bin/fd $out/bin/fdfind
    '')

    # Core development tools (for instant AI agent commands)
    nodejs_20 # Node.js 20.19.4 with npm - eliminates devenv activation overhead
    (python3.withPackages (ps: with ps; [
      rich # Rich - Python terminal UI library (for BASB system)
      pymupdf4llm # PyMuPDF for LLM-optimized PDF processing
      # markitdown # DISABLED: pulls in ctranslate2 which fails on GCC 15
      pytest # Testing framework for Python
      pydantic # Data validation using Python type hints
      jinja2 # Jinja2 templating engine (for claude-nixos-automation)
    ])) # Python 3 with rich included (system-wide, avoids tkinter issues in devenv)
    gcc # GCC compiler for native dependencies
    gnumake # GNU Make for build systems
    ninja # Build system for faster compilation (required by numpy/aider)
    pkg-config # Package config tool for native module builds

    # Development environment management (completes AI agent optimization)
    direnv # Automatic per-directory environment activation - enables .envrc
    devenv # Fast, declarative development environments - instant service commands
    cachix # Binary cache for faster Nix builds - system-wide availability

    # system tools
    fastfetch # A neofetch-like tool for fetching system information and displaying them in a pretty way
    gparted # A free partition editor for graphically managing your disk partitions - https://gparted.org/
    usbimager # A minimalist GUI application to write compressed disk images to USB drives
    p7zip # A file archiver with a high compression ratio - https://www.7-zip.org/
    android-tools # Android SDK platform tools (adb, fastboot) - replaces programs.adb since systemd 258
    wl-clipboard # Wayland clipboard utilities (wl-copy, wl-paste) - enables screenshot paste
    rclone # Cloud storage sync and mount tool - Google Drive, S3, etc. - https://rclone.org/
    # smart-office-open: Opens office files - Google native (0 byte) in browser, others with OnlyOffice
    (pkgs.writeShellScriptBin "smart-office-open" (builtins.readFile ../../scripts/smart-office-open.sh))

    # productivity tools
    kooha # Elegantly record your screen (Wayland-native, minimal UI) - https://github.com/SeaDve/Kooha
    google-chrome # Google's web browser - https://www.google.com/chrome/
    obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files - https://obsidian.md/
    anki-bin # A program which makes remembering things easy - https://apps.ankiweb.net/
    gimp-with-plugins # The GNU Image Manipulation Program, with a set of popular plugins - https://www.gimp.org/
    vlc # A free and open source cross-platform multimedia player and framework - https://videolan.org/vlc/
    onlyoffice-desktopeditors # Office suite with document, spreadsheet, presentation editing - https://www.onlyoffice.com/
    # libreoffice         # A powerful and free office suite - DISABLED: no binary cache (30+ min build)

    # fonts
    dejavu_fonts # A font family based on the Vera Fonts
    roboto # Google's signature font family
    jetbrains-mono # JetBrains Mono - programming font with ligatures and better readability
    nerd-fonts.jetbrains-mono # JetBrains Mono Nerd Font - adds programming icons and symbols
    noto-fonts-color-emoji # Color emoji support for terminals and applications

    # Claude Code performance optimization tools
    sqlite # Database for project indexing and analysis
    hyperfine # Precise command benchmarking
    tokei # Fast code statistics (lines, languages)
    dust # Modern disk usage analyzer (faster than du)
    tmux # Session persistence and parallel operations
    procs # Modern process viewer (better than ps)
    entr # File watcher for automated rebuilds/tests
    just # Modern command runner (better than make)
    bottom # Modern system monitor (btm command)
    ast-grep # Structural search and replace for code
    semgrep # Static analysis for pattern matching
    xh # Fast HTTPie alternative in Rust
    delta # Better git diff viewer
    lazygit # Simple terminal UI for git

    # Additional AI workflow enhancement tools
    vhs # Terminal session recording for AI workflow documentation

    # Database development tools (AI-friendly CLI clients)
    pgcli # PostgreSQL client with autocompletion and syntax highlighting
    mycli # MySQL/MariaDB client with smart completion
    usql # Universal database CLI for multiple database types

    # Advanced API development
    hurl # HTTP testing with file-based test definitions

    # Note: Some code quality tools are better managed per-project (devenv/package.json)
    # gitleaks, typos are better managed per-project for:
    # - Custom configurations (.gitleaksignore)
    # - Project-specific rules and dictionaries
    # - Team collaboration and reproducibility
    # However, pre-commit is useful system-wide for NixOS configs

    # Code Quality & Analysis Tools (Enterprise-grade)
    pre-commit # Git hook framework (needed for .pre-commit-config.yaml)
    python312Packages.lizard # Code complexity analysis (CCN < 10) - integrates with Cursor AI quality gates
    python312Packages.radon # Python code metrics and complexity analysis
    # jscpd - JavaScript/TypeScript clone detection (pinned version)
    (pkgs.writeShellScriptBin "jscpd" ''
      exec ${pkgs.nodejs_20}/bin/npx --yes jscpd@${npmVersions.jscpd} "$@"
    '')
    ruff # Lightning-fast Python linter/formatter
    uv # Extremely fast Python package manager (provides uvx for MCP servers)
    docker-compose # Container orchestration
    k9s # Kubernetes cluster management
    podman # Docker alternative
    nmap # Network discovery and security auditing
    wireshark # Network protocol analyzer
    tcpdump # Command-line packet analyzer

    # NordVPN via WireGuard
    wgnord # NordVPN WireGuard (NordLynx) client in POSIX shell
    wireguard-tools # WireGuard utilities for VPN management
    openresolv # DNS management for VPN connections
    strace # System call tracer
    (ltrace.overrideAttrs (old: { doCheck = false; })) # Library call tracer (tests disabled - flaky)
    jless # JSON viewer (better than jq for large files)
    yq-go # YAML/XML processor (like jq for YAML)
    miller # CSV/JSON/YAML data processing
    zoxide # Smarter cd command (z replacement)
    starship # Cross-shell prompt
    choose # Human-friendly cut/awk alternative
    shellcheck # Shell script linter
    shfmt # Shell formatter
    nixpkgs-fmt # Nix code formatter (for pre-commit hooks)
    nvd # NixOS package version diff tool (used by rebuild-nixos)
    nix-output-monitor # Beautiful build tree visualization (nom command, used by rebuild-nixos)

    # useseless tools
    cmatrix # A terminal-based "Matrix" screen saver

    # file searchers and visualizers
    fzf # A command-line fuzzy finder
    gum # Interactive prompts and beautiful CLI forms for shell scripts
    yazi # A modern terminal file manager
    yaziPlugins.rich-preview # Rich preview for Yazi
    rich-cli # Rich command-line interface for rich preview
    glow # Markdown renderer
    pandoc # Universal document converter (MD to PPTX/PDF/HTML)

    # PDF to Markdown converters (AI-optimized document processing)
    # Marker - High-accuracy PDF to Markdown with table/formula support (uses uvx for latest)
    (pkgs.writeShellScriptBin "marker" ''
      export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
      exec ${pkgs.uv}/bin/uvx --python ${pkgs.python312}/bin/python marker-pdf "$@"
    '')
    ueberzugpp # Successor to ueberzug for image previews
    bat # A cat clone with wings

    # Essential dependencies for yazi preview functionality
    file # File type detection (essential for yazi)
    ffmpegthumbnailer # Video thumbnails for yazi
    poppler-utils # PDF preview utilities
    imagemagick # Image processing for previews

    # File viewers and openers for yazi
    eog # Eye of GNOME - default GNOME image viewer
    feh # Lightweight image viewer (yazi secondary opener)
    kdePackages.okular # Full-featured PDF viewer with annotations
    file-roller # Archive manager for GNOME
  ];
}
