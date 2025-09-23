{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.chrome-profiles;

  # Chrome profile configuration type
  profileType = types.submodule {
    options = {
      extensions = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of extension IDs to install for this profile";
        example = [ "dbepggeogbaibhgnhhndojpepiihcmeb" ];
      };

      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Chrome settings specific to this profile";
        example = {
          "BookmarkBarEnabled" = false;
          "DefaultZoomLevel" = 1.1;
        };
      };

      profileName = mkOption {
        type = types.str;
        description = "Human-readable profile name";
        example = "Personal Gmail";
      };

      accountType = mkOption {
        type = types.enum [ "consumer" "enterprise" ];
        default = "consumer";
        description = "Account type for policy compatibility";
      };
    };
  };

  # Generate policy JSON for a profile
  generateProfilePolicy = profileId: profile: {
    name = "chrome-policy-${profileId}";
    value = pkgs.writeTextFile {
      name = "chrome-policy-${profileId}.json";
      text = builtins.toJSON {
        ExtensionInstallForcelist = profile.extensions;
      } // (if profile.accountType == "consumer" then {} else profile.settings);
    };
  };

  # Generate all profile policy files
  profilePolicyFiles = mapAttrs' generateProfilePolicy cfg.profiles;

in {
  options.programs.chrome-profiles = {
    enable = mkEnableOption "profile-specific Chrome management";

    profiles = mkOption {
      type = types.attrsOf profileType;
      default = {};
      description = "Chrome profiles with their specific configurations";
      example = literalExpression ''
        {
          personal-gmail = {
            profileName = "Personal Gmail";
            accountType = "consumer";
            extensions = [
              "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
              "nkbihfbeogaeaoehlefnkodbefgpgknn" # MetaMask
            ];
          };
          business = {
            profileName = "Business Profile";
            accountType = "enterprise";
            extensions = [
              "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
              "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
            ];
            settings = {
              "BookmarkBarEnabled" = true;
            };
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install Chrome
    environment.systemPackages = [ pkgs.google-chrome ];

    # Create profile-specific policy directories
    environment.etc =
      let
        # Create policy files for each profile
        createProfilePolicy = profileId: profile:
          let
            policyContent = {
              ExtensionInstallForcelist = profile.extensions;
            } // (if profile.accountType == "consumer" then {} else profile.settings);
          in {
            "opt/chrome/policies/managed/profile-${profileId}.json" = {
              text = builtins.toJSON policyContent;
              mode = "0644";
            };
          };
      in
        lib.foldr (a: b: a // b) {} (lib.mapAttrsToList createProfilePolicy cfg.profiles);

    # Create profile mapping documentation
    environment.etc."opt/chrome/policies/profile-mapping.json" = {
      text = builtins.toJSON {
        profiles = mapAttrs (id: profile: {
          name = profile.profileName;
          accountType = profile.accountType;
          extensions = profile.extensions;
          managedBy = "NixOS chrome-profiles module";
        }) cfg.profiles;
        generated = "NixOS";
        timestamp = "system-build-time";
      };
      mode = "0644";
    };

    # Documentation and helper scripts
    environment.etc."opt/chrome/policies/README.md" = {
      text = ''
        # Chrome Profile-Specific Policies

        This directory contains Chrome policies managed by NixOS chrome-profiles module.

        ## Profile Configuration

        ${concatStringsSep "\n" (mapAttrsToList (id: profile: ''
        ### ${profile.profileName} (${id})
        - **Account Type**: ${profile.accountType}
        - **Extensions**: ${toString (length profile.extensions)} extensions
        - **Policy File**: profile-${id}.json
        '') cfg.profiles)}

        ## How It Works

        Chrome reads policies from /etc/opt/chrome/policies/managed/ directory.
        Each profile gets its own policy file with specific extensions and settings.

        ## Viewing Applied Policies

        1. Open Chrome with desired profile
        2. Navigate to chrome://policy
        3. Check ExtensionInstallForcelist policy

        ## Configuration

        Edit your NixOS configuration at:
        programs.chrome-profiles.profiles.{profile-name}

        Then rebuild: sudo nixos-rebuild switch --flake .
      '';
      mode = "0644";
    };
  };
}