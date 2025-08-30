# Linear Issue 自動補完コマンド

## 使い方

Linear の Issue ID を指定すると、コードベースを検索・調査して、不足している description や label を自動的に補完します。

## コマンド形式

```
/linear-enrich <ISSUE_ID>
```

例：

```
/linear-enrich ENG-1234
```

## 実行フロー

### 1. Issue の取得

指定された Issue ID から現在の情報を取得します：

- タイトル
- 現在の説明文
- 既存のラベル
- ステータス
- 担当者

### 2. コードベース調査

Issue のタイトルとコンテキストから以下を自動調査：

#### コード検索

- 関連するファイル・関数・クラスを検索
- エラーメッセージやログから関連箇所を特定
- 類似の過去の実装を参照

#### 影響範囲の分析

- 変更が必要なファイル一覧
- 依存関係の確認
- テストファイルの特定

#### 技術スタック確認

- 使用されているフレームワーク/ライブラリ
- 必要な設定ファイル
- 環境変数の確認

### 3. 自動補完される情報

#### Description の拡充

```markdown
## 🔍 調査結果サマリー

[自動生成された調査結果の概要]

## 📍 関連コード

- `path/to/file.ts:123` - [該当関数/クラスの説明]
- `path/to/another.ts:456` - [関連する処理の説明]

## 🎯 影響範囲

### 直接影響を受けるファイル

- `src/components/Feature.tsx` - UI コンポーネント
- `src/api/feature.ts` - API エンドポイント
- `tests/feature.test.ts` - テストファイル

### 間接的な影響

- [依存関係のあるモジュール一覧]

## 🔧 実装に必要な変更

1. **フロントエンド**
   - [具体的な変更内容]
2. **バックエンド**
   - [具体的な変更内容]
3. **データベース**
   - [必要なマイグレーション]

## ⚠️ 注意事項

- [発見された潜在的な問題]
- [考慮すべきエッジケース]

## 🧪 テスト方針

- 単体テスト: [必要なテストケース]
- 統合テスト: [E2E シナリオ]

## 📚 参考実装

- [類似機能へのリンク]
- [関連する PR/Issue]

## 📈 見積もり

- 推定作業時間: [自動計算された見積もり]
- 複雑度: [Low/Medium/High]
```

#### Labels の自動推奨

コード調査結果に基づいて以下のラベルを自動推奨：

**作業タイプ**

- `bug` - エラー修正の場合
- `feature` - 新機能の場合
- `refactoring` - リファクタリングの場合
- `performance` - パフォーマンス改善の場合
- `security` - セキュリティ関連の場合

**サービス**

- Dart 系の修正
  - `p:mobile`: プレイ外の修正
  - `p:design_system`: design_system 配下の修正
  - `p:play_screen_v2`: プレイ中の修正
- `backend`: Backend 系の修正
- JS 系の修正
  - `p:web`: LP の修正
  - `p:admin`: Admin 画面の修正
  - `p:studio`: Studio Console の修正
  - `p:studio_editor`: Studio Editor の修正

### 4. 更新の実行

調査結果を基に Issue を自動更新：

- Description に詳細情報を追加
- 推奨ラベルを適用
- 関連リンクを追加
- Estimate の設定
- 必要に応じてコメントで補足情報を追加

## 実行例

### 入力

```
/linear-enrich ENG-1234
```

### 処理ログ

```
📋 Issue を取得中: ENG-1234
✅ 取得完了: "ユーザー認証エラーの修正"

🔍 コードベースを調査中...
  ✓ "authentication" で検索: 15 ファイル発見
  ✓ "auth error" で検索: 8 箇所発見
  ✓ エラーログ分析: 3 パターン検出
  ✓ 影響範囲分析: 12 ファイルが影響

📝 Description を生成中...
  ✓ 関連コード: 5 箇所を特定
  ✓ 影響範囲: フロントエンド 3, バックエンド 2
  ✓ テスト方針: 8 ケースを提案

🏷️ ラベルを推奨中...
  ✓ 技術: backend, typescript, authentication
  ✓ タイプ: bug, high-impact
  ✓ その他: needs-qa

📤 Linear を更新中...
  ✓ Description 更新完了
  ✓ ラベル 5 個を追加
  ✓ コメントで補足情報を追加

✨ Issue ENG-1234 の補完が完了しました！
```

## オプション

### --dry-run

実際の更新を行わず、変更内容をプレビュー

```
/linear-enrich ENG-1234 --dry-run
```

### --labels-only

ラベルの推奨のみを実行

```
/linear-enrich ENG-1234 --labels-only
```

### --description-only

Description の補完のみを実行

```
/linear-enrich ENG-1234 --description-only
```

### --depth

コード調査の深さを指定（1-3）

```
/linear-enrich ENG-1234 --depth=3
```

### --context

追加のコンテキストを提供

```
/linear-enrich ENG-1234 --context="本番環境でのみ発生"
```

## カスタマイズ

### 調査パターンの設定

プロジェクト固有の調査パターンを定義可能：

```json
{
  "search_patterns": {
    "error_patterns": ["ERROR", "Exception", "Failed"],
    "code_patterns": ["TODO", "FIXME", "HACK"],
    "test_patterns": ["test", "spec", "__tests__"]
  },
  "label_mapping": {
    "auth": ["authentication", "authorization", "login"],
    "perf": ["performance", "optimization", "speed"]
  }
}
```

## 注意事項

1. **大規模リポジトリ**: コードベースが大きい場合、調査に時間がかかることがあります
2. **権限**: Linear の Issue 更新権限が必要です
3. **精度**: 自動生成された内容は必ずレビューしてください
4. **プライバシー**: センシティブな情報が含まれないよう注意してください

---

Issue ID を指定して実行してください。コードベースを調査して、自動的に詳細情報を補完します。
