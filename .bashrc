#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
################################
export SUDO_EDITOR=nvim
################################
br() {
    (($1 < 10)) && return
    sudo bash -c "echo -n $1 > /sys/class/backlight/intel_backlight/brightness"
}
################################
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vpnc="sudo bash -c 'openvpn --config $HOME/.client.ovpn'"
alias gitdot='git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME'
################################
CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}\W \$${RESET} "
