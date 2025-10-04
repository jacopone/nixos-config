{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # dev tools
    helix               # A post-modern modal text editor - https://helix-editor.com/
    zed-editor          # A high-performance, multiplayer code editor - https://zed.dev/
    vscode-fhs          # Visual Studio Code in an FHS-like environment - https://code.visualstudio.com/
    inputs.code-cursor-nix.packages.${pkgs.system}.cursor   # Cursor - Auto-updating AI Code Editor - https://cursor.com/
    plandex             # An open-source, terminal-based AI coding agent - https://plandex.ai/
    inputs.claude-code-nix.packages.${pkgs.system}.default  # A code-generation tool using Anthropic's Claude model (better packaged)
    # Claude Flow - AI orchestration platform (alpha version via npx)
    (pkgs.writeShellScriptBin "claude-flow" ''
      exec ${pkgs.nodejs_20}/bin/npx claude-flow@alpha "$@"
    '')
    gemini-cli-bin      # A command-line interface for Google's Gemini models (v0.6.0)
    google-jules        # Jules, the asynchronous coding agent from Google (CLI)

    # AI Development Enhancement Tools
    (pkgs.writeShellScriptBin "aider" ''
      exec ${pkgs.uv}/bin/uvx --python ${pkgs.python312}/bin/python --from aider-chat aider "$@"
    '')
    # Serena MCP Server - Semantic code analysis toolkit for coding agents
    (pkgs.writeShellScriptBin "serena" ''
      exec ${pkgs.nix}/bin/nix run github:oraios/serena -- "$@"
    '')
    atuin               # Neural network-powered shell history
    broot               # Interactive tree navigation with fuzzy search

    # Speech-to-Text (Acqua Voice-like dictation system)
    inputs.whisper-dictation.packages.${pkgs.system}.default  # Whisper Dictation - local STT with push-to-talk
    whisper-cpp         # High-performance C++ port of OpenAI Whisper for local STT

    # MCP NixOS Server - Model Context Protocol for NixOS package/option info
    (pkgs.writeShellScriptBin "mcp-nixos" ''
      exec ${pkgs.uv}/bin/uvx mcp-nixos "$@"
    '')
    git                 # A free and open source distributed version control system - https://git-scm.com/
    gh                  # GitHub's official command-line tool - https://cli.github.com/
    wget                # A free software package for retrieving files using HTTP, HTTPS, FTP and FTPS - https://www.gnu.org/software/wget/
    fish                # A smart and user-friendly command line shell - https://fishshell.com/
    fishPlugins.z       # A z-like directory jumping plugin for fish
    warp-terminal       # A blazingly fast, Rust-based terminal reimagined from the ground up - https://www.warp.dev/
    eza                 # A modern replacement for ls - https://eza.rocks/
    peco                # Simplistic interactive filtering tool
    gedit               # The official text editor of the GNOME desktop environment - https://wiki.gnome.org/Apps/Gedit
    jq                  # JSON processor - essential for development
    ripgrep             # Super fast grep (rg command)
    fd                  # Modern find alternative
    bat                 # Better cat with syntax highlighting
    
    # Create fdfind symlink for yazi compatibility
    (pkgs.runCommand "fdfind" {} ''
      mkdir -p $out/bin
      ln -s ${pkgs.fd}/bin/fd $out/bin/fdfind
    '')
    
    # Core development tools (for instant AI agent commands)
    nodejs_20           # Node.js 20.19.4 with npm - eliminates devenv activation overhead
    (python3.withPackages (ps: with ps; [
      rich              # Rich - Python terminal UI library (for BASB system)
    ]))                 # Python 3 with rich included (system-wide, avoids tkinter issues in devenv)
    python312Packages.pymupdf4llm  # PyMuPDF for LLM-optimized PDF processing
    gcc                 # GCC compiler for native dependencies
    gnumake             # GNU Make for build systems
    ninja               # Build system for faster compilation (required by numpy/aider)
    pkg-config          # Package config tool for native module builds
    
    # Development environment management (completes AI agent optimization)
    direnv              # Automatic per-directory environment activation - enables .envrc
    devenv              # Fast, declarative development environments - instant service commands
    cachix              # Binary cache for faster Nix builds - system-wide availability

    # system tools
    fastfetch           # A neofetch-like tool for fetching system information and displaying them in a pretty way
    pydf                # A df-like utility that displays disk usage in a more human-readable format
    gparted             # A free partition editor for graphically managing your disk partitions - https://gparted.org/
    gtop                # A system monitoring dashboard for your terminal
    usbimager           # A minimalist GUI application to write compressed disk images to USB drives
    p7zip               # A file archiver with a high compression ratio - https://www.7-zip.org/

    # productivity tools
    google-chrome       # Google's web browser - https://www.google.com/chrome/
    obsidian            # A powerful knowledge base that works on top of a local folder of plain text Markdown files - https://obsidian.md/
    anki-bin            # A program which makes remembering things easy - https://apps.ankiweb.net/
    gimp-with-plugins   # The GNU Image Manipulation Program, with a set of popular plugins - https://www.gimp.org/
    vlc                 # A free and open source cross-platform multimedia player and framework - https://videolan.org/vlc/
    libreoffice         # A powerful and free office suite - https://www.libreoffice.org/

    # fonts
    dejavu_fonts        # A font family based on the Vera Fonts
    roboto              # Google's signature font family
    jetbrains-mono      # JetBrains Mono - programming font with ligatures and better readability
    nerd-fonts.jetbrains-mono # JetBrains Mono Nerd Font - adds programming icons and symbols

    # Claude Code performance optimization tools
    sqlite             # Database for project indexing and analysis
    hyperfine          # Precise command benchmarking
    tokei              # Fast code statistics (lines, languages)
    dust               # Modern disk usage analyzer (faster than du)
    tmux               # Session persistence and parallel operations
    parallel           # GNU parallel for concurrent execution
    procs              # Modern process viewer (better than ps)
    entr               # File watcher for automated rebuilds/tests
    watchman           # Facebook's file watching service
    just               # Modern command runner (better than make)
    dua                # Tool to conveniently learn about disk usage of directories
    bottom             # Modern system monitor (btm command)
    ast-grep           # Structural search and replace for code
    semgrep            # Static analysis for pattern matching
    httpie             # Better HTTP client for API testing
    xh                 # Fast HTTPie alternative in Rust
    delta              # Better git diff viewer
    gitui              # Terminal git UI
    lazygit            # Simple terminal UI for git
    duf                # Modern df alternative with color
    
    # Additional AI workflow enhancement tools
    vhs                # Terminal session recording for AI workflow documentation
    mcfly              # Smart command history search with neural networks

    # Database development tools (AI-friendly CLI clients)
    pgcli              # PostgreSQL client with autocompletion and syntax highlighting
    mycli              # MySQL/MariaDB client with smart completion
    usql               # Universal database CLI for multiple database types

    # Advanced API development
    hurl               # HTTP testing with file-based test definitions

    # Note: Code quality tools moved to project-level (devenv/package.json)
    # gitleaks, pre-commit, typos are better managed per-project for:
    # - Custom configurations (.gitleaksignore, .pre-commit-config.yaml)
    # - Project-specific rules and dictionaries
    # - Team collaboration and reproducibility

    # Code Quality & Analysis Tools (Enterprise-grade)
    python312Packages.lizard # Code complexity analysis (CCN < 10) - integrates with Cursor AI quality gates
    python312Packages.radon # Python code metrics and complexity analysis
    # jscpd - JavaScript/TypeScript clone detection via npm
    (pkgs.writeShellScriptBin "jscpd" ''
      exec ${pkgs.nodejs_20}/bin/npx jscpd "$@"
    '')
    ruff               # Lightning-fast Python linter/formatter
    docker-compose     # Container orchestration
    k9s                # Kubernetes cluster management
    podman             # Docker alternative
    nmap               # Network discovery and security auditing
    wireshark          # Network protocol analyzer
    tcpdump            # Command-line packet analyzer
    strace             # System call tracer
    ltrace             # Library call tracer
    csvkit             # CSV manipulation tools
    jless              # JSON viewer (better than jq for large files)
    yq-go              # YAML/XML processor (like jq for YAML)
    miller             # CSV/JSON/YAML data processing
    zoxide             # Smarter cd command (z replacement)
    starship           # Cross-shell prompt
    skim               # Fuzzy finder (fzf alternative)
    choose             # Human-friendly cut/awk alternative
    shellcheck         # Shell script linter
    shfmt              # Shell formatter
    
    # useseless tools
    cmatrix             # A terminal-based "Matrix" screen saver

    # file searchers and visualizers
    fzf                 # A command-line fuzzy finder
    gum                 # Interactive prompts and beautiful CLI forms for shell scripts
    yazi                # A modern terminal file manager
    yaziPlugins.rich-preview # Rich preview for Yazi
    rich-cli            # Rich command-line interface for rich preview
    glow                # Markdown renderer
    ueberzugpp          # Successor to ueberzug for image previews
    bat                 # A cat clone with wings
    
    # Essential dependencies for yazi preview functionality
    file                # File type detection (essential for yazi)
    ffmpegthumbnailer   # Video thumbnails for yazi
    poppler_utils       # PDF preview utilities
    imagemagick         # Image processing for previews
    
    # File viewers and openers for yazi
    eog                 # Eye of GNOME - default GNOME image viewer
    feh                 # Fast, keyboard-driven image viewer
    sxiv                # Simple X Image Viewer with thumbnails
    sioyek              # Modern PDF viewer for technical documents
    mupdf               # Fast PDF renderer and viewer
    kdePackages.okular  # Full-featured PDF viewer with annotations
    file-roller         # Archive manager for GNOME
  ];
}
