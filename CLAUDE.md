# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際の Claude Code (claude.ai/code) へのガイダンスを提供します。

## 概要

これは Claude CLI の設定とデータストレージディレクトリ (`~/.claude`) です。通常のソフトウェアプロジェクトではなく、Claude Code の動作設定と作業セッションデータを管理する場所です。

## ディレクトリ構造

- `/commands/` - コマンドテンプレート（現在は `start-task.md` のみ）
- `/ide/` - IDE 統合用のロックファイル
- `/projects/` - プロジェクトごとのセッションデータ（JSONL形式）
- `/statsig/` - 分析/テレメトリのキャッシュ
- `/todos/` - タスク管理データ（JSON形式）

## 重要な設定

### settings.json

このファイルには Claude Code の権限設定が含まれています。主な許可されているコマンド：

**JavaScript/Node.js 開発:**
- `npm run build:*`, `npm run lint`, `npm install`
- `npx eslint:*`, `npx prettier:*`, `npx tsc:*`
- `npx prisma migrate dev:*`

**Go 開発:**
- `go mod:*`, `go build:*`, `go test:*`, `go run:*`

**Git/GitHub:**
- `git add:*`, `git commit:*`, `git push:*`, `git stash:*`
- `gh pr create:*`, `gh pr view:*`, `gh pr checkout:*`

**その他:**
- 基本的なファイル操作（`ls`, `mkdir`, `mv`, `rm`, `chmod`）
- `curl:*`, `python3:*`, `python test:*`
- カスタムスクリプト実行

## 作業中のプロジェクト

`/projects/` ディレクトリには以下のプロジェクトのセッションデータが保存されています：
- uzu-app 関連のプロジェクト群
- blog-starter-app
- dotfiles
- zenn（出版プラットフォーム）

## 注意事項

1. このディレクトリはソースコードリポジトリではないため、通常の開発タスク（ビルド、テスト、リント）は適用されません
2. 設定を変更する場合は `settings.json` を編集してください
3. プロジェクトセッションデータは自動的に管理されるため、手動での編集は推奨されません

## ファイル作成時の重要な規則

**必ずUTF-8エンコーディングでファイルを作成すること**
- Write ツールを使用する際は、常にUTF-8エンコーディングでファイルを保存する
- 日本語を含むファイルでも文字化けを防ぐため、この規則を厳守する
- 文字化けが発生した場合は、即座にUTF-8で書き直す

## GitHub PR アクセス時の注意

**GitHub のプライベートリポジトリの PR にアクセスする際は gh CLI を使用すること**
- `gh pr view <PR番号> --repo <オーナー名>/<リポジトリ名>` でPR情報を取得
- `gh pr diff <PR番号> --repo <オーナー名>/<リポジトリ名>` でPRの差分を確認
- `gh api` コマンドで詳細な情報を取得可能
- WebFetch では 404 エラーになるプライベートリポジトリも gh CLI なら正常にアクセス可能