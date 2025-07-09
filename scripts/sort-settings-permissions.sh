#!/bin/bash

# Script to sort permissions.allow array in settings.json alphabetically

SETTINGS_FILE="${1:-$HOME/.claude/settings.json}"

# Check if file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "✗ File not found: $SETTINGS_FILE"
    exit 1
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# Use jq to sort the permissions.allow array
if jq '.permissions.allow |= sort' "$SETTINGS_FILE" > "$TEMP_FILE" 2>/dev/null; then
    # Move the sorted content back to the original file
    mv "$TEMP_FILE" "$SETTINGS_FILE"
    echo "✓ Sorted permissions.allow in $SETTINGS_FILE"
else
    echo "✗ Error processing JSON file"
    rm -f "$TEMP_FILE"
    exit 1
fi