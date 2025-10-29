---
status: active
created: 2025-10-29
updated: 2025-10-29
type: guide
lifecycle: persistent
---

# CI/CD Implementation Guide

**Quick Start**: Follow Phase 1 (Week 1-2) to get automated quality gates running immediately.

---

## What You're Getting

### ✅ Provided in This Package

1. **GitHub Actions Workflows** (ready to use)
   - `validate-pr.yml` - Automatic validation on every pull request
   - `deploy-main.yml` - Automated deployment preparation on merge
   - `security-scan.yml` - Daily security scanning
   - `performance-bench.yml` - Weekly performance tracking
   - `update-dependencies.yml` - Weekly dependency updates

2. **Assessment Document**
   - `CICD_DEVOPS_ASSESSMENT.md` - Comprehensive analysis
   - Current state, gaps, recommendations
   - 3-phase implementation roadmap

3. **Git Hooks** (already installed)
   - `.git/hooks/pre-commit` - Documentation policy enforcement
   - Markdown YAML frontmatter validation

---

## Phase 1: Foundation (Week 1-2, 10-14 hours)

### Goal
Establish minimum CI/CD standards with automated quality gates and secret management.

### Step 1a: Enable GitHub Actions (0.5 hours)

**Status**: Workflows already created in `.github/workflows/`

**Verify they're in place**:
```bash
ls -la .github/workflows/
# Should show: validate-pr.yml, deploy-main.yml, security-scan.yml, etc.
```

**No additional action needed** - workflows are ready to use on next push.

### Step 1b: Configure Branch Protection (0.5 hours)

Navigate to GitHub repository settings:

1. **Go to**: https://github.com/jacopone/nixos-config/settings/branches

2. **Add rule for master branch**:
   - Click "Add rule"
   - Branch name pattern: `master`

3. **Enable protections**:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require code reviews: 1 reviewer (for solo dev)

4. **Status checks required**:
   - Select: `Syntax & Lint` (from validate-pr.yml)
   - Select: `Security Scan` (from security-scan.yml)
   - Optionally: `Build Performance Metrics`

5. **Save**

**Result**: Master branch now protected - broken changes cannot merge.

### Step 1c: Implement Pre-Commit Hooks (2-3 hours)

The basic hook is already installed. Enhance it with auto-formatting.

**Install additional tools**:
```bash
devenv shell

# Verify tools are available
which nixfmt
which prettier
which markdownlint-cli2
```

**Create enhanced pre-commit hook**:
```bash
# Replace .git/hooks/pre-commit with enhanced version
cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Running pre-commit checks..."

# Auto-format Nix files
echo "Formatting Nix files..."
git diff --cached --name-only --diff-filter=ACM | grep '\.nix$' | while read file; do
  if [ -f "$file" ]; then
    nixfmt "$file" || true
    git add "$file"
  fi
done

# Auto-format Markdown
echo "Formatting Markdown files..."
git diff --cached --name-only --diff-filter=ACM | grep '\.md$' | while read file; do
  if [ -f "$file" ]; then
    prettier --write "$file" 2>/dev/null || true
    git add "$file"
  fi
done

# Check markdown frontmatter (blocking)
echo "Checking markdown frontmatter..."
STAGED_MD=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)

if [ -n "$STAGED_MD" ]; then
  VIOLATIONS=0
  while IFS= read -r file; do
    if [ ! -f "$file" ]; then continue; fi
    if [[ "$file" =~ (CLAUDE\.md$|node_modules|\.devenv) ]]; then
      continue
    fi
    if ! head -1 "$file" | grep -q '^---$'; then
      echo -e "${RED}❌ Missing frontmatter: $file${NC}"
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  done <<< "$STAGED_MD"

  if [ $VIOLATIONS -gt 0 ]; then
    echo -e "${RED}❌ Add YAML frontmatter to all markdown files${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}✅ Pre-commit checks passed${NC}"
EOF

chmod +x .git/hooks/pre-commit
```

**Test the hook**:
```bash
# Try to commit a markdown file without frontmatter
cat > test-file.md <<'EOF'
# Test

This file is missing frontmatter.
EOF

git add test-file.md
git commit -m "test: try commit without frontmatter"
# Should fail with message about missing frontmatter

# Fix it
cat > test-file.md <<'EOF'
---
status: draft
created: 2025-10-29
updated: 2025-10-29
type: reference
lifecycle: ephemeral
---

# Test

This file has proper frontmatter.
EOF

git add test-file.md
git commit -m "test: add proper frontmatter"
# Should succeed

# Clean up
git reset --hard HEAD~1
rm test-file.md
```

### Step 1d: Secrets Management Setup (4-6 hours)

**Why**: GitHub tokens exposed in environment is a security risk.

**Implement with agenix**:

```bash
# 1. Generate secrets key (only once)
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -N "" -f ~/.ssh/agenix-key

# 2. Add agenix to flake.nix
# Open flake.nix and add to inputs:
cat >> /tmp/agenix-input.txt <<'EOF'
agenix.url = "github:ryantm/agenix";
EOF

# 3. Create secrets directory
mkdir -p secrets

# 4. Encrypt GitHub token (replace with your actual token)
cat > /tmp/encrypt-secrets.sh <<'EOF'
#!/usr/bin/env bash
# Get your GitHub token:
# 1. Go to https://github.com/settings/tokens
# 2. Create classic token with repo access
# 3. Copy token and paste below

read -sp "GitHub token (hidden): " GITHUB_TOKEN
echo ""

# Initialize agenix (one-time setup)
agenix-edit -i ~/.ssh/agenix-key.pub secrets/github-token.age

# In the editor, paste your token and save
# The file is encrypted and safe to commit
EOF

chmod +x /tmp/encrypt-secrets.sh
bash /tmp/encrypt-secrets.sh
```

**Use encrypted secrets in config**:
```nix
# In configuration.nix or a module
{
  age.secrets.github-token = {
    file = ./secrets/github-token.age;
    owner = "guyfawkes";
  };

  users.users.guyfawkes = {
    packages = [
      pkgs.gh  # Git hub CLI
    ];
  };

  # Reference in scripts or services:
  # cat $CREDENTIALS_DIRECTORY/github-token
}
```

**Rotation Schedule**:
- GitHub token: Rotate every 90 days
- Calendar reminder: Add to calendar
- Process: Generate new token → `agenix-edit` → commit → rebuild

### Step 1e: Test CI/CD Pipeline (2-3 hours)

**Create test PR**:

```bash
# Create feature branch
git checkout -b test/ci-validation

# Make a small change
echo "# CI/CD Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: verify CI/CD pipeline"
git push origin test/ci-validation

# Go to GitHub and create PR
# https://github.com/jacopone/nixos-config/pull/new/test/ci-validation
```

**Monitor PR checks**:
- Watch for validation workflow to start
- Should show:
  - Syntax & Lint ✅
  - Security Scan ✅
  - Documentation Quality ✅

**Merge and verify**:
- Merge PR to master
- Watch `Deploy on Master` workflow
- Should show: Build successful, deployment ready

**Cleanup**:
```bash
git checkout master
git branch -D test/ci-validation
git push origin --delete test/ci-validation
```

### Phase 1 Deliverables

- ✅ GitHub Actions workflows configured
- ✅ Branch protection rules enabled
- ✅ Pre-commit hooks with auto-formatting
- ✅ Secrets encrypted with agenix
- ✅ CI/CD pipeline tested and working

**Time**: 10-14 hours total
**Effort**: Medium
**Complexity**: Moderate

---

## Phase 2: Quality Gates (Week 3-4, 14-19 hours)

Skip this section for now. Will implement after Phase 1 is stable.

### What's included in Phase 2
- Performance benchmarking (automated)
- NixOS-specific testing
- Dependency vulnerability scanning
- Metrics dashboard

---

## Phase 3: Advanced (Month 2, 23-30 hours)

Skip for now. Focus on Phase 1 first.

---

## Troubleshooting

### Problem: Workflow not triggering

**Check**:
```bash
# Verify workflows exist
ls -la .github/workflows/

# Check if GitHub Actions is enabled
# Go to: Settings → Actions → General
# Should be: "Actions permissions: All actions and reusable workflows allowed"
```

**Fix**: If workflows not visible, push again:
```bash
git push origin master
```

### Problem: Branch protection blocking legitimate merges

**Cause**: Status checks failing

**Diagnose**:
1. Open PR on GitHub
2. Look at status checks (should show green ✅)
3. Click "Details" on any failing check
4. Review logs to see what failed

**Common fixes**:
- Missing markdown frontmatter: Add YAML header to `.md` files
- Secret detected: Run `gitleaks` locally to find and remove
- Syntax error: Run `nix flake check` to identify issue

### Problem: "Deployment" workflow not running

**Status**: Normal for Phase 1 - it's optional

**To enable**:
1. Go to Actions settings
2. Create repository secrets:
   - `DEPLOY_KEY` - SSH private key
   - `TARGET_HOST` - Hostname or IP
   - `TARGET_USER` - SSH username
3. Update `.github/workflows/deploy-main.yml`
4. Change `if: false` to `if: true`

---

## What to Commit

Once Phase 1 is complete, commit everything:

```bash
git add .github/workflows/
git add .git/hooks/pre-commit
git add secrets/  # Only .age encrypted files, never raw tokens
git commit -m "ci: add GitHub Actions workflows and security

- Add PR validation pipeline (syntax, security, docs)
- Add automatic deployment preparation
- Add security scanning (secrets, vulnerabilities)
- Enable branch protection rules
- Implement secrets management with agenix
- Add pre-commit hooks with auto-formatting"

git push origin master
```

---

## Next Steps After Phase 1

1. **Monitor workflows** - Watch for issues in first week
2. **Gather metrics** - Let performance benchmarks run for baseline
3. **Plan Phase 2** - Schedule quality gates implementation
4. **Document team** - Share CI/CD process with team (if any)

---

## Quick Reference: Common Commands

### Check workflow status
```bash
gh workflow list
gh run list --limit 10
gh run view <RUN_ID> --log
```

### Manually trigger workflow
```bash
gh workflow run security-scan.yml
```

### Debug locally before pushing
```bash
# Test nix syntax
nix flake check

# Test security scanning
nix shell nixpkgs#gitleaks --command \
  gitleaks detect --source .

# Test documentation
devenv shell bash -c 'markdownlint-cli2 "docs/**/*.md"'
```

### Update branch protection
```bash
# Use GitHub CLI
gh api repos/jacopone/nixos-config/branches/master \
  --input - << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Syntax & Lint", "Security Scan"]
  }
}
EOF
```

---

## Security Best Practices

1. **Never commit secrets**
   - Use `agenix` for encryption
   - Add to `.gitignore`
   - Scan with `gitleaks` before pushing

2. **Rotate credentials regularly**
   - GitHub tokens: 90 days
   - SSH keys: 365 days
   - Set calendar reminders

3. **Review workflow permissions**
   - Only request needed permissions
   - Never use `admin` unless necessary
   - Use environment protection for deployments

4. **Monitor security reports**
   - Check daily security scan results
   - Review trivy/gitleaks findings
   - Update dependencies with known CVEs immediately

---

## Success Metrics

### Week 1
- All workflows deployed and visible in Actions tab
- PR validation running on new pull requests
- Branch protection preventing direct commits to master

### Week 2
- First deployment workflow completed successfully
- Pre-commit hooks preventing invalid commits
- Secrets successfully encrypted

### Week 3+
- Zero broken merges due to quality gate failures
- Consistent test pass rate >95%
- Security scans identifying issues before they reach production

---

**Ready to start?** Begin with Step 1b (Branch Protection) - it takes 30 minutes and immediately improves safety.

**Questions?** Check the full assessment: `docs/CICD_DEVOPS_ASSESSMENT.md`
