---
name: create-pr
description: 日本語の説明文でプルリクエストを作成する
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git push:*), Bash(git remote:*), Bash(gh pr:*), Bash(ls:*), Read, Glob
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main"`
- このブランチの最近のコミット: !`git log --oneline -10`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

## タスク

現在のブランチに対して、日本語で整理された説明文を持つプルリクエストを作成します。

### ステップ0: プランモードの終了（アクティブな場合）

現在プランモードにいる場合は、ExitPlanModeツールを使用して今すぐ終了してください。プルリクエスト作成の続行についてユーザーの承認を得ています。

### ステップ1: 前提条件の確認

1. 現在のブランチがデフォルトブランチ（main/master）でないことを確認
2. PRを作成するコミットが存在するか確認
3. コミットが存在しない場合は、ユーザーに通知して終了

### ステップ2: PRテンプレートの確認

以下の順序でPRテンプレートを検索します:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `.github/PULL_REQUEST_TEMPLATE/default.md`
4. `docs/PULL_REQUEST_TEMPLATE.md`
5. `PULL_REQUEST_TEMPLATE.md`

`Read`ツールを使用して、これらのファイルが存在するか確認し、見つかった場合は内容を読み取ります。
見つからない場合は、ユーザーに通知して終了。

### ステップ3: PR説明文のための変更分析

変更に関する包括的な情報を収集します:

1. ベースブランチに対するdiffサマリーを取得
2. このブランチのすべてのコミットメッセージを取得
3. 変更の種類を特定（機能追加、バグ修正、リファクタリングなど）

### ステップ4: PRタイトルと説明文の生成

#### PRテンプレートが存在する場合:

**重要: テンプレートの構造を厳密に保持すること**

1. **見出しの保持**
   - テンプレート内のすべての見出し（`##`, `###` など）をそのまま維持する
   - 見出しの順序を変更しない
   - 見出しを日本語に翻訳しない（英語の見出しはそのまま使用）

2. **セクション内容の記述**
   - 各セクションの内容は日本語で記述する
   - `<!-- ... -->` のHTMLコメントによる指示がある場合は、その指示に従う
   - プレースホルダーテキスト（例: `Describe your changes here`）は削除し、実際の内容に置き換える

3. **チェックボックスの処理**
   - チェックボックス（`- [ ]`）はそのまま残す
   - 該当する項目にはチェック（`- [x]`）を入れる
   - 該当しない項目はチェックなしのまま残す

4. **入出力例**

   テンプレート:
   ```markdown
   ## Description
   <!-- Describe your changes -->

   ## Type of change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   ```

   出力:
   ```markdown
   ## Description
   ユーザー認証のバグを修正しました。ログイン時にセッションが正しく保存されない問題を解決。

   ## Type of change
   - [x] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   ```

### ステップ5: PRタイトルの生成

簡潔で説明的なPRタイトルを日本語で作成します:
- 主な変更を要約
- 70文字以内
- プロジェクトの慣例に従って適切なプレフィックスを使用

### ステップ6: PRの作成

複数行のbodyにはHEREDOCを使用して`gh pr create`を実行します:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<PR body content>
EOF
)"
```

### ステップ7: 結果の報告

PR URLを表示し、含まれた内容を要約します。

### ステップ8: セッションのクリア

PR作成完了後、常に`/clear`を実行してセッションをクリアしてください。

これにより、クリアせずに作業を続行した際の意図しないプッシュやコメントを防ぎます。

## 制約

- **PRタイトルと説明文の内容は日本語で記述すること**
  - ただし、テンプレートの見出し（`## Description` など）は英語のまま保持する
  - 日本語化するのはセクションの本文のみ
- 変更を自動的にプッシュしない; `gh pr create`に任せる
- PR作成が失敗した場合、エラーを表示して解決策を提案
- 曖昧な点がある場合は作成前にユーザーに確認

## エッジケース

### リモートトラッキングブランチがない場合
以下でプッシュ: `git push -u origin $(git branch --show-current)`

### PRがすでに存在する場合
以下で確認: `gh pr view --json url -q '.url' 2>/dev/null`

### 複数のPRテンプレートがある場合
一覧を表示し、どれを使用するかユーザーに確認する。

## コミュニケーションスタイル

- 常に日本語で回答する
- PRの内容を積極的に説明する
- PRを作成する前に確認を求める
