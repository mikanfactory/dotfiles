---
name: revise-loop
description: |
  PR作成済みブランチへの仕様変更プランを「TDD実装 → /simplify整理 → コミット
  → PR本文更新 → push → Greptile新規指摘の自動修正」で1パス実行するスキル。
  ブランチ名は変更せず、既存PRを編集で更新する。
  「/revise-loop」で起動。/refine-loop でPR作成済みのあとに仕様変更が出た場合にトリガー。
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, Skill
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main"`
- デフォルトブランチとこのブランチの差分: !`git diff origin/main...HEAD --stat 2>/dev/null || echo "差分なし"`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- リポジトリ情報（owner/repo）: !`gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "不明"`
- gh認証状態: !`gh auth status 2>&1 | head -3 || echo "未認証"`
- リモート: !`git remote -v | head -2 || echo "リモートなし"`
- 既存PR: !`gh pr view --json number,url,title,isDraft 2>/dev/null || echo "PRなし"`
- 既存PR本文: !`gh pr view --json body --jq '.body' 2>/dev/null || echo "本文なし"`
- 最新プランファイル: !`ls -1t /Users/shoji/.claude/plans/*.md 2>/dev/null | head -1 || echo "プランファイルなし"`
- PRテンプレート: !`cat $(git rev-parse --show-toplevel)/.github/pull_request_template.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE/default.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/docs/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "テンプレートなし"`

## タスク

**PR作成済み**のブランチに対して、承認済みの**仕様変更プラン**の実装から push までを **1パス** で自動実行します。`/refine-loop` の後段スキルであり、ブランチ名は維持し、PRは新規作成せず**本文を編集して更新**します。コミット作成はサブスキル呼び出しせず、その手順を**インライン化**します。

### ステップ0: プランモードの終了

現在プランモードにいる場合は、`ExitPlanMode`ツールを使用して今すぐ終了してください。実装〜push続行についてユーザーの承認を得ています。

### ステップ0.5: 前提チェック

上記コンテキストを確認:

- `gh認証状態` が未認証、または `リポジトリ情報` が「不明」、または `origin` リモートが無い場合 → 理由を報告して**中断**
- `既存PR` が「PRなし」の場合 → 「PRが未作成のため `/refine-loop` を使用してください」と報告して**中断**（本スキルは既存PRの更新を前提とするため）
- 現在のブランチが `main` / `master` / `develop` のいずれか → 「保護ブランチでは実行できません」と報告して**中断**

`既存PR` から **PR番号・URL・Draft状態** を捕捉して以降のステップで使用する。

### ステップ0.7: ブランチ rename は行わない

`/refine-loop` のステップ0.7に相当する `rename-branch` の呼び出しは**実行しません**。ブランチ名を変更すると既存PRとの紐付けが壊れるためです。現在のブランチ名のまま続行してください。

### ステップ1: TDDでコード生成

**今回承認された仕様変更プラン**を `/tdd-workflow` の原則で実装します:

1. **RED** — まず失敗するテストを書く（各テストは1つの振る舞い・説明的なテスト名・外部依存はモック・エッジケースとエラーパスを含む）
2. **GREEN** — テストを通過する最小限のコードを書く
3. **REFACTOR** — テストをグリーンに保ったままコードを改善
4. **カバレッジ確認** — プロジェクトのテストコマンドで実行。Pythonなら:
   ```bash
   uv run pytest --cov=src --cov-report=term-missing
   ```
   **80%未満なら**テストを追加し、閾値に到達するまで RED→GREEN を繰り返す。

仕様変更で不要になった既存コード・テストは削除する（旧仕様のテストを残したまま新仕様を足さない）。

### ステップ2: /simplify でリファクタリング

`Skill`ツールで `simplify` を呼び出し、変更コードの再利用性・品質・効率を見直して自動修正させます。

完了後、ステップ1のテストを再実行してグリーンを確認。`/simplify` の変更でテストが壊れた場合は最小限の修正で回復させる。

### ステップ3: コミット（インライン）

`/commit-fast` の手順をインラインで実行し、すべての変更（フォーマッタ変更含む）を分割コミットする:

- `git status` と `git diff HEAD --stat` を見て、変更を論理グループ（feat/fix/refactor/docs/test/chore）に分類する。ファイル名・パス・変更行数で判断が付くものはdiffを読まずに分類し、内容を見ないと分類できないファイルに限り `git diff HEAD -- <file>` で確認する
- **ユーザー確認は挟まず**、各論理グループを `git add <files...>` → `git commit -m "<type>: <summary>"` で順次コミットする（メッセージは英語・命令形・50文字以内推奨、依存関係のあるコミットは正しい順序で）

`pr-creator`エージェントは**呼びません**（PRは既に存在するため）。

### ステップ4: Greptile基準点の記録 → push → PR本文の更新

1. **push前に既存Greptileコメントの基準点を記録**する。ローカル時刻とGitHub側時刻のズレを避けるため、時刻ではなく**コメントIDの集合**をベースラインにする（IDは単調増加するため、未知のID＝新規と判定できる）。`{owner}/{repo}` と `{pr}` は実値に置換:

   ```bash
   gh api "repos/{owner}/{repo}/pulls/{pr}/comments" --paginate \
     --jq '.[] | select(.user.login | test("greptile")) | .id' \
     > /tmp/greptile-seen-ids.txt
   gh api "repos/{owner}/{repo}/pulls/{pr}/reviews" --paginate \
     --jq '.[] | select(.user.login | test("greptile")) | .id' \
     > /tmp/greptile-seen-review-ids.txt
   wc -l < /tmp/greptile-seen-ids.txt
   wc -l < /tmp/greptile-seen-review-ids.txt
   ```

   出力された**ID一覧と件数を会話中に保持**する（以降のステップで新規判定に使う）。

2. push する:
   ```bash
   git push
   ```

3. **人間による本文の書き換えを検出**する。PR作成後にユーザーが手でPR本文を編集している場合、機械的な上書きでその記述を消してはいけない。

   ```bash
   gh api graphql -F owner='{owner}' -F repo='{repo}' -F pr={pr} -f query='
     query($owner:String!, $repo:String!, $pr:Int!) {
       repository(owner:$owner, name:$repo) {
         pullRequest(number:$pr) {
           userContentEdits(last: 20) { nodes { editedAt editor { login } } }
         }
       }
     }' --jq '.data.repository.pullRequest.userContentEdits.nodes'
   ```

   併せて、上記コンテキストの「既存PR本文」を「PRテンプレート」および本スキル／`pr-creator` が生成する形式と突き合わせ、**テンプレートに無い見出し・手書きの補足・レビュー向けメモ・議論の経緯**など、人間が加筆したと判断できる記述があるかを確認する。編集履歴が空でも本文が生成物と乖離していれば人間編集ありとみなす。

4. **PR本文を編集して更新**する。上記コンテキストの「既存PR本文」「PRテンプレート」「最新プランファイル」と `git diff origin/main...HEAD --stat` を材料に、**仕様変更後の最終状態**を表す本文を日本語で再生成する:

   - PRテンプレートの**見出しと順序はそのまま維持**（英語の見出しは翻訳しない。チェックボックスは該当項目のみ `- [x]`）
   - 「〜を追加しました、その後〜に変更しました」のような**経緯の羅列にせず、現在の仕様として書き直す**
   - 変更後の内容とPRタイトルが乖離している場合のみ `--title` も併せて更新する

   **ステップ4-3で人間による書き換えを検出した場合**は、上書き再生成をせず以下のいずれかを選ぶ:

   - **(a) 人間の記述に沿って最小限だけ編集する** — 人間が加筆した見出し・文章・文体・構成は**そのまま残し**、今回の仕様変更で事実と食い違う箇所（古い仕様の説明、変更されたファイル一覧、チェックボックスの状態など）**だけ**を書き換える。人間が書いたセクションを削除・要約・言い換えしない。
   - **(b) 編集せず、タスク完了後に提案する** — 人間の記述と新仕様が正面から矛盾する、意図的にスキルの生成物と違う書き方をしていると読める、どこまで書き換えてよいか判断が付かない、のいずれかに当てはまる場合は **`gh pr edit` を実行しない**。ステップ7の最終サマリに「PR本文の更新案」を差分付きで提示し、適用するかどうかの判断をユーザーに委ねる。

   **迷ったら (b) を選ぶ**（人間が書いた文章を失う方が、本文が一時的に古いまま残るより損害が大きいため）。

   ```bash
   gh pr edit {pr} --body "$(cat <<'EOF'
   <再生成した本文>
   EOF
   )"
   ```

5. **Draft状態は変更しない**（`--ready` は付けない）。

### ステップ5: Greptileレビュー待ち（新規コメントのみ）

ステップ4のPR番号に対し、Greptileのレビューコメントが**ベースラインを超える**まで **60秒間隔・最大15分（最大15回）** ポーリングします。`BASE_N` / `BASE_M` はステップ4-1で記録した件数を実値で埋める:

```bash
BASE_N=<ステップ4-1のインラインコメント件数>
BASE_M=<ステップ4-1のレビュー件数>
for i in $(seq 1 15); do
  n=$(gh api "repos/{owner}/{repo}/pulls/{pr}/comments" --paginate \
        --jq '[.[] | select(.user.login | test("greptile"))] | length' 2>/dev/null || echo 0)
  m=$(gh api "repos/{owner}/{repo}/pulls/{pr}/reviews" --paginate \
        --jq '[.[] | select(.user.login | test("greptile"))] | length' 2>/dev/null || echo 0)
  echo "poll $i: inline=$n/$BASE_N reviews=$m/$BASE_M"
  [ "$n" -gt "$BASE_N" ] || [ "$m" -gt "$BASE_M" ] && { echo "GREPTILE_READY"; break; }
  sleep 60
done
```

- `GREPTILE_READY` が出たら次へ。
- foreground `sleep` がハーネスにブロックされる場合は、`Monitor`ツールでGreptileコメント数 `> BASE_N` を until条件にしてフォールバックする。
- **15分経過しても増分0**の場合 → 「Greptileの新規レビューが時間内に付かなかった」と警告し、**ステップ6・7をスキップして正常終了**（PRはpush済み・本文更新済みで残る。最終サマリでPR URLを報告）。

レビューが取得できたら、`/review-greptile` と同じ3ソースでコメント本体を取得:

```bash
# 5a: インラインレビューコメント
gh api "repos/{owner}/{repo}/pulls/{pr}/comments" --paginate \
  --jq '[.[] | select(.user.login | test("greptile")) | {id, path, line: (.line // .original_line), side, body, diff_hunk, created_at}]'
# 5b: トップレベルレビュー
gh api "repos/{owner}/{repo}/pulls/{pr}/reviews" --paginate \
  --jq '[.[] | select(.user.login | test("greptile")) | {id, body, state}]'
# 5c: レビューに紐づくコメント（review_idが取れた場合）
gh api "repos/{owner}/{repo}/pulls/{pr}/reviews/{review_id}/comments" --paginate \
  --jq '[.[] | {id, path, line: (.line // .original_line), body, diff_hunk}]'
```

取得した全件のうち、**ステップ4-1で記録したIDに含まれないものだけ**を新規として扱う（IDのフィルタはシェルで組まず、記録済みIDリストと突き合わせて判断する）。前回ラウンドで判定済みの指摘は**再評価しない**。

### ステップ6: 新規推奨指摘の自動修正

`/review-greptile` の分析ロジックを流用しますが、**ユーザー選択は待たず**「対応推奨」のみ自動適用します。対象はステップ5で絞り込んだ**新規コメントのみ**。

1. 各新規インラインコメントについて、該当ファイルを `Read`（コメント行の前後20行程度）し、以下を判定:
   - **妥当性**: 指摘は正しいか
   - **重要度**: `バグ` / `セキュリティ` / `パフォーマンス` / `スタイル` / `その他`
   - **対応推奨**: `対応` または `スキップ`
   - **理由**: 判定の根拠（1-2文）／対応推奨なら**修正案**（1文）
2. 分析レポートを **表示のみ**（選択は待たない）:
   ```markdown
   # Greptileレビュー分析レポート（新規分のみ）
   **PR:** #123 - タイトル
   **新規コメント数:** X件 | **推奨対応:** Y件 | **推奨スキップ:** Z件
   （前回ラウンドまでの N件 は判定済みのため対象外）

   ## コメント一覧
   ### [1] 対応推奨 | バグ | `src/api/users.py:42`
   **指摘:** ...
   **分析:** ...
   **修正案:** ...
   ### [2] スキップ推奨 | スタイル | `src/utils/helper.py:15`
   **指摘:** ...
   **分析:** ...
   ```
   トップレベルレビュー（ファイル参照なし）は「総括コメント」として別セクションに記載。
3. **「対応推奨」と判定したコメントのみ** `Edit` で自動修正する。修正はコメントが指摘する範囲のみ（スコープ外のリファクタリングは禁止）。
4. **新規0件 or 全件「スキップ推奨」**の場合 → 修正・追加コミット・pushをスキップし、「対応不要」と報告して終了（最終サマリでPR URLを報告）。
5. 修正後、ステップ1のテストを再実行し、カバレッジ80%以上を再確認。修正でテストが壊れたら最小限の修正で回復させる。**回復不能な場合は push せず**、状況を報告して中断。

### ステップ7: 追加コミット & push

1. ステップ6の修正を、ステップ3と同じ `/commit-fast` のインライン手順で論理的でアトミックなコミットに分割して作成する。
2. push する:
   ```bash
   git push
   ```
3. 最終サマリを日本語で表示:
   ```markdown
   ## revise-loop 完了
   - PR: #123 <URL> (Draft / 本文更新済み)
   - Greptile: 新規指摘 N件中 対応 Y件 / スキップ Z件
   - テスト: グリーン / カバレッジ XX%
   ```

   ステップ4-4で **(b) 編集せず提案** を選んだ場合は、PR行を `(Draft / 本文は未更新)` とし、続けて更新案を提示する:

   ```markdown
   ## PR本文の更新案（未適用）
   PR本文にユーザーの加筆を検出したため、自動更新は行いませんでした。
   以下の更新案でよければ「適用して」と指示してください。

   ### 更新が必要な箇所
   - `## 概要` 3段落目: 旧仕様「〜」→ 新仕様「〜」
   - `## 変更内容`: `src/foo.py` の行を追加

   ### 更新後の本文（全文）
   ...
   ```

   ステップ4-3で人間編集を検出し **(a) 最小限の編集** を選んだ場合は、PR行に `(Draft / 本文を部分更新)` と記し、どのセクションを書き換えたかを1行で添える。

## 制約

- **ブランチのrenameは行わない**（既存PRとの紐付けを壊さないため）
- **PRは新規作成せず、既存PRの本文を編集して更新する**
- **人間が書き換えたPR本文を機械的に上書きしない** — 加筆を検出したら、その記述に沿って最小限だけ編集するか、編集せず最終サマリで更新案を提案する。判断が付かない場合は編集しない
- **PRは常にDraftのまま維持する（Ready for reviewへの自動変更はしない）**
- **Greptile指摘は今回のpush以降の新規分のみを対象にする**（前回ラウンドで判定済みの指摘は再評価しない）
- **PR本文更新・コミットを「タスク完了」扱いにして停止しない**
- すべてのコミットメッセージは英語・Claudeの共著フッターを追加しない（既存スキル継承）
- 各コミットはアトミックで独立してリバート可能であること
- PRタイトル/本文・ユーザーへの出力は日本語
- ブランチ比較は常に `origin/main`
- **1パスのみ**（Greptile再レビューの反復はしない）
- Greptile指摘の修正はコメントが指摘する範囲のみ（スコープ外リファクタ禁止、Greptileのコメント以外は対象外）
- 各段階でテストグリーン・カバレッジ80%以上を維持。回復不能な失敗時は push せず中断して報告

---

## 参照

### スキル
- [`/refine-loop`](../refine-loop/SKILL.md) - 初回のPR作成まで担う姉妹スキル（本スキルはその後段）
- [`/commit-fast`](../commit-fast/SKILL.md) - 分割コミット手順のインライン化元（ステップ3・7）
- `/simplify` - 変更コードのリファクタリング（ビルトイン、`Skill`ツールで起動・自動修正）
- [`/tdd-workflow`](../tdd-workflow/SKILL.md) - TDDワークフローの原則とパターン
- [`/review-greptile`](../review-greptile/SKILL.md) - Greptileコメント取得・分類ロジックの流用元
