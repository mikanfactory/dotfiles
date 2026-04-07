---
name: kb
description: |
  Karpathy式LLMナレッジベース管理スキル。~/code/knowledge_base に構造化Markdown wikiを構築・維持する。
  3操作を提供: ingest（URL/ファイルからの知識取り込み）、query（wikiへの質問応答）、lint（整合性チェック）。
  「/kb ingest <URL or path>」「/kb query <質問>」「/kb lint」で起動。
  ナレッジベースへの追加・検索・メンテナンスを依頼された場合にもトリガー。
allowed-tools: WebFetch, Read, Write, Edit, Glob, Grep
---

# KB - ナレッジベース管理

LLMが生のドキュメントを読み込み、構造化されたMarkdown wikiに「コンパイル」するナレッジベースを管理する。

**ベースディレクトリ**: `~/code/knowledge_base`

## 初期化

操作実行前に、ナレッジベースのディレクトリ構造を確認する。

1. `~/code/knowledge_base` が存在しない場合、以下を作成:
   - `sources/web/`、`sources/local/` ディレクトリ
   - `wiki/topics/`、`wiki/topics/queries/` ディレクトリ
   - `CLAUDE.md` — [wiki-schema.md](./references/wiki-schema.md) のテンプレート部分（コードブロック内）をコピー
   - `wiki/index.md` — 空のインデックス（[page-templates.md](./references/page-templates.md) の index.md テンプレート参照）
   - `wiki/_recent.md` — 空の更新履歴テーブル

2. 既に存在する場合は `CLAUDE.md` を読み込み、現在のスキーマを把握する

## 操作ルーティング

ユーザー入力から操作を判定する:

- `ingest <URL>` or `ingest <ファイルパス>` → Ingest
- `query <質問>` → Query
- `lint` → Lint
- 引数なし → ユーザーに操作を確認

## Ingest ワークフロー

### Step 1: ソース種別の判定

- `http://` or `https://` で始まる → Web ソース
- それ以外 → ローカルファイル

### Step 2: コンテンツの取得と保存

**Webソースの場合:**

1. `WebFetch` でURLの内容を取得する。プロンプト:
   > この記事の内容を詳細にMarkdown形式で抽出してください。タイトル、著者、公開日などのメタデータも含めてください。要約ではなく、できるだけ詳細に全文を抽出してください。
2. 取得した内容を `sources/web/YYYY-MM-DD_slug.md` に保存
   - slugはURLまたはタイトルから生成（kebab-case、英数字のみ）
   - frontmatterに `url` と `fetched` を記録

**ローカルファイルの場合:**

1. `Read` でファイル内容を読み取る
2. `sources/local/YYYY-MM-DD_original-filename.md` にコピー
   - frontmatterに `original_path` と `copied` を記録

### Step 3: 重複チェック

`sources/` 内を `Grep` で検索し、同じURL or ファイルパスが既に取り込み済みでないか確認する。重複の場合はユーザーに通知し、上書き or スキップを確認する。

### Step 4: Wikiへのコンパイル

1. `wiki/index.md` を読み、既存のカテゴリとトピックを把握
2. ソース内容を分析し、以下を判定:
   - **既存トピックに統合すべきか**: 既存ページを `Read` → `Edit` で新情報を追記、`updated` を更新
   - **新規ページを作成すべきか**: [page-templates.md](./references/page-templates.md) の標準トピックページテンプレートに従って作成
3. カテゴリの選択:
   - 既存カテゴリに該当するものがあれば優先使用
   - 該当なしの場合のみ新規カテゴリを作成

### Step 5: インデックス更新

1. `wiki/index.md` に新規/更新ページのエントリを追加・更新
2. `wiki/_recent.md` の先頭に追加（最大20件、超過分は末尾から削除）

### Step 6: ユーザーへの報告

以下を報告する:
- 保存したソースファイルのパス
- 作成/更新したwikiページのパス
- 割り当てたカテゴリとタグ

## Query ワークフロー

### Step 1: 関連ページの特定

1. `wiki/index.md` を読み、全体構造を把握
2. 質問のキーワードで `wiki/topics/` 内を `Grep` 検索
3. 関連性の高いページを `Read` で読み込む（最大5ページ）

### Step 2: 回答の合成

読み込んだwikiページの内容に基づいて回答を合成する。wikiに情報がない場合はその旨を明記する。

### Step 3: 回答のファイリング

1. 回答を `wiki/topics/queries/YYYY-MM-DD_question-slug.md` として保存
   - [page-templates.md](./references/page-templates.md) のQuery結果ページテンプレートに従う
   - `sources` は `["query"]` とする
   - 参照したページへのリンクを含める
2. `wiki/index.md` の Queries セクションに追加
3. `wiki/_recent.md` を更新

### Step 4: ユーザーへの回答

合成した回答をユーザーに直接提示する。ファイリングしたページのパスも添える。

## Lint ワークフロー

以下のチェックを実行し、結果をレポートとして提示する。**自動修正は行わない。**

### チェック項目

1. **孤立ページ**: `wiki/topics/` 内のページで `index.md` からリンクされていないもの
   - `Glob` で全ページを列挙 → `Grep` で index.md 内のリンクと照合

2. **壊れたリンク**: wiki内の `[text](path)` リンクで、リンク先ファイルが存在しないもの
   - `Grep` でリンクを抽出 → `Glob` で存在確認

3. **Frontmatter不足**: 必須フィールド（title, created, sources, tags）が欠けているページ
   - `Grep` で frontmatter をチェック

4. **空カテゴリ**: `index.md` 内のH2セクションで、配下にリンクがないもの

5. **重複トピック**: タイトルが類似しているページ（同一カテゴリ内で類似slugを検出）

6. **_recent.md の件数**: 20件を超えている場合に警告

### レポート形式

```
## Lintレポート

### 問題あり
- [重大] 孤立ページ: wiki/topics/ml/orphan-page.md
- [警告] Frontmatter不足: wiki/topics/web/page.md (tags missing)

### 統計
- 総ページ数: N
- カテゴリ数: N
- 問題数: N
```

## 規約

- wikiの内容は**日本語**で記述する
- ソースファイルは取り込み後に**変更しない**（不変）
- 内部リンクは**相対パス**を使用する
- frontmatterは**必ず**含める
- タグは**小文字kebab-case**

---

## 参照

### ドキュメント
- [`wiki-schema`](./references/wiki-schema.md) - ナレッジベースのCLAUDE.mdテンプレート
- [`page-templates`](./references/page-templates.md) - wikiページのテンプレート集
