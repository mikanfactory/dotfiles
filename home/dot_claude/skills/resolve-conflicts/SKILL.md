---
name: resolve-conflicts
description: マージコンフリクトを分析し、安全に解決する
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git merge:*), Bash(git rebase:*), Bash(git add:*), Bash(git checkout:*), Read, Edit, Grep, Glob
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- マージ/リベースの状態: !`git status`
- コンフリクトのあるファイル: !`git diff --name-only --diff-filter=U 2>/dev/null || echo "コンフリクトなし"`

## タスク

### ステップ0: プランモードの終了（アクティブな場合）

現在プランモードにいる場合は、ExitPlanModeツールを使用して今すぐ終了してください。コンフリクト解決の続行についてユーザーの承認を得ています。

### ステップ1: コンフリクトを解決

`conflict-resolver`エージェントを使用して以下を実行します:

1. コンフリクトを分析し、各ファイルの解決方針を提示する
2. ユーザーの承認後、コンフリクトを解決してステージングする
3. **コミットは実行しない** - ユーザーが `/commit` で実行する

## 制約

- コンフリクトのあるファイル以外を変更しないこと
- コミットを実行しないこと（ステージングまで）
- フォーマット修正やリファクタリングを行わないこと

---

## 参照

### エージェント
- [`conflict-resolver`](../../agents/conflict-resolver.md) - コンフリクトの分析と解決

### スキル
- [`/commit`](../commit/SKILL.md) - コンフリクト解決後のコミット作成
