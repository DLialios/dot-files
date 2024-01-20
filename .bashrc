#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source $HOME/.priv
set -o vi
################################################################
export PATH=$PATH:$HOME/.local/bin
export SUDO_EDITOR=nvim
export WINEDLLOVERRIDES=winemenubuilder.exe=d
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=gasp'
export _JAVA_AWT_WM_NONREPARENTING=1
################################################################

makeBatchScript() {
    local script='$sourceuri="<bouncer_uri><res_path>"
$targetpath="$env:userprofile\<filename>"
$username="<bouncer_user>"
$password="<bouncer_pass>"
$ftpwebrequest=[system.net.ftpwebrequest]::create($sourceuri)
$ftpwebrequest.credentials=new-object system.net.networkcredential($username,$password)
$ftpwebrequest.enablessl=$true
$webresponse=$ftpwebrequest.getresponse()
$stream=$webresponse.getresponsestream()
$targetfile=new-object system.io.filestream($targetpath,[io.filemode]::create)
[byte[]]$buf=new-object byte[] 16384
do {
$readlength=$stream.read($buf,0,16384)
$targetfile.write($buf,0,$readlength)
} while ($readlength -ne 0)
$targetfile.close()'
    local p1=$1
    local res_path=${p1/$SBOX_URI/}
    local filename=${res_path##*/}
    local script_new=${script//'<res_path>'/$res_path}
    script_new=${script_new//'<filename>'/$filename}
    script_new=${script_new//'<bouncer_uri>'/$BOUNCER_URI}
    script_new=${script_new//'<bouncer_user>'/$BOUNCER_USER}
    script_new=${script_new//'<bouncer_pass>'/$BOUNCER_PASS}
    local encoded=$(echo "$script_new" | unix2dos | iconv -t utf-16le | base64 -w0 -)
    echo '@echo off' > ./$filename.bat
    echo "powershell -encoded $encoded" >> ./$filename.bat
    unix2dos ./$filename.bat
}

sboxget() {
    local p1=$1
    local uri=${p1/$SBOX_URI/$BOUNCER_URI}
    local filename=${uri##*/}
    curl --ssl -k --user $BOUNCER_USER:$BOUNCER_PASS --output $filename $uri
}

################################################################
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

alias vi='nvim'
alias vim='vi'

alias ll='ls -lah'
alias f='fd -tf -u | xargs -P 4 egrep --color=auto -n'

alias gitdot='git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME'
alias gitdotg='gitdot log --graph --oneline --all'
alias gitg='git log --graph --oneline --all'

alias loginother='chmod 640 $HOME/.Xauthority && machinectl login'
alias vpnc="sudo sh -c 'openvpn --config $HOME/.client.ovpn'"
# alias rdp="xfreerdp /u: /p: /v:0.0.0.0:0 /drive:vol1,$HOME/tmp /f /cert-ignore +clipboard -grab-keyboard"

alias webcam='mpv av://v4l2:/dev/video0 --profile=low-latency --untimed --no-osc'
alias stream='ffmpeg -f x11grab -video_size 1920x1080 -framerate 30 -i :0.0 -pix_fmt yuv420p -f v4l2 /dev/video2'
alias fixwin="wmctrl -r 'obs_viewer - Google Chrome' -e 0,100,100,1280,848"
alias mpvsync='syncplay --no-gui --no-store --player-path /usr/bin/mpv -a $SYNCPLAY_SERVER -n $USER -r $SYNCPLAY_ROOM'
alias send7z='7z a -mhe=on -p$(keepassxc-cli generate -L 256 | tee /dev/tty) -mx0 data.7z'
alias weather='curl -sS v2.wttr.in | head -n-2'

################################################################

CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}\W \$${RESET} "
