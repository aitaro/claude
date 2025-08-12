#!/bin/bash

# 出力先のJSONファイル
OUTPUT_FILE="./settings.json"

# 現在のsettings.jsonを読み込み（存在しない場合は空のJSONを作成）
if [ -f "$OUTPUT_FILE" ]; then
    CURRENT_JSON=$(cat "$OUTPUT_FILE")
else
    CURRENT_JSON='{}'
fi

# 全てのsettings.local.jsonファイルを検索し、permissions.allowを収集
echo "Collecting permissions from all settings.local.json files..."

# 一時ファイルを作成してすべてのpermissionsを収集
TEMP_PERMS="/tmp/all_permissions_$$.txt"
> "$TEMP_PERMS"

# works/uzu/app と works/uzu/app.worktree 配下のsettings.local.jsonファイルのみを検索
find ~/works/uzu/app ~/works/uzu/app.worktree -name "settings.local.json" -type f 2>/dev/null | while read -r file; do
    echo "Processing: $file"
    if [ -f "$file" ]; then
        jq -r '.permissions.allow[]? // empty' "$file" 2>/dev/null >> "$TEMP_PERMS"
    fi
done

# 現在のsettings.jsonからも既存のpermissionsを取得
echo "$CURRENT_JSON" | jq -r '.permissions.allow[]? // empty' 2>/dev/null >> "$TEMP_PERMS"

# 重複を除去してソート
ALL_PERMISSIONS=$(cat "$TEMP_PERMS" | grep -v '^$' | sort -u)

# permissions配列をJSON形式に変換
PERMISSIONS_JSON=$(echo "$ALL_PERMISSIONS" | jq -R . | jq -s .)

# 新しいsettings.jsonを作成
NEW_JSON=$(echo "$CURRENT_JSON" | jq --argjson perms "$PERMISSIONS_JSON" '
    .permissions = .permissions // {} |
    .permissions.allow = $perms
')

# ファイルに書き込み
echo "$NEW_JSON" | jq '.' > "$OUTPUT_FILE"

# 一時ファイルを削除
rm -f "$TEMP_PERMS"

echo "✅ Permissions have been collected and merged into $OUTPUT_FILE"
echo "Total unique permissions: $(echo "$ALL_PERMISSIONS" | wc -l | tr -d ' ')"