# dotfiles

[chezmoi](https://www.chezmoi.io/)で管理する個人用dotfiles

## 特徴

- **複数マシン対応**: マシンIDに基づいて設定を自動適用
- **テンプレートベース**: 仕事用/個人用で条件分岐
- **自動セットアップ**: 新規マシンでワンライナーインストール
- **バージョン管理**: gitで変更履歴を追跡

## クイックスタート

### 新規マシンでのセットアップ

```bash
brew install chezmoi
chezmoi init --apply mikanfactory/dotfiles
```

初回実行時に`machineId`の入力を求められます:
- `work1` / `work2`: 仕事用マシン（専用のgit設定とパス）
- その他の名前（例: `mac-mini`）: 個人用マシン設定

### インストールされるもの

- **シェル**: Zsh（カスタム設定付き）
- **プロンプト**: Starship
- **エディタ**: Neovim（dein.vimプラグイン）
- **ターミナル**: Hyper
- **ツール**: peco, exa, bat, tig, tmux など
- **マシン固有**: nvm, pnpm, mise, direnv, Google Cloud SDK（自動設定）

## パッケージ管理

### Brewfileの使用

インストールするパッケージは`home/Brewfile`で管理しています。

```bash
# パッケージを追加
cd ~/dotfiles
echo 'brew "package-name"' >> home/Brewfile

# 新規マシンでは自動インストール（run_once_after_install-packages.sh.tmpl）
# 既存マシンで手動インストール
brew bundle --file=~/dotfiles/home/Brewfile

# 現在の環境に合わせてBrewfileを更新
brew bundle dump --file=~/dotfiles/home/Brewfile --force

# インストール済みパッケージの確認
brew bundle check --file=~/dotfiles/home/Brewfile
```

### パッケージの追加・削除

```bash
# 新しいパッケージを追加
cd ~/dotfiles
echo 'brew "new-package"' >> home/Brewfile
brew install new-package

# コミット
git add home/Brewfile
git commit -m "Add new-package to Brewfile"
git push
```

### 便利なコマンド

```bash
# 現在インストール済みのパッケージからBrewfileを生成
brew bundle dump --file=~/dotfiles/home/Brewfile --force

# Brewfile内のパッケージがすべてインストールされているか確認
brew bundle check --file=~/dotfiles/home/Brewfile

# Brewfileに記載されていない不要なパッケージを削除
brew bundle cleanup --file=~/dotfiles/home/Brewfile

# 削除されるパッケージをドライラン（実際には削除しない）
brew bundle cleanup --file=~/dotfiles/home/Brewfile --dry-run

# Brewfileの内容をリスト表示
brew bundle list --file=~/dotfiles/home/Brewfile

# 依存関係を含めてインストール
brew bundle install --file=~/dotfiles/home/Brewfile
```

## 日常的な使い方

### 設定の編集

```bash
# dotfileを編集
chezmoi edit ~/.zshrc

# マシン固有の設定を編集
chezmoi edit ~/.config/zsh/rc/local_env.sh
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

### dotfilesの変更方法

```bash
# ソースディレクトリに移動
cd ~/.local/share/chezmoi

# または（.chezmoirootを使用している場合）
cd ~/dotfiles

# 変更してコミット
git add -A
git commit -m "設定を更新"
git push

# 他のマシンで適用
chezmoi update  # 他のマシンで実行
```

## マシン固有の設定

`machineId`に基づいて設定が自動的にカスタマイズされます:

### 仕事用マシン（work1/work2）
- カスタムgitユーザー/メール
- 仕事用プロジェクトディレクトリ
- マシン別のGoogle Cloud SDKパス

### 個人用マシン
- 個人用gitユーザー/メール
- 開発ツール: nvm, pnpm, mise, direnv
- 個人用プロジェクトディレクトリ

### 新しいマシン固有設定の追加

`home/private_dot_config/zsh/rc/local_env.sh.tmpl`を編集して条件分岐を追加:

```bash
{{- if eq .machineId "new-machine" }}
# 新しいマシン固有の設定
export CUSTOM_VAR="value"
{{- end }}
```

## ディレクトリ構造

```
~/dotfiles/
├── .chezmoiroot              # home/をソースとして指定
├── home/                     # chezmoiソースディレクトリ
│   ├── .chezmoi.toml.tmpl   # マシン設定テンプレート
│   ├── .chezmoiignore       # 無視するファイル
│   ├── dot_zshrc            # ~/.zshrc
│   ├── dot_gitconfig.tmpl   # ~/.gitconfig（テンプレート）
│   ├── private_dot_config/  # ~/.config/
│   │   ├── nvim/
│   │   ├── starship.toml
│   │   └── zsh/rc/
│   │       └── local_env.sh.tmpl  # マシン固有設定
│   └── .chezmoiscripts/     # セットアップスクリプト
│       ├── run_once_before_install-homebrew.sh.tmpl
│       ├── run_once_after_install-packages.sh.tmpl
│       └── run_once_after_setup-nvim.sh.tmpl
└── install_scripts/         # 旧バージョン（参照用）
```

## トラブルシューティング

### machineIdの再設定

machineIdを変更する場合:

```bash
# ローカル設定を編集
vim ~/.config/chezmoi/chezmoi.toml

# または再初期化
chezmoi init
```

### 変更内容の確認

```bash
chezmoi diff
```

### 強制適用

```bash
chezmoi apply --force
```

### 管理対象ファイルの表示

```bash
chezmoi managed
```

## リソース

- [chezmoiドキュメント](https://www.chezmoi.io/)
- [chezmoiユーザーガイド](https://www.chezmoi.io/user-guide/setup/)
