#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
################################
export PATH=$PATH:$HOME/.local/bin
export SUDO_EDITOR=nvim
################################
alias vi='nvim'
alias vim='nvim'

alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'

alias gitdot='git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME'

alias vpnc="sudo bash -c 'openvpn --config $HOME/.client.ovpn'"

alias weather='curl -sS wttr.in | head -n-2'

alias webcam='mpv av://v4l2:/dev/video0 --profile=low-latency --untimed --no-osc'
################################
CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}\W \$${RESET} "
