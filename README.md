# dotfiles

mikanfactoryのdotfiles

## クイックスタート

### 新規マシンでのセットアップ

```bash
brew install chezmoi
chezmoi init --apply mikanfactory/dotfiles
```

初回実行時に`machineId`の入力を求められます。

## 日常的な使い方

### 設定の編集

```bash
chezmoi edit ~/.zshrc
```

### 変更の適用

```bash
# 変更をプレビュー
chezmoi diff

# ホームディレクトリに変更を適用
chezmoi apply

# 詳細出力で適用
chezmoi apply -v
```

### bitwarden 連携
```bash
# Bitwardenにログイン・アンロック
export BW_SESSION=$(bw unlock --raw)

# テンプレート出力をプレビュー
chezmoi cat ~/.claude/settings.json

# 適用
chezmoi apply
```

### マシン間での同期

```bash
# リモートリポジトリから更新
chezmoi update

# または手動で
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

### 便利なコマンド

```bash
# 現在インストール済みのパッケージからBrewfileを生成
brew bundle dump --file=~/dotfiles/home/Brewfile --force

# Brewfile内のパッケージがすべてインストールされているか確認
brew bundle check --file=~/dotfiles/home/Brewfile

# Brewfileに記載されていない不要なパッケージを削除（dry-run）
brew bundle cleanup --file=~/dotfiles/home/Brewfile

# Brewfileに記載されていない不要なパッケージを削除
brew bundle cleanup --file=~/dotfiles/home/Brewfile --force

# Brewfileの内容をリスト表示
brew bundle list --file=~/dotfiles/home/Brewfile

# 依存関係を含めてインストール
brew bundle install --file=~/dotfiles/home/Brewfile

# スキル（npx skills）のロックファイルを更新し、chezmoiソースに同期
mise run skill-lock

# スキルをインストールしてClaude Codeにリンク（-a claude-code が必要）
npx skills add <owner/repo> -g -s <skill-name> -a claude-code -y
```

## ローカルLangfuse（Claude Codeのトレース）

Claude Codeのセッションを、手元で動かすLangfuseに記録する。
公式のcomposeファイルは `home/.chezmoiexternal.toml` でバージョンを固定して取得する。

### 初回セットアップ

OrbStackの設定で「Start at login」を有効にする（CLIからは設定できない）。
コンテナは `restart: always` なので、以後はOrbStackの起動と一緒に立ち上がる。

```bash
# 公式composeファイルを ~/.config/langfuse/ に取得
chezmoi apply

# .env を生成してLangfuseを起動
mise run langfuse up -d

# Claude Codeプラグインをインストールし、ローカルLangfuseに接続
mise run langfuse-connect
```

- UI: http://localhost:3000
- ログイン情報: `~/.config/langfuse/.env` の `LANGFUSE_INIT_USER_EMAIL` と `LANGFUSE_INIT_USER_PASSWORD`
- 送信ログ: `~/.claude/state/langfuse_hook.log`

### 動作確認

```bash
env_file=~/.config/langfuse/.env
pk=$(grep '^LANGFUSE_INIT_PROJECT_PUBLIC_KEY=' "$env_file" | cut -d= -f2-)
sk=$(grep '^LANGFUSE_INIT_PROJECT_SECRET_KEY=' "$env_file" | cut -d= -f2-)

curl -s http://localhost:3000/api/public/health
curl -s -u "$pk:$sk" 'http://localhost:3000/api/public/v2/observations?limit=1'
```

セルフホスト版のv4は`events_only`モードで動くため、`/api/public/traces`などの旧APIは404を返す。
読み取りは`/api/public/v2/observations`を使う。

### 日常操作

引数はそのまま `docker compose` に渡される。

```bash
mise run langfuse ps
mise run langfuse logs -f langfuse-web
mise run langfuse down

# イメージの更新
mise run langfuse pull && mise run langfuse up -d
```

composeファイル自体を更新するときは、`home/.chezmoiexternal.toml` のタグを書き換えて `chezmoi apply` する。

### 注意

- `~/.config/langfuse/.env` を削除しないこと。暗号化キーなどが失われ、既存データが読めなくなる
- プロジェクト側で `LANGFUSE_PUBLIC_KEY` などの環境変数をexportしていると、プラグインはそちらを優先する

## リソース

- [chezmoiドキュメント](https://www.chezmoi.io/)
- [chezmoiユーザーガイド](https://www.chezmoi.io/user-guide/setup/)
