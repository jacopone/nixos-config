---
status: active
created: 2025-12-18
updated: 2026-02-13
type: guide
lifecycle: persistent
---

# Installation Guide

Complete guide for installing NixOS and configuring this flake-based system.

## Table of Contents

- [Fresh Installation (New Machine)](#fresh-installation-new-machine)
  - [Create Bootable USB](#step-1-create-bootable-usb)
  - [Boot and Partition](#step-2-boot-and-partition)
  - [Install Base NixOS](#step-3-install-base-nixos)
  - [Migrate to This Flake](#step-4-migrate-to-this-flake)
- [Remote Business Deployment](#remote-business-deployment)
  - [Build the Installer ISO](#step-1-build-the-installer-iso)
  - [Prepare the Business Host](#step-2-prepare-the-business-host)
  - [Remote Install via RustDesk](#step-3-remote-install-via-rustdesk)
- [Framework 16 Specific](#framework-16-specific-instructions)
- [Existing NixOS Migration](#existing-nixos-migration)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

---

## Fresh Installation (New Machine)

Use this section when installing NixOS on a new machine from scratch.

### Prerequisites

- NixOS ISO downloaded from [nixos.org/download](https://nixos.org/download/)
- USB drive (4GB+ recommended)
- Internet connection (Ethernet or WiFi)

### Step 1: Create Bootable USB

On an existing Linux/NixOS machine:

```bash
# Find your USB device
lsblk -d -o NAME,SIZE,MODEL,TRAN | grep usb

# Unmount if mounted (replace sdX with your device)
sudo umount /dev/sdX1

# Write ISO to USB (replace paths accordingly)
sudo dd if=~/Downloads/nixos-*.iso of=/dev/sdX bs=4M status=progress conv=fsync

# Ensure all data is written
sync
```

**Alternative (simpler):**
```bash
sudo cp ~/Downloads/nixos-*.iso /dev/sdX && sync
```

### Step 2: Boot and Partition

1. **Boot from USB**: Insert USB, restart, enter BIOS (F2/F12/DEL), select USB boot
2. **Connect to network**:
   - Ethernet: Automatic
   - WiFi: `nmcli device wifi connect "SSID" password "password"`

3. **Partition the disk** (for UEFI systems - most modern hardware):

```bash
# Identify your target disk
lsblk

# For NVMe drives (common in laptops like Framework)
DISK=/dev/nvme0n1

# Create GPT partition table
sudo parted $DISK -- mklabel gpt

# Create root partition (all space except first 512MB)
sudo parted $DISK -- mkpart root ext4 512MB 100%

# Create EFI boot partition (first 512MB)
sudo parted $DISK -- mkpart ESP fat32 1MB 512MB
sudo parted $DISK -- set 2 esp on

# Format partitions
sudo mkfs.ext4 -L nixos ${DISK}p1
sudo mkfs.fat -F 32 -n boot ${DISK}p2
```

**For BTRFS with snapshots** (optional, advanced):
```bash
sudo mkfs.btrfs -L nixos ${DISK}p1
sudo mount ${DISK}p1 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo umount /mnt
sudo mount -o subvol=@,compress=zstd ${DISK}p1 /mnt
sudo mkdir -p /mnt/{home,nix,boot}
sudo mount -o subvol=@home,compress=zstd ${DISK}p1 /mnt/home
sudo mount -o subvol=@nix,compress=zstd ${DISK}p1 /mnt/nix
sudo mount ${DISK}p2 /mnt/boot
```

**For ext4** (simpler):
```bash
# Mount partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

### Step 3: Install Base NixOS

```bash
# Generate initial configuration
sudo nixos-generate-config --root /mnt

# Edit configuration to enable flakes and networking
sudo nano /mnt/etc/nixos/configuration.nix
```

Add these lines to the configuration:

```nix
# Enable flakes
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Enable NetworkManager for WiFi
networking.networkmanager.enable = true;

# Add a user (replace 'yourusername')
users.users.yourusername = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  initialPassword = "changeme";  # Change after first login!
};

# Allow unfree packages (needed for NVIDIA, etc.)
nixpkgs.config.allowUnfree = true;
```

```bash
# Install NixOS
sudo nixos-install

# Set root password when prompted
# Reboot
sudo reboot
```

### Step 3.5: Bootstrap Claude Code (Optional but Recommended)

Before migrating to the full flake, install a minimal set of tools on the base NixOS.
This gives you Claude Code for AI-assisted debugging if the flake migration has issues
(e.g., slow WiFi, download failures, hardware quirks).

```bash
# Login with your user and change password
passwd

# Edit the base NixOS config to add bootstrap tools
sudo nano /etc/nixos/configuration.nix
```

Add these lines to the configuration:

```nix
# Bootstrap packages (remove after flake migration)
environment.systemPackages = with pkgs; [
  git
  nodejs_22
  google-chrome
  nano
  curl
  pciutils  # for lspci (needed to find GPU bus IDs)
];

# Required for Google Chrome
nixpkgs.config.allowUnfree = true;

# Fix download issues on WiFi (IPv6 half-working causes failures)
networking.enableIPv6 = false;

# Enable GNOME desktop (so you have a browser + terminal)
services.xserver.enable = true;
services.xserver.displayManager.gdm.enable = true;
services.xserver.desktopManager.gnome.enable = true;
```

```bash
# Rebuild base system (this is a small download - no flake, just a few packages)
sudo nixos-rebuild switch

# Reboot into GNOME desktop
sudo reboot
```

After rebooting into the GNOME desktop:

```bash
# Open a terminal (search "Terminal" in GNOME Activities)

# Login to Google Chrome first - sync your passwords and extensions

# Run Claude Code (npx downloads the latest version and runs it)
npx @anthropic-ai/claude-code@latest

# Claude Code will open Chrome for authentication on first run
# Once authenticated, you have AI assistance for the rest of the install
```

> **Tip**: If WiFi is unstable, use USB phone tethering. Plug your phone in,
> enable USB tethering, and NetworkManager will pick it up automatically.

### Step 4: Migrate to This Flake

With Claude Code available (or on your own), proceed with the flake migration:

```bash
# Clone this repository
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config

# Generate hardware configuration for YOUR machine
# Choose the appropriate host directory:
#   - hosts/nixos/ for generic machines
#   - hosts/framework-16/ for Framework Laptop 16
sudo nixos-generate-config --show-hardware-config > hosts/YOUR-HOST/hardware-configuration.nix

# Customize username in flake.nix (if different from 'guyfawkes')
# Edit flake.nix and change: username = "guyfawkes"; → username = "yourusername";

# Build and switch to the flake configuration
sudo nixos-rebuild switch --flake .#YOUR-HOST

# Reboot to apply all changes
sudo reboot
```

---

## Remote Business Deployment

Deploy NixOS on a remote business user's machine without them touching a terminal.
Uses a custom live ISO with RustDesk pre-installed for remote access.

### Prerequisites

- This flake repo cloned on the tech admin's machine
- Business user has a USB drive (4GB+) and internet connection
- A way to communicate during setup (phone call, video chat)

### Step 1: Build the Installer ISO

On the tech admin's machine:

```bash
cd ~/nixos-config

# Build the custom ISO (includes GNOME installer + RustDesk)
nix build .#business-installer-iso

# ISO output location:
ls -lh result/iso/
# Example: result/iso/nixos-gnome-26.05.20260208-x86_64-linux.iso
```

Send the ISO to the business user (cloud storage, WeTransfer, etc.).

**Flashing the USB (business user does this):**

The business user installs [Balena Etcher](https://etcher.balena.io/) (Windows/macOS/Linux), then:
1. Open Etcher
2. Click "Flash from file" → select the ISO
3. Click "Select target" → pick their USB drive
4. Click "Flash!"

### Step 2: Prepare the Business Host

Before the remote session, create a host config for the business user's machine.

```bash
cd ~/nixos-config

# Copy the template
cp -r hosts/business-template hosts/<model-username>

# Add to flake.nix under nixosConfigurations:
```

```nix
# Example: Dell Latitude for user mario
dell-latitude-mario = mkBusinessHost {
  hostname = "dell-latitude-mario";
  username = "mario";
};
```

```bash
# Validate syntax
nix flake check --no-build

# Commit and push so you can clone it during remote install
git add hosts/<model-username> flake.nix
git commit -m "feat: add business host <model-username>"
git push
```

> **Note**: `hardware-configuration.nix` in the template is a placeholder.
> It gets replaced with the real one during remote install (Step 3).

### Step 3: Remote Install via RustDesk

Walk the business user through these steps over a phone/video call:

1. **Boot from USB** — plug in USB, restart, enter BIOS (F2/F12/DEL), select USB boot
2. **Connect to WiFi** — click the WiFi icon in the GNOME top bar
3. **Run Calamares installer** — click "Install NixOS" on the desktop, follow the wizard:
   - Language, timezone, keyboard
   - "Erase disk" for partitioning (simplest option)
   - Set username and password (must match `username` in flake.nix)
   - Click Install, wait for completion
4. **Do NOT reboot** when Calamares says "All done"
5. **Open RustDesk** — click Activities, type "RustDesk", open it
6. **Read you the ID and password** displayed in RustDesk

Once connected via RustDesk, the tech admin takes over:

```bash
# Open a terminal in the live session

# Find and mount the installed system's partitions
lsblk  # identify the installed root and boot partitions

# For a typical Calamares UEFI install:
sudo mount /dev/sda2 /mnt        # root (adjust device as needed)
sudo mount /dev/sda1 /mnt/boot   # EFI boot partition

# Generate hardware config for this specific machine
sudo nixos-generate-config --root /mnt

# Backup the Calamares-generated config, clone the flake
sudo mv /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix.calamares
cd /mnt/etc/nixos
sudo git clone https://github.com/jacopone/nixos-config.git .

# Copy the real hardware config into the host directory
sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/<model-username>/hardware-configuration.nix

# Install using the flake
sudo nixos-install --root /mnt --flake .#<model-username> --no-root-passwd
```

Tell the business user to reboot. They boot into the full business profile with
Chrome, VS Code, OnlyOffice, RustDesk, and all configured tools.

### Post-Deployment

After the first real boot, connect via RustDesk again to:

- Configure WiFi (if not auto-detected)
- Sign into Google Chrome and other accounts
- Set up Git credentials for the business user
- Commit the real `hardware-configuration.nix` back to the repo

```bash
# On your machine, pull the hardware config
cd ~/nixos-config
# Copy hardware-configuration.nix from the business machine
# Commit it so future rebuilds work
git add hosts/<model-username>/hardware-configuration.nix
git commit -m "feat: add hardware config for <model-username>"
git push
```

---

## Framework 16 Specific Instructions

The Framework Laptop 16 (AMD Ryzen AI + NVIDIA RTX) has dedicated support.

### Hardware Configuration

```bash
# Generate hardware config specifically for Framework 16
sudo nixos-generate-config --show-hardware-config > hosts/framework-16/hardware-configuration.nix
```

### NVIDIA PRIME Bus IDs

After installation, find the correct PCI bus IDs:

```bash
# Find GPU bus IDs
lspci | grep -E "VGA|3D"

# Example output:
# 01:00.0 3D controller: NVIDIA Corporation...  → nvidiaBusId
# c1:00.0 VGA compatible: AMD/ATI...            → amdgpuBusId

# Convert hex to decimal (for c1 → 193)
echo "ibase=16; C1" | bc
```

Update `hosts/framework-16/default.nix`:

```nix
hardware.nvidia.prime = {
  amdgpuBusId = "PCI:193:0:0";  # Update with your value
  nvidiaBusId = "PCI:1:0:0";    # Update with your value
};
```

### Build for Framework 16

```bash
sudo nixos-rebuild switch --flake .#framework-16
```

### Framework-Specific Features

This config includes (via `nixos-hardware`):
- AMD Ryzen AI 9 HX 370 optimizations
- NVIDIA RTX 5070 driver support
- Power management and battery optimization
- WiFi 7 (AMD RZ717) support
- Fingerprint reader support
- Ambient light sensor
- Framework EC module for battery limits

### Firmware Updates

After installation, update Framework firmware:

```bash
# Enable fwupd (already in config)
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update
```

**Warning**: Keep a NixOS USB handy - some firmware updates may require recovery boot.

---

## Existing NixOS Migration

If you already have NixOS installed (without flakes):

### Step 1: Enable Flakes

Add to `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Rebuild: `sudo nixos-rebuild switch`

### Step 2: Clone and Configure

```bash
git clone https://github.com/jacopone/nixos-config.git ~/nixos-config
cd ~/nixos-config

# Generate hardware config
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix

# Customize username
sed -i 's/guyfawkes/yourusername/g' flake.nix

# Apply
sudo nixos-rebuild switch --flake .#nixos
```

---

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

### Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### First Rebuild with Script

```bash
cd ~/nixos-config
./rebuild-nixos
```

The interactive script will:
1. Validate configuration syntax
2. Test build without activation
3. Prompt for confirmation
4. Update Claude Code configurations
5. Offer to commit changes

---

## Troubleshooting

### Build Fails

```bash
# View detailed error
nix log /nix/store/xxx-nixos-system-xxx.drv

# Rollback to previous working system
sudo nixos-rebuild switch --rollback
```

### Downloads Failing (HTTP 206 / Slow Downloads)

Common during fresh installs on WiFi. Symptoms: floods of `HTTP error 206`,
`Failed sending data to the peer`, `retrying from offset` messages.

```bash
# Fix 1: Disable IPv6 (most common cause)
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Fix 2: Disable WiFi power saving (replace wlpXXXs0 with your interface from `ip link`)
nix-shell -p iw --run "sudo iw dev wlpXXXs0 set power_save off"

# Fix 3: Reduce download parallelism
sudo nixos-rebuild switch --flake .#YOUR-HOST -j 1

# Fix 4: Use USB phone tethering (most reliable)
# Plug phone via USB, enable USB tethering, NetworkManager auto-detects it

# Fix 5: Change DNS
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
```

> **Warning**: Do NOT use `--fallback` unless you're prepared to wait hours.
> It compiles packages from source (LLVM alone takes 30-60 min).

### WiFi Not Working (Live USB)

```bash
# List networks
nmcli device wifi list

# Connect
nmcli device wifi connect "SSID" password "password"

# Or use wpa_supplicant directly
wpa_passphrase "SSID" "password" | sudo tee /etc/wpa_supplicant.conf
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
sudo dhclient wlan0
```

### Memory Issues During Build

```bash
# Reduce parallelism
sudo nixos-rebuild switch --flake . --cores 2 --max-jobs 1

# Add swap temporarily
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### NVIDIA Issues (Framework 16)

```bash
# Check if NVIDIA module loaded
lsmod | grep nvidia

# Check PRIME status
prime-offload status

# Run app on NVIDIA GPU
prime-run glxinfo | grep "OpenGL renderer"
```

### Boot Issues After Firmware Update

If Framework won't boot after firmware update:

1. Boot from NixOS USB
2. Mount your system:
   ```bash
   sudo mount /dev/disk/by-label/nixos /mnt
   sudo mount /dev/disk/by-label/boot /mnt/boot
   ```
3. Enter the system:
   ```bash
   sudo nixos-enter
   ```
4. Reinstall bootloader:
   ```bash
   NIXOS_INSTALL_BOOTLOADER=1 /run/current-system/bin/switch-to-configuration boot
   ```
5. Reboot

### EFI vs BIOS Detection

```bash
[ -d /sys/firmware/efi ] && echo "EFI" || echo "BIOS"
```

---

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/jacopone/nixos-config/issues)
- **NixOS Manual**: [nixos.org/manual](https://nixos.org/manual/nixos/stable/)
- **NixOS Hardware**: [github.com/NixOS/nixos-hardware](https://github.com/NixOS/nixos-hardware)
- **Framework Community**: [community.frame.work](https://community.frame.work/)
- **NixOS Discourse**: [discourse.nixos.org](https://discourse.nixos.org/)
