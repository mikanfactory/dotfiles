---
name: rename-branch
description: |
  承認済みプランの要約から英語kebab-caseのブランチ名を生成し、
  ローカルブランチをrenameして新名でoriginにpushするスキル。
  「/rename-branch」で起動。/refine-loop からも自動呼び出しされる。
allowed-tools: Bash(git branch:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git config:*), Bash(git push:*), Bash(git ls-remote:*), Bash(ls:*), Read, Glob
model: Sonnet
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- git config user.name: !`git config user.name 2>/dev/null || echo ""`
- 最新プランファイル: !`ls -1t /Users/shoji/.claude/plans/*.md 2>/dev/null | head -1 || echo "プランファイルなし"`
- ローカルブランチ一覧: !`git branch --format='%(refname:short)' 2>/dev/null`
- リモートブランチ一覧: !`git ls-remote --heads origin 2>/dev/null | awk '{print $2}' | sed 's|refs/heads/||' || echo "リモートなし"`

## タスク

承認済みプランの要約から意味のあるブランチ名を生成し、現在のブランチを rename して origin に新名で push します。

### ステップ0: プランモードの終了（アクティブな場合）

現在プランモードにいる場合は、`ExitPlanMode`ツールを使用して今すぐ終了してください。ブランチrenameの続行についてユーザーの承認を得ています。

### ステップ1: 前提チェック

上記コンテキストを確認:

- 現在のブランチが `main` / `master` / `develop` / `HEAD` のいずれか → 「保護ブランチはrename対象外」と報告して**中断**
- 最新プランファイルが「プランファイルなし」 → 「プランファイルが存在しないため新ブランチ名を生成できません」と報告して**中断**

### ステップ2: プランから新ブランチ名を生成

1. 上記コンテキストの「最新プランファイル」のパスを `Read` で読み込む
2. プランの **Context セクションと見出し** から変更の本質を1行で要約
3. 要約を英語kebab-caseの `<description>` に変換:
   - 25文字以内目安、**40文字を超えない**
   - 動詞 + 対象の形を優先（例: `add-rename-branch-skill`, `fix-greptile-polling`, `refactor-auth-flow`）
   - 小文字英数字とハイフンのみ。記号・日本語は含めない
4. プレフィックスを決定:
   - 上記コンテキストの「git config user.name」が非空ならそれを使用
   - 空なら現在のブランチが `<prefix>/...` 形式であればその `<prefix>` を流用
   - どちらも取れなければ**中断**
5. 完成形: `<prefix>/<description>`（例: `mikanfactory/add-rename-branch-skill`）

### ステップ3: 衝突 & 不要チェック

- 生成した新名 == 上記コンテキストの「現在のブランチ」 → 「rename不要（既に妥当な名前）」と報告して**正常終了**
- 上記コンテキストの「ローカルブランチ一覧」に新名が存在 → 「ローカルブランチ衝突」と報告して**中断**
- 上記コンテキストの「リモートブランチ一覧」に新名が存在 → 「リモートブランチ衝突」と報告して**中断**

### ステップ4: rename実行

1. ローカル rename:
   ```bash
   git branch -m <new-name>
   ```
2. 新名で origin に push（upstream設定込み）:
   ```bash
   git push -u origin <new-name>
   ```
3. **古いリモートブランチは触らない**（PR既作成時の事故防止・他者の参照断ち防止のため）

### ステップ5: 完了報告

日本語で1-2行のサマリを出力:

```
ブランチを <old> → <new> に rename し、origin に push しました。
古いリモートブランチは残しています（必要なら手動で削除してください）。
```

## 制約

- 保護ブランチ（main/master/develop/HEAD）は対象外
- 新名は英語のkebab-case、**40文字以内**
- 古いリモートブランチは**削除しない**
- プランファイルが無ければ中断（推測命名は禁止）
- ユーザーへの出力は日本語

---

## 参照

### スキル
- [`/refine-loop`](../refine-loop/SKILL.md) - 本スキルをステップ0.7で呼び出す側
