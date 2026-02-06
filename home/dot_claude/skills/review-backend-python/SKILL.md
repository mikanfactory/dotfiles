---
name: review-backend-python
description: 複数の専門エージェントを使用してPythonバックエンドコードの包括的なレビューを実行します
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(find:*), Bash(ls:*), Read, Glob, Grep
---

## 重要: レビューのみ

- 発見事項と推奨事項のみを提供してください
- 自動的に修正を実装しないでください
- プランモードを終了して変更を実行しないでください
- 変更を行う前に、明示的なユーザーの指示を待ってください（例:「修正して」「修正を実装して」）

## コンテキスト

- 現在のgitステータス: !`git status --short`
- 現在のブランチ: !`git branch --show-current`
- 変更されたファイル（HEAD~1との比較）: !`git diff --name-only HEAD~1 2>/dev/null || echo "No previous commit"`
- ステージされたファイル: !`git diff --name-only --cached`
- リポジトリルート: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

## タスク

`backend-review-orchestrator`エージェントを通じて複数の専門エージェントを調整し、包括的なPythonバックエンドコードレビューをオーケストレーションします。

### ステップ1: レビュー範囲の決定

以下の優先順位に基づいて、レビューするPythonファイルを特定します:

**オプションA: 変更/ステージされたファイルのレビュー（デフォルト）**
ステージされた変更またはコミットされていない変更がある場合、それらのファイルをレビューします:
```bash
git diff --name-only --cached HEAD
git diff --name-only HEAD
```

**オプションB: 特定のパスのレビュー**
ユーザーがパス引数を指定した場合（例: `/review-python src/api/`）、そのパスをレビュー対象として使用します。

**オプションC: すべてのPythonバックエンドファイルのレビュー**
ユーザーがフルレビューを要求した場合、または変更がない場合、すべてのPythonバックエンドファイルをスキャンします:
```bash
find . -type f -name "*.py" \
  ! -path "*/node_modules/*" ! -path "*/.venv/*" ! -path "*/__pycache__/*" ! -path "*/.git/*"
```

**ファイルフィルタリング:**
- 含める: バックエンド関連パスの`*.py`
- 除外: `node_modules/`、`.venv/`、`__pycache__/`、`.git/`
- 最大: レビューセッションあたり50ファイル

### ステップ2: ファイルコンテキストの分析

レビューする各ファイルについて、以下を収集します:
1. ファイルパスとサイズ
2. 主要言語（Python）
3. 機能領域のヒント（パスから: api/、services/、models/、auth/、db/）
4. フレームワーク検出（FastAPI、Django、Flaskなど）

レビューマニフェストを作成します:
```json
{
  "scope": "changed|path|all",
  "target_path": "<path or null>",
  "branch": "<current branch>",
  "files": [
    {
      "path": "src/api/users.py",
      "language": "python",
      "area": "api",
      "framework_hints": ["fastapi"]
    }
  ],
  "git_context": {
    "has_uncommitted_changes": true,
    "is_pull_request": false
  }
}
```

### ステップ3: backend-review-orchestratorの呼び出し

レビューマニフェストを`backend-review-orchestrator`エージェントに渡します。

オーケストレーターは以下を行います:
1. 適切な専門エージェントにファイルをディスパッチ:
   - **python-pro**: Python型安全性、パターン、テスト
   - **backend-developer**: API設計、データベース、マイクロサービス
   - **security-engineer**: 脆弱性、認証、OWASP
   - **database-administrator**: データベースパフォーマンス、クエリ最適化、スキーマ設計
2. JSON形式のレビュー出力を収集
3. 発見事項を集約して重複を排除
4. 統一レポートを生成

### ステップ4: レビュー結果の提示

オーケストレーターからの集約レポートを表示します:

**1. エグゼクティブサマリー**
```markdown
# Pythonバックエンドコードレビューレポート

**レビューしたファイル数:** X
**総問題数:** Y

| 重大度 | 件数 |
|--------|------|
| Critical | X |
| High | X |
| Medium | X |
| Low | X |

## 重大な問題（ある場合）
1. **SE-001** `src/db/queries.py:67`でのSQLインジェクション
```

**2. 重大度別の詳細な発見事項**
CriticalからLowまでのすべての問題を以下の情報とともにリスト:
- 問題IDとタイトル
- 行番号付きのファイル位置
- カテゴリと担当エージェント
- 説明と推奨事項
- コード提案（利用可能な場合）

**3. カテゴリサマリー**
カテゴリ別に問題をグループ化（セキュリティ、パフォーマンス、設計、型安全性、データベースなど）

**4. ポジティブな発見事項**
レビュー中に見つかった適切に実装されたパターンをハイライト

**5. アクションアイテム**
優先順位付きの推奨事項:
- 即時（マージ前に修正必須）
- 短期（今スプリント中に対応）
- 長期（技術的負債）

## 使用例

```bash
# 変更されたファイルをレビュー（デフォルト）
/review-python

# 特定のディレクトリをレビュー
/review-python src/api/

# 特定のファイルをレビュー
/review-python src/services/user_service.py

# すべてのPythonバックエンドファイルをレビュー
/review-python --all
```

## 制約

- Pythonファイルのみをレビュー（フロントエンド、静的アセット、設定は除外）
- 特に要求されない限り、テストファイルはセキュリティレビューから除外
- 徹底した分析を確保するため、レビューあたり最大50ファイル
- 合計タイムアウト: 10分
- Pythonファイルが見つからない場合は、明確に報告して終了
- ユーザーとのコミュニケーションでは常に日本語で結果を出力

## コミュニケーションスタイル

- 実行可能な推奨事項とともに発見事項を明確に提示
- すべてのレポートで重大度レベルを一貫して使用
- すべての問題に具体的なファイル:行の参照を含める
- 可能な場合は修正のコード例を提供
- ユーザーには日本語で回答

---

## 参照

### エージェント
- [`backend-review-orchestrator`](../../agents/backend-review-orchestrator.md) - レビューのオーケストレーション
- [`python-pro`](../../agents/python-pro.md) - Python型安全性とパターン
- [`backend-developer`](../../agents/backend-developer.md) - API設計とデータベース
- [`security-engineer`](../../agents/security-engineer.md) - 脆弱性と認証
- [`database-administrator`](../../agents/database-administrator.md) - データベースパフォーマンス
