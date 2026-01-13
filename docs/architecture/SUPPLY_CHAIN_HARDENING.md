---
status: active
created: 2026-01-10
updated: 2026-01-11
type: architecture
lifecycle: persistent
---

# Supply Chain Hardening Plan

Comprehensive supply chain security enhancements for NixOS based on:
- [Nixcademy: Secure Supply Chain with Nix](https://nixcademy.com/posts/secure-supply-chain-with-nix/)
- [How NixOS could have detected the xz backdoor](https://luj.fr/blog/how-nixos-could-have-detected-xz.html)

---

## Implementation Status

| Part | Status | Description |
|------|--------|-------------|
| Part 1: Source Closure Audit | ✅ Done | `--audit` flag exports FOD manifest |
| Part 2: NPM Pinning | ✅ Done | `npm-versions.nix` pins 6 tools |
| Part 3 Option 1: Quick Check | ✅ Done | Lightweight reproducibility in `--audit` |
| Part 3 Option 2: --verify-bootstrap | ✅ Done | Deep bootstrap verification flag |
| Part 3 Option 3: r13y Monitoring | ✅ Done | Community reproducibility tracking |

---

## Security Posture

```
┌─────────────────────────────────────────────────────────────┐
│                 SUPER SECURE NIXOS                          │
├─────────────────────────────────────────────────────────────┤
│ Layer 1: Flake Lock (narHash)          ✅ Active            │
│ Layer 2: Trusted Binary Caches         ✅ Active            │
│ Layer 3: Bubblewrap Sandboxing         ✅ Active            │
│ Layer 4: Source Closure Manifest       ✅ Part 1            │
│ Layer 5: NPM Version Pinning           ✅ Part 2            │
│ Layer 6: Quick Reproducibility Check   ✅ Part 3 Opt 1      │
│ Layer 7: Deep Bootstrap Verification   ✅ Part 3 Opt 2      │
│ Layer 8: Community r13y Validation     ✅ Part 3 Opt 3      │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 1: Source Closure Audit (Implemented)

### What It Does
The `--audit` flag extracts all fixed-output derivations (sources) from the build closure and saves them to `~/.nixos-audit/`.

### Usage
```bash
./rebuild-nixos --audit
```

### Files Modified
- `rebuild-nixos` - Added Phase 2.7 with FOD extraction

---

## Part 2: NPM Version Pinning (Implemented)

### What It Does
Replaces `@latest` npm specifiers with pinned versions for reproducibility.

### Files Created/Modified
- `modules/core/npm-versions.nix` - Central version tracking
- `modules/core/packages.nix` - Uses pinned versions
- `scripts/update-npm-versions.sh` - Version check helper

### Pinned Tools
| Tool | Version |
|------|---------|
| claude-flow | 3.0.0-alpha.42 |
| bmad-method | 4.44.3 |
| gemini-cli | 0.23.0 |
| jules | 0.1.42 |
| openspec | 0.18.0 |
| jscpd | 4.0.5 |

---

## Part 3: Reproducibility Verification (Pending)

### Architecture Decision

| Component | Location | Rationale |
|-----------|----------|-----------|
| Quick reproducibility check | `rebuild-nixos` (bash) | Fast, native nix commands |
| Deep bootstrap verification | `rebuild-nixos` (bash) | Uses nix-build --check |
| r13y status monitoring | `claude-nixos-automation` (Python) | Web scraping, data analysis |

---

### Option 1: Lightweight (extend --audit) - ~30 min

Add to existing Phase 2.7 in `rebuild-nixos`:

```bash
# === PHASE 2.7.1: Quick Reproducibility Check ===
if [ "$AUDIT" = true ]; then
    log_step "Checking critical package reproducibility..."

    # Critical bootstrap packages to verify
    CRITICAL_PKGS="xz gzip bzip2 coreutils gnugrep gnused gawk"
    REPRO_PASSED=0
    REPRO_FAILED=0

    for pkg in $CRITICAL_PKGS; do
        if nix-build '<nixpkgs>' -A "$pkg" --check 2>&1 | grep -q "checking outputs"; then
            if [ $? -eq 0 ]; then
                log_success "$pkg: reproducible ✓"
                ((REPRO_PASSED++))
            else
                log_warning "$pkg: NOT reproducible"
                ((REPRO_FAILED++))
            fi
        else
            log_warning "$pkg: check skipped (not in store)"
        fi
    done

    add_stat "Reproducibility: $REPRO_PASSED passed, $REPRO_FAILED failed"
fi
```

---

### Option 2: --verify-bootstrap flag - ~2 hours

New flag: `./rebuild-nixos --verify-bootstrap`

#### Step 1: Add flag parsing
```bash
VERIFY_BOOTSTRAP=false

# In case statement
--verify-bootstrap) VERIFY_BOOTSTRAP=true; shift ;;

# In help
echo "  --verify-bootstrap  Deep reproducibility check of bootstrap packages"
```

#### Step 2: Add Phase 2.8 (after audit, before activation)

```bash
# === PHASE 2.8: Bootstrap Package Verification ===
# Inspired by: https://luj.fr/blog/how-nixos-could-have-detected-xz.html
if [ "$VERIFY_BOOTSTRAP" = true ]; then
    log_step "Deep verification of bootstrap packages..."

    VERIFY_DIR="$HOME/.nixos-audit/bootstrap-verify-$TIMESTAMP"
    mkdir -p "$VERIFY_DIR"

    # Bootstrap-critical packages (first-stage build dependencies)
    BOOTSTRAP_PKGS=(
        "xz"           # Compression (xz backdoor target)
        "gzip"         # Compression
        "bzip2"        # Compression
        "coreutils"    # Basic utilities
        "gnugrep"      # Pattern matching
        "gnused"       # Stream editor
        "gawk"         # Text processing
        "bash"         # Shell
        "gnumake"      # Build system
        "binutils"     # Linker/assembler
        "gcc"          # Compiler (if not from binary cache)
    )

    VERIFY_RESULTS=()

    for pkg in "${BOOTSTRAP_PKGS[@]}"; do
        log_step "Verifying $pkg..."

        # Build with --check to compare against existing store path
        CHECK_OUTPUT=$(nix-build '<nixpkgs>' -A "$pkg" --check --keep-failed 2>&1) || true

        if echo "$CHECK_OUTPUT" | grep -q "output .* is identical"; then
            log_success "$pkg: REPRODUCIBLE ✓"
            VERIFY_RESULTS+=("$pkg:PASS")
        elif echo "$CHECK_OUTPUT" | grep -q "output .* differs"; then
            log_error "$pkg: DIVERGENT OUTPUT - POTENTIAL TAMPERING"
            VERIFY_RESULTS+=("$pkg:FAIL")

            # Find the .check path for analysis
            CHECK_PATH=$(echo "$CHECK_OUTPUT" | grep -oP '/nix/store/[^"]+\.check' | head -1)
            if [ -n "$CHECK_PATH" ]; then
                echo "$pkg diverged. Check path: $CHECK_PATH" >> "$VERIFY_DIR/divergent-packages.txt"

                # Optional: Run nix-diff for root cause
                if command -v nix-diff &>/dev/null; then
                    ORIG_PATH="${CHECK_PATH%.check}"
                    nix-diff "$ORIG_PATH" "$CHECK_PATH" > "$VERIFY_DIR/$pkg-diff.txt" 2>&1 || true
                fi
            fi
        else
            log_warning "$pkg: skipped (not in store or build failed)"
            VERIFY_RESULTS+=("$pkg:SKIP")
        fi
    done

    # Summary report
    PASS_COUNT=$(printf '%s\n' "${VERIFY_RESULTS[@]}" | grep -c ':PASS' || echo 0)
    FAIL_COUNT=$(printf '%s\n' "${VERIFY_RESULTS[@]}" | grep -c ':FAIL' || echo 0)
    SKIP_COUNT=$(printf '%s\n' "${VERIFY_RESULTS[@]}" | grep -c ':SKIP' || echo 0)

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Bootstrap Verification Summary                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo "  ✅ Reproducible: $PASS_COUNT"
    echo "  ❌ Divergent:    $FAIL_COUNT"
    echo "  ⏭️  Skipped:      $SKIP_COUNT"

    if [ "$FAIL_COUNT" -gt 0 ]; then
        log_error "SECURITY ALERT: $FAIL_COUNT package(s) failed reproducibility check!"
        echo "  Review: $VERIFY_DIR/divergent-packages.txt"

        if ! prompt_user "Continue despite reproducibility failures? (y/n)"; then
            log_error "Aborting due to reproducibility failures"
            exit 1
        fi
    fi

    # Save results
    printf '%s\n' "${VERIFY_RESULTS[@]}" > "$VERIFY_DIR/results.txt"
    add_stat "Bootstrap verification: $PASS_COUNT/$((PASS_COUNT + FAIL_COUNT)) reproducible"
    add_action "Bootstrap packages verified"
fi
```

---

### Option 3: r13y Monitoring - ~4 hours

**Location**: `claude-nixos-automation` (new Python module)

**New file**: `claude_automation/cli/check_reproducibility.py`

```python
#!/usr/bin/env python3
"""
Check package reproducibility status against r13y.com infrastructure.
Since r13y has no formal API, we parse their published reports.
"""

import json
import requests
from pathlib import Path
from datetime import datetime
from bs4 import BeautifulSoup


R13Y_URL = "https://reproducible.nixos.org/"
CACHE_DIR = Path.home() / ".nixos-audit" / "r13y-cache"


def fetch_r13y_status() -> dict:
    """Fetch current reproducibility status from r13y.com."""
    try:
        resp = requests.get(f"{R13Y_URL}data/latest.json", timeout=30)
        if resp.ok:
            return resp.json()
    except:
        pass

    # Fallback: Parse HTML report
    resp = requests.get(R13Y_URL, timeout=30)
    soup = BeautifulSoup(resp.text, 'html.parser')

    stats = {}
    for row in soup.select('table tr'):
        cols = row.select('td')
        if len(cols) >= 2:
            pkg = cols[0].text.strip()
            status = 'reproducible' if '✓' in cols[1].text else 'non-reproducible'
            stats[pkg] = status

    return stats


def get_local_packages() -> list:
    """Get list of packages in current system closure."""
    import subprocess
    result = subprocess.run(
        ['nix-store', '-qR', '/run/current-system'],
        capture_output=True, text=True
    )
    return [p.split('-', 1)[1] if '-' in p else p
            for p in result.stdout.strip().split('\n')]


def compare_reproducibility():
    """Compare local packages against r13y status."""
    r13y_status = fetch_r13y_status()
    local_pkgs = get_local_packages()

    report = {
        'timestamp': datetime.now().isoformat(),
        'total_local': len(local_pkgs),
        'checked_against_r13y': 0,
        'reproducible': [],
        'non_reproducible': [],
        'unknown': []
    }

    for pkg in local_pkgs:
        pkg_base = pkg.split('-')[0] if '-' in pkg else pkg
        if pkg_base in r13y_status:
            report['checked_against_r13y'] += 1
            if r13y_status[pkg_base] == 'reproducible':
                report['reproducible'].append(pkg)
            else:
                report['non_reproducible'].append(pkg)
        else:
            report['unknown'].append(pkg)

    return report


def main():
    """CLI entry point."""
    print("🔍 Checking reproducibility status against r13y.com...")

    report = compare_reproducibility()

    print(f"\n📊 Results:")
    print(f"   Total packages: {report['total_local']}")
    print(f"   Checked: {report['checked_against_r13y']}")
    print(f"   ✅ Reproducible: {len(report['reproducible'])}")
    print(f"   ❌ Non-reproducible: {len(report['non_reproducible'])}")
    print(f"   ❓ Unknown: {len(report['unknown'])}")

    if report['non_reproducible']:
        print(f"\n⚠️  Non-reproducible packages:")
        for pkg in report['non_reproducible'][:10]:
            print(f"      - {pkg}")
        if len(report['non_reproducible']) > 10:
            print(f"      ... and {len(report['non_reproducible']) - 10} more")

    # Save report
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    report_file = CACHE_DIR / f"report-{datetime.now():%Y%m%d-%H%M%S}.json"
    report_file.write_text(json.dumps(report, indent=2))
    print(f"\n📁 Report saved: {report_file}")


if __name__ == '__main__':
    main()
```

**Integration with flake.nix** (in claude-nixos-automation):

```nix
# Add to apps
check-reproducibility = {
  type = "app";
  program = "${self.packages.${system}.claude-automation}/bin/check-reproducibility";
};
```

**Integration with rebuild-nixos**:

```bash
# In Phase 4 (after activation, optional)
if [ "$AUDIT" = true ]; then
    log_step "Checking against community reproducibility data..."
    if [ -d "$AUTOMATION_FLAKE" ]; then
        nix run "$AUTOMATION_FLAKE#check-reproducibility" 2>&1 | tee -a "$LOG_FILE" || true
    fi
fi
```

---

## Verification Plan

```bash
# 1. Test quick reproducibility check (Option 1)
./rebuild-nixos --audit --dry-run
# Should show "Checking critical package reproducibility..."

# 2. Test deep bootstrap verification (Option 2)
./rebuild-nixos --verify-bootstrap --dry-run
# Should show bootstrap package list

# 3. Test r13y monitoring (Option 3)
cd ~/claude-nixos-automation
nix run .#check-reproducibility
# Should fetch and compare against r13y.com

# 4. Full security audit
./rebuild-nixos --audit --verify-bootstrap
# Complete supply chain verification
```

---

## Combined Security Layers

| Layer | When | What It Catches |
|-------|------|-----------------|
| Source Manifest (existing) | Every build | Unknown dependencies |
| Quick Repro Check (Opt 1) | Every --audit | Obvious tampering |
| Deep Bootstrap Verify (Opt 2) | On-demand | xz-style backdoors |
| r13y Monitoring (Opt 3) | Periodic | Community-known issues |

---

## References

- [Nixcademy: Secure Supply Chain with Nix](https://nixcademy.com/posts/secure-supply-chain-with-nix/)
- [How NixOS could have detected the xz backdoor](https://luj.fr/blog/how-nixos-could-have-detected-xz.html)
- [r13y.com - Is NixOS Reproducible?](https://r13y.com/)
- [NixOS Reproducible Builds](https://reproducible.nixos.org/)
- [Nix Diff Hook Documentation](https://nix.dev/manual/nix/2.25/advanced-topics/diff-hook)
