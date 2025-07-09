#!/bin/bash

# Script to merge mcp.json into ~/.claude/settings.json

MCP_FILE="$HOME/.claude/mcp.json"
SETTINGS_FILE="$HOME/.claude.json"
BACKUP_FILE="$HOME/.claude.json.backup"

# Check if required files exist
if [ ! -f "$MCP_FILE" ]; then
    echo "Error: $MCP_FILE not found"
    exit 1
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Error: $SETTINGS_FILE not found"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

# Create backup
echo "Creating backup at $BACKUP_FILE"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Merge the files
echo "Merging $MCP_FILE into $SETTINGS_FILE"
jq -s '.[0] * .[1]' "$SETTINGS_FILE" "$MCP_FILE" >"$SETTINGS_FILE.tmp"

# Check if merge was successful
if [ $? -eq 0 ]; then
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "Successfully merged mcp.json into settings.json"
    echo "Backup saved at: $BACKUP_FILE"
else
    echo "Error: Failed to merge files"
    rm -f "$SETTINGS_FILE.tmp"
    exit 1
fi
