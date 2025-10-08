---
status: active
created: 2025-01-01
updated: 2025-10-08
type: guide
lifecycle: persistent
---

# Common Tasks - Quick Reference

Fast answers to "How do I...?" for daily nixos-config operations.

---

## 🚀 Quick Links

- [Adding Packages](#adding-packages)
- [Managing Flakes](#managing-flakes)
- [Testing Changes](#testing-changes)
- [Garbage Collection](#garbage-collection)
- [Rollback](#rollback-procedures)
- [Fish Shell](#fish-shell-customization)
- [Claude Automation](#claude-automation)
- [Troubleshooting](#troubleshooting)

---

## Adding Packages

### Add System-Wide Package

**File**: `modules/core/packages.nix`

```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  newpackage    # Add your package here
];
```

**Then rebuild**:
```bash
./rebuild-nixos
```

**Example**: Adding `htop`
```nix
environment.systemPackages = with pkgs; [
  # System Monitoring
  htop  # Interactive process viewer
  # ... rest ...
];
```

---

### Add User-Level Package

**File**: `modules/home-manager/base.nix`

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  newpackage
];
```

**When to use**:
- ✅ Personal utilities (don't need system-wide)
- ✅ Experimental tools (easier to remove)
- ✅ User-specific configurations

---

### Add Package with Overlay

For packages not in nixpkgs or custom builds:

**File**: `overlays/<package-name>.nix`

```nix
{ lib, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "my-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "user";
    repo = "repo";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # Build instructions...
}
```

**Register in flake.nix**:
```nix
overlays.default = final: prev: {
  my-package = final.callPackage ./overlays/my-package.nix { };
};
```

**See**: `overlays/jules.nix` for real example (google-jules)

---

## Managing Flakes

### Update All Flake Inputs

```bash
cd ~/nixos-config
nix flake update
./rebuild-nixos
```

**Updates**:
- nixpkgs
- home-manager
- claude-code-nix
- claude-automation
- ai-project-orchestration
- All other inputs

---

### Update Specific Input

```bash
# Update only nixpkgs
nix flake update nixpkgs

# Update only claude-automation
nix flake update claude-automation

# Then rebuild
./rebuild-nixos
```

---

### Pin Input to Specific Commit

```bash
nix flake lock --override-input claude-automation github:jacopone/claude-nixos-automation/<commit-hash>
./rebuild-nixos
```

**Use case**: Roll back a broken update

---

### Show Flake Metadata

```bash
nix flake metadata
nix flake show
```

**Output**: Current versions, inputs, outputs

---

## Testing Changes

### Syntax Validation Only

```bash
nix flake check
```

**What it checks**:
- ✅ Nix syntax
- ✅ Flake structure
- ✅ Import resolution
- ❌ Does NOT build packages

**Time**: ~5 seconds

---

### Test Build Without Activating

```bash
nixos-rebuild test --flake .
```

**What it does**:
- ✅ Builds full system
- ✅ Activates temporarily
- ❌ Does NOT set as boot default
- ❌ Reverts on reboot

**Use case**: Testing risky changes safely

---

### Build Specific Package

```bash
nix build .#nixosConfigurations.nixos.config.environment.systemPackages
```

**Or build from nixpkgs**:
```bash
nix build nixpkgs#package-name
```

---

### Check What Will Change

```bash
nixos-rebuild dry-build --flake .
```

**Output**: List of packages to build/download

---

## Garbage Collection

### List System Generations

```bash
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

**Output**:
```
  14   2025-10-02 10:30:45
  15   2025-10-03 14:22:11
  16   2025-10-05 18:45:33   (current)
```

---

### Delete Specific Generations

```bash
# Delete generations 14 and 15
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 14 15

# Then collect garbage
nix-collect-garbage
```

**Note**: Cannot delete current generation

---

### Delete Old Generations by Age

```bash
# Delete everything older than 7 days
sudo nix-collect-garbage --delete-older-than 7d

# Delete everything older than 30 days
sudo nix-collect-garbage --delete-older-than 30d
```

---

### Full System Cleanup

```bash
# 1. Delete old generations
sudo nix-collect-garbage --delete-older-than 7d

# 2. Optimize store (deduplicate)
nix-store --optimise

# 3. Clean user caches
rm -rf ~/.cache/uv
rm -rf ~/.cache/google-chrome
rm -rf ~/.cache/yarn
rm -rf ~/.cache/pnpm
rm -rf ~/.cache/ms-playwright
```

**Can free**: 5-20 GB depending on usage

---

### Emergency: Disk Full

```bash
# Nuclear option - delete ALL old generations
sudo nix-collect-garbage -d

# Then optimize
nix-store --optimise

# Clean build artifacts
rm -rf result result-*

# Clean devenv artifacts
rm -rf .devenv
```

---

## Rollback Procedures

### Quick Rollback (System Broken)

```bash
sudo nixos-rebuild switch --rollback
```

**Reverts to**: Previous generation

---

### Rollback to Specific Generation

```bash
# 1. List generations
sudo nix-env -p /nix/var/nix/profiles/system --list-generations

# 2. Switch to generation 15
sudo nix-env -p /nix/var/nix/profiles/system --switch-to-generation 15

# 3. Activate it
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

---

### Boot Into Previous Generation

**If system won't boot**:

1. Reboot machine
2. Press **SPACE** during GRUB menu
3. Select "NixOS - Configuration X (old)"
4. After booting, make it permanent:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

---

## Fish Shell Customization

### Add Fish Abbreviation

**File**: `modules/home-manager/base.nix`

```nix
programs.fish.shellAbbrs = {
  # ... existing abbreviations ...
  myabbr = "my-full-command";
};
```

**Example**: Add git shortcut
```nix
programs.fish.shellAbbrs = {
  gst = "git status";
  gco = "git checkout";
};
```

**Then rebuild**: `./rebuild-nixos`

---

### Add Fish Function

**File**: `modules/home-manager/base.nix`

```nix
programs.fish.functions = {
  my_function = ''
    # Fish function code
    echo "Hello from my function"
  '';
};
```

---

### Check Current Abbreviations

```bash
# In fish shell
abbr --show

# Count them
abbr --show | wc -l
```

**Current**: 58 abbreviations

---

## Claude Automation

### Update Claude Configs Manually

```bash
cd ~/nixos-config
nix run github:jacopone/claude-nixos-automation#update-all
```

**Updates**:
- `~/.claude/CLAUDE.md` (system-level)
- `./CLAUDE.md` (project-level)
- `~/.claude/CLAUDE-USER-POLICIES.md.example` (examples)

---

### Update Only System CLAUDE.md

```bash
nix run github:jacopone/claude-nixos-automation#update-system
```

---

### Update Only Project CLAUDE.md

```bash
nix run github:jacopone/claude-nixos-automation#update-project
```

---

### Edit User Policies

```bash
# Edit source file (user maintains)
nano ~/.claude/CLAUDE-USER-POLICIES.md

# Rebuild to merge into CLAUDE.md
./rebuild-nixos
```

**Note**: After merge refactoring, policies will be merged into `~/.claude/CLAUDE.md`

---

### Restore CLAUDE.md from Backup

```bash
# List backups
ls -lt ~/.claude/.backups/

# Restore most recent
cp ~/.claude/.backups/CLAUDE.md.backup-* ~/.claude/CLAUDE.md
```

---

## Troubleshooting

### "Error: selector 'nixos' matches no derivations"

**Cause**: Wrong flake path

**Fix**:
```bash
# Make sure you're in nixos-config directory
cd ~/nixos-config

# Use correct flake path
nixos-rebuild switch --flake .
```

---

### "Unfree package not allowed"

**Cause**: Package is unfree and not explicitly allowed

**Already fixed in this config** via:
```nix
nixpkgs.config.allowUnfree = true;
```

If still happening, check which package:
```bash
nixos-rebuild switch --flake . 2>&1 | grep unfree
```

---

### Rebuild Hangs on "Building..."

**Possible causes**:
1. Network download stuck
2. Large package compiling

**Check**:
```bash
# See what's building
nix-store --query --requisites /nix/var/nix/profiles/system | tail

# Check network
ping nixos.org
```

**Fix**:
- Wait (some packages take 10+ minutes)
- Or Ctrl+C and retry
- Check `nix.conf` settings

---

### "Out of Disk Space"

**Quick check**:
```bash
df -h /nix
du -sh /nix/store
```

**Fix**:
```bash
# Delete old generations
sudo nix-collect-garbage --delete-older-than 7d

# Optimize store
nix-store --optimise
```

See [Garbage Collection](#garbage-collection) section

---

### Changes Not Taking Effect

**Checklist**:
- [ ] Did you rebuild? `./rebuild-nixos`
- [ ] Did you log out/in? (for home-manager changes)
- [ ] Did you restart service? `sudo systemctl restart <service>`
- [ ] Is config in right file? (system vs home-manager)

---

### Git Hooks Blocking Commit

**If you need to bypass temporarily**:
```bash
git commit --no-verify -m "message"
```

**Better**: Fix the issue the hook is catching

**Note**: As of 2025-10-06, hooks disabled in nixos-config

---

## Advanced Tasks

### Search for Package in nixpkgs

```bash
# Search by name
nix search nixpkgs <package-name>

# Example
nix search nixpkgs htop
```

---

### Format All Nix Files

```bash
nixpkgs-fmt **/*.nix
```

Or with fd:
```bash
fd '\.nix$' -x nixpkgs-fmt
```

---

### Check Which Generation You're On

```bash
nixos-rebuild list-generations | grep current
```

---

### Export Current Configuration

```bash
# Export as JSON
nix eval --json .#nixosConfigurations.nixos.config.system > current-config.json

# Pretty print
nix eval --json .#nixosConfigurations.nixos.config.system | jq
```

---

## AI Orchestration Tools

### Initialize New Project (Greenfield)

```bash
cd ~/projects/new-project
ai-init-greenfield
```

**Provides**: Spec-driven setup, TDD enforcement, quality gates

---

### Rescue Legacy Project (Brownfield)

```bash
cd ~/projects/legacy-project
ai-init-brownfield
```

**Provides**: Assessment, remediation, spec adoption

---

### Launch Master Orchestrator

```bash
ai-project
```

**Or via TUI**:
```bash
aitui
```

---

## Quick Maintenance Checklist

**Weekly**:
- [ ] `nix flake update` - Update inputs
- [ ] `./rebuild-nixos` - Apply updates
- [ ] `sudo nix-collect-garbage --delete-older-than 7d` - Clean old generations

**Monthly**:
- [ ] Review `CHANGELOG.md` and update with recent changes
- [ ] Check disk usage: `df -h /nix`
- [ ] Optimize store: `nix-store --optimise`
- [ ] Update CLAUDE.md if packages/abbreviations changed

**As Needed**:
- [ ] Backup important configs before major changes
- [ ] Test risky changes with `nixos-rebuild test` first
- [ ] Document significant architecture changes

---

## Getting Help

### Check Logs

```bash
# System journal
journalctl -xeu <service-name>

# Last boot
journalctl -b

# Follow live
journalctl -f
```

### NixOS Manual

```bash
man configuration.nix
```

### Search Options

```bash
# Search for option
nix search nixpkgs <option-name>

# Example
nix search nixpkgs environment.systemPackages
```

### Community Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [r/NixOS](https://reddit.com/r/NixOS)

---

**Last Updated**: 2025-10-06
**NixOS Version**: 25.11 (unstable)
**Config Location**: `~/nixos-config`
