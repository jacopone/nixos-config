---
status: active
created: 2025-12-18
updated: 2025-12-18
type: guide
lifecycle: persistent
---

# Installation Guide

Complete guide for installing and configuring this NixOS configuration.

## Prerequisites

### System Requirements

- **Fresh NixOS installation** (minimal or desktop ISO)
- **Flakes enabled** (see below)
- **8GB RAM minimum** (16GB recommended for parallel builds)
- **20GB free disk space** (for Nix store)
- **Internet connection** for package downloads

### Enable Flakes

Add this to `/etc/nixos/configuration.nix` before proceeding:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then rebuild: `sudo nixos-rebuild switch`

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### Step 2: Generate Hardware Configuration

```bash
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
```

This captures your specific hardware (CPU, GPU, disks, etc.).

### Step 3: Customize Username

Replace the default username throughout the config:

```bash
# Replace 'guyfawkes' with your username
sed -i 's/guyfawkes/yourusername/g' flake.nix hosts/nixos/default.nix
```

### Step 4: Review Boot Configuration

Check `hosts/nixos/default.nix` for boot loader settings:

```nix
# For EFI (most modern systems - 2012+)
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# For BIOS/Legacy (older systems)
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";  # Your boot disk
```

### Step 5: Apply Configuration

```bash
./rebuild-nixos
```

The interactive script will:
1. Validate configuration syntax (`nix flake check`)
2. Test build without activation (catches errors early)
3. Prompt for confirmation before applying
4. Update Claude Code configurations automatically
5. Offer to commit changes to git
6. Display rollback instructions

**First build time**: ~20-30 minutes depending on internet speed.

## Post-Installation

### Verify Installation

```bash
# Check system generation
nixos-version

# Verify tools are available
fd --version
bat --version
rg --version

# Check Claude Code integration
cat ~/.claude/CLAUDE.md | head -20
```

### Set Up Claude Code (Optional)

If you use Claude Code:

```bash
# Claude Code will automatically read:
# - ~/.claude/CLAUDE.md (system-level, auto-generated)
# - ./CLAUDE.md (project-level, auto-generated)
```

No manual setup needed - the rebuild script handles everything.

### Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## Troubleshooting

### Build Fails

```bash
# View detailed error
nix log /nix/store/xxx-nixos-system-xxx.drv

# Rollback to previous working system
sudo nixos-rebuild switch --rollback
```

### Memory Issues

Large builds may exhaust RAM. Try:

```bash
# Reduce parallelism
sudo nixos-rebuild switch --flake . --cores 2 --max-jobs 1

# Add swap temporarily
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Missing Hardware Support

If hardware isn't detected:

```bash
# Regenerate hardware config
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix

# For specific hardware (NVIDIA, etc.), check profiles/
ls profiles/
```

### Network Issues During Build

```bash
# Use a mirror
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update

# Or specify substituter
sudo nixos-rebuild switch --flake . --option substituters "https://cache.nixos.org"
```

### EFI vs BIOS Detection

```bash
# Check if system uses EFI
[ -d /sys/firmware/efi ] && echo "EFI" || echo "BIOS"
```

## Customization

### Adding System Packages

Edit `modules/core/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  your-package
];
```

### Adding User Packages

Edit `modules/home-manager/base.nix`:

```nix
home.packages = with pkgs; [
  # User-specific packages
  your-user-package
];
```

### Per-Project Environments

Use DevEnv for project-specific tools:

```bash
cd your-project
devenv init
# Edit devenv.nix, then:
devenv shell
```

## Updating

### Regular Updates

```bash
cd ~/nixos-config
./rebuild-nixos
```

### Update Flake Inputs

```bash
nix flake update
./rebuild-nixos
```

### Update Specific Input

```bash
nix flake lock --update-input nixpkgs
./rebuild-nixos
```

## Uninstallation

This config doesn't modify your base NixOS installation destructively. To revert:

```bash
# Switch back to default NixOS config
sudo nixos-rebuild switch -I nixos-config=/etc/nixos

# Or restore from a previous generation
sudo nixos-rebuild switch --rollback
```

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/jacopone/nixos-config/issues)
- **NixOS Manual**: [nixos.org/manual](https://nixos.org/manual/nixos/stable/)
- **Nix Pills**: [nixos.org/guides/nix-pills](https://nixos.org/guides/nix-pills/)
- **NixOS Discourse**: [discourse.nixos.org](https://discourse.nixos.org/)
