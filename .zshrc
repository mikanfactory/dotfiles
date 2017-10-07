# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# zsh theme
ZSH_THEME="af-magic"

# plugins
plugins=(git ruby rails heroku rake-fast brew mysql)

# User configuration
source $ZSH/oh-my-zsh.sh

# fundamental
autoload -U compinit
compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history
bindkey -e
setopt auto_pushd
setopt correct
setopt nolistbeep
setopt list_packed

export EDITOR=/usr/local/bin/vim
export SHELL=/bin/zsh

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# alias
alias :q="exit"
alias cd="pushd"
alias pop="popd"
alias end="popd"
alias dirs="dirs -v"
alias venv=". venv/bin/activate"
alias vexit="deactivate"
alias gcd='cd $(ghq root)/$(ghq list | peco)'
# alias vim=nvim

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="/usr/local/sbin:$PATH"
export PYTHONPATH="/usr/local/lib/python2.7/site-packages/:$PYTHONPATH"
