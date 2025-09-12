{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # dev tools
    helix               # A post-modern modal text editor - https://helix-editor.com/
    zed-editor          # A high-performance, multiplayer code editor - https://zed.dev/
    vscode-fhs          # Visual Studio Code in an FHS-like environment - https://code.visualstudio.com/
    code-cursor         # An AI-powered code editor based on VSCode - https://cursor.so/
    plandex             # An open-source, terminal-based AI coding agent - https://plandex.ai/
    claude-code         # A code-generation tool using Anthropic's Claude model
    # Claude Flow - AI orchestration platform (alpha version via npx)
    (pkgs.writeShellScriptBin "claude-flow" ''
      exec ${pkgs.nodejs_20}/bin/npx claude-flow@alpha "$@"
    '')
    gemini-cli          # A command-line interface for Google's Gemini models
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
    tree                # Directory visualization  
    htop                # Better system monitoring
    ripgrep             # Super fast grep (rg command)
    fd                  # Modern find alternative
    bat                 # Better cat with syntax highlighting
    
    # Create fdfind symlink for yazi compatibility
    (pkgs.runCommand "fdfind" {} ''
      mkdir -p $out/bin
      ln -s ${pkgs.fd}/bin/fd $out/bin/fdfind
    '')
    docker
    
    # Core development tools (for instant AI agent commands)
    nodejs_20           # Node.js 20.19.4 with npm - eliminates devenv activation overhead
    python3             # Python for build scripts and native modules
    gcc                 # GCC compiler for native dependencies
    gnumake             # GNU Make for build systems
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
    
    # Additional Claude Code enhancement packages
    postgresql         # Database operations and schema analysis
    redis              # In-memory data operations
    ruff               # Lightning-fast Python linter/formatter
    uv                 # Ultra-fast Python package manager
    yarn               # Alternative Node.js package manager
    pnpm               # Efficient Node.js package manager
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
    ncdu                # NCurses Disk Usage
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
