{
  description = "AI Quality DevEnv Template - Hybrid Approach";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    devenv.flake = false;
  };

  outputs = { self, nixpkgs, devenv, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Development shell for nix develop users
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Core development tools
          nodejs_20
          python313
          git
          # Quality gates
          gitleaks
          semgrep
          lizard
          nodePackages.jscpd
          ruff
          nodePackages.eslint
          nodePackages.prettier
        ];

        shellHook = ''
          echo "🚀 AI Quality DevEnv Template (Flake Mode)"
          echo "💡 For enhanced experience, use: devenv shell"
          echo "📋 Quality gates available via git hooks"
        '';
      };

      # Package outputs for building/deployment
      packages.${system} = {
        # Add your package definitions here
        # default = ...;
      };

      # Template configuration
      templates.default = {
        path = ./.;
        description = "AI Quality development environment with comprehensive quality gates";
      };
    };
}