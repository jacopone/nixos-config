#!/usr/bin/env bash
# Documentation Quality Assessment Script
# Part of AI Quality DevEnv Template - Week 1

echo ""
echo "📚 Documentation Quality Assessment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p .quality

echo "📝 Step 1: Markdown Linting..."
markdownlint-cli2 "**/*.md" --config .markdownlint-cli2.jsonc \
  2>&1 | tee .quality/markdown-lint.txt || true

echo ""
echo "📖 Step 2: JSDoc Coverage (TypeScript/JavaScript)..."
if [ -d "src" ]; then
  # Count functions and their documentation
  TOTAL_FUNCS=$(rg --type ts --type js "^(export )?(function|const .* =|class )" src/ -c 2>/dev/null | \
    awk -F: '{sum += $2} END {print sum}' || echo "0")
  DOCUMENTED_FUNCS=$(rg --type ts --type js -B 1 "^(export )?(function|const .* =|class )" src/ 2>/dev/null | \
    rg "^\s*\*|^/\*\*" -c || echo "0")

  if [ "$TOTAL_FUNCS" -gt 0 ]; then
    JSDOC_PCT=$((DOCUMENTED_FUNCS * 100 / TOTAL_FUNCS))
  else
    JSDOC_PCT=0
  fi

  echo "{\"total_functions\": $TOTAL_FUNCS, \"documented\": $DOCUMENTED_FUNCS, \"coverage_pct\": $JSDOC_PCT}" \
    > .quality/jsdoc-coverage.json
  echo "  ✓ JSDoc coverage: $JSDOC_PCT% ($DOCUMENTED_FUNCS/$TOTAL_FUNCS functions)"
else
  echo "  ℹ️  No src/ directory found"
  echo "{\"total_functions\": 0, \"documented\": 0, \"coverage_pct\": 0}" > .quality/jsdoc-coverage.json
fi

echo ""
echo "🐍 Step 3: Python Docstring Coverage..."
if command -v interrogate &> /dev/null && [ -d "src" ]; then
  interrogate --quiet --generate-badge .quality/ src/ 2>&1 | tee .quality/docstring-coverage.txt || true
else
  echo "  ℹ️  interrogate not available or no src/ directory"
fi

echo ""
echo "📋 Step 4: Required Documentation Files..."
REQUIRED_DOCS=("README.md" "ARCHITECTURE.md")
MISSING_DOCS=()

for doc in "${REQUIRED_DOCS[@]}"; do
  if [ -f "$doc" ]; then
    echo "  ✓ $doc exists"
  else
    echo "  ✗ $doc missing"
    MISSING_DOCS+=("$doc")
  fi
done

# Generate JSON report
if command -v jq &> /dev/null; then
  printf '%s\n' "${MISSING_DOCS[@]}" | jq -R . | jq -s '{missing_docs: .}' > .quality/required-docs.json
else
  echo "{\"missing_docs\": [$(printf '"%s",' "${MISSING_DOCS[@]}" | sed 's/,$//')]}" > .quality/required-docs.json
fi

echo ""
echo "✅ Documentation assessment complete"
echo "📊 Reports: .quality/markdown-lint.txt, .quality/jsdoc-coverage.json"
