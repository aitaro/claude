# Claude Code Configuration Directory

このリポジトリは `~/.claude` ディレクトリと同期されることを前提としています。

## 概要

Claude Code (claude.ai/code) の設定とセッションデータを保存するディレクトリです。

## ディレクトリ構造

```
~/.claude/
├── commands/        # コマンドテンプレート
├── ide/            # IDE統合用ロックファイル
├── projects/       # プロジェクトごとのセッションデータ (JSONL)
├── statsig/        # テレメトリキャッシュ
├── todos/          # タスク管理データ (JSON)
├── settings.json   # Claude Code権限設定
├── mcp.json        # MCPサーバー設定
└── CLAUDE.md       # グローバル指示書
```

## セットアップ

```bash
# リポジトリをクローン
git clone [repository-url] ~/claude-config

# 既存の ~/.claude をバックアップ
mv ~/.claude ~/.claude.backup

# シンボリックリンクを作成
ln -s ~/claude-config ~/.claude
```

## 注意事項

- settings.json の編集時は、Claude Code の再起動が必要な場合があります
