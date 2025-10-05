{ config, pkgs, lib, inputs, ... }:

{
  environment.systemPackages = [
    inputs.ai-project-orchestration.packages.${pkgs.system}.default
  ];

  # Optional: Add shell aliases for convenience
  programs.bash.shellAliases = {
    ai-init-green = "ai-init-greenfield";
    ai-init-brown = "ai-init-brownfield";
    ai-rescue = "ai-init-brownfield";
  };

  programs.fish.shellAliases = {
    ai-init-green = "ai-init-greenfield";
    ai-init-brown = "ai-init-brownfield";
    ai-rescue = "ai-init-brownfield";
  };

  # Documentation hint
  environment.etc."ai-project-orchestration-docs".source =
    "${inputs.ai-project-orchestration.packages.${pkgs.system}.default}/share/ai-project-orchestration/docs";
}
