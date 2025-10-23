{
  description = "My NixOS Flake Configuration";

  inputs = {
    # Nix Packages collection
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (optional, but recommended)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code - Better packaged version with Node.js bundled
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Cursor - AI Code Editor (you are the maintainer)
    code-cursor-nix = {
      url = "github:jacopone/code-cursor-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Whisper Dictation - Local speech-to-text (your project)
    whisper-dictation = {
      url = "path:/home/guyfawkes/whisper-dictation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude NixOS Automation - CLAUDE.md management tools
    claude-automation = {
      url = "github:jacopone/claude-nixos-automation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, claude-code-nix, code-cursor-nix, whisper-dictation, claude-automation, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ self.overlays.default ];
    };
  in
  {
    # Overlays for custom packages (none currently - using npx/@latest for AI tools)
    overlays.default = final: prev: {};

    # Expose packages for `nix build` (none currently)
    packages.${system} = {};

    # Your NixOS system configuration
    nixosConfigurations = {
      # Hostname is set to "nixos"
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # Pass inputs to your config
        modules = [
          # Your main configuration file
          ./hosts/nixos

          # Apply overlays and allow unfree packages
          {
            nixpkgs.overlays = [ self.overlays.default ];
            nixpkgs.config.allowUnfree = true;
          }

          # Home Manager module (optional)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            # The path to your home-manager config, username is set to "guyfawkes"
            home-manager.users.guyfawkes = import ./users/guyfawkes/home.nix;
          }
        ];
      };
    };
  };
}
