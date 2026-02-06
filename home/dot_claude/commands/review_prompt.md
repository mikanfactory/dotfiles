---
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(git log:*)
description: LLMプロンプトをレビューして品質・効率・安全性を評価する
---

## コンテキスト

- 現在の作業ディレクトリ: !`pwd`
- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "Not a git repo"`
- ステージ済みファイル: !`git diff --name-only --cached 2>/dev/null`
- 未ステージファイル: !`git diff --name-only 2>/dev/null`
- mainとのdiff: !`git diff --name-only main...HEAD 2>/dev/null || echo "No main branch"`

## タスク

`prompt-engineer`エージェントの専門知識を使用して、包括的なLLMプロンプトレビューを実施します。

### ステップ1: レビュー対象のプロンプトファイルを特定

以下の優先順位でレビュー対象のプロンプトファイルを決定します:

**オプションA: ステージ済み/未ステージの変更（デフォルト）**
ステージ済みまたは未コミットの変更がある場合、プロンプト関連ファイルをフィルタリング:
```bash
git diff --name-only --cached 2>/dev/null
git diff --name-only 2>/dev/null
```

**オプションB: mainブランチとのdiff**
ステージ済み/未ステージのプロンプトファイルがない場合、mainとのdiffを確認:
```bash
git diff --name-only main...HEAD 2>/dev/null
```

**オプションC: 特定のパスが指定された場合**
ユーザーがパス引数を指定した場合（例: `/review_prompt prompts/system.md`）、そのパスを使用。

**オプションD: インラインプロンプトが提供された場合**
ユーザーが引用符内でプロンプトテキストを直接提供した場合、そのテキストをレビュー。

**検出するプロンプトファイルパターン:**
- `*.prompt`, `*.prompt.md`, `*.prompt.txt`
- `**/prompts/**/*.md`, `**/prompts/**/*.txt`
- `CLAUDE.md`, `SKILL.md`, `*.skill.md`
- ファイル名に`system_prompt`、`user_prompt`を含むファイル
- `**/agents/**/*.md`

### ステップ2: プロンプト構造の分析

各プロンプトファイルについて、メタデータを収集:

```json
{
  "file_path": "<path>",
  "prompt_type": "system|user|few-shot|chain-of-thought|mixed",
  "estimated_tokens": "<count>",
  "components": {
    "has_system_instructions": true,
    "has_few_shot_examples": false,
    "has_output_format": true,
    "has_constraints": true,
    "has_persona": false
  }
}
```

### ステップ3: レビューの実施

以下の5つのカテゴリでプロンプトを評価:

#### 3.1 明確性と具体性 (PE-1xx)
- **PE-101**: 明確なタスク定義
- **PE-102**: 曖昧さのない指示
- **PE-103**: 具体的な出力期待値
- **PE-104**: 明確に定義されたスコープ

#### 3.2 トークン効率 (PE-2xx)
- **PE-201**: 冗長なコンテンツの検出
- **PE-202**: 圧縮の機会
- **PE-203**: 不必要な冗長性
- **PE-204**: 例の効率（few-shot用）

#### 3.3 安全性の考慮事項 (PE-3xx)
- **PE-301**: プロンプトインジェクションの脆弱性
- **PE-302**: 出力操作のリスク
- **PE-303**: 機密データの取り扱い
- **PE-304**: ガードレールの推奨事項

#### 3.4 パターンの効果性 (PE-4xx)
- **PE-401**: パターン選択の適切性（Zero-shot、Few-shot、CoT、ToT、ReAct）
- **PE-402**: 例の品質と関連性（few-shot用）
- **PE-403**: 推論ステップの明確さ（CoT用）
- **PE-404**: パターンの一貫性

#### 3.5 ベストプラクティス (PE-5xx)
- **PE-501**: 役割/ペルソナの明確さ
- **PE-502**: 出力フォーマットの指定
- **PE-503**: エラーハンドリングの指示
- **PE-504**: エッジケースのカバレッジ

### ステップ4: 重大度の分類

- `critical` - プロンプトが失敗するか有害な出力を生成する可能性が高い
- `high` - 効果性または安全性に重大な問題
- `medium` - 品質を著しく向上させる改善点
- `low` - スタイルの提案と軽微な最適化

### ステップ5: レビュー結果の提示

#### エグゼクティブサマリー

```markdown
# LLMプロンプトレビューレポート

**プロンプトソース:** <ファイルパスまたは"inline">
**プロンプトタイプ:** <type>
**推定トークン数:** <count>

## サマリー

| カテゴリ | 問題数 | 重大度 |
|----------|--------|----------|
| 明確性 | X | High: Y, Medium: Z |
| 効率性 | X | High: Y, Medium: Z |
| 安全性 | X | Critical: Y, High: Z |
| パターン | X | Medium: Y, Low: Z |
| ベストプラクティス | X | Medium: Y, Low: Z |

**品質スコア:** X/100

### クリティカルな問題（即時対応が必要）
1. **PE-301** プロンプトインジェクションの脆弱性...
```

#### 詳細な発見事項

各問題について以下を提供:
- 問題ID (PE-XXX)
- カテゴリと重大度
- 場所（行番号またはセクション）
- 説明
- 改善されたテキストを含む推奨事項
- 該当する場合はBefore/After比較

#### ポジティブな発見事項

適切に実装されたパターンをハイライト:
- 技術の効果的な使用
- 優れた安全性プラクティス
- クリーンな構造

#### 改善されたプロンプトの提案

クリティカルまたは高重大度の問題が存在する場合、最適化されたバージョンを提供。

## 使用例

```bash
# ステージ済み/未ステージのプロンプトファイルをレビュー（デフォルト）
/review_prompt

# 特定のファイルをレビュー
/review_prompt prompts/system-prompt.md

# インラインプロンプトをレビュー
/review_prompt "You are a helpful assistant..."

# ディレクトリをレビュー
/review_prompt prompts/
```

## 制約

- 最大プロンプトサイズ: 100,000トークン
- プロンプトファイルが見つからない場合、明確に報告して終了
- ユーザーとコミュニケーションする際は常に日本語で結果を出力
- 具体的な例を含む実用的な推奨事項を提供
- 安全性の問題が見つかった場合は常に目立つようにフラグを立てる

## コミュニケーションスタイル

- 明確で実用的な言葉を使用
- 改善点にはbefore/afterの例を提供
- クリティカルな問題を最上部に優先
- 効率性の提案にはトークン数への影響を含める
- ユーザーへの回答は日本語で

---

## 参照

### エージェント
- [`prompt-engineer`](../agents/prompt-engineer.md) - LLMプロンプトの評価と最適化
