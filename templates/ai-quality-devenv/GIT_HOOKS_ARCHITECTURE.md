# Git Hooks Architecture

Technical documentation for the devenv-based git hooks implementation in ai-quality-devenv template.

## Problem Statement

Git hooks run **outside** the devenv shell environment. This creates a challenge:

1. Quality tools (ls-lint, markdownlint-cli2) are provided by devenv
2. These tools live in nix store paths like `/nix/store/abc123-ls-lint-2.3.1/bin/ls-lint`
3. These paths are only available within the devenv shell
4. Git triggers hooks from the user's normal shell environment
5. Result: Hooks fail with "Executable not found" errors

## Solution Architecture

### 1. Hook Wrapper Pattern

Wrap each quality tool invocation in `devenv shell bash -c 'command'`:

```nix
# modules/git-hooks.nix
ls-lint = {
  enable = true;
  name = "naming-conventions";
  entry = "devenv shell bash -c 'ls-lint'";
  language = "system";
  pass_filenames = false;
};
```

**What happens**:
1. Git triggers hook: `.git/hooks/pre-commit`
2. Pre-commit framework calls: `devenv shell bash -c 'ls-lint'`
3. Devenv spawns shell with all tools in PATH
4. ls-lint executes with access to nix store paths
5. Hook succeeds or fails based on validation

### 2. Nix Package for GC Roots

Include `nix` package in devenv to provide `nix-store` command:

```nix
# devenv.nix
packages = with pkgs; [
  nix  # Required for git-hooks installation (provides nix-store command)
  # ... other packages
];
```

**Why needed**:
- Devenv's git-hooks installer creates garbage collection (GC) roots
- GC roots prevent nix from deleting hook executables during cleanup
- The installer script uses `nix-store --add-root` to create these roots
- Without `nix` package, installer fails with "nix-store: command not found"

### 3. Automatic Hook Installation

Devenv installs hooks automatically on shell entry:

```bash
devenv shell
# Running tasks     devenv:enterShell
# Running           devenv:git-hooks:install
# Succeeded         devenv:git-hooks:install (2.63s)
```

**Process**:
1. User runs `devenv shell` (or enters via direnv)
2. Devenv executes `devenv:git-hooks:install` task
3. Task runs `/nix/store/.../devenv-git-hooks-install` script
4. Script generates `.pre-commit-config.yaml` with wrapped commands
5. Script installs `.git/hooks/pre-commit` and `.git/hooks/commit-msg`
6. Hooks are ready to use

## Implementation Details

### Generated Configuration

The `.pre-commit-config.yaml` contains:

```yaml
{
  "repos": [{
    "hooks": [{
      "id": "ls-lint",
      "name": "naming-conventions",
      "entry": "devenv shell bash -c 'ls-lint'",
      "language": "system",
      "pass_filenames": false
    }]
  }]
}
```

### Hook Execution Flow

```
User commits code
  ↓
Git triggers .git/hooks/pre-commit
  ↓
Pre-commit framework reads .pre-commit-config.yaml
  ↓
For each hook:
  ↓
  Spawn: devenv shell bash -c 'ls-lint'
    ↓
    Devenv initializes environment
    ↓
    ls-lint runs with full PATH
    ↓
    Returns exit code (0=pass, 1=fail)
  ↓
All hooks pass: commit proceeds
Any hook fails: commit blocked
```

### Performance Characteristics

**First commit after devenv shell**:
- ~2-3 seconds (devenv shell spawn time)
- Devenv caches environment after first run
- Includes full environment initialization

**Subsequent commits**:
- ~1-2 seconds (cached devenv environment)
- Much faster due to caching
- Only runs quality checks

**Compared to system-wide tools**:
- Slightly slower (devenv spawn overhead)
- Much more portable (no system dependencies)
- Identical behavior across environments

## Advantages

### 1. No System-Wide Installation

Tools don't need to be installed globally:
- ✅ Works in containers, CI, fresh machines
- ✅ Each project can have different tool versions
- ✅ No conflicts between projects
- ✅ Reproducible across all environments

### 2. Automatic Availability

Developers don't need to remember:
- ✅ No manual `devenv shell` before committing
- ✅ Works from any directory
- ✅ Works with GUI git clients
- ✅ Works with IDE git integrations

### 3. Consistent Enforcement

Quality gates work everywhere:
- ✅ Local development machines
- ✅ CI/CD pipelines
- ✅ Docker containers
- ✅ Remote development environments

### 4. Version Control

Tool versions are locked in:
- ✅ `devenv.lock` pins exact nix store hashes
- ✅ Team uses identical tool versions
- ✅ No "works on my machine" issues
- ✅ Reproducible builds

## Trade-offs

### Slower Hook Execution

**Impact**: 1-2 second overhead per commit
**Mitigation**: Devenv caching reduces subsequent runs
**Worth it**: Portability and consistency benefits outweigh cost

### Devenv Required

**Impact**: Contributors must have devenv installed
**Mitigation**: Documented in README with clear installation steps
**Worth it**: Already required for development environment

### Shell Spawn Overhead

**Impact**: Each hook spawns a new bash shell
**Mitigation**: Modern machines handle this easily
**Worth it**: Simpler than complex environment sharing

## Alternative Approaches Considered

### 1. System-Wide Tool Installation

```nix
# modules/core/packages.nix
environment.systemPackages = [ ls-lint markdownlint-cli2 ];
```

**Rejected because**:
- Requires NixOS rebuild for tool updates
- Doesn't work in non-NixOS environments
- Can't have per-project tool versions
- Breaks reproducibility

### 2. Direct Nix Store Paths

```nix
entry = "/nix/store/abc123-ls-lint-2.3.1/bin/ls-lint";
```

**Rejected because**:
- Paths change on every rebuild
- Requires regenerating hooks after updates
- Breaks when garbage collection runs
- Not portable across machines

### 3. Pre-commit's Native Entry Points

```nix
entry = "${pkgs.ls-lint}/bin/ls-lint";
```

**Rejected because**:
- Only evaluates within nix build context
- Doesn't work when git hooks run
- Pre-commit framework doesn't understand nix expressions

## Troubleshooting Guide

### "Executable not found" errors

**Symptom**: Hook fails with `/nix/store/.../ls-lint: not found`

**Diagnosis**:
```bash
# Check if path is wrapped in devenv shell
grep "ls-lint" .pre-commit-config.yaml
# Should show: "entry": "devenv shell bash -c 'ls-lint'"

# If shows direct path, regenerate hooks:
rm .pre-commit-config.yaml .git/hooks/pre-commit
devenv shell  # Triggers hook installation
```

**Root cause**: Hooks not regenerated after template update

### "nix-store: command not found"

**Symptom**: Hook installation fails during `devenv shell`

**Diagnosis**:
```bash
devenv shell bash -c "which nix-store"
# Should show: /nix/store/.../bin/nix-store
```

**Fix**: Add `nix` package to devenv.nix:
```nix
packages = with pkgs; [
  nix  # Required for git-hooks installation
  # ... other packages
];
```

### Hooks are slow

**Symptom**: 3-5 second delay on every commit

**Diagnosis**: Check if devenv shell is spawning multiple times

**Expected**: First commit slow, subsequent commits faster

**If all commits slow**:
- Check devenv cache: `ls -la .devenv/`
- Verify direnv working: `direnv status`
- May need to rebuild devenv: `rm -rf .devenv && devenv shell`

## Migration Guide

### From System-Wide Tools

If you had tools installed globally:

1. **Remove from system packages** (optional):
   ```nix
   # modules/core/packages.nix
   # Remove: ls-lint, markdownlint-cli2
   ```

2. **Rebuild NixOS** (optional):
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

3. **Regenerate hooks**:
   ```bash
   rm .pre-commit-config.yaml .git/hooks/*
   devenv shell  # Auto-installs new hooks
   ```

4. **Test**:
   ```bash
   git commit -m "test: verify hooks work"
   # Should see all quality checks run
   ```

### From Direct Nix Store Paths

If you had unwrapped hooks:

1. **Update git-hooks.nix**:
   ```nix
   # OLD:
   entry = "${pkgs.ls-lint}/bin/ls-lint";

   # NEW:
   entry = "devenv shell bash -c 'ls-lint'";
   language = "system";
   ```

2. **Add nix package**:
   ```nix
   packages = with pkgs; [
     nix  # Required
     # ... other packages
   ];
   ```

3. **Regenerate**:
   ```bash
   rm -rf .devenv .pre-commit-config.yaml .git/hooks/*
   devenv shell
   ```

## Technical References

- **Pre-commit framework**: https://pre-commit.com/
- **Devenv git-hooks**: https://devenv.sh/reference/options/#git-hookshooks
- **Nix garbage collection**: https://nixos.org/manual/nix/stable/package-management/garbage-collection.html
- **nixos-config dogfooding**: See root `devenv.nix` for real-world example

## Real-World Example

The nixos-config repository uses this pattern:

```nix
# /home/guyfawkes/nixos-config/devenv.nix
{
  imports = [
    ./templates/ai-quality-devenv/modules/packages.nix
    ./templates/ai-quality-devenv/modules/git-hooks.nix
  ];

  packages = with pkgs; [
    nix  # Critical for hook installation
    # ... project-specific tools
  ];
}
```

Result:
- ✅ All quality gates working
- ✅ First real test of ai-quality-devenv template
- ✅ Commits automatically validated
- ✅ No system-wide tool installation needed
