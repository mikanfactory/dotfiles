---
name: commit-fast
description: 高速にgitコミットを作成する (確認なし・サブエージェントなし・分割あり)
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
model: Sonnet
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 変更サマリー (--stat): !`git diff HEAD --stat`
- 現在のブランチ: !`git branch --show-current`
- 最近のコミット: !`git log --oneline -10`

## タスク

`/commit` skillの軽量・高速版。サブエージェントを使わず、ユーザー確認も挟まずに分割コミットまで一気に実行する。

### ステップ0: プランモードの終了（アクティブな場合）

プランモードにいる場合は、ExitPlanModeツールで即座に終了する。

### ステップ1: 変更の分類

上記コンテキストの`git status`と`--stat`サマリーを見て、変更を論理グループ (feat/fix/refactor/docs/test/chore) に分類する。

- ファイル名・パス・変更行数のサマリーで判断が付くものは、追加でdiffを読まずに分類する
- 内容を見ないと分類できないファイルに限り `git diff HEAD -- <file>` を実行して中身を確認する
- 1ファイル内に複数目的の変更が混在している場合は、無理に分けず1コミットにまとめて良い (高速優先)

### ステップ2: 分割コミットの実行

**ユーザー確認は挟まない。** 各論理グループに対し以下を順次実行する:

```
git add <files...>
git commit -m "<type>: <summary>"
```

- メッセージは英語・命令形・50文字以内推奨・`type: Short description` 形式
- 共著フッター (Co-Authored-By 等) は**付けない**
- 依存関係のあるコミットは正しい順序で

### ステップ3: 結果の表示

最後に `git log --oneline -5` を実行し、作成されたコミットを表示して終了する。

`/clear` は呼ばない (高速優先・必要なら手動で)。

## 制約

- 共著フッターを追加しないこと
- すべてのコミットメッセージは英語で書くこと
- 各コミットはアトミックで独立してリバート可能であること
- 秘密情報 (APIキー・トークン・パスワード) を含むファイルを検出した場合は中断してユーザーに報告する
- プッシュは行わない (ローカルコミットのみ)

---

## 参照

### スキル
- [`/commit`](../commit/SKILL.md) - 確認付き・サブエージェント経由の通常版 (こちらは慎重だが遅い)

### エージェント
- [`git-commit-splitter`](../../agents/git-commit-splitter.md) - 分類ロジックの参考元 (本skillでは呼ばない)
