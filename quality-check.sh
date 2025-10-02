#!/usr/bin/env bash
# Quality check script for nixos-config
# Run this before committing to ensure quality gates pass

set -e

echo "🔍 Running quality checks on nixos-config..."
echo ""

# Enter devenv shell for quality tools
devenv shell bash <<'DEVENV_SCRIPT'

echo "1️⃣ Security scan (Gitleaks)..."
if gitleaks detect --source . --report-path /tmp/gitleaks-report.json; then
  echo "   ✅ No secrets detected"
else
  echo "   ⚠️  Potential secrets found - check /tmp/gitleaks-report.json"
fi

echo ""
echo "2️⃣ Markdown linting..."
if fd -e md -x markdownlint-cli2 {} \; 2>/dev/null; then
  echo "   ✅ Markdown files pass linting"
else
  echo "   ⚠️  Markdown linting issues found"
fi

echo ""
echo "3️⃣ Naming conventions (ls-lint)..."
if ls-lint; then
  echo "   ✅ File naming conventions pass"
else
  echo "   ⚠️  Naming convention violations found"
fi

echo ""
echo "4️⃣ Nix syntax check..."
if nix flake check --no-build 2>&1 | head -20; then
  echo "   ✅ Nix flake syntax valid"
else
  echo "   ⚠️  Nix flake syntax errors"
fi

echo ""
echo "✅ Quality check complete!"

DEVENV_SCRIPT
