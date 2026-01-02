# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- **Multi-machine support**: Automatically adapts configuration based on machine ID
- **Template-based configuration**: Conditional settings for work/personal machines
- **Automated setup**: One-liner installation for new machines
- **Version controlled**: Track changes with git

## Quick Start

### New Machine Setup

```bash
# One-liner installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mikanfactory/dotfiles
```

Or with Homebrew:

```bash
brew install chezmoi
chezmoi init --apply mikanfactory/dotfiles
```

On first run, you'll be prompted to enter a `machineId`:
- `work1` / `work2`: Work machines (custom git config and paths)
- Any other name (e.g., `mac-mini`): Personal machine settings

### What Gets Installed

- **Shell**: Zsh with custom configuration
- **Prompt**: Starship
- **Editor**: Neovim with plugins (dein.vim)
- **Terminal**: Hyper
- **Tools**: peco, exa, bat, tig, tmux, and more
- **Machine-specific**: nvm, pnpm, mise, direnv, Google Cloud SDK (auto-configured)

## Daily Usage

### Editing Configuration

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# Edit machine-specific settings
chezmoi edit ~/.config/zsh/rc/local_env.sh
```

### Applying Changes

```bash
# Preview changes
chezmoi diff

# Apply changes to home directory
chezmoi apply

# Apply with verbose output
chezmoi apply -v
```

### Syncing Across Machines

```bash
# Update from remote repository
chezmoi update

# Or manually
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

### Making Changes to Dotfiles

```bash
# Navigate to source directory
cd ~/.local/share/chezmoi

# Or use the symlink (if using .chezmoiroot)
cd ~/dotfiles

# Make changes and commit
git add -A
git commit -m "Update configuration"
git push

# Apply to other machines
chezmoi update  # on other machines
```

## Machine-Specific Configuration

Configuration is automatically customized based on `machineId`:

### Work Machines (work1/work2)
- Custom git user/email
- Work-specific project directories
- Machine-specific Google Cloud SDK paths

### Personal Machines
- Personal git user/email
- Development tools: nvm, pnpm, mise, direnv
- Personal project directories

### Adding New Machine-Specific Settings

Edit `home/private_dot_config/zsh/rc/local_env.sh.tmpl` and add conditional blocks:

```bash
{{- if eq .machineId "new-machine" }}
# New machine specific settings
export CUSTOM_VAR="value"
{{- end }}
```

## Directory Structure

```
~/dotfiles/
├── .chezmoiroot              # Points to home/ as source
├── home/                     # chezmoi source directory
│   ├── .chezmoi.toml.tmpl   # Machine configuration template
│   ├── .chezmoiignore       # Files to ignore
│   ├── dot_zshrc            # ~/.zshrc
│   ├── dot_gitconfig.tmpl   # ~/.gitconfig (templated)
│   ├── private_dot_config/  # ~/.config/
│   │   ├── nvim/
│   │   ├── starship.toml
│   │   └── zsh/rc/
│   │       └── local_env.sh.tmpl  # Machine-specific settings
│   └── .chezmoiscripts/     # Setup scripts
│       ├── run_once_before_install-homebrew.sh.tmpl
│       ├── run_once_after_install-packages.sh.tmpl
│       └── run_once_after_setup-nvim.sh.tmpl
└── install_scripts/         # Legacy (for reference)
```

## Troubleshooting

### Re-initialize Configuration

If you need to change your machineId:

```bash
# Edit local config
vim ~/.config/chezmoi/chezmoi.toml

# Or re-run init
chezmoi init
```

### Check What Would Change

```bash
chezmoi diff
```

### Force Apply

```bash
chezmoi apply --force
```

### View Managed Files

```bash
chezmoi managed
```

## Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [chezmoi User Guide](https://www.chezmoi.io/user-guide/setup/)

## Legacy Setup (Deprecated)

The old Makefile-based setup is deprecated. Use chezmoi instead.

```bash
# Old method (not recommended)
make install
```
