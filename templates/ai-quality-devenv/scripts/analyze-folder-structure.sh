#!/usr/bin/env bash
# Folder Structure Analysis Script
# Part of AI Quality DevEnv Template - Week 1

echo ""
echo "📂 Folder Structure Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p .quality

echo "📊 Step 1: Directory Depth Analysis..."
MAX_DEPTH=$(find . -type d -not -path "*/node_modules/*" -not -path "*/.devenv/*" \
  -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" \
  -not -path "*/.direnv/*" -not -path "*/coverage/*" \
  | awk -F/ '{print NF-1}' | sort -rn | head -1)

echo "  Max depth: $MAX_DEPTH levels (recommended: ≤5)"
echo "$MAX_DEPTH" > .quality/max-depth.txt

if [ "$MAX_DEPTH" -gt 5 ]; then
  echo "  ⚠️  Depth exceeds recommended limit"
else
  echo "  ✓ Within recommended depth"
fi

echo ""
echo "📋 Step 2: Files Per Directory..."
echo "Analyzing directory file counts..."
find . -type d -not -path "*/node_modules/*" -not -path "*/.devenv/*" \
  -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" | while read dir; do
  count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
  if [ $count -gt 30 ]; then
    echo "⚠️  $dir: $count files (recommended: ≤30)"
  fi
done > .quality/files-per-dir.txt

WARNINGS=$(wc -l < .quality/files-per-dir.txt)
if [ "$WARNINGS" -gt 0 ]; then
  echo "  ⚠️  $WARNINGS directories exceed 30 files"
  cat .quality/files-per-dir.txt
else
  echo "  ✓ All directories within limits"
fi

echo ""
echo "🏗️  Step 3: God Directories (>50 files)..."
GOD_COUNT=0
find . -type d -not -path "*/node_modules/*" -not -path "*/.devenv/*" \
  -not -path "*/.git/*" -not -path "*/dist/*" | while read dir; do
  count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
  if [ $count -gt 50 ]; then
    echo "  🔴 $dir: $count files"
    GOD_COUNT=$((GOD_COUNT + 1))
  fi
done | tee .quality/god-directories.txt

if [ -s .quality/god-directories.txt ]; then
  echo "  ⚠️  God directories detected - consider reorganization"
else
  echo "  ✓ No god directories found"
fi

echo ""
echo "📁 Step 4: Root Directory Clutter..."
ROOT_FILES=$(find . -maxdepth 1 -type f 2>/dev/null | wc -l)
echo "  Root level files: $ROOT_FILES (recommended: ≤5)"
echo "$ROOT_FILES" > .quality/root-files-count.txt

if [ "$ROOT_FILES" -gt 5 ]; then
  echo "  ⚠️  Consider moving configuration files to subdirectories"
else
  echo "  ✓ Root directory is clean"
fi

echo ""
echo "📐 Step 5: Structure Score Calculation..."
SCORE=100

# Deduct points for violations
if [ "$MAX_DEPTH" -gt 5 ]; then
  PENALTY=$(( (MAX_DEPTH - 5) * 10 ))
  SCORE=$((SCORE - PENALTY))
  echo "  -$PENALTY points: Excessive depth ($MAX_DEPTH levels)"
fi

if [ "$ROOT_FILES" -gt 5 ]; then
  PENALTY=$(( (ROOT_FILES - 5) * 2 ))
  SCORE=$((SCORE - PENALTY))
  echo "  -$PENALTY points: Root clutter ($ROOT_FILES files)"
fi

if [ -s .quality/god-directories.txt ]; then
  GOD_COUNT=$(wc -l < .quality/god-directories.txt)
  PENALTY=$((GOD_COUNT * 15))
  SCORE=$((SCORE - PENALTY))
  echo "  -$PENALTY points: God directories ($GOD_COUNT found)"
fi

# Ensure score doesn't go below 0
if [ "$SCORE" -lt 0 ]; then
  SCORE=0
fi

echo "$SCORE" > .quality/structure-score.txt
echo ""
echo "📊 Structure Score: $SCORE/100"

if [ "$SCORE" -ge 80 ]; then
  echo "  ✅ Excellent structure"
elif [ "$SCORE" -ge 60 ]; then
  echo "  ⚠️  Good, but room for improvement"
elif [ "$SCORE" -ge 40 ]; then
  echo "  ⚠️  Needs reorganization"
else
  echo "  🔴 Significant structural issues"
fi

echo ""
echo "✅ Structure analysis complete"
echo "📊 Reports: .quality/max-depth.txt, .quality/structure-score.txt"
