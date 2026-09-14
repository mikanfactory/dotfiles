---
name: kb
description: |
  Obsidian vault をベースにしたプロジェクト別ナレッジベースを扱うスキル。
  vault のパスは環境変数 $OBSIDIAN_VAULT_DIR（chezmoi でマシンごとに設定）。
  3操作を提供: research（調査ノートの作成）、dd（Design Doc の執筆）、ref（DD と関連ノートの参照）。
  「/kb research <topic> <調査内容>」「/kb dd <topic>」「/kb ref <topic>」で起動。
  「調査をナレッジベースに残して」「Design Doc / DD を書いて」「DD を参照して」と依頼された場合にもトリガー。
argument-hint: "<research|dd|ref> [project/]topic [内容]"
allowed-tools: Read, Write, Edit, Glob, Grep, WebFetch, Bash(git remote *), Bash(mkdir *), Bash(echo *)
---

# KB - プロジェクト別ナレッジベース

調査ノート → Design Doc → Implementation Plan を、Obsidian vault の `<project>/<topic>/` に蓄積する。
書き方の規約は [vault-conventions.md](./references/vault-conventions.md) に従う。

## 操作ルーティング

`$ARGUMENTS` の先頭語で判定する。

- `research` → Research
- `dd` → Design Doc
- `ref` → Reference
- 引数なし・判定不能 → ユーザーに操作を確認する

## 共通: 保存先の解決

すべての操作の最初に行う。

1. `echo "$OBSIDIAN_VAULT_DIR"` で vault のパスを取得する。空なら**中断**し、`chezmoi init && chezmoi apply` の実行と Claude Code の再起動を案内する
2. project を決める
   - 引数が `project/topic` 形式ならそれを使う
   - topic だけなら `git remote get-url origin` のリポジトリ名（例: `ivry-inc/datahub` → `datahub`）を vault 直下のディレクトリ名と照合する
   - 一致しない・git 外の場合は、vault 直下のディレクトリ一覧（`日記/` を除く）を示して聞く
3. topic は kebab-case のディレクトリ名（例: `slack-webhook`）。research / dd で存在しなければ `mkdir -p` する
4. 以降のパスは `$OBSIDIAN_VAULT_DIR/<project>/<topic>/` を絶対パスに展開して扱う（Write は絶対パスを受け取る）

## Research ワークフロー

`/kb research [project/]topic <調査したいこと>`

1. 依頼を独立した問いに分解し、ユーザーに一覧で示す（例: 「Incoming Webhook の URL を JSON params で変更できるか」「Plan A: Webhook のまま強化」）
2. topic フォルダの既存ノートを Glob / Read で把握する。同じ問いのノートがあれば新規作成せず追記・更新する
3. 問いごとに調べる
   - コードは `path:line` で根拠を示す
   - 外部仕様は公式ドキュメントを WebFetch し、原文を引用して URL を添える
   - 裏付けが取れない情報は「**記憶ベース・未検証**」と明記する。推測を事実として書かない
4. 1 問 1 ノートで書く。テンプレートは [note-templates.md](./references/note-templates.md) の「調査ノート」「案ノート」「比較ノート」から選ぶ
5. 相互リンク: 新しいノートの `## 関連` に関連ノートを並べ、関連する既存ノートの `## 関連` にも新しいノートを追記する
6. `YYYY-MM-DD プロンプト.md` に依頼文と作成・更新したノートの wikilink 一覧を追記する（同日のファイルがあれば追記）
7. 作成・更新したファイルのパスと、各問いの結論を 1 行ずつ報告する

## Design Doc ワークフロー

`/kb dd [project/]topic`

1. topic フォルダの全ノートを読む。`Design Doc*.md` が既にあれば最新版（`Design Doc.md` = v1、`Design Doc vN.md` = vN）を特定する
2. 調査ノートだけでは決まらない判断（採用案、スコープ外、リリース順など）を洗い出し、AskUserQuestion で 1 つずつ確認する
3. [design-doc-template.md](./references/design-doc-template.md) に沿って書く
   - 初版は `Design Doc.md`、既存がある場合は `Design Doc vN.md`（N = 既存の最大版 + 1）
   - 版を上げたら末尾に「vN-1 からの変更点」表を置く
   - 該当しない章は削除せず「なし」と理由を 1 行で書く
4. 不採用案・懸念点・制約は根拠となる調査ノートへ `[[wikilink]]` を張る。根拠ノートがない主張は「設計の未検証事項」に回す
5. 旧版の Design Doc は変更しない
6. 作成したパスと、ユーザーの判断が必要な未検証事項を報告する

## Reference ワークフロー

`/kb ref [project/]topic` または `/kb ref <キーワード>`（**読み取り専用**）

1. topic ディレクトリを特定する。キーワードの場合は vault 全体を Grep し、候補の topic を示して選んでもらう
2. 最新の `Design Doc*.md` と `Implementation Plan.md`（あれば）を読む
3. 本文中の `[[X]]` を同じ project 配下の `**/X.md` として Glob で解決し、1 ホップ分だけ読む
4. 会話に次の要約を出す
   - 採用した設計と主要な決定
   - 守るべき制約・前提
   - 不採用案とその理由（同じ案を再提案しないため）
   - 設計の未検証事項
   - 実装の進捗（Implementation Plan の「現在地」）
5. 以後の実装・回答はこの要約に従う。Design Doc と矛盾する変更が必要になったら、実装前にユーザーへ指摘する
6. ファイルには書き込まない

---

## 参照

### ドキュメント
- [`vault-conventions`](./references/vault-conventions.md) - vault の構造・命名・リンク・記述の規約
- [`note-templates`](./references/note-templates.md) - 調査ノート・案ノート・比較ノート・プロンプトログのテンプレート
- [`design-doc-template`](./references/design-doc-template.md) - Design Doc の章立てテンプレート
