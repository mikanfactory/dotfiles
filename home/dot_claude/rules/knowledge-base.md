# ナレッジベース（Obsidian vault）

環境変数 `OBSIDIAN_VAULT_DIR` が設定されている場合に適用する。未設定なら無視し、各スキルの既定に従う。

## superpowers の出力先

- superpowers:brainstorming の spec は `docs/superpowers/specs/` ではなく、`/kb adr` の手順とテンプレートで `$OBSIDIAN_VAULT_DIR/<project>/<topic>/ADR-NNNN-<決定のタイトル>.md` に保存する
- superpowers:writing-plans の plan は `docs/superpowers/plans/` ではなく同じフォルダの `Implementation Plan.md` に保存し、冒頭に `Spec: [[ADR-NNNN-<決定のタイトル>]]` を書く
- vault は git 管理外なので、spec / plan のコミット手順は省略する
- project / topic の決め方と記述規約は `/kb` スキルに従う

## 文書の書き分け

- 1 つの決定の記録は `/kb adr`、人に読ませる文書（Design Doc を含む）は `/doc-writing` で書く

## 参照

- ユーザーが Design Doc・ADR・調査ノート・vault 内のトピックに言及したら、`/kb ref` で読み込んでから作業する

---

## 参照

### スキル
- [`/kb`](../skills/kb/SKILL.md) - vault への調査ノート作成・ADR 作成・参照
- [`/doc-writing`](../skills/doc-writing/SKILL.md) - Design Doc など人に読ませる文書の段階的な執筆
