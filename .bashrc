[[ $- != *i* ]] && return

set -o vi

export PATH=$PATH:$HOME/.local/bin
export SUDO_EDITOR=nvim

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias vi='nvim'
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias gitdot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias gitdotg='gitdot log --graph --oneline --all'
alias gitdotd='gitdot difftool --dir-diff'
alias gitg='git log --graph --oneline --all'
alias gitgf='git log --first-parent --graph --oneline --all'
alias gitd='git difftool --dir-diff'
alias weather='curl -sS v2.wttr.in | head -n-2'

CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}\W \$${RESET} "

