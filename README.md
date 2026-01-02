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
```

## リソース

- [chezmoiドキュメント](https://www.chezmoi.io/)
- [chezmoiユーザーガイド](https://www.chezmoi.io/user-guide/setup/)
