---
name: design-pen
description: .penファイルのデザイン提案・実装スキル。Pencil MCPツールを使用して、プロのデザイナーとしてUIデザインを作成・編集する。ユーザーが.penファイルのデザイン作業を依頼した場合、またはUIデザイン・レイアウト・コンポーネント作成を要望した場合にトリガー。
allowed-tools: mcp__pencil__*
---

# Design Pen

Pencil MCPツールを使用して.penファイルのデザインを提案・実装するスキル。

## ワークフロー

### ステップ1: エディタ状態確認

`get_editor_state(include_schema: true)` で現在の状態を取得する。

- エディタが開いていない場合: `open_document` で対象ファイルを開く（新規なら `"new"`）
- スキーマは初回のみ取得し、以降は `include_schema: false` を使用

### ステップ2: 現状把握

`batch_get` でドキュメント構造を読み取る。

- 既存コンポーネント（`reusable: true`）を検索して利用可能な部品を把握
- `readDepth: 2` で全体構造を確認
- 選択中のノードがあれば、そのコンテキストを理解

### ステップ3: ガイドライン・スタイル取得

デザインタイプに応じて適切なガイドラインを取得する。

| デザインタイプ | `get_guidelines` topic |
|--------------|----------------------|
| ランディングページ | `landing-page` |
| モバイルアプリ | `mobile-app` |
| Webアプリ/ダッシュボード | `web-app` |
| デザインシステム利用 | `design-system` |
| スライド | `slides` |
| テーブル含む | `table` |

新規デザインの場合は `get_style_guide_tags` → `get_style_guide(tags)` でスタイルガイドも取得する。

### ステップ4: デザイン提案

実装前にテキストでデザイン方針を提示する:

- レイアウト構造（フレーム階層）
- 使用コンポーネント
- カラー・タイポグラフィ方針
- レスポンシブ対応（該当する場合）

**ユーザーの承認を待つ。承認なしに実装しない。**

### ステップ5: 実装

承認後、`batch_design` で変更を適用する。

- 1回あたり最大25操作に制限
- 大規模な変更は複数回に分割（構造→コンテンツ→スタイルの順）
- 操作構文の詳細は [pencil-tool-patterns.md](./references/pencil-tool-patterns.md) を参照

### ステップ6: 検証

実装後に品質を確認する。

1. `get_screenshot` で視覚的に確認
2. `snapshot_layout(problemsOnly: true)` でレイアウト問題を検出
3. 問題があれば修正を適用

### ステップ7: 結果提示

スクリーンショットとともに変更内容をユーザーに提示する。問題点や改善提案があれば併せて報告する。

---

## 参照

### ドキュメント
- [`pencil-tool-patterns.md`](./references/pencil-tool-patterns.md) - batch_design操作の具体パターン集
