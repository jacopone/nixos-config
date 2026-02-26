---
status: active
created: 2026-02-25
updated: 2026-02-26
type: guide
lifecycle: persistent
---

# Machine Restore Guide

Restore a full NixOS workstation from Google Drive backups and this git repo.

## Backup Structure

Google Drive path: `gdrive:backups/<hostname>/`

```
backups/
├── MACHINE_RESTORE.md          # This guide (auto-synced)
└── thinkpad-x1-jacopo/         # (or framework-16, biz-003, etc.)
    ├── ssh/                     # SSH keys, config, known_hosts
    ├── gh/                      # GitHub CLI auth tokens
    ├── gnupg/                   # GPG keys and trust database
    ├── rclone/                  # rclone remote definitions
    ├── claude/                  # Claude Code settings, permissions, sessions, memory
    ├── atuin/                   # Shell command history (Atuin)
    ├── fish/                    # Fish shell config
    ├── gcloud/                  # Google Cloud SDK config
    ├── keyrings/                # GNOME keyrings (WiFi passwords, etc.)
    ├── local-bin/               # Custom scripts (~/.local/bin)
    ├── whatsapp-db/             # WhatsApp message archive
    ├── bimby-nutritionist/      # Bimby recipes database
    ├── yuka-db/                 # Yuka food/cosmetics DB
    ├── gitignored-critical/     # Albo data, .env files
    ├── birthday-manager/        # Birthday events database
    ├── pta-ledger/              # PTA financial ledger
    ├── gogcli/                  # Google Suite CLI credentials
    └── ...                      # Other data (Downloads, Pictures, etc.)
```

Backups run automatically once per day via `backup-configs` systemd timer (defined in `modules/home-manager/cloud-storage/backup-sync.nix`). Run `systemctl --user start backup-configs` for an immediate sync before travel or risky changes.

## Prerequisites

- NixOS live USB (or existing NixOS install)
- Internet connection
- Google account access (for rclone OAuth)

## Step 1: Bootstrap rclone

rclone config is on Google Drive, so bootstrap manually first:

```bash
# On the live ISO or fresh install
nix-shell -p rclone

# Create a new Google Drive remote (interactive OAuth flow)
rclone config
# Choose: n (new remote) → name: gdrive → type: drive → follow OAuth prompts
```

## Step 2: Restore configs from Google Drive

```bash
# Decide source: use the hostname of the machine you're restoring FROM
SOURCE_HOST="thinkpad-x1-jacopo"  # or whichever backup to restore

# SSH keys (restore first - needed for git clone)
mkdir -p ~/.ssh && chmod 700 ~/.ssh
rclone sync "gdrive:backups/$SOURCE_HOST/ssh/" ~/.ssh/
chmod 600 ~/.ssh/id_* 2>/dev/null
chmod 644 ~/.ssh/*.pub 2>/dev/null

# GitHub CLI
mkdir -p ~/.config/gh
rclone sync "gdrive:backups/$SOURCE_HOST/gh/" ~/.config/gh/

# GPG keys
mkdir -p ~/.gnupg && chmod 700 ~/.gnupg
rclone sync "gdrive:backups/$SOURCE_HOST/gnupg/" ~/.gnupg/

# Claude Code config
mkdir -p ~/.claude
rclone sync "gdrive:backups/$SOURCE_HOST/claude/" ~/.claude/

# Atuin shell history
mkdir -p ~/.local/share/atuin
rclone sync "gdrive:backups/$SOURCE_HOST/atuin/" ~/.local/share/atuin/

# Fish config
mkdir -p ~/.config/fish
rclone sync "gdrive:backups/$SOURCE_HOST/fish/" ~/.config/fish/

# GNOME keyrings (WiFi passwords, etc.)
mkdir -p ~/.local/share/keyrings
rclone sync "gdrive:backups/$SOURCE_HOST/keyrings/" ~/.local/share/keyrings/

# Custom scripts
mkdir -p ~/.local/bin
rclone sync "gdrive:backups/$SOURCE_HOST/local-bin/" ~/.local/bin/
```

## Step 3: Clone and install NixOS config

```bash
# Test SSH access to GitHub
ssh -T git@github.com

# If SSH fails, use HTTPS for initial clone
git clone https://github.com/jacopone/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config
git checkout personal

# For a fresh install (partitions already formatted and mounted on /mnt):
sudo nixos-install --flake .#<host-name>

# For an existing install (rebuild in place):
# Copy repo to final location first
# sudo nixos-rebuild switch --flake .#<host-name>
```

## Step 3.5: Clone repos and restore project data

After NixOS is rebuilt and you've logged in:

```bash
cd ~/nixos-config

# Clone all GitHub repos + restore gitignored data (databases, .env files)
./scripts/restore-machine.sh <source-hostname>

# Example:
./scripts/restore-machine.sh thinkpad-x1-jacopo
```

This clones all repos from GitHub that aren't already present in `~/`, then
restores gitignored project data (databases, credentials) from the Drive backup
into the correct repo directories.

Requires: `gh auth login` completed, rclone configured (Steps 1-2).

## Step 4: Post-install verification

```bash
# Verify rclone mount
systemctl --user status rclone-gdrive

# Verify auto-backup timer
systemctl --user status backup-configs.timer
systemctl --user list-timers backup-configs

# Verify SSH
ssh -T git@github.com

# Verify GitHub CLI
gh auth status

# Verify Claude Code
claude --version
```

## Step 5: Set up auto-backup for the NEW machine

The `backup-sync.nix` module uses the machine's hostname automatically. After rebuild, the new machine creates its own backup path:

```
gdrive:backups/<new-hostname>/
```

Trigger an immediate backup to verify:

```bash
systemctl --user start backup-configs
journalctl --user -u backup-configs --no-pager -n 20
```

## Available Hosts

| Host | Hardware | Helper |
|------|----------|--------|
| `thinkpad-x1-jacopo` | ThinkPad X1 Carbon | `mkTechHost` |
| `framework-16` | Framework 16 | `mkTechHost` |
| `biz-003` | MacBook Air 2018 (T2) | `mkBusinessHost` |

## Machine-Specific Notes

### MacBook Air 2018 (biz-003)
- Requires T2 kernel and apple-bce module
- WiFi firmware: GitHub-sourced (Apple servers broken)
- Use `iwd` backend (not wpa_supplicant)
- See `overlays/apple-bcm-firmware.nix`

### ThinkPad X1 Carbon (thinkpad-x1-jacopo)
- Standard install, no special firmware needs

### Framework 16 (framework-16)
- Uses `nixos-hardware.nixosModules.framework-16-7040-amd`

## Troubleshooting

### rclone OAuth expired
```bash
rclone config reconnect gdrive:
```

### Git push rejected after restore
The restored SSH key might not match GitHub. Re-add:
```bash
gh ssh-key add ~/.ssh/id_ed25519.pub
```

### Claude Code permissions not working
`settings.local.json` contains machine-specific paths. After restore, review and update paths:
```bash
cat ~/.claude/settings.local.json | jq .
```

### Backup timer not running
```bash
systemctl --user enable --now backup-configs.timer
```
