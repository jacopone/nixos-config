# Starship prompt configuration
{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$git_metrics$character";

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold bright-blue";
        truncation_length = 4;
        truncate_to_repo = true;
        fish_style_pwd_dir_length = 1;
        read_only = " 󰌾";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style = "bold purple";
        truncation_length = 25;
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bright-red";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        conflicted = "≠$count";
        deleted = "✘$count";
        renamed = "»$count";
        modified = "✱$count";
        staged = "✚$count";
        untracked = "?$count";
        stashed = "📦$count";
      };

      git_metrics = {
        format = "(\\(+$added/-$deleted\\) )";
        added_style = "bright-green";
        deleted_style = "bright-red";
        disabled = false;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
      
      # Performance optimization
      scan_timeout = 10;
      command_timeout = 500;
      
      # Additional Nerd Font symbols for other modules
      aws = {
        symbol = "  ";
      };
      
      buf = {
        symbol = " ";
      };
      
      bun = {
        symbol = " ";
      };
      
      cmake = {
        symbol = " ";
      };
      
      crystal = {
        symbol = " ";
      };
      
      dart = {
        symbol = " ";
      };
      
      deno = {
        symbol = " ";
      };
      
      elixir = {
        symbol = " ";
      };
      
      elm = {
        symbol = " ";
      };
      
      fennel = {
        symbol = " ";
      };
      
      fossil_branch = {
        symbol = " ";
      };
      
      gcloud = {
        symbol = "  ";
      };
      
      git_commit = {
        tag_symbol = "  ";
      };
      
      guix_shell = {
        symbol = " ";
      };
      
      haxe = {
        symbol = " ";
      };
      
      hg_branch = {
        symbol = " ";
      };
      
      hostname = {
        ssh_symbol = " ";
      };
      
      julia = {
        symbol = " ";
      };
      
      lua = {
        symbol = " ";
      };
      
      memory_usage = {
        symbol = "󰍛 ";
      };
      
      meson = {
        symbol = "󰔷 ";
      };
      
      nim = {
        symbol = "󰆥 ";
      };
      
      nix_shell = {
        symbol = " ";
      };
      
      ocaml = {
        symbol = " ";
      };
      
      package = {
        symbol = "󰏗 ";
      };
      
      perl = {
        symbol = " ";
      };
      
      pijul_channel = {
        symbol = " ";
      };
      
      pixi = {
        symbol = "󰏗 ";
      };
      
      rlang = {
        symbol = "󰟔 ";
      };
      
      ruby = {
        symbol = " ";
      };
      
      scala = {
        symbol = " ";
      };
      
      swift = {
        symbol = " ";
      };
      
      zig = {
        symbol = " ";
      };
      
      gradle = {
        symbol = " ";
      };
    };
  };

  # You can also manage settings for other programs, for example:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your@email.com";
  # };
}
