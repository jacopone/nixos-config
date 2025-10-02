#!/usr/bin/env bash
# Naming Conventions Check Script
# Part of AI Quality DevEnv Template - Week 1

echo ""
echo "🏷️  Naming Conventions Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p .quality

if [ ! -f ".ls-lint.yml" ]; then
  echo "⚠️  .ls-lint.yml not found - creating default configuration..."
  cat > .ls-lint.yml << 'EOF'
ls:
  src:
    .js: camelCase | PascalCase
    .ts: camelCase | PascalCase
    .tsx: PascalCase
    .py: snake_case
  tests:
    .test.js: kebab-case | camelCase
    .test.ts: kebab-case | camelCase
    .test.py: snake_case
  docs:
    .md: kebab-case | SCREAMING-SNAKE-CASE
  .:
    .json: kebab-case | regex:^\.[a-z]+
    .yaml: kebab-case | regex:^\.[a-z]+
    .yml: kebab-case | regex:^\.[a-z]+
  .dir: kebab-case | snake_case
ignore:
  - node_modules
  - .devenv
  - .direnv
  - .git
  - dist
  - build
  - coverage
EOF
  echo "  ✓ Created default .ls-lint.yml"
fi

echo "🔍 Running ls-lint..."
if ! command -v ls-lint &> /dev/null; then
  echo "  ⚠️  ls-lint not found - skipping naming check"
  echo "  💡 Run from devenv shell for full quality checks"
  exit 0
fi

ls-lint --config .ls-lint.yml 2>&1 | tee .quality/naming-violations.txt

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
  echo ""
  echo "✅ All files follow naming conventions"
  echo "0" > .quality/naming-violations-count.txt
else
  VIOLATIONS=$(grep -c "FAILED" .quality/naming-violations.txt 2>/dev/null || echo "0")
  echo ""
  echo "⚠️  $VIOLATIONS naming violations found"
  echo "$VIOLATIONS" > .quality/naming-violations-count.txt
  echo "📋 Details: .quality/naming-violations.txt"
  echo ""
  echo "Common violations:"
  grep "FAILED" .quality/naming-violations.txt 2>/dev/null | head -5
  echo ""
  echo "💡 Fix naming to match project conventions (see .ls-lint.yml)"
fi

# Generate summary JSON
cat > .quality/naming-summary.json << EOF
{
  "violations_count": $(cat .quality/naming-violations-count.txt),
  "status": "$([ $EXIT_CODE -eq 0 ] && echo 'passed' || echo 'failed')",
  "config_file": ".ls-lint.yml"
}
EOF

echo ""
echo "✅ Naming conventions check complete"
echo "📊 Report: .quality/naming-violations.txt"
