# Vault 規約

## ディレクトリ構造

```
$OBSIDIAN_VAULT_DIR/
├── YYYY-MM-DD.md                 # デイリーノート（kb の対象外）
├── 日記/                         # kb の対象外
└── <project>/                    # リポジトリ名と同じ名前（例: datahub）
    ├── YYYY-MM-DD-<単発メモ>.md   # topic に属さない単発ノート（任意）
    └── <topic>/                  # kebab-case（例: slack-webhook）
        ├── YYYY-MM-DD プロンプト.md
        ├── <問いのタイトル>.md       # 調査ノート（1 問 1 ファイル）
        ├── Plan A - <案の名前>.md    # 案ノート
        ├── Plan B と Plan C の比較.md # 比較ノート
        ├── Design Doc.md            # v1
        ├── Design Doc v2.md         # 以降の版
        └── Implementation Plan.md   # superpowers:writing-plans の出力
```

## 命名

- project / topic ディレクトリ: kebab-case の英数字
- ノートのファイル名: 日本語のタイトルそのまま（スペース可）。`/` など OS で使えない文字は避ける
- 固定名: `Design Doc.md`、`Design Doc vN.md`、`Implementation Plan.md`、`YYYY-MM-DD プロンプト.md`

## リンク

- Obsidian の wikilink `[[ノート名]]` を使う（拡張子なし）。相対パスの Markdown リンクは使わない
- 見出しへのリンクは `[[ノート名#見出し]]`
- ノート名は同一 project 内で一意にする。解決は `<project>/**/<ノート名>.md` を Glob する
- すべてのノートの末尾に `## 関連` を置き、関連ノートを箇条書きで並べる。リンクは双方向に張る

## 記述

- 日本語で書く
- frontmatter は必須にしない
- 結論を先に書き、根拠を後に置く
- 根拠の種類を区別する
  - コード: `path:line` とコード片
  - 公式ドキュメント: 原文の引用 + URL
  - 実機検証: 手順と結果
  - 裏付けなし: 「記憶ベース・未検証」と明記する
- 比較は表を使う
- シーケンスや構成は mermaid で描く

## その他

- vault は git 管理外。コミットや PR の対象にしない
- 既存ノートの内容を消すときは、理由を残すか新しい版を作る
