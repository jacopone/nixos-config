#!/usr/bin/env bash
# smart-office-open: Opens office files intelligently
# - Google Drive native files (0 byte in ~/GoogleDrive): opens in browser
# - Regular files: opens with OnlyOffice

GDRIVE_MOUNT="$HOME/GoogleDrive"

if [[ $# -eq 0 ]]; then
    echo "Usage: smart-office-open <file>" >&2
    exit 1
fi

FILE="$1"

# Resolve to absolute path
if [[ ! "$FILE" = /* ]]; then
    FILE="$(pwd)/$FILE"
fi

# Check if file exists
if [[ ! -e "$FILE" ]]; then
    echo "Error: File not found: $FILE" >&2
    exit 1
fi

# Check if it's in GoogleDrive mount AND is a 0-byte file (Google native)
if [[ "$FILE" == "$GDRIVE_MOUNT"* ]]; then
    FILE_SIZE=$(stat -c%s "$FILE" 2>/dev/null || echo "0")

    if [[ "$FILE_SIZE" -eq 0 ]]; then
        # Google native file - get file ID and open in browser
        RELATIVE_PATH="${FILE#"$GDRIVE_MOUNT"/}"
        DIR_PATH=$(dirname "$RELATIVE_PATH")
        FILENAME=$(basename "$RELATIVE_PATH")

        # Get file ID using rclone lsf
        FILE_ID=$(rclone lsf "gdrive:$DIR_PATH/" --format "pi" 2>/dev/null | grep "^${FILENAME};" | head -1 | sed 's/^[^;]*;//' | cut -f1)

        if [[ -n "$FILE_ID" ]]; then
            xdg-open "https://drive.google.com/open?id=$FILE_ID"
            exit 0
        fi

        # Fallback: try rclone link
        WEB_LINK=$(rclone link "gdrive:$RELATIVE_PATH" 2>/dev/null)
        if [[ -n "$WEB_LINK" ]]; then
            xdg-open "$WEB_LINK"
            exit 0
        fi

        echo "Error: Could not get web link for $FILE" >&2
        exit 1
    fi
fi

# Regular file - open with OnlyOffice
onlyoffice-desktopeditors "$FILE"
