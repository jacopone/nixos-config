#!/usr/bin/env python3
"""
Add YAML frontmatter to markdown files based on their location and purpose.
"""

import os
import sys
from pathlib import Path
from datetime import date

# File categorization rules
RULES = [
    # (path_pattern, status, type, lifecycle, created_date)
    ("docs/architecture/*.md", "active", "architecture", "persistent", "2025-10-03"),
    ("docs/guides/*.md", "active", "guide", "persistent", None),
    ("docs/tools/*.md", "active", "guide", "persistent", None),
    ("docs/analysis/*.md", "active", "guide", "persistent", None),
    ("docs/integrations/*.md", "active", "reference", "persistent", None),

    # BASB guides
    ("basb-system/BASB-*.md", "active", "guide", "persistent", None),

    # BASB session notes
    ("basb-system/*SUMMARY*.md", "archived", "session-note", "ephemeral", "2025-10-01"),
    ("basb-system/CHROME-*.md", "archived", "session-note", "ephemeral", "2025-10-01"),
    ("basb-system/README.md", "active", "reference", "persistent", "2024-08-01"),
    ("basb-system/README-QUICKSTART.md", "active", "guide", "persistent", None),

    # Planning docs (should be archived)
    ("docs/planning/**/*.md", "draft", "planning", "ephemeral", "2025-10-05"),
    ("docs/automation/*.md", "draft", "planning", "ephemeral", "2025-10-07"),

    # Stack management
    ("stack-management/README.md", "active", "reference", "persistent", None),
    ("stack-management/CHROME-EXTENSIONS.md", "active", "reference", "persistent", None),
    ("stack-management/active/*.md", "active", "reference", "persistent", None),
    ("stack-management/chrome-profiles/**/*.md", "active", "reference", "persistent", None),
    ("stack-management/discovery/*.md", "draft", "reference", "ephemeral", None),
    ("stack-management/deprecated/*.md", "deprecated", "reference", "ephemeral", None),
    ("stack-management/templates/*.md", "active", "reference", "persistent", None),

    # Archive
    ("docs/archive/*.md", "archived", "session-note", "ephemeral", None),

    # Templates
    ("templates/*.md", "active", "reference", "persistent", None),
]

def file_has_frontmatter(filepath):
    """Check if file already has YAML frontmatter."""
    try:
        with open(filepath, 'r') as f:
            first_line = f.readline().strip()
            return first_line == '---'
    except:
        return False

def add_frontmatter(filepath, status, doc_type, lifecycle, created):
    """Add YAML frontmatter to a markdown file."""
    if file_has_frontmatter(filepath):
        print(f"⏭️  Skipping (has frontmatter): {filepath}")
        return False

    try:
        with open(filepath, 'r') as f:
            content = f.read()

        today = date.today().isoformat()
        created_date = created if created else today

        frontmatter = f"""---
status: {status}
created: {created_date}
updated: {today}
type: {doc_type}
lifecycle: {lifecycle}
---

"""
        with open(filepath, 'w') as f:
            f.write(frontmatter + content)

        print(f"✅ Added frontmatter: {filepath}")
        print(f"   status={status}, type={doc_type}, lifecycle={lifecycle}")
        return True
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")
        return False

def main():
    repo_root = Path(__file__).parent.parent
    os.chdir(repo_root)

    processed = 0
    skipped = 0

    print("📋 Adding YAML frontmatter to markdown files...")
    print()

    # Skip auto-generated files
    skip_files = {"CLAUDE.md"}

    # Process all markdown files
    for pattern, status, doc_type, lifecycle, created in RULES:
        for filepath in repo_root.glob(pattern):
            if filepath.name in skip_files:
                continue

            if filepath.is_file() and filepath.suffix == '.md':
                if add_frontmatter(filepath, status, doc_type, lifecycle, created):
                    processed += 1
                else:
                    skipped += 1

    print()
    print("📊 Summary:")
    print(f"   ✅ Processed: {processed} files")
    print(f"   ⏭️  Skipped: {skipped} files")
    print()
    print("✨ Done!")

if __name__ == "__main__":
    main()
