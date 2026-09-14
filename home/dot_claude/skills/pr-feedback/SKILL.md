---
name: pr-feedback
description: |
  作成済みPRのタイトル・本文への手直しやユーザーのコメントから文体のクセを抽出し、
  create-pr の writing-style.md に更新案を提示して、承認分だけ反映するスキル。
  「/pr-feedback [PR番号 or URL] [コメント]」で起動。
  「PRの文体をフィードバックしたい」「このPR本文の書き方を覚えて」と依頼された場合にもトリガー。
allowed-tools: Bash(gh pr:*), Bash(gh api:*), Bash(gh repo:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(chezmoi source-path:*), Bash(ls:*), Read, Edit, Glob, Grep, AskUserQuestion
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "gitリポジトリ外"`
- 現在のPR: !`gh pr view --json number,url,title 2>/dev/null || echo "PRなし"`
- リポジトリ情報: !`gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "不明"`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- chezmoiソースパス: !`chezmoi source-path 2>/dev/null || echo "chezmoiなし"`

## タスク

PR作成後にユーザーが手直しした差分と口頭コメントから文体のクセを抽出し、[`writing-style`](../create-pr/references/writing-style.md) の更新案を提示します。承認された案だけをファイルに反映します。

### ステップ0: プランモードの終了（アクティブな場合）

現在プランモードにいる場合は、`ExitPlanMode`ツールを使用して今すぐ終了してください。フィードバック反映の続行についてユーザーの承認を得ています。

### ステップ1: 対象PRと口頭コメントの特定

引数を以下のように解釈する:

- 先頭が数字（`123` / `#123`）または PR URL なら、それを対象PRとし、残りを口頭コメントとする
  - URL の場合は owner/repo も URL から取る
- 先頭がそれ以外なら、引数全体を口頭コメントとし、対象PRは上記コンテキストの「現在のPR」
- 対象PRが特定できず口頭コメントも無い場合は「対象PRが見つからない」と報告して終了

### ステップ2: 材料の取得

**編集履歴**（本文・タイトル）を1回のクエリで取得する:

```bash
gh api graphql -F owner='{owner}' -F repo='{repo}' -F number={pr} -f query='
query($owner:String!,$repo:String!,$number:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$number){
      title body createdAt
      userContentEdits(first:50){ totalCount nodes{ editedAt editor{login} diff } }
      timelineItems(first:50,itemTypes:[RENAMED_TITLE_EVENT]){
        nodes{ ... on RenamedTitleEvent{ createdAt actor{login} previousTitle currentTitle } }
      }
    }
  }
}'
```

データの読み方（実PRで確認済み）:

- `userContentEdits.nodes` は**新しい順**。`diff` は差分ではなく**その時点の本文全文**
  - 末尾（最古）の `editedAt` はPR作成時刻と一致し、生成された初版
  - 先頭（最新）は現在の `body` と一致する
  - 本文を一度も編集していなければ `totalCount` は 0
- ブラウザで編集した版は改行が `\r\n`、`gh pr create` / `gh pr edit` で書いた版は `\n` になる
  - 古い順に並べ、`\n` の版 → 次に `\n` の版が現れる直前の `\r\n` の版、を1組の「生成物へのユーザーの手直し」として扱う（ブラウザでの小刻みな連続編集は1組にまとめる）
  - 手直しの後に続く `\n` の版は `/revise-loop` 等による再生成なので、それ自体は手直しとして扱わない
  - 改行で判別できない場合は、最古版 → 最新版の差分を使う
- タイトルの手直しは `RenamedTitleEvent` の `previousTitle` → `currentTitle`

手直しも口頭コメントも無い場合は「フィードバックの材料が無い」と報告して終了。

### ステップ3: writing-style.md の特定と読み込み

編集対象は chezmoi の**ソース側**。`~/.claude/skills/...`（ターゲット側）は `chezmoi apply` で上書きされるので編集しない。

1. リポジトリルートに `home/dot_claude/skills/create-pr/references/writing-style.md` があれば、それを使う（dotfiles の worktree で作業中のケース）
2. 無ければ `{chezmoiソースパス}/dot_claude/skills/create-pr/references/writing-style.md`
3. どちらも無ければパスを報告して終了

`Read` で全文を読み、既存ルールを把握する。

### ステップ4: クセの抽出

手直しの差分と口頭コメントから、変化を以下に分類する:

- **削った**: 冗長な説明、網羅的な列挙、宣伝調の表現など
- **足した**: 動機、前後PRへのリンク、スコープ外の明記など
- **言い換えた**: 語尾、語彙、表記（スペース・括弧・大文字小文字）など
- **並べ替えた / 構成を変えた**: セクション、箇条書きのネストなど

そのうえで、各変化を判定する:

- **PR固有の内容修正**（事実誤り、情報の追加・削除、リンクの差し替え）→ 候補にしない
- **文体・構成のクセ** → 候補にする
  - 既存ルールで既にカバーされている → 追加しない。「ルールはあるが守られていなかった」として報告に含める
  - 既存ルールと矛盾する → 置き換え案にする
  - このPRだけの一回性の好みで他のPRに汎化できない → 候補から外す

### ステップ5: 更新案の提示

候補ごとに以下を表示する:

```
### 案1: <ルールの要約>
- 根拠: <差分の該当箇所（before → after）または口頭コメント>
- 反映先: <writing-style.md のセクション名>（追加 / 置き換え）
- 文面:
  <追記・置き換えする Markdown>
```

あわせて「ルールはあるが守られていなかった」項目を列挙する（こちらは pr-creator 側の問題の可能性があるので、必要なら改善案を一言添える）。

候補が0件なら、その旨と守られていなかった項目だけを報告して終了。

候補がある場合は `AskUserQuestion`（`multiSelect: true`）で反映する案を選んでもらう。候補が4件を超える場合は、テキストで一覧を出したうえで番号で選んでもらう。

### ステップ6: 反映

承認された案だけを `Edit` で反映する。

- 既存のセクション構成に合わせて該当セクションへ追記・置き換えする。当てはまるセクションが無ければ「避けるもの」の前に新設する
- ガイド自体の文体に合わせる: 箇条書き・常体・体言止め、例は短く `例: 「...」` の形
- 例文には顧客名・社内URL・Slackリンク・個人名を含めない（ファイル末尾の「注意」に従う）。固有名詞は一般化してから書く

### ステップ7: 完了報告（ここで停止）

編集したファイルのパスと、反映したルールの要約を報告してターンを終了する。コミットはしない。

## 制約

- 編集してよいのは writing-style.md のみ。`pr-creator.md` などの修正が必要そうな場合は提案に留める
- PRのタイトル・本文そのものは更新しない
- ユーザーの承認前にファイルを編集しない

---

## 参照

### ドキュメント
- [`writing-style`](../create-pr/references/writing-style.md) - 更新対象のPRタイトル・本文の文体ガイド
