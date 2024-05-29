tac=${commands[tac]:-"tail -r"}

# peco history
function peco-history-selection() {
BUFFER=`\history -n 1 | eval $tac | awk '!a[$0]++' | peco`
CURSOR=$#BUFFER
  zle reset-prompt
}

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

# peco ps
function peco-ps() {
  ps auxw P
  # zle clear-screen
  zle reset-prompt
}


if command -v peco &> /dev/null
then
    # peco-history
    zle -N peco-history-selection
    bindkey '^R' peco-history-selection

    # peco-ssh
    zle -N peco-ssh
    bindkey '^\' peco-ssh

    # peco-ps
    zle -N peco-ps
    bindkey '^}' peco-ps
fi
