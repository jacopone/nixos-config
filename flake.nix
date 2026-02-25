{
  description = "My NixOS Flake Configuration";

  # Nix configuration for this flake
  # NOTE: eval-cache is NOT set here - managed by rebuild-nixos --fresh flag
  # This prevents phantom generations where cached evaluations mask config changes
  nixConfig = {
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

    # NixOS Hardware - vendor-specific optimizations
    # Provides modules for Framework, ThinkPad, Dell, and many other vendors
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    # NixClaw - Personal AI agent platform for NixOS
    # MAINTAINER: @jacopone (YOU) | LOCAL DEV: path input
    # TEMPORARILY DISABLED: path input breaks on machines without ~/nixclaw
    # Re-enable when published to GitHub: url = "github:jacopone/nixclaw";
    # nixclaw = {
    #   url = "path:/home/guyfawkes/nixclaw";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # NOTE: mcps.nix removed - requires pkgs.mcp-servers which isn't in nixpkgs yet
    # Revisit when mcp-servers package is available in nixpkgs
    # For now, using manual .mcp.json configuration

  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, claude-code-nix, code-cursor-nix, whisper-dictation, claude-automation, antigravity-nix, ... }@inputs:
    let
      # Shared overlay: fix test failures / missing deps in nixos-unstable
      # Uses interpreter override (not overrideScope) so python3.withPackages sees fixes
      pyFixups = pyFinal: pyPrev: {
        llm = pyPrev.llm.overridePythonAttrs (old: { doCheck = false; });
        picosvg = pyPrev.picosvg.overridePythonAttrs (old: { doCheck = false; });
        pymupdf4llm = pyPrev.pymupdf4llm.overridePythonAttrs (old: {
          dependencies = (old.dependencies or [ ]) ++ [ pyFinal.tabulate ];
        });
      };
      gccFixOverlay = final: prev: {
        python313 = prev.python313.override { packageOverrides = pyFixups; };
        python312 = prev.python312.override { packageOverrides = pyFixups; };
      };

      # Tech profile helper — full power-user setup (350+ packages, AI orchestration)
      mkTechHost = { hostname, username, system ? "x86_64-linux", extraModules ? [ ] }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Host-specific configuration
          ./hosts/${hostname}

          # Allow unfree packages + overlays
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              gccFixOverlay
              # VibeTyper - AI voice typing with speech-to-text
              (import ./overlays/vibetyper.nix)
            ];
          }

          # NixClaw AI agent (services.nixclaw options)
          # TEMPORARILY DISABLED: nixclaw input commented out
          # nixclaw.nixosModules.default

          # Home Manager module (tech profile)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username; };
            home-manager.users.${username} = import ./modules/home-manager;
          }
        ] ++ extraModules;
      };

      # Business profile helper — curated setup (~40 packages, office + learning to code)
      mkBusinessHost = { hostname, username, system ? "x86_64-linux", extraModules ? [ ] }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Host-specific configuration
          ./hosts/${hostname}

          # Allow unfree packages + GCC fix overlay
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              gccFixOverlay
            ];
          }

          # Home Manager module (business profile)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username; };
            home-manager.users.${username} = import ./modules/business/home-manager;
          }
        ] ++ extraModules;
      };

    in
    {
      # Expose packages for `nix build`
      packages.x86_64-linux = {
        # Custom installer ISO with RustDesk for remote business setup
        # Build: nix build .#business-installer-iso
        business-installer-iso = self.nixosConfigurations.business-installer.config.system.build.isoImage;

        # T2 Mac installer ISO — Apple keyboard/trackpad/SSD work out of the box
        # Build: nix build .#t2-installer-iso
        t2-installer-iso = self.nixosConfigurations.t2-installer.config.system.build.isoImage;
      };

      # NixOS System Configurations
      # Each host can be built with: nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = {

        # ── Tech workstations ──────────────────────────────────────────

        # ThinkPad X1 Carbon (Intel UHD 620 + 8-core)
        # Build: nixos-rebuild switch --flake .#thinkpad-x1-jacopo
        thinkpad-x1-jacopo = mkTechHost {
          hostname = "thinkpad-x1-jacopo";
          username = "guyfawkes";
        };

        # Framework Laptop 16 (AMD Ryzen AI 9 HX 370 + NVIDIA RTX 5070)
        # Build: nixos-rebuild switch --flake .#tech-001
        tech-001 = mkTechHost {
          hostname = "tech-001";
          username = "guyfawkes";
          extraModules = [
            # NixOS Hardware module for Framework 16 with AMD AI 300 + NVIDIA
            nixos-hardware.nixosModules.framework-16-amd-ai-300-series-nvidia
          ];
        };

        # ── Business workstations ──────────────────────────────────────

        # Template for new business deployments
        # Usage: cp -r hosts/business-template hosts/biz-NNN
        #        Then add: biz-NNN = mkBusinessHost { hostname = "biz-NNN"; username = "name"; };
        # Build: nixos-rebuild switch --flake .#business-template
        business-template = mkBusinessHost {
          hostname = "business-template";
          username = "user";
        };

        # ThinkPad X1 Carbon (Intel UHD 620 + 8-core) — business profile
        # Build: nixos-rebuild switch --flake .#biz-001
        biz-001 = mkBusinessHost {
          hostname = "biz-001";
          username = "guyfawkes";
        };

        # HP workstation for Pietro
        # Build: nixos-rebuild switch --flake .#biz-002
        biz-002 = mkBusinessHost {
          hostname = "biz-002";
          username = "pietro";
        };

        # MacBook Air 2018 (Intel, T2 chip) — business profile
        # Build: nixos-rebuild switch --flake .#biz-003
        biz-003 = mkBusinessHost {
          hostname = "biz-003";
          username = "guyfawkes";
          extraModules = [
            nixos-hardware.nixosModules.apple-t2
          ];
        };

        # MacBook Air 7,2 (Early 2015, Intel Broadwell) — business profile
        # Build: nixos-rebuild switch --flake .#biz-004
        biz-004 = mkBusinessHost {
          hostname = "biz-004";
          username = "bernie";
          extraModules = [
            nixos-hardware.nixosModules.apple-macbook-air-7
          ];
        };

        # ── Installer ISOs ─────────────────────────────────────────

        # Generic business installer with RustDesk for remote setup
        # Build ISO: nix build .#business-installer-iso
        # Flow: business user boots USB → Calamares install → opens RustDesk → tech admin takes over
        business-installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            ({ pkgs, ... }: {
              environment.systemPackages = with pkgs; [
                rustdesk-flutter # Remote desktop (TeamViewer-like)
                git # For cloning flake repo during install
              ];
            })
          ];
        };

        # T2 Mac installer — patched for Apple keyboard, trackpad, and NVMe
        # Build ISO: nix build .#t2-installer-iso
        # Flow: boot USB on MacBook → CLI install → reboot → plug ethernet → flake rebuild
        t2-installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            nixos-hardware.nixosModules.apple-t2
            # Broadcom WiFi+BT firmware (Apple servers return 403, using GitHub mirror)
            ./overlays/apple-bcm-firmware.nix
            ({ pkgs, ... }: {
              # Force-load T2 modules in initrd: keyboard, trackpad, SSD, WiFi
              boot.initrd.kernelModules = [ "apple-bce" ];
              boot.kernelModules = [ "apple-bce" "hid_apple" "brcmfmac" ];

              # Ensure all other firmware is available too
              hardware.enableAllFirmware = true;
              hardware.enableRedistributableFirmware = true;

              # iwd backend — wpa_supplicant 2.11 has a T2 Broadcom regression
              networking.networkmanager.wifi.backend = "iwd";
              networking.wireless.iwd.enable = true;
              boot.kernelParams = [ "brcmfmac.feature_disable=0x82000" ];

              # Apple keyboard tweaks for the live environment
              boot.extraModprobeConfig = ''
                options hid_apple fnmode=2
                options hid_apple swap_opt_cmd=1
              '';

              # Pre-installed tools for manual CLI install + WiFi debugging
              environment.systemPackages = with pkgs; [
                git
                gh
                google-chrome
                inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
                rustdesk-flutter
                iw # WiFi debugging
                wirelesstools # iwconfig
              ];

              # Enable flakes in the live environment
              nix.settings.experimental-features = [ "nix-command" "flakes" ];

              nixpkgs.config.allowUnfree = true;
            })
          ];
        };

      };
    };
}
