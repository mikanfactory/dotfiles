# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# zsh theme
ZSH_THEME="af-magic"

# plugins
plugins=(git)

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
disable r

export EDITOR=/usr/local/bin/vim
export SHELL=/bin/zsh
export PATH="/usr/local/sbin:$PATH"

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="/usr/local/opt/go@1.9/bin:$PATH"

# alias
alias :q="exit"
alias cd="pushd"
alias pop="popd"
alias end="popd"
alias dirs="dirs -v"
alias vinit="virtualenv venv && venv"
alias venv=". venv/bin/activate"
alias vexit="deactivate"
alias gcd='cd $(ghq root)/$(ghq list | peco)'
# alias vim=nvim

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/s-sugai/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/s-sugai/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/s-sugai/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/s-sugai/google-cloud-sdk/completion.zsh.inc'; fi

# peco history
function peco-history-selection() {
BUFFER=`\history -n 1 | tail -r  | awk '!a[$0]++' | peco`
CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# peco ssh
function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
bindkey '^\' peco-ssh
