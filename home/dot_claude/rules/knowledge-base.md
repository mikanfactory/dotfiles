# ナレッジベース（Obsidian vault）

環境変数 `OBSIDIAN_VAULT_DIR` が設定されている場合に適用する。未設定なら無視し、各スキルの既定に従う。

## superpowers の出力先

- superpowers:brainstorming の spec は `docs/superpowers/specs/` ではなく `$OBSIDIAN_VAULT_DIR/<project>/<topic>/Design Doc.md` に保存する。既にあれば `Design Doc vN.md` として版を上げる
- superpowers:writing-plans の plan は `docs/superpowers/plans/` ではなく同じフォルダの `Implementation Plan.md` に保存し、冒頭に `Spec: [[Design Doc vN]]` を書く
- vault は git 管理外なので、spec / plan のコミット手順は省略する
- project / topic の決め方と記述規約は `/kb` スキルに従う

## 参照

- ユーザーが Design Doc・調査ノート・vault 内のトピックに言及したら、`/kb ref` で読み込んでから作業する

---

## 参照

### スキル
- [`/kb`](../skills/kb/SKILL.md) - vault への調査ノート作成・Design Doc 執筆・参照
