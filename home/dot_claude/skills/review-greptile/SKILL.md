---
name: review-greptile
description: GitHub PRのGreptileレビューコメントを取得・分析し、各コメントに対して対応/スキップの判定を提示する。ユーザーがGreptileのレビュー対応を依頼した場合にトリガー。
allowed-tools: Bash(gh api:*), Bash(gh pr:*), Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Read, Edit, Glob, Grep
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在のPR: !`gh pr view --json number,url,title 2>/dev/null || echo "PRなし"`
- リポジトリ情報: !`gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "不明"`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

## タスク

GitHub PRに投稿されたGreptileのレビューコメントを取得・分析し、各コメントに対して対応/スキップの判定を提示します。ユーザーが選択したコメントのみを修正します。

### ステップ1: PR番号の特定

以下の優先順位でPR番号を決定:

**オプションA: 引数で指定された場合**
ユーザーが `/review-greptile 123` のように番号を指定した場合、その番号を使用。

**オプションB: 現在のブランチのPR（デフォルト）**
```bash
gh pr view --json number --jq '.number'
```

PRが見つからない場合はエラーを報告して終了。

### ステップ2: Greptileコメントの取得

リポジトリのowner/repoは上記コンテキストの「リポジトリ情報」から取得する。

#### 2a: インラインレビューコメント

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate \
  --jq '[.[] | select(.user.login | test("greptile")) | {id, path, line: (.line // .original_line), side, body, diff_hunk, created_at}]'
```

#### 2b: トップレベルレビュー

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate \
  --jq '[.[] | select(.user.login | test("greptile")) | {id, body, state}]'
```

#### 2c: レビューに紐づくコメント

レビューIDが取得できた場合:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews/{review_id}/comments --paginate \
  --jq '[.[] | {id, path, line: (.line // .original_line), body, diff_hunk}]'
```

コメントが0件の場合は「Greptileのコメントはありません」と報告して終了。

### ステップ3: コードコンテキストの読み込みと分析

各インラインコメントについて:

1. コメントが参照するファイルパスと行番号を特定
2. `Read`で該当ファイルの関連部分を読み込む（コメント行の前後20行程度）
3. コメントの内容とコードを照合し、以下を判定:
   - **妥当性**: コメントの指摘は正しいか
   - **重要度**: `バグ` / `セキュリティ` / `パフォーマンス` / `スタイル` / `その他`
   - **対応推奨**: `対応` または `スキップ`
   - **理由**: 判定の根拠（1-2文）
   - **修正案**: 対応推奨の場合、具体的な修正内容（1文）

### ステップ4: 判定結果の提示

以下のフォーマットで結果を表示:

```markdown
# Greptileレビュー分析レポート

**PR:** #123 - PRタイトル
**コメント数:** X件 | **推奨対応:** Y件 | **推奨スキップ:** Z件

## コメント一覧

### [1] 対応推奨 | バグ | `src/api/users.py:42`
**指摘:** NullPointerの可能性...
**分析:** 指摘は妥当。`user`がNoneの場合にエラーが発生する。
**修正案:** Noneチェックの追加

### [2] スキップ推奨 | スタイル | `src/utils/helper.py:15`
**指摘:** 変数名が不明瞭...
**分析:** 現在の命名はドメイン用語に基づいており適切。

---

対応するコメント番号を指定してください（例: `1,3,5` / `all` / `none`）
```

トップレベルレビュー（ファイル参照なし）は「総括コメント」として別セクションに表示。

### ステップ5: ユーザー選択の待機

ユーザーの回答を待つ:

- `1,3,5` — 指定番号のコメントのみ修正
- `all` — 推奨対応のすべてを修正
- `none` — 修正せず終了

### ステップ6: 選択されたコメントの修正

ユーザーが選択した各コメントについて:

1. 該当ファイルを`Read`で読み込み
2. `Edit`で修正を実施
3. 修正内容を簡潔に報告
4. 次のコメントに移動

すべての修正完了後、修正サマリーを表示:

```markdown
## 修正サマリー

| # | ファイル | 修正内容 |
|---|---------|---------|
| 1 | `src/api/users.py:42` | Noneチェックを追加 |
| 3 | `src/db/queries.py:67` | パラメータバインディングに変更 |

修正が完了しました。`/commit` でコミットできます。
```

## 制約

- レビュー結果のみを提示し、ユーザーの明示的な指示なしに修正を実施しない
- Greptileのコメント以外のレビューコメントは対象外
- 修正はコメントが指摘する範囲のみ（スコープ外のリファクタリングは行わない）
- ユーザーとのコミュニケーションでは常に日本語で結果を出力

## 使用例

```bash
# 現在のブランチのPRのGreptileコメントをレビュー（デフォルト）
/review-greptile

# 特定のPR番号を指定
/review-greptile 123
```

---

## 参照

### スキル
- [`/commit`](../commit/SKILL.md) - 修正後のコミット作成
