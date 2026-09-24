---
name: resolve-conflicts
description: マージコンフリクトを分析し、安全に解決する
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git merge:*), Bash(git rebase:*), Bash(git add:*), Bash(git checkout:*), Bash(git rev-parse:*), Bash(git commit:*), Bash(git push:*), Read, Edit, Grep, Glob
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- マージ/リベースの状態: !`git status`
- コンフリクトのあるファイル: !`git diff --name-only --diff-filter=U 2>/dev/null || echo "コンフリクトなし"`

## タスク

### ステップ1: コンフリクトを解決

`conflict-resolver`エージェントを使用して以下を実行します:

1. コンフリクトを分析し、各ファイルの解決方針を提示する
2. ユーザーの承認後、コンフリクトを解決してステージングする

方針が承認されたら、以降のステップは確認なしで最後まで実行する。

### ステップ2: コミット

1. `git rev-parse -q --verify MERGE_HEAD` でマージ中であることを確認する。マージ中でない（リベース中など）場合は状況を報告して終了する
2. `git diff --name-only --diff-filter=U` が空であることを確認する
3. `git commit --no-edit` で Git のデフォルトのマージメッセージのままコミットする

### ステップ3: push

1. `git push` を実行する。upstream が未設定の場合は `git push -u origin HEAD` を実行する
2. `git log --oneline -1` と `git status` で結果を報告する

## 制約

- コンフリクトのあるファイル以外を変更しないこと
- フォーマット修正やリファクタリングを行わないこと
- コミットメッセージは編集せず `git commit --no-edit` を使うこと（`/commit-fast` は使わない）
- force push はしないこと

---

## 参照

### エージェント
- [`conflict-resolver`](../../agents/conflict-resolver.md) - コンフリクトの分析と解決
