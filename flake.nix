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
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # Your NixOS system configuration
    nixosConfigurations = {
      # Hostname is set to "nixos"
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # Pass inputs to your config
        modules = [
          # Your main configuration file
          ./hosts/nixos

          # Home Manager module (optional)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # The path to your home-manager config, username is set to "guyfawkes"
            home-manager.users.guyfawkes = import ./users/guyfawkes/home.nix;
          }
        ];
      };
    };
  };
}
