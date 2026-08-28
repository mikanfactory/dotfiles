---
name: refine-loop
description: |
  プラン承認後に「ブランチrename → TDD実装 → /simplify整理 → コミット&PR作成
  → Greptileレビュー待ち → 推奨指摘の自動修正 → push → Greptileへ対応可否を返信」を
  1パスで自動実行するスキル。
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

承認済みプランの実装から push までを **1パス** で自動実行します。コミット作成・PR作成はサブスキル呼び出しせず、その手順を**インライン化**します

### ステップ0: プランモードの終了

現在プランモードにいる場合は、`ExitPlanMode`ツールを使用して今すぐ終了してください。実装〜push続行についてユーザーの承認を得ています。

### ステップ0.5: 前提チェック

上記コンテキストを確認:

- `gh認証状態` が未認証、または `リポジトリ情報` が「不明」、または `origin` リモートが無い場合 → 理由を報告して**中断**（ステップ3以降が実行できないため）。

### ステップ0.7: ブランチ rename

`Skill`ツールで `rename-branch` を呼び出し、承認済みプランの要約から意味のあるブランチ名へ自動rename します（PRが最初から内容を表すブランチ名で作成されるようにするため）。

- 「rename不要」と報告された場合 → そのままステップ1へ続行
- 中断（保護ブランチ／衝突／プラン未検出）の場合 → refine-loop全体を**中断**（誤ブランチでのPR作成を防ぐため）

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

コミット作成からPR作成までを以下の手順で実行します（PR作成を「完了」扱いにせず、ステップ4へ続行する）。

1. `/commit-fast` の手順をインラインで実行し、すべての変更（フォーマッタ変更含む）を分割コミットする:
   - `git status` と `git diff HEAD --stat` を見て、変更を論理グループ（feat/fix/refactor/docs/test/chore）に分類する。ファイル名・パス・変更行数で判断が付くものはdiffを読まずに分類し、内容を見ないと分類できないファイルに限り `git diff HEAD -- <file>` で確認する
   - **ユーザー確認は挟まず**、各論理グループを `git add <files...>` → `git commit -m "<type>: <summary>"` で順次コミットする（メッセージは英語・命令形・50文字以内推奨、依存関係のあるコミットは正しい順序で）
2. `pr-creator`エージェントを `Task` で起動する。**上記コンテキストの「PRテンプレート」の内容をエージェントのプロンプトに含める**。さらに**「PRはDraftとして作成すること（`gh pr create --draft` を使用）」と明示的に指示する**。前提条件（ブランチ・コミットの存在）を確認し、PRテンプレートを使って日本語のタイトルと説明文を生成し、`gh pr create --draft` でPRをDraftとして作成させる。push はこの時点で完了する。
3. PR番号とURLを捕捉して保持する:
   ```bash
   gh pr view --json number,url --jq '"PR #" + (.number|tostring) + " " + .url'
   ```
4. **PR作成はゴールではなく通過点。「完了」扱いで停止せず、必ずステップ4へ進む**

### ステップ4: Greptileレビューのトリガー & レビュー待ち

取得・待機の詳細手順は [`review-greptile/references/greptile-api.md`](../review-greptile/references/greptile-api.md) に従う。`{owner}/{repo}` は上記コンテキストの「リポジトリ情報」、`{pr}` はステップ3で捕捉したPR番号を実値で埋める。

1. **ベースラインを空にする**（新規PRのため既存Greptileコメントは無い）。リファレンス §2 の `STATE_DIR` / `snapshot()` を定義したうえで:

   ```bash
   : > "$STATE_DIR/baseline.txt"
   ```

2. **レビューをトリガーする**。Greptileは `@greptileai` メンションがないとレビューを開始しない場合があるため、PR作成直後にメンションコメントを投稿する:

   ```bash
   gh pr comment {pr} --body "@greptileai review"
   ```

3. **完了を待つ**。リファレンス §4 のポーリングループを **`Bash`ツールの `run_in_background: true`** で実行する（foregroundの `sleep` はハーネスにブロックされるため必須）。30秒間隔・最大30回＝15分でタイムアウトする。

   - 出力に `GREPTILE_READY` が現れたら次へ進む
   - `GREPTILE_TIMEOUT` の場合 → 「Greptileのレビューが時間内に付かなかった」と警告し、**ステップ5〜7をスキップして正常終了**（PRはpush済みで残る。最終サマリでPR URLを報告）

4. **本文を取得する**。リファレンス §5 に従い、サマリ（`issues/{pr}/comments`）・インライン（`pulls/{pr}/comments`）・レビュー（`pulls/{pr}/reviews` のbody非空）の3ソースを取得する。**指摘0件のPRではインラインが0件・レビューbodyが空になり、サマリだけが唯一のレビュー結果になる**ため、サマリを必ず取得する。

### ステップ5: 推奨指摘の自動修正

`/review-greptile` の分析ロジックを流用しますが、**ユーザー選択は待たず**「対応推奨」のみ自動適用します。

1. 各インラインコメントについて、該当ファイルを `Read`（コメント行の前後20行程度）し、以下を判定:
   - **妥当性**: 指摘は正しいか
   - **重要度**: `バグ` / `セキュリティ` / `パフォーマンス` / `スタイル` / `その他`
   - **対応推奨**: `対応` または `スキップ`
   - **理由**: 判定の根拠（1-2文）／対応推奨なら**修正案**（1文）

   **サマリ・レビュー本文も同じ基準で分析する。** リファレンス §6 のとおり、インラインコメントが0件でもサマリ本文に具体的な指摘が含まれることがあるため、必ず読んで指摘を抽出し、番号を振って判定する。
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
   サマリ・トップレベルレビュー（ファイル参照なし）は「総括コメント（Greptileサマリ）」として別セクションに記載。
3. **「対応推奨」と判定したコメントのみ** `Edit` で自動修正する。修正はコメントが指摘する範囲のみ（スコープ外のリファクタリングは禁止）。
4. **全件「スキップ推奨」or コメント0件**の場合 → 修正・追加コミット・pushはスキップするが、**ステップ7の返信は実施する**（「対応不要」と判断した理由をGreptileに返す）。
5. 修正後、ステップ1のテストを再実行し、カバレッジ80%以上を再確認。修正でテストが壊れたら最小限の修正で回復させる。**回復不能な場合は push せず**、状況を報告して中断。

### ステップ6: 追加コミット & push

1. ステップ5の修正を、ステップ3と同じ `/commit-fast` のインライン手順で論理的でアトミックなコミットに分割して作成する。
2. push する:
   ```bash
   git push
   ```

### ステップ7: Greptileへの返信

push完了後、[`review-greptile/references/greptile-api.md`](../review-greptile/references/greptile-api.md) の **§7** に従い、**Greptileが投稿したコメントに限り**対応可否と理由を返信する。ユーザー確認は挟まない。

1. リファレンス §7.1 で既返信スレッドを除外する
2. **インラインコメント** → `pulls/{pr}/comments/{comment_id}/replies` へスレッド返信（§7.2）。「対応しました」/「対応見送り」＋理由1〜2文
3. **サマリ・総括レビュー** → PRコメント1件に集約して投稿（§7.3）。インラインの対応結果も表に含める
4. 全件スキップ・指摘0件の場合も、サマリへの返信（§7.3）だけは投稿し「対応不要と判断した」旨と理由を記す

最終サマリを日本語で表示:

```markdown
## refine-loop 完了
- PR: #123 <URL> (Draft)
- Greptile: 推奨対応 Y件修正 / スキップ Z件
- Greptileへの返信: インライン N件 + 総括 1件
- テスト: グリーン / カバレッジ XX%
```

## 制約

- **PRは常にDraftとして作成し、refine-loop完了後もDraftのまま維持する（Ready for reviewへの自動変更はしない）**
- **PR作成・コミットを「タスク完了」扱いにして停止しない**
- **返信するのはGreptileが投稿したコメントのみ。人間のコメント・他のbotのコメントには絶対に返信しない**
- 既に自分が返信済みのスレッドには再返信しない
- 返信は修正のpush完了後に行う（返信内容と実際のコードを一致させるため）
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
- [`pr-creator`](../../agents/pr-creator.md) - PRの作成と説明文の生成

### スキル
- [`/commit-fast`](../commit-fast/SKILL.md) - 分割コミット手順のインライン化元（ステップ3・6）
- [`/rename-branch`](../rename-branch/SKILL.md) - プラン要約からブランチ名を生成しrename（ステップ0.7で呼び出し）
- [`/revise-loop`](../revise-loop/SKILL.md) - PR作成後に仕様変更が出た場合の後段スキル（ブランチ維持・PR本文を編集で更新）
- `/simplify` - 変更コードのリファクタリング（ビルトイン、`Skill`ツールで起動・自動修正）
- [`/tdd-workflow`](../tdd-workflow/SKILL.md) - TDDワークフローの原則とパターン
- [`/review-greptile`](../review-greptile/SKILL.md) - Greptileコメント取得・分類ロジックの流用元

### ドキュメント
- [`greptile-api`](../review-greptile/references/greptile-api.md) - Greptileコメントの取得・待機・返信のAPI手順（ステップ4・5・7）
