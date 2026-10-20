---
name: kb
description: |
  Obsidian vault をベースにしたプロジェクト別ナレッジベースを扱うスキル。
  vault のパスは環境変数 $OBSIDIAN_VAULT_DIR（chezmoi でマシンごとに設定）。
  3操作を提供: research（調査ノートの作成）、adr（1決定1ファイルの ADR の作成）、ref（ADR・DD と関連ノートの参照）。
  「/kb research <topic> <調査内容>」「/kb adr <topic> [決定内容]」「/kb ref <topic>」で起動。
  「調査をナレッジベースに残して」「この決定を ADR に残して」「DD / ADR を参照して」と依頼された場合にもトリガー。
  Design Doc の執筆は /doc-writing が担当する。
argument-hint: "<research|adr|ref> [project/]topic [内容]"
allowed-tools: Read, Write, Edit, Glob, Grep, WebFetch, Bash(git remote *), Bash(mkdir *), Bash(echo *)
---

# KB - プロジェクト別ナレッジベース

調査ノート → ADR → Implementation Plan を、Obsidian vault の `<project>/<topic>/` に蓄積する。
人に読ませる Design Doc は [`/doc-writing`](../doc-writing/SKILL.md) で同じ topic フォルダに書く。
書き方の規約は [vault-conventions.md](./references/vault-conventions.md) に従う。

## 操作ルーティング

`$ARGUMENTS` の先頭語で判定する。

- `research` → Research
- `adr` → ADR
- `dd` → 廃止。Design Doc の執筆は `/doc-writing` に案内する
- `ref` → Reference
- 引数なし・判定不能 → ユーザーに操作を確認する

## 共通: 保存先の解決

すべての操作の最初に行う。

1. `echo "$OBSIDIAN_VAULT_DIR"` で vault のパスを取得する。空なら**中断**し、`chezmoi init && chezmoi apply` の実行と Claude Code の再起動を案内する
2. project を決める
   - 引数が `project/topic` 形式ならそれを使う
   - topic だけなら `git remote get-url origin` のリポジトリ名（例: `ivry-inc/datahub` → `datahub`）を vault 直下のディレクトリ名と照合する
   - 一致しない・git 外の場合は、vault 直下のディレクトリ一覧（`日記/` を除く）を示して聞く
3. topic は kebab-case のディレクトリ名（例: `slack-webhook`）。research / adr で存在しなければ `mkdir -p` する
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

## ADR ワークフロー

`/kb adr [project/]topic [決定内容]`

1. topic フォルダの調査ノートと既存の `ADR-*.md` を読む。同じ決定の ADR が `Accepted` で既にあれば、新規作成せずユーザーに覆すのかを確認する
2. 決定内容・採らなかった案・理由のうち、依頼文と調査ノートから読めないものを AskUserQuestion で確認する
3. 番号は topic 内の既存 `ADR-NNNN-*.md` の最大 + 1（無ければ `0001`）。[adr-template.md](./references/adr-template.md) に沿って `ADR-NNNN-<決定のタイトル>.md` を書く。段階ごとの承認は取らない
4. 状況・不採用案の根拠は調査ノートへ `[[wikilink]]` を張る。根拠ノートがない前提は「未検証事項」に回す
5. 決定を覆す場合は、旧 ADR のステータス行だけを `Superseded by [[新 ADR]]` に変える。旧 ADR の本文は変更しない
6. 関連する調査ノートの `## 関連` にも新しい ADR を追記する
7. 作成したパスと、決定を 1 行で報告する

## Reference ワークフロー

`/kb ref [project/]topic` または `/kb ref <キーワード>`（**読み取り専用**）

1. topic ディレクトリを特定する。キーワードの場合は vault 全体を Grep し、候補の topic を示して選んでもらう
2. 全 `ADR-*.md`、最新の `Design Doc*.md`、`Implementation Plan.md`（それぞれあれば）を読む
3. 本文中の `[[X]]` を同じ project 配下の `**/X.md` として Glob で解決し、1 ホップ分だけ読む
4. 会話に次の要約を出す
   - 有効な ADR（`Superseded` を除く）の決定を 1 行ずつ
   - 採用した設計と主要な決定
   - 守るべき制約・前提
   - 不採用案とその理由（同じ案を再提案しないため）
   - 設計の未検証事項
   - 実装の進捗（Implementation Plan の「現在地」）
5. 以後の実装・回答はこの要約に従う。ADR・Design Doc と矛盾する変更が必要になったら、実装前にユーザーへ指摘する
6. ファイルには書き込まない

---

## 参照

### スキル
- [`/doc-writing`](../doc-writing/SKILL.md) - Design Doc など人に読ませる文書の執筆（kb dd の移管先）

### ドキュメント
- [`vault-conventions`](./references/vault-conventions.md) - vault の構造・命名・リンク・記述の規約
- [`note-templates`](./references/note-templates.md) - 調査ノート・案ノート・比較ノート・プロンプトログのテンプレート
- [`adr-template`](./references/adr-template.md) - ADR のテンプレート
