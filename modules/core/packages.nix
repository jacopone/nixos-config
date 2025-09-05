{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # dev tools
    helix               # A post-modern modal text editor - https://helix-editor.com/
    zed-editor          # A high-performance, multiplayer code editor - https://zed.dev/
    vscode-fhs          # Visual Studio Code in an FHS-like environment - https://code.visualstudio.com/
    code-cursor         # An AI-powered code editor based on VSCode - https://cursor.so/
    plandex             # An open-source, terminal-based AI coding agent - https://plandex.ai/
    claude-code         # A code-generation tool using Anthropic's Claude model
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
    vlc                 # A free and open source cross-platform multimedia player and framework - https://www.videolan.org/vlc/
    libreoffice         # A powerful and free office suite - https://www.libreoffice.org/

    # fonts
    dejavu_fonts        # A font family based on the Vera Fonts
    roboto              # Google's signature font family

    # useseless tools
    cmatrix             # A terminal-based "Matrix" screen saver
  ];
}
