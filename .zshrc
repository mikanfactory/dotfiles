# lang
export LANG=ja_JP.UTF-8


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
disable r

export EDITOR=/usr/bin/vim
export SHELL=/bin/zsh
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/shoji.sugai/.local/bin:$PATH"
export PATH=$HOME/.nodebrew/current/bin:$PATH

# alias
alias :q="exit"
alias cd="pushd"
alias pop="popd"
alias end="popd"
alias dirs="dirs -v"
alias vinit="python3 -m venv venv && venv"
alias venv=". .venv/bin/activate"
alias vexit="deactivate"
alias vim=/usr/bin/vim
alias diff=colordiff

if command -v exa &> /dev/null
then
    alias ll='exa -bghmla --git'
fi

if command -v peco &> /dev/null
then
    alias -g P="| peco"
fi

if command -v jq &> /dev/null
then
    alias -g J="| jq ."
fi

# global alias
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g W="| wc -l"

# export peco custom functions
source "$HOME/code/dotfiles/.config/zsh/rc/peco.sh"

# export custom environment
source "$HOME/code/dotfiles/.config/zsh/rc/custom_env.sh"

# auto suggestion
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# starship
eval "$(starship init zsh)"

# config
WORDCHARS='*?_-[]~&;!#$%^(){}<>|.'

