---
name: refine-loop
description: |
  プラン承認後に「TDD実装 → /simplify整理 → コミット&PR作成 → Greptileレビュー待ち
  → 推奨指摘の自動修正 → push」を1パスで自動実行するスキル。
  プランモードを終了して一連のリファインフローを回す。
  「/refine-loop」で起動。プランが承認済みで自動で最後まで通したい場合にトリガー。
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
- 既存PR: !`gh pr view --json number,url 2>/dev/null || echo "PRなし"`
- PRテンプレート: !`cat $(git rev-parse --show-toplevel)/.github/pull_request_template.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE/default.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/docs/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat $(git rev-parse --show-toplevel)/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "テンプレートなし"`

## タスク

承認済みプランの実装から push までを **1パス** で自動実行します。`/commit-and-pr` `/commit` はサブスキル呼び出しせず、その手順を**インライン化**します

### ステップ0: プランモードの終了

現在プランモードにいる場合は、`ExitPlanMode`ツールを使用して今すぐ終了してください。実装〜push続行についてユーザーの承認を得ています。

### ステップ0.5: 前提チェック

上記コンテキストを確認:

- `gh認証状態` が未認証、または `リポジトリ情報` が「不明」、または `origin` リモートが無い場合 → 理由を報告して**中断**（ステップ3以降が実行できないため）。

### ステップ1: TDDでコード生成

承認済みプランを `/tdd-workflow` の原則で実装します:

1. **RED** — まず失敗するテストを書く（各テストは1つの振る舞い・説明的なテスト名・外部依存はモック・エッジケースとエラーパスを含む）
2. **GREEN** — テストを通過する最小限のコードを書く
3. **REFACTOR** — テストをグリーンに保ったままコードを改善
4. **カバレッジ確認** — プロジェクトのテストコマンドで実行。Pythonなら:
   ```bash
   uv run pytest --cov=src --cov-report=term-missing
   ```
   **80%未満なら**テストを追加し、閾値に到達するまで RED→GREEN を繰り返す。

### ステップ2: /simplify でリファクタリング

`Skill`ツールで `simplify` を呼び出し、変更コードの再利用性・品質・効率を見直して自動修正させます。

完了後、ステップ1のテストを再実行してグリーンを確認。`/simplify` の変更でテストが壊れた場合は最小限の修正で回復させる。

### ステップ3: コミット & PR作成（インライン）

`/commit-and-pr` の手順を、**末尾の「完了（ここで停止）」ステップは行わず**に再現します（PR作成後もステップ4へ続行する）。

1. `git-commit-splitter`エージェントを `Task` で起動し、すべての変更（フォーマッタ変更含む）を論理的でアトミックなコミットに分割して作成する。
2. `pr-creator`エージェントを `Task` で起動する。**上記コンテキストの「PRテンプレート」の内容をエージェントのプロンプトに含める**。前提条件（ブランチ・コミットの存在）を確認し、PRテンプレートを使って日本語のタイトルと説明文を生成し、`gh pr create` でPRを作成させる。push はこの時点で完了する。
3. PR番号とURLを捕捉して保持する:
   ```bash
   gh pr view --json number,url --jq '"PR #" + (.number|tostring) + " " + .url'
   ```
4. **PR作成はゴールではなく通過点。「完了」扱いで停止せず、必ずステップ4へ進む**

### ステップ4: Greptileレビュー待ち（ポーリング+タイムアウト継続）

ステップ3のPR番号に対し、Greptileのレビューコメントを **60秒間隔・最大15分（最大15回）** ポーリングします。owner/repo は上記コンテキストの「リポジトリ情報」、`{pr}` はステップ3で捕捉したPR番号を使用。

単一Bash内のポーリングループ例（`{owner}/{repo}` と `{pr}` を実値に置換して実行）:

```bash
for i in $(seq 1 15); do
  n=$(gh api "repos/{owner}/{repo}/pulls/{pr}/comments" --paginate \
        --jq '[.[] | select(.user.login | test("greptile"))] | length' 2>/dev/null || echo 0)
  m=$(gh api "repos/{owner}/{repo}/pulls/{pr}/reviews" --paginate \
        --jq '[.[] | select(.user.login | test("greptile"))] | length' 2>/dev/null || echo 0)
  echo "poll $i: inline=$n reviews=$m"
  [ "$n" -gt 0 ] || [ "$m" -gt 0 ] && { echo "GREPTILE_READY"; break; }
  sleep 60
done
```

- `GREPTILE_READY` が出たら次のステップへ。
- foreground `sleep` がハーネスにブロックされる場合は、`Monitor`ツールでGreptileコメント数 `> 0` を until条件にしてフォールバックする。
- **15分経過しても0件**の場合 → 「Greptileのレビューが時間内に付かなかった」と警告し、**ステップ5・6をスキップして正常終了**（PRはpush済みで残る。最終サマリでPR URLを報告）。

レビューが取得できたら、`/review-greptile` と同じ3ソースでコメント本体を取得:

```bash
# 2a: インラインレビューコメント
gh api repos/{owner}/{repo}/pulls/{pr}/comments --paginate \
  --jq '[.[] | select(.user.login | test("greptile")) | {id, path, line: (.line // .original_line), side, body, diff_hunk, created_at}]'
# 2b: トップレベルレビュー
gh api repos/{owner}/{repo}/pulls/{pr}/reviews --paginate \
  --jq '[.[] | select(.user.login | test("greptile")) | {id, body, state}]'
# 2c: レビューに紐づくコメント（review_idが取れた場合）
gh api repos/{owner}/{repo}/pulls/{pr}/reviews/{review_id}/comments --paginate \
  --jq '[.[] | {id, path, line: (.line // .original_line), body, diff_hunk}]'
```

### ステップ5: 推奨指摘の自動修正

`/review-greptile` の分析ロジックを流用しますが、**ユーザー選択は待たず**「対応推奨」のみ自動適用します。

1. 各インラインコメントについて、該当ファイルを `Read`（コメント行の前後20行程度）し、以下を判定:
   - **妥当性**: 指摘は正しいか
   - **重要度**: `バグ` / `セキュリティ` / `パフォーマンス` / `スタイル` / `その他`
   - **対応推奨**: `対応` または `スキップ`
   - **理由**: 判定の根拠（1-2文）／対応推奨なら**修正案**（1文）
2. 分析レポートを **表示のみ**（選択は待たない）:
   ```markdown
   # Greptileレビュー分析レポート
   **PR:** #123 - タイトル
   **コメント数:** X件 | **推奨対応:** Y件 | **推奨スキップ:** Z件

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
4. **全件「スキップ推奨」or コメント0件**の場合 → 修正・追加コミット・pushをスキップし、「対応不要」と報告して終了（最終サマリでPR URLを報告）。
5. 修正後、ステップ1のテストを再実行し、カバレッジ80%以上を再確認。修正でテストが壊れたら最小限の修正で回復させる。**回復不能な場合は push せず**、状況を報告して中断。

### ステップ6: 追加コミット & push

1. `git-commit-splitter`エージェントを `Task` で起動し、ステップ5の修正を論理的でアトミックなコミットに分割して作成する。
2. push する:
   ```bash
   git push
   ```
3. 最終サマリを日本語で表示:
   ```markdown
   ## refine-loop 完了
   - PR: #123 <URL>
   - Greptile: 推奨対応 Y件修正 / スキップ Z件
   - テスト: グリーン / カバレッジ XX%
   ```

## 制約

- **PR作成・コミットを「タスク完了」扱いにして停止しない**
- すべてのコミットメッセージは英語・Claudeの共著フッターを追加しない（既存スキル継承）
- 各コミットはアトミックで独立してリバート可能であること
- PRタイトル/本文・ユーザーへの出力は日本語
- ブランチ比較は常に `origin/main`
- **1パスのみ**（Greptile再レビューの反復はしない）
- Greptile指摘の修正はコメントが指摘する範囲のみ（スコープ外リファクタ禁止、Greptileのコメント以外は対象外）
- 各段階でテストグリーン・カバレッジ80%以上を維持。回復不能な失敗時は push せず中断して報告

---

## 参照

### エージェント
- [`git-commit-splitter`](../../agents/git-commit-splitter.md) - 変更を論理的なコミットに分割
- [`pr-creator`](../../agents/pr-creator.md) - PRの作成と説明文の生成

### スキル
- `/simplify` - 変更コードのリファクタリング（ビルトイン、`Skill`ツールで起動・自動修正）
- [`/tdd-workflow`](../tdd-workflow/SKILL.md) - TDDワークフローの原則とパターン
- [`/review-greptile`](../review-greptile/SKILL.md) - Greptileコメント取得・分類ロジックの流用元
