# ページテンプレート集

## 標準トピックページ

```markdown
---
title: トピック名
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - sources/web/YYYY-MM-DD_slug.md
tags: [tag1, tag2]
---

# トピック名

## 概要

[1-2段落のサマリー]

## 主要ポイント

- ポイント1
- ポイント2
- ポイント3

## 詳細

[詳細な説明。必要に応じてサブセクションを追加]

## 関連ページ

- [関連トピック](../category/related-topic.md)
```

## Query結果ページ

```markdown
---
title: "Q: 質問内容"
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - query
tags: [query, related-tag]
---

# Q: 質問内容

## 回答

[wikiの内容に基づいて合成した回答]

## 参照したページ

- [ページタイトル](../category/page.md) - このページから得た情報の要約
```

## index.md

```markdown
# ナレッジベース インデックス

> 最終更新: YYYY-MM-DD | 総ページ数: N

## カテゴリ名

- [トピック名](./topics/category/slug.md) - 簡潔な説明

## Queries

- [Q: 質問内容](./topics/queries/slug.md) - 回答の要約
```

## _recent.md

```markdown
# 最近の更新

| 日付 | ページ | 操作 |
|------|--------|------|
| YYYY-MM-DD | [タイトル](./topics/category/slug.md) | 新規作成 |
| YYYY-MM-DD | [タイトル](./topics/category/slug.md) | 更新 |
```

最大20件を保持。古いエントリは下から削除する。

## ソースファイル（Web）

```markdown
---
url: https://example.com/article
fetched: YYYY-MM-DD
title: 記事タイトル
---

[WebFetchで取得したMarkdown内容]
```

## ソースファイル（ローカル）

```markdown
---
original_path: /path/to/original/file.md
copied: YYYY-MM-DD
---

[元ファイルの内容]
```
