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

export EDITOR=/usr/bin/vim
export SHELL=/bin/zsh
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/shoji.sugai/.local/bin:$PATH"
export PATH=$HOME/.nodebrew/current/bin:$PATH

export AWS_PROFILE=andpad-production
export GOOGLE_APPLICATION_CREDENTIALS=$HOME/code/bqloader/config/gcp.json

# alias
alias :q="exit"
alias cd="pushd"
alias pop="popd"
alias end="popd"
alias dirs="dirs -v"
alias vinit="python3 -m venv venv && venv"
alias venv=". .venv/bin/activate"
alias vexit="deactivate"
alias ll='exa -bghml --git'
alias vim=/usr/bin/vim
alias diff=colordiff

# global alias
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g P="| peco"
alias -g J="| jq ."
alias -g W="| wc -l"

tac=${commands[tac]:-"tail -r"}

# peco history
function peco-history-selection() {
BUFFER=`\history -n 1 | eval $tac | awk '!a[$0]++' | peco`
CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# peco ssh
function peco-ssh() {
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

# peco ps
function peco-ps() {
  ps auxw P
  # zle clear-screen
  zle reset-prompt
}
zle -N peco-ps
bindkey '^}' peco-ps

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/shoji.sugai/code/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/shoji.sugai/code/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/shoji.sugai/code/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/shoji.sugai/code/google-cloud-sdk/completion.zsh.inc'; fi