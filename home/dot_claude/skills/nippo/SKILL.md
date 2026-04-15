---
name: nippo
description: >
  Claude Code のセッションログから日報・リフレクション・インサイトを生成する。
  /nippo で日報、/nippo reflection で内省の問い、/nippo guide で学習支援、
  /nippo report で進捗報告、/nippo review で自己評価、/nippo insight で深い振り返り、
  /nippo trend で長期変化分析を生成する。Go バイナリ (nippo) でデータを収集する。
argument-hint: "[mode] [days] [project]"
allowed-tools: Read, Write, Bash(nippo *), Bash(mkdir *)
---

# 指示

`$ARGUMENTS` に基づいてモード・期間・プロジェクトフィルタを決定し、`nippo` CLI を実行して取得した JSON を元にレポートを生成する。

## ルール

- データ収集は `nippo` CLI のみ。**Python は絶対に使わない**
- JSON の `stats` フィールドは**直接引用する。再計算しない**
- 書籍・URL は紹介しない。概念名・検索キーワードを示す
- レポートは日本語で出力する
- 出力先ディレクトリは環境変数 `$NIPPO_REPORTS_DIR`（未設定時は cwd の `reports/`）。先頭で `mkdir -p "$NIPPO_REPORTS_DIR"` を実行
- ファイル名: `$NIPPO_REPORTS_DIR/{モード}-YYYY-MM-DD.md`（期間 N>1 なら `-Nd` を付与。モードが日報の場合は `nippo-` プレフィックス）
- `~` やチルダ展開は Bash 経由で解決する（Write は絶対パスを受け取る）
- `nippo` は stdout に出力するので `> /tmp/nippo-{モード}.json` にリダイレクトしてから Read で読む

## Go 版 nippo CLI のフラグ

- `--days N` : 過去 N 日（0=全期間）
- `--from YYYY-MM-DD --to YYYY-MM-DD` : 範囲指定
- `--period today|yesterday|this-week|last-week|this-month|last-month`
- `--project SUBSTR` : プロジェクト名部分一致
- `--format markdown|json` : 既定は markdown。集計データを参照するときは json
- `--claude-dir PATH` : 既定 `$HOME/.claude`
- `--max-sessions N`

`collect` サブコマンドや `--format summary` / `--stats-only` は存在しない。JSON に含まれる `stats` を使う。

## モード決定

`$ARGUMENTS` をトリミングし、先頭単語でモードを決定する:

| 先頭単語 | モード | デフォルト期間 | 実行コマンド |
|---------|--------|-------------|-------------|
| (空) | 日報 | 1日 | `nippo --days 1 --format json` |
| brief | brief | 1日 | `nippo --days 1 --format markdown`（出力をそのまま保存） |
| reflection | reflection | 1日 | `nippo --days 1 --format json` |
| guide | guide | 1日 | `nippo --days 1 --format json` |
| report | report | 7日 | `nippo --days 7 --format json` |
| review | review | 90日 | `nippo --days 90 --format json` |
| insight | insight | 7日 | `nippo --days 7 --format json` |
| trend | trend | 90日 | 3回 `nippo --from X --to Y --format json` で3期間分 |
| (数値のみ) | 日報 | その数値 | `nippo --days N --format json` |

残りトークンに数値があれば `--days` を置換。モード名でも数値でもない文字列は `--project` に渡す。

## 実行手順

1. モードに対応する `nippo` コマンドを Bash で実行し、`/tmp/nippo-{モード}.json`（brief は `.md`）に保存
2. Read で読み込む
3. 以下のテンプレートに従いレポートを組み立てる
4. Write で `reports/...md` に保存
5. パスをユーザーに通知

## モード別テンプレート

### 日報（デフォルト）
- 見出し: 期間、合計セッション数、合計 input/output トークン
- プロジェクトごとに: セッション数、主な作業内容、使用ツール、触れたファイル
- 末尾に「今日学んだ用語」セクション（JSONから抽出した技術用語）

### brief
- `nippo --format markdown` の出力を加工せず保存

### reflection
- 「今日の問い」として 3〜5 個の内省的な質問を生成
- **回答は書かない**。問いのみ
- 参考: コルブの経験学習サイクル、ALACT モデル

### guide
- 日報と同じ事実ベースの要約に加え
- 今日詰まった箇所 → 関連概念 → 多角的フィードバック（技術・学習プロセス・メンタル）
- 同日の `reports/nippo-YYYY-MM-DD.md` があれば Read して参照
- 回答つき

### report
- 成果（定量: コミット数、触れたファイル、ツール使用数）
- 進行中の課題
- 次の一手
- 感情は含めない

### review
- 期間全体の成果を定量化
- 成長した領域
- 次期（3ヶ月後）の目標候補

### insight
- ALACT モデル（Action → Looking back → Awareness → Creating alternatives → Trial）に沿った振り返り
- 各ステップに回答を書く

### trend
- 3期間（直近30日、31〜60日、61〜90日）の比較
- セッション数・プロジェクト分布・ツール使用傾向の変化
- 最低45日のデータが必要

## reflection / guide / insight の補足

これらのモードは「内省支援」のため、以下を意識:
- 事実と感情を分けて記述
- 判断を保留して観察を書く
- 同日の日報がある場合はそれを Read して一貫性を持たせる
