{
  description = "My NixOS Flake Configuration";

  # Enable evaluation caching for 60-80% faster repeated evaluations
  nixConfig = {
    eval-cache = true;
    tarball-ttl = 3600; # Cache flake inputs for 1 hour
  };

  inputs = {
    # UPDATE POLICY:
    # - nixpkgs/home-manager: Updated automatically by system (weekly/monthly)
    # - External GitHub inputs: Updated via `./rebuild-nixos` (uses --refresh for locally-maintained)
    # - Path inputs: Track local development, no pinning needed
    # - Review flake.lock monthly for security updates
    # - Last manual review: 2025-11-20

    # Nix Packages collection (nixos-unstable = latest stable packages)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (official stable, follows nixpkgs for compatibility)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code - Better packaged version with Node.js bundled
    # MAINTAINER: @sadjow | AUTO-UPDATE: Via rebuild-nixos --refresh
    # Current: c06fdde (locked via flake.lock)
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Cursor - AI Code Editor (you are the maintainer)
    # MAINTAINER: @jacopone (YOU) | AUTO-UPDATE: Via rebuild-nixos --refresh
    # Current: cbe5b8b (locked via flake.lock)
    # Includes Chrome for Browser Automation support
    code-cursor-nix = {
      url = "github:jacopone/code-cursor-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Whisper Dictation - Local speech-to-text (your project)
    # MAINTAINER: @jacopone (YOU) | AUTO-UPDATE: Via rebuild-nixos --refresh
    # For local dev, use: nix flake lock --override-input whisper-dictation path:../whisper-dictation
    whisper-dictation = {
      url = "github:jacopone/whisper-dictation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude NixOS Automation - CLAUDE.md management tools
    # MAINTAINER: @jacopone (YOU) | AUTO-UPDATE: Via rebuild-nixos --refresh
    claude-automation = {
      url = "github:jacopone/claude-nixos-automation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Google Antigravity - Next-generation agentic IDE
    # MAINTAINER: @jacopone (YOU) | AUTO-UPDATE: Via rebuild-nixos --refresh
    # For local dev, use: nix flake lock --override-input antigravity-nix path:../antigravity-nix
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTE: mcps.nix removed - requires pkgs.mcp-servers which isn't in nixpkgs yet
    # Revisit when mcp-servers package is available in nixpkgs
    # For now, using manual .mcp.json configuration

  };

  outputs = { self, nixpkgs, home-manager, claude-code-nix, code-cursor-nix, whisper-dictation, claude-automation, antigravity-nix, ... }@inputs:
    let
      system = "x86_64-linux";

      # CONFIGURATION: Change this username to match your system
      # This is the ONLY place you need to change when adapting this config
      username = "guyfawkes";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Expose packages for `nix build` (none currently)
      packages.${system} = { };

      # Your NixOS system configuration
      nixosConfigurations = {
        # Hostname is set to "nixos"
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs username; }; # Pass inputs and username to your config
          modules = [
            # Your main configuration file
            ./hosts/nixos

            # Allow unfree packages
            {
              nixpkgs.config.allowUnfree = true;
            }

            # Home Manager module (optional)
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs username; };
              # The path to your home-manager config (modular organization in modules/home-manager/)
              home-manager.users.${username} = import ./modules/home-manager;
            }
          ];
        };
      };
    };
}
