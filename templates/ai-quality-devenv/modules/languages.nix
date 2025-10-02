{ pkgs, lib, config, ... }:

{
  # https://devenv.sh/languages/
  languages.javascript = {
    enable = true;
    npm = {
      enable = true;
      install.enable = true;
    };
  };

  languages.python = {
    enable = true;
    uv.enable = true;
    uv.sync.enable = true;
  };
}
