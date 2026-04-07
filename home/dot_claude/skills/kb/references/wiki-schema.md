# ナレッジベース CLAUDE.md テンプレート

初期化時にこの内容を `~/code/knowledge_base/CLAUDE.md` として生成する。

---

```markdown
# Knowledge Base

Karpathy式LLMナレッジベース。生のドキュメントをLLMが読み込み、構造化されたMarkdown wikiに「コンパイル」する。

## アーキテクチャ

3層構造で知識を管理する:

1. **Raw Sources** (`sources/`) - 取り込んだ不変のドキュメント
2. **Schema** (この `CLAUDE.md`) - wiki構造と規約の定義
3. **Compiled Wiki** (`wiki/`) - LLMが生成・更新するMarkdownファイル群

## ディレクトリ構造

```
knowledge_base/
├── CLAUDE.md
├── sources/
│   ├── web/                     # WebFetchで取得した記事
│   │   └── YYYY-MM-DD_slug.md
│   └── local/                   # ローカルファイルのコピー
│       └── YYYY-MM-DD_filename.md
└── wiki/
    ├── index.md                 # カテゴリ別トピック一覧
    ├── _recent.md               # 最近の更新（最大20件）
    └── topics/
        ├── {category}/          # カテゴリ別ディレクトリ
        │   └── {topic-slug}.md
        └── queries/             # query結果の蓄積
            └── {question-slug}.md
```

## Frontmatter スキーマ

すべてのwikiページに必須:

```yaml
---
title: ページタイトル
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - sources/web/YYYY-MM-DD_slug.md
tags: [tag1, tag2]
---
```

- `title`: ページの表示名
- `created`: 作成日（ISO 8601）
- `updated`: 最終更新日（ISO 8601）
- `sources`: 元となったソースファイルの相対パス一覧。queryの場合は `["query"]`
- `tags`: 小文字kebab-case のタグリスト

## ページ本文構造

```markdown
# タイトル

## 概要
1-2段落のサマリー

## 主要ポイント
- 箇条書きで要点を整理

## 詳細
詳細な説明。必要に応じてサブセクションを追加

## 関連ページ
- [関連トピック](../category/related-topic.md)
```

## 命名規則

- カテゴリディレクトリ: kebab-case（例: `machine-learning`, `web-development`）
- ページファイル: kebab-case `.md`（例: `transformer-architecture.md`）
- ソースファイル: `YYYY-MM-DD_slug.md`（例: `2026-04-06_karpathy-knowledge-base.md`）

## 規約

- wikiの内容は日本語で記述する
- ソースファイル（`sources/`配下）は取り込み後に変更しない（不変）
- 内部リンクは相対パスを使用する
- 既存トピックに関連する新しい情報は、新規ページではなく既存ページに統合する
- カテゴリは既存のものを優先的に使用し、新規カテゴリは必要な場合のみ作成する
```
