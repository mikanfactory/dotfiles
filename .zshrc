# fundamental
WORDCHARS='*?_-[]~&;!#$%^(){}<>|.'

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

# editor
if builtin command -v nvim > /dev/null 2>&1; then
  export EDITOR=${EDITOR:-nvim}
else
  export EDITOR=${EDITOR:-vim}
fi

# path
export SHELL=/bin/zsh
export PATH="/usr/local/sbin:$PATH"

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
source "$ZRCDIR/peco.sh"

# export custom environment
local_env="$ZRCDIR/local_env.sh"
if [ -e $local_env ]; then
  source $local_env
fi

# auto suggestion
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# starship
eval "$(starship init zsh)"


