---
status: active
created: 2026-02-25
updated: 2026-02-27
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

## Step 2: Clone NixOS config and install

```bash
# Use HTTPS for initial clone (SSH keys not restored yet)
git clone https://github.com/jacopone/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config
git checkout personal

# For a fresh install (partitions already formatted and mounted on /mnt):
sudo nixos-install --flake .#<host-name>

# For an existing install (rebuild in place):
# Copy repo to final location first
# sudo nixos-rebuild switch --flake .#<host-name>
```

## Step 3: Run restore script

After NixOS is rebuilt and you've logged in, the restore script handles everything:
system configs, GitHub repos, and project data.

```bash
cd ~/nixos-config
./scripts/restore-machine.sh <source-hostname>

# Example:
./scripts/restore-machine.sh thinkpad-x1-jacopo
```

The script runs four phases:
1. **System configs** — SSH keys, GPG, Claude Code, Atuin history, Fish, keyrings, gcloud, rclone, custom scripts (with correct permissions)
2. **GitHub repos** — clones all repos from GitHub to `~/`
3. **Gitignored project data** — databases, .env files, credentials from Drive backup into repos
4. **Verification** — functional checks (SSH, gh, GPG, rclone) and existence checks for all restored data

Requires: rclone configured (Step 1). The script restores `gh` credentials in Phase 1,
so `gh auth login` is not needed separately.

### Manual fallback (if script fails)

If the restore script is unavailable, restore configs manually:

```bash
SOURCE_HOST="thinkpad-x1-jacopo"

mkdir -p ~/.ssh && chmod 700 ~/.ssh
rclone sync "gdrive:backups/$SOURCE_HOST/ssh/" ~/.ssh/
chmod 600 ~/.ssh/id_* 2>/dev/null && chmod 644 ~/.ssh/*.pub 2>/dev/null

mkdir -p ~/.config/gh && rclone sync "gdrive:backups/$SOURCE_HOST/gh/" ~/.config/gh/
mkdir -p ~/.gnupg && chmod 700 ~/.gnupg && rclone sync "gdrive:backups/$SOURCE_HOST/gnupg/" ~/.gnupg/
mkdir -p ~/.claude && rclone sync "gdrive:backups/$SOURCE_HOST/claude/" ~/.claude/
mkdir -p ~/.local/share/atuin && rclone sync "gdrive:backups/$SOURCE_HOST/atuin/" ~/.local/share/atuin/
mkdir -p ~/.config/fish && rclone sync "gdrive:backups/$SOURCE_HOST/fish/" ~/.config/fish/
mkdir -p ~/.config/gcloud && rclone sync "gdrive:backups/$SOURCE_HOST/gcloud/" ~/.config/gcloud/
mkdir -p ~/.local/share/keyrings && rclone sync "gdrive:backups/$SOURCE_HOST/keyrings/" ~/.local/share/keyrings/
mkdir -p ~/.local/bin && rclone sync "gdrive:backups/$SOURCE_HOST/local-bin/" ~/.local/bin/
```

## Step 4: Post-install verification

The restore script runs automated verification in Phase 4, checking every restored
item with functional tests (SSH, gh, GPG, rclone) and existence checks (databases,
config files). Review its output for any warnings.

For manual spot-checks or debugging:

```bash
ssh -T git@github.com              # SSH auth
gh auth status                     # GitHub CLI
gpg --list-secret-keys             # GPG keys
rclone listremotes                 # rclone remotes
systemctl --user status rclone-gdrive       # Drive mount
systemctl --user status backup-configs.timer # Backup timer
claude --version                   # Claude Code
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
