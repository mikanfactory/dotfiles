---
name: commit-and-pr
description: 変更をコミットしてプルリクエストを作成する
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git push:*), Bash(git remote:*), Bash(gh pr:*), Bash(ls:*), Read, Glob, Skill
model: Sonnet
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のgit diff（ステージ済みおよび未ステージの変更）: !`git diff HEAD`
- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main"`
- 最近のコミット: !`git log --oneline -10`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- デフォルトブランチとこのブランチの差分: !`git diff origin/main...HEAD --stat`
- PRテンプレート: !`cat $(git rev-parse --show-toplevel)/.github/pull_request_template.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE/default.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/docs/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "テンプレートなし"`

## タスク

### ステップ0: プランモードの終了（アクティブな場合）

現在プランモードにいる場合は、ExitPlanModeツールを使用して今すぐ終了してください。コミットおよびPR作成の続行についてユーザーの承認を得ています。

### ステップ1: 変更を分割してコミットを作成

`git-commit-splitter`エージェントを使用して以下を実行します:

1. すべての変更を分析する（フォーマッタの変更を含む）
2. 変更を論理的でアトミックなコミットに分割する
3. 各論理グループに対して、明確で説明的なメッセージを持つ別々のコミットを作成する

### ステップ2: PRを作成

`pr-creator`エージェントを使用して以下を実行します。
**上記コンテキストのPRテンプレートの内容をエージェントのプロンプトに含めてください。**

1. 前提条件を確認する（ブランチ、コミットの存在）
2. 上記コンテキストに含まれるPRテンプレートを使用して説明文を生成する
3. 変更内容を分析し、日本語でPRタイトルと説明文を作成する
4. `gh pr create`でPRを作成し、結果を報告する

### ステップ3: セッションのクリア

PR作成完了後、常に`/clear`を実行してセッションをクリアしてください。

これにより、クリアせずに作業を続行した際の意図しないプッシュやコメントを防ぎます。

## 制約

- コミットにClaudeの共著フッターを追加しないこと
- 各コミットはアトミックであり、独立してリバートできるものであること
- **すべてのコミットメッセージは英語で書くこと**
- ブランチ比較は常に`origin/main`を使用すること
- PRタイトルと説明文の内容は日本語で記述すること
- 曖昧な点がある場合は作成前にユーザーに確認

---

## 参照

### エージェント
- [`git-commit-splitter`](../../agents/git-commit-splitter.md) - 変更を論理的なコミットに分割
- [`pr-creator`](../../agents/pr-creator.md) - PRの作成と説明文の生成
