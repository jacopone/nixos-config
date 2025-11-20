#!/usr/bin/env python3
"""
Pre-commit hook to enforce YAML frontmatter in Markdown documentation.

Validates that documentation files have proper YAML frontmatter with required fields:
- status: draft | active | deprecated | archived
- created: YYYY-MM-DD
- updated: YYYY-MM-DD
- type: guide | reference | planning | session-note | architecture
- lifecycle: ephemeral | persistent
"""

import sys
import re
from pathlib import Path
from datetime import datetime

# Required frontmatter fields
REQUIRED_FIELDS = {'status', 'created', 'updated', 'type', 'lifecycle'}

# Valid values for enum fields
VALID_STATUS = {'draft', 'active', 'deprecated', 'archived'}
VALID_TYPE = {'guide', 'reference', 'planning', 'session-note', 'architecture'}
VALID_LIFECYCLE = {'ephemeral', 'persistent'}

# Date format regex
DATE_REGEX = re.compile(r'^\d{4}-\d{2}-\d{2}$')

def parse_frontmatter(content: str) -> dict | None:
    """Extract and parse YAML frontmatter from markdown content."""
    if not content.startswith('---'):
        return None

    try:
        # Find the closing --- delimiter
        end_idx = content.find('---', 3)
        if end_idx == -1:
            return None

        frontmatter_text = content[3:end_idx].strip()

        # Simple YAML parser for key: value pairs
        frontmatter = {}
        for line in frontmatter_text.split('\n'):
            line = line.strip()
            if ':' in line:
                key, value = line.split(':', 1)
                frontmatter[key.strip()] = value.strip()

        return frontmatter
    except Exception:
        return None

def validate_frontmatter(filepath: Path, frontmatter: dict) -> list[str]:
    """Validate frontmatter fields and return list of errors."""
    errors = []

    # Check required fields
    missing = REQUIRED_FIELDS - frontmatter.keys()
    if missing:
        errors.append(f"Missing required fields: {', '.join(missing)}")

    # Validate status
    if 'status' in frontmatter:
        if frontmatter['status'] not in VALID_STATUS:
            errors.append(f"Invalid status '{frontmatter['status']}'. Must be one of: {', '.join(VALID_STATUS)}")

    # Validate type
    if 'type' in frontmatter:
        if frontmatter['type'] not in VALID_TYPE:
            errors.append(f"Invalid type '{frontmatter['type']}'. Must be one of: {', '.join(VALID_TYPE)}")

    # Validate lifecycle
    if 'lifecycle' in frontmatter:
        if frontmatter['lifecycle'] not in VALID_LIFECYCLE:
            errors.append(f"Invalid lifecycle '{frontmatter['lifecycle']}'. Must be one of: {', '.join(VALID_LIFECYCLE)}")

    # Validate dates
    for date_field in ['created', 'updated']:
        if date_field in frontmatter:
            if not DATE_REGEX.match(frontmatter[date_field]):
                errors.append(f"Invalid {date_field} date '{frontmatter[date_field]}'. Must be YYYY-MM-DD format")
            else:
                # Validate it's a real date
                try:
                    datetime.strptime(frontmatter[date_field], '%Y-%m-%d')
                except ValueError:
                    errors.append(f"Invalid {date_field} date '{frontmatter[date_field]}'. Not a valid date")

    return errors

def check_file(filepath: str) -> tuple[bool, list[str]]:
    """Check a single file for valid frontmatter. Returns (success, errors)."""
    path = Path(filepath)

    # Skip certain directories
    if any(part in path.parts for part in ['.git', 'node_modules', '.direnv']):
        return True, []

    # Only check markdown files in docs/
    if not str(path).startswith('docs/') or path.suffix != '.md':
        return True, []

    try:
        content = path.read_text(encoding='utf-8')
    except Exception as e:
        return False, [f"Failed to read file: {e}"]

    # Parse frontmatter
    frontmatter = parse_frontmatter(content)
    if frontmatter is None:
        return False, ["Missing YAML frontmatter. Add:\n---\nstatus: draft\ncreated: YYYY-MM-DD\nupdated: YYYY-MM-DD\ntype: guide\nlifecycle: persistent\n---"]

    # Validate frontmatter
    errors = validate_frontmatter(path, frontmatter)
    if errors:
        return False, errors

    return True, []

def main():
    """Main entry point for pre-commit hook."""
    files = sys.argv[1:] if len(sys.argv) > 1 else []

    if not files:
        print("No files to check")
        return 0

    all_passed = True
    for filepath in files:
        success, errors = check_file(filepath)
        if not success:
            all_passed = False
            print(f"\n❌ {filepath}")
            for error in errors:
                print(f"   {error}")

    if all_passed:
        print(f"✅ All {len(files)} file(s) have valid frontmatter")
        return 0
    else:
        print("\n💡 Fix frontmatter errors above and try again")
        return 1

if __name__ == '__main__':
    sys.exit(main())
