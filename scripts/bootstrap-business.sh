#!/usr/bin/env bash
# Bootstrap a fresh NixOS install into a business workstation profile.
# Run this after connecting via RustDesk to a plain NixOS install.
#
# Usage: sudo bash bootstrap-business.sh <hostname> [username]
#   hostname: flake host name (e.g., hp-pietro)
#   username: optional, auto-detected from current user if omitted
#
# Prerequisites:
#   - Fresh NixOS install with flakes enabled
#   - Internet connection
#   - Running as root (sudo)

set -euo pipefail

REPO_URL="https://github.com/jacopone/nixos-config.git"
NIXOS_DIR="/etc/nixos"

# --- Parse arguments ---
HOSTNAME="${1:-}"
USERNAME="${2:-$(logname 2>/dev/null || echo "$SUDO_USER")}"

if [[ -z "$HOSTNAME" ]]; then
    echo "Usage: sudo bash bootstrap-business.sh <hostname> [username]"
    echo ""
    echo "Available business hosts:"
    echo "  hp-pietro    - HP workstation for Pietro"
    echo ""
    echo "Username defaults to the current logged-in user: $USERNAME"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: run with sudo"
    exit 1
fi

echo "========================================"
echo "  Business NixOS Bootstrap"
echo "========================================"
echo "  Hostname: $HOSTNAME"
echo "  Username: $USERNAME"
echo "  Repo:     $REPO_URL"
echo "========================================"
echo ""
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# --- Step 1: Install git ---
echo ""
echo "[1/5] Installing git..."
if ! command -v git &>/dev/null; then
    nix-env -iA nixos.git
    echo "  git installed."
else
    echo "  git already available."
fi

# --- Step 2: Backup and clone ---
echo ""
echo "[2/5] Cloning nixos-config..."
if [[ -d "$NIXOS_DIR/.git" ]]; then
    echo "  $NIXOS_DIR is already a git repo, pulling latest..."
    git -C "$NIXOS_DIR" pull
else
    # Backup existing config
    if [[ -f "$NIXOS_DIR/configuration.nix" ]]; then
        echo "  Backing up existing configuration.nix..."
        cp "$NIXOS_DIR/configuration.nix" "$NIXOS_DIR/configuration.nix.backup"
    fi
    if [[ -f "$NIXOS_DIR/hardware-configuration.nix" ]]; then
        echo "  Backing up existing hardware-configuration.nix..."
        cp "$NIXOS_DIR/hardware-configuration.nix" "$NIXOS_DIR/hardware-configuration.nix.detected"
    fi

    # Clone into /etc/nixos
    rm -rf "${NIXOS_DIR:?}/.git"
    git clone "$REPO_URL" "${NIXOS_DIR}.tmp"
    # Move contents (preserving backups)
    cp -a "${NIXOS_DIR}.tmp/." "$NIXOS_DIR/"
    rm -rf "${NIXOS_DIR}.tmp"
    echo "  Cloned into $NIXOS_DIR"
fi

# --- Step 3: Generate hardware config ---
echo ""
echo "[3/5] Generating hardware configuration..."
HOST_DIR="$NIXOS_DIR/hosts/$HOSTNAME"

if [[ ! -d "$HOST_DIR" ]]; then
    echo "  Error: host directory $HOST_DIR does not exist."
    echo "  Available hosts:"
    ls -1 "$NIXOS_DIR/hosts/"
    exit 1
fi

nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware-configuration.nix"
echo "  Hardware config written to $HOST_DIR/hardware-configuration.nix"

# --- Step 4: Verify username match ---
echo ""
echo "[4/5] Verifying username..."
if id "$USERNAME" &>/dev/null; then
    echo "  User '$USERNAME' exists on this system."
else
    echo "  WARNING: User '$USERNAME' does not exist on this system!"
    echo "  The flake will create it with initialPassword 'changeme'."
    read -rp "  Continue anyway? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# Check the flake expects this username
if grep -q "username = \"$USERNAME\"" "$NIXOS_DIR/flake.nix"; then
    echo "  Username '$USERNAME' matches flake.nix entry."
else
    echo "  WARNING: flake.nix may not have username = \"$USERNAME\" for host $HOSTNAME."
    echo "  Check flake.nix before continuing."
    read -rp "  Continue anyway? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# --- Step 5: Rebuild ---
echo ""
echo "[5/5] Rebuilding NixOS with business profile..."
echo "  Running: nixos-rebuild switch --flake $NIXOS_DIR#$HOSTNAME"
echo ""
nixos-rebuild switch --flake "$NIXOS_DIR#$HOSTNAME"

echo ""
echo "========================================"
echo "  Bootstrap complete!"
echo "========================================"
echo ""
echo "  Next steps:"
echo "  1. Tell the user to change their password: passwd"
echo "  2. Reboot to apply all changes"
echo "  3. Commit hardware-configuration.nix back to the repo"
echo ""
