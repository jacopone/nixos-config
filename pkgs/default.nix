{ pkgs, ... }: {
  brownkit = pkgs.callPackage ./brownkit.nix { };
  handy = pkgs.callPackage ./handy.nix { };
}
