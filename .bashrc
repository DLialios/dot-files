[[ $- != *i* ]] && return

export PATH=$PATH:$HOME/.cargo/bin
export SUDO_EDITOR=vim

eval "$(fzf --bash)"

alias ls='ls --color=auto'
alias ll='ls -lah'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

alias update-openwebui="docker run \
--rm \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower --run-once --log-level debug open-webui"

CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}\W \$${RESET} "
